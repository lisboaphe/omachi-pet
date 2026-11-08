-- Build the Slime's Play and Meditate sheets from the supplied front-facing
-- idle variant, so they match the eat/happy/sleep art style.
--
--   aseprite -b --script-param src=assets/pets/slime-default/slime/idle_variant_two.png \
--            --script-param out=assets/pets/slime-default/slime \
--            --script tools/build_extra_sprites.lua
--
-- play.png:     8 frames, hop with squash/stretch while a beach ball bounces overhead.
-- meditate.png: 8 frames, eyes closed, gentle float with an aura and orbiting sparkles.

local pc = app.pixelColor
local src = Image{ fromFile = app.params.src }
local outDir = app.params.out
local W, H, BASE = 96, 96, 90

local function frame(i)
  local img = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do img:drawPixel(x, y, src:getPixel(i * W + x, y)) end end
  return img
end

local function get(img, x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return 0 end
  return img:getPixel(x, y)
end

-- Nearest-neighbour scale around the feet, then lift by dy (negative = up).
local function pose(img, sx, sy, dy)
  local out = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local px = math.floor(48 + (x + 0.5 - 48) / sx)
    local py = math.floor(BASE - (BASE - (y - dy + 0.5)) / sy)
    out:drawPixel(x, y, get(img, px, py))
  end end
  return out
end

local function put(img, x, y, c) if x >= 0 and y >= 0 and x < W and y < H then img:drawPixel(x, y, c) end end
local function blend(img, x, y, c, a)
  if x < 0 or y < 0 or x >= W or y >= H then return end
  local d = img:getPixel(x, y)
  local da = pc.rgbaA(d)
  if da == 0 then img:drawPixel(x, y, pc.rgba(pc.rgbaR(c), pc.rgbaG(c), pc.rgbaB(c), math.floor(255 * a))); return end
  local function m(p, q) return math.floor(p + (q - p) * a + 0.5) end
  img:drawPixel(x, y, pc.rgba(m(pc.rgbaR(d), pc.rgbaR(c)), m(pc.rgbaG(d), pc.rgbaG(c)), m(pc.rgbaB(d), pc.rgbaB(c)), da))
end

local OUT = pc.rgba(16, 22, 58, 255)
local RED, WHITE, YEL, SHADE = pc.rgba(232, 72, 72, 255), pc.rgba(250, 248, 240, 255), pc.rgba(255, 210, 90, 255), pc.rgba(196, 190, 186, 255)

-- 9x9 beach ball with an outline, three colour bands and a highlight.
local BALL = {
  "..XXXXX..",
  ".XRRWYYX.",
  "XRRRWYYYX",
  "XRRWWWYYX",
  "XWWWWWWWX",
  "XYYWWWRRX",
  "XYYYWRRRX",
  ".XYYWRRX.",
  "..XXXXX..",
}
local function ball(img, cx, cy)
  for r, row in ipairs(BALL) do for c = 1, #row do
    local ch, x, y = row:sub(c, c), cx + c - 5, cy + r - 5
    if ch == "X" then put(img, x, y, OUT)
    elseif ch == "R" then put(img, x, y, RED)
    elseif ch == "W" then put(img, x, y, (r > 5) and SHADE or WHITE)
    elseif ch == "Y" then put(img, x, y, YEL) end
  end end
  put(img, cx - 2, cy - 2, WHITE)
end

local function shadow(img, w, alpha)
  for x = -w, w do
    local a = alpha * (1 - math.abs(x) / (w + 1))
    blend(img, 48 + x, BASE, pc.rgba(10, 18, 30, 255), a)
    blend(img, 48 + x, BASE + 1, pc.rgba(10, 18, 30, 255), a * 0.6)
  end
end

-- Play: anticipation squash, launch, airborne, land, recover; ball counter-bounces.
local base = frame(0)
local play = Image(W * 8, H, ColorMode.RGB)
local P = {
  { 1.10, 0.86,   0, 40 }, { 0.92, 1.12,  -6, 30 }, { 0.98, 1.03, -14, 24 }, { 1.00, 1.00, -17, 22 },
  { 0.98, 1.03, -13, 26 }, { 0.94, 1.08,  -5, 32 }, { 1.12, 0.85,   0, 40 }, { 1.03, 0.97,   0, 36 },
}
for i, p in ipairs(P) do
  local f = Image(W, H, ColorMode.RGB)
  shadow(f, math.floor(18 + p[3] * 0.4), 0.35 + p[3] * 0.01)
  f:drawImage(pose(base, p[1], p[2], p[3]), Point(0, 0))
  ball(f, 64, p[4])
  play:drawImage(f, Point((i - 1) * W, 0))
end
play:saveAs(outDir .. "/play.png")

-- Meditate: eyes closed, float on a sine, soft aura, two sparkles orbiting.
local calm = frame(4)
local med = Image(W * 8, H, ColorMode.RGB)
local AURA = pc.rgba(150, 220, 255, 255)
for i = 0, 7 do
  local t = i / 8 * 2 * math.pi
  local lift = -6 + math.floor(math.sin(t) * 3 + 0.5)
  local f = Image(W, H, ColorMode.RGB)
  shadow(f, 14 - math.floor(math.sin(t)), 0.22)
  -- aura ring under the body
  for x = -20, 20 do
    local y = BASE - 3 + lift + math.floor((x * x) / 110)
    blend(f, 48 + x, y, AURA, 0.75 + 0.2 * math.sin(t + x * 0.3)); blend(f, 48 + x, y + 1, AURA, 0.35)
  end
  f:drawImage(pose(calm, 1, 1, lift), Point(0, 0))
  for k = 0, 1 do
    local a = t + k * math.pi
    local sx = 48 + math.floor(math.cos(a) * 30 + 0.5)
    local sy = 64 + lift + math.floor(math.sin(a) * 8 + 0.5)
    local front = math.sin(a) > 0
    local c = front and WHITE or AURA
    put(f, sx, sy, c)
    for d = 1, (front and 2 or 1) do put(f, sx - d, sy, AURA); put(f, sx + d, sy, AURA); put(f, sx, sy - d, AURA); put(f, sx, sy + d, AURA) end
  end
  med:drawImage(f, Point(i * W, 0))
end
med:saveAs(outDir .. "/meditate.png")
print("wrote play.png and meditate.png")
