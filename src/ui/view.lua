local Petting=require('src.entities.dog.petting')
local Gore=require('src.effects.gore')
local Tilemap=require('src.world.tilemap')
local World=require('src.world.map')
local Actors=require('src.actors')
local Title=require('src.ui.title')
local Cinema=require('src.scenes.cinema')
local Boss=require('src.entities.aliens.boss')
local V={}; local g=love.graphics
local draw=require('src.ui.drawing').bind(V)
local color,rect,text,shadow=draw.color,draw.rect,draw.text,draw.shadow
local C=draw.C
function V.load()
 V.small=g.newFont(9);V.medium=g.newFont(13);V.title=g.newFont(43);V.big=g.newFont(24)
 V.grass={};local rng=love.math.newRandomGenerator(402)
 for i=1,1100 do V.grass[i]={rng:random(9,630),rng:random(97,320),rng:random()} end
end
function V.farm(s) require('src.world.scenery').draw(s,V) end
local ufo=require('src.entities.aliens.ship').draw
local function cow(c,s) require('src.entities.cows.render').draw(c,s,V) end
local function dog(d,t) Actors.dog(d,t) end
local function player(p,t) Actors.player(p,t) end
local function enemy(e,t) Actors.enemy(e,t) end
function V.draw(s)
 if s.state=='menu' then Title.draw(s,V);return end
 g.push();if Cinema.active(s) then Cinema.camera(s) else g.translate(-math.floor(s.cameraX or 0),0) end;if s.shake>0 then g.translate(math.sin(s.time*110)*s.shake,math.cos(s.time*97)*s.shake*.5) end
 V.farm(s)
 Cinema.world(s,ufo,enemy)
 Gore.ground(s)
 require('src.scenes.feeling').shadows(s)
 World.drawProps(s);World.ambience(s)
 if s.stage=='arrival' then color(C.mint,.10);g.polygon('fill',110,178,180,178,158,91,134,91);ufo(145,94,28,s.time) end
 for _,e in ipairs(s.enemies) do if e.kind=='boss' then Boss.drawTelegraph(e,V.small) end end
 local things={};for _,c in ipairs(s.cows) do things[#things+1]={y=c.y,draw=function() cow(c,s) end} end
 if s.gateRunner then things[#things+1]={y=s.gateRunner.y,draw=function() enemy(s.gateRunner,s.time) end} end
 things[#things+1]={y=s.dog.y,draw=function() dog(s.dog,s.time) end};things[#things+1]={y=s.player.y,draw=function() player(s.player,s.time) end}
 for _,e in ipairs(s.enemies) do things[#things+1]={y=e.y,draw=function() enemy(e,s.time) end} end
 table.sort(things,function(a,b)return a.y<b.y end);for _,o in ipairs(things) do o.draw() end
 Petting.draw(s,Actors)
 for _,d in ipairs(s.drops) do shadow(d.x,d.y+4,6);rect(d.x-4,d.y-5,8,9,{.57,.37,.19});rect(d.x-3,d.y-6,6,2,C.mint);rect(d.x+2,d.y-12,1,8,C.cream);text('+',d.x-3,d.y-3,C.mint) end
 for _,a in ipairs(s.shots) do color(C.mint,.16);g.circle('fill',a.x,a.y,7);rect(a.x-2,a.y-2,4,4,C.mint) end
 Gore.air(s)
 for _,a in ipairs(s.particles) do color(a.c,math.min(1,a.t*3));g.rectangle('fill',a.x,a.y,2,2) end
 g.pop()
 if Cinema.active(s) and s.state=='play' then Cinema.draw(s,V);return end
 require('src.ui.hud').draw(s,V)
end
return V
