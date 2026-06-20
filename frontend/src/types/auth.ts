export interface LoginRequest {
  username: string
  password: string
}

export interface AuthUser {
  userId: number
  username: string
  realName: string
  roles: string[]
  permissions: string[]
}

export interface LoginResponse extends AuthUser {
  token: string
}
