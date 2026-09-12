local C={}
local function distance(a,b) return ((a.x-b.x)^2+(a.y-b.y)^2)^.5 end
function C.pet(s)
 local d=s.dog;d.behavior='happy';d.behaviorTime=1.8;d.affection=(d.affection or 0)+1;d.moving=false
 s:burst(d.x,d.y-15,7,{1,.62,.62})
end
function C.throw(s)
 local d=s.dog;local p=s.player
 d.stick={x=math.max(36,math.min(s.gateOpen and 1242 or 602,p.x+p.facingX*95)),y=math.max(111,math.min(302,p.y+p.facingY*95))};d.behavior='fetch';d.behaviorTime=8;d.hasStick=false
 s.audio.play('swing');s:say('¡Buscá, Moro!')
end
function C.update(d,p,dt,s,D)
 d.behaviorTime=math.max(0,(d.behaviorTime or 0)-dt);d.lifeClock=(d.lifeClock or 0)+dt
 d.activityCycle=d.activityCycle or 0;d.behavior=d.behavior or 'follow'
 if (d.barkTimer or 0)>0 then d.moving=false;return end
 if d.behavior=='happy' and d.behaviorTime>0 then
  d.moving=false;d.hop=math.abs(math.sin(d.lifeClock*10))*3;return
 end
 d.hop=0
 if d.behavior=='fetch' and d.stick then
  D.move(d,d.stick,145,dt)
  if distance(d,d.stick)<6 then d.hasStick=true;d.behavior='return' end;return
 elseif d.behavior=='return' then
  D.move(d,p,140,dt)
  if distance(d,p)<24 then d.hasStick=false;d.stick=nil;C.pet(s);s.audio.play('bark') end;return
 end
 local gap=distance(d,p)
 if gap>105 then d.behavior='follow';D.move(d,{x=p.x-p.facingX*22,y=p.y-p.facingY*22},145,dt);return end
 if #s.enemies>0 then
  d.behavior='watch';d.moving=false
  if gap>38 then D.move(d,{x=p.x-p.facingX*28,y=p.y-p.facingY*28},130,dt)
  elseif d.behaviorTime<=0 then
   local e=s.enemies[1];local dx,dy=e.x-d.x,e.y-d.y;local n=math.max(1,distance(d,e));d.facingX=dx<0 and -1 or 1;d.facingY=dy/n;d.behaviorTime=.7
  end;return
 end
 if s.stage=='travel' then d.behavior='guide';D.move(d,{x=math.min(925,p.x+53),y=225},95,dt);return end
 if d.behaviorTime<=0 then
  d.activityCycle=d.activityCycle%4+1;d.behavior=({'sniff','circle','look','ahead'})[d.activityCycle];d.behaviorTime=2.5
  d.wanderX=math.max(30,math.min(s.gateOpen and 1242 or 602,p.x+math.cos(d.lifeClock)*42));d.wanderY=math.max(106,math.min(308,p.y+math.sin(d.lifeClock)*28))
 end
 if d.behavior=='sniff' then
  if distance(d,{x=d.wanderX,y=d.wanderY})>8 then D.move(d,{x=d.wanderX,y=d.wanderY},55,dt) else d.moving=false end
 elseif d.behavior=='circle' then D.move(d,{x=p.x+math.cos(d.lifeClock*2)*29,y=p.y+math.sin(d.lifeClock*2)*17},75,dt)
 elseif d.behavior=='look' then d.moving=false;local dx,dy=p.x-d.x,p.y-d.y;d.facingX=dx<0 and -1 or 1;d.facingY=dy/math.max(1,gap)
 else D.move(d,{x=math.max(25,math.min(s.gateOpen and 1242 or 602,p.x+p.facingX*45)),y=math.max(105,math.min(310,p.y+p.facingY*35))},100,dt) end
end
function C.onKill(s,e,D)
 local d=s.dog
 if e.kind~='boss' and distance(d,e)<150 and s.time>(d.nextCheer or 0) then
  d.nextCheer=s.time+5;d.behavior='happy';d.behaviorTime=.75;D.bark(d,s.audio,e)
 end
end
return C
