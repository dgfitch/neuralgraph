data = {
  -- largely from 12.1 of PIL
  serialize = function(args)
    local s = args.string or ""
    local o = args.object
    local depth = args.depth or 0

    local ignore = args.ignore or {}

    if ignore == true then
      ignore = { }
      ignore["type"] = true
    end

    local indent = ""
    for i=1,depth do 
      indent = indent .. "  "
    end

    if type(o) == "number" then
      s = s .. o
    elseif type(o) == "string" then
      s = s .. string.format("%q", o)
    elseif type(o) == "boolean" then
      if o then
        s = s .. "true"
      else
        s = s .. "false"
      end
    elseif type(o) == "table" then
      s = s .. "{\n"
      for k,v in pairs(o) do
        if (not ignore[k]) then
          if type(v) == "function" then
          else
            local serialized = data.serialize{object=v, depth=depth+1, ignore=ignore}
            s = s .. indent .. "  " .. k .. " = " .. serialized .. ",\n"
          end
        end
      end
      s = s .. indent .. "}\n"
    else
      s = "nil"
    end
    return s
  end,
  serialize_cycles = function(args)
    local saved = args.saved or {}
    local name = args.name or "x"
    local value = args.object
    local s = name .. " = "
    if type(value) == "table" then
      if saved[value] then
        s = s .. saved[value] .. "\n"
      else
        saved[value] = name
        s = s .. "{}\n"
        for k,v in pairs(value) do
          local fieldname = string.format("%s[%s]", name,
                                          data.serialize{object=k})
          if k == "type" then
            s = s .. data.serialize_cycles{name=fieldname, object=v.typeName, saved=saved}
          else
            s = s .. data.serialize_cycles{name=fieldname, object=v, saved=saved}
          end
        end
      end
    else
      s = s .. data.serialize{object=value} .. "\n"
    end
    return s
  end,
  save = function(name)
    local crud = data.serialize_cycles{object=objects.collection, name="objects.collection"}
    local fullname = name .. ".graph"
    if love.filesystem.exists(fullname) then
      love.filesystem.remove(fullname)
    end
    local file = love.filesystem.newFile(fullname,love.file_write)
    love.filesystem.open(file)
    love.filesystem.write(file,crud)
    love.filesystem.close(file)
  end,
  restore = function(name)
    local fullname = name .. ".graph"
    local content = love.filesystem.read(fullname)
    loadstring(content)()
    data.repair()
  end,
  repair = function()
    -- Fix the types to point at the right place
    for k,v in pairs(objects.collection) do
      local t
      if v.type == "node" then
        t = objects.node
      elseif v.type == "arc" then
        t = objects.arc
      elseif v.type == "signal" then
        t = objects.signal
      else
        error("Unknown type: " .. tostring(v.type))
      end

      v.type = t
      v.draw = t.draw
      v.update = t.update
      v.destroy = t.destroy
      v.contains = t.contains
      if v.type == objects.node then
        objects.node.enforceNodeType(v, v.nodeType)
      end
    end
  end,
}

