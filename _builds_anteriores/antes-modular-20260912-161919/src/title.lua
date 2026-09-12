local T={}
function T.draw(s,V)
 local g=love.graphics;local t=s.time
 g.setColor(.014,.021,.027);g.rectangle('fill',0,0,640,360)
 for i=1,35 do g.setColor(.26,.38,.36,.18+math.sin(t*.7+i)*.07);g.rectangle('fill',(i*113)%640,35+(i*59)%275,1,1) end
 -- A quiet blade silhouette, a single light, and plenty of empty space.
 g.push();g.translate(321,167);g.rotate(-.55)
 g.setColor(.33,.43,.39,.10);g.rectangle('fill',-5,-112,10,150);g.setColor(.55,.48,.29,.12);g.rectangle('fill',-6,39,12,32);g.pop()
 g.setFont(V.big);g.setColor(.91,.87,.71);g.printf('MACHETE',0,95,640,'center')
 g.setFont(V.title);g.setColor(.8,.85,.67);g.printf('CÓSMICO',0,120,640,'center')
 g.setFont(V.small);g.setColor(.49,.59,.52);g.printf('LA PRIMERA NOCHE',0,177,640,'center')
 local selected=s.menuChoice or 1
 g.setColor(.75,.9,.69);g.setFont(V.medium);g.printf((selected==1 and '> ' or '')..'EMPEZAR',0,239,640,'center')
 g.printf((selected==2 and '> ' or '')..'OPCIONES',0,281,640,'center')
 g.setColor(.45,.57,.50);g.setFont(V.small);g.printf(require('src.controls').device=='gamepad' and 'A confirmar · stick / cruz elegir' or 'ENTER confirmar · flechas elegir',0,261,640,'center')
 g.setColor(.43,.48,.45);g.printf('developed by leshuggah',0,326,640,'center')
end
return T
