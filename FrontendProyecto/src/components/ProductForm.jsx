import { useEffect, useState } from 'react'

const emptyProduct = {
  name: '',
  description: '',
  price: '',
  stock: '',
  category_id: '',
}

function ProductForm({ categories, editingProduct, isSaving, onCancel, onSubmit }) {
  const [form, setForm] = useState(emptyProduct)

  useEffect(() => {
    if (!editingProduct) {
      setForm(emptyProduct)
      return
    }

    setForm({
      name: editingProduct.name || '',
      description: editingProduct.description || '',
      price: editingProduct.price || '',
      stock: String(editingProduct.stock ?? ''),
      category_id: editingProduct.category?.id ? String(editingProduct.category.id) : '',
    })
  }, [editingProduct])

  function handleChange(event) {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
  }

  function handleSubmit(event) {
    event.preventDefault()
    onSubmit({
      ...form,
      stock: Number(form.stock),
      category_id: form.category_id ? Number(form.category_id) : '',
    })
  }

  return (
    <form className="form-panel" onSubmit={handleSubmit}>
      <div className="section-heading">
        <h2>{editingProduct ? 'Editar producto' : 'Nuevo producto'}</h2>
      </div>

      <label>
        Nombre
        <input name="name" value={form.name} onChange={handleChange} required />
      </label>

      <label>
        Descripcion
        <input name="description" value={form.description} onChange={handleChange} />
      </label>

      <div className="two-columns">
        <label>
          Precio
          <input
            name="price"
            type="number"
            min="0.01"
            step="0.01"
            value={form.price}
            onChange={handleChange}
            required
          />
        </label>

        <label>
          Stock
          <input
            name="stock"
            type="number"
            min="0"
            step="1"
            value={form.stock}
            onChange={handleChange}
            required
          />
        </label>
      </div>

      <label>
        Categoria
        <select name="category_id" value={form.category_id} onChange={handleChange}>
          <option value="">Sin categoria</option>
          {categories.map((category) => (
            <option key={category.id} value={category.id}>
              {category.name}
            </option>
          ))}
        </select>
      </label>

      <div className="actions-row">
        <button type="submit" className="primary-button" disabled={isSaving}>
          {isSaving ? 'Guardando...' : editingProduct ? 'Actualizar' : 'Crear producto'}
        </button>

        {editingProduct ? (
          <button type="button" className="ghost-button" onClick={onCancel}>
            Cancelar
          </button>
        ) : null}
      </div>
    </form>
  )
}

export default ProductForm
