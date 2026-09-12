local A={}
local geometry=require('src.core.geometry')
local dist,move=geometry.distance,geometry.move

function A.update(self,e,p,dt)
 local d=dist(e,p)
    if e.wind>0 then
     e.wind=math.max(0,e.wind-dt)
     if e.wind==0 then self.shots[#self.shots+1]={x=e.x,y=e.y,vx=e.aimX*110,vy=e.aimY*110,t=5};e.cool=1.65 end
    elseif e.cool<=0 then
     local n=math.max(1,d);e.aimX=(p.x-e.x)/n;e.aimY=(p.y-e.y)/n;e.wind=.45
    elseif d>125 then move(e,p,32,dt) elseif d<70 then move(e,p,-24,dt) end

end
return A
