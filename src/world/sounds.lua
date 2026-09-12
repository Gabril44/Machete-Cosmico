local noisy=require('src.effects.synthesis').noisy
local function insect(t,v,s,env)
    s=math.sin(t*6.283*4200)*math.sin(t*6.283*37)^8
    env=math.sin(math.pi*t/v[2])*.35
 return s,env
end
return {insect={3200,.16,insect},hit={95,.10,noisy}}
