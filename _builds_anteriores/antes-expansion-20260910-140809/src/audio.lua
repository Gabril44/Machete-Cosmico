local A={sources={},muted=false}
function A.load()
 local specs={hit={95,.10},swing={280,.08},dash={430,.12},hurt={66,.22},rage={150,.55},bark={180,.16},wave={180,.65},pickup={680,.15}}
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
   if name=='hit' or name=='hurt' then s=s*.45+(love.math.random()*2-1)*.55 end
   d:setSample(i,s*env*.22)
  end
  A.sources[name]=love.audio.newSource(d,'static')
 end
end
function A.play(name)
 if A.muted then return end
 local s=A.sources[name]; if s then s:stop(); s:play() end
end
return A
