local B={};local g=love.graphics
local function rect(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local dark={.10,.17,.18};local skin={.43,.65,.56};local light={.61,.79,.64}
local plate={.29,.25,.39};local edge={.51,.42,.59};local glow={.57,.96,.68}
function B.draw(e,t)
 local dead=e.defeated;local roar=(e.roar or 0)>0;local wind=e.wind or 0
 local charge=(e.charge or 0)>0 or wind>0 and e.attackKind=='charge'
 local pulse=wind>0 and not charge
 local face=(e.facingX or 1)<0 and -1 or 1
 local back=(e.facingY or 0)<-.6 and not roar
 local step=e.moving and math.sin(t*9)*2 or 0
 local breath=dead and 0 or math.sin(t*2.8)*.55
 local lift=roar and math.max(0,math.sin(math.min(1,(e.roarClock or 0)/.45)*math.pi))*4 or 0
 g.push('all');g.translate(math.floor(e.x),math.floor(e.y));g.scale(2.3)
 g.setColor(.018,.04,.04,.4);g.ellipse('fill',0,5,13,4)
 g.scale(face,1)
 -- Weighted feet remain planted while the chest breathes and the arms articulate.
 for i=-1,1,2 do
  local foot=i*6;local dy=i*step-(i==1 and lift or 0)
  rect(foot-3,-3,6,9+dy,dark);rect(foot-4,4+dy,9,4,plate)
  rect(foot-3,4+dy,7,1,edge);rect(foot-3,7+dy,8,1,{.20,.18,.24})
  rect(foot-2,-1,4,3,edge)
 end
 local impact=math.min(1,(e.impact or 0)/.32)
 g.translate(0,breath+(charge and 2 or 0));g.rotate((charge and .12 or 0)+(e.impactSide or 1)*face*impact*.10)
 local flash=(e.flash or 0)>0;local flesh=flash and light or dead and {.23,.31,.27} or skin
 -- Upper and lower arm share an explicit shoulder and elbow; no floating limbs.
 local function arm(side)
  local sx,sy=side*8,-16
  local ex,ey=side*12,-9
  local hx,hy=side*12,-1
  if roar then ex=side*15;ey=-20;hx=side*16;hy=-29
  elseif pulse then ex=side*14;ey=-17;hx=side*11;hy=-24
  elseif charge then ex=side*10;ey=-12;hx=side*6;hy=-9
  else hy=hy+side*step*.5 end
  g.setLineWidth(6);g.setColor(dark);g.line(sx,sy,ex,ey,hx,hy)
  g.setLineWidth(4);g.setColor(flesh);g.line(sx,sy,ex,ey,hx,hy);g.setLineWidth(1)
  rect(sx-4,sy-3,8,6,plate);rect(sx-3,sy-3,6,1,edge)
  rect(ex-2,ey-1,4,3,edge);rect(hx-3,hy-2,6,5,flesh)
  for k=0,2 do rect(hx-2+k*2,hy+2,1,2,{.76,.77,.57}) end
 end
 arm(-1)
 rect(-8,-19,16,20,flesh);rect(-7,-18,3,15,light);rect(5,-17,3,16,{.28,.47,.40})
 rect(-9,-14,18,12,plate);rect(-8,-14,16,2,edge)
 for i=1,3 do rect(-7,-11+i*3,14,1,{.19,.18,.28}) end
 if back then rect(-2,-18,4,16,edge)
 else
  rect(-4,-12,8,8,dark);rect(-3,-11,6,6,dead and dark or glow)
  if not dead then rect(-1,-10,2,3,{.80,1,.78}) end
  if e.hp<e.maxHp*.5 then g.setColor(dark);g.line(3,-14,1,-8,5,-4) end
 end
 rect(-8,-2,16,3,dark);rect(-2,-2,4,3,edge)
 local headY=roar and -3 or charge and 2 or 0
 g.push();g.translate(charge and 2 or 0,headY)
 rect(-5,-23,10,6,flesh);rect(-10,-32,20,13,flesh);rect(-7,-35,14,4,flesh)
 rect(-8,-32,4,10,light);rect(7,-30,3,10,{.28,.47,.40})
 rect(-10,-35,20,3,plate);rect(-9,-36,18,1,edge)
 rect(-8,-39,3,4,edge);rect(5,-38,3,3,edge)
 if back then rect(-6,-30,12,2,{.28,.47,.40})
 else
  rect(-7,-30,5,6,dark);rect(3,-30,5,6,dark)
  if not dead then rect(-6,-28,3,1,glow);rect(4,-28,3,1,glow) end
  rect(-3,-22,6,roar and 6 or 2,dark)
  if roar then rect(-2,-22,4,1,{.84,.81,.61});rect(-1,-18,3,1,{.39,.22,.41}) end
 end
 g.pop();arm(1)
 if roar and (e.roarClock or 0)>.45 and not dead then
  g.setColor(.64,.48,.78,.35);g.arc('line','open',0,-27,21+math.sin(t*19)*2,-2.5,-.65)
 end
 g.pop()
end
return B
