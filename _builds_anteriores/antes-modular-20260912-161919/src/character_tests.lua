local T={}
function T.run(Game,Audio,View,check,snap)
 local function fresh(side)
  local s=Game.new(Audio);s:reset();s.stage='test';s.player.hidden=false;s.player.weaponPose=nil;s.dog.hidden=false;s.save=function()end
  s.player.x=300;s.player.y=235;s.dog.x=300+(side or 1)*33;s.dog.y=241;return s
 end
 local function tick(s,n,input) for i=1,n do s:update(1/60,input or {x=0,y=0}) end end
 local s=fresh();s:key('e');check(s.player.pet~=nil,'E starts full pet animation')
 local dx=s.dog.x;tick(s,1);check(math.abs(s.dog.x-dx)<1.1,'Moro approaches hand without teleporting')
 tick(s,65);local t=s.player.pet.t;s:key('e');check(s.player.pet.t==t,'repeated E does not restart petting')
 check(s.dog.petSquint and s.player.petBend>5,'Moro relaxes while farmer bends down');snap(s,'pet-right')
 tick(s,125);check(not s.player.pet and s.player.petBend==0 and not s.dog.petSquint,'petting finishes and restores poses')
 s=fresh(-1);s:key('e');tick(s,75);check(s.player.facingX==-1 and s.dog.facingX==1,'petting mirrors on left side');snap(s,'pet-left')
 tick(s,1,{x=1,y=0});check(not s.player.pet,'walking interrupts petting')
 s=fresh();s:key('e');tick(s,45);s:key('lshift');check(not s.player.pet and s.player.dashTimer>0,'dash interrupts petting immediately')
 s=fresh();s:key('e');tick(s,45);s:key('space');check(not s.player.pet and s.player.attackTimer>0,'attack interrupts petting immediately')
 s=fresh();s:key('e');tick(s,45);s.player.inv=0;s:hurt(1,0,0);check(not s.player.pet,'damage interrupts petting')
 s=fresh();s.dog.x=450;s:key('e');check(not s.player.pet,'petting requires nearby dog')
 s=fresh();s.player.bloodLevel=10;s:reset();check((s.player.bloodLevel or 0)==0,'new run clears blood from clothes')
 local A=require('src.actors');local P=require('src.petting');local g=love.graphics
 local c=g.newCanvas(640,360);g.push('all');g.setCanvas(c);g.clear(.055,.075,.075);g.setColor(1,1,1);g.print('CAMPESINO Y MORO - DETALLE',18,12)
 for i,dir in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
  local z=fresh();z.player.x=0;z.player.y=0;z.player.facingX=dir[1];z.player.facingY=dir[2];z.player.bloodLevel=i==4 and 8 or 0
  z.dog.x=0;z.dog.y=26;z.dog.facingX=dir[1];z.dog.facingY=dir[2];z.dog.behavior='happy'
  g.push();g.translate(80+(i-1)*157,160);g.scale(2.6);A.player(z.player,1);A.dog(z.dog,1);g.pop()
 end
 local z=fresh();z:key('e');tick(z,80);g.push();g.translate(-575,-430);g.scale(3);A.player(z.player,z.time);A.dog(z.dog,z.time);P.draw(z,A);g.pop()
 g.setCanvas();g.pop();c:release()
end
return T
