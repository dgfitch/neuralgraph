keys = {
  shift = function()
    return (love.keyboard.isDown(love.key_rshift) or love.keyboard.isDown(love.key_lshift))
  end,
  control = function()
    return (love.keyboard.isDown(love.key_rctrl) or love.keyboard.isDown(love.key_lctrl))
  end,
  alt = function()
    return (love.keyboard.isDown(love.key_ralt) or love.keyboard.isDown(love.key_lalt))
  end,
}

keypressed = function(key)
  if key == love.key_r then
    love.system.restart()
  end
  if key == love.key_d then
    debug = not debug
  end
  if key == love.key_down then
    music.quantizer = music.quantizer + 0.01
  end
  if key == love.key_up then
    music.quantizer = music.quantizer - 0.01
  end
end

mousepressed = function(x,y,button)
  local clickedK, clickedV = nil, nil
  for k,v in ipairs(objects.collection) do
    if v:contains(x,y) then 
      clickedK, clickedV = k,v
      break
    end
  end

  local increaseLength = (button == love.mouse_left and keys.alt() and clickedV ~= nil and clickedV.type == objects.arc)
  local decreaseLength = (button == love.mouse_right and keys.alt() and clickedV ~= nil and clickedV.type == objects.arc)

  local changeNode = (button == love.mouse_left and keys.alt() and clickedV ~= nil and clickedV.type == objects.node)
  local changeSample = (button == love.mouse_right and keys.alt() and clickedV ~= nil and clickedV.type == objects.node and clickedV.nodeType == 6)

  local createNode = (button == love.mouse_left and clickedV == nil)
  local createArc = (button == love.mouse_left and keys.shift() and selection.object ~= nil and (clickedV == nil or clickedV.type == objects.node))
  local destroy = (button == love.mouse_right and clickedV ~= nil and (not decreaseLength) and (not changeSample))

  local stimulate = (button == love.mouse_left and keys.control() and clickedV ~= nil)
  local increaseStrength = (button == love.mouse_left and keys.shift() and clickedV ~= nil)

  local headNode = nil
  if createNode then
    headNode = objects.node.getNew(x,y)
    table.insert(objects.collection,headNode)
  else
    headNode = clickedV
  end

  if createArc then
    local tailNode = nil
    if selection.object.type==objects.node then
      tailNode = selection.object
    elseif selection.object.type==objects.arc then
      tailNode = selection.object.head
    end
    if tailNode ~= nil and not objects.arc.exists(tailNode,headNode) and tailNode ~= headNode then
      local newArc = objects.arc.getNew(tailNode,headNode)
      table.insert(objects.collection,newArc)
    end
  end

  if destroy then
    if clickedV.activationStrength > 1 then
      clickedV.activationStrength = 1
    else
      clickedV:destroy()
      selection.object = nil
    end
  else
    selection.object = headNode
  end

  selection.time = 0

  if stimulate then
    if clickedV.type==objects.arc then
      table.insert(objects.collection, objects.signal.getNew(clickedV,1))
    elseif clickedV.type==objects.node then
      clickedV:stimulate(1)
    end
  end

  if increaseStrength then
    clickedV.activationStrength = clickedV.activationStrength + 0.5
  end

  if increaseLength then
    clickedV.segments = clickedV.segments + 1
  end

  if decreaseLength then
    if clickedV.segments > 1 then
      clickedV.segments = clickedV.segments - 1
    else
      clickedV:destroy()
      selection.object = nil
    end
  end

  if changeNode then
    objects.node.advanceNodeType(clickedV)
  end
end

mousereleased = function(x,y,button)
  selection.time = 0
end
