# Listado de puntos a mejorar o problemas encontrados en el repo.

## Agregar sentry u otro servicio de registro de errores (done)

## Modo Dev
- El modo development esta activado para produccion
- Se puede agregar un modo debug para admin luego

## Aqui se agregaran items de:
- Refactorizacion de codigo.
- Metodos ineficientes.
- Gemas o funcionalidades faltantes a nivel técnico.
- Problemas de cualquier tipo encontrados.
- Metodos o flujos incoherentes.


# Mails
- Revisar que en el envio de mail no muestra error al enviar(fixed) (send_mail_after_creating no muestra el error correctamente)
- al anular un movimiento de una sucursal que no tiene email se muestra un error en rojo, se envia el mail pero el error no es friendly(se arregló pero falta mostrar razon de error en el mensage notice sobre envio de mail al generar movimiento y la sucursal no tenga email)
- agregar un mail default a las branches para que se envien los mails

# Maintenance mode
- Busacar alguna manera de agregar un modo mantenimiento para realizar las actualiaciones, pruebas y migraciones necesarias en prod.
- Se me ocurre una variable redis que tenga el valor mantenance_mode = true, y en apllication controller redireccionar a maintenance.html.erb si el usuario no es admin.

1. Storage: Use Redis/Rails.cache for fast checks
2. Exemptions: Skip maintenance for health checks, assets, admin routes
3. SEO: Return 503 status for search engines
4. Caching: Consider CDN-level maintenance pages
5. Testing: Add tests to verify admin bypass works correctly

# Eliminar archivos viejos
- Al migrar se dejan los excels, eliminarlos luego de usar


# Personas
- EL index de personas tiene un n+1 query muy pesado, mejorar el performance o implementar paginacion 


# Movimientos
- Hay un error en el filtro de fechas, muestra error de bd revisar.(done)
- Cuando se genera un movimiento canje de producto con precio, se guarda en la descripcion en lugar de otro valor que sirva para facilmente recuperarlo.
- Create requiere una refactorizacion, separar por el tipo de movimiento y hacer mucho mas legible el codigo, tambien que responda a errores sencillos de email, como por ejemplo cuando la branch no tiene email cargado(done)
- La anulacion de movimientos de canje de venta, que son dos movimientos juntos deberia englobarse en una sola anulacion para evitar problemaso malos entendidos.
- Anulacion de movmientos:  carga de entidad, probar anulacion(quedo pendiente de actualizacion v0.10.0)
- Agregar un limite al movimeinto, 5 millones con redis, para evitar problemas con mov gigantescos

# Comercios
- El index de comercios tiene algo raro, revisar

# Clientes
- 

# Usuarios
- La autenticacion de contraseña utiliza un hardcode en la master password, utilizar variable de entorno minimamente

# Redis Keys
- Las redis keys no funciona la creacion, estan mal las rutas default que utiliza(fixed branch feature/redis_keys_refactor)
- Quitar archivos viejos de vistas 


# Empleados
- Los filtros de empleado cuando estoy cn usuario gerente me dejan ver todas las sucursales, tengo entendido que el gerente es solo correspondiene a una sucursal.




# Errores muy especificos

- AL cargar dashboard con admin hay error por los movements de porduct exchange sin amount