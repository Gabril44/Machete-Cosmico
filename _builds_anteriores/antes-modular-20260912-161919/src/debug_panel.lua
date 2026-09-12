local Petting=require('src.petting')
local World=require('src.world')
local Cinema=require('src.cinema')
local Dog=require('src.dog')
local Debug={};Debug.__index=Debug
local scenes={
 {'intro','Salida de la casa','Intro completa, desde la puerta.'},
 {'draw','Desenvainado','Intro desde antes de sacar el machete.'},
 {'eyes','Ojos en la oscuridad','Intro desde la reacción de Moro.'},
 {'tutorial','Pasto y Moro','Tutorial listo para caminar, cortar y acariciar.'},
 {'wave1','Oleada 1','Primera invasión con vida completa.'},
 {'wave2','Oleada 2','Incluye tiradores de plasma.'},
 {'wave3','Oleada 3','Incluye enemigos pesados.'},
 {'boss','Jefe completo','Inspector con toda la vida.'},
 {'pulse','Poder del jefe','Prepara inmediatamente el ataque circular.'},
 {'charge','Embestida y ladridos','Carga, recuperación y aviso de Moro.'},
 {'death','Muerte del Inspector','Final completo desde el golpe mortal.'},
 {'beam','Rayo y abducción','Final desde antes del encendido de la nave.'},
 {'rage','Grito y furia','Primer plano final desde el grito.'},
 {'cow','Rescatar una vaca','Captor junto a la vaca; atacalo para cortar el rayo.'},
 {'dog','Giros y ladridos','Moro en la chacra, sin enemigos.'},
 {'combat','Práctica de combate','Cuatro roles de enemigo, sin oleadas nuevas.'},
}
local actions={
 {'heal','Recuperar vida','Restaura 100 de vida en la escena actual.'},
 {'fury','Llenar furia','Carga la barra; activala con F durante el juego.'},
 {'god','Invulnerabilidad','Alterna daño al jugador. También disponible con F6.'},
 {'hold','Congelar / continuar','Detiene la simulación. Atajo: F3.'},
 {'step','Avanzar un cuadro','Avanza 1/60 s y queda congelado. Atajo: F4.'},
 {'slow','Cámara lenta','Alterna velocidad normal y 0.25x. Atajo: F5.'},
 {'boxes','Ver áreas de combate','Muestra alcance, colisiones y posiciones. Atajo: F7.'},
 {'bark','Escuchar a Moro','Reproduce su aviso de dos ladridos en esta escena.'},
 {'kill','Derrotar al jefe','Inicia su muerte desde la posición actual, si está vivo.'},
 {'normal','Volver al menú normal','Desactiva todas las ayudas y empieza una partida limpia.'},
}
local expansion={{'pet','Caricia a Moro','E repite la caricia; movimiento o combate la interrumpen.'},{'gore','Gore alienígena','Aliens débiles para probar sangre y restos con el machete.'},{'field','Maizal y galpón','Llegada a la nueva zona.'},{'gate','Portón abierto','Seguí a Moro hacia el este.'},{'props','Cajones y golpes','Rompé cajones o estampá aliens contra ellos.'},{'looter','Ladrón de papas','Alcanzalo antes de que se escape con la bolsa.'},{'dog','Moro y palito','E para acariciar, R para lanzar un palito.'}}
table.insert(expansion,1,{'worried','Moro preocupado','Moro te acompaña con poca vida.'})
table.insert(expansion,2,{'farewell','Antes del jefe','Última caricia antes de enfrentar al inspector.'})
function Debug.new() return setmetatable({open=false,tab=1,selected=1,hold=false,speed=1,god=false,boxes=false,last='intro'},Debug) end
function Debug:list() return self.tab==1 and scenes or self.tab==2 and actions or expansion end
function Debug:mark(s) s.debugUsed=true end
local function ready(s)
 s:reset();Cinema.finish(s);s.player.x=300;s.player.y=235;s.dog.x=272;s.dog.y=239;s.messageTime=0
end
local function seek(s,seconds)
 local muted=s.audio.muted;s.audio.muted=true
 for i=1,math.floor(seconds*60) do if s.endingScene and s.endingScene.qteActive then s:key('space') end;s:update(1/60,{x=0,y=0}) end
 s.audio.muted=muted
end
function Debug:scene(s,id)
 self.last=id;self.open=false;self.hold=false;self.pendingStep=false
 if id=='intro' or id=='draw' or id=='eyes' then
  s:reset();self:mark(s);seek(s,id=='draw' and 7.2 or id=='eyes' and 11.8 or 0)
 else
  ready(s);self:mark(s)
  if id=='tutorial' then return
  elseif id=='gore' then s.stage='sandbox';s.player.x=330;s.player.y=232;for i,k in ipairs({'raider','brute','gunner','looter'}) do local e=s:spawnEnemy(k);e.x=360+i*22;e.y=210+(i%2)*35;e.hp=1 end
  elseif id=='worried' then s.stage='sandbox';s.player.hp=25
  elseif id=='farewell' then s.player.x=940;s.dog.x=912;World.enter(s);s.enemies={};s.queue=0;s.stage='preboss';s.stageTime=0;s.lastPetStarted=false;s.cameraX=620
  elseif id=='pet' then s.stage='sandbox';s.player.x=300;s.player.y=230;s.dog.x=325;s.dog.y=237;s.player.facingX=1;s.player.facingY=0;s:key('e')
  elseif id=='field' then s.player.x=895;s.player.y=235;s.dog.x=873;s.dog.y=239;World.enter(s);s.cameraX=575
  elseif id=='gate' then s.stage='travel';s.gateOpen=true;s.wave=2
  elseif id=='props' then s.stage='sandbox';s.player.x=330;s.player.y=194;s.player.facingX=1;s.player.facingY=0
  elseif id=='looter' then s.stage='sandbox';local e=s:spawnEnemy('looter');e.x=475;e.y=255
  elseif id:match('^wave') then if id=='wave3' then s.player.x=940;s.dog.x=912;World.enter(s);s.cameraX=620 end;s:beginWave(tonumber(id:sub(-1)))
  elseif id=='dog' then s.stage='sandbox';Dog.bark(s.dog,s.audio,s.player)
  elseif id=='cow' then
   s.stage='sandbox';s.player.x=195;s.player.y=178;s.dog.x=221;s.dog.y=186
   local e=s:spawnEnemy('thief');e.x=s.cows[1].x;e.y=s.cows[1].y;s.cows[1].progress=3
  elseif id=='combat' then
   s.stage='sandbox';for i,k in ipairs({'raider','thief','gunner','brute'}) do local e=s:spawnEnemy(k);e.x=160+i*65;e.y=150 end
  else
   World.enter(s);s.player.x=940;s.player.y=235;s.dog.x=912;s.dog.y=239;s.cameraX=620;s.stage='boss';s.wave=3;local e=s:spawnEnemy('boss');e.x=980;e.y=185
   if id=='pulse' or id=='charge' then e.cool=0;e.attackCount=id=='charge' and 2 or 0
   elseif id=='death' or id=='beam' or id=='rage' then
    e.hp=0;s:update(1/60,{x=0,y=0});seek(s,id=='beam' and 8.7 or id=='rage' and 16 or 0)
   end
  end
 end
end
function Debug:action(s,id)
 if id=='normal' then
  self.god=false;self.hold=false;self.speed=1;self.boxes=false;self.open=false;self.pendingStep=false;s:reset();s.state='menu';return
 end
 self:mark(s)
 if id=='heal' then s.player.hp=s.player.maxHp
 elseif id=='fury' then s.player.rage=100
 elseif id=='god' then self.god=not self.god;s.debugGod=self.god
 elseif id=='hold' then self.hold=not self.hold
 elseif id=='step' then self.hold=true;self.pendingStep=true;self.open=false
 elseif id=='slow' then self.speed=self.speed==1 and .25 or 1
 elseif id=='boxes' then self.boxes=not self.boxes
 elseif id=='bark' then Dog.bark(s.dog,s.audio,s.player);self.open=false
 elseif id=='kill' then if s.boss and s.boss.hp>0 and s.stage=='boss' then s.boss.hp=0;self.open=false;self.hold=false else self.notice='Primero cargá una escena con el jefe vivo.' end end
end
function Debug:key(s,k)
 if k=='f1' then self.open=not self.open;self.notice=nil;return true end
 if k=='f2' then self:scene(s,self.last);return true end
 local shortcuts={f3='hold',f4='step',f5='slow',f6='god',f7='boxes'}
 if shortcuts[k] then self:action(s,shortcuts[k]);return true end
 if not self.open then return false end
 if k=='escape' then self.open=false
 elseif k=='tab' or k=='1' or k=='2' or k=='3' then self.tab=tonumber(k) or self.tab%3+1;self.selected=1;self.notice=nil
 elseif k=='down' then self.selected=self.selected%#self:list()+1
 elseif k=='up' then self.selected=(self.selected-2)%#self:list()+1
 elseif k=='right' or k=='left' then self.selected=((self.selected-1+8)%#self:list())+1
 elseif k=='return' or k=='space' then local item=self:list()[self.selected];if self.tab~=2 then self:scene(s,item[1]) else self:action(s,item[1]) end end
 return true
end
function Debug:mouse(s,x,y,b)
 if not self.open then return false end
 if b~=1 then return true end
 if y>=51 and y<75 then self.tab=math.max(1,math.min(3,math.floor((x-38)/188)+1));self.selected=1;return true end
 if x>=38 and x<602 and y>=87 and y<255 then
  local col=x<320 and 0 or 1;local row=math.floor((y-87)/21);local index=col*8+row+1
  if self:list()[index] then self.selected=index;self:key(s,'return') end
 end
 return true
end
function Debug:update(s,dt)
 s.debugGod=self.god
 if self.god then self:mark(s) end
 if self.open then return end
 if self.pendingStep then
  self.pendingStep=false;local state=s.state
  if state=='pause' then s.state='play' end
  s:update(1/60)
  if state=='pause' and s.state=='play' then s.state='pause' end
 elseif not self.hold then s:update(dt*self.speed) end
end
function Debug:draw(s)
 local g=love.graphics;g.setFont(self.font or g.getFont())
 if not self.font then self.font=g.newFont(10);self.heading=g.newFont(16);g.setFont(self.font) end
 if self.boxes and not Cinema.active(s) then
  g.push();g.translate(-math.floor(s.cameraX or 0),0)
  g.setColor(1,.3,.5,.8);g.setLineWidth(1);g.circle('line',s.player.x,s.player.y,10)
  local p=s.player;local a=math.atan2(p.facingY,p.facingX);g.arc('line','open',p.x,p.y,p.reach or 44,a-1.72,a+1.72)
  for _,e in ipairs(s.enemies) do g.circle('line',e.x,e.y,e.radius or 9) end
  g.setColor(.4,.85,1);g.circle('line',s.dog.x,s.dog.y,10);g.pop()
 end
 if not self.open then
  g.setColor(.025,.04,.065,.88);g.rectangle('fill',3,349,430,11)
  g.setColor(.7,.8,.75);g.print(s.debugUsed and string.format('DEBUG  F1 panel / F2 repetir / F3 pausa / %.2fx%s',self.speed,self.god and ' / INVULNERABLE' or '') or 'F1 · PRUEBAS RÁPIDAS',7,349)
  if self.hold then g.setColor(1,.6,.3);g.print('CONGELADO · F4 cuadro / F3 continuar',170,36) end
  return
 end
 g.setColor(.015,.025,.045,.96);g.rectangle('fill',24,14,592,329)
 g.setColor(.65,1,.77);g.setFont(self.heading);g.print('BANCO DE PRUEBAS',39,25);g.setFont(self.font)
 g.setColor(.7,.75,.73);g.print('F1 / ESC cerrar · escena congelada mientras elegís',255,31)
 for i,label in ipairs({'1  ESCENAS','2  HERRAMIENTAS','3  EXPANSIÓN'}) do g.setColor(i==self.tab and .18 or .07,.23,.22);g.rectangle('fill',38+(i-1)*188,52,182,23);g.setColor(.94,.89,.75);g.print(label,48+(i-1)*188,58) end
 for i,item in ipairs(self:list()) do
  local x=38+math.floor((i-1)/8)*282;local y=87+((i-1)%8)*21
  if i==self.selected then g.setColor(.21,.34,.29);g.rectangle('fill',x,y,276,19) end
  g.setColor(i==self.selected and .75 or .86,i==self.selected and 1 or .87,.73);g.print(item[2],x+9,y+4)
 end
 g.setColor(.8,.86,.8);g.printf(self.notice or self:list()[self.selected][3],40,266,556)
 g.setColor(.57,.7,.67);g.print('Flechas + Enter o clic · TAB cambia pestaña · F2 repite la escena',40,291)
 g.print(string.format('%s / %s / %.1f s   Vida %d   Furia %d   Velocidad %.2fx',s.state,s.stage,s.stageTime,s.player.hp,s.player.rage,self.speed),40,307)
 g.setColor(1,.65,.36);g.print('Las partidas intervenidas con debug no guardan récord.',40,323)
end
return Debug
