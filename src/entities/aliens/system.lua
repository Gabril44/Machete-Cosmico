local PlayerLines=require('src.entities.player.dialogue')
local A={}
local Combat=require('src.systems.combat')
local Behavior=require('src.entities.aliens.behavior')
local Companion=require('src.entities.dog.behavior')
local Dog=require('src.entities.dog.model')
local Gore=require('src.effects.gore')
local World=require('src.world.map')
local Cinema=require('src.scenes.cinema')

function A.update(self,dt)
 local p=self.player
 for _,c in ipairs(self.cows) do c.active=false end
 for i=#self.enemies,1,-1 do
  local e=self.enemies[i];local previousX,previousY=e.x,e.y;e.flash=math.max(0,e.flash-dt);e.stun=math.max(0,e.stun-dt);e.cool=e.cool-dt
  Combat.strike(self,e)
  e.x=math.max(12,math.min(1268,e.x+e.kx*dt));e.y=math.max(96,math.min(318,e.y+e.ky*dt));e.kx=e.kx*math.max(0,1-dt*9);e.ky=e.ky*math.max(0,1-dt*9)
  if e.hp<=0 then
   if not e.escaped then
   Companion.onKill(self,e,Dog);if e.kind~='boss' then Gore.death(self,e,p) end
   self.score=self.score+100+math.min(20,self.combo)*10;self.kills=self.kills+1;self:burst(e.x,e.y,24)
   self.marks[#self.marks+1]={x=e.x,y=e.y};if #self.marks>65 then table.remove(self.marks,1) end
   if self.kills%4==0 then self.drops[#self.drops+1]={x=e.x,y=e.y,t=16} end
   if e.carrying then if e.lootTarget then e.lootTarget.stolen=false end;self.score=self.score+200;self:say(PlayerLines.potatoesSaved) end
   end
   table.remove(self.enemies,i)
   if e.kind=='boss' then Cinema.beginEnding(self,e);return true end
  elseif e.stun<=0 then
   Behavior.update(self,e,p,dt)
  end
  e.moving=(e.x-previousX)^2+(e.y-previousY)^2>.002
  if e.moving then local dx,dy=e.x-previousX,e.y-previousY;local n=math.max(.001,math.sqrt(dx*dx+dy*dy));e.facingX=dx/n;e.facingY=dy/n end
  if e.hp>0 then World.resolve(self,e,true) end
 end

 return false
end
return A
