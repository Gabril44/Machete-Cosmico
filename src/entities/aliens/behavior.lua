local melee=require('src.entities.aliens.ai.melee')
local strategies={thief=require('src.entities.aliens.ai.captor'),gunner=require('src.entities.aliens.ai.gunner'),
 looter=require('src.entities.aliens.ai.looter'),boss=require('src.entities.aliens.boss')}
local A={}
function A.update(s,e,p,dt) return (strategies[e.kind] or melee).update(s,e,p,dt) end
return A
