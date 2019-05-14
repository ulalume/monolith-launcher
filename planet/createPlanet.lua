local Planet = require "planet.planet"
local createPlanetTexture = require "planet.createPlanetTexture"

function randomColor ()
  return {math.random(), math.random(), math.random()}
end

return function (seed, name)
  math.randomseed(seed or math.random())

  local size = math.random()
  local ss = 8/6
  local texture, texture_night = createPlanetTexture(256 / ss, 128 / ss, (10 + 100 * math.random()) / ss, (50 * math.random()) / ss, (50* math.random())/ ss, randomColor(), randomColor(), randomColor(), randomColor(), math.random(), (1 - math.random()*math.random()) , name)
  --local texture_clouds = love.graphics.newImage("assets/image/texture_clouds.png")

  return Planet.new({
    x = 64,
    y = 64,
    radius = 25 + 10 * size,
    speed = -(0.1 + 0.03 * (1 - size)),

    planet_texture = texture,
    clouds_texture = texture_clouds,
    night_texture = texture_night,

    light_angle = math.pi+math.pi/16,
    rotate_angle = -math.pi/16,

    atmosphere_color = {0.62 / 1.5, 0.62 / 1.5, 0.75 / 1.5},
    atmosphere_size = 42 * 1
  })
end
