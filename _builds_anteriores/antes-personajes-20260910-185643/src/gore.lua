local G={};local rng=love.math.newRandomGenerator(9173)
local blood={.39,.72,.17};local dark={.17,.29,.09}
local function cap(t,n) while #t>n do table.remove(t,1) end end
function G.reset(s) s.gore={drops={},splats={},organs={}} end
local function splat(s,x,y,size)
 local t=s.gore.splats;t[#t+1]={x=x,y=y,size=size,shape=rng:random(1,3)};cap(t,220)
end
function G.hit(s,e,p,power)
 if not s.gore then G.reset(s) end
 local dx,dy=e.x-p.x,e.y-p.y;local a=math.atan2(dy,dx)
 for i=1,6+power*4 do
  local angle=a+(rng:random()-.5)*1.8;local speed=rng:random(35,90)+power*15
  s.gore.drops[#s.gore.drops+1]={x=e.x,y=e.y,z=12,vx=math.cos(angle)*speed,vy=math.sin(angle)*speed*.55,vz=rng:random(25,65),size=rng:random(1,2)}
 end
 cap(s.gore.drops,180);splat(s,e.x,e.y,3+power)
end
function G.death(s,e,p)
 local power=e.kind=='boss' and 4 or p.heavy and 2 or 1
 G.hit(s,e,p,power);splat(s,e.x,e.y,7+power)
 for i=1,power+2 do
  local a=rng:random()*6.283;local speed=rng:random(30,65)+power*12
  s.gore.organs[#s.gore.organs+1]={x=e.x,y=e.y,z=13,vx=math.cos(a)*speed,vy=math.sin(a)*speed*.6,vz=rng:random(65,110),angle=a,spin=(rng:random()-.5)*12,kind=i%3,size=e.kind=='boss' and 1.35 or 1,bounces=0,settled=false}
 end
 cap(s.gore.organs,90)
end
function G.update(s,dt)
 if not s.gore then return end
 for i=#s.gore.drops,1,-1 do
  local d=s.gore.drops[i];d.x=d.x+d.vx*dt;d.y=d.y+d.vy*dt;d.z=d.z+d.vz*dt;d.vz=d.vz-260*dt
  if d.z<=0 then splat(s,math.max(8,math.min(1272,d.x)),math.max(99,math.min(315,d.y)),d.size+1);table.remove(s.gore.drops,i) end
 end
 for _,o in ipairs(s.gore.organs) do if not o.settled then
  o.x=math.max(8,math.min(1272,o.x+o.vx*dt));o.y=math.max(99,math.min(315,o.y+o.vy*dt));o.z=o.z+o.vz*dt;o.vz=o.vz-260*dt;o.angle=o.angle+o.spin*dt
  local drag=math.max(0,1-dt*1.7);o.vx=o.vx*drag;o.vy=o.vy*drag
  if o.z<=0 then
   o.z=0;splat(s,o.x,o.y,4);o.bounces=o.bounces+1
   if o.bounces>=2 then o.settled=true else o.vz=math.abs(o.vz)*.25;o.vx=o.vx*.45;o.vy=o.vy*.45 end
  end
 end end
end
local function organ(o)
 local g=love.graphics;g.push();g.translate(math.floor(o.x),math.floor(o.y-o.z));g.rotate(o.angle);g.scale(o.size)
 if o.kind==0 then
  g.setColor(.38,.16,.32);g.rectangle('fill',-4,-3,7,5);g.rectangle('fill',-2,-5,5,8)
  g.setColor(.70,.35,.54);g.rectangle('fill',-2,-3,3,2);g.setColor(blood);g.rectangle('fill',3,0,4,2)
 elseif o.kind==1 then
  g.setColor(.44,.31,.49);g.setLineWidth(3);g.line(-5,0,-3,-3,1,-2,2,2,5,1)
  g.setColor(.71,.47,.65);g.setLineWidth(1);g.line(-5,-1,-3,-3,1,-2,2,1,5,0)
 else
  g.setColor(.71,.81,.51);g.rectangle('fill',-3,-3,6,6);g.setColor(.12,.18,.12);g.rectangle('fill',0,-2,2,4)
  g.setColor(.48,.25,.43);g.rectangle('fill',-6,1,4,2)
 end
 g.setLineWidth(1);g.pop()
end
function G.ground(s)
 if not s.gore then return end
 local g=love.graphics
 for _,d in ipairs(s.gore.splats) do
  g.setColor(dark);g.ellipse('fill',d.x,d.y,d.size,d.size*.43)
  g.setColor(.29,.46,.12);g.rectangle('fill',d.x-d.size*.5,d.y-1,d.size,2)
  g.setColor(.34,.55,.13,.7);g.rectangle('fill',d.x+d.size+2,d.y+d.shape,2,1)
 end
 for _,o in ipairs(s.gore.organs) do
  g.setColor(.02,.035,.02,.3);g.ellipse('fill',o.x,o.y+2,5,2)
  if o.settled then organ(o) end
 end
end
function G.air(s)
 if not s.gore then return end
 local g=love.graphics
 for _,d in ipairs(s.gore.drops) do g.setColor(blood);g.rectangle('fill',d.x,d.y-d.z,d.size,d.size+1) end
 for _,o in ipairs(s.gore.organs) do if not o.settled then organ(o) end end
end
return G
