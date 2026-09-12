local A={};local g=love.graphics
local ink={.045,.07,.08};local skin={.81,.58,.35};local cream={.94,.91,.77}
local function r(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function shadow(x,y,w) g.setColor(.018,.04,.04,.4);g.ellipse('fill',x,y,w,4) end
function A.player(p,t)
 if p.hidden then return end
 local x,y=math.floor(p.x),math.floor(p.y);shadow(x,y+5,12)
 if (p.dodgeFlash or 0)>0 then
  g.setColor(.83,.94,.73,p.dodgeFlash/.22);g.setLineWidth(1);g.ellipse('line',x,y-10,15+(1-p.dodgeFlash/.22)*6,21)
 end
 if p.inv>0 and math.floor(t*20)%2==0 then return end
 local active=p.attackTimer>0;local f=p:attackPhase();local side=p.facingX<0 and -1 or 1
 local view=p.weaponPose=='reach' and 'side' or p.facingY<-.6 and 'back' or p.facingY>.6 and 'front' or 'side'
 local profile=view=='side'
 local furious=p.weaponPose=='furious'
 local step=p.moving and math.sin(p.weaponPose and t*13 or p.stride or t*13)*3 or active and 2 or 0
 local lean=active and math.sin(f*math.pi)*(p.heavy and -3 or 3)*side or 0
 if p.berserk then g.setColor(1,.4,.15,.15);g.circle('fill',x,y-9,25+math.sin(t*14)*2) end
 if p.dashTimer>0 then for i=1,3 do r(x-p.facingX*i*8-5,y-p.facingY*i*8-23,10,23,{.39,.58,.53,.20}) end end
 if profile then
  for i=1,2 do
   local stride=(i==1 and step or -step)*side
   local legX=x-2+stride
   r(legX,y-3,5,10,i==1 and {.13,.19,.20} or {.23,.29,.28})
   r(legX+(side<0 and -3 or 0),y+4,8,4,{.16,.12,.09})
   r(legX+(side<0 and -3 or 0),y+7,8,1,{.39,.30,.17})
  end
 else
 r(x-7,y-3,14,5,{.19,.24,.24})
 r(x-7,y-2,5,8+step,{.19,.24,.24});r(x+2,y-2,5,8-step,{.14,.20,.21})
 r(x-6,y,2,4+step*.5,{.28,.33,.31});r(x+3,y,2,4-step*.5,{.23,.29,.28})
 r(x-8,y+3+step,7,5,{.16,.12,.09});r(x+2,y+3-step,7,5,{.16,.12,.09})
 r(x-7,y+6+step,5,2,{.39,.30,.17});r(x+3,y+6-step,5,2,{.39,.30,.17})
 r(x-6,y+3+step,2,1,{.51,.40,.24});r(x+4,y+3-step,2,1,{.51,.40,.24})
 end
 x=x+lean;y=y+(p.petBend or 0)-(p.lift or 0)+(p.moving and math.sin((p.weaponPose and t*13 or p.stride or 0)*2)*.6 or 0)
 if p.finishWaiting then y=y+math.sin(t*7)*.8 end
 local shirt=p.berserk and {.71,.30,.19} or {.36,.50,.47}
 if furious then y=y+2 end
 -- Broad shoulders taper into the belt; sleeves overlap the torso in both profiles.
 if profile then
  r(x-5,y-18,11,15,shirt);r(x-side*4-1,y-17,3,13,{.26,.38,.36})
  r(x+side*3-1,y-16,2,11,{.47,.60,.53})
  r(x-2,y-18,2,15,{.27,.23,.16});r(x-2,y-14,2,2,{.69,.58,.33})
  r(x-5,y-3,11,3,{.24,.18,.12});r(x+side*4-1,y-3,2,3,{.67,.51,.26})
 else
 r(x-9,y-18,18,7,shirt);r(x-8,y-12,16,9,shirt)
 r(x-6,y-18,3,15,{.47,.60,.53});r(x+5,y-16,2,13,{.26,.38,.36})
 r(x-4,y-19,8,3,{.26,.38,.36});r(x-3,y-19,3,2,{.59,.68,.57});r(x+1,y-19,3,2,{.59,.68,.57})
 if view=='back' then
  g.setColor(.25,.20,.14);g.setLineWidth(2);g.line(x-5,y-19,x+4,y-3);g.line(x+5,y-19,x-4,y-3);g.setLineWidth(1)
 else
  r(x-5,y-18,2,17,{.27,.23,.16});r(x+4,y-18,2,17,{.27,.23,.16});r(x-1,y-17,1,13,{.67,.70,.57})
  r(x-5,y-15,2,2,{.69,.58,.33});r(x+4,y-15,2,2,{.69,.58,.33});r(x+1,y-12,3,4,{.27,.39,.36})
 end
 r(x-9,y-3,18,3,{.24,.18,.12});r(x-1,y-3,3,3,{.67,.51,.26})
 end
 local armX=x-side*8
 if not profile then
 local armSwing=step*.25
 r(armX-2,y-15+armSwing,4,9,skin)
 r(armX-2,y-7+armSwing,4,3,{.88,.65,.41})
 r(armX-3,y-18,6,5,{.59,.68,.57});r(armX-3,y-14,6,1,{.40,.51,.44})
 end
 local sheathX=x-side*(profile and 4 or 7)-2
 r(sheathX,y-2,4,12,{.25,.17,.10});r(sheathX+1,y,1,8,{.49,.33,.17});r(sheathX,y-2,4,2,{.61,.46,.25})
 if furious then y=y+2 end
 if view=='back' then
  r(x-6,y-28,12,11,{.31,.22,.15});r(x-4,y-21,8,4,skin)
 elseif view=='front' then
  r(x-6,y-29,12,14,skin);r(x-6,y-20,12,6,{.29,.20,.14});r(x-3,y-18,6,1,{.56,.34,.21})
  r(x-4,y-25,3,1,ink);r(x+2,y-25,3,1,ink);r(x-3,y-24,1,2,ink);r(x+3,y-24,1,2,ink)
  r(x-1,y-23,3,4,{.92,.65,.38});r(x-4,y-16,2,1,{.47,.31,.19})
 else
  r(x-5,y-29,11,14,skin);r(x+side*5-1,y-25,3,5,{.92,.64,.36});r(x-5,y-20,11,6,{.30,.21,.14})
  r(x+side*2-1,y-26,4,1,ink);r(x+side*3-1,y-25,2,2,ink);r(x-side*5,y-24,2,4,{.64,.42,.25})
 end
 -- The old, crooked hat is the recognizable silhouette in every direction.
 r(x-14,y-31,29,5,{.64,.46,.23});r(x-13,y-31,24,1,{.85,.66,.35});r(x-8,y-39,15,10,{.61,.42,.21})
 r(x-7,y-39,11,2,{.77,.58,.29});r(x-8,y-33,15,3,{.24,.19,.13});r(x+12,y-29,3,3,shirt)
 r(x+3,y-35,2,2,{.42,.30,.17});r(x-10,y-29,4,1,{.81,.60,.31})
 local stains=math.min(10,p.bloodLevel or 0)
 for i=1,stains do local sx=profile and x-4+(i*7)%8 or x-6+(i*7)%13;local sy=y-18+(i*5)%16;r(sx,sy,2,i%2+1,{.32,.52,.12}) end
 if stains>=3 and view~='back' then r(x-3,y-24,2,3,{.38,.62,.14});r(x+5,y-29,2,1,{.39,.60,.12}) end
 if furious then y=y-4 end
 if p.pet then return end
 if (p.sip or 0)>0 then
  local raise=math.min(1,(1.1-p.sip)/.2,p.sip/.2)
  local cupX=x+side*6;local cupY=y-9-raise*10
  g.setColor(skin);g.setLineWidth(3);g.line(x,y-14,cupX,cupY);g.setLineWidth(1)
  r(cupX-3,cupY-2,6,7,{.49,.30,.16});r(cupX-2,cupY-3,4,2,{.52,.68,.34});r(cupX+side,cupY-7,1,5,{.84,.86,.73})
  return
 end
 local shoulderX=profile and x or x+side*7
 local angle=p:bladeAngle();local hx=x+math.cos(angle)*12;local hy=y-11+math.sin(angle)*7
 if p.weaponPose then
  if p.weaponPose=='finish' then
   local f=p.finishStroke or 0;local handX=x+10+(p.finishWaiting and math.sin(t*29)*.45 or 0);local handY=y-42+f*22
   g.setColor(skin);g.setLineWidth(4);g.line(x,y-15,x+5,handY+7,handX,handY);g.setLineWidth(1)
   r(x-3,y-18,6,5,{.59,.68,.57});r(handX-2,handY-2,4,5,skin)
   r(handX-2,handY,4,7,{.37,.25,.16});r(handX-2,handY+7,4,22,{.68,.80,.78});r(handX-2,handY+8,1,20,{1,1,.84})
   if f>.9 then r(handX-1,handY+20,3,6,{.36,.57,.13}) end
   return
  end
  local draw=p.weaponPose=='sheathed' and 0 or p.weaponPose=='drawing' and (p.drawProgress or 0) or 1
  hx=x+side*(9+draw*5);hy=y-5-draw*12;angle=p.weaponPose=='rest' and 1.1 or 1.57
  if furious then hx=x+side*7;hy=y-5;angle=side>0 and 1.25 or 1.89;r(hx-3,hy-2,6,5,{.88,.65,.41}) end
  if p.weaponPose=='reach' then
   g.setColor(skin);g.setLineWidth(4);g.line(shoulderX,y-15,x+side*8,y-23,x+side*11,y-35);g.setLineWidth(1)
   r(shoulderX-3,y-18,6,5,{.59,.68,.57});r(x+side*11-2,y-37,4,5,{.88,.65,.41});return
  end
  r(shoulderX-3,y-18,6,5,{.59,.68,.57});g.setColor(skin);g.setLineWidth(3);g.line(shoulderX,y-14,hx,hy);g.setLineWidth(1)
  g.push();g.translate(hx,hy);g.rotate(angle);r(0,-2,7,4,{.37,.25,.16});if draw>0 then r(7,-2,22*draw,4,{.73,.84,.79}) end;g.pop();return
 end
 r(shoulderX-3,y-18,6,5,{.59,.68,.57});g.setColor(skin);g.setLineWidth(4);g.line(shoulderX,y-14,hx,hy);g.setLineWidth(1)
 if p:isAttackActive() then
  local tail=p.combo==2 and .85 or -.85
  g.setColor(p.berserk and 1 or .92,p.berserk and .45 or .98,.65,.19);g.arc('fill','pie',p.x,p.y-6,p.reach,math.min(angle,angle+tail),math.max(angle,angle+tail),22)
  g.setColor(1,.94,.7,.9);g.setLineWidth(p.heavy and 3 or 2);g.arc('line','open',p.x,p.y-6,p.reach,math.min(angle,angle+tail),math.max(angle,angle+tail),22);g.setLineWidth(1)
 end
 g.push();g.translate(hx,hy);g.rotate(angle);r(0,-2,7,4,{.37,.25,.16});r(7,-3,22,5,{.68,.80,.78});r(10,-3,18,1,{1,1,.84});if stains>0 then r(19,-2,4,2,{.36,.57,.13}) end;g.pop()
end

function A.dogHead(d,t)
 local vertical=math.abs(d.facingY or 0)>.7;local sniff=d.behavior=='sniff' and not d.moving
 local hy=(sniff and -9 or -18)-(d.petLift or 0)
 return d.x+(vertical and 0 or 9*(d.facingX or 1)),d.y-(d.lift or 0)-(d.hop or 0)+hy
end
function A.dog(d,t)
 if d.hidden then return end
 shadow(d.x,d.y+5,12);g.push();g.translate(math.floor(d.x),math.floor(d.y-(d.lift or 0)-(d.hop or 0)));g.scale((d.facingX or 1)<0 and -1 or 1,1)
 local vertical=math.abs(d.facingY or 0)>.7;local back=vertical and d.facingY<0
 local happy=d.behavior=='happy' or d.behavior=='petted';local alert=d.behavior=='watch' or (d.barkTimer or 0)>0
 local worried=d.behavior=='worried'
 local sniff=d.behavior=='sniff' and not d.moving;local stretch=d.behavior=='stretch' and not d.moving
 local run=(d.moveSpeed or 0)>120;local stride=d.moving and math.sin(t*(run and 23 or 15)) or 0
 local bob=d.moving and math.abs(stride)*(run and 1.6 or .6) or 0
 if stretch then g.rotate(.16);g.scale(1.12,.86) end
 r(-8,-1,3,7+stride*2,{.38,.25,.15});r(4,-1,3,7-stride*2,{.42,.28,.16})
 r(-8,4+stride*2,4,2,{.79,.70,.48});r(4,4-stride*2,4,2,{.91,.81,.59})
 r(-10,-11-bob,20,12,{.59,.34,.16});r(-7,-12-bob,13,3,{.77,.48,.24});r(4,-7-bob,6,9,{.91,.80,.55})
 if (d.facingX or 1)>0 or vertical then r(-7,-10-bob,8,6,{.28,.18,.12});r(-5,-4-bob,4,2,{.34,.21,.12}) end
 local wag=worried and 7+math.sin(t*3)*.4 or math.sin(t*(happy and 25 or alert and 5 or 10))*(happy and 4 or 2)
 g.setColor(.65,.39,.17);g.setLineWidth(3);g.line(-10,-8,-15,-11+wag,-17,-14+wag);g.setLineWidth(1);r(-18,-15+wag,3,3,{.90,.79,.53})
 local hy=(sniff and -9 or stretch and -10 or -18)-(d.petLift or 0)-bob
 local hx=vertical and -5 or 4
 g.push();g.translate(hx+5,hy+6)
 if worried then g.rotate(-.15) end
 if d.behavior=='nuzzle' then g.rotate(math.sin(t*7)*.18) end
 if d.behavior=='look' then g.rotate(math.sin((d.lifeClock or t)*1.7)*.13) end
 r(-5,-6,11,11,{.77,.49,.25});r(-3,-6,7,2,{.88,.62,.34})
 -- One lifted ear and one soft, hanging ear make Moro recognizable.
 r(-6,alert and -10 or -7,4,alert and 8 or 10,{.30,.19,.12});r(4,-7,3,5,{.35,.22,.13});r(5,-3,3,6,{.40,.25,.14})
 if not back then
  if vertical then
   r(-2,-4,3,9,{.92,.82,.57});r(-3,2,8,4,{.92,.82,.57});r(-1,2,3,2,ink)
   if d.petSquint then r(-4,-1,3,1,ink);r(2,-1,3,1,ink) else r(-3,-3,2,2,ink);r(3,-3,2,2,ink);r(-3,-3,1,1,cream);r(3,-3,1,1,cream) end
  else
   r(3,0,8,5,{.93,.82,.57});r(9,0,3,2,ink)
   if d.petSquint then r(1,-2,3,1,ink) else r(1,-3,3,3,ink);r(1,-3,1,1,cream) end
   r(1,-5,4,1,{.55,.32,.17})
  end
  if happy or d.behavior=='pant' then r(vertical and 0 or 7,5,2,3+math.sin(t*5)*.5,{.87,.44,.43}) end
 end
 r(-4,5,9,3,{.72,.20,.16});r(-4,5,9,1,{.96,.39,.27})
 local tag= d.moving and math.sin(t*16)*1.5 or 0;r(1+tag,8,3,3,{.84,.71,.34});r(2+tag,8,1,1,cream)
 if d.hasStick then r(4,4,19,2,{.69,.51,.28}) end
 g.pop()
 if (d.barkTimer or 0)>0 then g.setColor(cream);g.arc('line','open',18,hy+6,7,-.7,.7);g.arc('line','open',18,hy+6,11,-.7,.7) end
 if d.behavior=='happy' then r(-2,-30,3,3,{1,.52,.54});r(2,-30,3,3,{1,.52,.54});r(0,-28,3,3,{1,.52,.54}) end
 g.pop()
 if d.stick and not d.hasStick then r(d.stick.x-6,d.stick.y,12,2,{.7,.51,.28}) end
end

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
