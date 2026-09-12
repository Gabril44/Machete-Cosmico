local T={}
function T.run(Game,Audio,View,check,snap)
 local Cinema=require('src.cinema');local W=require('src.world');local Debug=require('src.debug_panel')
 local s=Game.new(Audio);s:reset();Cinema.finish(s);s.stage='sandbox';s.debugUsed=true;s.player.x=600;s.player.y=232
 local function tick(n,input) for i=1,n do s:update(1/60,input or {x=0,y=0}) end end
 tick(50,{x=1,y=0});check(s.player.x<=612,'closed gate blocks access to extension')
 snap(s,'continuous-locked')
 s.stage='travel';s.gateOpen=true;s.wave=2
 local cows,props,weeds=s.cows,s.props,s.weeds;props[1].broken=true;weeds[1].cut=true
 local maxStep,maxCamera=0,0;local px,cx=s.player.x,s.cameraX
 for i=1,120 do
  s:update(1/60,{x=1,y=0});maxStep=math.max(maxStep,math.abs(s.player.x-px));maxCamera=math.max(maxCamera,math.abs(s.cameraX-cx));px,cx=s.player.x,s.cameraX
  if i==50 then snap(s,'continuous-midpoint') end
 end
 check(s.player.x>800 and s.stage=='travel','crossing gate does not switch or restart scene')
 tick(65,{x=1,y=0})
 check(s.fieldStarted and s.stage=='fieldintro' and s.player.x>900,'arena triggers only on arrival')
 check(s.cows==cows and s.props==props and s.weeds==weeds and props[1].broken and weeds[1].cut,'world objects and animals persist across crossing')
 check(maxStep<2 and maxCamera<2 and s.transition==0,'walking and camera stay continuous without fade')
 snap(s,'continuous-arrival')
 s.stage='sandbox';tick(360,{x=-1,y=0});check(s.player.x<330 and s.props==props and s.cows==cows,'player can return to unchanged farm')
 local d=Debug.new();d:scene(s,'charge');tick(1);check(s.boss.x>640 and s.boss.ex>640,'boss charge uses extended-world coordinates')
 tick(65,{x=0,y=1});check(s.boss.x>640,'boss charge does not snap back to farm')
 -- Cached tiles must be built in local coordinates regardless of camera transforms.
 local map=require('src.tilemap').new();local g=love.graphics;g.push();g.translate(-620,0);require('src.tilemap').draw(map);g.pop()
 local data=map.canvas:newImageData();local _,_,_,a=data:getPixel(1100,150)
 check(a==1,'tile cache covers far end independent of camera')
end
return T
