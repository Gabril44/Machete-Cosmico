local I=require('src.input.controls')
local O=require('src.ui.options')
local R={axisClock=0}
local navKeys={up='up',down='down',['return']='confirm',space='confirm',escape='back'}
local navPad={dpup='up',dpdown='down',a='confirm',b='back',start='back',button1='confirm',button2='back'}
function R.input(s,device,button)
 I.device=device
 if O.open then O.input(device,button);return end
 local action=I.action(device,button)
 if s.state=='menu' or s.state=='pause' then
  local nav=(device=='keyboard' and navKeys or navPad)[button]
  s.menuChoice=s.menuChoice or 1
  if nav=='up' or nav=='down' then s.menuChoice=3-s.menuChoice
  elseif nav=='confirm' then
   if s.menuChoice==2 then O.show() else
    I.blockStick=true
    if s.state=='menu' then s:key('return') else s:key('escape') end
   end
  elseif s.state=='pause' and (nav=='back' or action=='pause') then s:key('escape');I.blockStick=true end
  return
 end
 if s.state=='dead' or s.state=='win' then
  if (device=='keyboard' and button=='return') or (device=='gamepad' and (button=='a' or button=='button1')) then s:key('return');I.blockStick=true end
  return
 end
 if action and I.legacy[action] then s:key(I.legacy[action]);if action=='pause' then s.menuChoice=1 end
 elseif not action and device=='keyboard' and button=='m' then s:key('m') end
end
function R.update(s,dt)
 I.update();R.axisClock=math.max(0,R.axisClock-dt)
 if not O.open and s.state~='menu' and s.state~='pause' then return end
 if O.capture then return end
 local x,y=I.axes(I.connected())
 if math.abs(x)<.5 and math.abs(y)<.5 then R.axisClock=0;return end
 if R.axisClock>0 or I.blockStick then return end
 R.axisClock=.24;I.device='gamepad'
 local nav=math.abs(y)>=math.abs(x) and (y<0 and 'up' or 'down') or (x<0 and 'left' or 'right')
 if O.open then O.nav(nav) elseif nav=='up' or nav=='down' then s.menuChoice=3-(s.menuChoice or 1) end
end
function R.mouse(s,x,y)
 if O.open then O.mouse(x,y);return true end
 if s.state=='menu' then
  if x>=180 and x<=460 and y>=232 and y<=304 then s.menuChoice=y<274 and 1 or 2;R.input(s,'keyboard','return') end
  return true
 elseif s.state=='pause' then
  if x>=170 and x<=470 and y>=171 and y<=250 then s.menuChoice=y<211 and 1 or 2;R.input(s,'keyboard','return') end
  return true
 end
 return false
end
return R
