local A={}
function A.spawn(self,kind)
 local side=love.math.random(4); local x=side==1 and 18 or side==2 and 622 or love.math.random(50,590); local y=side==3 and 98 or side==4 and 313 or love.math.random(115,300)
 local hp=kind=='boss' and 85 or kind=='brute' and 7 or kind=='gunner' and 3 or 2
 local e={x=x,y=y,kind=kind,hp=hp,maxHp=hp,radius=kind=='boss' and 20 or 9,flash=0,stun=0,cool=1,wind=0,kx=0,ky=0}
 local base=self.region=='field' and 640 or 0;e.x=e.x+base;e.spawnBase=base
 if kind=='boss' then e.x=base+320;e.y=132;self.boss=e end
 self.enemies[#self.enemies+1]=e; self:burst(e.x,e.y,12,{.4,.9,1}); return e
end

return A
