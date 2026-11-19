// Сервер присутствия для Synchronization в Nocturne UI.
// Хранит в памяти, кто из пользователей скрипта сейчас на каком сервере Roblox (JobId),
// их модели и цвета тем, события между ними (чат, метки, таймеры, музыка, эмоции),
// приглашения, общий онлайн, рейтинг по времени в игре и временные коды конфигов.
//
// Запуск: node presence-server.js   (Node.js 18+, без зависимостей)
// Порт берётся из переменной окружения PORT, по умолчанию 8080.
//
// API:
//   POST /presence  { userId, jobId, placeId, model?, color?, playSeconds?, since?, events? }
//                -> { users, models, colors, seq, events, online, ranking, invites }
//   POST /leave     { userId, jobId }                         -> { ok }
//   POST /invite    { userId, jobId, placeId, target }        -> { ok }
//   POST /config    { userId, jobId, config }                 -> { code }
//   POST /config/get{ userId, jobId, code }                   -> { config }
//   GET  /          -> { ok, online }

"use strict";

const http = require("http");

const PORT = Number(process.env.PORT) || 8080;
const TTL_MS = 45_000; // нет отметки 45 с = ушёл
const MAX_SESSIONS = 50_000;
const MAX_USERS_PER_SERVER = 200;
const MAX_BODY = 8 * 1024;
const MAX_CONFIG_BODY = 64 * 1024;
const MODEL_PARTS = ["Accessories", "Clothing", "Body Colors", "Face"];
const EVENT_TYPES = ["chat", "waypoint", "timer", "music", "emote"];
const EVENT_TTL_MS = 60_000;
const MAX_EVENTS_PER_SERVER = 100;
const MAX_EVENTS_PER_REQUEST = 5;
const CONFIG_TTL_MS = 60 * 60_000; // код конфига живёт час
const INVITE_TTL_MS = 5 * 60_000;

/** jobId -> { users: Map(userId -> entry), events: [], seq } */
const sessions = new Map();
/** userId -> { lastSeen, placeId, jobId, playSeconds } — для общего онлайна и рейтинга */
const everyone = new Map();
/** userId -> [{ from, placeId, jobId, at }] */
const inboxes = new Map();
/** code -> { config, at } */
const configs = new Map();

function cleanup() {
	const now = Date.now();
	for (const [jobId, session] of sessions) {
		for (const [userId, entry] of session.users) {
			if (now - entry.lastSeen > TTL_MS) session.users.delete(userId);
		}
		session.events = session.events.filter((event) => now - event.at <= EVENT_TTL_MS);
		if (session.users.size === 0) sessions.delete(jobId);
	}
	for (const [userId, entry] of everyone) {
		if (now - entry.lastSeen > TTL_MS) everyone.delete(userId);
	}
	for (const [userId, list] of inboxes) {
		const fresh = list.filter((invite) => now - invite.at <= INVITE_TTL_MS);
		if (fresh.length) inboxes.set(userId, fresh);
		else inboxes.delete(userId);
	}
	for (const [code, entry] of configs) {
		if (now - entry.at > CONFIG_TTL_MS) configs.delete(code);
	}
}
setInterval(cleanup, 15_000).unref();

function send(res, status, body) {
	res.writeHead(status, { "Content-Type": "application/json", "Cache-Control": "no-store" });
	res.end(JSON.stringify(body));
}

function parseInput(data) {
	const userId = Number(data && data.userId);
	const jobId = String((data && data.jobId) || "");
	if (!Number.isSafeInteger(userId) || userId <= 0) return null;
	if (!/^[A-Za-z0-9-]{1,64}$/.test(jobId)) return null;
	return { userId, jobId };
}

function parseModel(raw) {
	if (!raw || typeof raw !== "object") return null;
	const userId = Number(raw.userId);
	if (!Number.isSafeInteger(userId) || userId <= 0) return null;
	const parts = Array.isArray(raw.parts)
		? [...new Set(raw.parts.filter((part) => MODEL_PARTS.includes(part)))]
		: MODEL_PARTS.slice();
	return { userId, parts };
}

function parseColor(raw) {
	const text = String(raw || "").replace(/^#/, "");
	return /^[0-9a-fA-F]{6}$/.test(text) ? text.toLowerCase() : null;
}

// События: только известные типы, данные — небольшой объект; текст ограничиваем.
function parseEvent(raw) {
	if (!raw || typeof raw !== "object" || !EVENT_TYPES.includes(raw.type)) return null;
	const data = raw.data && typeof raw.data === "object" ? raw.data : {};
	const clean = {};
	for (const [key, value] of Object.entries(data).slice(0, 8)) {
		if (typeof value === "number" && Number.isFinite(value)) clean[key] = value;
		else if (typeof value === "string") clean[key] = value.slice(0, 200);
		else if (typeof value === "boolean") clean[key] = value;
	}
	return { type: raw.type, data: clean };
}

function readBody(req, limit, callback) {
	let raw = "";
	let tooBig = false;
	req.on("data", (chunk) => {
		raw += chunk;
		if (raw.length > limit) {
			tooBig = true;
			req.destroy();
		}
	});
	req.on("end", () => {
		if (tooBig) return;
		try {
			callback(JSON.parse(raw));
		} catch {
			callback(null);
		}
	});
}

function makeCode() {
	const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
	let code;
	do {
		code = "";
		for (let i = 0; i < 6; i++) code += alphabet[Math.floor(Math.random() * alphabet.length)];
	} while (configs.has(code));
	return code;
}

function handlePresence(res, data, input) {
	let session = sessions.get(input.jobId);
	if (!session) {
		if (sessions.size >= MAX_SESSIONS) return send(res, 503, { error: "server is full" });
		session = { users: new Map(), events: [], seq: 0 };
		sessions.set(input.jobId, session);
	}
	if (!session.users.has(input.userId) && session.users.size >= MAX_USERS_PER_SERVER) {
		return send(res, 503, { error: "too many users on this server" });
	}
	const now = Date.now();
	session.users.set(input.userId, {
		lastSeen: now,
		model: parseModel(data.model),
		color: parseColor(data.color),
	});
	const playSeconds = Math.max(0, Math.min(Number(data.playSeconds) || 0, 7 * 24 * 3600));
	everyone.set(input.userId, { lastSeen: now, placeId: Number(data.placeId) || 0, jobId: input.jobId, playSeconds });

	// новые события от этого пользователя
	if (Array.isArray(data.events)) {
		for (const raw of data.events.slice(0, MAX_EVENTS_PER_REQUEST)) {
			const event = parseEvent(raw);
			if (!event) continue;
			session.seq += 1;
			session.events.push({ seq: session.seq, from: input.userId, at: now, ...event });
		}
		if (session.events.length > MAX_EVENTS_PER_SERVER) {
			session.events.splice(0, session.events.length - MAX_EVENTS_PER_SERVER);
		}
	}

	const others = [];
	const models = {};
	const colors = {};
	for (const [userId, entry] of session.users) {
		if (userId === input.userId || now - entry.lastSeen > TTL_MS) continue;
		others.push(userId);
		if (entry.model) models[String(userId)] = entry.model;
		if (entry.color) colors[String(userId)] = entry.color;
	}

	const since = Number(data.since);
	const events = since >= 0
		? session.events.filter((event) => event.seq > since).map(({ at, ...event }) => event)
		: [];

	const ranking = [...everyone.entries()]
		.sort((a, b) => b[1].playSeconds - a[1].playSeconds)
		.slice(0, 10)
		.map(([userId, entry]) => ({ userId, seconds: entry.playSeconds }));

	const invites = (inboxes.get(input.userId) || []).map(({ at, ...invite }) => invite);
	inboxes.delete(input.userId);

	send(res, 200, {
		users: others,
		models,
		colors,
		seq: session.seq,
		events,
		online: everyone.size,
		ranking,
		invites,
	});
}

const server = http.createServer((req, res) => {
	const path = (req.url || "/").split("?")[0];

	if (req.method === "GET" && path === "/") return send(res, 200, { ok: true, online: everyone.size });
	if (req.method !== "POST") return send(res, 404, { error: "not found" });

	const limit = path === "/config" ? MAX_CONFIG_BODY : MAX_BODY;
	readBody(req, limit, (data) => {
		if (!data) return send(res, 400, { error: "bad json" });
		const input = parseInput(data);
		if (!input) return send(res, 400, { error: "bad input" });

		if (path === "/presence") return handlePresence(res, data, input);

		if (path === "/leave") {
			const session = sessions.get(input.jobId);
			if (session) session.users.delete(input.userId);
			everyone.delete(input.userId);
			return send(res, 200, { ok: true });
		}

		if (path === "/invite") {
			const target = Number(data.target);
			const placeId = Number(data.placeId);
			if (!Number.isSafeInteger(target) || target <= 0 || !Number.isSafeInteger(placeId)) {
				return send(res, 400, { error: "bad invite" });
			}
			const list = inboxes.get(target) || [];
			list.push({ from: input.userId, placeId, jobId: input.jobId, at: Date.now() });
			inboxes.set(target, list.slice(-10));
			return send(res, 200, { ok: true });
		}

		if (path === "/config") {
			if (typeof data.config !== "string" || data.config.length > MAX_CONFIG_BODY) {
				return send(res, 400, { error: "bad config" });
			}
			const code = makeCode();
			configs.set(code, { config: data.config, at: Date.now() });
			return send(res, 200, { code });
		}

		if (path === "/config/get") {
			const entry = configs.get(String(data.code || "").toUpperCase());
			if (!entry) return send(res, 404, { error: "code not found" });
			return send(res, 200, { config: entry.config });
		}

		send(res, 404, { error: "not found" });
	});
});

server.listen(PORT, () => {
	console.log(`Nocturne presence server listening on port ${PORT}`);
});
