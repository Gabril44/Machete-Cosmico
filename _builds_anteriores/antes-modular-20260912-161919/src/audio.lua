local A={sources={},muted=false}
function A.load()
 local specs={insect={3200,.16},tag={1900,.32},hit={95,.10},swing={280,.08},dash={430,.12},hurt={66,.22},rage={150,.55},bark={180,.16},wave={180,.65},pickup={680,.15}}
 specs.abduction={510,.7};specs.roar={72,1.2};specs.dodge={1100,.07}
 specs.bossCharge={85,.65};specs.bossRush={65,.28}
 specs.bossGather={115,.8};specs.bossPulse={75,.38}
 for name,v in pairs(specs) do
  local d=love.sound.newSoundData(math.floor(22050*v[2]),22050,16,1)
  for i=0,d:getSampleCount()-1 do
   local t=i/22050; local env=(1-t/v[2])^2
   local f=v[1]*(1-.6*t/v[2]); local s=math.sin(t*f*6.283)
   if name=='bark' then
    -- A short voiced rasp with a hard attack, rather than the old pure-tone chirp.
    local phase=6.283*(185*t-190*t*t)
    s=(math.sin(phase)+.5*math.sin(phase*3)+.25*math.sin(phase*5))*.5+(love.math.random()*2-1)*.16
    env=math.min(1,t/.007)*(1-t/v[2])^1.4
   end
   if name=='roar' then
    local phase=6.283*(82*t-15*t*t)
    s=(math.sin(phase)+.4*math.sin(phase*2.03)+.3*math.sin(phase*4.1))*.5
    s=s*(.7+.3*math.sin(t*61))
    env=math.min(1,t/.1)*(1-t/v[2])^.6
   end
   if name=='insect' then
    s=math.sin(t*6.283*4200)*math.sin(t*6.283*37)^8
    env=math.sin(math.pi*t/v[2])*.35
   end
   if name=='bossGather' or name=='bossCharge' then
    local phase=6.283*(v[1]*t+38*t*t)
    s=math.sin(phase)*.55+math.sin(phase*2.07)*.20+math.sin(phase*3.13)*.12
    s=s*(.82+.18*math.sin(t*39))
    env=math.min(1,t/.03)*math.min(1,(v[2]-t)/.08)*(.3+.6*t/v[2])
   elseif name=='bossPulse' or name=='bossRush' then
    local phase=6.283*(v[1]*t-40*t*t)
    s=math.sin(phase)*.6+math.sin(phase*2.09)*.18+math.sin(t*6.283*227)*math.sin(t*6.283*71)*.16
    env=math.min(1,t/.006)*(1-t/v[2])^1.6
   end
   if name=='abduction' then
    local phase=6.283*(510*t+140*t*t)+2.4*math.sin(t*6.283*11)
    s=math.sin(phase)*.7+math.sin(phase*1.5)*.25
    env=math.min(1,t/.025)*(1-t/v[2])*(.35+.65*math.sin(t*6.283*3)^2)
   end
   if name=='hit' or name=='hurt' then s=s*.45+(love.math.random()*2-1)*.55 end
   d:setSample(i,s*env*.22)
  end
  A.sources[name]=love.audio.newSource(d,'static')
 end
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
