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

require "geo"
require "node"
require "arc"
require "signal"
require "ui"
require "sound"
require "clock"
require "data"

load = function()
  debug = false
  font = love.graphics.newFont(love.default_font, 12)
  love.graphics.setFont(font)
  samples = sound.list()
end

draw = function()
  love.graphics.setColor(objects.bgColor)
  love.graphics.rectangle(love.draw_fill,0,0,800,600)
  if debug then
    love.graphics.setColor(love.graphics.newColor(0,0,0,255))
    love.graphics.draw("DEBUG", 2, 12)
    love.graphics.draw(string.format("T: %.5f Lag: %.5f 16: %.5f BPM: %.1f O: %d", clock.currentTime, clock.lag, clock.sixteenth(), clock.bpm, #objects.collection), 2, 24)
    love.graphics.draw("Samples loaded: " .. #samples, 2, 36)
    love.graphics.draw(string.format("Draw error: %s Update error: %s", last_draw_error, last_update_error), 2, 48)
  end
  for k,v in ipairs(objects.collection) do
    status, err = pcall(function () v:draw() end)
    if not status then
      if err ~= last_draw_error then print(string.format("Draw error [%s]: %s", k, err)) end
      last_draw_error = err
    end
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
  clock.update(dt)
  for k,v in ipairs(objects.collection) do
    status, err = pcall(function () v:update(dt) end)
    if not status then
      if err ~= last_update_error then print(string.format("Update error [%s]: %s", k, err)) end
      last_update_error = err
    end
  end
  if love.mouse.isDown(love.mouse_left) and selection.object ~= nil then
    selection.time = selection.time + dt
  end
  garbageCollect()
end

