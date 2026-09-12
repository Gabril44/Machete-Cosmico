local T={}
function T.run(Game,Audio,View,check,snap)
 local W=require('src.world');local C=require('src.companion');local Debug=require('src.debug_panel')
 local function fresh() local s=Game.new(Audio);s:reset();require('src.cinema').finish(s);s.stage='sandbox';s.player.x=300;s.player.y=220;s.dog.x=276;s.dog.y=230;s.debugUsed=true;return s end
 local function tick(s,n,input) for i=1,n do s:update(1/60,input or {x=0,y=0}) end end
 local s=fresh();local p=s.player;local e=s:spawnEnemy('brute');e.x=335;e.y=220;e.stun=9;s.props={}
 s:key('q');tick(s,10);check(e.hp==7 and not p:isAttackActive(),'heavy attack windup cannot damage')
 tick(s,7);check(e.hp==4,'heavy attack damages after visible windup');snap(s,'heavy-impact')
 s=fresh();p=s.player;p:attack(false);tick(s,9);p:attack(false);tick(s,8);check(p.combo==2 and p.swing==2,'buffered light input chains second cut')
 local angle2=p:bladeAngle();p.attackCooldown=0;p:attack(false);check(p.combo==3 and p.damage==2 and p:bladeAngle()~=angle2,'third cut has different animation and damage')
 s=fresh();s.props={{kind='crate',x=400,y=220,hp=2,radius=12,solid=true}};p=s.player;p.x=320;e=s:spawnEnemy('brute');e.x=360;e.y=220;e.stun=4
 s:key('q');tick(s,42);check(s.props[1].broken and e.hp<=2,'machete knockback smashes enemy into crate');snap(s,'crate-smash')
 check(#s.drops==1,'broken crate drops healing mate')
 s=fresh();local crate=s.props[1];p=s.player;p.x=crate.x-15;p.y=crate.y;W.resolve(s,p,false);check(math.abs(p.x-crate.x)>=19,'intact crates block walking')
 local corn;for _,o in ipairs(s.props) do if o.kind=='corn' then corn=o;break end end
 W.breakProp(s,corn,1);check(corn.broken,'corn is destructible')
 s=fresh();e=s:spawnEnemy('looter');local sack;for _,o in ipairs(s.props) do if o.kind=='sack' then sack=o;break end end;e.x=sack.x;e.y=sack.y
 tick(s,50);check(e.carrying and sack.stolen,'looter visibly steals potato sack');snap(s,'potato-thief')
 e.hp=0;tick(s,2);check(not sack.stolen and s.score>=300,'killing looter recovers potatoes and bonus')
 s=fresh();e=s:spawnEnemy('looter');e.carrying=true;e.x=30;e.y=221;tick(s,12);check(#s.enemies==0 and s.kills==0,'escaped looter is removed without kill reward')
 s=fresh();e=s:spawnEnemy('gunner');e.x=440;e.y=220;e.cool=0;tick(s,1);check(e.wind>0 and #s.shots==0,'gunner announces shot before firing')
 s.player.y=300;tick(s,29);check(#s.shots==1 and math.abs(s.shots[1].vy)<1,'gunner aim locks during warning')
 s=fresh();e=s:spawnEnemy('brute');e.x=319;e.y=220;e.cool=0;tick(s,1);check(e.wind>.6,'brute has longer readable windup')
 s=fresh();C.pet(s);check(s.dog.behavior=='happy','petting produces happy reaction');snap(s,'moro-happy')
 local seen={};for i=1,1100 do s:update(1/60,{x=0,y=0});seen[s.dog.behavior]=true end
 check(seen.sniff and seen.circle and seen.look and seen.ahead,'Moro cycles sniffing circling watching and exploring')
 s=fresh();s:key('r');check(s.dog.behavior=='fetch' and s.dog.stick,'throwing stick starts fetch')
 local returned=false;for i=1,480 do s:update(1/60,{x=0,y=0});if (s.dog.affection or 0)>0 and not s.dog.stick then returned=true;break end end
 check(returned,'Moro brings stick back');snap(s,'moro-fetch-return')
 s=fresh();s.stage='travel';s.gateOpen=true;s.wave=2;s.player.x=588;s.player.y=225;tick(s,180,{x=1,y=0})
 check(s.region=='field' and s.stage=='fieldintro' and #s.cows==3 and s.farmCows==s.cows,'walking through east gate loads field and preserves cows')
 tick(s,185);check(s.wave==3 and s.stage=='wave','field arrival starts final wave');snap(s,'field-battle')
 s.dog.behavior='happy';s.dog.hasStick=true;s.dog.stick={x=100,y=100};s.dog.hop=3;require('src.cinema').beginEnding(s,{x=320,y=180,kind='boss'});check(s.dog.behavior=='watch' and not s.dog.stick and not s.dog.hasStick and s.dog.hop==0,'ending clears playful Moro state')
 local d=Debug.new();for _,id in ipairs({'gate','field','props','looter'}) do d:scene(s,id);check(s.debugUsed and s.state=='play','expansion debug loads '..id) end
 d:scene(s,'boss');check(s.region=='field','debug boss is in new arena');snap(s,'field-boss')
 d.open=true;d.tab=3;d.selected=1;snap(s,'debug-expansion',d)
 -- Short deterministic playthrough using actual attack/movement input, with safety health only.
 d:scene(s,'combat');s.debugGod=true;local killed=s.kills
 for frame=1,1500 do
  local target=s.enemies[1];if not target then break end
  local dx,dy=target.x-s.player.x,target.y-s.player.y;local length=math.sqrt(dx*dx+dy*dy)
  if s.player.attackTimer<=0 then s.player.facingX=dx/math.max(1,length);s.player.facingY=dy/math.max(1,length) end
  if length<48 and s.player.attackCooldown<=0 then s:key('q') end
  s:update(1/60,length>34 and {x=dx,y=dy} or {x=0,y=0})
 end
 check(s.kills>killed,'combat can be played through actual movement and attacks')
end
return T
