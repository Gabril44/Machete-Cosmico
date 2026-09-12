local W={}
local g=love.graphics
local function rect(x,y,w,h,c) g.setColor(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function new(kind,x,y) return {kind=kind,x=x,y=y,hp=(kind=='crate' or kind=='hay') and 3 or 1,radius=kind=='corn' and 5 or 12,solid=kind=='crate' or kind=='hay'} end
W.new=new
function W.breakProp(s,o,force)
 if o.broken then return end
 o.hp=o.hp-force
 if o.kind=='crate' then
  o.hitTime=.18;s:burst(o.x,o.y-10,o.hp>0 and 6 or 24,{.76,.53,.28})
  if o.hp>0 then s.audio.play('prop',.5,1.3) end
 end
 if o.hp<=0 then
  o.broken=true;s:burst(o.x,o.y,o.kind=='corn' and 7 or 19,o.kind=='corn' and {.43,.62,.24} or {.76,.53,.28})
  s.audio.play('prop',o.kind=='corn' and .4 or .8,o.kind=='hay' and .75 or o.kind=='corn' and 1.65 or o.kind=='sack' and .9 or 1)
  if o.kind=='crate' then s.drops[#s.drops+1]={x=o.x,y=o.y,t=18} end
 end
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
   x=x+math.sin((o.hitTime or 0)*85)*(o.hitTime or 0)*9
   rect(x-13,y-4,26,9,{.055,.09,.07});rect(x-11,y-21,22,23,{.48,.31,.17});rect(x-9,y-19,18,3,{.71,.48,.25});rect(x-9,y-3,18,3,{.71,.48,.25});g.setColor(.66,.45,.23);g.setLineWidth(2);g.line(x-9,y-15,x+9,y-4);g.setLineWidth(1)
   if o.hp<=2 then
    g.setColor(.19,.12,.08);g.line(x-4,y-19,x-1,y-14,x-4,y-10,x,y-6)
    rect(x-3,y-15,1,3,{.83,.62,.34})
   end
   if o.hp<=1 then
    g.setColor(.16,.10,.07);g.line(x+7,y-18,x+3,y-12,x+6,y-8,x+2,y)
    g.line(x-1,y-14,x+4,y-13);rect(x-10,y-6,4,3,{.22,.14,.08})
   end
  elseif o.kind=='hay' then
   rect(x-14,y-14,28,17,{.62,.51,.26});rect(x-8,y-14,2,17,{.32,.29,.19});rect(x+8,y-14,2,17,{.32,.29,.19})
  else
   g.setColor(.62,.48,.27);g.ellipse('fill',x,y-7,10,12);rect(x-5,y-20,10,4,{.37,.28,.17});rect(x-4,y-11,8,6,{.44,.35,.20})
  end
 end
end

return W
