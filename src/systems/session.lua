local S={}
local Player=require('src.entities.player.model')
local Dog=require('src.entities.dog.model')
local Gore=require('src.effects.gore')
local World=require('src.world.map')
local Cows=require('src.entities.cows.model')
local Grass=require('src.world.grass')
function S.reset(self)
 self.omen=0;self.insectTimer=0;self.lastPetStarted=false
 if self.audio.stopAll then self.audio.stopAll() end
 self.debugUsed=false;self.debugGod=false;Gore.reset(self)
 self.player=Player.new(300,205); self.dog=Dog.new(289,104); self.enemies={}; self.particles={}; self.drops={}; self.shots={}; self.marks={}
 Cows.reset(self)
 Grass.reset(self)
 self.stage='intro'; self.state='play'; self.stageTime=0; self.wave=0; self.queue=0; self.spawn=0; self.score=0; self.kills=0; self.combo=0; self.chain=0; self.pet=false; self.cut=0; self.walked=0; self.shake=0; self.stop=0; self.message=''; self.messageTime=0; self.elapsed=0; self.lost=0; self.boss=nil; self.player.x=297;self.player.y=100;self.cinemaSound=0;self.endingScene=nil;self.defeatedBoss=nil;self.player.weaponPose='sheathed';self.player.hidden=true;self.dog.hidden=true;self.gateOpen=false;self.transition=0;self.farmCows=nil;World.setup(self,'farm')
end

return S
