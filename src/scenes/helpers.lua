local g=love.graphics
local function clamp(x) return math.max(0,math.min(1,x)) end
local function lerp(a,b,t) return a+(b-a)*clamp(t) end
local function ease(t) t=clamp(t);return t*t*(3-2*t) end
local function rect(x,y,w,h,r,gg,b,a) g.setColor(r,gg,b,a or 1);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function subtitle(t,font,y) rect(20,(y or 308)-3,600,font:getHeight()+7,.015,.018,.025,.82);g.setFont(font);g.setColor(.97,.91,.76);g.printf(t,25,y or 308,590,'center') end
local function walk(a,x,y,speed,dt)
 local dx,dy=x-a.x,y-a.y;local n=math.sqrt(dx*dx+dy*dy);a.moving=n>1
 if n>1 then local step=math.min(n,speed*dt);a.x=a.x+dx/n*step;a.y=a.y+dy/n*step;a.facingX=dx/n;a.facingY=dy/n end
end
return {clamp=clamp,lerp=lerp,ease=ease,rect=rect,subtitle=subtitle,walk=walk}
