# Grupo 7 - API REST Rails: Products y Categories

Backend API en Ruby on Rails para la parte de productos, categorias y documentacion del proyecto de e-commerce.

## Alcance implementado

- Modelo `Product` con `name`, `description`, `price`, `stock` y `category_id`.
- Modelo `Category` para clasificar productos.
- CRUD completo de productos.
- CRUD completo de categorias como valor agregado.
- Validaciones de nombre, precio y stock.
- Busqueda/filtros por texto, categoria, precio e inventario disponible.
- Manejo centralizado de errores en JSON.
- Migraciones para PostgreSQL.
- Coleccion Postman en `postman/Grupo7_Products_Categories.postman_collection.json`.

## Requisitos

- Ruby 3.2 o superior.
- PostgreSQL.
- Bundler.

## Instalacion

```bash
bundle install
```

Configura la base de datos con variables de entorno o deja los valores por defecto:

```bash
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=grupo7_ecommerce_development
```

Crear y migrar la base:

```bash
rails db:create
rails db:migrate
rails db:seed
```

Ejecutar el servidor:

```bash
rails server
```

URL base local:

```text
http://localhost:3000
```

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

## Sustentacion rapida de esta parte

- `Product` representa los productos del e-commerce y se guarda en PostgreSQL con precio decimal para evitar errores de precision.
- `Category` permite agrupar productos y se relaciona con `Product` mediante `category_id`.
- Las validaciones estan en los modelos porque son reglas del dominio.
- Los controladores solo reciben parametros, llaman al modelo y devuelven JSON.
- `ApplicationController` centraliza los errores para que las respuestas sean consistentes.
- La busqueda y filtros estan en `GET /api/products`, como valor agregado.
