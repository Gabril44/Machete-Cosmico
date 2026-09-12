local V={}
local g=love.graphics
local P=require('src.ui.drawing').bind(V)
local C,color,rect,text,center,shadow,bar=P.C,P.color,P.rect,P.text,P.center,P.shadow,P.bar
local function ufo(x,y,r,t)
 shadow(x,y+26,r)
 color({.12,.22,.29});g.ellipse('fill',x,y,r,7);color({.48,.64,.62});g.ellipse('fill',x,y-3,r,5)
 color({.27,.56,.56});g.ellipse('fill',x,y-7,r*.45,8);color({.62,1,.79});g.ellipse('fill',x-3,y-10,r*.23,3)
 for i=-2,2 do rect(x+i*r*.32-1,y,3,2,math.sin(t*4+i)>0 and C.mint or {.2,.48,.42}) end
end

return {draw=ufo}
