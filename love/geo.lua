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

