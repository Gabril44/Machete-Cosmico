local Gore=require('src.gore')
local Tilemap=require('src.tilemap')
local W={};local g=love.graphics
local function rect(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function new(kind,x,y) return {kind=kind,x=x,y=y,hp=kind=='crate' and 2 or kind=='hay' and 3 or 1,radius=kind=='corn' and 5 or 12,solid=kind=='crate' or kind=='hay'} end
function W.setup(s,region)
 s.region='farm';s.worldWidth=1280;s.cameraX=0;s.props={};s.tilemap=Tilemap.new();s.fieldStarted=false
 for _,v in ipairs({{'crate',386,192},{'crate',409,192},{'hay',93,194},{'sack',548,269},{'sack',571,274},{'crate',805,190},{'crate',828,190},{'hay',1125,272},{'hay',1160,272},{'sack',1130,128},{'sack',1159,134}}) do s.props[#s.props+1]=new(v[1],v[2],v[3]) end
 for row=0,2 do for col=0,8 do
  s.props[#s.props+1]=new('corn',447+col*13,300+row*4)
  s.props[#s.props+1]=new('corn',689+col*14,124+row*15)
 end end
end
function W.enter(s)
 if s.fieldStarted then return end
 s.fieldStarted=true;s.region='field';s.gateOpen=true;s.farmCows=s.cows
 s.stage='fieldintro';s.stageTime=0
 s:say('Moro, junto a mí. Estos vinieron por el galpón.');s.audio.play('wave')
end
function W.camera(s,dt)
 local target=math.max(0,math.min((s.worldWidth or 1280)-640,s.player.x-320))
 s.cameraX=(s.cameraX or 0)+(target-(s.cameraX or 0))*(1-math.exp(-7*dt))
end
function W.limit(s,a)
 a.x=math.max(22,math.min((s.worldWidth or 1280)-22,a.x));a.y=math.max(96,math.min(316,a.y))
 if not s.gateOpen then a.x=math.min(612,a.x)
 elseif a.y<201 or a.y>263 then
  if a.x>615 and a.x<647 then a.x=a.x<631 and 615 or 647 end
 end
end
function W.breakProp(s,o,force)
 if o.broken then return end
 o.hp=o.hp-force
 if o.hp<=0 then
  o.broken=true;s:burst(o.x,o.y,o.kind=='corn' and 7 or 19,o.kind=='corn' and {.43,.62,.24} or {.76,.53,.28})
  if o.kind=='crate' then s.audio.play('hit');s.drops[#s.drops+1]={x=o.x,y=o.y,t=18} end
 end
end
function W.resolve(s,a,enemy)
 for _,o in ipairs(s.props or {}) do
  if not o.broken and o.solid then
   local dx,dy=a.x-o.x,a.y-o.y;local d=math.sqrt(dx*dx+dy*dy);local radius=o.radius+(enemy and (a.radius or 9) or 8)
   if d<radius then
    local speed=math.sqrt((a.kx or 0)^2+(a.ky or 0)^2)
    if enemy and speed>80 then
     W.breakProp(s,o,3);a.hp=a.hp-2;Gore.hit(s,a,s.player,2);a.stun=.45;a.kx=0;a.ky=0;s.shake=4;s:burst(a.x,a.y,16);s.audio.play('hit');s.score=s.score+50
    else
     if d<.01 then dx,dy,d=1,0,1 end
     a.x=o.x+dx/d*radius;a.y=o.y+dy/d*radius
     if enemy then a.y=a.y+(dy<=0 and -.7 or .7) end
    end
   end
  end
 end
 W.limit(s,a)
end
function W.update(s,dt)
 s.transition=0
 local p=s.player
 if p:isAttackActive() then for _,o in ipairs(s.props or {}) do if not o.broken and o.lastSwing~=p.swing and p:inArc(o) then o.lastSwing=p.swing;W.breakProp(s,o,p.damage) end end end
 W.resolve(s,p,false)
 W.limit(s,s.dog)
 if s.stage=='travel' and p.x>885 then W.enter(s) end
 W.camera(s,dt)
 if s.stage=='fieldintro' and s.stageTime>3 then s:beginWave(3) end
end
function W.loot(s,e,dt)
 if e.carrying then
  local edge=(e.spawnBase or 0)>0 and 1265 or 15;local dx=edge-e.x;e.x=e.x+math.min(math.abs(dx),67*dt)*(dx<0 and -1 or 1);e.y=e.y+(221-e.y)*dt
  if math.abs(e.x-edge)<12 then e.escaped=true;e.hp=0;s:say('Se llevó las papas. LAS PAPAS.');end
  return
 end
 local target;local best=math.huge
 for _,o in ipairs(s.props or {}) do if o.kind=='sack' and math.floor(o.x/640)==math.floor((e.spawnBase or 0)/640) and not o.broken and not o.stolen then local d=(e.x-o.x)^2+(e.y-o.y)^2;if d<best then best=d;target=o end end end
 if target then
  local d=math.sqrt(best)
  if d>17 then e.x=e.x+(target.x-e.x)/d*48*dt;e.y=e.y+(target.y-e.y)/d*48*dt
  else e.steal=(e.steal or 0)+dt;if e.steal>.7 then target.stolen=true;e.carrying=true;e.lootTarget=target end end
 else e.kind='raider' end
end
function W.field(s,V)
 g.push();g.translate(640,0)
 rect(364,61,170,43,{.24,.23,.23});rect(372,68,155,35,{.34,.29,.24})
 for x=375,527,9 do rect(x,67,1,36,{.21,.22,.21}) end
 g.setColor(.22,.24,.28);g.polygon('fill',351,65,371,34,519,34,547,65)
 rect(408,73,47,31,{.055,.09,.095});rect(472,77,18,13,{.53,.65,.56})
 g.setFont(V.small);g.setColor(.78,.75,.59);g.print('GALPÓN / LOTE 02',390,51)
 g.pop()
end
function W.drawProps(s)
 for _,o in ipairs(s.props or {}) do
  local x,y=o.x,o.y
  if o.stolen then rect(x-7,y,14,2,{.25,.23,.16})
  elseif o.broken then
   for i=1,4 do rect(x-10+i*4,y+(i%2)*3,5,2,o.kind=='corn' and {.30,.41,.19} or {.41,.32,.20}) end
  elseif o.kind=='corn' then
   local bend=math.sin(s.time*1.5+x)*2
   g.setColor(.35,.49,.23);g.line(x,y,x+bend,y-16);g.line(x+bend,y-11,x-5,y-16);g.line(x+bend,y-7,x+7,y-12);rect(x+bend,y-13,3,7,{.68,.61,.26})
  elseif o.kind=='crate' then
   rect(x-13,y-4,26,9,{.055,.09,.07});rect(x-11,y-21,22,23,{.48,.31,.17});rect(x-9,y-19,18,3,{.71,.48,.25});rect(x-9,y-3,18,3,{.71,.48,.25});g.setColor(.66,.45,.23);g.setLineWidth(2);g.line(x-9,y-15,x+9,y-4);g.setLineWidth(1)
  elseif o.kind=='hay' then
   rect(x-14,y-14,28,17,{.62,.51,.26});rect(x-8,y-14,2,17,{.32,.29,.19});rect(x+8,y-14,2,17,{.32,.29,.19})
  else
   g.setColor(.62,.48,.27);g.ellipse('fill',x,y-7,10,12);rect(x-5,y-20,10,4,{.37,.28,.17});rect(x-4,y-11,8,6,{.44,.35,.20})
  end
 end
 -- The same physical fence exists before and after unlocking.
 for y=102,316,17 do if y<200 or y>260 then rect(628,y,4,16,{.43,.40,.27});rect(622,y+5,16,2,{.32,.31,.22}) end end
 rect(623,195,8,14,{.56,.47,.29});rect(623,257,8,14,{.56,.47,.29})
 if s.gateOpen then
  rect(631,198,33,3,{.51,.42,.25});rect(652,193,3,14,{.51,.42,.25})
 else
  rect(626,208,4,47,{.47,.39,.25});rect(620,212,16,3,{.63,.50,.29});rect(620,245,16,3,{.63,.50,.29})
 end
 g.setColor(.67,.76,.54);g.print(s.gateOpen and 'GALPÓN >' or 'PORTÓN CERRADO',535,190)
end
function W.ambience(s)
 local g=love.graphics
 -- Low intensity pools of window light and drifting fireflies.
 local x,y=1120,92
 for radius=40,12,-7 do g.setColor(.85,.65,.3,.012);g.ellipse('fill',x,y+10,radius,radius*.44) end
 for i=1,20 do
  local px=30+(i*73)%1220+math.sin(s.time*.35+i)*9;local py=116+(i*39)%175+math.cos(s.time*.6+i)*4
  local a=math.max(0,math.sin(s.time*1.2+i))*.4
  g.setColor(.67,.83,.40,a*.15);g.circle('fill',px,py,4);g.setColor(.78,.9,.49,a);g.rectangle('fill',px,py,1,1)
 end
end
return W
