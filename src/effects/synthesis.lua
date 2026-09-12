local S={}
function S.noisy(t,v,s,env) return s*.45+(love.math.random()*2-1)*.55,env end
function S.build(v)
 local d=love.sound.newSoundData(math.floor(22050*v[2]),22050,16,1)
 for i=0,d:getSampleCount()-1 do
  local t=i/22050;local env=(1-t/v[2])^2
  local f=v[1]*(1-.6*t/v[2]);local s=math.sin(t*f*6.283)
  if v[3] then s,env=v[3](t,v,s,env) end
  d:setSample(i,s*env*.22)
 end
 return love.audio.newSource(d,'static')
end
return S
