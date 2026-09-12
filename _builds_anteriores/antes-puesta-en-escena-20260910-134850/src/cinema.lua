local D=require('src.dog')
local C={};local g=love.graphics
local function clamp(x) return math.max(0,math.min(1,x)) end
local function lerp(a,b,t) return a+(b-a)*clamp(t) end
local function rect(x,y,w,h,r,gg,b,a) g.setColor(r,gg,b,a or 1);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function subtitle(t,font,y) rect(20,(y or 308)-3,600,font:getHeight()+7,.015,.018,.025,.82);g.setFont(font);g.setColor(.97,.91,.76);g.printf(t,25,y or 308,590,'center') end
function C.active(s) return s.stage=='intro' or s.stage=='ending' end
function C.finish(s)
 if s.stage=='intro' then
  s.stage='tutorial';s.stageTime=0;s.player.x=241;s.player.y=231;s.player.moving=false;s.dog.x=219;s.dog.y=231;s.dog.facingX=1;s.dog.facingY=0;s:say('Un poco de pasto y nos vamos a dormir, Moro.')
 elseif s.stage=='ending' then s.state='win';s:save() end
end
function C.update(s,dt)
 local t=s.stageTime;local p=s.player
 if s.stage=='intro' then
  if t<6 then p.x=297;p.y=lerp(99,193,(t-1)/5);p.facingX=0;p.facingY=1;p.moving=t>1;D.move(s.dog,{x=280,y=p.y+12},65,dt)
  elseif t<10 then p.x=lerp(297,241,(t-6)/4);p.y=lerp(193,231,(t-6)/4);p.facingX=-1;p.facingY=.3;p.moving=true;D.move(s.dog,{x=p.x-22,y=p.y+7},80,dt)
  else p.moving=false;s.dog.facingX=1;s.dog.facingY=-1 end
  if t>10 and s.cinemaSound==0 then s.audio.play('bark');s.cinemaSound=1 end
  if t>16 then C.finish(s) end
 else
  if t<3 then D.move(s.dog,{x=320,y=169},85,dt);D.move(p,{x=320,y=200},65,dt);p.facingX=0;p.facingY=-1
  elseif t<8 then s.dog.y=169-(t-3)*24;p.x=320;p.y=200-math.sin(clamp((t-3)/2)*math.pi)*22;p.moving=true
  else p.moving=false end
  if t>5 and s.cinemaSound==0 then s.audio.play('hurt');s.shake=5;s.cinemaSound=1 end
  if t>12 and s.cinemaSound==1 then s.audio.play('rage');s.cinemaSound=2 end
  if t>20 then C.finish(s) end
 end
end
function C.camera(s)
 if not C.active(s) or s.state=='menu' then return end
 local t=s.stageTime;local z,cx,cy=1.45,297,167
 if s.stage=='intro' then
  if t<6 then cy=lerp(123,180,t/6)
  elseif t<10 then cx=lerp(297,260,(t-6)/4);cy=205
  elseif t<14 then cx=lerp(260,445,(t-10)/3);cy=lerp(205,125,(t-10)/3);z=lerp(1.45,2,(t-10)/3)
  else z=lerp(2,1,(t-14)/2);cx=lerp(445,320,(t-14)/2);cy=lerp(125,180,(t-14)/2) end
 else z=1.35;cx=320;cy=160 end
 g.translate(320,180);g.scale(z);g.translate(-cx,-cy)
end
local function portrait(s,V)
 local t=s.stageTime;local rage=clamp((t-12)/4);local scream=t<11.8
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
  elseif t<7 then subtitle('Dale, Moro. Cortamos un poco y entramos.',V.medium,296)
  elseif t<10 then subtitle('Mañana se viene la lluvia.',V.medium,296)
  elseif t<14 then
   -- The camera discovers eyes; the farmer has not noticed them yet.
   rect(0,0,640,360,.005,.012,.018,.76)
   for i=1,14 do local x=205+i*19;local y=143+(i%3)*9;rect(x-18,y-15,41,46,.008,.019,.017,.95) end
   for i=1,3 do local x=185+i*74;local y=151+(i%2)*17;local a=clamp((t-10-i*.32)*2)*(.65+math.sin(t*3+i)*.2);rect(x,y,6,3,.56,1,.69,a);rect(x+15,y,6,3,.56,1,.69,a) end
   subtitle('Moro: grrrr...',V.medium,296)
  else subtitle('¿Qué pasa, compañero? No hay nada.',V.medium,296) end
  if t<1 then rect(0,0,640,360,0,0,0,1-t) end
 else
  if t<3 then subtitle('Moro... ¡no te acerques!',V.medium,297)
  elseif t<5 then subtitle('¡No! ¡Soltalo!',V.big,289)
  elseif t<8 then subtitle('¡¡MOROOOO!!',V.big,289)
  elseif t<18 then portrait(s,V)
  else rect(0,0,640,360,.015,.018,.025);subtitle('MACHETE CÓSMICO',V.title,139);subtitle('Esto recién empieza.',V.medium,210) end
 end
 rect(0,0,640,25,0,0,0);rect(0,334,640,26,0,0,0)
 g.setFont(V.small);g.setColor(.55,.59,.59);g.printf('ENTER omitir  ·  ESC pausa',20,341,600,'right')
end
return C
