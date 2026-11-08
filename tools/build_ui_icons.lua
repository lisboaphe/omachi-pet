-- Pixel-art HUD icons for the panel. Drawn 1:1 and shown at 2x with smoothing off.
--
--   aseprite -b --script-param out=assets/ui --script tools/build_ui_icons.lua

local pc = app.pixelColor
local out = app.params.out

local P = {
  K = pc.rgba(16, 22, 48, 255),     -- outline
  W = pc.rgba(250, 250, 244, 255),  -- highlight / white
  R = pc.rgba(232, 72, 84, 255), r = pc.rgba(160, 40, 62, 255),   -- red
  G = pc.rgba(110, 200, 110, 255),  -- leaf green
  B = pc.rgba(122, 82, 52, 255),    -- brown
  Y = pc.rgba(255, 214, 80, 255), y = pc.rgba(222, 150, 40, 255),  -- yellow
  H = pc.rgba(182, 231, 203, 255), h = pc.rgba(120, 178, 150, 255), -- mint (brand)
  D = pc.rgba(108, 78, 62, 255),    -- door
  P = pc.rgba(150, 168, 206, 255),  -- gamepad
  M = pc.rgba(156, 188, 237, 255), m = pc.rgba(230, 238, 255, 255), -- mind blue
  O = pc.rgba(239, 166, 143, 255), S = pc.rgba(210, 220, 232, 255), -- power orange / steel
  V = pc.rgba(201, 166, 232, 255), C = pc.rgba(255, 138, 192, 255), g = pc.rgba(190, 190, 200, 255), -- creativity
  A = pc.rgba(236, 196, 126, 255),  -- charisma gold
  T = pc.rgba(142, 216, 194, 255),  -- adventure teal
  Z = pc.rgba(166, 223, 255, 255),  -- sleep blue
}

local ICONS = {
  apple = {
    "....K.....",
    "...KBK.KK.",
    "..KKBKKGGK",
    ".KRRRRRKK.",
    "KRWRRRRRRK",
    "KRWRRRRRRK",
    "KRRRRRRRrK",
    "KRRRRRRRrK",
    ".KRRRRRrK.",
    "..KKKKKK..",
  },
  heart = {
    ".KK...KK.",
    "KRRK.KRRK",
    "KRWRKRRRK",
    "KRWRRRRRK",
    "KRRRRRRrK",
    ".KRRRRrK.",
    "..KRRrK..",
    "...KrK...",
    "....K....",
  },
  bolt = {
    "....KKKK.",
    "...KYYYK.",
    "..KYYYK..",
    ".KYYYKKKK",
    "KYYYYYYYK",
    "KKKKYYyK.",
    "...KYyK..",
    "..KYyK...",
    "..KyK....",
    "..KK.....",
  },
  zzz = {
    "....KKKKK",
    "....KZZZK",
    ".....KZK.",
    "KKKKKKZKK",
    "KZZZKZZZK",
    ".KZKKKKKK",
    "KZKK.....",
    "KZZZK....",
    "KKKKK....",
  },
  home = {
    ".....K.....",
    "....KHK....",
    "...KHHHK...",
    "..KHHHHHK..",
    ".KHHHHHHHK.",
    "KKKHHHHHKKK",
    "..KHHDDHK..",
    "..KhHDDHK..",
    "..KKKKKKK..",
  },
  growth = {
    "........KKK",
    "........KHK",
    "....KKK.KHK",
    "....KAK.KHK",
    "KKK.KAK.KHK",
    "KOK.KAK.KhK",
    "KOK.KAK.KhK",
    "KKK.KKK.KKK",
  },
  activities = {
    ".KKKKKKKKK.",
    "KPPPPPPPPPK",
    "KPWPPPPPRPK",
    "KWWWPPPRPRK",
    "KPWPPPPPRPK",
    "KPPPKKKPPPK",
    ".KKK...KKK.",
  },
  mind = {
    "KKKKK.KKKKK",
    "KMMMMKMMMMK",
    "KMmmMKMmmMK",
    "KMMMMKMMMMK",
    "KMmmMKMmmMK",
    "KMMMMKMMMMK",
    "KKKKKKKKKKK",
  },
  power = {
    "......KKK",
    ".....KSSK",
    "....KSWK.",
    "K..KSWK..",
    "KKKSWK...",
    ".KOKK....",
    "KOKOK....",
    "KKKKK....",
  },
  creativity = {
    "......KKK",
    ".....KVVK",
    "....KVVK.",
    "...KVVK..",
    "..KggK...",
    ".KCgK....",
    "KCCK.....",
    "KKK......",
  },
  charisma = {
    "....K....",
    "...KAK...",
    "KKKKAKKKK",
    "KAAAAAAAK",
    ".KAAWAAK.",
    "..KAAAK..",
    ".KAAKAAK.",
    "KAK...KAK",
    "KK.....KK",
  },
  adventure = {
    "..KKKKK..",
    ".KTTTTTK.",
    "KTTTRTTTK",
    "KTTRRRTTK",
    "KTTTKTTTK",
    "KTTWWWTTK",
    "KTTTWTTTK",
    ".KTTTTTK.",
    "..KKKKK..",
  },
}

local function save(name, rows)
  local w = 0
  for _, r in ipairs(rows) do w = math.max(w, #r) end
  local img = Image(w, #rows, ColorMode.RGB)
  for y, r in ipairs(rows) do for x = 1, #r do
    local c = P[r:sub(x, x)]
    if c then img:drawPixel(x - 1, y - 1, c) end
  end end
  img:saveAs(out .. "/" .. name .. ".png")
end

for name, rows in pairs(ICONS) do save(name, rows) end

-- Thought bubble: 17x13 rounded body with a two-dot tail, white fill.
local BW, BH = 17, 16
local bubble = Image(BW, BH, ColorMode.RGB)
local K, W = P.K, P.W
for y = 0, 12 do for x = 0, BW - 1 do
  local cut = (y == 0 or y == 12) and 2 or ((y == 1 or y == 11) and 1 or 0)
  if x >= cut and x <= BW - 1 - cut then
    local edge = (y == 0 or y == 12) or x == cut or x == BW - 1 - cut
      or (y == 1 and (x == 1 or x == BW - 2)) or (y == 11 and (x == 1 or x == BW - 2))
    bubble:drawPixel(x, y, edge and K or W)
  end
end end
-- corner pixels between the stepped edges
bubble:drawPixel(1, 1, K); bubble:drawPixel(BW - 2, 1, K); bubble:drawPixel(1, 11, K); bubble:drawPixel(BW - 2, 11, K)
for _, p in ipairs({ { 4, 13 }, { 5, 13 }, { 4, 14 }, { 5, 14 }, { 2, 15 } }) do bubble:drawPixel(p[1], p[2], K) end
bubble:saveAs(out .. "/bubble.png")
print("icons written")
