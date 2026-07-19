# WebProyectoFinal - Grupo 7

API REST de e-commerce desarrollada con Ruby on Rails API, PostgreSQL, JWT y BCrypt. El repositorio tambien incluye un frontend React/Vite en la carpeta `FrontendProyecto`.

## Estado General

| Componente | Estado |
|---|---|
| Backend Rails API | Implementado |
| PostgreSQL y migraciones | Implementado |
| Usuarios y login JWT | Implementado |
| Roles `usuario` y `admin` | Implementado |
| CRUD de productos | Implementado |
| CRUD de categorias | Implementado |
| Recibos de compra | Implementado |
| Calculo de total en backend | Implementado |
| Validacion y descuento de stock | Implementado |
| Manejo centralizado de errores | Implementado |
| OpenAPI | `docs/openapi.yaml` |
| Postman | `postman/Grupo7_Ecommerce_API.postman_collection.json` |
| Frontend | `FrontendProyecto` |
| Script SQL de base de datos | `db/database.sql` |

## Tecnologias

Backend:

- Ruby 3.2 o superior
- Ruby on Rails 7.1 en modo API
- ActiveRecord
- PostgreSQL
- JWT
- BCrypt
- Minitest

Frontend:

- React
- Vite
- JavaScript
- CSS

## Arquitectura

```text
app/
  controllers/
    application_controller.rb
    api/
      auth_controller.rb
      users_controller.rb
      products_controller.rb
      categories_controller.rb
      receipts_controller.rb
  models/
    user.rb
    product.rb
    category.rb
    receipt.rb
    receipt_item.rb
  services/
    json_web_token.rb
    receipts/
      create_service.rb
      delete_service.rb
  serializers/
    user_serializer.rb
    receipt_serializer.rb
  errors/
    business_rule_error.rb

FrontendProyecto/
  src/
    api/
    components/
    pages/
```

Los controladores reciben solicitudes HTTP y responden JSON. Los modelos concentran relaciones y validaciones. Los servicios manejan logica de negocio como JWT, creacion de recibos, transacciones y restauracion de stock. Los serializers actuan como DTOs de salida.

## Modelo de Datos

```text
User 1---N Receipt
Receipt 1---N ReceiptItem
Product 1---N ReceiptItem
Category 1---N Product
```

Entidades principales:

- `User`: usuarios con credenciales protegidas, datos personales y rol.
- `Product`: productos con precio decimal, stock y categoria opcional.
- `Category`: clasificacion de productos.
- `Receipt`: cabecera de compra de un usuario.
- `ReceiptItem`: detalle de productos comprados, cantidad, precio unitario y subtotal.

## Reglas de Negocio

- El cliente no envia el total de la compra.
- El backend calcula subtotales y total usando precios reales guardados en PostgreSQL.
- El usuario del recibo se obtiene desde el token JWT.
- Antes de crear un recibo se valida que cada producto exista.
- Antes de confirmar la compra se valida stock suficiente.
- Al crear un recibo se descuenta stock automaticamente.
- La creacion del recibo se ejecuta dentro de una transaccion.
- Si una compra falla, no se descuenta stock.
- Al eliminar un recibo se restaura el stock de sus productos.
- Las contrasenas se guardan con BCrypt y no se devuelven en respuestas HTTP.
- Productos y categorias solo pueden crearse, actualizarse o eliminarse con un usuario `admin`.

## Requisitos

- Ruby 3.2 o superior
- PostgreSQL
- Bundler
- Node.js y npm para el frontend
- Git

## Variables de Entorno

Configura estas variables antes de ejecutar el backend:

```env
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=tu_clave_postgresql
DB_NAME=grupo7_ecommerce_development
JWT_SECRET=una_clave_segura_generada_con_rails_secret
ADMIN_EMAIL=admin@grupo7.com
ADMIN_PASSWORD=Admin123*
```

En Windows PowerShell:

```powershell
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="5432"
$env:DB_USERNAME="postgres"
$env:DB_PASSWORD="tu_clave_postgresql"
$env:DB_NAME="grupo7_ecommerce_development"
$env:JWT_SECRET="cambia_esta_clave"
```

Para generar una clave JWT segura:

```bash
bundle exec rails secret
```

## Ejecutar Backend

```bash
bundle install
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails server
```

Servidor local:

```text
http://localhost:3000
```

Probar rapidamente:

```text
GET http://localhost:3000/api/products
```

## Ejecutar Frontend

El frontend esta en:

```text
FrontendProyecto
```

Comandos:

```bash
cd FrontendProyecto
npm install
npm run dev
```

Vite inicia normalmente en:

```text
http://localhost:5173
```

El frontend usa proxy de Vite para enviar `/api` hacia `http://localhost:3000`, por eso el backend debe estar encendido al mismo tiempo.

## Usuario Administrador de Prueba

`db:seed` crea un administrador por defecto:

```text
email: admin@grupo7.com
password: Admin123*
role: admin
```

Puedes cambiar esos valores con `ADMIN_EMAIL` y `ADMIN_PASSWORD`.

## Autenticacion

Login:

```http
POST /api/users/login
```

Body:

```json
{
  "email": "admin@grupo7.com",
  "password": "Admin123*"
}
```

Las rutas protegidas usan:

```http
Authorization: Bearer TOKEN_JWT
```

El token expira despues de 24 horas.

## Endpoints

### Usuarios

| Metodo | Ruta | Auth | Descripcion |
|---|---|---|---|
| POST | `/api/users/register` | No | Registrar usuario |
| POST | `/api/users/login` | No | Iniciar sesion |
| GET | `/api/users/:id` | Si | Consultar cuenta propia |
| PUT | `/api/users/:id` | Si | Actualizar cuenta propia |
| DELETE | `/api/users/:id` | Si | Eliminar cuenta propia |

### Productos

| Metodo | Ruta | Auth | Descripcion |
|---|---|---|---|
| GET | `/api/products` | No | Listar y filtrar productos |
| GET | `/api/products/:id` | No | Consultar producto |
| POST | `/api/products` | Admin | Crear producto |
| PUT | `/api/products/:id` | Admin | Actualizar producto |
| DELETE | `/api/products/:id` | Admin | Eliminar producto |

Filtros:

```text
q
search
category_id
min_price
max_price
in_stock
```

Ejemplo:

```http
GET /api/products?q=teclado&category_id=1&min_price=10&max_price=100&in_stock=true
```

### Categorias

| Metodo | Ruta | Auth | Descripcion |
|---|---|---|---|
| GET | `/api/categories` | No | Listar categorias |
| GET | `/api/categories/:id` | No | Consultar categoria |
| POST | `/api/categories` | Admin | Crear categoria |
| PUT | `/api/categories/:id` | Admin | Actualizar categoria |
| DELETE | `/api/categories/:id` | Admin | Eliminar categoria |

### Recibos

| Metodo | Ruta | Auth | Descripcion |
|---|---|---|---|
| POST | `/api/receipts` | Si | Crear compra y descontar stock |
| GET | `/api/receipts` | Si | Listar recibos del usuario autenticado |
| GET | `/api/receipts/:id` | Si | Consultar recibo propio |
| GET | `/api/receipts/user/:user_id` | Si | Listar recibos de usuario autenticado |
| DELETE | `/api/receipts/:id` | Si | Eliminar recibo y restaurar stock |

## Ejemplos

Crear categoria como admin:

```http
POST /api/categories
Authorization: Bearer TOKEN_ADMIN
Content-Type: application/json
```

```json
{
  "category": {
    "name": "Tecnologia",
    "description": "Productos electronicos y accesorios"
  }
}
```

Crear producto como admin:

```http
POST /api/products
Authorization: Bearer TOKEN_ADMIN
Content-Type: application/json
```

```json
{
  "product": {
    "name": "Teclado mecanico",
    "description": "Teclado USB con switches mecanicos",
    "price": 49.99,
    "stock": 15,
    "category_id": 1
  }
}
```

Crear recibo como usuario autenticado:

```http
POST /api/receipts
Authorization: Bearer TOKEN_JWT
Content-Type: application/json
```

```json
{
  "items": [
    {
      "productId": 1,
      "quantity": 2
    }
  ]
}
```

## Formato de Errores

```json
{
  "error": {
    "message": "Datos invalidos",
    "details": {
      "price": ["debe ser mayor que 0"]
    }
  }
}
```

Casos manejados:

- Token ausente, invalido o vencido.
- Acceso a recursos de otro usuario.
- Usuario sin rol administrador.
- Parametros invalidos.
- Producto inexistente.
- Stock insuficiente.
- Validaciones de modelos.

## Base de Datos

La base se puede construir de dos formas:

1. Con migraciones Rails:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

2. Con el script SQL incluido:

```text
db/database.sql
```

El archivo `db/schema.rb` representa el estado actual generado por Rails.

## Pruebas

Ejecutar:

```bash
bundle exec rails test
```

La suite cubre:

- Validaciones de modelos.
- Registro y login.
- JWT.
- Rutas protegidas.
- Creacion de recibos.
- Calculo de total en backend.
- Descuento y restauracion de stock.
- Errores de reglas de negocio.

## Documentacion y Evidencias

- OpenAPI: `docs/openapi.yaml`
- Postman: `postman/Grupo7_Ecommerce_API.postman_collection.json`
- Evidencias: `docs/evidencias`

## Flujo Sugerido para Sustentacion

1. Levantar PostgreSQL.
2. Ejecutar backend Rails en `localhost:3000`.
3. Ejecutar frontend React en `localhost:5173`.
4. Iniciar sesion como admin.
5. Crear una categoria.
6. Crear un producto.
7. Ver productos desde la tienda.
8. Registrar o iniciar sesion como usuario.
9. Agregar productos al carrito.
10. Crear una compra.
11. Ver el recibo generado.
12. Confirmar que el stock bajo automaticamente.

## Repositorio

```text
https://github.com/Vaziii/WebProyectoFinal
```
