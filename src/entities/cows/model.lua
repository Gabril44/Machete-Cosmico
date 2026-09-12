local PlayerLines=require('src.entities.player.dialogue')
local C={}
function C.reset(self)
 self.cows={{x=145,y=167,progress=0},{x=480,y=177,progress=0},{x=495,y=274,progress=0}}
 self.cowAlarmCooldown=0;self.cowWarningTime=0;self.cowWarningShown=false
end
function C.update(self,dt)
 for _,c in ipairs(self.cows) do if not c.lost then c.progress=math.max(0,c.progress+(c.active and dt or -dt*.85));if c.progress>=9 then c.lost=true;c.departTime=self.time;self.lost=self.lost+1;self:say(PlayerLines.cowLost);self.audio.play('hurt') end end end
 local abduction=false
 for _,c in ipairs(self.cows) do if c.active and not c.lost then abduction=true end end
 self.cowAlarmCooldown=math.max(0,(self.cowAlarmCooldown or 0)-dt)
 self.cowWarningTime=math.max(0,(self.cowWarningTime or 0)-dt)
 if abduction then
  if self.cowAlarmCooldown<=0 then self.audio.play('abduction',.8);self.cowAlarmCooldown=4 end
  if not self.cowWarningShown then self.cowWarningShown=true;self.cowWarningTime=3.4 end
 end

end
return C
