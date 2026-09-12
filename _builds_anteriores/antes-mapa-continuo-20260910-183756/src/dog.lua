local Companion=require('src.companion')
local D={}
function D.new(x,y) return {x=x,y=y,facingX=1,facingY=0,moving=false} end
function D.move(d,target,speed,dt)
 local dx,dy=target.x-d.x,target.y-d.y;local n=math.sqrt(dx*dx+dy*dy)
 d.moving=n>2
 if n>2 then
  if math.abs(dx)>2 then d.facingX=dx<0 and -1 or 1 end
  d.facingY=dy/n
  local step=math.min(n,speed*dt);d.x=d.x+dx/n*step;d.y=d.y+dy/n*step
 end
end
function D.bark(d,a,target)
 d.barkTimer=.8;d.barkRepeat=.18;d.barkCount=(d.barkCount or 0)+1
 if target then local dx,dy=target.x-d.x,target.y-d.y;local n=math.max(1,math.sqrt(dx*dx+dy*dy));d.facingX=dx<0 and -1 or 1;d.facingY=dy/n end
 a.play('bark')
end
function D.update(d,dt,a)
 d.barkTimer=math.max(0,(d.barkTimer or 0)-dt)
 if (d.barkRepeat or 0)>0 then d.barkRepeat=d.barkRepeat-dt;if d.barkRepeat<=0 then a.play('bark') end end
end
function D.follow(d,p,dt,s)
 if s then Companion.update(d,p,dt,s,D);return end
 if (d.barkTimer or 0)>0 then d.moving=false;return end
 local dx,dy=p.x-d.x,p.y-d.y
 if dx*dx+dy*dy>32*32 then D.move(d,{x=p.x-p.facingX*20,y=p.y-p.facingY*20},125,dt) else d.moving=false end
end
return D
