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
function D.follow(d,p,dt)
 local dx,dy=p.x-d.x,p.y-d.y
 if dx*dx+dy*dy>32*32 then D.move(d,{x=p.x-p.facingX*20,y=p.y-p.facingY*20},125,dt) else d.moving=false end
end
return D
