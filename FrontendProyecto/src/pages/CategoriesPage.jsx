import { useCallback, useEffect, useState } from 'react'
import CategoryForm from '../components/CategoryForm.jsx'
import {
  createCategory,
  deleteCategory,
  formatApiError,
  getCategories,
  updateCategory,
} from '../api/client.js'

function CategoriesPage({ session }) {
  const [categories, setCategories] = useState([])
  const [editingCategory, setEditingCategory] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [notice, setNotice] = useState(null)

  const loadCategories = useCallback(async () => {
    setLoading(true)
    try {
      setCategories(await getCategories())
    } catch (error) {
      setCategories([])
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    loadCategories()
  }, [loadCategories])

  async function handleSubmit(category) {
    setSaving(true)
    setNotice(null)

    try {
      if (editingCategory) {
        await updateCategory(editingCategory.id, category, session.token)
        setNotice({ type: 'success', text: 'Categoria actualizada correctamente.' })
      } else {
        await createCategory(category, session.token)
        setNotice({ type: 'success', text: 'Categoria creada correctamente.' })
      }

      setEditingCategory(null)
      await loadCategories()
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setSaving(false)
    }
  }

  async function handleDelete(category) {
    const accepted = window.confirm(`Eliminar categoria "${category.name}"?`)

    if (!accepted) {
      return
    }

    try {
      await deleteCategory(category.id, session.token)
      setNotice({ type: 'success', text: 'Categoria eliminada correctamente.' })
      await loadCategories()
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    }
  }

  return (
    <section className="page-grid">
      <CategoryForm
        editingCategory={editingCategory}
        isSaving={saving}
        onCancel={() => setEditingCategory(null)}
        onSubmit={handleSubmit}
      />

      <section className="content-panel">
        <div className="section-heading">
          <h2>Categorias</h2>
          <span>{loading ? 'Cargando...' : `${categories.length} registro(s)`}</span>
        </div>

        {notice ? (
          <div className={`notice ${notice.type}`} role="status">
            {notice.text}
          </div>
        ) : null}

        {loading ? (
          <p className="empty-state">Cargando categorias...</p>
        ) : categories.length === 0 ? (
          <p className="empty-state">No hay categorias para mostrar.</p>
        ) : (
          <div className="data-grid categories-grid">
            {categories.map((category) => (
              <article className="data-card" key={category.id}>
                <div className="card-meta">
                  <span>Categoria</span>
                  <span>ID {category.id}</span>
                </div>

                <h3>{category.name}</h3>
                <p>{category.description || 'Sin descripcion'}</p>

                <div className="actions-row compact">
                  <button type="button" className="secondary-button" onClick={() => setEditingCategory(category)}>
                    Editar
                  </button>
                  <button type="button" className="danger-button" onClick={() => handleDelete(category)}>
                    Eliminar
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>
    </section>
  )
}

export default CategoriesPage
