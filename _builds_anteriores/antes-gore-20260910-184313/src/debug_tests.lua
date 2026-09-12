local T={}
function T.run(Game,Audio,View,check,snap)
 local Debug=require('src.debug_panel');local d=Debug.new();local s=Game.new(Audio)
 d:key(s,'f1');local t=s.stageTime;d:update(s,.04);check(d.open and s.stageTime==t,'debug panel freezes underlying scene')
 check(d:key(s,'q') and s.player.attackTimer==0,'debug panel consumes gameplay input')
 for _,id in ipairs({'intro','draw','eyes','tutorial','wave1','wave2','wave3','boss','pulse','charge','death','beam','rage','cow','dog','combat'}) do
  d:scene(s,id);check(s.state=='play' and s.debugUsed,'debug scene loads: '..id);View.draw(s)
 end
 d:scene(s,'charge');d:update(s,1/60);check(s.boss.attackKind=='charge','debug charge forces correct boss attack')
 d:scene(s,'pulse');d:update(s,1/60);check(s.boss.attackKind=='pulse','debug pulse forces correct boss attack')
 d:scene(s,'tutorial');d:key(s,'f3');t=s.stageTime;d:update(s,.04);check(s.stageTime==t,'debug freeze stops simulation')
 d:key(s,'f4');d:update(s,.04);check(math.abs(s.stageTime-t-1/60)<.001,'debug single step advances exactly one frame')
 d:key(s,'f3');d:key(s,'f5');t=s.stageTime;d:update(s,.04);check(math.abs(s.stageTime-t-.01)<.001,'debug slow motion is quarter speed')
 d:key(s,'f6');s.player.inv=0;s:hurt(20,0,0);check(s.player.hp==100,'debug god mode prevents damage')
 d:key(s,'f6');s:hurt(20,0,0);check(s.player.hp==80,'debug god mode disables correctly')
 d:action(s,'heal');d:action(s,'fury');check(s.player.hp==100 and s.player.rage==100,'debug restores health and rage')
 d:scene(s,'beam');check(s.stage=='ending' and s.stageTime>8.6 and s.endingScene,'debug seek reconstructs cinematic state')
 d:key(s,'f2');check(d.last=='beam' and s.stageTime<9,'debug repeat restarts last scene')
 d:scene(s,'boss');d:action(s,'kill');d:update(s,.04);check(s.stage=='ending','debug kill starts real boss death')
 d.open=true;d.tab=1;d.selected=10;snap(s,'debug-scenes',d)
 d.tab=2;d.selected=3;snap(s,'debug-tools',d)
 local saved=0;local write=love.filesystem.write;love.filesystem.write=function() saved=saved+1;return true end
 s.debugUsed=true;s.score=s.best+1000;s:save();love.filesystem.write=write;check(saved==0,'debug runs cannot write high scores')
 d:action(s,'normal');check(not s.debugUsed and not d.god and not d.hold and d.speed==1 and s.state=='menu','normal menu clears debug state')
 d:key(s,'f1');d:key(s,'1');d:mouse(s,50,87+3*21+5,1);check(s.stage=='tutorial' and not d.open,'debug mouse activates intended scene')
end
return T
