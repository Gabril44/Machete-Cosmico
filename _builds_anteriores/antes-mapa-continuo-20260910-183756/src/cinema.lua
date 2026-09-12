local D=require('src.dog')
local C={};local g=love.graphics
local function clamp(x) return math.max(0,math.min(1,x)) end
local function lerp(a,b,t) return a+(b-a)*clamp(t) end
local function ease(t) t=clamp(t);return t*t*(3-2*t) end
local function rect(x,y,w,h,r,gg,b,a) g.setColor(r,gg,b,a or 1);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function subtitle(t,font,y) rect(20,(y or 308)-3,600,font:getHeight()+7,.015,.018,.025,.82);g.setFont(font);g.setColor(.97,.91,.76);g.printf(t,25,y or 308,590,'center') end
local function walk(a,x,y,speed,dt)
 local dx,dy=x-a.x,y-a.y;local n=math.sqrt(dx*dx+dy*dy);a.moving=n>1
 if n>1 then local step=math.min(n,speed*dt);a.x=a.x+dx/n*step;a.y=a.y+dy/n*step;a.facingX=dx/n;a.facingY=dy/n end
end
function C.active(s) return s.stage=='intro' or s.stage=='ending' end
function C.finish(s)
 if s.stage=='intro' then
  s.stage='tutorial';s.stageTime=0;s.player.x=241;s.player.y=231;s.player.moving=false;s.player.weaponPose=nil;s.player.hidden=false;s.player.lift=0
  s.dog.x=219;s.dog.y=234;s.dog.facingX=1;s.dog.facingY=0;s.dog.hidden=false;s.dog.lift=0
  s:say('Un poco de pasto y nos vamos a dormir, Moro.')
 elseif s.stage=='ending' then s.state='win';s:save() end
end
function C.beginEnding(s,e)
 s.stage='ending';s.stageTime=0;s.shots={};s.cinemaSound=0;s.defeatedBoss=e
 s.endingScene={dogX=s.dog.x,dogY=s.dog.y,farmerX=s.player.x,farmerY=s.player.y,burst=false,beam=0,shipY=45}
 e.wind=0;e.charge=0;e.recover=0;e.flash=0;e.kx=0;e.ky=0
 local p=s.player;p.inv=0;p.attackTimer=0;p.berserk=false;p.berserkTimer=0;p.dashTimer=0;p.weaponPose='rest';p.moving=false;p.hidden=false;p.lift=0
 s.dog.behavior='watch';s.dog.stick=nil;s.dog.hasStick=false;s.dog.hop=0;s.dog.hidden=false;s.dog.lift=0;s.dog.moving=false;s.dog.barkTimer=0;s.dog.barkRepeat=0
end
function C.update(s,dt)
 local t=s.stageTime;local p=s.player;local dog=s.dog
 if s.stage=='intro' then
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
 else
  local scene=s.endingScene
  if not scene then C.beginEnding(s,s.boss or {x=320,y=160,kind='boss',hp=0,maxHp=85,flash=0,wind=0});scene=s.endingScene end
  scene.beam=t>=9 and t<14.6 and ease((t-9)/.6) or 0
  scene.shipY=45-190*ease((t-14.6)/1.4)
  if t<3.3 then
   p.moving=false;dog.moving=false
   if t>1 and not scene.surge then scene.surge=true;s.audio.play('wave') end
   if t>2.35 and not scene.burst then scene.burst=true;s.audio.play('hit');s.shake=7;s:burst(s.defeatedBoss.x,s.defeatedBoss.y-25,55,{.7,.49,1}) end
  elseif t<4 then
   p.moving=false;dog.moving=false
  elseif t<9 then
   -- Moro investigates on his own. The farmer remains where the fight ended.
   D.move(dog,{x=420,y=183},110,dt);p.moving=false
   if t>7.6 and not scene.bark then scene.bark=true;D.bark(dog,s.audio,{x=420,y=45}) end
  else
   dog.moving=false;dog.facingX=1;dog.facingY=.3
   if t>=9.8 then dog.lift=138*ease((t-9.8)/4.8) end
   if t>9.3 and t<14.6 then
    walk(p,420,207,150,dt);p.weaponPose='reach'
    local close=(p.x-420)^2+(p.y-207)^2<25
    if close and not scene.jumpTime then scene.jumpTime=t end
    if scene.jumpTime then p.lift=18*math.sin(clamp((t-scene.jumpTime)/.75)*math.pi) end
   else p.moving=false;p.lift=0 end
   if t>9 and not scene.beamSound then scene.beamSound=true;s.audio.play('wave') end
   if t>12 and not scene.cry then scene.cry=true;s.audio.play('hurt') end
   if t>=14.6 then dog.hidden=true end
  end
  if t>20 and not scene.rage then scene.rage=true;s.audio.play('rage') end
  if t>28 then C.finish(s) end
 end
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
  local e=s.defeatedBoss or {x=320,y=170}
  local f=ease((t-3.3)/1.5);z=lerp(1.5,1,f);cx=lerp(math.max(220,math.min(420,e.x)),320,f);cy=lerp(math.max(150,math.min(220,e.y-20)),180,f)
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
 end
 if s.stage=='ending' and s.defeatedBoss then
  local e=s.defeatedBoss;local f=ease((t-2.35)/.75);e.defeated=t>2.8
  g.push();g.translate(e.x,e.y);g.rotate(f*1.5);g.scale(1,1-f*.24);g.translate(-e.x,-e.y)
  e.flash=t<2.35 and math.sin(t*28)>.7 and .1 or 0;enemy(e,s.time);g.pop()
  if t<2.5 then
   g.setColor(.7,.5,1,.3);g.circle('line',e.x,e.y-25,10+t*8)
   for i=1,8 do local a=i*.785+t*3;rect(e.x+math.cos(a)*(28-t*4),e.y-25+math.sin(a)*(28-t*4),2,3,.7,.55,1) end
  end
 end
end

local function portrait(s,V)
 local t=s.stageTime-8;local rage=clamp((t-12)/4);local scream=t<11.8
 rect(0,0,640,360,.015+rage*.06,.018,.025)
 -- Original pixel portrait: the same work shirt, beard and old hat.
 g.push();g.translate(320+math.sin(t*55)*rage,185);g.scale(2.7+rage*.45)
 rect(-65,39,130,50,.27,.37,.35);rect(-23,15,46,40,.50,.31,.19)
 rect(-39,-43,78,81,.70,.46,.28);rect(-34,-40,60,71,.82,.57,.35)
 rect(-42,-21,7,24,.54,.34,.22);rect(35,-21,7,24,.54,.34,.22)
 rect(-33,15,66,25,.25,.18,.14);rect(-25,25,50,15,.23,.17,.14)
 rect(-64,-54,128,12,.65,.46,.23);rect(-38,-81,76,31,.60,.40,.20);rect(-38,-58,76,7,.24,.20,.15)
 rect(-31,-18,24,8,.95,.88,.72);rect(8,-18,24,8,.95,.88,.72)
 rect(-19,-18,5,8,.06,.07,.08);rect(15,-18,5,8,.06,.07,.08)
 g.setColor(.13,.11,.10);g.setLineWidth(4)
 g.line(-32,-24-rage*4,-8,-24+rage*7);g.line(8,-24+rage*7,32,-24-rage*4)
 rect(-3,-12,8,23,.65,.39,.23)
 if scream then rect(-16,13,32,21,.075,.035,.035);rect(-14,14,28,5,.97,.89,.71);rect(-10,28,20,4,.61,.23,.20)
 else rect(-19,18,38,7,.90,.80,.61);rect(-18,21,36,1,.22,.15,.13) end
 if rage<.6 then rect(-25,-7,2,22,.54,.74,.77,.7*(1-rage)) end
 rect(-38,-39,76,22,.045,.035,.035,rage*.66)
 g.pop()
 if rage>0 then
  for i=1,22 do local x=(i*83)%640;local y=(i*43+s.time*40)%360;rect(x,y,1,15+rage*30,.9,.23,.10,rage*.20) end
 end
 if scream then subtitle('¡¡MOROOOO!!',V.big,292)
 elseif t<15 then subtitle('...',V.big,296)
 else subtitle('Te voy a encontrar.',V.big,292) end
end

function C.draw(s,V)
 local t=s.stageTime
 if s.stage=='intro' then
  if t<2 then subtitle('LA QUERENCIA · 23:47',V.medium,286)
  elseif t<7.3 then subtitle('Dale, Moro. Cortamos un poco y entramos.',V.medium,296)
  elseif t<12 then subtitle('Mañana se viene la lluvia.',V.medium,296)
  elseif t<16 then
   rect(0,0,640,360,.005,.012,.018,.76)
   for i=1,14 do local x=205+i*19;local y=143+(i%3)*9;rect(x-18,y-15,41,46,.008,.019,.017,.95) end
   for i=1,3 do local x=185+i*74;local y=151+(i%2)*17;local a=clamp((t-12-i*.32)*2)*(.65+math.sin(t*3+i)*.2);rect(x,y,6,3,.56,1,.69,a);rect(x+15,y,6,3,.56,1,.69,a) end
   subtitle('Moro: grrrr...',V.medium,296)
  else subtitle('¿Qué pasa, compañero? No hay nada.',V.medium,296) end
  if t<1 then rect(0,0,640,360,0,0,0,1-t) end
 else
  if t<3.3 then
   local flash=1-clamp((t-2.35)/.16);if t>=2.35 then rect(0,0,640,360,.75,.65,1,flash*.6) end
  elseif t<5 then subtitle('... Ya está.',V.medium,297)
  elseif t<8 then subtitle('Moro. Vení para acá.',V.medium,297)
  elseif t<9.8 then subtitle('Moro... ¿qué estás mirando?',V.medium,297)
  elseif t<12 then subtitle('¡No! ¡Soltalo!',V.big,289)
  elseif t<16 then subtitle('¡¡MOROOOO!!',V.big,289)
  elseif t<26 then portrait(s,V)
  else rect(0,0,640,360,.015,.018,.025);subtitle('MACHETE CÓSMICO',V.title,139);subtitle('Esto recién empieza.',V.medium,210) end
 end
 rect(0,0,640,25,0,0,0);rect(0,334,640,26,0,0,0)
 g.setFont(V.small);g.setColor(.55,.59,.59);g.printf('ENTER omitir  ·  ESC pausa',20,341,600,'right')
end
return C
