// Сервер присутствия для Synchronization в Nocturne UI.
// Хранит в памяти, кто из пользователей скрипта сейчас на каком сервере Roblox (JobId)
// и какую кастомную модель он надел, и каждому отдаёт эти данные об остальных на том же сервере.
//
// Запуск: node presence-server.js   (Node.js 18+, без зависимостей)
// Порт берётся из переменной окружения PORT (так делают Render/Railway и т.п.), по умолчанию 8080.
//
// API:
//   POST /presence  { "userId": 123, "jobId": "...", "placeId": 456,
//                     "model": { "userId": 789, "parts": ["Accessories", "Clothing"] } }   // model — необязательно
//                -> { "users": [111, 222], "models": { "111": { "userId": 789, "parts": [...] } } }
//   POST /leave     { "userId": 123, "jobId": "..." }  ->  { "ok": true }
//   GET  /          -> { "ok": true, "online": N }   (проверка, что сервер жив)

"use strict";

const http = require("http");

const PORT = Number(process.env.PORT) || 8080;
const TTL_MS = 45_000; // клиент шлёт отметку раз в 15 с; 45 с без отметки = ушёл
const MAX_SESSIONS = 50_000; // защита от переполнения памяти
const MAX_USERS_PER_SERVER = 200;
const MAX_BODY = 2048;
const MODEL_PARTS = ["Accessories", "Clothing", "Body Colors", "Face"];

/** jobId -> Map(userId -> { lastSeen, model }) */
const sessions = new Map();

function cleanup() {
	const now = Date.now();
	for (const [jobId, users] of sessions) {
		for (const [userId, entry] of users) {
			if (now - entry.lastSeen > TTL_MS) users.delete(userId);
		}
		if (users.size === 0) sessions.delete(jobId);
	}
}
setInterval(cleanup, 15_000).unref();

function onlineCount() {
	let total = 0;
	for (const users of sessions.values()) total += users.size;
	return total;
}

function send(res, status, body) {
	res.writeHead(status, {
		"Content-Type": "application/json",
		"Cache-Control": "no-store",
	});
	res.end(JSON.stringify(body));
}

function parseInput(data) {
	const userId = Number(data && data.userId);
	const jobId = String((data && data.jobId) || "");
	if (!Number.isSafeInteger(userId) || userId <= 0) return null;
	if (!/^[A-Za-z0-9-]{1,64}$/.test(jobId)) return null;
	return { userId, jobId };
}

// Кастомная модель: чей аватар надет и какие части скопированы.
function parseModel(raw) {
	if (!raw || typeof raw !== "object") return null;
	const userId = Number(raw.userId);
	if (!Number.isSafeInteger(userId) || userId <= 0) return null;
	const parts = Array.isArray(raw.parts)
		? [...new Set(raw.parts.filter((part) => MODEL_PARTS.includes(part)))]
		: MODEL_PARTS.slice();
	return { userId, parts };
}

const server = http.createServer((req, res) => {
	const path = (req.url || "/").split("?")[0];

	if (req.method === "GET" && path === "/") {
		return send(res, 200, { ok: true, online: onlineCount() });
	}
	if (req.method !== "POST" || (path !== "/presence" && path !== "/leave")) {
		return send(res, 404, { error: "not found" });
	}

	let raw = "";
	let tooBig = false;
	req.on("data", (chunk) => {
		raw += chunk;
		if (raw.length > MAX_BODY) {
			tooBig = true;
			req.destroy();
		}
	});
	req.on("end", () => {
		if (tooBig) return;
		let data;
		try {
			data = JSON.parse(raw);
		} catch {
			return send(res, 400, { error: "bad json" });
		}
		const input = parseInput(data);
		if (!input) return send(res, 400, { error: "bad input" });

		let users = sessions.get(input.jobId);

		if (path === "/leave") {
			if (users) users.delete(input.userId);
			return send(res, 200, { ok: true });
		}

		if (!users) {
			if (sessions.size >= MAX_SESSIONS) return send(res, 503, { error: "server is full" });
			users = new Map();
			sessions.set(input.jobId, users);
		}
		if (!users.has(input.userId) && users.size >= MAX_USERS_PER_SERVER) {
			return send(res, 503, { error: "too many users on this server" });
		}
		users.set(input.userId, { lastSeen: Date.now(), model: parseModel(data.model) });

		const now = Date.now();
		const others = [];
		const models = {};
		for (const [userId, entry] of users) {
			if (userId === input.userId || now - entry.lastSeen > TTL_MS) continue;
			others.push(userId);
			if (entry.model) models[String(userId)] = entry.model;
		}
		send(res, 200, { users: others, models });
	});
});

server.listen(PORT, () => {
	console.log(`Nocturne presence server listening on port ${PORT}`);
});
