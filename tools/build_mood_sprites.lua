-- Derive the Slime's mood sheets (sad, tired) from the supplied idle sheet so
-- they keep the original palette, outline and breathing motion.
--
--   aseprite -b --script-param idle=assets/pets/slime-default/slime/idle.png \
--            --script-param out=assets/pets/slime-default/slime \
--            --script tools/build_mood_sprites.lua
--
-- Outputs slime/sad.png and slime/tired.png (96x96 frames, one row, same
-- frame count as idle). Durations are set in pet.json.

local pc = app.pixelColor
local src = Image{ fromFile = app.params.idle }
local outDir = app.params.out
local W, H = 96, 96
local FRAMES = src.width // W
local BASE = 90 -- feet line, matches the pack anchor

local function rgba(c) return pc.rgbaR(c), pc.rgbaG(c), pc.rgbaB(c), pc.rgbaA(c) end
local function lum(c) local r, g, b = rgba(c); return 0.299 * r + 0.587 * g + 0.114 * b end

local function crop(i)
  local img = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do img:drawPixel(x, y, src:getPixel(i * W + x, y)) end end
  return img
end

local function get(img, x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return 0 end
  return img:getPixel(x, y)
end

-- Most common opaque mid-tone = body colour; darkest common = outline colour.
local function palette(img)
  local counts = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local c = img:getPixel(x, y)
    if pc.rgbaA(c) > 200 then counts[c] = (counts[c] or 0) + 1 end
  end end
  local body, outline, bodyN, outN = 0, 0, 0, 0
  for c, n in pairs(counts) do
    local l = lum(c)
    if l >= 60 and l <= 200 and n > bodyN then body, bodyN = c, n end
    if l < 60 and n > outN then outline, outN = c, n end
  end
  return body, outline
end

-- Eyes: dark 4-connected clusters that never touch transparency (the outline always does).
local function eyes(img)
  local seen, found = {}, {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local k = y * W + x
    local c = img:getPixel(x, y)
    if not seen[k] and pc.rgbaA(c) > 200 and lum(c) < 60 then
      local stack, comp, open = { { x, y } }, { x1 = x, x2 = x, y1 = y, y2 = y, n = 0 }, false
      seen[k] = true
      while #stack > 0 do
        local p = table.remove(stack)
        local px, py = p[1], p[2]
        comp.n = comp.n + 1
        comp.x1, comp.x2 = math.min(comp.x1, px), math.max(comp.x2, px)
        comp.y1, comp.y2 = math.min(comp.y1, py), math.max(comp.y2, py)
        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
          local nx, ny = px + d[1], py + d[2]
          local nc = get(img, nx, ny)
          if pc.rgbaA(nc) == 0 then open = true
          elseif lum(nc) < 60 then
            local nk = ny * W + nx
            if not seen[nk] then seen[nk] = true; stack[#stack + 1] = { nx, ny } end
          end
        end
      end
      if not open and comp.n >= 8 and comp.y2 - comp.y1 >= 3 then found[#found + 1] = comp end
    end
  end end
  table.sort(found, function(a, b) return a.x1 < b.x1 end)
  return found
end

local function nearEdge(img, x, y)
  for dy = -1, 1 do for dx = -1, 1 do if pc.rgbaA(get(img, x + dx, y + dy)) == 0 then return true end end end
  return false
end

local function isEyePixel(c) local l = lum(c); return pc.rgbaA(c) > 0 and (l < 60 or l > 200) end

-- Half-closed lids: a flat lid line with one row of pupil peeking under it.
local function droopyLids(img, list, body, outline)
  for _, e in ipairs(list) do
    local lid = e.y1 + math.floor((e.y2 - e.y1 + 1) * 0.55)
    local keep = {}
    for x = e.x1, e.x2 do keep[x] = get(img, x, lid + 1) end
    -- Clear the whole eye box (highlights inside the eye are mid-tones), sparing the outline.
    for y = e.y1, e.y2 do for x = e.x1, e.x2 do
      if not nearEdge(img, x, y) then img:drawPixel(x, y, body) end
    end end
    for x = e.x1 - 1, e.x2 + 1 do
      local c = get(img, x, e.y1 - 1)
      if lum(c) < 90 and pc.rgbaA(c) > 0 and not nearEdge(img, x, e.y1 - 1) then img:drawPixel(x, e.y1 - 1, body) end
    end
    for x = e.x1 - 1, e.x2 + 1 do img:drawPixel(x, lid, outline) end
    for x = e.x1 + 1, e.x2 - 1 do if isEyePixel(keep[x]) then img:drawPixel(x, lid + 1, outline) end end
  end
end

-- Worried brows: inner ends raised. Eyes are sorted left to right; inner side faces the other eye.
local function worriedBrows(img, list, outline)
  for i, e in ipairs(list) do
    local w = e.x2 - e.x1 + 1
    local innerRight = (i == 1 and #list > 1)
    for k = 0, w - 1 do
      local x = e.x1 + k
      local inner = innerRight and (k >= w / 2) or (not innerRight and k < w / 2)
      img:drawPixel(x, e.y1 - (inner and 4 or 3), outline)
    end
  end
end

local function drop(img, x, y, fill, outline)
  local shape = { "..X..", ".XOX.", "XOOOX", "XOOOX", ".XXX." }
  for r, row in ipairs(shape) do for c = 1, #row do
    local ch = row:sub(c, c)
    if ch == "X" then img:drawPixel(x + c - 3, y + r - 1, outline)
    elseif ch == "O" then img:drawPixel(x + c - 3, y + r - 1, fill) end
  end end
end

local function tear(img, x, y, fill, outline)
  local shape = { ".X.", "XOX", "XOX", ".X." }
  for r, row in ipairs(shape) do for c = 1, #row do
    local ch = row:sub(c, c)
    if ch == "X" then img:drawPixel(x + c - 2, y + r - 1, outline)
    elseif ch == "O" then img:drawPixel(x + c - 2, y + r - 1, fill) end
  end end
end

-- Mix toward grey (desaturate) and scale brightness, keeping alpha.
local function tint(img, desat, bright)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local r, g, b, a = rgba(img:getPixel(x, y))
    if a > 0 then
      local l = 0.299 * r + 0.587 * g + 0.114 * b
      local function f(v) return math.max(0, math.min(255, math.floor((v + (l - v) * desat) * bright + 0.5))) end
      img:drawPixel(x, y, pc.rgba(f(r), f(g), f(b), a))
    end
  end end
end

-- Nearest-neighbour squash anchored on the feet line and horizontal centre.
local function squash(img, sx, sy)
  local out = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local sxp = math.floor(48 + (x + 0.5 - 48) / sx)
    local syp = math.floor(BASE - (BASE - (y + 0.5)) / sy)
    out:drawPixel(x, y, get(img, sxp, syp))
  end end
  return out
end

local function bodyTop(img)
  for y = 0, H - 1 do for x = 0, W - 1 do if pc.rgbaA(img:getPixel(x, y)) > 0 then return x, y end end end
  return 48, 40
end

local function bodyLeft(img, y)
  for x = 0, W - 1 do if pc.rgbaA(img:getPixel(x, y)) > 0 then return x end end
  return 24
end

local sad = Image(W * FRAMES, H, ColorMode.RGB)
local tired = Image(W * FRAMES, H, ColorMode.RGB)
local tearFill, dropFill = pc.rgba(190, 236, 255, 255), pc.rgba(225, 246, 255, 255)

for i = 0, FRAMES - 1 do
  local base = crop(i)
  local body, outline = palette(base)
  local list = eyes(base)

  -- Sad: worried brows, a tear sliding down under the front eye, a little deflated and greyer.
  local s = crop(i)
  worriedBrows(s, list, outline)
  if #list > 0 then
    local e = list[1]
    tear(s, e.x1 - 2, e.y2 - 2 + 2 * i, tearFill, outline)
  end
  s = squash(s, 1.03, 0.92)
  tint(s, 0.45, 0.88)
  sad:drawImage(s, Point(i * W, 0))

  -- Tired: heavy lids, flattened, slightly greyer, a sweat drop by the head.
  local t = crop(i)
  droopyLids(t, list, body, outline)
  t = squash(t, 1.08, 0.84)
  tint(t, 0.15, 0.96)
  local _, top = bodyTop(t)
  local dy = top + 10
  drop(t, bodyLeft(t, dy) + 7, dy - 1 + (i % 2), dropFill, outline)
  tired:drawImage(t, Point(i * W, 0))
end

sad:saveAs(outDir .. "/sad.png")
tired:saveAs(outDir .. "/tired.png")
print("wrote " .. FRAMES .. " frames to sad.png and tired.png")
