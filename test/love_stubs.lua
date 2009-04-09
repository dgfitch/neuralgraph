g = function()
  return nil
end
love = {
  meta = {
    __index = function(t, k)
      return {}
    end,
  },
  graphics = {
    newColor = g
  },
}

setmetatable(love, love.meta)
setmetatable(love.graphics, love.meta)
