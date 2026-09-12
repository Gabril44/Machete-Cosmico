local T={}
function T.run(Game,Audio,View,check,snap)
 local Gore=require('src.gore');local Debug=require('src.debug_panel');local s=Game.new(Audio);local d=Debug.new();d:scene(s,'gore')
 s.debugGod=true;local p=s.player;p.facingX=1;p.facingY=0
 local e=s.enemies[1];e.x=p.x+25;e.y=p.y;e.stun=4;s:key('q')
 for i=1,20 do s:update(1/60,{x=0,y=0}) end
 check(#s.gore.organs>0 and #s.gore.drops>0,'lethal machete hit spawns alien blood and organs');snap(s,'gore-impact')
 s.enemies={};s.stage='sandbox';for i=1,180 do s:update(1/60,{x=0,y=0}) end
 check(#s.gore.drops==0 and s.gore.organs[1].settled and #s.gore.splats>0,'alien debris lands and leaves persistent splashes')
 for i=1,6 do Gore.death(s,{x=310+i*18,y=245+(i%2)*16,kind='brute'},p) end
 for i=1,150 do s:update(1/60,{x=0,y=0}) end;snap(s,'gore-ground')
 local remains=s.gore;s.stage='travel';s.gateOpen=true;s.player.x=886;s:update(1/60,{x=0,y=0});check(s.gore==remains,'gore persists across continuous map')
 for i=1,130 do Gore.death(s,{x=300,y=220,kind='raider'},p) end
 check(#s.gore.organs<=90 and #s.gore.drops<=180 and #s.gore.splats<=220,'gore collections stay bounded')
 s:reset();check(#s.gore.organs==0 and #s.gore.splats==0,'new game clears previous gore')
end
return T
