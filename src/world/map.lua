local PlayerLines=require('src.entities.player.dialogue')
local Gore=require('src.effects.gore')
local Tilemap=require('src.world.tilemap')
local W={};local g=love.graphics
local function rect(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local Props=require('src.world.props')
local new=Props.new
function W.setup(s,region)
 s.region='farm';s.worldWidth=1280;s.cameraX=0;s.props={};s.tilemap=Tilemap.new();s.fieldStarted=false;s.gateRunner=nil;s.gateProgress=0
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
 s:say(PlayerLines.field);s.audio.play('wave')
end
function W.camera(s,dt)
 local target=math.max(0,math.min((s.worldWidth or 1280)-640,s.player.x-320))
 if s.stage=='gateopening' then target=308 end
 s.cameraX=(s.cameraX or 0)+(target-(s.cameraX or 0))*(1-math.exp(-7*dt))
end
function W.limit(s,a)
 a.x=math.max(22,math.min((s.worldWidth or 1280)-22,a.x));a.y=math.max(96,math.min(316,a.y))
 if not s.gateOpen then a.x=math.min(612,a.x)
 elseif a.y<201 or a.y>263 then
  if a.x>615 and a.x<647 then a.x=a.x<631 and 615 or 647 end
 end
end
W.breakProp=Props.breakProp
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
 for _,o in ipairs(s.props or {}) do o.hitTime=math.max(0,(o.hitTime or 0)-dt) end
 if p:isAttackActive() then for _,o in ipairs(s.props or {}) do if not o.broken and o.lastSwing~=p.swing and p:inArc(o) then o.lastSwing=p.swing;W.breakProp(s,o,o.kind=='crate' and 1 or p.damage) end end end
 W.resolve(s,p,false)
 W.limit(s,s.dog)
 if s.stage=='travel' and p.x>885 then W.enter(s) end
 W.camera(s,dt)
 if s.stage=='fieldintro' and s.stageTime>3 then s:beginWave(3) end
end
function W.loot(s,e,dt) return require('src.entities.aliens.ai.looter').update(s,e,s.player,dt) end
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
 Props.drawProps(s)
 -- The same physical fence exists before and after unlocking.
 for y=102,316,17 do if y<200 or y>260 then rect(628,y,4,16,{.43,.40,.27});rect(622,y+5,16,2,{.32,.31,.22}) end end
 rect(623,195,8,14,{.56,.47,.29});rect(623,257,8,14,{.56,.47,.29})
 if not s.gateOpen and (s.gateProgress or 0)>0 then
  local f=s.gateProgress;g.setColor(.53,.44,.26);g.setLineWidth(4);g.line(628,208,628+31*f,255-47*f);g.setLineWidth(1)
 elseif s.gateOpen then
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
