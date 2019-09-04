package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.so'

local monolith = require "monolith.core".new({ ledColorBits = 9 })

local createPlanet = require "planet.createPlanet"

local gameData = require "config.game_data"

local storage = require "util.storage" : load "launcher.json"

local selectedIndex = storage.data.selectedIndex or 1
if selectedIndex > #gameData then selectedIndex = 1 end

local nowPlanet
local nowSeed

local table2 = require "util.table2"

local rainbow = require "graphics.rainbow":new(2/60)

local musicSystem
local randomSound


function nowGameData()
  return gameData[selectedIndex]
end
function setSelectedIndex(index)
  selectedIndex = index
  local now = nowGameData()
  nowSeed = now.seed or stringToNum(now.name)
  nowPlanet = createPlanet(nowSeed, now.name)
end
function goNext()
  selectedIndex = selectedIndex + 1
  if selectedIndex == #gameData + 1 then selectedIndex = 1 end
  setSelectedIndex(selectedIndex)
end
function goPrev()
  selectedIndex = selectedIndex - 1
  if selectedIndex == 0 then selectedIndex = #gameData end
  setSelectedIndex(selectedIndex)
end


local scale = 1
local coinUsers = {false,false,false,false}
local function launchingGame()
  local trues = 0
  for i=1, #coinUsers do
    if coinUsers[i] then
      trues = trues + 1
    end
  end
  return trues >= 2
end


function love.load()
  if require "util.osname" == "Linux" then
    for i,inp in ipairs(require "config.linux_input_settings") do monolith.input:setUserSetting(i, inp) end
  else
    for i,inp in ipairs(require "config.input_settings") do monolith.input:setUserSetting(i, inp) end
  end

  --love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  --love.graphics.setLineStyle('rough')

  local devices, musicPathTable, priorityTable = unpack(require "config.music_data")
  musicSystem = require("music.music_system"):new({true, true, true, true}, devices, musicPathTable, priorityTable)
  randomSound = require "randomSound":new(musicSystem)

  goNext()
  --setSelectedIndex(selectedIndex)

  musicSystem:playAllPlayer("bgm")
end

local function launch(folder, coinUsers)
  local args = " -c "
  for i=1,4 do
    if coinUsers[i] then
      args = args.."1"
    else
      args = args.."0"
    end
  end

  storage.data.selectedIndex = selectedIndex
  storage:save()

  if require "util.osname" == "Linux" then
    local cmd = "sleep 2;/usr/bin/env DISPLAY=:0 /usr/bin/sudo -E /usr/bin/love /home/pi/Desktop/"..folder..args.." &"
    os.execute(cmd)
  else
    os.execute("/Applications/love.app/Contents/MacOS/love ../"..folder..args.." &")
  end
  love.event.quit()
end

function love.update(dt)
  musicSystem:update(dt)
  randomSound:update(dt)

  for i=1, 4 do
    if monolith.input:getButtonDown(i, "a") or monolith.input:getButtonDown(i, "b") then
      coinUsers[i] = true--not coinUsers[i]

      if coinUsers[i] then
        --musicSystem:play(i, "select")
      end
    end
  end

  local launching = launchingGame()
  if not launching then
    for i=1, 4 do
      if monolith.input:getButtonDown(i, "left") or monolith.input:getButtonDown(i, "up") then
        goPrev()
      end
      if monolith.input:getButtonDown(i, "right") or monolith.input:getButtonDown(i, "down") then
        goNext()
      end
    end
  end

  if launching then
    scale = scale * 1.005
    if scale > 4 then
      launch(gameData[selectedIndex].folder, coinUsers)
    end
  else
    scale = math.max(1, scale * 0.98)
  end
  nowPlanet:update(dt)
end


function drawUsers(users)
  local count = 5
  local dx = {0, 0,  1, -1}
  local dy = {1, -1, 0, 0}
  local x = {64, 64, 128 - count, 0 + count}
  local y = {128 - count, 0 + count, 64, 64}

  love.graphics.push()

  for i,v in ipairs(users) do
    if v then
      for k=0, count do
        local r, g, b = rainbow:color(k):rgb()
        love.graphics.setColor(r, g, b, 0.3)
        love.graphics.circle("fill", x[i] + dx[i] * k * 2, y[i] + dy[i] * k * 2, count)
      end
    end
  end

  love.graphics.pop()
end


function love.draw()
  monolith:beginDraw()

  love.graphics.push()
  love.graphics.scale(scale)
  local d = (scale - 1) * 32
  nowPlanet.x = 64 - d
  nowPlanet.y = 64 - d

  nowPlanet:draw()

  love.graphics.scale()
  love.graphics.pop()

  love.graphics.setColor(0, 0, 0, (scale  - 1) / 2)
  love.graphics.rectangle("fill", 0, 0, 128, 128)

  drawUsers(coinUsers)

  monolith:endDraw()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("seed : "..tostring(nowSeed), 0, 0)
  love.graphics.print(tostring(love.timer.getFPS( )), 0, 20)
end

function stringToNum(str)
  local b = string.byte(str)
  return b + #str * b + b*b + 1
end

function love.quit()
  musicSystem:gc()
end
