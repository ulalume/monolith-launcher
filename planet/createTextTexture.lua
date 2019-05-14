
local fontsize = 18
local gillSans = love.graphics.newFont("assets/font/Gill Sans.ttf", fontsize)

local function terrain (w, h)
    return function (x, y, r, g, b, a)
      local xx, yy = x / w, y / h
      x = (math.cos(xx * math.pi * 2) +1)* w /3
      y = (math.sin(yy * math.pi * 2) +1)* h /3

      local c1 = love.math.noise(x / 2, y / 2, v2, v1)
      local c2 = love.math.noise(x / (scale / 3), y / (scale / 3), v1 / 3, v2 / 3)
      local c3 = love.math.noise(x / scale, y / scale, v1, v2)

      local c = math.min(1, math.max(0, (c2 * c3 + c3 / 2 - c2 / 3)  + c1 * 0.14 + c3 * 0.12))

      love.timer.sleep(0)

      return c, c, c, 1
    end
end


local function createTextTexture(w, h, str)
  local canvas = love.graphics.newCanvas(w, h)
  love.graphics.push()

  love.graphics.setCanvas(canvas)
  love.graphics.clear(0.5,0.5,0.5,1)
  love.graphics.setFont(gillSans)
  love.graphics.setColor(0,0,0)
  love.graphics.print(str, 0 + 1, (h - fontsize) / 2 + 0)
  love.graphics.print(str, 0 + 0, (h - fontsize) / 2 + 1)
  love.graphics.print(str, 0 + 2, (h - fontsize) / 2 + 1)
  love.graphics.print(str, 0 + 1, (h - fontsize) / 2 + 2)
  love.graphics.setColor(1,1,1)
  love.graphics.print(str, 0 + 1, (h - fontsize) / 2 + 1)
  love.graphics.setCanvas()
  love.graphics.pop()

  return canvas
end

return createTextTexture
