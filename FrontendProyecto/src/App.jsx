import { useEffect, useState } from 'react'
import ProductsPage from './pages/ProductsPage.jsx'
import CategoriesPage from './pages/CategoriesPage.jsx'
import LoginPage from './pages/LoginPage.jsx'
import ShopPage from './pages/ShopPage.jsx'
import './App.css'

const sessionKey = 'grupo7-ecommerce-session'

function App() {
  const [session, setSession] = useState(() => readSession())
  const [activePage, setActivePage] = useState('shop')
  const isAdmin = session?.user?.role === 'admin'

  useEffect(() => {
    if (!isAdmin && ['products', 'categories'].includes(activePage)) {
      setActivePage('shop')
    }
  }, [activePage, isAdmin])

  function handleLogin(nextSession) {
    localStorage.setItem(sessionKey, JSON.stringify(nextSession))
    setSession(nextSession)
  }

  function handleLogout() {
    localStorage.removeItem(sessionKey)
    setSession(null)
    setActivePage('login')
  }

  return (
    <main className="app-shell">
      <header className="app-header">
        <div>
          <p className="eyebrow">Grupo 7 Ecommerce</p>
          <h1>Tienda y administracion</h1>
        </div>

        <nav className="nav-tabs" aria-label="Secciones">
          <button
            type="button"
            className={activePage === 'shop' ? 'active' : ''}
            onClick={() => setActivePage('shop')}
          >
            Tienda
          </button>
          {isAdmin ? (
            <>
              <button
                type="button"
                className={activePage === 'products' ? 'active' : ''}
                onClick={() => setActivePage('products')}
              >
                Productos
              </button>
              <button
                type="button"
                className={activePage === 'categories' ? 'active' : ''}
                onClick={() => setActivePage('categories')}
              >
                Categorias
              </button>
            </>
          ) : null}
          <button
            type="button"
            className={activePage === 'login' ? 'active' : ''}
            onClick={() => setActivePage('login')}
          >
            Sesion
          </button>
        </nav>
      </header>

      {activePage === 'shop' ? <ShopPage session={session} onGoToLogin={() => setActivePage('login')} /> : null}
      {activePage === 'products' && isAdmin ? <ProductsPage session={session} /> : null}
      {activePage === 'categories' && isAdmin ? <CategoriesPage session={session} /> : null}
      {activePage === 'login' ? (
        <LoginPage session={session} onLogin={handleLogin} onLogout={handleLogout} />
      ) : null}
    </main>
  )
}

function readSession() {
  try {
    const savedSession = localStorage.getItem(sessionKey)
    return savedSession ? JSON.parse(savedSession) : null
  } catch {
    return null
  }
}

export default App
