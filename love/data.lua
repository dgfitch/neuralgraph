data = {
  -- largely from 12.1 of PIL
  serialize = function(o,s)
    if s == nil then
      s = ""
    end
    if type(o) == "number" then
      s = s .. o
    elseif type(o) == "string" then
      s = s .. string.format("%q", o)
    elseif type(o) == "table" then
      s = s .. "{\n"
      for k,v in pairs(o) do
        if not k ~= "update" then
          s = s .. " " .. k .. " = " .. data.serialize(v) .. ",\n"
        end
      end
      s = s .. "}\n"
    else
      error("cannot serialize a " .. type(o))
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

