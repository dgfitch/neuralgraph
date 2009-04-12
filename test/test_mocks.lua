-- This is a set of fake LŐVE functions so we can run unit tests without 
-- actually drawing. May not work quite right yet.

love = {
  graphics = {
    newColor = function()
    end,
    newImage = function()
    end,
  },
}
