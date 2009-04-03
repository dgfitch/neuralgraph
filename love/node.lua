objects.node = {
  defaultRadius = 15,
  activationStrength = 1,
  activationThreshold = 1,

  contains = function(o,x,y)
    return (geo.distance(o.x,o.y,x,y) <= o.radius)
  end,

  update = function(o,dt)
    if selection.object == o and selection.time > selection.dragThreshold then
      o.x = love.mouse.getX()
      o.y = love.mouse.getY()
    end
  end,

  fire = function(o)
    local arcs = {}
    for k,v in ipairs(objects.collection) do
      if v.type == objects.arc and v.tail == o then
        table.insert(arcs,v)
      end
    end
    for k,v in ipairs(arcs) do
      table.insert(objects.collection, objects.signal.getNew(v,o.polarity))
    end
    o.activation = math.max(0,o.activation - o.activationStrength)
  end,


  nodeTypes = {
    -- excite
    {
      stimulate = function(o, strength)
        o.activation = o.activation + (strength*objects.node.activationStrength)
      end,
      fire = function(o)
        objects.node.fire(o)
      end,
      update = function(o,dt)
        objects.node.update(o,dt)
        if music.fire then
          if o.activation > objects.node.activationThreshold then
            o:fire()
            o.activation = -o.activationStrength/4
          end
        end
        o.activation = o.activation * math.exp(-2*dt)
      end,
      polarity = 1,
      image = 0,
      sound = 0,
      text = function(o)
        return o:activationAsString()
      end,
    },

    -- inhibit
    {
      stimulate = function(o, strength)
        o.activation = o.activation + (strength*objects.node.activationStrength)
      end,
      fire = function(o)
        objects.node.fire(o)
      end,
      update = function(o,dt)
        objects.node.update(o,dt)
        if music.fire then
          if o.activation > objects.node.activationThreshold then
            o:fire()
            o.activation = -o.activationStrength/4
          end
        end
        o.activation = o.activation * math.exp(-2*dt)
      end,
      polarity = -1,
      image = love.graphics.newImage("img/inhibitor.png"),
      sound = 0,
      text = function(o)
        return o:activationAsString()
      end,
    },

    -- clock
    {
      stimulate = function(o,strength) end,
      fire = function(o)
        objects.node.fire(o)
      end,
      update = function(o,dt)
        objects.node.update(o,dt)
        if music.fire then  o:fire()  end
      end,
      polarity = 1,
      image = love.graphics.newImage("img/clock.png"),
      sound = 0,
      text = function(o)
        return "clock:" .. music.quantizer
      end,
    },

    -- filter
    {
      stimulate = function(o,strength)
        o.activation = o.activation + strength/math.abs(strength)
      end,
      fire = function(o)
        objects.node.fire(o)
        o.activation = 0
      end,
      update = function(o,dt)
        objects.node.update(o,dt)
        if music.fire and math.abs(o.activation) > 1 then o:fire() end
      end,
      polarity = 1,
      image = love.graphics.newImage("img/filter.png"),
      sound = 0,
      text = function(o)
        return o:activationAsString()
      end,
    },

    -- inverter
    {
      stimulate = function(o,strength)
        o.activation = -strength
      end,
      fire = function(o)
        o.polarity = o.activation / math.abs(o.activation)
        objects.node.fire(o)
        o.activation = 0
      end,
      update = function(o,dt)
        objects.node.update(o,dt)
        if music.fire and o.activation ~= 0 then o:fire() end
      end,
      polarity = 1,
      image = love.graphics.newImage("img/inverter.png"),
      sound = 0,
      text = function(o)
        return o:activationAsString()
      end,
    },

    -- player
    {
      stimulate = function(o,strength)
        o.activation = o.activation + 1
      end,
      fire = function(o)
        objects.node.fire(o)
        o.activation = 0
        if o.sound ~= 0 then love.audio.play(o.sound) end
      end,
      update = function(o,dt)
        objects.node.update(o,dt)
        if music.fire and o.activation > 0 then o:fire() end
      end,
      polarity = 1,
      image = love.graphics.newImage("img/player.png"),
      sound = love.audio.newSound("sounds/q.ogg"),
      text = function(o)
        return "sound:q.ogg"
      end,
    },
  },

  enforceNodeType = function(o,t)
    for k,v in pairs(objects.node.nodeTypes[t]) do
      o[k] = v
    end
    o.nodeType = t
  end,

  advanceNodeType = function(o)
    local newNodeType = o.nodeType % table.getn(objects.node.nodeTypes) + 1
    objects.node.enforceNodeType(o,newNodeType)
  end,

  draw = function(o)
    local a = math.abs(math.max(-1,math.min(1,o.activation)))
    local fillColor
    if o.activation < 0 then
      fillColor = love.graphics.newColor(0,0,0,a*255)
    else
      fillColor = love.graphics.newColor(255,255,255,a*255) 
    end

    love.graphics.setColor(fillColor)
    love.graphics.circle(love.draw_fill,o.x,o.y,o.radius,36)

    if selection.object == o then
      love.graphics.setColor(objects.selectedColor)
      love.graphics.setLineWidth(objects.selectedWidth + o.activationStrength)
    else
      love.graphics.setColor(objects.nonSelectedColor)
      love.graphics.setLineWidth(objects.nonSelectedWidth + o.activationStrength)
    end
    love.graphics.circle(love.draw_line,o.x,o.y,o.radius,36)

    if o.image ~= 0 then love.graphics.draw(o.image,o.x,o.y) end

    if debug and o:contains(love.mouse.getX(), love.mouse.getY()) then
      love.graphics.draw(o:text(), o.x + 20, o.y + 4)
    end
  end,

  destroy = function(o)
    o.dead = true
  end,

  getNew = function(nx,ny)
    local result = {
      x = nx,
      y = ny,
      activationStrength = objects.node.activationStrength,
      radius = objects.node.defaultRadius,
      activation = 0,
      contains = objects.node.contains,
      draw = objects.node.draw,
      destroy = objects.node.destroy,
      isDestructible = true,
      type = objects.node,
      dead = false,
      activationAsString = function(o)
        return string.format("s%.3f ACT%.3f", o.activationStrength, o.activation)
      end,
    }
    objects.node.enforceNodeType(result,1)
    return result
  end,
}

