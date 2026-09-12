local PlayerLines=require('src.entities.player.dialogue')
local A={}
local Petting=require('src.entities.dog.petting')
local Companion=require('src.entities.dog.behavior')
local dist=require('src.core.geometry').distance
function A.hurt(self,n,x,y)
 local p=self.player
 if p.inv>0 or self.debugGod then
  if not self.debugGod and p.dashTimer>.09 and not p.dodgeRewarded then
   p.dodgeRewarded=true;p.dodgeFlash=.22;self.audio.play('dodge',.7);self:burst(p.x,p.y-10,6,{.83,.94,.73})
  end
  return
 end
 p.sip=0
 Petting.cancel(self);p.hp=math.max(0,p.hp-n); p.inv=.85; self.shake=5; self.combo=0; self.audio.play('hurt'); self:burst(p.x,p.y,12,{1,.3,.23})
 if p.hp<=0 then self.state='dead'; self:save() end
end

function A.key(self,k)
 local p=self.player
 if p.pet and (k=='space' or k=='q' or k=='lshift' or k=='rshift' or k=='r' or k=='f') then Petting.cancel(self) end
 if k=='r' then Companion.throw(self)
 elseif k=='space' or k=='q' then if p:attack(k=='q') then self.audio.play('swing') end
 elseif k=='lshift' or k=='rshift' then if p:dash() then self.audio.play('dash') end
 elseif k=='f' then if p:activateBerserk() then self.audio.play('rage'); self:say(PlayerLines.rage); self.shake=6 end
 elseif k=='e' and dist(p,self.dog)<44 and Petting.start(self) then self.pet=true; Companion.pet(self);self.audio.play('bark'); self:say(PlayerLines.pet); self:burst(self.dog.x,self.dog.y-12,8,{1,.55,.6}) end
end
return A
