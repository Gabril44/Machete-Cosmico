local C={}
local Gore=require('src.effects.gore')
local dist=require('src.core.geometry').distance
function C.effects(self,dt)
 for _,e in ipairs(self.enemies) do
  e.impact=math.max(0,(e.impact or 0)-dt)
  if e.impact>.1 and math.abs(e.kx or 0)+math.abs(e.ky or 0)>35 then
   e.dustTimer=(e.dustTimer or 0)-dt;if e.dustTimer<=0 then self:burst(e.x,e.y+5,2,{.38,.31,.19});e.dustTimer=.06 end
  end
 end
end
function C.strike(self,e)
 local p=self.player
  if p:isAttackActive() and e.lastSwing~=p.swing and p:inArc(e) then
   p.bloodLevel=math.min(10,(p.bloodLevel or 0)+1);Gore.hit(self,e,p,p.berserk and 3 or p.heavy and 2 or 1);e.lastSwing=p.swing;e.hp=e.hp-p.damage;e.flash=.12;e.stun=e.kind=='boss' and .05 or .22
   local d=math.max(1,dist(e,p)); local force=p.heavy and 340 or 190; if e.kind=='boss' then force=force*.22 end
   e.kx=(e.x-p.x)/d*force;e.ky=(e.y-p.y)/d*force
   e.impact=.32;e.impactSide=e.x<p.x and -1 or 1
   if p.heavy then self:burst(e.x,e.y+4,14,{.43,.34,.19}) end
   p:addRage(9);self.combo=self.combo+1;self.chain=2.2;self.stop=.035;self.shake=p.heavy and 4 or 2;self.audio.play('hit');self:burst(e.x,e.y,12)
  end
end
return C
