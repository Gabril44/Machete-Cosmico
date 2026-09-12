local S={}
local D=require('src.entities.dog.model')
local Gore=require('src.effects.gore')
local H=require('src.scenes.helpers')
local clamp,lerp,ease,rect,subtitle,walk=H.clamp,H.lerp,H.ease,H.rect,H.subtitle,H.walk
local g=love.graphics
function S.update(s,dt,C)
 local t=s.stageTime;local p=s.player;local dog=s.dog
  p.hidden=t<.7;dog.hidden=t<1.6
  p.weaponPose=t<7.3 and 'sheathed' or t<8.7 and 'drawing' or 'rest';p.drawProgress=ease((t-7.3)/1.4)
  if t<4.1 then
   if t>.7 then walk(p,297,157,21,dt) end
   if t>1.6 then D.move(dog,{x=297,y=139},30,dt) end
  elseif t<7.3 then
   walk(p,241,231,34,dt);D.move(dog,{x=219,y=234},48,dt)
  else
   p.moving=false;dog.moving=false
   if t<9 then p.facingX=-.6;p.facingY=.8 end
  end
  if t>8 and s.cinemaSound==0 then s.audio.play('swing');s.cinemaSound=1 end
  if t>12 and s.cinemaSound==1 then D.bark(dog,s.audio,{x=440,y=110});s.cinemaSound=2 end
  if t>18 then C.finish(s) end
end
return S
