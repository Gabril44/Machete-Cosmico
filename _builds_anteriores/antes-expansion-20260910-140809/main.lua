local Debug=require('src.debug_panel')
local debugPanel=Debug.new()
local Game=require('src.game')
local View=require('src.view')
local Audio=require('src.audio')
local game,canvas,scale,ox,oy
local smoke=false
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
 View.load(); Audio.load(); game=Game.new(Audio)
 for _,v in ipairs(args or {}) do if v=='--test' then require('src.tests').run(Game,Audio,View); love.event.quit() end end
 for _,v in ipairs(args or {}) do if v=='--smoke' then smoke=true end end
end
function love.update(dt) debugPanel:update(game,math.min(dt,.04)) end
function love.draw()
 love.graphics.setCanvas(canvas); love.graphics.clear(.025,.035,.065)
 View.draw(game); debugPanel:draw(game); love.graphics.setCanvas(); love.graphics.setColor(1,1,1)
 local w,h=love.graphics.getDimensions(); scale=math.min(w/640,h/360); ox=(w-640*scale)/2; oy=(h-360*scale)/2
 love.graphics.draw(canvas,ox,oy,0,scale,scale)
 if smoke then love.event.quit() end
end
function love.keypressed(k)
 if k=='f11' then love.window.setFullscreen(not love.window.getFullscreen()); return end
 if debugPanel:key(game,k) then return end
 game:key(k)
end
function love.mousepressed(x,y,b)
 local w,h=love.graphics.getDimensions();local z=math.min(w/640,h/360)
 if debugPanel:mouse(game,(x-(w-640*z)/2)/z,(y-(h-360*z)/2)/z,b) then return end
 if b==1 then game:key('space') elseif b==2 then game:key('q') end
end
function love.focus(f) if not f and game.state=='play' then game.state='pause' end end
