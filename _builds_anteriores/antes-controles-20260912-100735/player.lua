local P={};P.__index=P
function P.new(x,y)
 return setmetatable({x=x,y=y,hp=100,maxHp=100,rage=0,maxRage=100,baseSpeed=108,facingX=1,facingY=0,attackTimer=0,attackCooldown=0,dashTimer=0,dashCooldown=0,berserkTimer=0,berserk=false,inv=0,combo=0,comboTime=0,swing=0,windup=0,stride=0},P)
end
function P:update(dt,input)
 self.dodgeFlash=math.max(0,(self.dodgeFlash or 0)-dt)
 self.sip=math.max(0,(self.sip or 0)-dt)
 if input.x~=0 or input.y~=0 or self.attackTimer>0 or self.dashTimer>0 or self.pet then self.sip=0 end
 for _,k in ipairs({'attackTimer','attackCooldown','dashTimer','dashCooldown','berserkTimer','inv','comboTime'}) do self[k]=math.max(0,self[k]-dt) end
 self.berserk=self.berserkTimer>0
 local dx,dy=input.x,input.y;local n=math.sqrt(dx*dx+dy*dy)
 if n>0 then dx,dy=dx/n,dy/n;if self.dashTimer<=0 and self.attackTimer<=0 then self.facingX,self.facingY=dx,dy end end
 local speed=self.berserk and 142 or self.baseSpeed
 if self.attackTimer>0 then speed=speed*(self.heavy and .45 or .72) end
 if self.dashTimer>0 then dx,dy=self.facingX,self.facingY;speed=360 end
 if self:isAttackActive() and self.attackTimer>(self.activeTime or .16)-.055 then
  self.x=self.x+self.facingX*(self.heavy and 105 or 55)*dt;self.y=self.y+self.facingY*(self.heavy and 105 or 55)*dt
 end
 self.x=math.max(22,math.min(self.maxX or 1258,self.x+dx*speed*dt));self.y=math.max(96,math.min(316,self.y+dy*speed*dt));self.moving=n>0
 if self.moving then self.stride=self.stride+dt*speed*.15 end
 if self.queued and self.attackCooldown<=0 then local h=self.queued=='heavy';self.queued=nil;self:attack(h) end
end
function P:attack(heavy)
 self.sip=0
 if self.attackCooldown>0 then if self.attackCooldown<.18 then self.queued=heavy and 'heavy' or 'light' end;return false end
 self.combo=heavy and 0 or (self.comboTime>0 and self.combo%3 or 0)+1;self.comboTime=.9
 self.heavy=heavy;self.windup=heavy and .22 or .035;self.activeTime=heavy and .19 or .16
 self.attackDuration=self.windup+self.activeTime;self.attackTimer=self.attackDuration
 self.attackCooldown=heavy and .60 or (self.berserk and .19 or .26)
 self.damage=(heavy and 3 or (self.combo==3 and 2 or 1))*(self.berserk and 2 or 1)
 self.reach=heavy and 58 or self.combo==3 and 49 or 44;self.swing=self.swing+1
 return true
end
function P:isAttackActive() return self.attackTimer>0 and self.attackTimer<=(self.activeTime or .16) end
function P:attackPhase() return self.attackDuration and math.max(0,math.min(1,1-self.attackTimer/self.attackDuration)) or 0 end
function P:bladeAngle()
 local a=math.atan2(self.facingY,self.facingX);local f=self:attackPhase()
 if self.attackTimer<=0 then return a+.8 end
 if self.heavy then return a-1.8+math.max(0,(f-.53)/.47)*3.1 end
 if self.combo==2 then return a+1.45-f*2.9 end
 if self.combo==3 then return a-2.2+f*4.4 end
 return a-1.25+f*2.5
end
function P:dash()
 if self.dashCooldown>0 then return false end
 self.sip=0;self.dodgeRewarded=false;self.dashTimer=.17;self.dashCooldown=.72;self.inv=.24;return true
end
function P:addRage(n) if not self.berserk then self.rage=math.min(100,self.rage+n) end end
function P:activateBerserk()
 if self.rage<100 or self.berserk then return false end
 self.rage=0;self.berserkTimer=6;self.berserk=true;self.inv=.7;return true
end
function P:inArc(e)
 local dx,dy=e.x-self.x,e.y-self.y;local d=math.sqrt(dx*dx+dy*dy)
 return d<(self.reach or 44)+(e.radius or 8) and (d<16 or (dx*self.facingX+dy*self.facingY)/d>-.15)
end
return P
