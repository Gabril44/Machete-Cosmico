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

1. Caminá, cortá al menos 18 yuyos y acariciá a Moro.
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

Comprobaciones automáticas ejecutadas dentro de LÖVE 11.5, incluyendo daño, invulnerabilidad, combo, furia, abducción y rescate, proyectiles, ataques del jefe, derrota, reinicio y progresión de las tres oleadas hasta el final. Se revisaron capturas renderizadas por el motor. Estas pruebas verifican funcionamiento; el balance y la diversión todavía necesitan tus partidas.

Para repetir las pruebas ejecutá `lovec ruta/a/machete_cosmico --test`. El informe y las capturas se escriben en la raíz con el prefijo test-.

Este proyecto utiliza la instalación local de LÖVE.


## Actualización: calma, sospecha y furia

- Introducción con salida de la casa, paseo con Moro, cámara y ojos en la oscuridad. Enter permite omitir las cinemáticas; Esc las pausa.
- Tutorial: 18 yuyos de 36 repartidos en tres grupos, más la interacción con Moro.
- Moro mira hacia donde camina, con orientación lateral, frontal y de espaldas.
- El Inspector intercala una embestida después de dos pulsos. La franja marca el recorrido: esquivá al costado. Queda vulnerable durante su recuperación.
- Final ampliado: intento de alcanzar a Moro, grito, primer plano de dolor que se convierte en furia y título.
- Nuevos módulos: src/dog.lua, src/boss.lua y src/cinema.lua.

## Puesta en escena revisada

Moro avisa con dos ladridos y una reacción visible cuando el Inspector queda expuesto después de su embestida. Se retiró el texto «¡AHORA!».

La introducción muestra la salida por la puerta, a Moro saliendo después, la caminata y el desenvainado del machete desde la cintura antes de ponerse a cortar.

El final conserva las posiciones reales de la pelea: agonía y descarga del Inspector, caída, revelación de la flota que ya estaba en el cielo, Moro acercándose, encendido del rayo de la nave mayor, elevación del perro y carrera del campesino. La nave recién se retira después de recoger a Moro. El cierre continúa con el grito y el primer plano de furia. Enter omite y Esc pausa.

## Debug / pruebas rápidas

Abrí JUGAR.bat y presioná **F1**, incluso desde el menú o una cinemática. El panel congela la escena mientras elegís. Tiene pestañas de escenas y herramientas, seleccionables con clic o flechas + Enter. Tab, 1 y 2 cambian de pestaña.

- **F2**: repetir la última escena cargada.
- **F3**: congelar / continuar.
- **F4**: avanzar un cuadro de 1/60 s y quedar congelado.
- **F5**: cámara lenta 0.25x / velocidad normal.
- **F6**: invulnerabilidad.
- **F7**: áreas de combate.

Escenas: intro, desenvainado, ojos, tutorial, tres oleadas, jefe, poder circular, embestida con ladridos, muerte, rayo, primer plano final, vaca en abducción, Moro y práctica de combate.

Herramientas: curar, llenar furia, invulnerabilidad, tiempo, áreas de combate, ladridos y derrotar al jefe actual. «Volver al menú normal» limpia todas las ayudas. Las partidas modificadas por debug no guardan récord. Cargar una escena reemplaza la partida actual; F1 por sí solo no cambia nada.

## Expansión: la chacra y el galpón

La segunda oleada abre el portón del este. Seguí a Moro y cruzá por el camino a la derecha para entrar al maizal y al terreno del galpón. Allí ocurren la última oleada, el Inspector y el final. Las vacas que salvaste quedan en la chacra y siguen contando en el resultado.

El combo tiene cortes de ida, revés y remate; podés anticipar la siguiente pulsación cerca del final del golpe. Q prepara un ataque fuerte y después impacta: no hace daño durante la preparación. Los cajones y fardos bloquean el paso y se rompen. Estampar un alien contra ellos produce daño adicional; los cajones dejan mates. También podés cortar maíz.

Los ladrones de papas buscan bolsas y escapan con ellas. Matarlos recupera la bolsa y suma un bono; dejarlos escapar no impide terminar la oleada. Los tiradores anuncian y fijan su disparo antes de lanzarlo, y los grandotes levantan los brazos para preparar el golpe.

Moro olfatea, explora, da vueltas, te mira, reacciona a las caricias y observa a los enemigos. **R lanza un palito** para que lo busque y lo traiga. **E lo acaricia** si estás cerca. Moro no recibe daño del combate; su secuestro sigue siendo narrativo.

F1 tiene una tercera pestaña, **3 EXPANSIÓN**, con pruebas de la zona, el portón, objetos, ladrón y Moro. La portada ahora es simple y lleva la firma exacta «developed by leshuggah».

## Mapa continuo

La chacra y el galpón ahora forman un único tilemap de 1280 × 224 unidades de terreno, con tiles de 16 × 16. La cámara sigue al personaje horizontalmente. No hay teletransporte, cambio de pantalla ni fundido al cruzar el portón.

Después de la segunda oleada se abre el portón del camino oriental. Caminá hacia el galpón: al llegar al terreno del fondo empieza la última oleada y luego aparece el Inspector. Podés volver por el mismo camino; los animales, objetos rotos y cultivos conservan su estado. Los accesos de debug siguen disponibles en F1.

## Gore alienígena

Los machetazos salpican sangre verde; al morir, los aliens dejan pequeños órganos violetas, vísceras y ojos caricaturescos. Los restos rebotan y quedan en el terreno continuo, con límites de cantidad para mantener la lectura del combate. Los golpes fuertes y Berserk generan más salpicaduras. El Inspector libera sus restos durante su descarga final. F1 → 3 EXPANSIÓN → Gore alienígena permite probarlo rápidamente.

## Personajes y caricias

El protagonista mantiene su sombrero gastado en todas las vistas y las cinemáticas, con barba, tiradores, mangas arremangadas, funda y botas embarradas. La sangre verde se acumula sobre la ropa y la cara durante el combate y aparece en el primer plano final. Moro tiene pecho claro, mancha lateral, oreja caída, collar rojo y chapita, ojos y lengua expresivos, variaciones de trote, jadeo y estiramiento.

E cerca de Moro inicia una caricia de tres segundos: se arrima, el campesino se agacha y le rasca la cabeza. Moverse, atacar, esquivar o recibir daño la interrumpe. F1 → 3 EXPANSIÓN → Caricia a Moro permite comprobarla rápidamente.
