# Changelog

Todos los cambios importantes iran en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Versionado Semántico](https://semver.org/spec/v2.0.0.html).


## [0.16.0] 2026-4-5
### Added
- Se agrega Rama Develop


## [0.15.3] 2026-3-28
### Changed
- Se modifica root page e index de usuarios sucursales

## [0.15.2] 2026-3-03
### Changed
- Se modifican variables para utilizar subdominio app.puntosaltoque.com

## [0.15.1] 2026-2-21
### Changed
- Se agrega default_from para el envio de mails con opcion recuperada de redis (mailer_setting_service)

## [0.15.0] 2026-2-20
### Changed
- Se unifica el mensaje de movimiento de venta en configuracion y en plantilla de email.
- Se agrega config de color de texto en emails.

## [0.14.4] 2026-2-19
### Changed
- Se arregla formulario de registro de persona cuando el usuario no esta logeado, error de +14meses

## [0.14.3] 2026-2-08
### Changed
- Se arregla bypass de autenticacion en nuevas paginas de confirmacion de correo.

## [0.14.2] 2026-2-08
### Added
- Se agrega remitente al envio de mails con variable de entorno SMTP_DEFAULT_FROM 

## [0.14.1] 2026-2-07
### Added
- Uso de servidor de correo resend, prueba de registro
- Se agregan paginas de registro de clientes por email con link de confirmacion

## [0.14.0] 2026-2-04
### Added
- Atributo para marcar correos de clientes como validados(validated_at tipo timestamp)
- Script y archivo para activar mails verificados por envialosimple
- Se agrega validacion de sintaxis correcta del mail en el formulario de registro de cliente.
- Verificacion de emails validados para el envio de mails por movimiento
- Se agrega envio de mail de confirmacion (WIP).


## [0.13.10] 2026-1-25
### Added
- Added google Analitics with GoogleTag

## [0.13.9] 2026-1-20
### Changed
- Se corrige momento de registro del envio de mail para que quede constancia de solicitud de envio desde el sistema.
- Se modifica el boton de registro de cliente de usuario gerente general para usar el link externo dentro del listado de clientes.
- Se corrige link de registrar persona/cliente en nuevo movimiento, pas a utilizar link externo.
- Se corrige link cancelar de wizard registro de cliente en sucursal(persona existente).


## [0.13.8] 2026-1-19
### Changed
- Se elimina validacion de email de sucursal al diferir de las politicas de nuevo servicio de correo EnvialoSimple Transaccional.
- Se quita del dashboard el boton de carga diferida de graficos de clientes. Se mantiene optimizacion pero se mantiene el lugar de carga original.

## [0.13.7] 2026-1-19
### Changed
- Se oculta en config de sucursales el ingreso de email.

## [0.13.6] 2026-1-18
### Changed
- Se realiza modificacion del modulo de email para permitir el uso de nuevo servicio de correo EnvialoSimple.
- Se modifica remitente de mail para permitir el envio desde nuevo servidor(solo permite mail xxx@puntosaltoque.com)
- Se agrega Nombre de comercio y sucursal en el remitente como alias junto al correo.
- smtp config allows redis key for domain.

## [0.13.5] 2026-1-13
### Changed
- Se agrea Alta de Clientes para gerente sucursal.
- Se agrega carga a demanda a traves de un boton para graficos de clientes.
- Se realiza optimizacion de la consulta que carga graficos de clientes.

## [0.13.4] 2026-1-13
### Changed
- Se corrige dormir clientes a nivel de company.

## [0.13.3] 2026-1-12
### Changed
- Se corrige Dashboard para mostrar info correcta.
- Se refactoriza leftsidebar menu.

## [0.13.2] 2026-1-6
### Changed
- Se corrige label de tipos de movimientos para mostrar canje catalogo sin modificar la key del enumerado.
- Se arregla label de config de sucursal, opcion: "Permite Canje" a "Permite Venta Canje"

## [0.13.1] 2026-1-6
### Changed
- Se corrige el nombre canje producto por canje catalogo, se mantiene el valor en BD como producto.
- Se corrige filtro de fechas para que tome correctamente el rango inicio y fin del dia para movimientos.

## [0.13.0] 2026-1-5
### Changed
- Se agrega attrib admits_product_exchange para poder definir correctamente el tipo de movimiento admitida.
- Se corrige filtro de movimientos y se limit a 1 mes por defecto para que no se demore al cargar datatable.
- Se cambian estilos css, se agrega toggle theme para dark mode y se modifican imagenes de assets.
- Se arregla eliminacion de producto en catalogo.
- Se mejora el Readme.md

## [0.12.6] 2025-12-15
### Changed
- Se corrige el dashboard para admin, utilizando los metodos refactorizados de mov tipo cred y debito.

## [0.12.5] 2025-12-8
### Added
- Se agrega capacidad de generar mov de canje de productos seleccionando multiples productos.
- Se agrega filtro de clientes por fecha de carga
- Columna de fecha de carga en reporte de clientes
- Se agrega control de nuevo producto en movimientos 

## [0.12.4] 2025-12-6
### Changed
- Se arregla el filtro de clientes, devuelve clientes correspondientes a la company y se mejora la performance.

## [0.12.3] 2025-11-26
### Changed
- Se arregla permisos de company_owner_role(gerente empresa) para que pueda editar productos del catalogo

## [0.12.2] 2025-11-10
### Changed
- Se arregla mensaje de perdida de csrf token, y se redirecciona a nuevo movimiento a los usuarios cuando buscan personas con el link de hotwire: /customers/search_person_customer

## [0.12.1] 2025-11-10
### Changed
- Fixed multiple redirects on dashboard for basic role

## [0.12.0] 2025-11-9
### Added
- Added sentry to start monitoring.
- Added annulations on movements table index.
- Added chaching on movements_table


## [0.11.2] 2025-11-6
### Added
- Permiso para usuario gerente_general(company_owner_role) para anular movimientos desde tabla de movimientos.


## [0.11.1] 2025-11-5
### Added
- file filtered_clients_updated, con los clientes de las sucursales y sus puntos actualizados de fidely.com
- task para actualizar los puntos de los clientes de las nuevas sucursales
- tamb se tiene en cuenta clientes que utilizaron el sistema a la vez(en otra sucursal)


## [0.11.0] 2025-11-5
### Changed
- Se arregla el uso de redis keys, tenia problemas al crear y actualizar registros
- Se mejora la funcionalidad de redis keys en general
### Added
- Se agrega un maintenance mode simple, basado en redis y redireccion en application_controller.
- Pagina de maintenance mode

## [0.10.0] 2025-11-5
### Added
- Rol básico tiene nueva opcion en el menu alta de clientes(link a qr nuevo cliente)
- Rol basico limita su visibilidad de movimientos(dia actual y mov propios)
- No permitir ninguna anulacion (incluida de rol basico) si no hay puntos disponibles o ya fueron canjeados.
- Rol Gerente puede anular cualquier movimiento de su comercio, si los puntos a anular son menores que los del cliente en el momento.
- Se corrige la cantidad de canjes que se muestran en cta. cte. para mostrar correctamente las anulaciones.
- No se permite anular un movimiento ya anulado.
- Optimizacion en carga ciudades.
- Se mejora mensaje de error al anular movimeintos y la sucursal carezca de email.
- Se arreglaron botones de orden de la tabla de movimientos para los de tipo numerico que usan DataTables.
- En la anulacion de canje de una vta con canje se advierte al usuario o gerente que se debe reingresar dinero.
- Se quita boton volver de cta cte externa


## [0.9.6] 2025-11-2
### Added
- Task migracion de clientes faltantes de aguaray.xlsx'


## [0.9.5] 2025-11-2
### Added
- Task anulacion de movimientos por pedido luego de migracion, basado en archivo 'para_anular_completo.xlsx'


## [0.9.4] 2025-10-21
### Changed
- Redireccion a dashboard para admin o group owner cuando el usuario ingresa como entidad

### Added
- Se agregar archivo de conocimeinto de negocio(Entidades y asignacion de puntos)


## [0.9.3] 2025-10-01
### Changed
- Acceso a opciones del menu segun basic role


## [0.9.2] 2025-10-01
### Added
- Optimizacion de show de comercios(clientes y transacciones)


## [0.9.1] 2025-09-29
### Added
- Archivo de migracion de clientes a produccion.


## [0.9.0] 2025-09-29
### Added
- Se agrega script para importacion desde excel
- Se arregla index personas cuando no tiene doc o tipo doc.
- Se mejora perormance en grillas de clientes y movimientos.
- Se separa nuevo movimiento de listado de movimientos para evitar llamadas inecesarias.
- Se optimiza el job al entrar a index de clientes cada vez y se pone en background para no bloquear.
- Se filtran graficos en el dashboard para branches con mas de 2mil cleintes.


## [0.8.12] 2025-09-29
### Added
- Roo gem
- Se permite al company_owner administrar catalogos.
- Se agregan atributos de persona para importacion de clientes.

## [0.8.11] 2025-09-24
### Added
- Se oculta el monto ahorrado si es 0 en los mails.

## [0.8.10] 2025-09-24
### Added
- Debug for movement mail.
- Added re send movement mail with ID.

## [0.8.9] 2025-09-19
### Added
- Debug for mail.

## [0.8.8] 2025-09-19
### Added
- Excel clientes y movimientos, formateo de fechas a gmt-3.

## [0.8.7] 2025-09-18
### Changed
- Excel clientes con mas campos de persona y sin overflow de url, optimizado.
- Excel de movimientos con mas campos y sin overflow, optimizado.
- Boton para cta.cte de cliente en email de puntos.

## [0.8.6] 2025-09-12
### Changed
- Permite agregar empleado a una sucursal siendo admin(el grupo se obtiene de la company seleccionada)
- Se arregla busqueda de persona en nuevo movimiento.

## [0.8.5] 2025-09-11
### Changed
- Se soluciona acceso a boton ver de notificaciones de movimientos.
- Se coloca fecha y hora en la grilla con gmt-3.

## [0.8.4] 2025-09-09
### Changed
- Se optimiza el dashboard, ranking de clientes.
- Se optimiza el index de clientes.
- Se arregla busqueda de persona en nuevo movimiento external que daba error.

## [0.8.3] 2025-09-09
### Changed
- Se optimiza el index de moviminetos, solo queda la n+1 relacionada a la anulacion.
- Fixed changlog typo.

## [0.8.2] 2025-09-09
### Changed
- Se optimiza movments index.

## [0.8.1] 2025-09-09
### Added
- Se agrega gema rack-mini-profiler para debug de n+1 queries.

## [0.8.0] 2025-09-08
### Added
- Se agrega gema caxlsx para renderizado de excel.

## [0.7.4] 2025-09-08
### Changed
- Se Agregan validaciones en la carga de clientes por tipo y nº doc.

## [0.7.3] 2025-09-08
### Changed
- Se Agregan validaciones en la carga de clientes por tipo y nº doc.

## [0.7.2] 2025-09-02
### Changed
- Se Modifica estilo en navbar de botones top_bar (revert).

## [0.7.1] 2025-09-02
### Changed
- Se reordenan columnas de tabla de movimientos.
- Se Modifica estilo en navbar de botones top_bar.

## [0.7.0] 2025-09-02

### Added
- Se agrega trazablidad de usuarios registrados.
- Se agrega el usuario que registra un movimiento, y se muestran mas columnas en la tabla de movimientos.

## [0.6.4] 2025-09-01

### Changed
- Fix doble imagen en el mail

## [0.6.3] 2025-09-01

### Changed
- Maneja mejor las imagenes del mail al generar movimientos.
- Al visualizar una alerta se la marca como leída.

## [0.6.2] 2025-08-31

### Changed
- Se arregla allow null en pantalla de qr para catalogos, colores de texto y recomendaciones al cargar imagenes.

## [0.6.1] 2025-08-27

### Changed
- Se modifica migracion de color de texto encatalogos.

## [0.6.0] 2025-08-27

### Added
- Se agrega posibilidad de editar catalogos con colores, tipografias e imagenes.


## [0.5.3] 2025-08-21

### Added
- Se agrega funcion para obtener el catalogo desde la branch + fix error por tal motivo
- Se agregan pantallas 404 y not allowed para control de permisos en redis_keys

## [0.5.2] 2025-08-20

### Changed
- Se modifica para configurar mail server con redis o con envs

## [0.5.1] 2025-08-18

### Changed
- Se deja descripcion en el titulo del showcase de catalogos

## [0.5.0] 2025-08-13

### Added
- Se agrega la posibilidad de agregar catalogos de productos, y generar movimientos para intercambiar productos por puntos.


## [0.4.3] 2025-06-27

### Changed
- Se agrega el qr de nuevo movimiento para los de tipo entidad que se habia quitado.


## [0.4.2] 2025-06-27

### Changed
- Se Quita el boton 'Nuevo cliente' del index, para entidades de tipo grupo(carga puntos por entidad).
- Se oculta el estado en la busqueda de persona(por qr) para entidades de tipo grupo.
- Se arreglan las opciones Movimientos y Clientes para Admin que no contemplaban la falta de grupo al iniciar sesion
- Al ingresar como entidad redirecciona a Movements y se ocultan los dashboards.
- Se muestran diferentes imagenes en el top_bar segun grupo, tipo o branch.


## [0.4.1] 2025-06-27

### Changed
- Se arregla array de movimientos para que funcione para cte cte empleado y persona

## [0.4.0] 2025-06-27

### Changed
- Se Modifica la obtencion de datos para la cta cte de los clientes pertenecientes a grupos que acumuluan puntos por entidad

## [0.3.5] 2025-06-10

### Added
- Se formatea el valor ahorrado en el mail de carga de puntos

## [0.3.4] 2025-06-6

### Added
- Se agrega opcion para activar desactivar empleado y otros cambios de visibilidad de titulos

## [0.3.3] 2025-06-5

### Changed
- Se corrige nombre de variable en form_employee

## [0.3.2] 2025-06-5

### Changed
- Se corrige error de titulo en formulario de empleado

## [0.3.1] 2025-06-5

### Changed
- Se corrige error de titulo en formulario de empleado

## [0.3.0] 2025-06-5

### Added
- Se agrega opcion para que group_owners puedan agregar gerentes y otros empledos
- Se agrega svg icon con logo de puntos

## [0.2.15] 2025-06-3

### Changed
- Se modifica el acceso a los qr


## [0.2.14] 2025-05-23

### Changed
- Se cambia el formato de fecha en la tabal de movimientos a gmt-3

## [0.2.13] 2025-05-20

### Changed
- Se arregla la relacion a customer al crear desde el qr

## [0.2.12] 2025-05-9

### Changed
- Se agrega filtro para buscar nombre los comercios al iniciar sesion
- Se ocultan inputs al crear una sucursal

## [0.2.11] 2025-04-30

### Changed
- Se agrega filtro para buscar por ciudad en comercios

### Removed
- Se quitan imagenes cargadas con css

## [0.2.10] 2025-04-29

### Changed
- group_owner_role no puede visualizar el boton Nuevo movimiento desde index de movimientos

## [0.2.9] 2025-04-29

### Changed
- Nuevo rol group_owner_role
- Se ocultan opciones para nuevo rol group_owner_role

## [0.2.8] 2025-04-16

### Changed
- Se oculta el dsahboard para users con basic_role


## [0.2.7] 2025-04-15

### Changed
- Fixed condicion de visualizacion de indicadores

## [0.2.6] 2025-04-15

### Changed
- Se ocultan opciones del menú, se corrige la obtencion de branches en seleccion de branches

## [0.2.5] 2025-03-19

### Changed
- Cuenta corriente por de Personas se muestra/oculta según tipo Entidad
- Alta de movimientos de entidad habilitado/deshabilitado según tipo Entidad
- Cuenta corriente por de clientes actualizado según tipo Entidad
- Filtro de Movimientos corregido
- Filtro de Clientes corregido

## [0.2.4] 2025-03-19

### Changed
- Imagen Dev actualizada

## [0.2.3] 2025-03-18

### Changed
- Se agregó tipo de acumulación de puntos en cuenta para entidades
- Se quitaron campos no utilizados en Comercios

## [0.2.2] 2025-02-12

### Changed
- Fix en cuenta corriente: Ahora suma todos los puntos de todas las compañias dentro de la entidad
- Documento agregado en visualizaciones de Cta. Cte.

## [0.2.1] 2025-02-11

### Changed
- Manejo de Entidades
- Correcciones en cálculos de canjes
- Configuración de sucursales para permitir canjes
- Movimientos vinculados a personas
- Usuarios por entidad

## [0.1.11] 2024-12-23

### Changed
- Mejora de inicio de sesión con panel de navegación desplegado y mejoras en dispositivos moviles
- Correccion de docker-compose para que funcione pgadmin
- Error de warning de datatable en cta cte de clientes de un comercio
- Corrección de error redis en testing 
- Corrección de orden de generación de ventas y canjes
- Corrección de imagen de mail para que aparezca
- Corrección de show de email de persona
- Correccion de canjes de ventas y cajas


## [0.1.10] 2024-12-17

### Changed
- Correcciones qr_code y qr_branch para poner boton volver, aplicacion de token en rutas external al sistemas. 
- Correccion de editar y agregar nuevo teléfono de persona y cliente
- Correccion de boton volver con el datatable de todas las tablas 
- Corrección en editar sucursal de comercio cuando se marca y desmarca el atributo principal
- Inicialización y filtros con datatable de todas las tablas del sistema para que aparezca cuando comienza 
- Warning en datatable cuando se ingresa a la cuenta corriente, sale error de datatables
- Error de redis en testing (pruebas en entorno testing)
- Imagen de correo en tesging (pruebas en entorno testing)

## [0.1.9] 2024-12-11

### Changed
- Vuelta de REDIS_DB a 0.

## [0.1.8] 2024-12-11

### Changed
- Prueba de REDIS_DB de 0 a 1.

## [0.1.7] 2024-12-10

### Changed
- Cambio de redis en cable.yml con variables de ambiente como en las instancias de Redis

## [0.1.6] 2024-12-09

### Changed
- Correccion en el editar y crear sucursales de un comercio
- Pruebas de envio de correos de pruebas con redis (seccion de configuracion de email)
- Cambios en configuracion para mails de enviropment de development y production (fijarse si funcionan cuando envio correo en testing)
- Correcciones visuales en etiquetas de mails y telefonos de personas
- Correcccion de doble datatable cuando apretas boton volver (del navegador) o a veces en el menu de arriba (aplicado a todas las tablas)
- Correccion cuando se crea y edita un telefono de una persona por el enum de codigo de area de pais.
- Graficos al inicio de sesion en la parte de Home
- Task de redis de correos electronicos (fijarse de ejecutarlas en testing)

## [0.1.5] 2024-10-31

### Changed
- Terminar ultimas correcciones de QR de comercio y sucursal (nivel visual y funcional, tambien para que ande en bixi)
- Datatable en tablas del sistema : Tabla de movimeinto, comercios, alert, branchalert, provincia, pais, ciudades
- Los movimiento anda con la configuracion de alertas de sucursales (correccion  visual)
- Correccion en eliminar imagen de sucursal, no andaba
- Correccion de navbar (panel izquierdo cuando retorno) salia cortado el top-margin


## [0.1.4] 2024-10-31

### Added
- Agregados de archivos para release.

## [0.1.3] 2024-10-10

### Fixed
- Corregidas todas las conexiones a redis.

## [0.1.2] 2024-10-08

### Added
- Agregados los hosts faltantes

## [0.1.1] 2024-09-06

### Removed
- Eliminados limites de recursos temporalmente.

## [0.1.0] 2024-09-05

### Added
- Subida inicial con el proyecto actual.
- Creación de changelog.