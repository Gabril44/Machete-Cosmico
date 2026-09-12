local P={}
function P.burst(self,x,y,n,color)
 for i=1,n do local a=love.math.random()*6.283; local s=love.math.random(20,110); self.particles[#self.particles+1]={x=x,y=y,vx=math.cos(a)*s,vy=math.sin(a)*s,t=.3+love.math.random()*.35,c=color or {0.6,1,.25}} end
end

function P.update(self,dt)
 for i=#self.particles,1,-1 do local a=self.particles[i]; a.t=a.t-dt;a.x=a.x+a.vx*dt;a.y=a.y+a.vy*dt;a.vy=a.vy+90*dt;if a.t<=0 then table.remove(self.particles,i) end end
end
return P
