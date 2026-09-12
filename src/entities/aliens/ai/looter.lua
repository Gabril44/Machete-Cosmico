local PlayerLines=require('src.entities.player.dialogue')
local A={}
function A.update(s,e,p,dt)
 if e.carrying then
  local edge=(e.spawnBase or 0)>0 and 1265 or 15;local dx=edge-e.x;e.x=e.x+math.min(math.abs(dx),67*dt)*(dx<0 and -1 or 1);e.y=e.y+(221-e.y)*dt
  if math.abs(e.x-edge)<12 then e.escaped=true;e.hp=0;s:say(PlayerLines.potatoesLost);end
  return
 end
 local target;local best=math.huge
 for _,o in ipairs(s.props or {}) do if o.kind=='sack' and math.floor(o.x/640)==math.floor((e.spawnBase or 0)/640) and not o.broken and not o.stolen then local d=(e.x-o.x)^2+(e.y-o.y)^2;if d<best then best=d;target=o end end end
 if target then
  local d=math.sqrt(best)
  if d>17 then e.x=e.x+(target.x-e.x)/d*48*dt;e.y=e.y+(target.y-e.y)/d*48*dt
  else e.steal=(e.steal or 0)+dt;if e.steal>.7 then target.stolen=true;e.carrying=true;e.lootTarget=target end end
 else e.kind='raider' end
end

return A
