local R={}
local ufo=require('src.entities.aliens.ship').draw
function R.draw(c,s,V)
local g=love.graphics
local P=require('src.ui.drawing').bind(V)
local C,color,rect,text,center,shadow,bar=P.C,P.color,P.rect,P.text,P.center,P.shadow,P.bar

local function cow(c,s)
 if c.lost then
  local depart=s.time-(c.departTime or s.time)
  if depart<1.5 then ufo(c.x,c.y-59-depart*depart*120,23,s.time) end
  return
 end
 local f=math.max(0,math.min(1,(c.progress-6)/3));local rise=f*f*(3-2*f)
 local shrink=1-math.max(0,(f-.72)/.28)*.95
 local x,y=c.x,c.y-rise*51;shadow(x,c.y+4,16*(1-rise*.8))
 if c.active and not c.lost then
  color(C.orange,.65+.25*math.sin(s.time*7));g.ellipse('line',x,c.y+5,22,7)
  text('!',x-2,y-29,C.ink,V.medium)
  text('!',x-3,y-30,C.orange,V.medium)
 end
 if c.progress>0 then
  color(C.mint,.12);g.polygon('fill',x-24,c.y+8,x+24,c.y+8,x+10,c.y-57,x-10,c.y-57)
  ufo(x,c.y-59,23,s.time);bar(x-20,c.y+12,40,4,c.progress/9,C.orange)
 end
 g.push();g.translate(x,y);g.scale(shrink);g.translate(-x,-y)
 local tailPhase=s.time*(c.active and 10 or 2.5)+c.x*.07
 local tailSwing=math.sin(tailPhase)*(c.active and 3 or 1.5)
 color(C.cream);g.setLineWidth(1);g.line(x-11,y-8,x-15,y-5,x-15+tailSwing,y+1)
 rect(x-16+tailSwing,y,3,3,{.30,.29,.22})
 rect(x-12,y-10,24,14,C.cream);rect(x-10,y+2,3,5,{.53,.54,.43});rect(x+8,y+2,3,5,{.53,.54,.43})
 rect(x-6,y-9,7,7,{.17,.21,.21});rect(x+4,y-3,6,5,{.17,.21,.21})
 local cycle=(s.time*.65+c.x*.037+c.y*.021)%8
 local grazing=not c.active and c.progress==0 and (s.omen or 0)<.4
 local dip=grazing and math.max(0,math.min(1,(cycle-2)*2,(5.5-cycle)*2)) or 0
 local chew=grazing and cycle>5.5 and cycle<7.5 and math.sin(s.time*10+c.x) or 0
 local lift=(s.omen or 0)>.4 and 4 or -dip*11
 if grazing then
  color({.39,.54,.23});g.line(x+15,c.y+4,x+13,c.y,x+16,c.y+2,x+18,c.y-1)
 end
 rect(x+10,y-12-lift,9,10,C.cream);rect(x+13,y-5-lift+chew,8,4,{.70,.49,.43});rect(x+15,y-10-lift,2,2,C.ink);rect(x+11,y-15-lift,2,4,{.60,.51,.34})
 if grazing and cycle>4 and cycle<7.5 then
  rect(x+18,y-2-lift+chew,1,3,{.47,.63,.25});rect(x+20,y-1-lift+chew,1,2,{.37,.52,.20})
 end
 g.pop()
end

cow(c,s)
end
return R
