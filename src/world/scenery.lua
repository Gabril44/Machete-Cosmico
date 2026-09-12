local R={}
local Tilemap=require('src.world.tilemap')
local World=require('src.world.map')
function R.draw(s,V)
local g=love.graphics
local P=require('src.ui.drawing').bind(V)
local C,color,rect,text,center,shadow,bar=P.C,P.color,P.rect,P.text,P.center,P.shadow,P.bar
local function fence(y)
 rect(15,y+4,610,2,{.38,.36,.25});rect(15,y+9,610,2,{.27,.29,.22})
 for x=15,626,23 do rect(x,y,3,16,{.49,.44,.30});rect(x+1,y,1,4,{.68,.59,.38}) end
 rect(291,y,55,16,{.24,.235,.17})
end
local function farm(s)
 rect(0,0,1280,360,{.035,.06,.11})
 for i=1,94 do rect((i*137)%1280,(i*31)%85,1,1,{.33,.49,.57}) end
 color({.76,.86,.71});g.circle('fill',553,45,17);color({.035,.06,.11});g.circle('fill',561,40,15)
 for i=0,20 do local x=i*68;color({.075,.14,.17});g.polygon('fill',x-50,97,x+12,55+(i%3)*12,x+77,97) end
 Tilemap.draw(s.tilemap)
 fence(100);fence(311);g.push();g.translate(640,0);fence(100);fence(311);g.pop();World.field(s,V)
 -- Galpón and porch, placed above the traversable field.
 rect(225,59,145,42,{.31,.27,.22});rect(234,69,128,30,{.42,.33,.23})
 for x=235,361,8 do rect(x,69,1,28,{.30,.25,.21}) end
 color({.22,.22,.25});g.polygon('fill',215,64,236,37,356,37,380,64)
 for x=239,357,12 do rect(x,42,2,18,{.34,.32,.32}) end
 rect(282,73,30,28,{.09,.12,.13});rect(244,74,15,14,{.88,.63,.29});rect(250,74,2,14,{.35,.28,.22});rect(244,80,15,2,{.35,.28,.22})
 rect(327,80,29,5,{.20,.21,.17});text('LA QUERENCIA',259,52,C.cream)
 -- Garden beds and vegetables.
 for row=0,3 do
  rect(47,255+row*13,110,9,{.23,.20,.14})
  for col=0,8 do local x=52+col*12;local y=259+row*13;rect(x,y,2,5,{.41,.48,.24});rect(x-2,y-2,6,3,{.26,.40,.22});rect(x,y-5,2,6,{.36,.48,.23}) end
 end
 -- Tractor, hay, barrels.
 shadow(568,132,25);rect(547,111,32,17,{.43,.22,.16});rect(568,101,13,20,{.51,.29,.17});rect(571,104,7,9,{.15,.27,.29});rect(552,105,3,8,{.16,.18,.16})
 color(C.ink);g.circle('fill',550,128,8);g.circle('fill',576,128,10);color({.50,.43,.28});g.circle('fill',550,128,3);g.circle('fill',576,128,4)
 for i=0,2 do rect(62+i*19,124,16,11,{.60,.48,.25});rect(66+i*19,124,2,11,{.36,.31,.20}) end
 for _,m in ipairs(s.marks) do color({.19,.32,.15});g.ellipse('fill',m.x,m.y,10,4);rect(m.x-12,m.y+2,4,2,{.26,.4,.17}) end
 for _,w in ipairs(s.weeds) do if not w.cut then rect(w.x,w.y-7,2,9,{.52,.60,.28});rect(w.x-4,w.y-4,9,2,{.40,.49,.22});rect(w.x+3,w.y-9,2,7,{.64,.65,.32}) else rect(w.x-2,w.y,5,2,{.30,.36,.20}) end end
end

farm(s)
end
return R
