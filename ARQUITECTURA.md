# Organización del proyecto

La demo conserva sus reglas, dibujos, diálogos, sonidos, controles y tiempos. Esta reorganización separa quién es responsable de cada parte. No introduce un motor nuevo ni cambia el formato de configuración del jugador.

## Dónde editar cada cosa

| Parte | Carpeta | Responsabilidad |
|---|---|---|
| Protagonista | `src/entities/player/` | Movimiento y ataques (`model.lua`), acciones y daño (`actions.lua`), cuerpo (`render.lua`), primer plano (`portrait.lua`), frases (`dialogue.lua`) y sonidos (`sounds.lua`). |
| Moro | `src/entities/dog/` | Movimiento y ladridos (`model.lua`), decisiones y reacciones (`behavior.lua`), caricias (`petting.lua`), dibujo, frases y sonidos. |
| Aliens | `src/entities/aliens/` | Creación (`factory.lua`), actualización y muerte (`system.lua`), selección de comportamiento (`behavior.lua`), jefe (`boss.lua`), dibujo, nave, nombres y sonidos. |
| Tipos de alien | `src/entities/aliens/ai/` | Captor de vacas, tirador, combate cuerpo a cuerpo y ladrón de papas. |
| Vacas | `src/entities/cows/` | Estado, progreso de abducción y alarma (`model.lua`); pastoreo, ascenso, encogimiento y partida de la nave (`render.lua`). |
| Mundo | `src/world/` | Mapa y límites, objetos rompibles, pasto cortable, tilemap, escenario y sonidos ambientales. |
| Sistemas | `src/systems/` | Combate, proyectiles, mates, oleadas, reinicio de partida y presentación de mensajes. |
| Escenas | `src/scenes/` | Introducción, final, coordinación de cámara y subtítulos, portón y momento anterior al jefe. |
| Interfaz | `src/ui/` | Composición de la imagen, HUD, inicio, opciones y primitivas de dibujo. |
| Controles | `src/input/` | Asignaciones, persistencia, teclado, joystick y navegación. |
| Efectos | `src/effects/` | Partículas, gore, reproducción de audio y generación de sonidos. |
| Debug y pruebas | `src/debug/`, `src/tests/` | Panel de pruebas rápidas y comprobaciones automatizadas. |

`main.lua` conecta LÖVE con carga, controles y dibujo. `src/game.lua` coordina la partida: ya no contiene la inteligencia artificial, el daño de los ataques, la abducción de vacas ni la recogida de mates.

## Diálogos y sonidos

Las frases pertenecen a su hablante. Por ejemplo, la protesta por las vacas está en `entities/player/dialogue.lua`, aunque la muestre el HUD; el gruñido pertenece a `entities/dog/dialogue.lua`. Los aliens conservan los nombres y textos que ya tenían, sin agregarles conversaciones nuevas.

Para cambiar una frase, editá el valor correspondiente en `dialogue.lua`; no renombres su clave sin actualizar a sus consumidores. Las escenas eligen cuándo se pronuncia. `systems/dialogue.lua` maneja la duración de los mensajes normales.

Los parámetros y las formas de onda están en `sounds.lua` de cada personaje. `effects/audio.lua` reúne los sonidos y los reproduce; `effects/synthesis.lua` construye las muestras. Los efectos de objetos siguen compartiendo su canal limitado para evitar superposiciones.

## Orden de la partida

El orden de `Game:update` es intencional: efectos y escena activa; jugador y Moro; mundo; pasto y oleadas; enemigos; vacas; proyectiles; mates. Las escenas pueden consumir la actualización y la muerte del jefe inicia el final antes de procesar los sistemas restantes.

Los módulos reciben la sesión `s` o los actores con los que trabajan. No importan `game.lua` para modificarlo globalmente. La sesión conserva los campos existentes (`player`, `dog`, `enemies`, `cows`, `props`, etc.) para que debug y pruebas sigan operando sobre el mismo estado.

## Agregar o cambiar un alien

1. Editar su creación en `entities/aliens/factory.lua`.
2. Agregar su comportamiento a `entities/aliens/ai/` y registrarlo en `behavior.lua`.
3. Definir su dibujo en `entities/aliens/render.lua` y sus sonidos/textos en los catálogos de esa carpeta.
4. Incluirlo en `systems/progression.lua` si debe aparecer en una oleada.
5. Verificar combate, aparición, muerte y recompensas con las pruebas.

## Compatibilidad y respaldo

Los archivos cortos de la raíz de `src` como `player.lua`, `dog.lua`, `world.lua` y `tests.lua` son puntos de entrada de compatibilidad: devuelven el módulo nuevo mediante `require`. No contienen copias de la implementación. Editá los archivos de las carpetas indicadas arriba.

`src/actors.lua` es una fachada que reúne los dibujos para los callbacks del escenario y las cinemáticas. El dibujo real está en la carpeta de cada personaje.

Los archivos antiguos del prototipo que ya no se utilizaban (`alien.lua`, `cow.lua` y el diseño descartado `boss_art.lua`) se retiran de `src` y se conservan en el respaldo anterior a la reorganización, dentro de `_builds_anteriores`.

## Comprobar los cambios

Ejecutar LÖVE sobre la carpeta del proyecto con `--test` para las pruebas, o con `--smoke` para verificar la carga y el primer dibujo. Se sigue generando únicamente el informe de texto de las pruebas; no se guardan capturas.

La reorganización se compara además con una copia anterior mediante huellas de estado, píxeles en memoria y audio generado con semilla fija. Esa herramienta es temporal y no se instala en la demo.
