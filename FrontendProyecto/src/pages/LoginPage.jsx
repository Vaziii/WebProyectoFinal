import { useState } from 'react'
import LoginForm from '../components/LoginForm.jsx'
import RegisterForm from '../components/RegisterForm.jsx'
import { formatApiError, loginUser, registerUser } from '../api/client.js'

function LoginPage({ session, onLogin, onLogout }) {
  const [mode, setMode] = useState('login')
  const [saving, setSaving] = useState(false)
  const [notice, setNotice] = useState(null)

  async function handleLogin(credentials) {
    setSaving(true)
    setNotice(null)

    try {
      const response = await loginUser(credentials)
      onLogin({
        token: response.token,
        user: response.user,
      })
      setNotice({ type: 'success', text: 'Inicio de sesion correcto.' })
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setSaving(false)
    }
  }

  async function handleRegister(user) {
    setSaving(true)
    setNotice(null)

    try {
      await registerUser(user)
      const response = await loginUser({
        email: user.email,
        password: user.password,
      })

      onLogin({
        token: response.token,
        user: response.user,
      })
      setMode('login')
      setNotice({ type: 'success', text: 'Cuenta creada e inicio de sesion correcto.' })
    } catch (error) {
      setNotice({ type: 'error', text: formatApiError(error) })
    } finally {
      setSaving(false)
    }
  }

  return (
    <section className="login-layout">
      <div className="auth-column">
        <div className="auth-switch" aria-label="Acceso de cuenta">
          <button
            type="button"
            className={mode === 'login' ? 'active' : ''}
            onClick={() => setMode('login')}
          >
            Ingresar
          </button>
          <button
            type="button"
            className={mode === 'register' ? 'active' : ''}
            onClick={() => setMode('register')}
          >
            Crear cuenta
          </button>
        </div>

        {mode === 'login' ? (
          <LoginForm isSaving={saving} onSubmit={handleLogin} />
        ) : (
          <RegisterForm isSaving={saving} onSubmit={handleRegister} />
        )}
      </div>

      <section className="content-panel">
        <div className="section-heading">
          <h2>Cuenta</h2>
          <span>{session ? 'Activa' : 'Sin sesion'}</span>
        </div>

        {notice ? (
          <div className={`notice ${notice.type}`} role="status">
            {notice.text}
          </div>
        ) : null}

        {session ? (
          <div className="session-card">
            <div>
              <span>Usuario</span>
              <strong>
                {session.user.firstName} {session.user.lastName}
              </strong>
            </div>

            <div>
              <span>Correo</span>
              <strong>{session.user.email}</strong>
            </div>

            <div>
              <span>Rol</span>
              <strong>{session.user.role === 'admin' ? 'Administrador' : 'Usuario'}</strong>
            </div>

            <div>
              <span>ID</span>
              <strong>{session.user.userId}</strong>
            </div>

            <button type="button" className="ghost-button" onClick={onLogout}>
              Cerrar sesion
            </button>
          </div>
        ) : (
          <p className="empty-state">Ingresa con una cuenta registrada o crea una cuenta nueva para comprar.</p>
        )}
      </section>
    </section>
  )
}

export default LoginPage
