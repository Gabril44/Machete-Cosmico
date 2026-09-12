local A={}
local geometry=require('src.core.geometry')
local dist,move=geometry.distance,geometry.move

function A.update(self,e,p,dt)
 local d=dist(e,p)
    if e.wind>0 then e.wind=e.wind-dt;if e.wind<=0 then if d<30 then self:hurt(e.kind=='brute' and 19 or 11,e.x,e.y) end;e.cool=.9 end
    elseif d<22 and e.cool<=0 then e.wind=e.kind=='brute' and .65 or .38
    elseif d>20 then move(e,p,e.kind=='brute' and 33 or 52,dt) end
end
return A
