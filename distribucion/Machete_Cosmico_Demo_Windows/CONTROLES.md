# Controles y opciones

En el inicio y en pausa, elegí **Opciones** con las flechas, la cruceta o el stick izquierdo. También se puede entrar haciendo clic.

- Volumen general: izquierda/derecha, o clic a cada lado de la fila.
- Pantalla completa: activar/desactivar. F11 sigue disponible fuera de la configuración.
- Controles de teclado y joystick: elegí una acción y pulsá la nueva tecla, botón o gatillo. Si ya está asignado, las dos acciones intercambian sus controles.
- Zona muerta del stick: aumentala si el personaje se mueve sin tocar el mando.
- Cada dispositivo tiene un botón para restaurar sus controles originales.

Los cambios se guardan automáticamente en la carpeta de datos de LÖVE (`machete_cosmico_demo/controls-settings.txt`), separados del código y del récord.

## Por defecto

| Acción | Teclado | Joystick (nombres Xbox) |
|---|---|---|
| Mover | WASD o flechas | Stick izquierdo o cruceta |
| Corte / remate QTE | Espacio | X |
| Golpe fuerte | Q | Y |
| Esquivar | Shift izquierdo | A |
| Furia | F | RB |
| Acariciar a Moro | E | B |
| Lanzar palito | R | LB |
| Pausa | Esc | Start |
| Omitir cinemática | Enter | Back / View |

Los avisos de juego cambian según el último dispositivo usado y la asignación actual. El movimiento del stick es analógico. Desconectar el mando activo pausa la partida.

La navegación de menús conserva flechas/cruceta/stick, Enter o A para aceptar, y Esc o B para volver. Esc cancela la captura de una asignación; F1–F12 están reservadas para las herramientas del juego. Estas referencias fijas permiten recuperar una configuración equivocada.

Para mandos reconocidos por LÖVE como gamepad se usan los nombres Xbox (en otros mandos representan posiciones equivalentes). Los joysticks genéricos pueden asignar sus botones numerados; los ejes 1 y 2 se usan para mover y los botones 1 y 2 para aceptar/volver. La compatibilidad física depende del mando y su controlador.
