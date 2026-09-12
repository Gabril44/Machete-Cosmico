local A={};local g=love.graphics
local ink={.045,.07,.08};local skin={.81,.58,.35};local cream={.94,.91,.77}
local function r(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function shadow(x,y,w) g.setColor(.018,.04,.04,.4);g.ellipse('fill',x,y,w,4) end
function A.player(p,t)
 if p.hidden then return end
 local x,y=math.floor(p.x),math.floor(p.y);shadow(x,y+5,11)
 if p.inv>0 and math.floor(t*20)%2==0 then return end
 local active=p.attackTimer>0;local f=p:attackPhase();local back=p.facingY<-.55;local side=p.facingX<0 and -1 or 1
 local bob=p.moving and math.sin(p.stride)*1 or 0;local lean=active and math.sin(f*math.pi)*(p.heavy and -3 or 3)*side or 0
 local step=p.moving and math.sin(p.stride)*3 or active and 2 or 0
 if p.berserk then g.setColor(1,.4,.15,.15);g.circle('fill',x,y-9,24+math.sin(t*14)*2) end
 if p.dashTimer>0 then for i=1,3 do r(x-p.facingX*i*8-5,y-p.facingY*i*8-20,10,21,{.39,.58,.53,.20}) end end
 r(x-7,y,5,7+step,{.14,.19,.20});r(x+2,y,5,7-step,{.14,.19,.20});r(x-8,y+5+step,7,3,ink);r(x+2,y+5-step,7,3,ink)
 x=x+lean;y=y+bob
 r(x-8,y-16,16,18,p.berserk and {.71,.30,.19} or {.36,.50,.47});r(x-6,y-15,3,16,{.47,.61,.54});r(x-8,y-3,16,3,{.25,.21,.15})
 if back then r(x-5,y-23,10,8,{.35,.25,.17}) else r(x-5,y-24,10,12,skin);r(x-5,y-17,10,5,{.31,.23,.16});r(x+side*3-1,y-21,2,2,ink) end
 r(x-13,y-26,26,5,{.68,.51,.25});r(x-7,y-33,14,9,{.61,.43,.22});r(x-7,y-27,14,2,{.26,.22,.16});r(x-6,y-33,10,2,{.77,.59,.30})
 local angle=p:bladeAngle();local handX=x+math.cos(angle)*12;local handY=y-10+math.sin(angle)*7
 r(x-side*11,y-14+(active and 2 or step*.4),4,10,skin)
 g.setColor(skin);g.setLineWidth(4);g.line(x+side*7,y-12,handX,handY);g.setLineWidth(1)
 if p:isAttackActive() then
  local reach=p.reach;local a=angle;local tail=p.combo==2 and .85 or -.85
  g.setColor(p.berserk and 1 or .92,p.berserk and .45 or .98,.65,.19);g.arc('fill','pie',p.x,p.y-6,reach,math.min(a,a+tail),math.max(a,a+tail),22)
  g.setColor(1,.94,.7,.9);g.setLineWidth(p.heavy and 3 or 2);g.arc('line','open',p.x,p.y-6,reach,math.min(a,a+tail),math.max(a,a+tail),22);g.setLineWidth(1)
 end
 g.push();g.translate(handX,handY);g.rotate(angle);r(0,-2,7,4,{.37,.25,.16});r(7,-3,22,5,{.68,.80,.78});r(10,-3,18,1,{1,1,.84});g.pop()
end
function A.dog(d,t)
 if d.hidden then return end
 shadow(d.x,d.y+4,11);g.push();g.translate(math.floor(d.x),math.floor(d.y-(d.lift or 0)-(d.hop or 0)));g.scale(d.facingX or 1,1)
 local vertical=math.abs(d.facingY or 0)>.7;local sniff=d.behavior=='sniff' and not d.moving
 local legs=d.moving and math.sin(t*20)*2 or 0
 r(-8,-8,16,9,{.59,.34,.16});r(-7,-1,3,6+legs,{.36,.23,.14});r(4,-1,3,6-legs,{.36,.23,.14});r(-5,-8,8,3,{.72,.44,.20})
 local wag=math.sin(t*(d.behavior=='happy' and 26 or 12))*3;r(-13,-9+wag,7,3,{.65,.39,.17})
 local hx=vertical and -4 or 5;local hy=sniff and -7 or -15
 r(hx,hy,9,10,{.76,.48,.25});r(hx-2,hy-1,3,8,{.29,.19,.13});r(hx+6,hy-1,3,6,{.35,.23,.14})
 if not vertical then r(11,hy+5,7,4,{.85,.65,.37});r(10,hy+2,2,2,ink);r(16,hy+4,2,2,ink)
 elseif (d.facingY or 0)>0 then r(-2,hy+3,2,2,ink);r(3,hy+3,2,2,ink);r(-1,hy+7,5,3,{.9,.7,.43}) end
 r(hx,hy+9,8,2,{.83,.25,.18})
 if d.hasStick then r(8,hy+8,19,2,{.69,.51,.28}) end
 if (d.barkTimer or 0)>0 then g.setColor(cream);g.setLineWidth(1);g.arc('line','open',16,hy+6,7,-.7,.7);g.arc('line','open',16,hy+6,11,-.7,.7) end
 if d.behavior=='happy' then r(-2,-26,3,3,{1,.52,.54});r(2,-26,3,3,{1,.52,.54});r(0,-24,3,3,{1,.52,.54}) end
 g.pop()
 if d.stick and not d.hasStick then r(d.stick.x-6,d.stick.y,12,2,{.7,.51,.28}) end
end
function A.enemy(e,t)
 local boss=e.kind=='boss';local scale=boss and 2.3 or e.kind=='brute' and 1.5 or 1
 shadow(e.x,e.y+5,11*scale);g.push();g.translate(math.floor(e.x),math.floor(e.y));g.scale(scale)
 local direction=(e.facingX or 1)<0 and -1 or 1;g.scale(direction,1)
 local wind=e.wind or 0;local back=(e.facingY or 0)<-.6
 local running=e.moving and math.sin(t*(e.carrying and 21 or 13))*2 or 0
 local crouch=(e.kind=='looter' or e.kind=='thief') and 3 or 0
 local recoil=(e.flash or 0)>0 and 3 or 0
 local skinC=e.kind=='gunner' and {.59,.46,.75} or e.kind=='looter' and {.64,.70,.35} or {.45,.68,.62}
 if (e.flash or 0)>0 then skinC=cream elseif e.defeated then skinC={.22,.30,.28} end
 r(-6,-2,4,8+running,{.14,.25,.25});r(3,-2,4,8-running,{.14,.25,.25})
 g.translate(-recoil,crouch)
 r(-7,-14,14,14,skinC);r(-10,-25,20,14,skinC);r(-6,-28,12,4,skinC)
 if not back then r(-7,-23,5,7,ink);r(3,-23,5,7,ink);r(-2,-15,4,1,ink) else r(-6,-25,12,4,{.34,.51,.49}) end
 local arm=wind>0 and -12 or 0
 r(-11,-12+arm,4,12,skinC);r(8,-12+arm,4,12,skinC)
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
