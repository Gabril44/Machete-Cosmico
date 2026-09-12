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
 local pulse=.66+math.sin(t*2)*.16;g.setColor(.75,.9,.69,pulse);g.setFont(V.medium);g.printf('EMPEZAR',0,239,640,'center')
 g.setColor(.35,.47,.43);g.setFont(V.small);g.printf('ENTER',0,261,640,'center')
 g.setColor(.43,.48,.45);g.printf('developed by leshuggah',0,326,640,'center')
end
return T
