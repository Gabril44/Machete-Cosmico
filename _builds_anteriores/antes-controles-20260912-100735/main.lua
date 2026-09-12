local Debug=require('src.debug_panel')
local debugPanel=Debug.new()
local Game=require('src.game')
local View=require('src.view')
local Audio=require('src.audio')
local game,canvas,scale,ox,oy
local smoke=false
local loading,loadStep,loadingLabel,loadingDrawn=true,0,'Preparando la chacra...',false
local function loadNext()
 loadStep=loadStep+1
 if loadStep==1 then View.load();loadingLabel='Preparando sonidos...'
 elseif loadStep==2 then Audio.load();Audio.stopAll();loadingLabel='Revisando la partida...'
 elseif loadStep==3 then
  game=Game.new(Audio)
  assert(canvas:getWidth()==640 and canvas:getHeight()==360,'No se pudo preparar la imagen del juego')
  assert(View.small and View.medium,'No se pudieron cargar las fuentes')
  for _,name in ipairs({'hit','swing','dash','hurt','rage','bark','wave','pickup','tag','insect','abduction'}) do
   assert(Audio.sources[name] and Audio.sources[name]:getDuration()>0,'Falta el sonido: '..name)
  end
  assert(game.state=='menu' and #game.enemies==0 and game.cowAlarmCooldown==0,'La partida no comenzó limpia')
  Audio.stopAll();loadingLabel='Todo listo'
 else loading=false end
end
local function viewport()
 local w,h=love.graphics.getDimensions()
 local z=math.min(w/640,h/360)
 return z,(w-640*z)/2,(h-360*z)/2
end
local defaultError=love.errorhandler
function love.errorhandler(msg)
 local log=io.open(love.filesystem.getSource()..'/error-log.txt','w'); if log then log:write(tostring(msg)..'\n'..debug.traceback());log:close() end
 if love.filesystem then love.filesystem.write('error-log.txt',tostring(msg)..'\n'..debug.traceback()) end
 for _,v in ipairs(arg or {}) do if v=='--test' or v=='--smoke' then return function() return 1 end end end
 return defaultError(msg)
end
function love.load(args)
 love.graphics.setDefaultFilter('nearest','nearest')
 canvas=love.graphics.newCanvas(640,360)
 for _,v in ipairs(args or {}) do if v=='--test' then
  while loading do loadNext() end
  require('src.tests').run(Game,Audio,View); love.event.quit()
 end end
 for _,v in ipairs(args or {}) do if v=='--smoke' then smoke=true end end
end
function love.update(dt)
 if loading then if loadingDrawn then loadingDrawn=false;loadNext() end;return end
 debugPanel:update(game,math.min(dt,.04))
end
function love.draw()
 love.graphics.setCanvas(canvas); love.graphics.clear(.025,.035,.065)
 if loading then
  love.graphics.setColor(.94,.91,.77);love.graphics.printf('MACHETE COSMICO',0,140,640,'center')
  love.graphics.printf(loadingLabel,0,180,640,'center')
  love.graphics.setColor(.18,.23,.22);love.graphics.rectangle('fill',180,210,280,4)
  love.graphics.setColor(.61,.78,.47);love.graphics.rectangle('fill',180,210,280*math.min(1,loadStep/3),4)
  loadingDrawn=true
 else View.draw(game); debugPanel:draw(game) end
 love.graphics.setCanvas(); love.graphics.setColor(1,1,1)
 love.graphics.clear(.012,.016,.023)
 scale,ox,oy=viewport()
 love.graphics.draw(canvas,ox,oy,0,scale,scale)
 if smoke and not loading then love.event.quit() end
end
function love.keypressed(k)
 if k=='f11' then love.window.setFullscreen(not love.window.getFullscreen(),'desktop'); return end
 if loading then return end
 if debugPanel:key(game,k) then return end
 game:key(k)
end
function love.mousepressed(x,y,b)
 if loading then return end
 local z,left,top=viewport();x=(x-left)/z;y=(y-top)/z
 if x<0 or x>=640 or y<0 or y>=360 then return end
 if debugPanel:mouse(game,x,y,b) then return end
 if b==1 then game:key('space') elseif b==2 then game:key('q') end
end
function love.focus(f) if not f and game and game.state=='play' then game.state='pause' end end
