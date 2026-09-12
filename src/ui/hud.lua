local AlienLines=require('src.entities.aliens.dialogue')
local PlayerLines=require('src.entities.player.dialogue')
local H={}
function H.draw(s,V)
local g=love.graphics
local P=require('src.ui.drawing').bind(V)
local C,color,rect,text,center,shadow,bar=P.C,P.color,P.rect,P.text,P.center,P.shadow,P.bar
 rect(0,0,640,34,C.ink);text('LA PRIMERA NOCHE',13,7,C.cream);text(s.player.x>640 and 'GALPÓN / 02' or 'CHACRA / 01',13,20,C.muted)
 text('VIDA',151,5,C.muted);bar(180,6,101,7,s.player.hp/100,C.orange)
 text('FURIA',151,19,C.muted);bar(180,20,101,7,s.player.berserk and s.player.berserkTimer/6 or s.player.rage/100,C.mint)
 text(s.player.rage>=100 and '[F] ¡BERSERK!' or 'DASH',296,6,s.player.rage>=100 and C.mint or C.muted);bar(296,22,66,4,1-s.player.dashCooldown/.72,C.cream)
 text('VACAS '..(3-s.lost)..'/3',394,7,C.cream);text('PUNTOS '..string.format('%05d',s.score),509,7,C.mint)
 text(s.stage=='boss' and 'MINI JEFE' or s.wave>0 and ('OLEADA '..s.wave..'/3') or 'ANTES DEL DESASTRE',394,20,C.muted);text('M / '..(s.audio.muted and 'SIN SONIDO' or 'SONIDO'),509,20,C.muted)
 local input=require('src.input.controls');local function button(a) return input.label(a) end
 local movement=input.device=='gamepad' and 'STICK' or button('up')..'/'..button('left')..'/'..button('down')..'/'..button('right')
 rect(0,328,640,32,C.ink)
 local controls=movement..' mover · '..button('attack')..' corte · '..button('heavy')..' fuerte · '..button('dash')..' dash · '..button('rage')..' furia · '..button('pause')..' pausa'
 g.push();g.setFont(V.small);local fit=math.min(1,616/V.small:getWidth(controls));g.translate(12,337);g.scale(fit);color(C.cream);g.print(controls,0,0);g.pop()
 if s.stage=='tutorial' then
  rect(12,42,204,49,C.ink);text('UNA NOCHE CUALQUIERA',21,48,C.orange)
  text((s.walked>1 and '[OK]' or '[  ]')..' Caminá por la chacra',21,61,C.cream)
  text((s.cut>=s.grassGoal and '[OK]' or '[  ]')..' Cortá '..s.grassGoal..' yuyos ('..math.min(s.grassGoal,s.cut)..'/'..s.grassGoal..')',21,73,C.cream)
  rect(384,43,242,33,C.ink);text((s.pet and '[OK]' or '['..button('pet')..']')..' Acariciá a Moro',394,50,C.mint);text('Acercate a él. Siempre te acompaña.',394,63,C.muted)
  text('YUYOS',205,302,C.cream);text(button('throw')..' · tirarle un palito a Moro',384,80,C.muted)
 elseif s.stage=='travel' then
  text('Seguí a Moro hacia el portón del este >',15,43,C.mint)
 elseif s.stage=='fieldintro' then text('EL MAIZAL / EL GALPÓN',15,43,C.mint,V.medium)
 elseif s.stage=='wave' then
  text('Eliminá '..(#s.enemies+s.queue)..' invasores',15,43,C.cream)
  text(s.region=='field' and 'No les dejes vaciar el galpón.' or 'Cortá a los captores para frenar los rayos.',15,55,C.muted)
 elseif s.stage=='boss' and s.boss then
  rect(175,38,290,32,C.ink);center(AlienLines.bossName,42,C.cream,V.medium);bar(180,60,280,6,s.boss.hp/s.boss.maxHp,{.69,.44,.91})
 end
 if s.combo>1 then text(s.combo..' IMPACTOS',502,291,C.orange,V.medium) end
 if (s.cowWarningTime or 0)>0 and s.state=='play' then
  rect(75,299,490,26,C.ink);rect(75,299,3,26,C.orange)
  center(PlayerLines.cowWarning,304,C.orange,V.medium)
 elseif s.messageTime>0 and s.state=='play' then
  rect(40,306,560,17,C.ink);center(s.message,309,C.cream)
 end
 if s.state=='pause' or s.state=='dead' or s.state=='win' then
  color(C.ink,.91);g.rectangle('fill',0,0,640,360)
  if s.state=='pause' then
   center('UN MATE Y SEGUIMOS.',123,C.cream,V.big)
   center(((s.menuChoice or 1)==1 and '> ' or '')..'CONTINUAR',180,C.mint,V.medium)
   center(((s.menuChoice or 1)==2 and '> ' or '')..'OPCIONES',223,C.mint,V.medium)
   center(input.device=='gamepad' and 'Stick / cruz elegir · A aceptar · B volver' or 'Flechas elegir · ENTER aceptar · ESC volver',280,C.muted)
  elseif s.state=='dead' then center('TE PASARON POR ARRIBA.',109,C.orange,V.big);center('La chacra necesita otro intento.',158,C.cream,V.medium);center((input.device=='gamepad' and 'A' or 'ENTER')..' para volver a empezar',234,C.mint,V.medium)
  else center('MACHETE CÓSMICO',83,C.orange,V.title);center('Se llevaron al perro equivocado.',150,C.cream,V.big);center('Fin de la demo / La búsqueda de Moro recién empieza.',189,C.muted);center((input.device=='gamepad' and 'A' or 'ENTER')..' para jugar de nuevo',272,C.mint,V.medium) end
  if s.state~='pause' then center('PUNTOS '..s.score..'   /   VACAS A SALVO '..(3-s.lost)..'/3   /   RÉCORD '..s.best,212,C.cream) end
 end
end
return H
