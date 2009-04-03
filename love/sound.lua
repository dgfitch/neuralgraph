-- Generic sound loader, should eventually look in working dir and save dir

sound = {
  recurse = function(fileList, dir)
    local n = love.filesystem.enumerate(dir)
    for k,v in ipairs(n) do
      table.insert(fileList, v)
    end
    -- force insert some stuff for now
    local f = "sounds/Fugwhump_AnalogKitLite/"
    fileList[0] = f .. "fugwhump_akl_09_kick.ogg"
    fileList[1] = f .. "fugwhump_akl_10_kick.ogg"
    fileList[2] = f .. "fugwhump_akl_11_snare.ogg"
    fileList[3] = f .. "fugwhump_akl_12_snare.ogg"
    fileList[4] = f .. "fugwhump_akl_13_snare.ogg"
    fileList[5] = f .. "fugwhump_akl_14_hat.ogg"
    fileList[6] = f .. "fugwhump_akl_15_perc.ogg"
    fileList[7] = f .. "fugwhump_akl_16_perc.ogg"
    fileList[8] = f .. "fugwhump_akl_17_perc.ogg"
  end,
  list = function()
    local files = {}
    sound.recurse(files, love.filesystem.getSaveDirectory())
    return files
  end,
}
