import { useState } from 'react'

const emptyRegister = {
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  passwordConfirmation: '',
  address: '',
  phoneNumber: '',
}

function RegisterForm({ isSaving, onSubmit }) {
  const [form, setForm] = useState(emptyRegister)

  function handleChange(event) {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
  }

  function handleSubmit(event) {
    event.preventDefault()
    onSubmit(form)
  }

  return (
    <form className="form-panel login-form" onSubmit={handleSubmit}>
      <div className="section-heading">
        <h2>Crear cuenta</h2>
      </div>

      <div className="two-columns">
        <label>
          Nombre
          <input name="firstName" value={form.firstName} onChange={handleChange} required />
        </label>

        <label>
          Apellido
          <input name="lastName" value={form.lastName} onChange={handleChange} required />
        </label>
      </div>

      <label>
        Correo
        <input
          name="email"
          type="email"
          value={form.email}
          onChange={handleChange}
          placeholder="correo@ejemplo.com"
          required
        />
      </label>

      <div className="two-columns">
        <label>
          Contrasena
          <input
            name="password"
            type="password"
            value={form.password}
            onChange={handleChange}
            minLength={8}
            required
          />
        </label>

        <label>
          Confirmar
          <input
            name="passwordConfirmation"
            type="password"
            value={form.passwordConfirmation}
            onChange={handleChange}
            minLength={8}
            required
          />
        </label>
      </div>

      <div className="two-columns">
        <label>
          Direccion
          <input name="address" value={form.address} onChange={handleChange} />
        </label>

        <label>
          Telefono
          <input name="phoneNumber" value={form.phoneNumber} onChange={handleChange} />
        </label>
      </div>

      <button type="submit" className="primary-button" disabled={isSaving}>
        {isSaving ? 'Creando cuenta...' : 'Crear cuenta'}
      </button>
    </form>
  )
}

export default RegisterForm
