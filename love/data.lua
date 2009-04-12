data = {
  -- largely from 12.1 of PIL
  serialize = function(args)
    local s = args.string
    local o = args.object
    local depth = args.depth
    local ignore = args.ignore

    if depth == nil then
      depth = 0
    end

    if s == nil then
      s = ""
    end

    if ignore == nil then
      ignore = {}
    end

    if ignore == true then
      ignore = {
      }
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
      s = ""
    end
    return s
  end,
  save = function(name)
    local crud = data.serialize(objects.collection)
    local fullname = name .. ".graph"
    if love.filesystem.exists(fullname) then
      love.filesystem.remove(fullname)
    end
    local file = love.filesystem.newFile(fullname,love.file_write)
    love.filesystem.open(file)
    love.filesystem.write(file,"HEADER\n")
    love.filesystem.write(file,crud)
    love.filesystem.close(file)
  end,
  load = function()
    local file = love.filesystem.newFile(name .. ".graph",love.file_read)
    local content = love.filesystem.read(file)
  end,
}

