import request from './request'
import type { ApiResponse } from '@/types/api'
import type { AuthUser, LoginRequest, LoginResponse } from '@/types/auth'

export function loginApi(data: LoginRequest) {
  return request.post<unknown, ApiResponse<LoginResponse>>('/auth/login', data)
}

export function getCurrentUserApi() {
  return request.get<unknown, ApiResponse<AuthUser>>('/auth/me')
}

export function logoutApi() {
  return request.post<unknown, ApiResponse<{ loggedOut: boolean }>>('/auth/logout')
}
