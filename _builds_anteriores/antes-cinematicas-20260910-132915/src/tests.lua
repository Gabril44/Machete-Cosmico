local T={}
function T.run(Game,Audio,View)
 local function write(name,data) local f=assert(io.open(love.filesystem.getSource()..'/test-'..name,'wb'));f:write(data);f:close() end
 Audio.muted=true;love.math.setRandomSeed(18)
 local checks={};local function check(v,name) assert(v,name);checks[#checks+1]='PASS '..name end
 local function fresh() local s=Game.new(Audio);s:reset();s.save=function()end;return s end
 local function tick(s,n,input) for i=1,n do s:update(1/60,input or {x=0,y=0}) end end
 local function snap(s,name)
  local c=love.graphics.newCanvas(640,360);love.graphics.setCanvas(c);love.graphics.clear();View.draw(s);love.graphics.setCanvas();write(name..'.png',c:newImageData():encode('png'):getString())
 end
 local s=fresh();s.state='menu';snap(s,'menu');s:key('return');check(s.state=='play','menu starts tutorial')
 s:key('e');check(s.pet,'pet dog interaction')
 tick(s,70,{x=-1,y=0});s.player.x=222;s.player.y=273;s.player.facingX=1;s.player.facingY=0;s:key('q');tick(s,5)
 check(s.cut>=3,'machete cuts tutorial weeds');tick(s,220);check(s.wave==1,'tutorial advances into invasion')
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
 s=fresh();s:beginWave(2);tick(s,330);s.player.rage=100;s:key('f');s.player:attack(true);snap(s,'combat')
 s=fresh();s.stage='test';s.player.inv=0;s:hurt(200,0,0);check(s.state=='dead','death state');s:key('r');check(s.state=='play' and s.player.hp==100,'restart resets')
 -- Traverse the actual wave director using deterministic enemy clearing.
 s=fresh();s:beginWave(1);local frames=0
 while s.stage~='boss' and frames<15000 do
  for _,a in ipairs(s.enemies) do a.hp=0 end
  s.player.inv=1;s:update(1/60,{x=0,y=0});frames=frames+1
 end
 check(s.stage=='boss' and s.wave==3,'all three waves lead to boss')
 s.boss.hp=0;tick(s,2);check(s.stage=='ending','boss defeat starts dog abduction');tick(s,260);snap(s,'ending');tick(s,400);check(s.state=='win','ending reaches completion screen');snap(s,'complete')
 write('test-results.txt',table.concat(checks,'\n')..'\n'..#checks..' checks passed\n')
end
return T


