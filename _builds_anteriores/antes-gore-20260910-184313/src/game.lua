local World=require('src.world')
local Companion=require('src.companion')
local Cinema=require('src.cinema')
local Boss=require('src.boss')
local Dog=require('src.dog')
local Player=require('src.player')
local G={}; G.__index=G
local function dist(a,b) return ((a.x-b.x)^2+(a.y-b.y)^2)^.5 end
local function move(a,b,s,dt)
 local d=dist(a,b); if d>1 then a.x=a.x+(b.x-a.x)/d*s*dt; a.y=a.y+(b.y-a.y)/d*s*dt end
 return d
end
function G.new(audio)
 local self=setmetatable({audio=audio,state='menu',time=0,best=tonumber((love.filesystem.read('best.txt'))) or 0},G)
 self:reset(); self.state='menu'; return self
end
function G:reset()
 self.debugUsed=false;self.debugGod=false
 self.player=Player.new(300,205); self.dog=Dog.new(289,104); self.enemies={}; self.particles={}; self.drops={}; self.shots={}; self.marks={}
 self.cows={{x=145,y=167,progress=0},{x=480,y=177,progress=0},{x=495,y=274,progress=0}}
 self.weeds={}; self.grassGoal=18; for patch=0,2 do for i=0,11 do self.weeds[#self.weeds+1]={x=180+patch*98+(i%4)*15,y=250+math.floor(i/4)*17} end end
 self.stage='intro'; self.state='play'; self.stageTime=0; self.wave=0; self.queue=0; self.spawn=0; self.score=0; self.kills=0; self.combo=0; self.chain=0; self.pet=false; self.cut=0; self.walked=0; self.shake=0; self.stop=0; self.message=''; self.messageTime=0; self.elapsed=0; self.lost=0; self.boss=nil; self.player.x=297;self.player.y=100;self.cinemaSound=0;self.endingScene=nil;self.defeatedBoss=nil;self.player.weaponPose='sheathed';self.player.hidden=true;self.dog.hidden=true;self.gateOpen=false;self.transition=0;self.farmCows=nil;World.setup(self,'farm')
end
function G:say(t) self.message=t; self.messageTime=3.4 end
function G:burst(x,y,n,color)
 for i=1,n do local a=love.math.random()*6.283; local s=love.math.random(20,110); self.particles[#self.particles+1]={x=x,y=y,vx=math.cos(a)*s,vy=math.sin(a)*s,t=.3+love.math.random()*.35,c=color or {0.6,1,.25}} end
end
function G:spawnEnemy(kind)
 local side=love.math.random(4); local x=side==1 and 18 or side==2 and 622 or love.math.random(50,590); local y=side==3 and 98 or side==4 and 313 or love.math.random(115,300)
 local hp=kind=='boss' and 85 or kind=='brute' and 7 or kind=='gunner' and 3 or 2
 local e={x=x,y=y,kind=kind,hp=hp,maxHp=hp,radius=kind=='boss' and 20 or 9,flash=0,stun=0,cool=1,wind=0,kx=0,ky=0}
 local base=self.region=='field' and 640 or 0;e.x=e.x+base;e.spawnBase=base
 if kind=='boss' then e.x=base+320;e.y=132;self.boss=e end
 self.enemies[#self.enemies+1]=e; self:burst(e.x,e.y,12,{.4,.9,1}); return e
end
function G:beginWave(n)
 self.stage='wave'; self.stageTime=0; self.wave=n; self.queue=6+n*3; self.spawn=.5
 self.player.hp=math.min(100,self.player.hp+15)
 self:say(({ 'EH. Las vacas se quedan.', '¡Ni las papas me dejan!', 'Vengan. Hay machete para todos.' })[n]); self.audio.play('wave')
end
function G:hurt(n,x,y)
 local p=self.player; if p.inv>0 or self.debugGod then return end
 p.hp=math.max(0,p.hp-n); p.inv=.85; self.shake=5; self.combo=0; self.audio.play('hurt'); self:burst(p.x,p.y,12,{1,.3,.23})
 if p.hp<=0 then self.state='dead'; self:save() end
end
function G:save() if self.debugUsed then return end; if self.score>self.best then self.best=self.score; love.filesystem.write('best.txt',tostring(self.best)) end end
function G:key(k)
 if k=='m' then self.audio.muted=not self.audio.muted; return end
 if self.state=='menu' then if k=='return' or k=='space' then self:reset() end; return end
 if self.state=='dead' or self.state=='win' then if k=='r' or k=='return' then self:reset() end; return end
 if k=='escape' then self.state=self.state=='pause' and 'play' or 'pause'; return end
 if self.state~='play' then return end
 if Cinema.active(self) then if k=='return' and self.stageTime>1 then Cinema.finish(self) end;return end
 local p=self.player
 if k=='r' then Companion.throw(self)
 elseif k=='space' or k=='q' then if p:attack(k=='q') then self.audio.play('swing') end
 elseif k=='lshift' or k=='rshift' then if p:dash() then self.audio.play('dash') end
 elseif k=='f' then if p:activateBerserk() then self.audio.play('rage'); self:say('¡CON MI CHACRA NO!'); self.shake=6 end
 elseif k=='e' and dist(p,self.dog)<44 then self.pet=true; Companion.pet(self);self.audio.play('bark'); self:say('Buen perro, Moro. Quedate cerca.'); self:burst(self.dog.x,self.dog.y-12,8,{1,.55,.6}) end
end
function G:update(dt,override)
 self.time=self.time+dt
 if self.state~='play' then return end
 if self.stop>0 then self.stop=self.stop-dt; return end
 self.stageTime=self.stageTime+dt; self.elapsed=self.elapsed+dt; self.messageTime=math.max(0,self.messageTime-dt); self.shake=math.max(0,self.shake-dt*20)
 for i=#self.particles,1,-1 do local a=self.particles[i]; a.t=a.t-dt;a.x=a.x+a.vx*dt;a.y=a.y+a.vy*dt;a.vy=a.vy+90*dt;if a.t<=0 then table.remove(self.particles,i) end end
 Dog.update(self.dog,dt,self.audio)
 if Cinema.active(self) then Cinema.update(self,dt); return end
 local input=override or {x=(love.keyboard.isDown('d','right') and 1 or 0)-(love.keyboard.isDown('a','left') and 1 or 0),y=(love.keyboard.isDown('s','down') and 1 or 0)-(love.keyboard.isDown('w','up') and 1 or 0)}
 local p=self.player;p.maxX=self.gateOpen and 1258 or 612;p:update(dt,input)
 if input.x~=0 or input.y~=0 then self.walked=self.walked+dt end
 Dog.follow(self.dog,p,dt,self)
 World.update(self,dt)
 self.chain=math.max(0,self.chain-dt); if self.chain==0 then self.combo=0 end
 for _,w in ipairs(self.weeds) do if not w.cut and p:isAttackActive() and p:inArc(w) then w.cut=true;self.cut=self.cut+1;self:burst(w.x,w.y,8,{.5,.65,.25}) end end
 if self.stage=='tutorial' and self.walked>1 and self.cut>=self.grassGoal and self.pet then self.stage='arrival';self.stageTime=0;self:say('¿Y esa luz?');self.audio.play('wave') end
 if self.stage=='arrival' and self.stageTime>3 then self:beginWave(1);local e=self:spawnEnemy('thief'); e.x=145;e.y=148 end
 if self.stage=='wave' then
  self.spawn=self.spawn-dt
  if self.queue>0 and self.spawn<=0 then
   local k=self.queue%3==0 and 'thief' or 'raider'; if self.wave>=2 and self.queue%4==0 then k='gunner' end; if self.wave==3 and self.queue%5==0 then k='brute' elseif self.wave>=2 and self.queue%5==0 then k='looter' end
   if self.region=='field' and k=='thief' then k='looter' end
   self:spawnEnemy(k);self.queue=self.queue-1;self.spawn=1.45
  end
  if self.queue==0 and #self.enemies==0 then self.stage='rest';self.stageTime=0;self:say('Un respiro. Juntá los mates y preparate.') end
 elseif self.stage=='rest' and self.stageTime>4 then
  if self.wave==2 then self.stage='travel';self.gateOpen=true;self:say('Abrieron el portón. ¡Al galpón, Moro!')
  elseif self.wave<3 then self:beginWave(self.wave+1) else self.stage='boss';self.stageTime=0;self:spawnEnemy('boss');self:say('INSPECTOR DE GANADO • Permiso de abducción denegado.');self.audio.play('wave') end
 end
 for _,c in ipairs(self.cows) do c.active=false end
 for i=#self.enemies,1,-1 do
  local e=self.enemies[i];local previousX,previousY=e.x,e.y;e.flash=math.max(0,e.flash-dt);e.stun=math.max(0,e.stun-dt);e.cool=e.cool-dt
  if p:isAttackActive() and e.lastSwing~=p.swing and p:inArc(e) then
   e.lastSwing=p.swing;e.hp=e.hp-p.damage;e.flash=.12;e.stun=e.kind=='boss' and .05 or .22
   local d=math.max(1,dist(e,p)); local force=p.heavy and 340 or 190; if e.kind=='boss' then force=force*.22 end
   e.kx=(e.x-p.x)/d*force;e.ky=(e.y-p.y)/d*force
   p:addRage(9);self.combo=self.combo+1;self.chain=2.2;self.stop=.035;self.shake=p.heavy and 4 or 2;self.audio.play('hit');self:burst(e.x,e.y,12)
  end
  e.x=math.max(12,math.min(1268,e.x+e.kx*dt));e.y=math.max(96,math.min(318,e.y+e.ky*dt));e.kx=e.kx*math.max(0,1-dt*9);e.ky=e.ky*math.max(0,1-dt*9)
  if e.hp<=0 then
   if not e.escaped then
   Companion.onKill(self,e,Dog)
   self.score=self.score+100+math.min(20,self.combo)*10;self.kills=self.kills+1;self:burst(e.x,e.y,24)
   self.marks[#self.marks+1]={x=e.x,y=e.y};if #self.marks>65 then table.remove(self.marks,1) end
   if self.kills%4==0 then self.drops[#self.drops+1]={x=e.x,y=e.y,t=16} end
   if e.carrying then if e.lootTarget then e.lootTarget.stolen=false end;self.score=self.score+200;self:say('Las papas se quedan, campeón.') end
   end
   table.remove(self.enemies,i)
   if e.kind=='boss' then Cinema.beginEnding(self,e);return end
  elseif e.stun<=0 then
   local d=dist(e,p)
   if e.kind=='thief' then
    local target=nil;local near=math.huge;for _,c in ipairs(self.cows) do if not c.lost and dist(e,c)<near then target=c;near=dist(e,c) end end
    if target then if move(e,target,36,dt)<22 then target.active=true end else move(e,p,43,dt);if d<22 and e.cool<=0 then self:hurt(8,e.x,e.y);e.cool=1 end end
   elseif e.kind=='looter' then World.loot(self,e,dt)
   elseif e.kind=='gunner' then
    if e.wind>0 then
     e.wind=math.max(0,e.wind-dt)
     if e.wind==0 then self.shots[#self.shots+1]={x=e.x,y=e.y,vx=e.aimX*110,vy=e.aimY*110,t=5};e.cool=1.65 end
    elseif e.cool<=0 then
     local n=math.max(1,d);e.aimX=(p.x-e.x)/n;e.aimY=(p.y-e.y)/n;e.wind=.45
    elseif d>125 then move(e,p,32,dt) elseif d<70 then move(e,p,-24,dt) end
   elseif e.kind=='boss' then
    Boss.update(self,e,p,dt)
   else
    if e.wind>0 then e.wind=e.wind-dt;if e.wind<=0 then if d<30 then self:hurt(e.kind=='brute' and 19 or 11,e.x,e.y) end;e.cool=.9 end
    elseif d<22 and e.cool<=0 then e.wind=e.kind=='brute' and .65 or .38
    elseif d>20 then move(e,p,e.kind=='brute' and 33 or 52,dt) end
   end
  end
  e.moving=(e.x-previousX)^2+(e.y-previousY)^2>.002
  if e.moving then local dx,dy=e.x-previousX,e.y-previousY;local n=math.max(.001,math.sqrt(dx*dx+dy*dy));e.facingX=dx/n;e.facingY=dy/n end
  if e.hp>0 then World.resolve(self,e,true) end
 end
 for _,c in ipairs(self.cows) do if not c.lost then c.progress=math.max(0,c.progress+(c.active and dt or -dt*.85));if c.progress>=9 then c.lost=true;self.lost=self.lost+1;self:say('¡Esa vaca tenía nombre!');self.audio.play('hurt') end end end
 for i=#self.shots,1,-1 do
  local s=self.shots[i];s.x=s.x+s.vx*dt;s.y=s.y+s.vy*dt;s.t=s.t-dt
  if p:isAttackActive() and p:inArc(s) then s.t=0;p:addRage(3);self:burst(s.x,s.y,5,{.5,1,1}) elseif dist(s,p)<10 then self:hurt(9,s.x,s.y);s.t=0 end
  if s.t<=0 then table.remove(self.shots,i) end
 end
 for i=#self.drops,1,-1 do local d=self.drops[i];d.t=d.t-dt;if dist(d,p)<18 then p.hp=math.min(100,p.hp+18);self.audio.play('pickup');d.t=0 end;if d.t<=0 then table.remove(self.drops,i) end end
end
return G
