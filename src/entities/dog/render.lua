local A={};local g=love.graphics
local ink={.045,.07,.08};local skin={.81,.58,.35};local cream={.94,.91,.77}
local function r(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function shadow(x,y,w) g.setColor(.018,.04,.04,.4);g.ellipse('fill',x,y,w,4) end

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
 local blink=not alert and not d.moving and ((t+(d.x or 0)*.013)%4.7)<.13
 local squint=d.petSquint or blink
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
   if squint then r(-4,-1,3,1,ink);r(2,-1,3,1,ink) else r(-3,-3,2,2,ink);r(3,-3,2,2,ink);r(-3,-3,1,1,cream);r(3,-3,1,1,cream) end
  else
   r(3,0,8,5,{.93,.82,.57});r(9,0,3,2,ink)
   if squint then r(1,-2,3,1,ink) else r(1,-3,3,3,ink);r(1,-3,1,1,cream) end
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


return A
