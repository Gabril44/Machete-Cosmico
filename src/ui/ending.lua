local E={}
local P=require('src.ui.presentation')
function E.draw(s,V)
 local g=love.graphics;P.background(s.time,.28)
 local function line(text,y,font,c) g.setFont(font);g.setColor(c);g.printf(text,24,y,592,'center') end
 line('MACHETE CÓSMICO',38,V.big,{.73,.81,.73})
 line('FIN DE LA DEMO',76,V.small,{.50,.58,.68})
 line('Se llevaron al perro equivocado.',143,V.big,{.95,.90,.76})
 line('La búsqueda de Moro recién empieza.',185,V.medium,{.66,.74,.79})
 g.setColor(.38,.44,.55,.55);g.rectangle('fill',160,220,320,1)
 line('PUNTOS '..s.score..'    /    VACAS A SALVO '..(3-s.lost)..'/3    /    RÉCORD '..s.best,235,V.small,{.70,.75,.73})
 line((require('src.input.controls').device=='gamepad' and '[ A ]' or '[ ENTER ]')..'  JUGAR DE NUEVO',278,V.medium,{.79,.90,.75})
 line('Gracias por jugar esta demo.',312,V.small,{.58,.65,.70})
 line('developed by leshuggah',337,V.small,{.47,.52,.60})
end
return E
