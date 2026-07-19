const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/$/, '')

export class ApiError extends Error {
  constructor(message, status, details) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.details = details
  }
}

export function formatApiError(error) {
  if (error instanceof ApiError) {
    const details = formatDetails(error.details)
    return details ? `${error.message}: ${details}` : error.message
  }

  if (error instanceof TypeError) {
    return 'No se pudo conectar con el backend. Revisa que Rails este corriendo en http://localhost:3000.'
  }

  return 'Ocurrio un error inesperado.'
}

export async function loginUser(credentials) {
  return request('/users/login', {
    method: 'POST',
    body: credentials,
  })
}

export async function registerUser(user) {
  const response = await request('/users/register', {
    method: 'POST',
    body: cleanUser(user),
  })

  return response.data
}

export async function getProducts(filters = {}) {
  const params = new URLSearchParams()

  if (filters.q?.trim()) {
    params.set('q', filters.q.trim())
  }

  if (filters.categoryId) {
    params.set('category_id', filters.categoryId)
  }

  if (filters.inStock) {
    params.set('in_stock', 'true')
  }

  const query = params.toString()
  const response = await request(`/products${query ? `?${query}` : ''}`)
  return response.data
}

export async function createProduct(product, token) {
  const response = await request('/products', {
    method: 'POST',
    token,
    body: { product: cleanProduct(product) },
  })

  return response.data
}

export async function updateProduct(id, product, token) {
  const response = await request(`/products/${id}`, {
    method: 'PUT',
    token,
    body: { product: cleanProduct(product) },
  })

  return response.data
}

export async function deleteProduct(id, token) {
  await request(`/products/${id}`, { method: 'DELETE', token })
}

export async function createReceipt(token, items) {
  const response = await request('/receipts', {
    method: 'POST',
    token,
    body: { items },
  })

  return response.data
}

export async function getReceipts(token) {
  const response = await request('/receipts', { token })
  return response.data
}

export async function getCategories() {
  const response = await request('/categories')
  return response.data
}

export async function createCategory(category, token) {
  const response = await request('/categories', {
    method: 'POST',
    token,
    body: { category },
  })

  return response.data
}

export async function updateCategory(id, category, token) {
  const response = await request(`/categories/${id}`, {
    method: 'PUT',
    token,
    body: { category },
  })

  return response.data
}

export async function deleteCategory(id, token) {
  await request(`/categories/${id}`, { method: 'DELETE', token })
}

async function request(path, options = {}) {
  const headers = new Headers(options.headers)

  headers.set('Accept', 'application/json')

  const config = {
    ...options,
    headers,
  }

  if (options.body) {
    headers.set('Content-Type', 'application/json')
    config.body = JSON.stringify(options.body)
  }

  if (options.token) {
    headers.set('Authorization', `Bearer ${options.token}`)
  }

  delete config.token

  const response = await fetch(`${API_BASE_URL}${path}`, config)
  const payload = await parsePayload(response)

  if (!response.ok) {
    throw new ApiError(
      payload?.error?.message || `Solicitud rechazada (${response.status})`,
      response.status,
      payload?.error?.details,
    )
  }

  return payload
}

async function parsePayload(response) {
  const text = await response.text()

  if (!text) {
    return null
  }

  try {
    return JSON.parse(text)
  } catch {
    return null
  }
}

function cleanProduct(product) {
  return {
    name: product.name,
    description: product.description,
    price: product.price,
    stock: product.stock,
    category_id: product.category_id || null,
  }
}

function cleanUser(user) {
  return {
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    password: user.password,
    passwordConfirmation: user.passwordConfirmation,
    ...(user.address ? { address: user.address } : {}),
    ...(user.phoneNumber ? { phoneNumber: user.phoneNumber } : {}),
  }
}

function formatDetails(details) {
  if (!details) {
    return ''
  }

  if (typeof details === 'string') {
    return details
  }

  if (Array.isArray(details)) {
    return details.join(', ')
  }

  if (typeof details === 'object') {
  if (details.password_confirmation) {
    return 'Las contrasenas no coinciden.'
  }

  if (details.email) {
    return 'El correo ya esta registrado o no es valido.'
  }

  if (details.password) {
    return 'La contrasena debe tener al menos 8 caracteres.'
  }

  return 'Revisa los datos ingresados.'
}

  return String(details)
}
