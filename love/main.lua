music = {
  lastTime = 0,
  currentTime = 0,
  quantizer = 0.1,
}

objects = {
  bgColor = love.graphics.newColor(128,128,128),
  selectedColor = love.graphics.newColor(255,255,255),
  nonSelectedColor = love.graphics.newColor(0,0,0),

  selectedWidth = 3,
  nonSelectedWidth = 1,

  collection = {}
}

selection = {
  object = nil,
  time = 0,
  dragThreshold = 0.1
}

require "node"
require "arc"
require "signal"
require "geo"
require "ui"
require "sound"

load = function()
  debug = false
  font = love.graphics.newFont(love.default_font, 12)
  love.graphics.setFont(font)
  samples = sound.list()
end

draw = function()
  love.graphics.setColor(objects.bgColor)
  love.graphics.rectangle(love.draw_fill,0,0,800,600)
  for k,v in ipairs(objects.collection) do
    v:draw()
  end
  if debug then
    love.graphics.setColor(love.graphics.newColor(0,0,0,255))
    love.graphics.draw("DEBUG", 2, 12)
    love.graphics.draw(string.format("Quantizer: %.5f", music.quantizer), 2, 24)
    love.graphics.draw("Samples loaded: " .. #samples, 2, 36)
  end
end

garbageCollect = function()
  local nothingDestroyed
  repeat 
    nothingDestroyed = true
    local keptObjects = {}
    local destroyedObjects = {}
    for k,v in ipairs(objects.collection) do
      if v.dead then
        table.insert(destroyedObjects,v)
        nothingDestroyed = false
      else
        table.insert(keptObjects,v)
      end
    end
    objects.collection = keptObjects
    for k,v in ipairs(destroyedObjects) do
      v:destroy()
    end
  until nothingDestroyed
end

update = function(dt)
  music.currentTime = music.currentTime + dt
  music.fire = music.currentTime - music.lastTime > music.quantizer 
  if music.fire then
    music.lastTime = music.lastTime + music.quantizer
  end
  for k,v in ipairs(objects.collection) do
    v:update(dt)
  end
  if love.mouse.isDown(love.mouse_left) and selection.object ~= nil then
    selection.time = selection.time + dt
  end
  garbageCollect()
end

