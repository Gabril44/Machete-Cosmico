local function dist(a,b) return ((a.x-b.x)^2+(a.y-b.y)^2)^.5 end
local function move(a,b,s,dt)
 local d=dist(a,b); if d>1 then a.x=a.x+(b.x-a.x)/d*s*dt; a.y=a.y+(b.y-a.y)/d*s*dt end
 return d
end
return {distance=dist,move=move}
