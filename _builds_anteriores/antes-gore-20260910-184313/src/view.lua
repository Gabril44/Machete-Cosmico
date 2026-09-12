local Tilemap=require('src.tilemap')
local World=require('src.world')
local Actors=require('src.actors')
local Title=require('src.title')
local Cinema=require('src.cinema')
local Boss=require('src.boss')
local V={}; local g=love.graphics
local C={ink={.045,.06,.10},cream={.94,.88,.69},mint={.54,1,.71},orange={1,.51,.24},muted={.51,.62,.60}}
local function color(c,a) g.setColor(c[1],c[2],c[3],a or 1) end
local function rect(x,y,w,h,c) color(c);g.rectangle('fill',math.floor(x),math.floor(y),w,h) end
local function text(t,x,y,c,font) color(c or C.cream);g.setFont(font or V.small);g.print(t,math.floor(x),math.floor(y)) end
local function center(t,y,c,font) color(c or C.cream);g.setFont(font or V.small);g.printf(t,0,y,640,'center') end
local function shadow(x,y,w) g.setColor(.02,.04,.05,.35);g.ellipse('fill',x,y,w,4) end
local function bar(x,y,w,h,f,c) rect(x,y,w,h,{.11,.16,.19});rect(x+1,y+1,(w-2)*math.max(0,math.min(1,f)),h-2,c) end
function V.load()
 V.small=g.newFont(9);V.medium=g.newFont(13);V.title=g.newFont(43);V.big=g.newFont(24)
 V.grass={};local rng=love.math.newRandomGenerator(402)
 for i=1,1100 do V.grass[i]={rng:random(9,630),rng:random(97,320),rng:random()} end
end
local function fence(y)
 rect(15,y+4,610,2,{.38,.36,.25});rect(15,y+9,610,2,{.27,.29,.22})
 for x=15,626,23 do rect(x,y,3,16,{.49,.44,.30});rect(x+1,y,1,4,{.68,.59,.38}) end
 rect(291,y,55,16,{.24,.235,.17})
end
function V.farm(s)
 rect(0,0,1280,360,{.035,.06,.11})
 for i=1,94 do rect((i*137)%1280,(i*31)%85,1,1,{.33,.49,.57}) end
 color({.76,.86,.71});g.circle('fill',553,45,17);color({.035,.06,.11});g.circle('fill',561,40,15)
 for i=0,20 do local x=i*68;color({.075,.14,.17});g.polygon('fill',x-50,97,x+12,55+(i%3)*12,x+77,97) end
 Tilemap.draw(s.tilemap)
 fence(100);fence(311);g.push();g.translate(640,0);fence(100);fence(311);g.pop();World.field(s,V)
 -- Galpón and porch, placed above the traversable field.
 rect(225,59,145,42,{.31,.27,.22});rect(234,69,128,30,{.42,.33,.23})
 for x=235,361,8 do rect(x,69,1,28,{.30,.25,.21}) end
 color({.22,.22,.25});g.polygon('fill',215,64,236,37,356,37,380,64)
 for x=239,357,12 do rect(x,42,2,18,{.34,.32,.32}) end
 rect(282,73,30,28,{.09,.12,.13});rect(244,74,15,14,{.88,.63,.29});rect(250,74,2,14,{.35,.28,.22});rect(244,80,15,2,{.35,.28,.22})
 rect(327,80,29,5,{.20,.21,.17});text('LA QUERENCIA',259,52,C.cream)
 -- Garden beds and vegetables.
 for row=0,3 do
  rect(47,255+row*13,110,9,{.23,.20,.14})
  for col=0,8 do local x=52+col*12;local y=259+row*13;rect(x,y,2,5,{.41,.48,.24});rect(x-2,y-2,6,3,{.26,.40,.22});rect(x,y-5,2,6,{.36,.48,.23}) end
 end
 -- Tractor, hay, barrels.
 shadow(568,132,25);rect(547,111,32,17,{.43,.22,.16});rect(568,101,13,20,{.51,.29,.17});rect(571,104,7,9,{.15,.27,.29});rect(552,105,3,8,{.16,.18,.16})
 color(C.ink);g.circle('fill',550,128,8);g.circle('fill',576,128,10);color({.50,.43,.28});g.circle('fill',550,128,3);g.circle('fill',576,128,4)
 for i=0,2 do rect(62+i*19,124,16,11,{.60,.48,.25});rect(66+i*19,124,2,11,{.36,.31,.20}) end
 for _,m in ipairs(s.marks) do color({.19,.32,.15});g.ellipse('fill',m.x,m.y,10,4);rect(m.x-12,m.y+2,4,2,{.26,.4,.17}) end
 for _,w in ipairs(s.weeds) do if not w.cut then rect(w.x,w.y-7,2,9,{.52,.60,.28});rect(w.x-4,w.y-4,9,2,{.40,.49,.22});rect(w.x+3,w.y-9,2,7,{.64,.65,.32}) else rect(w.x-2,w.y,5,2,{.30,.36,.20}) end end
end
local function ufo(x,y,r,t)
 shadow(x,y+26,r)
 color({.12,.22,.29});g.ellipse('fill',x,y,r,7);color({.48,.64,.62});g.ellipse('fill',x,y-3,r,5)
 color({.27,.56,.56});g.ellipse('fill',x,y-7,r*.45,8);color({.62,1,.79});g.ellipse('fill',x-3,y-10,r*.23,3)
 for i=-2,2 do rect(x+i*r*.32-1,y,3,2,math.sin(t*4+i)>0 and C.mint or {.2,.48,.42}) end
end
local function cow(c,s)
 if c.lost then return end
 local x,y=c.x,c.y-c.progress*2;shadow(x,c.y+4,16)
 if c.progress>0 then
  color(C.mint,.12);g.polygon('fill',x-24,c.y+8,x+24,c.y+8,x+10,c.y-57,x-10,c.y-57)
  ufo(x,c.y-59,23,s.time);bar(x-20,c.y+12,40,4,c.progress/9,C.orange)
 end
 rect(x-12,y-10,24,14,C.cream);rect(x-10,y+2,3,5,{.53,.54,.43});rect(x+8,y+2,3,5,{.53,.54,.43})
 rect(x-6,y-9,7,7,{.17,.21,.21});rect(x+4,y-3,6,5,{.17,.21,.21});rect(x+10,y-12,9,10,C.cream);rect(x+13,y-5,8,4,{.70,.49,.43});rect(x+15,y-10,2,2,C.ink);rect(x+11,y-15,2,4,{.60,.51,.34})
end
local function dog(d,t) Actors.dog(d,t) end
local function player(p,t)
 if not p.weaponPose and p.bladeAngle then Actors.player(p,t);return end
 if p.hidden then return end
 local x,y=math.floor(p.x),math.floor(p.y);shadow(x,y+5,10);y=y-(p.lift or 0)
 if p.berserk then color(C.orange,.20);g.circle('fill',x,y-4,23+math.sin(t*13)*2) end
 if p.inv>0 and math.floor(t*20)%2==0 then return end
 local step=p.moving and math.sin(t*18)*2 or 0
 rect(x-6,y,5,7+step,{.15,.16,.18});rect(x+2,y,5,7-step,{.15,.16,.18})
 rect(x-7,y-13,14,15,p.berserk and {.88,.32,.16} or {.42,.54,.51});rect(x-8,y-5,16,3,{.28,.24,.18})
 rect(x-11,y-11,4,9,{.73,.50,.31});rect(x+7,y-11,4,9,{.73,.50,.31});rect(x-5,y-22,10,10,{.81,.59,.36})
 rect(x-5,y-16,10,4,{.35,.25,.18});rect(x+(p.facingX<0 and -4 or 2),y-20,2,2,C.ink)
 rect(x-13,y-25,26,5,{.72,.55,.28});rect(x-7,y-32,14,9,{.64,.45,.23});rect(x-7,y-26,14,2,{.28,.25,.19})
 local angle=math.atan2(p.facingY,p.facingX)
 if p.weaponPose then
  local side=p.facingX<0 and -1 or 1
  -- Sheath stays on the hip; the blade is drawn by the hand, never orbited around the torso.
  rect(x+side*9-2,y-3,4,20,{.23,.18,.13})
  local draw=p.weaponPose=='drawing' and (p.drawProgress or 0) or p.weaponPose=='sheathed' and 0 or 1
  local hx=x+side*(9+draw*5);local hy=y-5-draw*12
  rect(hx-2,hy,4,5,{.74,.51,.31})
  if p.weaponPose=='reach' then
   rect(x-2,y-27,4,15,{.81,.59,.36})
  else
   g.push();g.translate(hx,hy);g.rotate(p.weaponPose=='rest' and 1.1 or 1.57)
   rect(0,-2,6,4,{.37,.25,.17});if draw>0 then rect(6,-2,18*draw,4,{.81,.89,.85}) end;g.pop()
  end
  return
 end
 if p.attackTimer>0 then
  local f=1-p.attackTimer/p.attackDuration;local a=angle-1.3+f*2.6
  color(p.berserk and C.orange or C.cream,.30);g.arc('fill','pie',x,y-5,p.reach, a-.65,a,20)
  color(p.berserk and C.orange or C.cream);g.setLineWidth(2);g.arc('line','open',x,y-5,p.reach,a-.55,a,15)
  angle=a
 end
 g.push();g.translate(x+math.cos(angle)*10,y-6+math.sin(angle)*10);g.rotate(angle);rect(0,-2,8,4,{.37,.25,.17});rect(8,-2,18,4,{.81,.89,.85});rect(11,-3,14,1,{1,1,.89});g.pop()
end
local function enemy(e,t) Actors.enemy(e,t) end
function V.draw(s)
 if s.state=='menu' then Title.draw(s,V);return end
 g.push();if Cinema.active(s) then Cinema.camera(s) else g.translate(-math.floor(s.cameraX or 0),0) end;if s.shake>0 then g.translate(math.sin(s.time*110)*s.shake,math.cos(s.time*97)*s.shake*.5) end
 V.farm(s)
 Cinema.world(s,ufo,enemy)
 World.drawProps(s);World.ambience(s)
 if s.stage=='arrival' then color(C.mint,.10);g.polygon('fill',110,178,180,178,158,91,134,91);ufo(145,94,28,s.time) end
 for _,e in ipairs(s.enemies) do if e.kind=='boss' then Boss.drawTelegraph(e,V.small) end end
 local things={};for _,c in ipairs(s.cows) do things[#things+1]={y=c.y,draw=function() cow(c,s) end} end
 things[#things+1]={y=s.dog.y,draw=function() dog(s.dog,s.time) end};things[#things+1]={y=s.player.y,draw=function() player(s.player,s.time) end}
 for _,e in ipairs(s.enemies) do things[#things+1]={y=e.y,draw=function() enemy(e,s.time) end} end
 table.sort(things,function(a,b)return a.y<b.y end);for _,o in ipairs(things) do o.draw() end
 for _,d in ipairs(s.drops) do shadow(d.x,d.y+4,6);rect(d.x-4,d.y-5,8,9,{.57,.37,.19});rect(d.x-3,d.y-6,6,2,C.mint);rect(d.x+2,d.y-12,1,8,C.cream);text('+',d.x-3,d.y-3,C.mint) end
 for _,a in ipairs(s.shots) do color(C.mint,.16);g.circle('fill',a.x,a.y,7);rect(a.x-2,a.y-2,4,4,C.mint) end
 for _,a in ipairs(s.particles) do color(a.c,math.min(1,a.t*3));g.rectangle('fill',a.x,a.y,2,2) end
 g.pop()
 if Cinema.active(s) and s.state=='play' then Cinema.draw(s,V);return end
 -- Compact HUD, world remains readable.
 rect(0,0,640,34,C.ink);text('LA PRIMERA NOCHE',13,7,C.cream);text(s.player.x>640 and 'GALPÓN / 02' or 'CHACRA / 01',13,20,C.muted)
 text('VIDA',151,5,C.muted);bar(180,6,101,7,s.player.hp/100,C.orange)
 text('FURIA',151,19,C.muted);bar(180,20,101,7,s.player.berserk and s.player.berserkTimer/6 or s.player.rage/100,C.mint)
 text(s.player.rage>=100 and '[F] ¡BERSERK!' or 'DASH',296,6,s.player.rage>=100 and C.mint or C.muted);bar(296,22,66,4,1-s.player.dashCooldown/.72,C.cream)
 text('VACAS '..(3-s.lost)..'/3',394,7,C.cream);text('PUNTOS '..string.format('%05d',s.score),509,7,C.mint)
 text(s.stage=='boss' and 'MINI JEFE' or s.wave>0 and ('OLEADA '..s.wave..'/3') or 'ANTES DEL DESASTRE',394,20,C.muted);text('M / '..(s.audio.muted and 'SIN SONIDO' or 'SONIDO'),509,20,C.muted)
 rect(0,328,640,32,C.ink);text('WASD mover   ESPACIO corte   Q fuerte   SHIFT dash   F furia',12,337,C.cream);text('ESC pausa',565,337,C.muted)
 if s.stage=='tutorial' then
  rect(12,42,204,49,C.ink);text('UNA NOCHE CUALQUIERA',21,48,C.orange)
  text((s.walked>1 and '[OK]' or '[  ]')..' Caminá por la chacra',21,61,C.cream)
  text((s.cut>=s.grassGoal and '[OK]' or '[  ]')..' Cortá '..s.grassGoal..' yuyos ('..math.min(s.grassGoal,s.cut)..'/'..s.grassGoal..')',21,73,C.cream)
  rect(384,43,242,33,C.ink);text((s.pet and '[OK]' or '[E]')..' Acariciá a Moro, tu perro',394,50,C.mint);text('Acercate a él. Siempre te acompaña.',394,63,C.muted)
  text('YUYOS',205,302,C.cream);text('R · tirarle un palito a Moro',384,80,C.muted)
 elseif s.stage=='travel' then
  text('Seguí a Moro hacia el portón del este >',15,43,C.mint)
 elseif s.stage=='fieldintro' then text('EL MAIZAL / EL GALPÓN',15,43,C.mint,V.medium)
 elseif s.stage=='wave' then
  text('Eliminá '..(#s.enemies+s.queue)..' invasores',15,43,C.cream)
  text(s.region=='field' and 'No les dejes vaciar el galpón.' or 'Cortá a los captores para frenar los rayos.',15,55,C.muted)
 elseif s.stage=='boss' and s.boss then
  rect(175,38,290,32,C.ink);center('INSPECTOR DE GANADO',42,C.cream,V.medium);bar(180,60,280,6,s.boss.hp/s.boss.maxHp,{.69,.44,.91})
 end
 if s.combo>1 then text(s.combo..' IMPACTOS',502,291,C.orange,V.medium) end
 if s.messageTime>0 and s.state=='play' then
  rect(40,306,560,17,C.ink);center(s.message,309,C.cream)
 end
 if s.state=='menu' then
  color(C.ink,.88);g.rectangle('fill',0,0,640,360)
  text('NAUOXO / DEMO JUGABLE',41,33,C.mint)
  text('MACHETE',38,73,C.cream,V.title);text('CÓSMICO',38,115,C.orange,V.title)
  text('Un campesino. Un perro. Una invasión muy inoportuna.',42,177,C.cream)
  text('Defendé la chacra. Cuidá a los tuyos.',42,195,C.muted,V.medium)
  rect(42,241,215,31,C.orange);text('ENTER  /  EMPEZAR LA NOCHE',55,250,C.ink)
  text('Combo de 3 cortes · Dash invulnerable · Furia',42,290,C.muted)
  text('F11 pantalla completa    M sonido',42,307,C.muted)
  g.push();g.translate(468,234);g.scale(3);local p={x=0,y=0,facingX=1,facingY=0,inv=0,attackTimer=0};player(p,s.time);dog({x=24,y=3},s.time);g.pop()
 elseif s.state=='pause' or s.state=='dead' or s.state=='win' then
  color(C.ink,.91);g.rectangle('fill',0,0,640,360)
  if s.state=='pause' then center('UN MATE Y SEGUIMOS.',123,C.cream,V.big);center('ESC para volver a la chacra',180,C.mint,V.medium)
  elseif s.state=='dead' then center('TE PASARON POR ARRIBA.',109,C.orange,V.big);center('La chacra necesita otro intento.',158,C.cream,V.medium);center('ENTER / R para volver a empezar',234,C.mint,V.medium)
  else center('MACHETE CÓSMICO',83,C.orange,V.title);center('Se llevaron al perro equivocado.',150,C.cream,V.big);center('Fin de la demo / La búsqueda de Moro recién empieza.',189,C.muted);center('ENTER / R para jugar de nuevo',272,C.mint,V.medium) end
  if s.state~='pause' then center('PUNTOS '..s.score..'   /   VACAS A SALVO '..(3-s.lost)..'/3   /   RÉCORD '..s.best,212,C.cream) end
 end
end
return V
