import { useCallback, useEffect, useState } from 'react'
import ProductForm from '../components/ProductForm.jsx'
import {
  createProduct,
  deleteProduct,
  formatApiError,
  getCategories,
  getProducts,
  updateProduct,
} from '../api/client.js'

const initialFilters = {
  q: '',
  categoryId: '',
  inStock: false,
}

function ProductsPage({ session }) {
  const [products, setProducts] = useState([])
  const [categories, setCategories] = useState([])
  const [filters, setFilters] = useState(initialFilters)
  const [appliedFilters, setAppliedFilters] = useState(initialFilters)
  const [editingProduct, setEditingProduct] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [notice, setNotice] = useState(null)

  const loadCategories = useCallback(async () => {
    try {
      setCategories(await getCategories())
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    }
  }, [])

  const loadProducts = useCallback(async () => {
    setLoading(true)
    try {
      setProducts(await getProducts(appliedFilters))
    } catch (error) {
      setProducts([])
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setLoading(false)
    }
  }, [appliedFilters])

  useEffect(() => {
    loadCategories()
  }, [loadCategories])

  useEffect(() => {
    loadProducts()
  }, [loadProducts])

  function handleFilterChange(event) {
    const { name, value } = event.target
    const nextValue = event.target.type === 'checkbox' ? event.target.checked : value
    setFilters((current) => ({ ...current, [name]: nextValue }))
  }

  function handleFilterSubmit(event) {
    event.preventDefault()
    setAppliedFilters(filters)
  }

  function clearFilters() {
    setFilters(initialFilters)
    setAppliedFilters(initialFilters)
  }

  async function handleSubmit(product) {
    setSaving(true)
    setNotice(null)

    try {
      if (editingProduct) {
        await updateProduct(editingProduct.id, product, session.token)
        setNotice({ type: 'success', text: 'Producto actualizado correctamente.' })
      } else {
        await createProduct(product, session.token)
        setNotice({ type: 'success', text: 'Producto creado correctamente.' })
      }

      setEditingProduct(null)
      await loadProducts()
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setSaving(false)
    }
  }

  async function handleDelete(product) {
    const accepted = window.confirm(`Eliminar producto "${product.name}"?`)

    if (!accepted) {
      return
    }

    try {
      await deleteProduct(product.id, session.token)
      setNotice({ type: 'success', text: 'Producto eliminado correctamente.' })
      await loadProducts()
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    }
  }

  return (
    <section className="page-grid">
      <ProductForm
        categories={categories}
        editingProduct={editingProduct}
        isSaving={saving}
        onCancel={() => setEditingProduct(null)}
        onSubmit={handleSubmit}
      />

      <section className="content-panel">
        <div className="section-heading">
          <h2>Productos</h2>
          <span>{loading ? 'Cargando...' : `${products.length} resultado(s)`}</span>
        </div>

        {notice ? (
          <div className={`notice ${notice.type}`} role="status">
            {notice.text}
          </div>
        ) : null}

        <form className="filters" onSubmit={handleFilterSubmit}>
          <label>
            Buscar
            <input name="q" value={filters.q} onChange={handleFilterChange} placeholder="Nombre o descripcion" />
          </label>

          <label>
            Categoria
            <select name="categoryId" value={filters.categoryId} onChange={handleFilterChange}>
              <option value="">Todas</option>
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </label>

          <label className="checkbox-field">
            <input name="inStock" type="checkbox" checked={filters.inStock} onChange={handleFilterChange} />
            Solo disponibles
          </label>

          <div className="filter-actions">
            <button type="submit" className="secondary-button">
              Buscar
            </button>
            <button type="button" className="ghost-button" onClick={clearFilters}>
              Limpiar
            </button>
          </div>
        </form>

        {loading ? (
          <p className="empty-state">Cargando productos...</p>
        ) : products.length === 0 ? (
          <p className="empty-state">No hay productos para mostrar.</p>
        ) : (
          <div className="data-grid">
            {products.map((product) => (
              <article className="data-card" key={product.id}>
                <div className="card-meta">
                  <span>{product.category?.name || 'Sin categoria'}</span>
                  <span>{product.stock} en stock</span>
                </div>

                <h3>{product.name}</h3>
                <p>{product.description || 'Sin descripcion'}</p>

                <div className="product-footer">
                  <strong>{formatMoney(product.price)}</strong>
                  <div className="actions-row compact">
                    <button type="button" className="secondary-button" onClick={() => setEditingProduct(product)}>
                      Editar
                    </button>
                    <button type="button" className="danger-button" onClick={() => handleDelete(product)}>
                      Eliminar
                    </button>
                  </div>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>
    </section>
  )
}

function formatMoney(value) {
  return new Intl.NumberFormat('es-EC', {
    style: 'currency',
    currency: 'USD',
  }).format(Number(value) || 0)
}

export default ProductsPage
