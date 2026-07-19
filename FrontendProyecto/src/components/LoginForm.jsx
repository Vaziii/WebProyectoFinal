import { useState } from 'react'

const emptyLogin = {
  email: '',
  password: '',
}

function LoginForm({ isSaving, onSubmit }) {
  const [form, setForm] = useState(emptyLogin)

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
        <h2>Iniciar sesion</h2>
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

      <button type="submit" className="primary-button" disabled={isSaving}>
        {isSaving ? 'Ingresando...' : 'Entrar'}
      </button>
    </form>
  )
}

export default LoginForm
