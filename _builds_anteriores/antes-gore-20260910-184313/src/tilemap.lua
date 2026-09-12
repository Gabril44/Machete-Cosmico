local T={size=16,width=1280,height=224}
function T.new()
 local map={tiles={}}
 for row=0,13 do
  map.tiles[row+1]={}
  for col=0,79 do
   local road=row==8 or row==9 or (col>=18 and col<=21) or (col>=58 and col<=61)
   map.tiles[row+1][col+1]=road and 2 or 1
  end
 end
 return map
end
function T.draw(map)
 local g=love.graphics
 if not map.canvas then
  local previous=g.getCanvas();g.push("all");g.origin();g.setScissor();map.canvas=g.newCanvas(T.width,T.height);g.setCanvas(map.canvas);g.clear()
  for row,tiles in ipairs(map.tiles) do for col,kind in ipairs(tiles) do
   local x,y=(col-1)*16,(row-1)*16;local n=(col*19+row*37)%7
   if kind==2 then g.setColor(.235+n*.001,.23+n*.001,.17) else g.setColor(.12+n*.001,.19+n*.001,.16) end
   g.rectangle('fill',x,y,16,16)
   for i=1,3 do
    local px=x+(col*7+i*5+row)%15;local py=y+(row*3+i*7+col)%15
    if kind==2 then g.setColor(.28,.265,.195,.65) else g.setColor(.23,.31,.20,.6) end
    g.rectangle('fill',px,py,i==2 and 2 or 1,1)
   end
  end end
  g.setCanvas(previous);g.pop()
 end
 g.setColor(1,1,1);g.draw(map.canvas,0,96)
end
return T
