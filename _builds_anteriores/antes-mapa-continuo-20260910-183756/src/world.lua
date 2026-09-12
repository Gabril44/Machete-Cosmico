local W={};local g=love.graphics
local function rect(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function new(kind,x,y) return {kind=kind,x=x,y=y,hp=kind=='crate' and 2 or kind=='hay' and 3 or 1,radius=kind=='corn' and 5 or 12,solid=kind=='crate' or kind=='hay'} end
function W.setup(s,region)
 s.region=region;s.props={}
 local placements=region=='field' and {{'crate',165,190},{'crate',188,190},{'hay',485,272},{'hay',520,272},{'sack',490,128},{'sack',519,134}} or {{'crate',386,192},{'crate',409,192},{'hay',93,194},{'sack',548,269},{'sack',571,274}}
 for _,v in ipairs(placements) do s.props[#s.props+1]=new(v[1],v[2],v[3]) end
 for row=0,2 do for col=0,8 do s.props[#s.props+1]=new('corn',region=='field' and 49+col*14 or 447+col*13,region=='field' and 124+row*15 or 300+row*4) end end
end
function W.enter(s)
 s.farmCows=s.cows;s.cows={};s.weeds={};s.enemies={};s.shots={};s.marks={};s.drops={};W.setup(s,'field')
 s.dog.stick=nil;s.dog.hasStick=false;s.dog.behaviorTime=0;s.player.x=42;s.player.y=225;s.dog.x=25;s.dog.y=237;s.dog.behavior='follow';s.stage='fieldintro';s.stageTime=0;s.transition=1;s.gateOpen=false
 s:say('Moro, junto a mí. Estos vinieron por el galpón.');s.audio.play('wave')
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
     W.breakProp(s,o,3);a.hp=a.hp-2;a.stun=.45;a.kx=0;a.ky=0;s.shake=4;s:burst(a.x,a.y,16);s.audio.play('hit');s.score=s.score+50
    else
     if d<.01 then dx,dy,d=1,0,1 end
     a.x=o.x+dx/d*radius;a.y=o.y+dy/d*radius
     if enemy then a.y=a.y+(dy<=0 and -.7 or .7) end
    end
   end
  end
 end
 a.x=math.max(22,math.min(618,a.x));a.y=math.max(96,math.min(316,a.y))
end
function W.update(s,dt)
 s.transition=math.max(0,(s.transition or 0)-dt)
 local p=s.player
 if p:isAttackActive() then for _,o in ipairs(s.props or {}) do if not o.broken and o.lastSwing~=p.swing and p:inArc(o) then o.lastSwing=p.swing;W.breakProp(s,o,p.damage) end end end
 W.resolve(s,p,false)
 if s.stage=='travel' and p.x>598 and p.y>194 and p.y<259 then W.enter(s) end
 if s.stage=='fieldintro' and s.stageTime>3 then s:beginWave(3) end
end
function W.loot(s,e,dt)
 if e.carrying then
  local dx=625-e.x;e.x=e.x+math.min(dx,67*dt);e.y=e.y+(221-e.y)*dt
  if e.x>615 then e.escaped=true;e.hp=0;s:say('Se llevó las papas. LAS PAPAS.');end
  return
 end
 local target;local best=math.huge
 for _,o in ipairs(s.props or {}) do if o.kind=='sack' and not o.broken and not o.stolen then local d=(e.x-o.x)^2+(e.y-o.y)^2;if d<best then best=d;target=o end end end
 if target then
  local d=math.sqrt(best)
  if d>17 then e.x=e.x+(target.x-e.x)/d*48*dt;e.y=e.y+(target.y-e.y)/d*48*dt
  else e.steal=(e.steal or 0)+dt;if e.steal>.7 then target.stolen=true;e.carrying=true;e.lootTarget=target end end
 else e.kind='raider' end
end
function W.field(s,V)
 rect(0,0,640,360,{.035,.065,.095});rect(0,97,640,232,{.13,.20,.155})
 for i=1,60 do rect((i*71)%640,(i*37)%91,1,1,{.40,.53,.55}) end
 g.setColor(.6,.7,.57);g.circle('fill',569,46,13)
 for i=0,18 do local x=i*38;g.setColor(.055,.105,.11);g.polygon('fill',x-25,99,x,48+(i%3)*8,x+27,99) end
 rect(0,210,640,37,{.28,.25,.18});rect(256,100,79,226,{.25,.24,.17})
 for i=1,600 do local x=(i*97)%640;local y=106+(i*71)%208;if not (x>255 and x<338) and not(y>207 and y<250) then rect(x,y,2,2,i%2==0 and {.22,.30,.18} or {.10,.17,.14}) end end
 rect(364,61,170,43,{.24,.23,.23});rect(372,68,155,35,{.34,.29,.24})
 for x=375,527,9 do rect(x,67,1,36,{.21,.22,.21}) end
 g.setColor(.22,.24,.28);g.polygon('fill',351,65,371,34,519,34,547,65)
 rect(408,73,47,31,{.055,.09,.095});rect(472,77,18,13,{.53,.65,.56})
 g.setFont(V.small);g.setColor(.78,.75,.59);g.print('GALPÓN / LOTE 02',390,51)
 for x=10,631,22 do rect(x,103,3,14,{.42,.40,.27});rect(x,311,3,14,{.42,.40,.27}) end
 rect(8,109,624,2,{.34,.34,.23});rect(8,318,624,2,{.34,.34,.23})
 for _,m in ipairs(s.marks) do g.setColor(.22,.33,.15);g.ellipse('fill',m.x,m.y,11,4) end
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
 if s.gateOpen then
  rect(611,195,29,67,{.28,.25,.18});g.setColor(.7,.84,.46);g.setFont(love.graphics.getFont());g.print('GALPÓN >',545,200)
  g.line(613,228,626,228,621,223);g.line(626,228,621,233)
 end
end
function W.ambience(s)
 local g=love.graphics
 -- Low intensity pools of window light and drifting fireflies.
 local x,y=s.region=='field' and 480 or 251,s.region=='field' and 92 or 88
 for radius=40,12,-7 do g.setColor(.85,.65,.3,.012);g.ellipse('fill',x,y+10,radius,radius*.44) end
 for i=1,10 do
  local px=30+(i*73)%580+math.sin(s.time*.35+i)*9;local py=116+(i*39)%175+math.cos(s.time*.6+i)*4
  local a=math.max(0,math.sin(s.time*1.2+i))*.4
  g.setColor(.67,.83,.40,a*.15);g.circle('fill',px,py,4);g.setColor(.78,.9,.49,a);g.rectangle('fill',px,py,1,1)
 end
end
return W
