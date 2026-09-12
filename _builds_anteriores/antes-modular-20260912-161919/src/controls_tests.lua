local T={}
function T.run(Game,Audio,View,check,snap)
 local I=require('src.controls');local R=require('src.input_router');local O=require('src.options')
 local saved=I.serialize();local save=I.save;local writes=0
 I.save=function() writes=writes+1;return true end
 I.resetBindings('keyboard');I.resetBindings('gamepad')
 I.bind('keyboard','attack','q')
 check(I.keyboard.attack=='q' and I.keyboard.heavy=='space','keyboard conflict swaps bindings')
 I.bind('gamepad','dash','x')
 check(I.gamepad.dash=='x' and I.gamepad.attack=='a','controller conflict swaps bindings')
 local encoded=I.serialize();I.resetBindings('keyboard');I.resetBindings('gamepad');I.decode(encoded)
 check(I.keyboard.attack=='q' and I.gamepad.dash=='x','settings roundtrip preserves bindings')
 local x,y=I.stick(.05,.04);check(x==0 and y==0,'deadzone prevents stick drift')
 x,y=I.stick(1,1);check(math.abs(x*x+y*y-1)<.0001,'diagonal stick speed is capped')
 I.resetBindings('keyboard');I.resetBindings('gamepad')
 local function fresh()
  local s=Game.new(Audio);s:reset();s.stage='sandbox';s.player.hidden=false;s.player.weaponPose=nil;s.dog.hidden=false;s.save=function()end;return s
 end
 local s=fresh();I.bind('keyboard','attack','z');R.input(s,'keyboard','space');check(s.player.attackTimer==0,'old attack key no longer attacks')
 R.input(s,'keyboard','z');check(s.player.attackTimer>0,'rebound key attacks')
 s=fresh();R.input(s,'gamepad','a');check(s.player.dashTimer>0,'controller button starts dash')
 s=fresh();R.input(s,'gamepad','start');check(s.state=='pause','controller pauses gameplay')
 R.input(s,'gamepad','dpdown');R.input(s,'gamepad','a');check(O.open and s.state=='pause','options accessible from controller pause menu')
 O.page='gamepad';O.selected=3;O.accept();O.input('gamepad','triggerleft')
 check(I.gamepad.left=='triggerleft' and not O.capture,'trigger can be assigned')
 O.selected=4;O.accept();O.input('keyboard','escape');check(not O.capture,'capture can be cancelled')
 O.page='keyboard';O.selected=5;O.accept();O.input('keyboard','v')
 check(I.keyboard.attack=='v' and I.blocked['keyboard:v'],'captured key does not leak into gameplay')
 O.draw(View);O.close();R.input(s,'gamepad','b');check(s.state=='play','controller returns from pause')
 s=fresh();s.state='menu';s.menuChoice=2;R.input(s,'keyboard','return');check(O.open and s.state=='menu','options accessible before starting')
 O.page='main';O.selected=1;local volume=I.volume;O.change(-1)
 check(I.volume<volume and writes>0,'volume changes and settings are saved')
 O.close()
 s=fresh();require('src.cinema').beginEnding(s,{x=330,y=200,kind='boss',hp=0,maxHp=85,flash=0,wind=0})
 s.endingScene.qteActive=true;R.input(s,'keyboard','v');check(s.endingScene.qtePressed,'QTE honors rebound keyboard key')
 s.endingScene.qteActive=true;s.endingScene.qtePressed=false;I.bind('gamepad','attack','rightshoulder');R.input(s,'gamepad','rightshoulder')
 check(s.endingScene.qtePressed and I.label('attack')=='RB','QTE honors rebound controller button and label')
 I.resetBindings('keyboard');I.resetBindings('gamepad');I.blocked={};I.blockStick=false
 local original=I.joystick
 local axes={leftx=.65,lefty=0,triggerleft=0};local buttons={}
 local j={isConnected=function()return true end,isGamepad=function()return true end,getGamepadAxis=function(_,axis)return axes[axis] or 0 end,isGamepadDown=function(_,b)return buttons[b] or false end}
 I.attach(j);local movement=I.movement();check(movement.x>0 and movement.x<1 and movement.y==0,'analog stick produces proportional movement')
 local p=require('src.player').new(300,200);p:update(.1,movement);check(p.x>300 and p.x<310.8,'partial stick moves slower than full stick')
 axes.leftx=0;buttons.dpup=true;movement=I.movement();check(movement.y==-1,'controller dpad moves player')
 buttons.dpup=false;I.bind('gamepad','right','triggerleft');axes.triggerleft=.8;movement=I.movement();check(movement.x==1,'rebound trigger can drive movement')
 I.blocked['gamepad:triggerleft']=true;movement=I.movement();check(movement.x==0,'captured trigger is blocked until released')
 axes.triggerleft=0;I.update();check(not I.blocked['gamepad:triggerleft'],'releasing trigger clears input block')
 I.joystick=original
 I.resetBindings('keyboard');I.resetBindings('gamepad');I.decode(saved);I.device='keyboard';I.blocked={};I.blockStick=false;I.save=save;O.close();love.audio.setVolume(I.volume)
 Audio.muted=true
 print('Connected controllers: '..#love.joystick.getJoysticks())
end
return T
