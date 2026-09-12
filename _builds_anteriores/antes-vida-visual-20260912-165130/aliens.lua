local A={};local g=love.graphics
local ink={.045,.07,.08};local skin={.81,.58,.35};local cream={.94,.91,.77}
local function r(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function shadow(x,y,w) g.setColor(.018,.04,.04,.4);g.ellipse('fill',x,y,w,4) end

function A.enemy(e,t)
 local boss=e.kind=='boss';local scale=boss and 2.3 or e.kind=='brute' and 1.5 or 1
 shadow(e.x,e.y+5,11*scale);g.push();g.translate(math.floor(e.x),math.floor(e.y));g.scale(scale)
 local direction=(e.facingX or 1)<0 and -1 or 1;g.scale(direction,1)
 local wind=e.wind or 0;local back=(e.facingY or 0)<-.6
 local roaring=(e.roar or 0)>0
 if roaring then back=false;g.translate(0,(e.roarClock or 0)<.45 and -math.sin((e.roarClock or 0)/.45*math.pi)*3 or -2) end
 local running=e.moving and math.sin(t*(e.carrying and 21 or 13))*2 or 0
 local crouch=(e.kind=='looter' or e.kind=='thief') and 3 or 0
 local recoil=(e.flash or 0)>0 and 3 or 0
 local skinC=e.kind=='gunner' and {.59,.46,.75} or e.kind=='looter' and {.64,.70,.35} or {.45,.68,.62}
 if (e.flash or 0)>0 then skinC=cream elseif e.defeated then skinC={.22,.30,.28} end
 r(-6,-2,4,8+running,{.14,.25,.25});r(3,-2,4,8-running,{.14,.25,.25})
 local impact=math.max(0,(e.impact or 0)/.32)
 g.translate(0,crouch)
 g.rotate((e.impactSide or 1)*direction*impact*(boss and .08 or .32))
 g.scale(1,1-impact*(boss and .03 or .13))
 r(-7,-14,14,14,skinC);r(-10,-25,20,14,skinC);r(-6,-28,12,4,skinC)
 if not back then r(-7,-23,5,7,ink);r(3,-23,5,7,ink);r(-2,-15,4,1,ink) else r(-6,-25,12,4,{.34,.51,.49}) end
 local arm=(wind>0 or roaring or e.opening) and -12 or 0
 if roaring and (e.roarClock or 0)>.45 then
  r(-3,-20,6,7,{.045,.025,.06});r(-2,-20,4,1,cream)
  g.setColor(.66,.49,.83,.5);g.arc('line','open',0,-25,16,-2.5,-.65)
 end
 if boss then
  for _,sx in ipairs({-1,1}) do
   g.setColor(skinC);g.setLineWidth(4);g.line(sx*7,-12,sx*11,-8+arm*.5,sx*11,arm);g.setLineWidth(1)
   r(sx*7-3,-15,6,5,{.30,.26,.43});r(sx*11-2,arm-2,4,4,skinC)
  end
 else r(-11,-12+arm,4,12,skinC);r(8,-12+arm,4,12,skinC) end
 if e.kind=='brute' then r(-11,-13,22,7,{.30,.36,.35});r(8,-14+arm,7,7,{.55,.58,.43}) end
 if e.kind=='thief' then r(-7,-4,14,4,{.60,.45,.26});r(10,-15,4,6,{.6,1,.73}) end
 if e.kind=='looter' then
  r(-8,-11,16,4,{.43,.39,.21})
  if e.carrying then g.setColor(.67,.50,.26);g.ellipse('fill',11,-6,8,11);r(7,-19,8,3,{.33,.27,.17}) end
 end
 if e.kind=='gunner' then r(8,-9,13,5,{.28,.20,.39});r(19,-9,3,4,wind>0 and {1,.78,.4} or {.56,1,.74}) end
 if boss then r(-9,-13,18,9,{.30,.26,.43});r(-3,-12,6,5,e.defeated and {.17,.23,.20} or {.58,1,.74});r(-10,-29,20,3,{.51,.39,.61}) end
 g.pop()
 if e.hp<e.maxHp and not boss then r(e.x-11,e.y+10,22,3,{.12,.19,.18});r(e.x-10,e.y+11,20*math.max(0,e.hp/e.maxHp),1,{.55,.9,.61}) end
end

return A
