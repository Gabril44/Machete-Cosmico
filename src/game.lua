-- Session coordinator. The order below is part of the gameplay contract.
local PlayerActions=require('src.entities.player.actions')
local Player=require('src.entities.player.model')
local Dog=require('src.entities.dog.model')
local Petting=require('src.entities.dog.petting')
local World=require('src.world.map')
local Cinema=require('src.scenes.cinema')
local Feeling=require('src.scenes.feeling')
local Gore=require('src.effects.gore')
local Particles=require('src.effects.particles')
local Combat=require('src.systems.combat')
local Aliens=require('src.entities.aliens.system')
local Factory=require('src.entities.aliens.factory')
local Cows=require('src.entities.cows.model')
local Grass=require('src.world.grass')
local Progression=require('src.systems.progression')
local Projectiles=require('src.systems.projectiles')
local Pickups=require('src.systems.pickups')
local Session=require('src.systems.session')
local Dialogue=require('src.systems.dialogue')
local Controls=require('src.input.controls')
local G={};G.__index=G
function G.new(audio)
 local self=setmetatable({audio=audio,state='menu',time=0,best=tonumber((love.filesystem.read('best.txt'))) or 0},G)
 self:reset(); self.state='menu'; return self
end
G.reset=Session.reset
G.say=Dialogue.say
G.burst=Particles.burst
G.spawnEnemy=Factory.spawn
G.beginWave=Progression.beginWave
G.hurt=PlayerActions.hurt
function G:save() if self.debugUsed then return end; if self.score>self.best then self.best=self.score; love.filesystem.write('best.txt',tostring(self.best)) end end
function G:key(k)
 if k=='m' then self.audio.muted=not self.audio.muted; return end
 if self.state=='menu' then if k=='return' or k=='space' then self:reset() end; return end
 if self.state=='dead' or self.state=='win' then if k=='r' or k=='return' then self:reset() end; return end
 if k=='escape' then self.state=self.state=='pause' and 'play' or 'pause'; return end
 if self.state~='play' then return end
 if Cinema.active(self) then
  if k=='space' and self.state=='play' and self.endingScene and self.endingScene.qteActive then
   self.endingScene.qteDone=true;self.endingScene.qteActive=false;self.endingScene.qtePressed=true
  elseif k=='return' and self.stageTime>1 then Cinema.finish(self) end
  return
 end
 if self.stage=='preboss' then return end
 PlayerActions.key(self,k)
end
function G:update(dt,override)
 self.time=self.time+dt
 if self.state~='play' then return end
 if self.stop>0 then self.stop=self.stop-dt;return end
 self.stageTime=self.stageTime+dt;self.elapsed=self.elapsed+dt
 self.messageTime=math.max(0,self.messageTime-dt);self.shake=math.max(0,self.shake-dt*20)
 Combat.effects(self,dt)
 Particles.update(self,dt)
 Gore.update(self,dt)
 Dog.update(self.dog,dt,self.audio)
 if Feeling.update(self,dt) then return end
 if Cinema.active(self) then Cinema.update(self,dt);return end
 local input=override or Controls.movement()
 Petting.update(self,dt,input)
 local p=self.player;p.maxX=self.gateOpen and 1258 or 612;p:update(dt,input)
 if input.x~=0 or input.y~=0 then self.walked=self.walked+dt end
 Dog.follow(self.dog,p,dt,self)
 World.update(self,dt)
 self.chain=math.max(0,self.chain-dt);if self.chain==0 then self.combo=0 end
 Grass.update(self)
 Progression.update(self,dt)
 if Aliens.update(self,dt) then return end
 Cows.update(self,dt)
 Projectiles.update(self,dt)
 Pickups.update(self,dt)
end
return G
