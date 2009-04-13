objects.arc = {
  typeName = "arc",
  arrowAngle = 30*math.pi/180,
  arrowLength = 6,
  thickness = 3,
  detour = 0.04,
  
  segmentMarkerColor = love.graphics.newColor(0,0,0),
  segmentMarkerRadius = 4,

  exists = function(nodeTail, nodeHead)
    for k,v in ipairs(objects.collection) do
      if v.type == objects.arc and v.head == nodeHead and v.tail == nodeTail then return true end
    end
    return false
  end,

  getDetourInfo = function(o)
    local lineLength = geo.distance(o.head.x,o.head.y,o.tail.x,o.tail.y)
    local lineAngle = math.atan2(o.head.y-o.tail.y,o.head.x-o.tail.x)
    local perpAngle = lineAngle - math.pi/2
    
    -- don't go directly from head to tail; take a detour so you are graphically distinct from an opposing arc
    local trueCenterX = o.head.x - (o.head.x - o.tail.x) / 2
    local trueCenterY = o.head.y - (o.head.y - o.tail.y) / 2
    local detourX = trueCenterX + math.cos(perpAngle)*lineLength*objects.arc.detour
    local detourY = trueCenterY + math.sin(perpAngle)*lineLength*objects.arc.detour
    return perpAngle, detourX, detourY
  end,
  
  getPointAt = function(o, prog)
    local dummy,detourX,detourY = objects.arc.getDetourInfo(o)
    if prog < 0.5 then
      local d = prog*2
      return (detourX - o.tail.x)*d + o.tail.x, (detourY - o.tail.y)*d + o.tail.y
    else
      local d = prog*2-1
      return (o.head.x - detourX)*d + detourX, (o.head.y - detourY)*d + detourY
    end
  end,
  
  contains = function(o,x,y)
    local centerX = (o.head.x + o.tail.x) / 2
    local centerY = (o.head.y + o.tail.y) / 2
    local dummy, detourX, detourY = objects.arc.getDetourInfo(o)
    local correctSide = ((x-centerX)*(detourX-centerX) + (y-centerY)*(detourY-centerY)) > 0
  
    local margin = geo.distance(centerX,centerY,detourX,detourY)*1.25
    local projX, projY = geo.project(x,y,o.head.x,o.head.y,o.tail.x,o.tail.y)
    local closeToLine = (geo.distance(x,y,projX,projY) < margin)
    
    
    
    local segmentLength = geo.distance(o.head.x,o.head.y,o.tail.x,o.tail.y)
    local nearHead = geo.distance(x,y,o.head.x,o.head.y) < segmentLength
    local nearTail = geo.distance(x,y,o.tail.x,o.tail.y) < segmentLength
    
    local headContains = o.head:contains(x,y)
    local tailContains = o.tail:contains(x,y)
    
    return closeToLine and nearHead and nearTail and correctSide and (not headContains) and (not tailContains)
  end,

  draw = function(o)
    if selection.object == o then
      love.graphics.setColor(objects.selectedColor)
      love.graphics.setLineWidth(objects.selectedWidth + o.activationStrength)
    else
      love.graphics.setColor(objects.nonSelectedColor)
      love.graphics.setLineWidth(objects.nonSelectedWidth + o.activationStrength)
    end

    local perpAngle, detourX, detourY = objects.arc.getDetourInfo(o)
    
    local headAngle = math.atan2(detourY - o.head.y, detourX - o.head.x)
    local tailAngle = math.atan2(detourY - o.tail.y, detourX - o.tail.x)
    
    local tx = o.tail.x + math.cos(tailAngle)*o.tail.radius
    local ty = o.tail.y + math.sin(tailAngle)*o.tail.radius
    local hx = o.head.x + math.cos(headAngle)*o.head.radius
    local hy = o.head.y + math.sin(headAngle)*o.head.radius

    love.graphics.line(tx,ty,detourX,detourY)
    love.graphics.line(detourX,detourY,hx,hy)
    
    -- arrowhead
    local angle1 = headAngle + objects.arc.arrowAngle
    local angle2 = headAngle - objects.arc.arrowAngle
    local length = objects.arc.arrowLength
    love.graphics.line(hx,hy,hx+math.cos(angle1)*length,hy+math.sin(angle1)*length)
    love.graphics.line(hx,hy,hx+math.cos(angle2)*length,hy+math.sin(angle2)*length)

    -- length indicator
    length = 1.4 * (o.segments)
    local px = math.cos(perpAngle)*length
    local py = math.sin(perpAngle)*length
    love.graphics.line(detourX,detourY,detourX+px*2,detourY+py*2)
  end,

  destroy = function(o)
    o.dead = true
    o.head = nil
    o.tail = nil
  end,

  update = function(o,dt)
    if o.head == nil or o.head.dead or o.tail == nil or o.tail.dead then 
      o.dead = true
      return
    end
  end,

  getNew = function(nodeTail, nodeHead)
    return {
      head = nodeHead,
      tail = nodeTail,
      segments = 4,
      activationStrength = 1,
      contains = objects.arc.contains,
      draw = objects.arc.draw,
      update = objects.arc.update,
      destroy = objects.arc.destroy,
      isDestructible = true,
      type = objects.arc,
      dead = false
    }
  end,
}

