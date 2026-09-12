local PlayerLines=require('src.entities.player.dialogue')
local P={}
function P.beginWave(self,n)
 self.stage='wave'; self.stageTime=0; self.wave=n; self.queue=6+n*3; self.spawn=.5
 self.player.hp=math.min(100,self.player.hp+15)
 self:say(PlayerLines.waves[n]); self.audio.play('wave')
end

function P.update(self,dt)
 if self.stage=='tutorial' and self.walked>1 and self.cut>=self.grassGoal and self.pet then self.stage='arrival';self.stageTime=0;self:say(PlayerLines.arrival);self.audio.play('wave') end
 if self.stage=='arrival' and self.stageTime>3 then self:beginWave(1);local e=self:spawnEnemy('thief'); e.x=145;e.y=148 end
 if self.stage=='wave' then
  self.spawn=self.spawn-dt
  if self.queue>0 and self.spawn<=0 then
   local k=self.queue%3==0 and 'thief' or 'raider'; if self.wave>=2 and self.queue%4==0 then k='gunner' end; if self.wave==3 and self.queue%5==0 then k='brute' elseif self.wave>=2 and self.queue%5==0 then k='looter' end
   if self.region=='field' and k=='thief' then k='looter' end
   self:spawnEnemy(k);self.queue=self.queue-1;self.spawn=1.45
  end
  if self.queue==0 and #self.enemies==0 then self.stage='rest';self.stageTime=0;self:say(PlayerLines.rest) end
 elseif self.stage=='rest' and self.stageTime>4 then
  if self.wave==2 then self.stage='gateopening';self.stageTime=0;self.gateRunner={x=675,y=226,kind='raider',hp=2,maxHp=2,flash=0,wind=0,facingX=-1};self:say(PlayerLines.gateNotice)
  elseif self.wave<3 then self:beginWave(self.wave+1) else self.stage='preboss';self.stageTime=0;self.lastPetStarted=false;self.shots={} end
 end

end
return P
