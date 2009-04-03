objects.arc = {
  arrowAngle = 30*math.pi/180,
  arrowLength = 6,
  thickness = 3,

  segmentMarkerColor = love.graphics.newColor(0,0,0),
  segmentMarkerRadius = 4,

  exists = function(nodeTail, nodeHead)
    for k,v in ipairs(objects.collection) do
      if v.type == objects.arc and v.head == nodeHead and v.tail == nodeTail then return true end
    end
    return false
  end,

  contains = function(o,x,y)
    local projX, projY = geo.project(x,y,o.head.x,o.head.y,o.tail.x,o.tail.y)
    local closeToLine = (geo.distance(x,y,projX,projY) < objects.arc.thickness)
    local segmentLength = geo.distance(o.head.x,o.head.y,o.tail.x,o.tail.y)
    local nearHead = geo.distance(x,y,o.head.x,o.head.y) < segmentLength
    local nearTail = geo.distance(x,y,o.tail.x,o.tail.y) < segmentLength
    local headContains = o.head:contains(x,y)
    local tailContains = o.tail:contains(x,y)
    return closeToLine and nearHead and nearTail and (not headContains) and (not tailContains)
  end,

  draw = function(o)
    if selection.object == o then
      love.graphics.setColor(objects.selectedColor)
      love.graphics.setLineWidth(objects.selectedWidth + o.activationStrength)
    else
      love.graphics.setLineWidth(objects.nonSelectedWidth + o.activationStrength)
      love.graphics.setColor(objects.nonSelectedColor)
    end

    local lineLength = geo.distance(o.head.x,o.head.y,o.tail.x,o.tail.y)
    -- trueLength is unused
    local trueLength = lineLength - o.head.radius - o.tail.radius
    local lineAngle = math.atan2(o.head.y-o.tail.y,o.head.x-o.tail.x)
    local tx = o.tail.x + math.cos(lineAngle)*o.tail.radius
    local ty = o.tail.y + math.sin(lineAngle)*o.tail.radius
    local hx = o.head.x - math.cos(lineAngle)*o.head.radius
    local hy = o.head.y - math.sin(lineAngle)*o.head.radius

    love.graphics.line(tx,ty,hx,hy)

    local angle1 = -lineAngle + objects.arc.arrowAngle
    local angle2 = -lineAngle - objects.arc.arrowAngle
    local length = objects.arc.arrowLength
    love.graphics.line(hx,hy,hx-math.cos(angle1)*length,hy+math.sin(angle1)*length)
    love.graphics.line(hx,hy,hx-math.cos(angle2)*length,hy+math.sin(angle2)*length)

    love.graphics.setColor(objects.bgColor)
    for s = 1,(o.segments-1) do
      local d = s/(o.segments)
      local sx = (o.head.x - o.tail.x)*d / 1.1 + o.tail.x
      local sy = (o.head.y - o.tail.y)*d / 1.1 + o.tail.y
      love.graphics.circle(love.draw_fill,sx,sy,1 + o.activationStrength)
    end
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

