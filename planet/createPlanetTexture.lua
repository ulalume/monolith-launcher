local createTextTexture = require "planet.createTextTexture"

local function multiply(c, v)
  return {c[1] * v, c[2] * v, c[3] * v}
end
local function add(c, v)
  return {c[1] + v, c[2] + v, c[3] + v}
end

local function terrain (w, h, v1, v2, scale)
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

local function addtext (textImageData)
  return function (x, y, r)
    local r2 = textImageData:getPixel(x, y)
    local r2 = (r2 - 0.5) * 2
    local r1 = r * 0.3+ r2*0.7
    return r1, r1, r1, 1
  end
end
local function changeToNight (textImageData)
  textImageData:mapPixel(function (x, y, r)
    r = r - 0.5
    return r/3, r/ 1.5, r*2, 1
  end)
  return textImageData
end

local function colorize (w, h, v1, v2, scale, water, snow, COLOR_NUM, colors, colors_water, colors_snow, color_rock)

  COLOR_NUM = COLOR_NUM or 50

  local colorData = gradientData(COLOR_NUM, colors)
  local colorDataWater = gradientData(COLOR_NUM, colors_water)
  local colorDataSnow = gradientData(COLOR_NUM, colors_snow)

  return function (x, y, r)
    local xx, yy = x / w, y / h

    local r1, g1, b1
    if r < water then
      r1, g1, b1 = colorDataWater:getPixel(math.floor((COLOR_NUM - 1) * r / water), 0)
    else
      r1, g1, b1 = colorData:getPixel(math.floor((COLOR_NUM - 1) * (r - water) / (1 - water)), 0)
    end

    --local c = c3
    local sn = snow - math.abs(math.cos(yy * math.pi)) * math.abs(math.cos(yy * math.pi)) * 0.2
    if r > sn then
      local r2, g2, b2 = colorDataSnow:getPixel(math.floor((COLOR_NUM - 1) * (r - sn) / (1 - sn)), 0)
      if r < water then
        r1 = r1 / 0.4 + r2 * 0.6
        g1 = g1 / 0.4 + g2 * 0.6
        b1 = b1 / 0.4 + b2 * 0.6
      else
        r1 = color_rock[1] / 0.4 + r2 * 0.6
        g1 = color_rock[2] / 0.4 + g2 * 0.6
        b1 = color_rock[3] / 0.4 + b2 * 0.6
      end
    end

    return r1, g1, b1
  end
end

local function createPlanetTexture (w, h, scale, v1, v2, color_sand, color_plant, color_rock, color_water, water, snow, str)
  str = str or "B o m b !"

  v1 = v1 or 20
  v2 = v2 or 20
  scale = scale or 1

  color_sand = color_sand or {0.6, 0.4, 0.2}
  color_plant = color_plant or {0.1, 0.5, 0.2}
  color_rock = color_rock or {0.5, 0.3, 0.1}
  color_water =  color_water or {0.0, 0.3, 0.7}--{0, 0, 0.5}, , {0.2, 0.2, 1}

  water = water or 0.5
  snow = snow or 0.8

  local colors = {color_sand, multiply(color_sand, 0.7), color_plant, multiply(color_plant, 0.8), multiply(color_plant, 0.7), multiply(color_plant, 0.6), color_rock, multiply(color_rock, 1.1), multiply(color_rock, 1.2)}
  local colors_water = {multiply(color_water, 0.3), multiply(color_water, 0.1), color_water, color_water, color_water, multiply(color_water, 1.5)}
  local colors_snow = {multiply(add(color_water,0.3), 2), multiply(add(color_water,0.3), 2.5)}

  local imageData = love.image.newImageData(w, h)

  local textImageData = createTextTexture(w, h, str):newImageData()

  imageData:mapPixel(terrain(w, h, v1, v2, scale))

  imageData:mapPixel(addtext(textImageData))
  imageData:mapPixel(colorize(w, h, v1, v2, scale, water, snow, 32, colors, colors_water, colors_snow, color_rock))

  return love.graphics.newImage(imageData), love.graphics.newImage(changeToNight(textImageData))

end

function gradientData (w, colors)
  local cd = gradient(colors)
  local h = 2
  local c = love.graphics.newCanvas(w, h)

  love.graphics.push()
  love.graphics.setCanvas(c)
  drawinrect(cd, 0, 0, w, h)
  love.graphics.setCanvas()
  love.graphics.pop()
  return c:newImageData()
end

function drawinrect(img, x, y, w, h, r, ox, oy, kx, ky)
    love.graphics.draw(img, x, y, r, w / img:getWidth(), h / img:getHeight(), ox, oy, kx, ky)
end

function gradient(colors, horizontal)
    local horizontal = horizontal or true

    local result = love.image.newImageData(horizontal and #colors or 1, horizontal and 1 or #colors)
    for i, color in ipairs(colors) do
        local x, y
        if not horizontal then
            x, y = 0, i - 1
        else
            x, y = i - 1, 0
        end
        result:setPixel(x, y, color[1], color[2], color[3], color[4] or 1)
    end
    result = love.graphics.newImage(result)
    result:setFilter('linear', 'linear')
    return result
end


return createPlanetTexture
