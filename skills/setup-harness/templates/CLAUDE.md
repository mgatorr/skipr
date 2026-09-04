# {{PROJECT_NAME}}

Carpeta de trabajo: **{{DOMAIN}}**. Todo el agente trabaja aquí, no en un vault genérico.

## Reglas

- No inventes EXIF, GPS, fechas, clientes ni entregables. Si falta el dato, pregunta.
- No borres fotos ni carpetas originales. Si hace falta limpiar, propone y espera OK.
- Antes de decir «listo», ejecuta el checker de `checks/` que toque y arregla si falla.
- Respuestas al humano en español. Nombres de fichero en ASCII cuando se renombren.
- Mantén este fichero corto. Si crece de más, recorta; no añadas un Second Brain.

## Checkers

```bash
./checks/naming.sh        # viaje / culling
./checks/brief-ready.sh   # cliente
./checks/delivery.sh      # delivery
```

Solo aplica el que exista en esta carpeta.

## Hecho significa

El checker sale en verde **y** el humano confirma el resultado mirando ficheros
(o la pantalla), no solo leyendo lo que el modelo afirma.
