local function bark(t,v,s,env)
    -- A short voiced rasp with a hard attack, rather than the old pure-tone chirp.
    local phase=6.283*(185*t-190*t*t)
    s=(math.sin(phase)+.5*math.sin(phase*3)+.25*math.sin(phase*5))*.5+(love.math.random()*2-1)*.16
    env=math.min(1,t/.007)*(1-t/v[2])^1.4
 return s,env
end
return {bark={180,.16,bark},tag={1900,.32}}
