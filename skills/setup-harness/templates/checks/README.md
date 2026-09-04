# Checks

Scripts que pueden fallar. Si no pueden decir «no», no sirven.

## Cómo usarlos

```bash
./checks/naming.sh
./checks/brief-ready.sh
./checks/delivery.sh
```

Código de salida: `0` = ok, distinto de `0` = hay que arreglar algo.

## Romper a propósito (para ver que el arnés funciona)

1. **naming:** deja un fichero `IMG_0001.JPG` suelto en la raíz del proyecto
   (o una carpeta sin fecha `YYYY-MM-DD` en el nombre) y vuelve a correr
   `./checks/naming.sh`. Debe fallar.
2. **brief:** borra o vacía `BRIEF.md` y corre `./checks/brief-ready.sh`.
3. **delivery:** quita la carpeta `entregables/` o déjala vacía y corre
   `./checks/delivery.sh`.

Luego pídele al agente en Claude Code: «el checker ha fallado, arréglalo
sin borrar originales». Si no puede fallar el checker, el setup está mal.
