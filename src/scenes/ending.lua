local S={}
local D=require('src.entities.dog.model')
local Gore=require('src.effects.gore')
local H=require('src.scenes.helpers')
local clamp,lerp,ease,rect,subtitle,walk=H.clamp,H.lerp,H.ease,H.rect,H.subtitle,H.walk
local g=love.graphics
function S.update(s,dt,C)
 local t=s.stageTime;local p=s.player;local dog=s.dog
  local scene=s.endingScene
  if not scene then C.beginEnding(s,s.boss or {x=320,y=160,kind='boss',hp=0,maxHp=85,flash=0,wind=0});scene=s.endingScene end
  if t>=1.9 and t<2.2 and not scene.qteDone then
   scene.qteActive=true;scene.qteWait=(scene.qteWait or 0)+dt
   s.stageTime=1.9;t=1.9
  end
  scene.beam=t>=9 and t<14.6 and ease((t-9)/.6) or 0
  scene.shipY=45-190*ease((t-14.6)/1.4)
  if t<3.3 then
   p.moving=false;dog.moving=false
   local e=s.defeatedBoss
   if t>.6 then
    local approach=ease((t-.6)/1.25)
    p.x=lerp(scene.farmerX,e.x+15,approach);p.y=lerp(scene.farmerY,e.y-6,approach)
    p.moving=approach<1;p.facingX=1;p.facingY=0
   end
   p.finishWaiting=scene.qteActive or false
   if t>=1.85 then p.weaponPose='finish';p.finishStroke=scene.qteActive and .04+math.sin(s.time*22)*.025 or ease((t-2.12)/.23) end
   if t>.6 and not scene.surge then scene.surge=true;s.audio.play('hit',.6);s:burst(e.x+25,e.y+3,14,{.43,.34,.23}) end
   if t>2.35 and not scene.burst then scene.burst=true;Gore.death(s,e,p);s.audio.play('hit');s.shake=7;s.stop=.075;s:burst(e.x+25,e.y,30,{.39,.60,.16}) end
   if t>2.8 then p.finishStroke=1-ease((t-2.8)/.4) end
  elseif t<4 then
   p.moving=false;dog.moving=false;p.weaponPose='rest';p.finishStroke=nil
  elseif t<9 then
   -- Moro investigates on his own. The farmer remains where the fight ended.
   D.move(dog,{x=(scene.base or 0)+420,y=183},150,dt);p.moving=false
   if t>7.6 and not scene.bark then scene.bark=true;D.bark(dog,s.audio,{x=(scene.base or 0)+420,y=45}) end
  else
   dog.moving=false;dog.facingX=1;dog.facingY=.3
   if t>=9.8 then dog.lift=138*ease((t-9.8)/4.8) end
   if t>9.3 and t<14.6 then
    walk(p,(scene.base or 0)+420,207,150,dt);p.weaponPose='reach'
    local close=(p.x-(scene.base or 0)-420)^2+(p.y-207)^2<25
    if close and not scene.jumpTime then scene.jumpTime=t end
    if scene.jumpTime then p.lift=18*math.sin(clamp((t-scene.jumpTime)/.75)*math.pi) end
   else p.moving=false;p.lift=0 end
   if t>9 and not scene.beamSound then scene.beamSound=true;s.audio.play('wave') end
   if t>12 and not scene.cry then scene.cry=true;s.audio.play('hurt') end
   if t>=14.6 then dog.hidden=true end
  end
  if t>=14.6 then
   p.weaponPose='furious'
   if not scene.silence then scene.silence=true;if s.audio.stopAll then s.audio.stopAll() end;s.audio.play('tag',.45);dog.barkRepeat=0;dog.barkTimer=0 end
   if t>=15 and not scene.lastBark then scene.lastBark=true;s.audio.play('bark',.22,.88) end
  end
  if t>20 and not scene.rage then scene.rage=true;s.audio.play('rage') end
  if t>28 then C.finish(s) end
end
return S
