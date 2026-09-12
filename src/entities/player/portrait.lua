local P={}
local PlayerLines=require('src.entities.player.dialogue')
local H=require('src.scenes.helpers')
local clamp,lerp,ease,rect,subtitle,walk=H.clamp,H.lerp,H.ease,H.rect,H.subtitle,H.walk
local g=love.graphics
function P.draw(s,V)
 local t=s.stageTime-8;local rage=clamp((t-12)/4);local scream=t<11.8
 rect(0,0,640,360,.015+rage*.06,.018,.025)
 -- Original pixel portrait: the same work shirt, beard and old hat.
 g.push();g.translate(320+math.sin(t*55)*rage,185);g.scale(2.7+rage*.45)
 rect(-65,39,130,50,.27,.37,.35);rect(-38,39,8,48,.23,.18,.12);rect(30,39,8,48,.23,.18,.12);rect(-38,45,8,7,.64,.50,.26);rect(30,45,8,7,.64,.50,.26);rect(-23,15,46,40,.50,.31,.19)
 rect(-39,-43,78,81,.70,.46,.28);rect(-34,-40,60,71,.82,.57,.35)
 rect(-42,-21,7,24,.54,.34,.22);rect(35,-21,7,24,.54,.34,.22)
 rect(-33,15,66,25,.25,.18,.14);rect(-25,25,50,15,.23,.17,.14)
 rect(-64,-54,128,12,.65,.46,.23);rect(-38,-81,76,31,.60,.40,.20);rect(-38,-58,76,7,.24,.20,.15);rect(52,-47,12,5,.015,.018,.025);rect(-34,-78,55,3,.73,.52,.27);rect(18,-68,5,3,.42,.29,.15)
 rect(-31,-18,24,8,.95,.88,.72);rect(8,-18,24,8,.95,.88,.72)
 rect(-19,-18,5,8,.06,.07,.08);rect(15,-18,5,8,.06,.07,.08)
 g.setColor(.13,.11,.10);g.setLineWidth(4)
 g.line(-32,-24-rage*4,-8,-24+rage*7);g.line(8,-24+rage*7,32,-24-rage*4)
 rect(-3,-12,8,23,.65,.39,.23)
 if scream then rect(-16,13,32,21,.075,.035,.035);rect(-14,14,28,5,.97,.89,.71);rect(-10,28,20,4,.61,.23,.20)
 else rect(-19,18,38,7,.90,.80,.61);rect(-18,21,36,1,.22,.15,.13) end
 if rage<.6 then rect(-25,-7,2,22,.54,.74,.77,.7*(1-rage)) end
 rect(-38,-39,76,22,.045,.035,.035,rage*.66)
 -- Fixed splashes follow the face and cloth, leaving the eyes and mouth readable.
 local marks={{-29,-5,4,7},{22,0,5,8},{-18,-36,6,3},{-47,53,7,5},
  {29,-34,4,6},{-28,22,3,6},{12,43,5,7},{42,64,6,4},{25,25,4,7}}
 for i=1,math.min(#marks,s.player.bloodLevel or 0) do
  local m=marks[i];local x,y,w,h=m[1],m[2],m[3],m[4]
  local cloth=y>=43
  local light=(x>20 and .78 or 1)*(y< -18 and (1-rage*.55) or 1)
  -- A dark lower edge, olive body and small wet highlight give the stain volume.
  rect(x,y+1,w,h,.12*light,.20*light,.075*light,.9)
  rect(x+1,y,w-2,h,.30*light,.43*light,.12*light)
  rect(x,y+2,w,h-3,.34*light,.48*light,.15*light)
  rect(x+1,y+1,math.max(1,w-3),1,.54*light,.64*light,.27*light)
  if not cloth then
   rect(x+1,y+1,1,2,.72*light,.77*light,.43*light)
   rect(x+w-2,y+h-1,1,2+i%3,.24*light,.35*light,.10*light)
  else
   rect(x+2,y+h-2,1,2,.20,.30,.10,.7)
  end
  rect(x-2,y+2,1,2,.28*light,.39*light,.12*light,.8)
 end
 g.pop()
 if rage>0 then
  for i=1,22 do local x=(i*83)%640;local y=(i*43+s.time*40)%360;rect(x,y,1,15+rage*30,.9,.23,.10,rage*.20) end
 end
 if scream then subtitle(PlayerLines.scream,V.big,292)
 elseif t<15 then subtitle(PlayerLines.silence,V.big,296)
 else subtitle(PlayerLines.promise,V.big,292) end
end

return P
