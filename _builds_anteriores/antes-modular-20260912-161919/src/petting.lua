local P={}
local function smooth(t) t=math.max(0,math.min(1,t));return t*t*(3-2*t) end
function P.start(s)
 local p,d=s.player,s.dog
 if p.pet or p.attackTimer>0 or p.dashTimer>0 or d.hidden then return false end
 p.pet={t=0,side=d.x<p.x and -1 or 1};p.queued=nil;p.moving=false
 d.stick=nil;d.hasStick=false;d.hop=0;return true
end
function P.cancel(s)
 s.player.pet=nil;s.player.petBend=0;s.dog.petLift=0;s.dog.petSquint=false
 if s.dog.behavior=='petted' then s.dog.behavior='look';s.dog.behaviorTime=.8 end
end
function P.update(s,dt,input)
 local p,d=s.player,s.dog;local a=p.pet
 if not a then return false end
 if input.x~=0 or input.y~=0 then P.cancel(s);return false end
 a.t=a.t+dt;local t=a.t
 p.facingX=a.side;p.facingY=.2;p.petBend=6*smooth(t/.6)*(1-smooth((t-2.5)/.5))
 d.behavior='petted';d.moving=false;d.facingX=-a.side;d.facingY=0;d.petSquint=t>.6 and t<2.6
 local targetX=p.x+a.side*22;local targetY=math.min(307,p.y+7)
 local dx,dy=targetX-d.x,targetY-d.y;local n=math.sqrt(dx*dx+dy*dy)
 if n>1 then local step=math.min(n,65*dt);d.x=d.x+dx/n*step;d.y=d.y+dy/n*step;d.moving=true end
 d.petLift=t>.6 and t<2.5 and 2+math.sin(t*9)*.4 or 0
 if t>3 then P.cancel(s);d.behavior='happy';d.behaviorTime=1.1 end
 return true
end
function P.draw(s,Actors)
 local p=s.player;local a=p.pet;if not a then return end
 local g=love.graphics;local hx,hy=Actors.dogHead(s.dog,s.time)
 local reach=smooth(a.t/.6)*(1-smooth((a.t-2.5)/.5))
 local sx=p.x+a.side*8;local sy=p.y-15+(p.petBend or 0)
 local tx=sx+(hx-sx)*reach;local ty=sy+(hy-3-sy)*reach
 if a.t>.6 and a.t<2.5 then tx=tx+math.sin(a.t*19)*2 end
 g.setColor(.45,.28,.17);g.setLineWidth(5);g.line(sx,sy,sx+a.side*6,sy+5,tx,ty)
 g.setColor(.84,.6,.37);g.setLineWidth(3);g.line(sx,sy,sx+a.side*6,sy+5,tx,ty);g.rectangle('fill',math.floor(tx-3),math.floor(ty-1),6,3)
 g.setColor(.94,.71,.46);g.rectangle('fill',math.floor(tx-2),math.floor(ty-2),4,1);g.setLineWidth(1)
end
return P
