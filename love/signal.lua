objects.signal = {
  exciteColor = love.graphics.newColor(255,0,0),
  inhibitColor = love.graphics.newColor(0,0,255),
  radius = 6,

  contains = function(x,y)
    return false
  end,

  draw = function(s)
    if s.polarity == 1 then
      love.graphics.setColor(objects.signal.exciteColor)
    else
      love.graphics.setColor(objects.signal.inhibitColor)
    end
    local d = s.progress / s.arc.segments
    d = math.min(d,1.0)
    local x = (s.arc.head.x - s.arc.tail.x)*d + s.arc.tail.x
    local y = (s.arc.head.y - s.arc.tail.y)*d + s.arc.tail.y
    love.graphics.circle(love.draw_fill,x,y,objects.signal.radius)
  end,

  update = function(s,dt)
    if s.arc == nil or s.arc.dead then 
      s.dead = true
      return
    end
    if s.progress > s.arc.segments then
      s.dead = true
      s.arc.head:stimulate(s.arc.activationStrength*s.polarity)
    end
    s.progress = s.progress + dt/clock.sixteenth()
  end,

  destroy = function(s)
    s.arc = nil
  end,

  getNew = function(sourceArc, sPolarity)
    return {
      arc = sourceArc,
      progress = 0,
      polarity = sPolarity,
      contains = objects.signal.contains,
      draw = objects.signal.draw,
      update = objects.signal.update,
      destroy = objects.signal.destroy,
      isDestructible = false,
      type = objects.signal,
      dead = false
    }
  end
}
