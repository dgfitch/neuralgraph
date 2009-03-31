keys = {
	shift = function()
		return (love.keyboard.isDown(love.key_rshift) or love.keyboard.isDown(love.key_lshift))
	end,
	control = function()
		return (love.keyboard.isDown(love.key_rctrl) or love.keyboard.isDown(love.key_lctrl))
	end
}

geo = {
	distance = function(x1,y1,x2,y2)
		return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
	end,
	-- project point upx, upy onto line defined by lx1,ly1 and lx2,ly2
	project = function(upx,upy,lx1,ly1,lx2,ly2)	
	-- relative point coordinates
		local relPX, relPY = upx - lx1, upy - ly1
	-- relative line coordinates
		local relLX, relLY = lx2 - lx1, ly2 - ly1
		local dotProduct = relPX*relLX + relPY*relLY
		
		local dSquared = relLX*relLX + relLY*relLY
		
		local pScale = dotProduct/dSquared
		return relLX*pScale+lx1, relLY*pScale+ly1
	end
}

music = {
	lastTime = 0,
	currentTime = 0,
	quantizer = 0.0625,
}

objects = {

	types = {
		node = "node",
		arc = "arc",
		signal = "signal"
	},

	selectedColor = love.graphics.newColor(255,255,255),
	nonSelectedColor = love.graphics.newColor(0,0,0),
	
	selectedWidth = 3,
	nonSelectedWidth = 1,
		
	node = {
		defaultRadius = 10,
		activationStrength = 1,
		activationThreshold = 1,
		
		stimulate = function(o, strength)
			o.activation = o.activation + (strength*objects.node.activationStrength)
		end,
		
		fire = function(o)
			local arcs = {}
			for k,v in ipairs(objects.collection) do
				if v.objType == objects.types.arc and v.tail == o then
					table.insert(arcs,v)
				end
			end
			for k,v in ipairs(arcs) do
				table.insert(objects.collection, objects.signal.getNew(v))
			end
			o.activation = math.max(0,o.activation - o.activationStrength)
		end,
		
		contains = function(o,x,y)
			return (geo.distance(o.x,o.y,x,y) <= o.radius)
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
		end,
		
		destroy = function(o)
			o.dead = true
		end,
		
		update = function(o,dt)
			if selection.object == o and selection.time > selection.dragThreshold then
				o.x = love.mouse.getX()
				o.y = love.mouse.getY()
			end
			
			if music.fire then
				if o.activation > objects.node.activationThreshold then
					o:fire()
					o.activation = -o.activationStrength/4
				end
			end
			o.activation = o.activation * math.exp(-2*dt)
		end,
		
		getNew = function(nx,ny)
			return {
				x = nx,
				y = ny,
				activationStrength = objects.node.activationStrength,
				radius = objects.node.defaultRadius,
				activation = 0,
				stimulate = objects.node.stimulate,
				fire = objects.node.fire,
				contains = objects.node.contains,
				draw = objects.node.draw,
				update = objects.node.update,
				destroy = objects.node.destroy,
				isDestructible = true,
				objType = objects.types.node,
				dead = false,
			}
		end,
	},
	arc = {
		
		arrowAngle = 30*math.pi/180,
		arrowLength = 6,
		thickness = 3,
		
		segmentMarkerColor = love.graphics.newColor(0,0,0),
		segmentMarkerRadius = 4,
		lenPerSegment = 50,
		
		exists = function(nodeTail, nodeHead)
			for k,v in ipairs(objects.collection) do
				if v.objType == objects.types.arc and v.head == nodeHead and v.tail == nodeTail then return true end
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
			
			love.graphics.setColor(objects.arc.segmentMarkerColor)
			for s = 1,(o.segments-1) do
				local d = s/(o.segments)
				local sx = (o.tail.x - o.head.x)*d + o.head.x
				local sy = (o.tail.y - o.head.y)*d + o.head.y
				love.graphics.circle(love.draw_fill,sx,sy,objects.arc.segmentMarkerRadius + o.activationStrength)
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
			o.segments = math.ceil(geo.distance(o.head.x,o.head.y, o.tail.x,o.tail.y)/objects.arc.lenPerSegment)
		end,
		
		getNew = function(nodeTail, nodeHead)
			return {
				head = nodeHead,
				tail = nodeTail,
				segments = 1,
				activationStrength = 1,
				contains = objects.arc.contains,
				draw = objects.arc.draw,
				update = objects.arc.update,
				destroy = objects.arc.destroy,
				isDestructible = true,
				objType = objects.types.arc,
				dead = false
			}
		end,
	
	},

	signal = {
		color = love.graphics.newColor(255,0,0),
		radius = 6,
		contains = function(x,y)
			return false
		end,
		draw = function(s)
			love.graphics.setColor(objects.signal.color)
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
				s.arc.head:stimulate(s.arc.activationStrength)
			end
			s.progress = s.progress + dt/music.quantizer 
		end,
		destroy = function(s)
			s.arc = nil
		end,
		getNew = function(sourceArc)
			return {
				arc = sourceArc,
				progress = 0,
				contains = objects.signal.contains,
				draw = objects.signal.draw,
				update = objects.signal.update,
				destroy = objects.signal.destroy,
				isDestructible = false,
				objType = objects.types.signal,
				dead = false
			}
		end
	},
	
	collection = {}
}

selection = {
	object = nil,
	time = 0,
	dragThreshold = 0.1
}

load = function()
end

draw = function()
	local bgColor = love.graphics.newColor(128,128,128)
	love.graphics.setColor(bgColor)
	love.graphics.rectangle(love.draw_fill,0,0,800,600)
	for k,v in ipairs(objects.collection) do
		v:draw()
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
		music.currentTime = music.lastTime
	end
	for k,v in ipairs(objects.collection) do
		v:update(dt)
	end
	if love.mouse.isDown(love.mouse_left) and selection.object ~= nil then
		selection.time = selection.time + dt
	end
	garbageCollect()
end

mousepressed = function(x,y,button)
	local clickedK, clickedV = nil, nil
	for k,v in ipairs(objects.collection) do
		if v:contains(x,y) then 
			clickedK, clickedV = k,v
			break
		end
	end
	
	local createNode = (button == love.mouse_left and clickedV == nil)
	local createArc = (button == love.mouse_left and keys.shift() and selection.object ~= nil and (clickedV == nil or clickedV.objType == objects.types.node))
	local destroy = (button == love.mouse_right and clickedV ~= nil)
	
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
		if selection.object.objType == objects.types.node then
			tailNode = selection.object
		elseif selection.object.objType == objects.types.arc then
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
		if clickedV.objType == objects.types.arc then
			table.insert(objects.collection, objects.signal.getNew(clickedV))
		elseif clickedV.objType == objects.types.node then
			clickedV:stimulate(1)
		end
	end
	
	if increaseStrength then
		clickedV.activationStrength = clickedV.activationStrength + 0.5
	end
	
end

mousereleased = function(x,y,button)
	selection.time = 0
end
