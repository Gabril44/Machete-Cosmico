local P={}
local dist=require('src.core.geometry').distance
function P.update(self,dt)
 local p=self.player
 for i=#self.shots,1,-1 do
  local s=self.shots[i];s.x=s.x+s.vx*dt;s.y=s.y+s.vy*dt;s.t=s.t-dt
  if p:isAttackActive() and p:inArc(s) then s.t=0;p:addRage(3);self:burst(s.x,s.y,5,{.5,1,1}) elseif dist(s,p)<10 then self:hurt(9,s.x,s.y);s.t=0 end
  if s.t<=0 then table.remove(self.shots,i) end
 end

end
return P
