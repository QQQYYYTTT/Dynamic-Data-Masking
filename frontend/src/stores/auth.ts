import { defineStore } from 'pinia'
import { getCurrentUserApi, loginApi, logoutApi } from '@/api/auth'
import { clearToken, getToken, setToken } from '@/utils/token'
import type { AuthUser, LoginRequest } from '@/types/auth'

interface AuthState {
  token: string
  user: AuthUser | null
  loaded: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    token: getToken() || '',
    user: null,
    loaded: false
  }),
  getters: {
    isLogin: (state) => Boolean(state.token),
    permissions: (state) => state.user?.permissions || [],
    roles: (state) => state.user?.roles || [],
    hasPermission: (state) => {
      return (code?: string) => !code || state.user?.permissions.includes(code)
    }
  },
  actions: {
    async login(form: LoginRequest) {
      const response = await loginApi(form)
      this.token = response.data.token
      this.user = {
        userId: response.data.userId,
        username: response.data.username,
        realName: response.data.realName,
        roles: response.data.roles,
        permissions: response.data.permissions
      }
      this.loaded = true
      setToken(response.data.token)
    },
    async loadCurrentUser() {
      if (!this.token) return
      const response = await getCurrentUserApi()
      this.user = response.data
      this.loaded = true
    },
    async logout() {
      if (this.token) {
        await logoutApi().catch(() => undefined)
      }
      this.token = ''
      this.user = null
      this.loaded = false
      clearToken()
    }
  }
})
