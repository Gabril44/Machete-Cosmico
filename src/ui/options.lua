local I=require('src.input.controls')
local O={open=false,page='main',selected=1}
function O.show() O.open=true;O.page='main';O.selected=1;O.capture=nil;O.notice=nil end
function O.close() O.open=false;O.capture=nil;I.blockStick=true end
local function save() local ok=I.save();O.notice=ok and 'Guardado' or 'No se pudo guardar la configuración' end
function O.rows()
 if O.page~='main' then
  local rows={};for _,a in ipairs(I.actions) do rows[#rows+1]=I.names[a]..'     '..I.label(a,O.page) end
  rows[#rows+1]='Restaurar estos controles';rows[#rows+1]='Volver';return rows
 end
 return {'Volumen     '..math.floor(I.volume*100+.5)..'%','Pantalla completa     '..(I.fullscreen and 'Sí' or 'No'),'Controles de teclado','Controles de joystick','Zona muerta del stick     '..math.floor(I.deadzone*100+.5)..'%','Volver'}
end
function O.change(delta)
 if O.page~='main' then return end
 if O.selected==1 then I.volume=math.max(0,math.min(1,I.volume+delta*.05));love.audio.setVolume(I.volume);require('src.effects.audio').muted=false
 elseif O.selected==2 then
  local nextValue=not love.window.getFullscreen();local ok=love.window.setFullscreen(nextValue,'desktop')
  if not ok then O.notice='No se pudo cambiar el modo de pantalla';return end
  I.fullscreen=nextValue
 elseif O.selected==5 then I.deadzone=math.max(.1,math.min(.5,I.deadzone+delta*.05))
 else return end
 save()
end
function O.accept()
 if O.page=='main' then
  if O.selected==3 or O.selected==4 then O.page=O.selected==3 and 'keyboard' or 'gamepad';O.selected=1
  elseif O.selected==6 then O.close() else O.change(1) end
 else
  if O.selected<=#I.actions then O.capture=I.actions[O.selected];O.notice=nil
  elseif O.selected==#I.actions+1 then I.resetBindings(O.page);save()
  else O.page='main';O.selected=1 end
 end
end
function O.nav(k)
 if k=='up' then O.selected=(O.selected-2)%#O.rows()+1
 elseif k=='down' then O.selected=O.selected%#O.rows()+1
 elseif k=='left' then O.change(-1)
 elseif k=='right' then O.change(1)
 elseif k=='confirm' then O.accept()
 elseif k=='back' then if O.capture then O.capture=nil elseif O.page~='main' then O.page='main';O.selected=1 else O.close() end end
end
function O.input(device,b)
 if O.capture then
  if device=='keyboard' and b=='escape' then O.capture=nil;return end
  if device~=O.page then return end
  if device=='keyboard' and (b:match('^f%d+$') or b=='unknown') then O.notice='F1–F12 reservadas; elegí otra tecla';return end
  I.bind(device,O.capture,b);I.blocked[device..':'..b]=true;O.capture=nil;save();return
 end
 local nav=device=='keyboard' and ({up='up',down='down',left='left',right='right',['return']='confirm',space='confirm',escape='back'})[b]
  or device=='gamepad' and ({dpup='up',dpdown='down',dpleft='left',dpright='right',a='confirm',b='back',start='back',button1='confirm',button2='back'})[b]
 if nav then O.nav(nav) end
end
function O.mouse(x,y)
 if O.capture then return end
 local start=O.page=='main' and 100 or 55;local height=O.page=='main' and 28 or 18
 local row=math.floor((y-start)/height)+1
 if x>=62 and x<=578 and row>=1 and row<=#O.rows() then
  O.selected=row
  if O.page=='main' and (row==1 or row==5) then O.change(x<320 and -1 or 1) else O.accept() end
 end
end
function O.draw(V)
 local g=love.graphics;g.push('all');g.setColor(.018,.025,.03,.98);g.rectangle('fill',0,0,640,360)
 g.setFont(V.medium);g.setColor(.91,.88,.73);g.printf(O.page=='main' and 'OPCIONES' or O.page=='keyboard' and 'CONTROLES · TECLADO' or 'CONTROLES · JOYSTICK',0,20,640,'center')
 local start=O.page=='main' and 100 or 55;local height=O.page=='main' and 28 or 18
 g.setFont(V.small)
 for i,row in ipairs(O.rows()) do
  local y=start+(i-1)*height
  if i==O.selected then g.setColor(.20,.29,.25);g.rectangle('fill',62,y,516,height-2) end
  g.setColor(i==O.selected and .96 or .68,.82,.65);g.print(row,76,y+3)
 end
 g.setColor(.67,.73,.66)
 local help=O.page=='gamepad' and 'Stick izquierdo: mover · botones y gatillos reasignables' or 'Flechas / cruz: elegir · ENTER / A: aceptar · ESC / B: volver'
 g.printf(help,20,316,600,'center')
 if O.page=='gamepad' and not I.connected() then g.printf('Conectá un joystick para asignar sus botones.',20,333,600,'center')
 elseif O.notice then g.printf(O.notice,20,333,600,'center') end
 if O.capture then
  g.setColor(.02,.03,.04,.96);g.rectangle('fill',42,133,556,84);g.setColor(.95,.87,.64)
  g.printf('Asignar: '..I.names[O.capture],50,146,540,'center')
  g.printf(O.page=='keyboard' and 'Pulsá una tecla · ESC cancela' or 'Pulsá un botón o gatillo · ESC cancela',50,168,540,'center')
  g.printf(O.notice or 'Si ya estaba asignado, se intercambian las acciones.',50,191,540,'center')
 end
 g.pop()
end
return O
