local A={}
local geometry=require('src.core.geometry')
local dist,move=geometry.distance,geometry.move

function A.update(self,e,p,dt)
 local d=dist(e,p)
    local target=nil;local near=math.huge;for _,c in ipairs(self.cows) do if not c.lost and dist(e,c)<near then target=c;near=dist(e,c) end end
    if target then if move(e,target,36,dt)<22 then target.active=true end else move(e,p,43,dt);if d<22 and e.cool<=0 then self:hurt(8,e.x,e.y);e.cool=1 end end

end
return A
