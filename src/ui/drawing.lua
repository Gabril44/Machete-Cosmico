local g=love.graphics
local D={}
function D.bind(V)
local C={ink={.045,.06,.10},cream={.94,.88,.69},mint={.54,1,.71},orange={1,.51,.24},muted={.51,.62,.60}}
local function color(c,a) g.setColor(c[1],c[2],c[3],a or 1) end
local function rect(x,y,w,h,c) color(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function text(t,x,y,c,font) color(c or C.cream);g.setFont(font or V.small);g.print(t,math.floor(x),math.floor(y)) end
local function center(t,y,c,font) color(c or C.cream);g.setFont(font or V.small);g.printf(t,0,y,640,'center') end
local function shadow(x,y,w) g.setColor(.02,.04,.05,.35);g.ellipse('fill',x,y,w,4) end
local function bar(x,y,w,h,f,c) rect(x,y,w,h,{.11,.16,.19});rect(x+1,y+1,(w-2)*math.max(0,math.min(1,f)),h-2,c) end

 return {C=C,color=color,rect=rect,text=text,center=center,shadow=shadow,bar=bar}
end
return D
