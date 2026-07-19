import { useEffect, useState } from 'react'

const emptyCategory = {
  name: '',
  description: '',
}

function CategoryForm({ editingCategory, isSaving, onCancel, onSubmit }) {
  const [form, setForm] = useState(emptyCategory)

  useEffect(() => {
    if (!editingCategory) {
      setForm(emptyCategory)
      return
    }

    setForm({
      name: editingCategory.name || '',
      description: editingCategory.description || '',
    })
  }, [editingCategory])

  function handleChange(event) {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
  }

  function handleSubmit(event) {
    event.preventDefault()
    onSubmit(form)
  }

  return (
    <form className="form-panel" onSubmit={handleSubmit}>
      <div className="section-heading">
        <h2>{editingCategory ? 'Editar categoria' : 'Nueva categoria'}</h2>
      </div>

      <label>
        Nombre
        <input name="name" value={form.name} onChange={handleChange} required />
      </label>

      <label>
        Descripcion
        <input name="description" value={form.description} onChange={handleChange} />
      </label>

      <div className="actions-row">
        <button type="submit" className="primary-button" disabled={isSaving}>
          {isSaving ? 'Guardando...' : editingCategory ? 'Actualizar' : 'Crear categoria'}
        </button>

        {editingCategory ? (
          <button type="button" className="ghost-button" onClick={onCancel}>
            Cancelar
          </button>
        ) : null}
      </div>
    </form>
  )
}

export default CategoryForm
