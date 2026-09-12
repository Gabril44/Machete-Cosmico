local Dog=require('src.dog')
local B={}
local function segmentDistance(px,py,ax,ay,bx,by)
 local dx,dy=bx-ax,by-ay;local n=dx*dx+dy*dy
 local t=n>0 and math.max(0,math.min(1,((px-ax)*dx+(py-ay)*dy)/n)) or 0
 return ((px-ax-t*dx)^2+(py-ay-t*dy)^2)^.5
end
function B.update(s,e,p,dt)
 if (e.roar or 0)>0 then
  e.roarClock=(e.roarClock or 0)+dt;e.roar=math.max(0,e.roar-dt)
  if e.roarClock>=.45 and not e.roarSound then
   e.roarSound=true;s.audio.play('roar',.9);s.shake=5;s:burst(e.x,e.y+4,22,{.43,.34,.23})
  end
  if e.roar==0 then e.cool=1;e.roarCooldown=12 end
  return
 end
 e.roarCooldown=(e.roarCooldown or 12)-dt
 if e.roarCooldown<=0 and (e.recover or 0)<=0 and (e.charge or 0)<=0 and e.wind<=0 then
  e.roar=1.6;e.roarClock=0;e.roarSound=false;return
 end
 if (e.recover or 0)>0 then e.recover=math.max(0,e.recover-dt);return end
 if (e.charge or 0)>0 then
  local x,y=e.x,e.y;local step=math.min(e.charge,dt);e.charge=math.max(0,e.charge-dt)
  e.x=math.max((e.spawnBase or 0)+22,math.min((e.spawnBase or 0)+618,e.x+e.dx*440*step));e.y=math.max(98,math.min(314,e.y+e.dy*440*step))
  if segmentDistance(p.x,p.y,x,y,e.x,e.y)<27 then s:hurt(23,e.x,e.y) end
  s:burst(e.x,e.y,2,{.95,.55,.2})
  if e.charge<=0 then e.recover=1.15;e.cool=1.4;s.shake=4;s.audio.play('hit');Dog.bark(s.dog,s.audio,e) end
  return
 end
 if e.wind>0 then
  e.wind=math.max(0,e.wind-dt)
  if e.wind==0 then
   if e.attackKind=='charge' then e.charge=.48;s.audio.play('bossRush',.85)
   else
    s.audio.play('bossPulse',.85)
    s.shake=7;s:burst(e.tx,e.ty,35,{.6,.4,1});if ((p.x-e.tx)^2+(p.y-e.ty)^2)^.5<65 then s:hurt(24,e.x,e.y) end
    for a=0,7 do local angle=a*math.pi/4;s.shots[#s.shots+1]={x=e.tx,y=e.ty,vx=math.cos(angle)*90,vy=math.sin(angle)*90,t=3} end
    e.cool=e.hp<40 and 1.3 or 2.2
   end
  end
 elseif e.cool<=0 then
  e.attackCount=(e.attackCount or 0)+1
  -- Two familiar pulses, then a committed, dodgeable shoulder charge.
  e.attackKind=e.attackCount%3==0 and 'charge' or 'pulse'
  e.wind=e.attackKind=='charge' and .85 or 1;e.windMax=e.wind;e.tx=p.x;e.ty=p.y
  s.audio.play(e.attackKind=='charge' and 'bossCharge' or 'bossGather',.65)
  if e.attackKind=='charge' then
   local dx,dy=p.x-e.x,p.y-e.y;local n=math.sqrt(dx*dx+dy*dy)
   e.dx=n>0 and dx/n or 1;e.dy=n>0 and dy/n or 0
   e.ex=math.max((e.spawnBase or 0)+22,math.min((e.spawnBase or 0)+618,e.x+e.dx*211));e.ey=math.max(98,math.min(314,e.y+e.dy*211))
  end
 else
  local dx,dy=p.x-e.x,p.y-e.y;local n=math.sqrt(dx*dx+dy*dy)
  if n>1 then e.x=e.x+dx/n*28*dt;e.y=e.y+dy/n*28*dt end
 end
end
function B.drawTelegraph(e,font)
 local g=love.graphics;g.setFont(font);g.setLineWidth(1)
 if e.wind>0 and e.attackKind=='charge' then
  local nx,ny=-e.dy*27,e.dx*27
  g.setColor(1,.53,.2,.19);g.polygon('fill',e.x+nx,e.y+ny,e.ex+nx,e.ey+ny,e.ex-nx,e.ey-ny,e.x-nx,e.y-ny)
  g.setColor(1,.65,.3);g.line(e.x+nx,e.y+ny,e.ex+nx,e.ey+ny);g.line(e.x-nx,e.y-ny,e.ex-nx,e.ey-ny)
  g.line(e.ex-e.dx*14-e.dy*10,e.ey-e.dy*14+e.dx*10,e.ex,e.ey,e.ex-e.dx*14+e.dy*10,e.ey-e.dy*14-e.dx*10)
  g.printf('EMBESTIDA · DASH AL COSTADO',(e.spawnBase or 0)+160,80,320,'center')
 elseif e.wind>0 then
  g.setColor(1,.51,.24,.18);g.circle('fill',e.tx,e.ty,65);g.setColor(1,.51,.24);g.circle('line',e.tx,e.ty,65);g.circle('line',e.tx,e.ty,65*(1-e.wind));g.print('SALÍ DEL CÍRCULO',e.tx-43,e.ty+36)
 end
end
return B
