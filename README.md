# Gestor de Deudas

Aplicación móvil hecha con Flutter para gestionar deudas personales. Guarda toda la información de forma local usando Hive. No requiere registro ni conexión a internet.

## Funciones principales

- Agregar y eliminar personas deudoras.
- Registrar deudas con descripción, fecha, cantidad y dirección (me deben / les debo).
- Fecha límite opcional por deuda.
- Historial de pagos: marcar deudas como pagadas en lugar de borrarlas.
- Resumen global en la parte superior: cuánto te deben y cuánto debes.
- Lista de personas ordenada por la deuda más reciente; las deudas saldadas van al final.
- Buscador de personas.
- Soporte para tema claro y oscuro.

## Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada y proveedores
├── app.dart                     # Configuración de MaterialApp y tema
├── models/                      # Modelos Hive y adaptadores
├── services/                    # HiveService y DebtRepository
├── blocs/                       # Cubits para estado y tema
├── screens/                     # Pantallas de la app
└── widgets/                     # Widgets reutilizables
```

## Cómo ejecutar

1. Ve al directorio del proyecto:

   ```bash
   cd /home/msalazar/CascadeProjects/debt_manager
   ```

2. Instala las dependencias:

   ```bash
   flutter pub get
   ```

3. Ejecuta la app en tu dispositivo o emulador:

   ```bash
   flutter run
   ```

## Dependencias principales

- `hive` y `hive_flutter`: almacenamiento local.
- `flutter_bloc`: gestión de estado.
- `intl`: formato de moneda y fechas.
- `uuid`: identificadores únicos.
- `path_provider`: ubicación de almacenamiento local.

## Notas

- Los datos se guardan localmente en el dispositivo.
- El tema seleccionado también se persiste.
- La app usa Material 3.
