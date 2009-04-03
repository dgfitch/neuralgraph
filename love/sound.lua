-- Generic sound loader, should eventually look in working dir and save dir

sound = {
  recurse = function(fileList, dir)
    local n = love.filesystem.enumerate(dir)
    for k,v in ipairs(n) do
      table.insert(fileList, v)
    end
  end,
  list = function()
    local files = {}
    sound.recurse(files, love.filesystem.getSaveDirectory())
    return files
  end,
}
