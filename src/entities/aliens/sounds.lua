local function roar(t,v,s,env)
    -- Midrange harmonics keep the voice audible on small speakers.
    local phase=6.283*(125*t-18*t*t)+.65*math.sin(t*6.283*17)
    local voice=math.sin(phase)*.45+math.sin(phase*2.01)*.65+math.sin(phase*3.03)*.40+math.sin(phase*5.07)*.20
    local rasp=math.sin(t*6.283*713+2*math.sin(phase))* .15
    s=(voice+rasp)*(.82+.18*math.sin(t*6.283*23))
    env=math.min(1,t/.045)*math.min(1,(v[2]-t)/.24)*(.9-.25*t/v[2])
 return s,env
end
local function gather(t,v,s,env)
    local phase=6.283*(v[1]*t+38*t*t)
    s=math.sin(phase)*.45+math.sin(phase*2.07)*.45+math.sin(phase*3.13)*.30+math.sin(phase*4.17)*.12
    s=s*(.82+.18*math.sin(t*39))
    env=math.min(1,t/.03)*math.min(1,(v[2]-t)/.035)*(.45+.55*t/v[2])
 return s,env
end
local function release(t,v,s,env)
    local phase=6.283*(v[1]*t-40*t*t)
    s=math.sin(phase)*.5+math.sin(phase*2.09)*.45+math.sin(phase*3.11)*.30+math.sin(t*6.283*227)*math.sin(t*6.283*71)*.20
    env=math.min(1,t/.008)*(1-t/v[2])^1.2
 return s,env
end
local function abduction(t,v,s,env)
    local phase=6.283*(510*t+140*t*t)+2.4*math.sin(t*6.283*11)
    s=math.sin(phase)*.7+math.sin(phase*1.5)*.25
    env=math.min(1,t/.025)*(1-t/v[2])*(.35+.65*math.sin(t*6.283*3)^2)
 return s,env
end
return {wave={180,.65},abduction={510,.7,abduction},roar={72,1.2,roar},bossCharge={85,.85,gather},bossRush={65,.38,release},bossGather={115,1,gather},bossPulse={75,.45,release}}
