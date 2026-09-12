local DogLines=require('src.entities.dog.dialogue')
local PlayerLines=require('src.entities.player.dialogue')
local Petting=require('src.entities.dog.petting')
local Gore=require('src.effects.gore')
local D=require('src.entities.dog.model')
local C={};local g=love.graphics
local H=require('src.scenes.helpers')
local clamp,lerp,ease,rect,subtitle,walk=H.clamp,H.lerp,H.ease,H.rect,H.subtitle,H.walk
local g=love.graphics
function C.active(s) return s.stage=='intro' or s.stage=='ending' end
function C.finish(s)
 if s.stage=='intro' then
  s.stage='tutorial';s.stageTime=0;s.player.x=241;s.player.y=231;s.player.moving=false;s.player.weaponPose=nil;s.player.hidden=false;s.player.lift=0
  s.dog.x=219;s.dog.y=234;s.dog.facingX=1;s.dog.facingY=0;s.dog.hidden=false;s.dog.lift=0
  s:say(PlayerLines.tutorial)
 elseif s.stage=='ending' then s.state='win';s:save() end
end
function C.beginEnding(s,e)
 Petting.cancel(s)
 s.stage='ending';s.stageTime=0;s.shots={};s.cinemaSound=0;s.defeatedBoss=e
 s.endingScene={base=e.spawnBase or (s.region=='field' and 640 or 0),dogX=s.dog.x,dogY=s.dog.y,farmerX=s.player.x,farmerY=s.player.y,burst=false,beam=0,shipY=45}
 e.wind=0;e.charge=0;e.recover=0;e.flash=0;e.kx=0;e.ky=0
 local p=s.player;p.inv=0;p.attackTimer=0;p.berserk=false;p.berserkTimer=0;p.dashTimer=0;p.weaponPose='rest';p.moving=false;p.hidden=false;p.lift=0
 s.dog.behavior='watch';s.dog.stick=nil;s.dog.hasStick=false;s.dog.hop=0;s.dog.hidden=false;s.dog.lift=0;s.dog.moving=false;s.dog.barkTimer=0;s.dog.barkRepeat=0
end
local Intro=require('src.scenes.intro')
local Ending=require('src.scenes.ending')
function C.update(s,dt)
 if s.stage=='intro' then Intro.update(s,dt,C) else Ending.update(s,dt,C) end
end
function C.camera(s)
 if not C.active(s) or s.state=='menu' then return end
 local t=s.stageTime;local z,cx,cy=1.45,297,167
 if s.stage=='intro' then
  if t<4.1 then cy=lerp(137,175,ease(t/4.1))
  elseif t<9 then cx=lerp(297,260,ease((t-4.1)/3.2));cy=lerp(175,211,ease((t-4.1)/3.2))
  elseif t<12 then cx=260;cy=211
  elseif t<16 then cx=lerp(260,445,ease((t-12)/2));cy=lerp(211,125,ease((t-12)/2));z=lerp(1.45,2,ease((t-12)/2))
  else z=lerp(2,1,ease((t-16)/2));cx=lerp(445,320,ease((t-16)/2));cy=lerp(125,180,ease((t-16)/2)) end
 else
  local e=s.defeatedBoss or {x=320,y=170};local base=s.endingScene and s.endingScene.base or 0
  local f=ease((t-3.3)/1.5);z=lerp(1.5,1,f);cx=lerp(math.max(base+220,math.min(base+420,e.x)),base+320,f);cy=lerp(math.max(150,math.min(220,e.y-20)),180,f)
 end
 g.translate(320,180);g.scale(z);g.translate(-cx,-cy)
end
function C.world(s,ufo,enemy)
 local t=s.stageTime
 if s.stage=='intro' then
  -- A lit doorway and threshold mask give the exit an actual origin.
  local open=t<2.8 and 1 or 1-ease((t-2.8)/.6)
  rect(284,75,25*open,24,.58,.40,.20)
 end
 if s.stage=='boss' or s.stage=='ending' then
  local base=s.endingScene and s.endingScene.base or (s.boss and s.boss.spawnBase) or 0;g.push();g.translate(base,0)
  local depart=s.stage=='ending' and ease((t-14.6)/1.4) or 0
  for i,ship in ipairs({{77,48,20},{168,34,15},{297,47,18},{545,37,23},{591,68,14}}) do ufo(ship[1],ship[2]+math.sin(s.time*.8+i)*2-depart*140,ship[3],s.time) end
  local sy=s.endingScene and s.endingScene.shipY or 45
  ufo(420,sy,49,s.time)
  if s.stage=='ending' then
   local beam=s.endingScene and s.endingScene.beam or 0
   if beam>0 then
    g.setColor(.53,1,.74,.18*beam);g.polygon('fill',398,183,442,183,429,sy+3,411,sy+3)
    g.setColor(.77,1,.82,.85*beam);g.ellipse('fill',420,sy+3,10,3)
    g.setColor(.6,1,.75,.3*beam);g.ellipse('line',420,183,22,6)
   end
  end
  g.pop()
 end
 if s.stage=='ending' and s.defeatedBoss then
  local e=s.defeatedBoss;local f=ease(t/.65);e.defeated=true;e.roar=0;e.moving=false;e.impact=0
  g.push();g.translate(e.x,e.y);g.rotate(f*1.5);g.scale(1,1-f*.24);g.translate(-e.x,-e.y)
  e.flash=t>2.35 and t<2.48 and .1 or 0;enemy(e,s.time);g.pop()
  if s.endingScene and s.endingScene.qteActive then
   g.setColor(.32,.49,.40);g.setLineWidth(7)
   g.line(e.x+25,e.y-1,s.player.x+9,s.player.y-22,s.player.x+10,s.player.y-38+math.sin(s.time*22))
   g.setLineWidth(1)
   local input=require('src.input.controls');local label=input.label('attack')
   g.setFont(require('src.ui.view').small)
   local keyWidth=math.max(56,g.getFont():getWidth(label)+12)
   local keyX,keyY=s.player.x-keyWidth/2,s.player.y-72
   local pulse=.65+.25*math.sin(s.time*4)
   rect(keyX-2,keyY-2,keyWidth+4,25,.75,.64,.32,pulse)
   rect(keyX,keyY+3,keyWidth,19,.25,.28,.26)
   rect(keyX,keyY,keyWidth,18,.91,.90,.78)
   rect(keyX+2,keyY+1,keyWidth-4,1,1,1,.92)
   rect(keyX+3,keyY+14,keyWidth-6,2,.64,.65,.56)
   g.setColor(.10,.15,.14)
   local font=g.getFont();g.print(label,keyX+(keyWidth-font:getWidth(label))/2,keyY+2)
  end
  if t<.6 then
   g.setColor(.7,.5,1,.3);g.circle('line',e.x,e.y-25,10+t*8)
   for i=1,8 do local a=i*.785+t*3;rect(e.x+math.cos(a)*(28-t*4),e.y-25+math.sin(a)*(28-t*4),2,3,.7,.55,1) end
  end
 end
end

local portrait=require('src.entities.player.portrait').draw
function C.draw(s,V)
 local t=s.stageTime
 if s.stage=='intro' then
  if t<2 then subtitle('LA QUERENCIA · 23:47',V.medium,286)
  elseif t<7.3 then subtitle(PlayerLines.leaveHouse,V.medium,296)
  elseif t<12 then subtitle(PlayerLines.rain,V.medium,296)
  elseif t<16 then
   rect(0,0,640,360,.005,.012,.018,.76)
   for i=1,14 do local x=205+i*19;local y=143+(i%3)*9;rect(x-18,y-15,41,46,.008,.019,.017,.95) end
   for i=1,3 do local x=185+i*74;local y=151+(i%2)*17;local a=clamp((t-12-i*.32)*2)*(.65+math.sin(t*3+i)*.2);rect(x,y,6,3,.56,1,.69,a);rect(x+15,y,6,3,.56,1,.69,a) end
   subtitle(DogLines.growl,V.medium,296)
  else subtitle(PlayerLines.reassure,V.medium,296) end
  if t<1 then rect(0,0,640,360,0,0,0,1-t) end
 else
  if t<3.3 then
   local flash=1-clamp((t-2.35)/.16);if t>=2.35 then rect(0,0,640,360,.75,.65,1,flash*.6) end
  elseif t<5 then subtitle(PlayerLines.finished,V.medium,297)
  elseif t<8 then subtitle(PlayerLines.comeHere,V.medium,297)
  elseif t<9.8 then subtitle(PlayerLines.look,V.medium,297)
  elseif t<12 then subtitle(PlayerLines.release,V.big,289)
  elseif t<16 then subtitle(PlayerLines.scream,V.big,289)
  elseif t<26 then portrait(s,V)
  else rect(0,0,640,360,.015,.018,.025);subtitle('MACHETE CÓSMICO',V.title,139);subtitle('Esto recién empieza.',V.medium,210) end
 end
 rect(0,0,640,25,0,0,0);rect(0,334,640,26,0,0,0)
 local input=require('src.input.controls')
 g.setFont(V.small);g.setColor(.55,.59,.59);g.printf(input.label('skip')..' omitir  ·  '..input.label('pause')..' pausa',20,341,600,'right')
end
return C
