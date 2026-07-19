import { useCallback, useEffect, useMemo, useState } from 'react'
import {
  createReceipt,
  formatApiError,
  getCategories,
  getProducts,
  getReceipts,
} from '../api/client.js'

const initialFilters = {
  q: '',
  categoryId: '',
  inStock: true,
}

function ShopPage({ session, onGoToLogin }) {
  const [products, setProducts] = useState([])
  const [categories, setCategories] = useState([])
  const [receipts, setReceipts] = useState([])
  const [cart, setCart] = useState([])
  const [filters, setFilters] = useState(initialFilters)
  const [appliedFilters, setAppliedFilters] = useState(initialFilters)
  const [loadingProducts, setLoadingProducts] = useState(true)
  const [loadingReceipts, setLoadingReceipts] = useState(false)
  const [checkoutLoading, setCheckoutLoading] = useState(false)
  const [notice, setNotice] = useState(null)

  const cartTotal = useMemo(
    () => cart.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0),
    [cart],
  )

  const loadProducts = useCallback(async () => {
    setLoadingProducts(true)

    try {
      setProducts(await getProducts(appliedFilters))
    } catch (error) {
      setProducts([])
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setLoadingProducts(false)
    }
  }, [appliedFilters])

  const loadCategories = useCallback(async () => {
    try {
      setCategories(await getCategories())
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    }
  }, [])

  const loadReceipts = useCallback(async () => {
    if (!session?.token) {
      setReceipts([])
      return
    }

    setLoadingReceipts(true)

    try {
      setReceipts(await getReceipts(session.token))
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setLoadingReceipts(false)
    }
  }, [session])

  useEffect(() => {
    loadCategories()
  }, [loadCategories])

  useEffect(() => {
    loadProducts()
  }, [loadProducts])

  useEffect(() => {
    loadReceipts()
  }, [loadReceipts])

  function handleFilterChange(event) {
    const { name, value } = event.target
    const nextValue = event.target.type === 'checkbox' ? event.target.checked : value
    setFilters((current) => ({ ...current, [name]: nextValue }))
  }

  function handleFilterSubmit(event) {
    event.preventDefault()
    setAppliedFilters(filters)
  }

  function addToCart(product) {
    if (product.stock <= 0) {
      return
    }

    setCart((current) => {
      const existingItem = current.find((item) => item.id === product.id)

      if (!existingItem) {
        return [
          ...current,
          {
            id: product.id,
            name: product.name,
            price: product.price,
            stock: product.stock,
            quantity: 1,
          },
        ]
      }

      return current.map((item) =>
        item.id === product.id
          ? { ...item, quantity: Math.min(item.quantity + 1, item.stock) }
          : item,
      )
    })
  }

  function updateQuantity(productId, value) {
    setCart((current) =>
      current.map((item) =>
        item.id === productId
          ? { ...item, quantity: Math.max(1, Math.min(Number(value) || 1, item.stock)) }
          : item,
      ),
    )
  }

  function removeFromCart(productId) {
    setCart((current) => current.filter((item) => item.id !== productId))
  }

  async function handleCheckout() {
    if (!session?.token) {
      setNotice({ type: 'error', text: 'Inicia sesion antes de comprar.' })
      onGoToLogin()
      return
    }

    if (cart.length === 0) {
      return
    }

    setCheckoutLoading(true)
    setNotice(null)

    try {
      const receipt = await createReceipt(
        session.token,
        cart.map((item) => ({
          productId: item.id,
          quantity: item.quantity,
        })),
      )

      setCart([])
      setNotice({ type: 'success', text: `Compra realizada. Recibo #${receipt.receiptId} por ${formatMoney(receipt.total)}.` })
      await loadProducts()
      await loadReceipts()
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setCheckoutLoading(false)
    }
  }

  return (
    <section className="shop-layout">
      <section className="content-panel">
        <div className="section-heading">
          <h2>Tienda</h2>
          <span>{loadingProducts ? 'Cargando...' : `${products.length} producto(s)`}</span>
        </div>

        {notice ? (
          <div className={`notice ${notice.type}`} role="status">
            {notice.text}
          </div>
        ) : null}

        <form className="filters shop-filters" onSubmit={handleFilterSubmit}>
          <label>
            Buscar
            <input name="q" value={filters.q} onChange={handleFilterChange} placeholder="Producto" />
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
            Disponibles
          </label>

          <button type="submit" className="secondary-button">
            Buscar
          </button>
        </form>

        {loadingProducts ? (
          <p className="empty-state">Cargando catalogo...</p>
        ) : products.length === 0 ? (
          <p className="empty-state">No hay productos disponibles.</p>
        ) : (
          <div className="data-grid shop-products">
            {products.map((product) => (
              <article className="data-card" key={product.id}>
                <div className="card-meta">
                  <span>{product.category?.name || 'Sin categoria'}</span>
                  <span>{product.stock} disponibles</span>
                </div>

                <h3>{product.name}</h3>
                <p>{product.description || 'Sin descripcion'}</p>

                <div className="product-footer">
                  <strong>{formatMoney(product.price)}</strong>
                  <button
                    type="button"
                    className="secondary-button"
                    disabled={product.stock === 0}
                    onClick={() => addToCart(product)}
                  >
                    Agregar
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <aside className="side-stack">
        <section className="content-panel">
          <div className="section-heading">
            <h2>Carrito</h2>
            <span>{cart.length} item(s)</span>
          </div>

          {!session ? (
            <button type="button" className="ghost-button full-button" onClick={onGoToLogin}>
              Iniciar sesion
            </button>
          ) : (
            <p className="mini-copy">Comprando como {session.user.firstName}.</p>
          )}

          {cart.length === 0 ? (
            <p className="empty-state">Agrega productos para comprar.</p>
          ) : (
            <ul className="cart-list">
              {cart.map((item) => (
                <li key={item.id}>
                  <div>
                    <strong>{item.name}</strong>
                    <span>{formatMoney(item.price)} c/u</span>
                  </div>

                  <div className="cart-controls">
                    <input
                      aria-label={`Cantidad de ${item.name}`}
                      type="number"
                      min="1"
                      max={item.stock}
                      value={item.quantity}
                      onChange={(event) => updateQuantity(item.id, event.target.value)}
                    />
                    <button type="button" className="ghost-button" onClick={() => removeFromCart(item.id)}>
                      Quitar
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}

          <div className="cart-total">
            <span>Total</span>
            <strong>{formatMoney(cartTotal)}</strong>
          </div>

          <button
            type="button"
            className="primary-button full-button"
            disabled={cart.length === 0 || checkoutLoading}
            onClick={handleCheckout}
          >
            {checkoutLoading ? 'Procesando...' : 'Comprar'}
          </button>
        </section>

        <section className="content-panel">
          <div className="section-heading">
            <h2>Mis recibos</h2>
            <span>{session ? receipts.length : 'Sin sesion'}</span>
          </div>

          {!session ? (
            <p className="empty-state">Inicia sesion para ver tus recibos.</p>
          ) : loadingReceipts ? (
            <p className="empty-state">Cargando recibos...</p>
          ) : receipts.length === 0 ? (
            <p className="empty-state">Aun no tienes compras.</p>
          ) : (
            <div className="receipt-list">
              {receipts.map((receipt) => (
                <article className="receipt-card" key={receipt.receiptId}>
                  <div className="receipt-head">
                    <strong>Recibo #{receipt.receiptId}</strong>
                    <span>{formatDate(receipt.createdAt)}</span>
                  </div>

                  <div className="receipt-total">
                    <span>{receipt.amountOfItems} producto(s)</span>
                    <strong>{formatMoney(receipt.total)}</strong>
                  </div>

                  <ul>
                    {receipt.items.map((item) => (
                      <li key={item.receiptItemId}>
                        <span>{item.productName} x{item.quantity}</span>
                        <strong>{formatMoney(item.subtotal)}</strong>
                      </li>
                    ))}
                  </ul>
                </article>
              ))}
            </div>
          )}
        </section>
      </aside>
    </section>
  )
}

function formatMoney(value) {
  return new Intl.NumberFormat('es-EC', {
    style: 'currency',
    currency: 'USD',
  }).format(Number(value) || 0)
}

function formatDate(value) {
  const date = new Date(value)

  if (Number.isNaN(date.getTime())) {
    return 'Fecha no disponible'
  }

  return new Intl.DateTimeFormat('es-EC', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date)
}

export default ShopPage
