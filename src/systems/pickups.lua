local P={}
local dist=require('src.core.geometry').distance
function P.update(self,dt)
 local p=self.player
 for i=#self.drops,1,-1 do local d=self.drops[i];d.t=d.t-dt;if dist(d,p)<18 then
  p.hp=math.min(100,p.hp+18);self.audio.play('pickup');d.t=0
  if #self.enemies==0 and not p.moving and p.attackTimer<=0 and p.dashTimer<=0 and not p.pet then p.sip=1.1 end
 end;if d.t<=0 then table.remove(self.drops,i) end end
end
return P
