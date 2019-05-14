
local Timer = require "util.timer"
local controlTypes = require "music.control_type"
local controlTypeNames = require "music.control_type_names"
local table2 = require "util.table2"

local changeSoundControlls = {}

function getRandomSoundControl()
  return {controlTypes[controlTypeNames[math.random(1, #controlTypeNames)]], math.random(0, 127), Timer:new(0.2)}
end

local randomSound = {}
function randomSound:new(musicSystem)
  return setmetatable({musicSystem=musicSystem, changing={}}, {__index=self})
end

function randomSound:update(dt)
  if #self.changing < 5 then
    local sc = getRandomSoundControl()
    local ok = true
    for i,v in ipairs(self.changing) do
      if v[1] == sc[1] then
        ok = false
        break
      end
    end
    if ok then
      table.insert(self.changing, sc)
    end
  end
  local copiedSCs = table2.merge({}, self.changing)
  for _, sc in ipairs(copiedSCs) do
    if sc[3]:executable(dt) then
      local need = true
      for i, player in ipairs(self.musicSystem.players) do
        local nowValue = player.synth.controlls[sc[1]]
        if nowValue == nil then
          nowValue = sc[2]
        end

        if nowValue == sc[2] then
          need = false
        elseif nowValue < sc[2] then
          nowValue = nowValue+1
        else
          nowValue = nowValue-1
        end
        player.synth:controlChange(sc[1], nowValue)
      end

      if not need then
        table2.removeItem(self.changing, sc)
      end
    end
  end
end

return randomSound
