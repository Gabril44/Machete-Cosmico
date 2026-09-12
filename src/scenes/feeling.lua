local AlienLines=require('src.entities.aliens.dialogue')
local Boss=require('src.entities.aliens.boss')
local PlayerLines=require('src.entities.player.dialogue')
local F={}
local D=require('src.entities.dog.model')
local Pet=require('src.entities.dog.petting')
function F.update(s,dt)
 local p,d=s.player,s.dog
 if s.stage=='gateopening' then
  local a=s.gateRunner;local t=s.stageTime
  a.x=t<.6 and 675-40*t/.6 or t<1.3 and 635 or 635+(t-1.3)*150
  a.moving=t<.6 or t>1.3;a.facingX=t<1.3 and -1 or 1;a.opening=t>=.6 and t<1.3
  s.gateProgress=math.max(0,math.min(1,(t-.7)/.6))
  if t>=1.3 then s.gateOpen=true end
  if t>=2.4 then s.stage='travel';s.gateRunner=nil;s:say(PlayerLines.gateFollow) end
 end
 local danger=s.stage=='intro' and math.max(0,math.min(1,(s.stageTime-9)/4)) or s.stage=='tutorial' and math.min(.8,s.cut/s.grassGoal) or s.stage=='arrival' and 1 or 0
 s.omen=danger
 s.insectTimer=(s.insectTimer or 0)-dt
 if (s.stage=='intro' or s.stage=='tutorial') and danger<.65 and s.insectTimer<=0 then
  s.audio.play('insect',.18);s.insectTimer=2.4
 end
 if s.stage~='preboss' then return false end
 p.moving=false
 if not s.lastPetStarted then
  d.behavior='nuzzle';D.move(d,{x=p.x+22,y=math.min(307,p.y+7)},90,dt)
  if ((d.x-p.x)^2+(d.y-p.y)^2)<30^2 and p.attackTimer<=0 and p.dashTimer<=0 then
   s.lastPetStarted=true;Pet.start(s);s:say(PlayerLines.beforeBoss)
  else p:update(dt,{x=0,y=0}) end
 else
  Pet.update(s,dt,{x=0,y=0})
  if not p.pet then
   s.stage='boss';s.stageTime=0;local boss=s:spawnEnemy('boss');Boss.beginEntry(boss);s:say(AlienLines.bossArrival)
  end
 end
 return true
end
function F.shadows(s)
 if (s.omen or 0)<.7 then return end
 local g=love.graphics;g.setColor(.025,.045,.05,(s.omen-.7)*.7)
 for i=1,3 do local x=((s.time*37+i*211)%1450)-80;g.ellipse('fill',x,177+i*34,56,13) end
end
return F
