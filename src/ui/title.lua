local T={}
local P=require('src.ui.presentation')
function T.draw(s,V)
 local g=love.graphics;P.background(s.time,nil,true);P.machete(s.time)
 g.setFont(V.small);g.setColor(.60,.68,.72);g.print('LA PRIMERA NOCHE / DEMO',48,57)
 g.setFont(V.big);g.setColor(.93,.90,.77);g.print('MACHETE',47,82)
 g.setFont(V.title);g.setColor(.82,.89,.79);g.print('CÓSMICO',44,106)
 g.setColor(.60,.71,.65,.45);g.rectangle('fill',48,164,190,1)
 for i,label in ipairs({'EMPEZAR','OPCIONES','SALIR'}) do
  local y=213+(i-1)*29;local selected=(s.menuChoice or 1)==i
  g.setFont(V.medium);g.setColor(selected and .94 or .53,selected and .92 or .60,selected and .79 or .65)
  g.print(label,206,y)
  if selected then g.setColor(.79,.90,.75);g.polygon('fill',191,y+3,198,y+7,191,y+11) end
 end
 g.setFont(V.small);g.setColor(.54,.61,.68)
 g.print(require('src.input.controls').device=='gamepad' and 'A confirmar · stick / cruz elegir' or 'ENTER confirmar · flechas elegir',180,306)
 g.setColor(.52,.56,.63);g.printf('developed by leshuggah',0,335,640,'center')
end
return T
