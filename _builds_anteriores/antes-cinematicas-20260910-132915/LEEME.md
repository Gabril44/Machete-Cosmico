# Machete Cósmico — La primera noche

Demo del primer nivel basada en la biblia del proyecto. Lua + LÖVE 11.5, sin dependencias adicionales en el código del juego.

## Jugar en Windows

Abrí **JUGAR.bat** para iniciar este proyecto con LÖVE instalado. También podés arrastrar esta carpeta sobre love.exe.

La raíz del proyecto contiene main.lua, conf.lua y src. Ejecutá `love ruta/a/machete_cosmico` para jugar desde una terminal.

## Controles

| Acción | Tecla |
|---|---|
| Caminar / orientar el machete | WASD o flechas |
| Corte, combo de tres golpes | Espacio o clic izquierdo |
| Golpe fuerte | Q o clic derecho |
| Dash con invulnerabilidad | Shift |
| Berserk con furia completa | F |
| Acariciar a Moro, estando cerca | E |
| Pausa | Esc |
| Sonido | M |
| Pantalla completa | F11 |
| Reiniciar al ganar o perder | R o Enter |

El ataque apunta en la última dirección de movimiento; el mouse funciona como botón de ataque, no como mira. Pulsá de nuevo para encadenar cada golpe. Podés atacar durante el dash.

## Recorrido

1. Caminá, cortá al menos tres yuyos y acariciá a Moro.
2. Defendé la chacra durante tres oleadas. Los captores verdes se llevan las vacas: golpealos para interrumpir el rayo. Una abducción necesita nueve segundos de actividad; retrocede cuando no hay captores cerca.
3. Los aliens violetas disparan plasma. El machete puede cortar sus proyectiles. Los grandotes aguantan más y anuncian sus golpes.
4. Recogé mates para recuperar 18 puntos de vida. Entre oleadas recuperás 15. Golpear carga la furia; Berserk dura seis segundos.
5. Vencé al Inspector de Ganado. Salí de sus círculos antes del impacto y esquivá la descarga radial. Se acelera al bajar de la mitad de vida.
6. Mirá el cierre con el secuestro de Moro: es el comienzo de la aventura, como plantea la biblia.

Perder vacas reduce el resultado final, pero no bloquea el avance. Perder toda la vida termina la partida. El récord se guarda localmente mediante LÖVE.

## Alcance

Incluye menú, tutorial integrado, tres oleadas, cuatro roles de enemigo, mini jefe, combo, golpe fuerte, dash, furia, abducciones interrumpibles, perro acompañante, final, derrota, reinicio, pausa, sonidos sintetizados, partículas, hit-stop, sacudida y arte procedural con resolución interna de 640 × 360.

Es una demo del primer nivel, no la campaña completa. Las prótesis, la pistola impredecible, los niveles extraterrestres y el rescate final quedan para la continuación. El arte y el sonido son propios de esta demo y todavía pueden evolucionar; no se incluyen música ni assets externos.

## Código

- `main.lua`: inicio, ventana, entrada y escalado.
- `src/player.lua`: movimiento y kit de combate, desarrollado a partir del módulo original.
- `src/game.lua`: estados, enemigos, oleadas, rescate, jefe y narrativa.
- `src/view.lua`: escenario, personajes, efectos e interfaz.
- `src/audio.lua`: efectos sintetizados.
- `src/tests.lua`: pruebas deterministas de mecánicas y progresión.

El prototipo anterior está respaldado dentro de _builds_anteriores. Las entidades y el bucle se ampliaron para resolver daño al jugador, estados finales y rescates, que faltaban en la base.

## Validación

23 comprobaciones automáticas ejecutadas dentro de LÖVE 11.5, incluyendo daño, invulnerabilidad, combo, furia, abducción y rescate, proyectiles, ataques del jefe, derrota, reinicio y progresión de las tres oleadas hasta el final. Se revisaron capturas renderizadas por el motor. Estas pruebas verifican funcionamiento; el balance y la diversión todavía necesitan tus partidas.

Para repetir las pruebas ejecutá `lovec ruta/a/machete_cosmico --test`. El informe y las capturas se escriben en la raíz con el prefijo test-.

Este proyecto utiliza la instalación local de LÖVE.

