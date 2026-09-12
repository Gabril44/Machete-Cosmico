local T={}
function T.run(Game,Audio,View)
 local function write(name,data) local f=assert(io.open(love.filesystem.getSource()..'/test-'..name,'wb'));f:write(data);f:close() end
 Audio.muted=true;love.math.setRandomSeed(18)
 local checks={};local function check(v,name) assert(v,name);checks[#checks+1]='PASS '..name end
 local function fresh() local s=Game.new(Audio);s:reset();s.stage='tutorial';s.player.hidden=false;s.player.weaponPose=nil;s.dog.hidden=false;s.save=function()end;return s end
 local function tick(s,n,input) for i=1,n do s:update(1/60,input or {x=0,y=0}) end end
 local function snap(s,name,panel)
  local c=love.graphics.newCanvas(640,360);love.graphics.setCanvas(c);love.graphics.clear();View.draw(s);if panel then panel:draw(s) end;love.graphics.setCanvas();write(name..'.png',c:newImageData():encode('png'):getString())
 end
 local s=fresh();s.state='menu';snap(s,'menu');s:key('return');check(s.stage=='intro','menu starts cinematic')
 tick(s,250);snap(s,'intro-walk');s:key('escape');local paused=s.stageTime;tick(s,90);check(s.stageTime==paused,'cinematic pause freezes timeline');s:key('escape')
 tick(s,240);check(s.player.weaponPose=='drawing','machete drawn after walking');snap(s,'intro-draw');tick(s,370);snap(s,'intro-eyes');tick(s,240);check(s.stage=='tutorial','intro returns control')
 s:key('e');check(s.pet,'pet dog interaction')
 tick(s,70,{x=-1,y=0});s.player.x=180;s.player.y=268;s.player.facingX=1;s.player.facingY=0;s:key('q');tick(s,5)
 check(s.cut>3 and s.stage=='tutorial','more grass required before invasion')
 for _,x in ipairs({210,278,305,376,401}) do s.player.x=x;s.player.y=268;s.player.attackCooldown=0;s:key('q');tick(s,22) end
 check(s.cut>=18,'eighteen weeds can be cut');tick(s,220);check(s.wave==1,'extended tutorial advances into invasion')
 local Dog=require('src.dog');local dog=Dog.new(200,200)
 Dog.move(dog,{x=100,y=200},100,.1);check(dog.facingX==-1,'dog turns left');Dog.move(dog,{x=300,y=200},100,.1);check(dog.facingX==1,'dog turns right')
 Dog.move(dog,{x=dog.x,y=100},100,.1);check(dog.facingY<-.75,'dog turns upward');Dog.move(dog,{x=dog.x,y=300},100,.1);check(dog.facingY>.75,'dog turns downward')
 s=fresh();s.stage='intro';s.stageTime=2;s:key('return');check(s.stage=='tutorial','intro skip returns control')
 s=fresh();s.stage='test';s.player.x=300;s.player.y=200;local e=s:spawnEnemy('brute');e.x=328;e.y=200;e.stun=10
 s:key('space');tick(s,2);local hp=e.hp;tick(s,5);check(e.hp==hp,'one hit per swing');check(s.player.rage>0,'hits generate rage')
 s.player.attackCooldown=0;s:key('space');s.player.attackCooldown=0;s:key('space');check(s.player.combo==3 and s.player.damage==2,'three hit combo finisher')
 s.player.rage=100;s:key('f');check(s.player.berserk,'berserk activates');s.enemies={};tick(s,400);check(not s.player.berserk,'berserk expires')
 s.player.inv=0;s:hurt(10,0,0);check(s.player.hp==90,'player takes damage');s:hurt(10,0,0);check(s.player.hp==90,'damage invulnerability')
 s.player.inv=0;s:key('lshift');s:hurt(10,0,0);check(s.player.hp==90,'dash invulnerability')
 s=fresh();s.stage='test';e=s:spawnEnemy('thief');e.x=s.cows[1].x;e.y=s.cows[1].y;tick(s,180);check(s.cows[1].progress>2,'captor abduction progress');s.enemies={};tick(s,200);check(s.cows[1].progress<.5,'removing captor rescues cow')
 e=s:spawnEnemy('thief');e.x=s.cows[1].x;e.y=s.cows[1].y;tick(s,600);check(s.cows[1].lost and s.lost==1,'abduction completes')
 s=fresh();s.stage='test';e=s:spawnEnemy('gunner');e.x=400;e.y=200;tick(s,70);check(#s.shots>0,'gunner fires projectiles')
 s=fresh();s.stage='boss';e=s:spawnEnemy('boss');tick(s,62);check(e.wind>0,'boss telegraphs attack');s.player.x=500;tick(s,65);check(#s.shots>0,'boss radial burst');snap(s,'boss')
 local Boss=require('src.boss')
 s=fresh();s.stage='boss';e=s:spawnEnemy('boss');e.x=200;e.y=200;e.cool=0;e.attackCount=2;s.player.x=340;s.player.y=200
 Boss.update(s,e,s.player,1/60);check(e.attackKind=='charge' and e.wind>0,'third attack telegraphs charge');snap(s,'boss-charge')
 local aim=e.dy;s.player.y=290;Boss.update(s,e,s.player,.9);check(e.dy==aim and e.charge>0,'charge aim locks before dodge')
 for i=1,31 do Boss.update(s,e,s.player,1/60) end
 check(s.player.hp==100 and e.recover>0,'sidestep avoids charge and boss recovers');check(s.dog.barkCount==1,'Moro barks once on recovery');snap(s,'moro-warning')
 e.x=200;e.y=200;e.charge=.48;e.recover=0;e.dx=1;e.dy=0;s.player.x=300;s.player.y=200;s.player.inv=0
 Boss.update(s,e,s.player,.3);check(s.player.hp==77,'charge swept collision damages player')
 e.x=200;e.y=200;e.charge=.48;e.recover=0;s.player.hp=100;s.player.inv=.24
 Boss.update(s,e,s.player,.3);check(s.player.hp==100,'dash invulnerability blocks charge')
 e.charge=0;e.recover=0;e.wind=0;e.cool=0;Boss.update(s,e,s.player,1/60);check(e.attackKind=='pulse','normal power resumes after charge')
 s=fresh();s:beginWave(2);tick(s,330);s.player.rage=100;s:key('f');s.player:attack(true);snap(s,'combat')
 s=fresh();s.stage='test';s.player.inv=0;s:hurt(200,0,0);check(s.state=='dead','death state');s:key('r');check(s.state=='play' and s.player.hp==100,'restart resets')
 -- Traverse the actual wave director using deterministic enemy clearing.
 s=fresh();s:beginWave(1);local frames=0
 while s.stage~='boss' and frames<15000 do
  for _,a in ipairs(s.enemies) do a.hp=0 end
  s.player.inv=1;s:update(1/60,{x=0,y=0});frames=frames+1
 end
 check(s.stage=='boss' and s.wave==3,'all three waves lead to boss')
 local px,py=s.player.x,s.player.y;local dx,dy=s.dog.x,s.dog.y
 s.boss.hp=0;tick(s,2);check(s.stage=='ending' and s.defeatedBoss,'boss defeat starts visible death sequence')
 check(s.player.x==px and s.player.y==py and s.dog.x==dx and s.dog.y==dy,'ending preserves actor positions')
 tick(s,120);check(s.endingScene.beam==0 and not s.dog.hidden,'death occurs before abduction');snap(s,'boss-death')
 tick(s,180);check(s.endingScene.burst and s.endingScene.beam==0,'death burst precedes fleet light');snap(s,'fleet')
 tick(s,250);check(s.endingScene.beam>0 and s.dog.lift==0,'beam activates before dog lifts');snap(s,'beam-ignition')
 local ground=s.dog.y;local ship=s.endingScene.shipY
 tick(s,150);check(s.dog.y==ground and s.dog.lift>0 and s.endingScene.shipY==ship,'dog rises independently of stationary ship');snap(s,'abduction')
 tick(s,210);check(s.dog.hidden and s.endingScene.shipY<ship,'ship leaves after collecting dog');snap(s,'departure')
 tick(s,190);snap(s,'ending-scream');tick(s,320);snap(s,'ending-rage');tick(s,300);check(s.state=='win','ending reaches completion screen');snap(s,'complete')
 -- Bark scheduling is finite and remains a sound cue rather than an instruction.
 local calls=0;local a={play=function(name) if name=='bark' then calls=calls+1 end end};local d=Dog.new(0,0)
 Dog.bark(d,a,{x=10,y=0});for i=1,120 do Dog.update(d,1/60,a) end
 check(calls==2 and d.barkTimer==0,'Moro recovery cue is two barks without repetition')
 -- Sample full cinematics frame by frame: no teleports or floating weapon state at handoff.
 s=fresh();s:key('r');s:reset();s.save=function()end
 local lx,ly=s.player.x,s.player.y;local maxStep=0
 for i=1,1090 do s:update(1/60,{x=0,y=0});maxStep=math.max(maxStep,((s.player.x-lx)^2+(s.player.y-ly)^2)^.5);lx,ly=s.player.x,s.player.y end
 check(maxStep<2 and s.stage=='tutorial' and s.player.weaponPose==nil,'intro walk and handoff are continuous')
 require('src.debug_tests').run(Game,Audio,View,check,snap)
 write('test-results.txt',table.concat(checks,'\n')..'\n'..#checks..' checks passed\n')
end
return T


