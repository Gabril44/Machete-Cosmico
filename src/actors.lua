-- Public facade retained for the cinematic and debug drawing callbacks.
local Player=require('src.entities.player.render')
local Dog=require('src.entities.dog.render')
local Aliens=require('src.entities.aliens.render')
return {player=Player.player,dog=Dog.dog,dogHead=Dog.dogHead,enemy=Aliens.enemy}
