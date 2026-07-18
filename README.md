# Grupo 7 - API REST de E-commerce con Ruby on Rails

API REST desarrollada con Ruby on Rails en modo API y PostgreSQL. El sistema permite gestionar usuarios, autenticación mediante JWT, productos, categorías y posteriormente recibos de compra.

El proyecto reproduce el backend de e-commerce solicitado para el Grupo 7, aplicando arquitectura modular, validaciones, cifrado de contraseñas, manejo centralizado de errores, documentación y pruebas.

## Alcance implementado

- Registro de usuarios.
- Inicio de sesión mediante JWT.
- Contraseñas cifradas con BCrypt.
- Consulta, actualización y eliminación segura de usuarios.
- Control de acceso para impedir que un usuario modifique otra cuenta.
- Manejo de tokens ausentes, inválidos y vencidos.
- Pruebas automatizadas de usuarios, JWT y autorización.
- Modelo `Product` con `name`, `description`, `price`, `stock` y `category_id`.
- Modelo `Category` para clasificar productos.
- CRUD completo de productos.
- CRUD completo de categorias como valor agregado.
- Validaciones de nombre, precio y stock.
- Busqueda/filtros por texto, categoria, precio e inventario disponible.
- Manejo centralizado de errores en JSON.
- Migraciones para PostgreSQL.
- Colección Postman completa en `postman/Grupo7_Ecommerce_API.postman_collection.json`.


## Requisitos

- Ruby 3.2 o superior.
- Ruby on Rails 7.1.
- PostgreSQL 17 o compatible.
- Bundler.
- Postman o la extensión de Postman para Visual Studio Code.

## Instalacion

```bash
bundle install
```

### Variables de entorno

Copia el archivo `.env.example` como `.env` y configura tus valores locales.

```env
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_postgresql_password
DB_NAME=grupo7_ecommerce_development
JWT_SECRET=generate_with_rails_secret
```

Para generar la clave JWT:

```bash
bundle exec rails secret
```

Crear y migrar la base:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

Ejecutar el servidor:

```bash
bundle exec rails server
```

URL base local:

```text
http://localhost:3000
```
## Usuarios y autenticación

### Registrar usuario

```http
POST /api/users/register
```

Body:

```json
{
  "firstName": "Ana",
  "lastName": "Perez",
  "email": "ana@correo.com",
  "password": "Clave123*",
  "passwordConfirmation": "Clave123*",
  "address": "Quito",
  "phoneNumber": "0991234567"
}
```

Respuesta esperada: `201 Created`.

```json
{
  "message": "Usuario registrado correctamente",
  "data": {
    "userId": 1,
    "firstName": "Ana",
    "lastName": "Perez",
    "email": "ana@correo.com",
    "address": "Quito",
    "phoneNumber": "0991234567"
  }
}
```

Las propiedades `password`, `passwordConfirmation` y `password_digest` nunca se devuelven en las respuestas HTTP.

### Iniciar sesión

```http
POST /api/users/login
```

Body:

```json
{
  "email": "ana@correo.com",
  "password": "Clave123*"
}
```

Respuesta esperada: `200 OK`.

```json
{
  "message": "Inicio de sesión correcto",
  "token": "JWT_GENERADO",
  "user": {
    "userId": 1,
    "firstName": "Ana",
    "lastName": "Perez",
    "email": "ana@correo.com"
  }
}
```

### Utilizar el JWT

Las rutas protegidas requieren el encabezado:

```http
Authorization: Bearer JWT_GENERADO
```

### Consultar perfil

```http
GET /api/users/:id
```

Requiere JWT. El usuario solamente puede consultar su propia cuenta.

### Actualizar perfil

```http
PUT /api/users/:id
```

Ejemplo:

```json
{
  "firstName": "Ana Maria",
  "address": "Quito norte",
  "phoneNumber": "0987654321"
}
```

La actualización puede ser parcial.

### Eliminar usuario

```http
DELETE /api/users/:id
```

Respuesta esperada:

```http
204 No Content
```

El usuario solamente puede eliminar su propia cuenta.

## Validaciones de usuario

- Nombre obligatorio y máximo de 80 caracteres.
- Apellido obligatorio y máximo de 80 caracteres.
- Correo obligatorio, válido y único.
- El correo se almacena en minúsculas.
- Contraseña mínima de 8 caracteres.
- Confirmación de contraseña obligatoria y coincidente.
- Teléfono opcional de entre 7 y 15 dígitos.
- Dirección opcional.
- Contraseña almacenada con BCrypt en `password_digest`.

## Seguridad

- Autenticación basada en JSON Web Token.
- Token firmado con el algoritmo `HS256`.
- Expiración del token después de 24 horas.
- Contraseñas cifradas con BCrypt.
- Credenciales excluidas de todas las respuestas JSON.
- Rutas protegidas con `Authorization: Bearer`.
- Respuesta `401 Unauthorized` para token ausente, inválido o vencido.
- Respuesta `403 Forbidden` al intentar acceder a la cuenta de otro usuario.




## Endpoints de productos

### Crear producto

`POST /api/products`

Body:

```json
{
  "product": {
    "name": "Teclado mecanico",
    "description": "Teclado USB con switches mecanicos.",
    "price": 49.99,
    "stock": 15,
    "category_id": 1
  }
}
```

Respuesta `201 Created`.

### Listar productos

`GET /api/products`

Filtros opcionales:

- `q` o `search`: busca en nombre y descripcion.
- `category_id`: filtra por categoria.
- `min_price`: precio minimo.
- `max_price`: precio maximo.
- `in_stock`: `true` para productos con stock mayor que cero; `false` para agotados.

Ejemplo:

```text
GET /api/products?q=teclado&min_price=10&max_price=100&in_stock=true
```

### Buscar producto por id

`GET /api/products/:id`

### Actualizar producto

`PUT /api/products/:id`

Body:

```json
{
  "product": {
    "name": "Teclado mecanico RGB",
    "price": 54.99,
    "stock": 12
  }
}
```

### Eliminar producto

`DELETE /api/products/:id`

Respuesta `204 No Content`.

## Endpoints de categorias

```text
POST   /api/categories
GET    /api/categories
GET    /api/categories/:id
PUT    /api/categories/:id
DELETE /api/categories/:id
```

Body para crear categoria:

```json
{
  "category": {
    "name": "Tecnologia",
    "description": "Productos electronicos y accesorios."
  }
}
```

## Validaciones

`Product`:

- `name` es obligatorio y maximo 120 caracteres.
- `price` es obligatorio y debe ser mayor a 0.
- `stock` es obligatorio, entero y mayor o igual a 0.
- `description` es opcional y maximo 1000 caracteres.

`Category`:

- `name` es obligatorio, unico sin distinguir mayusculas/minusculas y maximo 80 caracteres.
- `description` es opcional y maximo 500 caracteres.

## Formato de errores

Ejemplo de validacion fallida:

```json
{
  "error": {
    "message": "Datos invalidos",
    "details": {
      "price": ["Price debe ser mayor que 0"],
      "stock": ["Stock debe ser mayor o igual que 0"]
    }
  }
}
```

Ejemplo de recurso inexistente:

```json
{
  "error": {
    "message": "Recurso no encontrado",
    "details": "Couldn't find Product with 'id'=99"
  }
}
```
## Pruebas automatizadas

Preparar la base de pruebas:

```bash
bundle exec rails db:test:prepare
```

Ejecutar todas las pruebas:

```bash
bundle exec rails test
```

Resultado obtenido para el módulo de usuarios:

```text
22 runs
67 assertions
0 failures
0 errors
0 skips
```

Las pruebas cubren:

- Validaciones del modelo `User`.
- Normalización del correo.
- Cifrado BCrypt.
- Generación y decodificación JWT.
- Token inválido y vencido.
- Registro.
- Login.
- Consulta protegida.
- Actualización.
- Eliminación.
- Acceso sin token.
- Acceso a la cuenta de otro usuario.

## Colección Postman

La colección completa se encuentra en:

```text
postman/Grupo7_Ecommerce_API.postman_collection.json
```

Contiene pruebas para:

- Registro de usuario.
- Login y almacenamiento automático del JWT.
- Consulta y actualización del perfil.
- Solicitud sin token.
- Token inválido.
- Eliminación mediante un usuario temporal.
- Productos y categorías.

La URL base utilizada es:

```text
http://localhost:3000
```

## Sustentacion rapida de esta parte

- `Product` representa los productos del e-commerce y se guarda en PostgreSQL con precio decimal para evitar errores de precision.
- `Category` permite agrupar productos y se relaciona con `Product` mediante `category_id`.
- Las validaciones estan en los modelos porque son reglas del dominio.
- Los controladores solo reciben parametros, llaman al modelo y devuelven JSON.
- `ApplicationController` centraliza los errores para que las respuestas sean consistentes.
- La busqueda y filtros estan en `GET /api/products`, como valor agregado.

## Sustentación rápida de usuarios y seguridad

- `User` representa a los usuarios registrados en el e-commerce.
- Las contraseñas nunca se almacenan en texto plano; se cifran mediante BCrypt en `password_digest`.
- El registro valida nombres, correo, contraseña, teléfono y duplicidad del correo.
- El login compara la contraseña mediante `authenticate` y genera un token JWT.
- El JWT contiene el identificador del usuario y una fecha de expiración.
- Las rutas protegidas requieren el encabezado `Authorization: Bearer TOKEN`.
- Un usuario solo puede consultar, actualizar o eliminar su propia cuenta.
- `ApplicationController` centraliza los errores de autenticación, autorización y validación.
- Las respuestas JSON nunca incluyen la contraseña ni `password_digest`.