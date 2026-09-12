local Player={}; Player.__index=Player
function Player.new(x,y)
 return setmetatable({x=x,y=y,hp=100,maxHp=100,rage=0,maxRage=100,baseSpeed=108,facingX=1,facingY=0,attackTimer=0,attackCooldown=0,dashTimer=0,dashCooldown=0,berserkTimer=0,berserk=false,inv=0,combo=0,comboTime=0,swing=0},Player)
end
function Player:update(dt,input)
 for _,k in ipairs({'attackTimer','attackCooldown','dashTimer','dashCooldown','berserkTimer','inv','comboTime'}) do self[k]=math.max(0,self[k]-dt) end
 self.berserk=self.berserkTimer>0
 local dx,dy=input.x,input.y; local n=math.sqrt(dx*dx+dy*dy)
 if n>0 then dx,dy=dx/n,dy/n; if self.dashTimer<=0 then self.facingX,self.facingY=dx,dy end end
 local speed=self.berserk and 142 or self.baseSpeed
 if self.dashTimer>0 then dx,dy=self.facingX,self.facingY; speed=360 end
 self.x=math.max(22,math.min(618,self.x+dx*speed*dt)); self.y=math.max(96,math.min(316,self.y+dy*speed*dt)); self.moving=n>0
end
function Player:attack(heavy)
 if self.attackCooldown>0 then return false end
 self.combo=(self.comboTime>0 and self.combo%3 or 0)+1; self.comboTime=.85
 self.heavy=heavy; self.attackTimer=heavy and .30 or .18; self.attackDuration=self.attackTimer
 self.attackCooldown=heavy and .58 or (self.berserk and .15 or .24)
 self.damage=(heavy and 3 or (self.combo==3 and 2 or 1))*(self.berserk and 2 or 1)
 self.reach=heavy and 58 or 44; self.swing=self.swing+1; return true
end
function Player:dash()
 if self.dashCooldown>0 then return false end
 self.dashTimer=.17; self.dashCooldown=.72; self.inv=.24; return true
end
function Player:addRage(n) if not self.berserk then self.rage=math.min(100,self.rage+n) end end
function Player:activateBerserk()
 if self.rage<100 or self.berserk then return false end
 self.rage=0; self.berserkTimer=6; self.berserk=true; self.inv=.7; return true
end
function Player:inArc(e)
 local dx,dy=e.x-self.x,e.y-self.y; local d=math.sqrt(dx*dx+dy*dy)
 return d<(self.reach or 44)+(e.radius or 8) and (d<16 or (dx*self.facingX+dy*self.facingY)/d>-.15)
end
return Player
