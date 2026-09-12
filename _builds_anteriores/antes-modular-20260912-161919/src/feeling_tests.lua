local T={}
function T.run(Game,Audio,View,check,snap)
 local function fresh()
  local s=Game.new(Audio);s:reset();s.stage='sandbox';s.player.hidden=false;s.player.weaponPose=nil;s.dog.hidden=false;s.player.x=300;s.player.y=235;s.dog.x=325;s.dog.y=241;s.save=function()end;return s
 end
 local function tick(s,n) for i=1,n do s:update(1/60,{x=0,y=0}) end end
 local s=fresh();s.player.hp=25;tick(s,10);check(s.dog.behavior=='worried','Moro worries at low health')
 s.player.hp=100;s.dog.behaviorTime=0;tick(s,10);check(s.dog.behavior~='worried','Moro resumes activities after healing')
 s=fresh();s.stage='preboss';tick(s,30);check(s.player.pet~=nil and not s.boss,'preboss affection precedes boss spawn')
 s:key('space');check(s.player.attackTimer==0,'preboss affection is protected from attack input')
 tick(s,200);check(s.stage=='boss' and s.boss and not s.player.pet,'preboss affection returns to boss gameplay')
 s=fresh();s.stage='tutorial';s.cut=0;tick(s,1);check(s.omen==0,'field begins calm')
 s.cut=18;tick(s,1);check(s.omen>=.7,'cutting grass reveals approaching shadows')
 s=fresh();local e=s:spawnEnemy('brute');e.x=325;e.y=235;e.stun=10;s.player.facingX=1;s.player.facingY=0;s:key('q');tick(s,17)
 check((e.impact or 0)>0 and e.impactSide==1,'heavy strike recoils enemy away from player')
 s=fresh();local calls={};s.audio={play=function(name) calls[name]=(calls[name] or 0)+1 end,stopAll=function()calls.stopped=(calls.stopped or 0)+1 end}
 require('src.cinema').beginEnding(s,{x=330,y=200,kind='boss',hp=0,maxHp=85,flash=0,wind=0})
 s.stageTime=14.6;tick(s,80)
 check(calls.stopped==1 and calls.tag==1 and calls.bark==1,'departure silence tag and distant bark occur once')
 check(s.player.weaponPose=='furious','loss changes farmer body posture')
 s:reset();check(s.omen==0 and not s.lastPetStarted,'restart resets emotional sequence')
 s=fresh();s.stage='rest';s.wave=2;s.stageTime=4.1;tick(s,1)
 check(s.stage=='gateopening' and not s.gateOpen,'alien arrives before gate unlocks')
 tick(s,90);check(s.gateOpen and s.gateRunner,'alien opens gate during animation')
 tick(s,70);check(s.stage=='travel' and not s.gateRunner,'gate animation returns exploration')
 s=fresh();local boss=s:spawnEnemy('boss');boss.roar=2;boss.roarClock=0
 local count=0;s.audio={play=function(name)if name=='roar' then count=count+1 end end}
 for i=1,130 do require('src.boss').update(s,boss,s.player,1/60) end
 check(count==1 and boss.roar==0 and boss.cool>0,'entry roar plays once and leaves attack windup time')
 boss.roarCooldown=0;boss.wind=0;boss.charge=0;boss.recover=0
 require('src.boss').update(s,boss,s.player,1/60)
 check(boss.roar>0,'boss repeats roar between attacks')
 s=fresh();require('src.cinema').beginEnding(s,{x=330,y=200,kind='boss',hp=0,maxHp=85,flash=0,wind=0});tick(s,125)
 check(s.endingScene.qteActive and not s.endingScene.burst,'finisher waits for input before impact')
 s:key('space');tick(s,40);check(s.endingScene.qtePressed and s.endingScene.burst,'one press completes finisher')
 s=fresh();require('src.cinema').beginEnding(s,{x=330,y=200,kind='boss',hp=0,maxHp=85,flash=0,wind=0});tick(s,310)
 tick(s,600)
 check(s.endingScene.qteActive and not s.endingScene.qteDone and not s.endingScene.burst and s.player.finishWaiting,'finisher keeps waiting without input')
 s:key('space');tick(s,40)
 check(s.endingScene.burst and not s.player.finishWaiting,'finisher resumes after delayed press')
end
return T
