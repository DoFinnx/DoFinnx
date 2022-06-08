
------------------------[Меню]------------------------------------
function start()
startmenu = gg.choice({
	"Legit", 
	"Rage", 
	"Chams",
	"Info",
	"Exit"
},nil,"RedSoft")
if startmenu == 1 then legit() end
if startmenu == 2 then rage() end
if startmenu == 3 then chams() end
if startmenu == 4 then info() end
if startmenu == 5 then quit() end
end

function legit()
legitmenu = gg.choice({
	"Aim Menu",
	"Norecoil Menu",
	"RadarHack",
	"Cfg Builder",
	"Back"
},nil,"Script By RedSoft")
if legitmenu == 1 then aim() end
if legitmenu == 2 then recoil() end
if legitmenu == 3 then radar() end
if legitmenu == 4 then cfg() end
if legitmenu == 5 then start() end
end

function rage() 
ragemenu = gg. multiChoice({
   "Fire Rate[Lobby]", 
   "Inf Ammo", 
   "WallShot", 
   "Aim Menu", 
   "NoRecoil Menu", 
   "Don't Return Spawn", 
   "Don't Block Move", 
   "AntiFlash", 
   "AntiSmoke", 
   "ExpHack", 
   "MoneyHack", 
   "BuyHack", 
   "DamageHack", 
   "Disable Kill Animation", 
   "Air Jump", 
   "FastBomb", 
   "FastPlant", 
   "Plant Any Where", 
   "Fov Menu", 
   "Immunity Yo Grenade", 
   "NoHud", 
   "Friendly Fire[Visual]", 
   "Respawn Hack", 
   "SpeedHack", 
   "BlackSky", 
   "Back"
},nil, "RedSoft Script") 
if ragemenu[1] == true then Firerate() end
if ragemenu[2] == true then Inf() end
if ragemenu[3] == true then WallShot() end
if ragemenu[4] == true then aim() end
if ragemenu[5] == true then recoil() end
if ragemenu[6] == true then DontSpawn() end
if ragemenu[7] == true then DontReturn() end
if ragemenu[8] == true then AntiFlash() end
if ragemenu[9] == true then AntiSmoke() end
if ragemenu[10] == true then ExpHack() end
if ragemenu[11] == true then Money() end
if ragemenu[12] == true then Buy() end
if ragemenu[13] == true then Damage() end
if ragemenu[14] == true then Disable() end
if ragemenu[15] == true then Air() end
if ragemenu[16] == true then Fastbomb() end
if ragemenu[17] == true then FastPlant() end
if ragemenu[18] == true then Plant() end
if ragemenu[19] == true then Fov() end
if ragemenu[20] == true then Imm() end
if ragemenu[21] == true then Ff() end
if ragemenu[22] == true then Respawn() end
if ragemenu[23] == true then Speed() end
if ragemenu[24] == true then BlackSky() end
if ragemenu[25] == true then start() end
end

function Firerate() 
fr = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if fr  == 1 then  on1() end
if fr  == 2 then off1()end
if fr  == 3 then start() end
end

function Inf() 
inf = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if inf  == 1 then  on2() end
if inf  == 2 then off2() end
if inf  == 3 then start() end
end

function WallShot() 
ws = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if ws == 1 then  on3() end
if ws == 2 then off3()end
if ws == 3 then start() end
end

function DontSpawn() 
ds = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if ds == 1 then  on4() end
if fs== 2 then off4()end
if ds == 3 then start() end
end

function DontReturn() 
dr = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if dr == 1 then  on5() end
if dr == 2 then off5()end
if dr == 3 then start() end
end

function AntiSmoke() 
as = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if as == 1 then  on6() end
if as == 2 then off6()end
if as == 3 then start() end
end

function AntiFlash() 
af = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if af == 1 then  on7() end
if af == 2 then off7()end
if af == 3 then start() end
end

function ExpHack() 
eh = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if eh == 1 then  on8() end
if eh == 2 then off8()end
if eh == 3 then start() end
end

function Money() 
m = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if m == 1 then  on9() end
if m == 2 then off9()end
if m == 3 then start() end
end

function Damage() 
d = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if d == 1 then  on10() end
if d == 2 then off10()end
if d == 3 then start() end
end

function Disable() 
di = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if di == 1 then  on11() end
if di == 2 then off11()end
if di == 3 then start() end
end

function Air() 
a = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if a == 1 then  on12() end
if a == 2 then off12()end
if a == 3 then start() end
end

function FastBomb() 
fb = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if fb == 1 then  on13() end
if fb == 2 then off13()end
if fb == 3 then start() end
end

function FastPlant() 
fp = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if fp == 1 then  on14() end
if fp == 2 then off15()end
if fp == 3 then start() end
end

function Plant() 
p = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if p == 1 then  on16() end
if p == 2 then off16()end
if p == 3 then start() end
end

function Fov() 
f = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if f == 1 then  on17() end
if f == 2 then off17()end
if f == 3 then start() end
end

function imm() 
i = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if i == 1 then  on18() end
if i == 2 then off18()end
if i == 3 then start() end
end

function Ff() 
ff = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if ff == 1 then  on19() end
if ff == 2 then off19()end
if ff == 3 then start() end
end

function Respawn() 
r = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if r == 1 then  on20() end
if r == 2 then off20()end
if r == 3 then start() end
end

function Speed() 
s = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if s == 1 then  on21() end
if s == 2 then off21()end
if s == 3 then start() end
end

function BlackSky() 
bs = gg.choice({
  "On", 
  "Off", 
  "Back", 
},nil,"ʙʏ RedSoft")
if bs == 1 then  on22() end
if bs == 2 then off22()end
if bs == 3 then start() end
end

function chams()
chamsmenu = gg.multiChoice({
    "Blue",
	"Green",
	"Rer",
	"Rainbow"
	"Back"
}, nil , "𝐁𝐥𝐞𝐧𝐝𝐞𝐫𝐂𝐡𝐚𝐦𝐬")
if chamsmenu[1] == true then Blue() end 
if chamsmenu[2] == true then Green() end
if chamsmenu[3] == true then Red() end
if chamsmenu[4] == true then Rainbow() end
if chamsmenu[5] == true then start() end
end


function aim()
aimmenu = gg.choice({
	    "SuperLegitAim",
		"LegitAim",
		"MediumAim ", 
		"HardAim", 
		"SkyAim ", 
		"Off",
		"Back"
},nil,"ʙʏ RedSoft")
if aimmenu == 1 then superlegit() end
if aimmenu == 2 then legitt() end
if aimmenu == 3 then Medium() end
if aimmenu == 4 then Hard() end
if aimmenu == 5 then Sky() end
if aimmenu == 6 then offaim() end	
if aimmenu == 7 then start() end	
end

function recoil()
recoilmenu = gg.choice({
		"25%",
		"50%",
		"75%",
		"100%",
		"0%",
		"Back"
},nil,"ʙʏ RedSoft")
if recoilmenu == 1 then recoil25() end
if recoilmenu == 2 then recoil50() end
if recoilmenu == 3 then recoil75() end
if recoilmenu == 4 then recoil100() end
if recoilmenu == 5 then offrecoil() end
if recoilmenu == 6 then start() end	
end

function radar()
radarmenu = gg.choice({
		"RadarHack On",
		"RadarHack Off",
		"Back"
	},nil,"ʙʏ RedSoft")
if radarmenu == 1 then radaron() end
if radarmenu == 2 then radaroff() end
if radarmenu == 3 then start() end	
end

---------------------------------------------------------------------


------------------------[Функции]------------------------------------
function superlegit() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
13429
Var #B9C66204|b9c66204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d66204
Var #B9C67094|b9c67094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d67094
Var #B9C90938|b9c90938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90938
Var #B9C90B14|b9c90b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90b14
Var #B9C91D84|b9c91d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d91d84
Var #B9E8F390|b9e8f390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|f8f390
Var #C04179B0|c04179b0|4|3e19999a|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libunity.so|1f09b0


]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ꜱᴜᴘᴇʀʟᴇɢɪᴛ ᴀɪᴍ Activated")
end

function legitt() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
13429
Var #B9C66204|b9c66204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d66204
Var #B9C67094|b9c67094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d67094
Var #B9C90938|b9c90938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90938
Var #B9C90B14|b9c90b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90b14
Var #B9C91D84|b9c91d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d91d84
Var #B9E8F390|b9e8f390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|f8f390
Var #C04179B0|c04179b0|4|3e3851ec|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libunity.so|1f09b0


]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ʟᴇɢɪᴛ ᴀɪᴍ Activated")
end

function Medium() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
13429
Var #B9C66204|b9c66204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d66204
Var #B9C67094|b9c67094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d67094
Var #B9C90938|b9c90938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90938
Var #B9C90B14|b9c90b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90b14
Var #B9C91D84|b9c91d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d91d84
Var #B9E8F390|b9e8f390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|f8f390
Var #C04179B0|c04179b0|4|3ecccccd|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libunity.so|1f09b0



]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ꜱᴜᴘᴇʀʟᴇɢɪᴛ ᴀɪᴍ Activated")
end

function Hard() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
13429
Var #B9C66204|b9c66204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d66204
Var #B9C67094|b9c67094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d67094
Var #B9C90938|b9c90938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90938
Var #B9C90B14|b9c90b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90b14
Var #B9C91D84|b9c91d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d91d84
Var #B9E8F390|b9e8f390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|f8f390
Var #C04179B0|c04179b0|4|3f4ccccd|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libunity.so|1f09b0



]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ʟᴇɢɪᴛ ᴀɪᴍ Activated")
end

function Sky() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
13429
Var #B9C66204|b9c66204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d66204
Var #B9C67094|b9c67094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d67094
Var #B9C90938|b9c90938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90938
Var #B9C90B14|b9c90b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90b14
Var #B9C91D84|b9c91d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d91d84
Var #B9E8F390|b9e8f390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|f8f390
Var #C04179B0|c04179b0|4|41d80000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libunity.so|1f09b0


]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("SkyAim Activated")
end




function offaim() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
13429
Var #B9C66204|b9c66204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d66204
Var #B9C67094|b9c67094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d67094
Var #B9C90938|b9c90938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90938
Var #B9C90B14|b9c90b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d90b14
Var #B9C91D84|b9c91d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|d91d84
Var #B9E8F390|b9e8f390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libil2cpp.so|f8f390
Var #C04179B0|c04179b0|4|3727c5ac|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-mTDZw4mUY0-Ltz1y8t9DJw==/lib/arm/libunity.so|1f09b0

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ᴀɪᴍ DeActivated")
end

function recoil25() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1D54878|c1d54878|4|44070000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|27e878

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ɴᴏʀᴇᴄᴏɪʟ Activated")
end

function recoil50() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1D54878|c1d54878|4|44340000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|27e878

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ɴᴏʀᴇᴄᴏɪʟ Activated")
end

function recoil75() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1D54878|c1d54878|4|44610000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|27e878

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ɴᴏʀᴇᴄᴏɪʟ Activated")
end

function recoil100() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1D54878|c1d54878|4|47c35000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|27e878

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ɴᴏʀᴇᴄᴏɪʟ Activated")
end

function offrecoil() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1D54878|c1d54878|4|43b40000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|27e878

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ɴᴏʀᴇᴄᴏɪʟ DeActivated")
end

function radaron() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BC19D8|c1bc19d8|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8c09d8
Var #C1BC19DC|c1bc19dc|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8c09dc

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ʀᴀᴅᴀʀʜᴀᴄᴋ Activated")
end

function radaroff() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
1337
Var #B6C6F0B0|b6c6f0b0|4|e92d4df0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-behNqTjLlT0Cn0XHIPVYog==/lib/arm/libil2cpp.so|9ab658
Var #B6C6F0B4|b6c6f0b4|4|e28db018|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-behNqTjLlT0Cn0XHIPVYog==/lib/arm/libil2cpp.so|9ab65c
]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ʀᴀᴅᴀʀʜᴀᴄᴋ DeActivated")
end

function on23() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C8AC7FEC|c8ac7fec|4|bf800000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|391fec

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("BlackSky Activated")
end

function on22() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #BB60957C|bb60957c|4|42a00000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e7857c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("SpeedHack Activated")
end

function on21() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1B97A2C|c1b97a2c|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|896a2c
Var #C1B97A30|c1b97a30|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|896a30
Var #C2067204|c2067204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d66204
Var #C2068094|c2068094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d67094
Var #C2091938|c2091938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d90938
Var #C2091B14|c2091b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d90b14
Var #C2092D84|c2092d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d91d84
Var #C2290390|c2290390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|f8f390

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("RespawnHack Activated")
end

function on20() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C216E904|c216e904|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e6d904
Var #C216E908|c216e908|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e6d908

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Friendly Fire Activated")
end

function on19() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #BB2F6760|bb2f6760|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|b65760

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Immunity to Grenada Activated")
end

function on18() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1EC9DB8|c1ec9db8|4|438c0000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|3f3db8

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Fov Activated")
end

function on16() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2127C00|c2127c00|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c00
Var #C2127C04|c2127c04|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c04
Var #C2127C58|c2127c58|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c58
Var #C2127C5C|c2127c5c|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c5c
Var #C2127CA0|c2127ca0|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26ca0
Var #C2127CA4|c2127ca4|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26ca4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Plant AnyWhere Activated")
end

function on15() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2120178|c2120178|4|e3a00000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e1f178
Var #C212017C|c212017c|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e1f17c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("FastPlant Activated")
end

function on14() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2124E94|c2124e94|4|e3400000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e23e94
Var #C2124E98|c2124e98|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e23e98

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("FastBomb Activated")
end

function on13() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C38634E4|c38634e4|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|25624e4
Var #C38634E8|c38634e8|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|25624e8

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("AirJump Activated")
end

function on12() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2190EB4|c2190eb4|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e8feb4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Disable Kill Animation Activated")
end

function on11() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1DEF4BC|c1def4bc|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4bc
Var #C1DEF4C0|c1def4c0|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4c0
Var #C1DEF4E4|c1def4e4|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4e4
Var #C1DEF4E8|c1def4e8|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4e8
Var #C1DEF50C|c1def50c|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee50c
Var #C1DEF510|c1def510|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee510
Var #C1DEF534|c1def534|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee534
Var #C1DEF538|c1def538|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee538
Var #C1DEF9B0|c1def9b0|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9b0
Var #C1DEF9B4|c1def9b4|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9b4
Var #C1DEF9E0|c1def9e0|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9e0
Var #C1DEF9E4|c1def9e4|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9e4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Damage Activated")
end

function on10() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1B93E80|c1b93e80|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|892e80
Var #C1B93E84|c1b93e84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|892e84
Var #C1B94D74|c1b94d74|4|e3a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|893d74
Var #C1B94D78|c1b94d78|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|893d78
Var #C1B98188|c1b98188|4|e3471f7f|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|897188
Var #C1B9818C|c1b9818c|4|e1a00001|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|89718c
Var #C1B98190|c1b98190|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|897190

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("BuyHack Activated")
end

function on9() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BA84CC|c1ba84cc|4|e3a00000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a74cc
Var #C1BA84D0|c1ba84d0|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a74d0

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("MoneyHack Activated")
end

function on8() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BA92D0|c1ba92d0|4|e3a00dfa|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a82d0
Var #C1BA92D4|c1ba92d4|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a82d4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ExpHack Activated")
end

function on7() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1F0F900|c1f0f900|4|0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|439900
Var #C1F0F904|c1f0f904|4|0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|439904
Var #C1F0F908|c1f0f908|4|0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|439908
Var #C1F0F90C|c1f0f90c|4|0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|43990c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("AntiSmoke Activated")
end

function on6() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #BB5C6848|bb5c6848|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e35848

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("AntiFlash Activated")
end

function on5() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C25A799C|c25a799c|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|12a699c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Dont Block Move Activated")
end

function on4() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BA67EC|c1ba67ec|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a57ec

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Dont Return Spawn Activated")
end

function on3() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C24C34A8|c24c34a8|4|c7c34f80|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|9ed4a8

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("WallShot Activated")
end

function on2() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C230EE88|c230ee88|4|e3000d05|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|100de88
Var #C230EE8C|c230ee8c|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|100de8c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("infAmmo Activated")
end

function on1() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C8AC7FEC|c8ac7fec|4|3c23d70a|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|391fec

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("FireRate Activated")
end

function off22() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #BB60957C|bb60957c|4|17|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e7857c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("BlackSky DeActivated")
end

function off21() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1B97A2C|c1b97a2c|4|e92d4830|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|896a2c
Var #C1B97A30|c1b97a30|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|896a30
Var #C2067204|c2067204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d66204
Var #C2068094|c2068094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d67094
Var #C2091938|c2091938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d90938
Var #C2091B14|c2091b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d90b14
Var #C2092D84|c2092d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d91d84
Var #C2290390|c2290390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|f8f390

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("SpeedHack DeActivated")
end

function off20() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1B97A2C|c1b97a2c|4|e92d4830|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|896a2c
Var #C1B97A30|c1b97a30|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|896a30
Var #C2067204|c2067204|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d66204
Var #C2068094|c2068094|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d67094
Var #C2091938|c2091938|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d90938
Var #C2091B14|c2091b14|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d90b14
Var #C2092D84|c2092d84|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|d91d84
Var #C2290390|c2290390|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|f8f390

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("RespawnHack DeActivated")
end

function off19() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C216E904|c216e904|4|e92d48f0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e6d904
Var #C216E908|c216e908|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e6d908

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Friendly Fire DeActivated")
end

function off18() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #BB2F6760|bb2f6760|4|2d5674c|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|b65760

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Immunity to Grenada DeActivated")
end

function off17() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C1EC9DB8|c1ec9db8|4|43b40000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|3f3db8

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Fov DeActivated")
end

function off16() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2127C00|c2127c00|4|e92d4c70|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c00
Var #C2127C04|c2127c04|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c04
Var #C2127C58|c2127c58|4|e92d48f0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c58
Var #C2127C5C|c2127c5c|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26c5c
Var #C2127CA0|c2127ca0|4|e92d4830|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26ca0
Var #C2127CA4|c2127ca4|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e26ca4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Plant AnyWhere DeActivated")
end

function off15() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2120178|c2120178|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e1f178
Var #C212017C|c212017c|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e1f17c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("FastPlant DeActivated")
end

function off14() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2124E94|c2124e94|4|e92d4c70|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e23e94
Var #C2124E98|c2124e98|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e23e98

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("FastBomb DeActivated")
end

function off13() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C38634E4|c38634e4|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|25624e4
Var #C38634E8|c38634e8|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|25624e8

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("AirJump DeActivated")
end

function off12() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C2190EB4|c2190eb4|4|e92d4ff0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e8feb4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Disable Kill Animation DeActivated")
end

function off11() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1DEF4BC|c1def4bc|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4bc
Var #C1DEF4C0|c1def4c0|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4c0
Var #C1DEF4E4|c1def4e4|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4e4
Var #C1DEF4E8|c1def4e8|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee4e8
Var #C1DEF50C|c1def50c|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee50c
Var #C1DEF510|c1def510|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee510
Var #C1DEF534|c1def534|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee534
Var #C1DEF538|c1def538|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee538
Var #C1DEF9B0|c1def9b0|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9b0
Var #C1DEF9B4|c1def9b4|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9b4
Var #C1DEF9E0|c1def9e0|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9e0
Var #C1DEF9E4|c1def9e4|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|aee9e4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Damage DeActivated")
end

function off10() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1B93E80|c1b93e80|4|e92d4c70|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|892e80
Var #C1B93E84|c1b93e84|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|892e84
Var #C1B94D74|c1b94d74|4|e92d4c70|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|893d74
Var #C1B94D78|c1b94d78|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|893d78
Var #C1B98188|c1b98188|4|e92d48f0|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|897188
Var #C1B9818C|c1b9818c|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|89718c
Var #C1B98190|c1b98190|4|e59f508c|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|897190

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("BuyHack DeActivated")
end

function off9() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BA84CC|c1ba84cc|4|e92d4c70|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a74cc
Var #C1BA84D0|c1ba84d0|4|e28db010|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a74d0

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("MoneyHack DeActivated")
end

function off8() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BA92D0|c1ba92d0|4|e92d4830|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a82d0
Var #C1BA92D4|c1ba92d4|4|e28db008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a82d4

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("ExpHack DeActivated")
end

function off7() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C8B6F900|c8b6f900|4|42c80000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|439900
Var #C8B6F904|c8b6f904|4|42c80000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|439904
Var #C8B6F908|c8b6f908|4|42c80000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|439908
Var #C8B6F90C|c8b6f90c|4|42c80000|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|43990c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("AntiSmoke DeActivated")
end

function off6() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #BB5C6848|bb5c6848|4|2f6d484|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|e35848

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("AntiFlash DeActivated")
end

function off5() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C25A799C|c25a799c|4|e12fff1e|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|12a699c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Dont Block Move DeActivated")
end

function off4() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1BA67EC|c1ba67ec|4|e92d4c70|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|8a57ec

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("Dont Return Spawn DeActivated")
end

function off3() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
31928
Var #C24C34A8|c24c34a8|4|3a83126f|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libunity.so|9ed4a8

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("WallShot DeActivated")
end

function off2() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C230EE88|c230ee88|4|e5901008|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|100de88
Var #C230EE8C|c230ee8c|4|e590000c|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|100de8c

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("infAmmo DeActivated")
end

function off1() -- 0.19.1 p2
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[]]):close()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
17084
Var #C1E71950|c1e71950|4|e92d4c10|0|0|0|0|r-xp|/data/app/com.axlebolt.standoff2-HQwPZOqOo19XnT4EN32eQQ==/lib/arm/libil2cpp.so|b70950

]]):close()
gg.loadList(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", gg.LOAD_VALUES)
gg.clearList()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[
fuck u xd
]]):close()
gg.toast("FireRate DeActivated")
end

function Blue()
gg.clearResults()
gg.setRanges(gg.REGIon_ANonYMOUS)
gg.searchNumber("1073741894", gg.TYPE_DWORD)
gg.refineNumber("1073741894", gg.TYPE_DWORD)
gg.refineNumber("1073741894", gg.TYPE_DWORD)
gg.refineNumber("1073741894", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741899', gg.TYPE_DWORD)
gg.toast("𝗯𝗹𝘂𝗲 𝗰𝗵𝗮𝗺𝘀 𝗮𝗰𝘁𝗶𝘃𝗮𝘁𝗲𝗱")
gg.clearResults()
end

function Green()
gg.clearResults()
gg.setRanges(gg.REGIon_ANonYMOUS)
gg.searchNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741904', gg.TYPE_DWORD)
gg.toast("𝗴𝗿𝗲𝗲𝗻 𝗰𝗵𝗮𝗺𝘀 𝗮𝗰𝘁𝗶𝘃𝗮𝘁𝗲𝗱")
gg.clearResults()
end

function Red()
gg.clearResults()
gg.setRanges(gg.REGIon_ANonYMOUS)
gg.searchNumber("1073741892", gg.TYPE_DWORD)
gg.refineNumber("1073741892", gg.TYPE_DWORD)
gg.refineNumber("1073741892", gg.TYPE_DWORD)
gg.refineNumber("1073741892", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741899', gg.TYPE_DWORD)
gg.toast("𝗿𝗲𝗱 𝗰𝗵𝗮𝗺𝘀 𝗮𝗰𝘁𝗶𝘃𝗮𝘁𝗲𝗱")
gg.clearResults()
end


function Rainbow()
gg.clearResults()
gg.setRanges(gg.REGIon_ANonYMOUS)
gg.searchNumber("1073741859", gg.TYPE_DWORD)
gg.refineNumber("1073741859", gg.TYPE_DWORD)
gg.refineNumber("1073741859", gg.TYPE_DWORD)
gg.refineNumber("1073741859", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741903', gg.TYPE_DWORD)
gg.toast("𝗿𝗮𝗶𝗻𝗯𝗼𝘄 𝗰𝗵𝗮𝗺𝘀 𝗮𝗰𝘁𝗶𝘃𝗮𝘁𝗲𝗱")
gg.clearResults()
end
---------------------------------------------------------------------
function cfg()
cont = gg.makeRequest("https://waithware-private.000webhostapp.com/waithlegit/cfg.lua").content
pcall(load(cont))
end
------------------------[Важное]------------------------------------
function quit()
io.open(gg.EXT_CACHE_DIR .. "/RedSoft.cfg", "w+"):write([[ɪꜰ ᴜ ᴡɪʟʟ ᴛʀʏ ᴛᴏ ꜱᴛᴇᴀʟ ʟᴏᴀᴅʟɪꜱᴛꜱ, ɪ ᴋɪʟʟ ᴜʀ ꜰᴀᴍɪʟʏ]]):close()
gg.alert("ᴄʜᴇᴀᴛ ꜱᴛᴏᴘᴘᴇᴅ")
gg.toast("T.ME/red_s0ft")
os.exit() 
end

function info()
gg.alert("ᴄʀᴇᴅɪᴛꜱ:\n T.ME/red_s0ft")
end

while true do 
	  menuend = 0
	    if gg.isVisible(true) then
	       gg.setVisible(false)
	       menuend = 1
	       if menuend == 1 then
	           start()
	           	end
end
end
