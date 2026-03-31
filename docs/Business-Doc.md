# Mejorar documentacion de puntos( creacion de entidades, comercios, usuarios owners, y los de branch, etc)
Tambien:



# Cargar puntos desde entidad
Debe ingresar como entidad, debe ser entidad de tipo grupo (son las de ej:INTEGRAL)
Se debe ir por menu a: Personas -> Cta.cte de una persona -> Boton 'Carga de entidad'
Genera un movimiento particular de carga de puntos
Actualmente (oct 2025) no se puede hacer cargas de entidad a por ejemplo los de tipo store(club propio).


# Tipos de entidad
Existen dos tipos de entidad que realizan muchas cosas de formas diferentes,
Entidad de tipo Grupo y entidad de Tipo Store
Carga de puntos -> Tipo group carga puntos para todas las companies, Tipo Store carga puntos solo por company(pero aun puede ser compartidas por branches)
La cuenta corriente y visibilidad de puntos de un usuario dependeré del grupo al que corresponde o fue cargado como cliente.


# Personas
Las personas son cargadas una sola vez en cualquier branch o parte del sistema, los clientes son los que difieren en cuanto a los comercios a los que fueron cargados.

# Mails
Recordar colocar mail(ficticio o no) a cada branch para que los clientes reciban el mail.

# Usarios
Ok ya encontré donde se crea el Gerente general, es cuando se crea o da de alta el Comercio, ahi se elige un usuario que se va a convertir en ese Gerente(company_owner_role)

# Agregar empleados
Desde la opcion de comercios, Ver comercio, Usuarios


## Modelo de Negocio: Store vs Group

### Entidades Tipo Store ("Por Comercio")

• Propósito: Programas de lealtad independientes por negocio
• Mercado objetivo: Negocios individuales o cadenas con tracking separado
• Característica clave: Puntos son específicos por compañía y no se comparten

### Entidades Tipo Group ("Por Entidad")

• Propósito: Gestión centralizada de lealtad across múltiples empresas
• Mercado objetivo: Corporaciones grandes, franquicias, grupos empresariales
• Característica clave: Puntos son portables entre todas las empresas del grupo

---

## Diferencias Operativas Clave

### Acumulación de Puntos

Store-Type:

• Puntos aislados por empresa
• Cliente no puede usar puntos en otra compañía
• Balance específico por negocio

Group-Type:

• Puntos unificados across todo el grupo
• Cliente puede acumular en una empresa y canjear en otra
• Balance único centralizado

### Gestión de Catálogos

Store-Type:

• Catálogo independiente por empresa
• Precios y productos específicos
• Mayor flexibilidad pero más overhead

Group-Type:

• Catálogo compartido para todo el grupo
• Economías de escala
• Precios unificados

El admin y gerente pueden crear catalogos sin restriccion, el ultimo catalogo es mostrado para el caso de tipo store.
---

## Casos de Uso de Negocio

### Group-Type es ideal para:

1. Sistemas de Franquicias (McDonald's, Subway)
2. Centros Comerciales (programa unificado retailers)
3. Grupos Corporativos (subsidiarias con lealtad unificada)
4. Programas de Alianza (socios comerciales compartiendo ecosistema)

### Store-Type es ideal para:

1. Retailers Independientes (negocio único con propio programa)
2. Cadenas de Restaurantes (misma marca pero tracking separado)
3. Servicios Profesionales (lealtad cliente-específica)
4. Negocios con Preocupaciones de Privacidad (aislamiento total de datos)

---

## Implicaciones para tu Feature

Para agregar puntos a clientes, debes considerar el tipo de entidad:

### En Store-Type:

• Movimiento afecta solo el balance de esa empresa
• Permisos a nivel de compañía/branch
• Reportes aislados

### En Group-Type:

• Movimiento podría afectar balance unificado
• Permisos a nivel de grupo
• Reportes consolidados