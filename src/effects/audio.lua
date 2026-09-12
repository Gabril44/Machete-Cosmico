local A={sources={},muted=false}
function A.load()
 local Player=require('src.entities.player.sounds')
 local Dog=require('src.entities.dog.sounds')
 local Aliens=require('src.entities.aliens.sounds')
 local World=require('src.world.sounds')
 local Synth=require('src.effects.synthesis')
 local specs={insect=World.insect,tag=Dog.tag,hit=World.hit,swing=Player.swing,dash=Player.dash,hurt=Player.hurt,rage=Player.rage,bark=Dog.bark,wave=Aliens.wave,pickup=Player.pickup}
 specs.abduction=Aliens.abduction;specs.roar=Aliens.roar;specs.dodge=Player.dodge
 specs.bossCharge=Aliens.bossCharge;specs.bossRush=Aliens.bossRush
 specs.bossGather=Aliens.bossGather;specs.bossPulse=Aliens.bossPulse
 for name,v in pairs(specs) do A.sources[name]=Synth.build(v) end
 A.sources.prop=A.sources.hit:clone()
end
function A.stopAll()
 A.propUntil=0
 for _,source in pairs(A.sources) do source:stop() end
end
function A.play(name,volume,pitch)
 if A.muted then return end
 if name=='prop' then
  local now=love.timer.getTime()
  if now<(A.propUntil or 0) then return end
  A.propUntil=now+.12
 end
 local s=A.sources[name]; if s then s:stop();s:setVolume(volume or 1);s:setPitch(pitch or 1);s:play() end
end
return A
