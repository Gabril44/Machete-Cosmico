local I={device='keyboard',volume=.8,fullscreen=true,deadzone=.22,blocked={},axisHeld={}}
I.actions={'up','down','left','right','attack','heavy','dash','rage','pet','throw','pause','skip'}
I.names={up='Mover arriba',down='Mover abajo',left='Mover izquierda',right='Mover derecha',attack='Corte / remate QTE',heavy='Golpe fuerte',dash='Esquivar',rage='Furia',pet='Acariciar a Moro',throw='Lanzar palito',pause='Pausa',skip='Omitir cinemática'}
local defaults={keyboard={up='w',down='s',left='a',right='d',attack='space',heavy='q',dash='lshift',rage='f',pet='e',throw='r',pause='escape',skip='return'},
 gamepad={up='dpup',down='dpdown',left='dpleft',right='dpright',attack='x',heavy='y',dash='a',rage='rightshoulder',pet='b',throw='leftshoulder',pause='start',skip='back'}}
I.legacy={attack='space',heavy='q',dash='lshift',rage='f',pet='e',throw='r',pause='escape',skip='return'}
function I.resetBindings(device)
 I[device]={};for action,button in pairs(defaults[device]) do I[device][action]=button end
end
I.resetBindings('keyboard');I.resetBindings('gamepad')
function I.bind(device,action,button)
 local old=I[device][action]
 for other,value in pairs(I[device]) do if other~=action and value==button then I[device][other]=old end end
 I[device][action]=button
end
function I.action(device,button)
 for _,action in ipairs(I.actions) do if I[device][action]==button then return action end end
end
local labels={space='ESPACIO',escape='ESC',return_='ENTER',lshift='SHIFT IZQ',rshift='SHIFT DER',leftshoulder='LB',rightshoulder='RB',triggerleft='LT',triggerright='RT',start='START',back='BACK',dpup='CRUZ ARRIBA',dpdown='CRUZ ABAJO',dpleft='CRUZ IZQ',dpright='CRUZ DER'}
function I.label(action,device)
 device=device or I.device;local b=I[device][action]
 local label=b=='return' and 'ENTER' or labels[b] or b:upper()
 return label
end
function I.serialize()
 local lines={'version=1','volume='..I.volume,'fullscreen='..tostring(I.fullscreen),'deadzone='..I.deadzone}
 for _,device in ipairs({'keyboard','gamepad'}) do for _,action in ipairs(I.actions) do lines[#lines+1]=device..'.'..action..'='..I[device][action] end end
 return table.concat(lines,'\n')
end
function I.decode(data)
 local pending={keyboard={},gamepad={}}
 for key,value in (data or ''):gmatch('([%w_.]+)=([^\r\n]+)') do
  if key=='volume' then I.volume=math.max(0,math.min(1,tonumber(value) or .8))
  elseif key=='deadzone' then I.deadzone=math.max(.1,math.min(.5,tonumber(value) or .22))
  elseif key=='fullscreen' and (value=='true' or value=='false') then I.fullscreen=value=='true'
  else local device,action=key:match('^(%w+)%.(%w+)$')
   if pending[device] and I.names[action] and #value<=32 and not value:find('[%s=]') then pending[device][action]=value end
  end
 end
 for device,map in pairs(pending) do
  local valid,seen=true,{}
  for _,a in ipairs(I.actions) do
   local b=map[a];if not b or seen[b] then valid=false;break end;seen[b]=true
   if device=='keyboard' then
    if not pcall(love.keyboard.isDown,b) then valid=false;break end
   else
    local allowed={a=true,b=true,x=true,y=true,back=true,guide=true,start=true,leftstick=true,rightstick=true,leftshoulder=true,rightshoulder=true,dpup=true,dpdown=true,dpleft=true,dpright=true,triggerleft=true,triggerright=true}
    if not allowed[b] and not b:match('^button[1-9]%d*$') then valid=false;break end
   end
  end
  if valid then I[device]=map end
 end
end
function I.save()
 local ok,err=love.filesystem.write('controls-settings.txt',I.serialize());return ok,err
end
function I.load()
 if love.filesystem.getInfo('controls-settings.txt') then I.decode(love.filesystem.read('controls-settings.txt')) end
 love.audio.setVolume(I.volume)
 if love.window.getFullscreen()~=I.fullscreen then love.window.setFullscreen(I.fullscreen,'desktop') end
end
function I.attach(j) I.joystick=j end
function I.connected()
 if I.joystick and I.joystick:isConnected() then return I.joystick end
 I.joystick=nil
 for _,j in ipairs(love.joystick.getJoysticks()) do I.joystick=j;break end
 return I.joystick
end
function I.axes(j)
 if not j then return 0,0 end
 if j:isGamepad() then return j:getGamepadAxis('leftx'),j:getGamepadAxis('lefty') end
 local count=j:getAxisCount();return count>=1 and j:getAxis(1) or 0,count>=2 and j:getAxis(2) or 0
end
function I.stick(x,y)
 local length=math.sqrt(x*x+y*y)
 if length<=I.deadzone then return 0,0 end
 local amount=math.min(1,(length-I.deadzone)/(1-I.deadzone))
 return x/length*amount,y/length*amount
end
function I.buttonDown(j,b)
 if not j then return false end
 if b:match('^button%d+$') then return j:isDown(tonumber(b:match('%d+'))) end
 if not j:isGamepad() then return false end
 if b=='triggerleft' or b=='triggerright' then return j:getGamepadAxis(b)>.55 end
 return j:isGamepadDown(b)
end
function I.movement()
 local j=I.connected();local sx,sy=I.axes(j);sx,sy=I.stick(sx,sy)
 local function down(a)
  local k=I.keyboard[a];local b=I.gamepad[a]
  local arrowAlias=I.keyboard[a]==defaults.keyboard[a] and not I.action('keyboard',a) and love.keyboard.isDown(a)
  return (not I.blocked['keyboard:'..k] and (love.keyboard.isDown(k) or arrowAlias)) or (not I.blocked['gamepad:'..b] and I.buttonDown(j,b))
 end
 local x=(down('right') and 1 or 0)-(down('left') and 1 or 0)
 local y=(down('down') and 1 or 0)-(down('up') and 1 or 0)
 if not I.blockStick then x=x+sx;y=y+sy end
 local n=math.sqrt(x*x+y*y);if n>1 then x,y=x/n,y/n end
 return {x=x,y=y}
end
function I.update()
 local j=I.connected()
 for token in pairs(I.blocked) do
  local device,b=token:match('^(%w+):(.+)$')
  local held=device=='keyboard' and love.keyboard.isDown(b) or device=='gamepad' and I.buttonDown(j,b)
  if not held then I.blocked[token]=nil end
 end
 local x,y=I.axes(j);if math.sqrt(x*x+y*y)<=I.deadzone then I.blockStick=false elseif not I.blockStick then I.device='gamepad' end
end
return I
