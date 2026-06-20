import request from './request'
import type { ApiResponse } from '@/types/api'

export interface StudentQueryRequest {
  studentNo?: string
  name?: string
  college?: string
  major?: string
  grade?: string
  pageNum: number
  pageSize: number
}

export interface StudentScore {
  id: number
  courseName: string
  score: string | number
  semester: string
}

export interface StudentRecord {
  id: number
  studentNo: string
  name: string
  gender: string
  phone: string
  email: string
  idCard: string
  address: string
  birthDate: string
  college: string
  major: string
  grade: string
  className: string
  gpa: string | number
  familyIncome: string | number
  bankCard: string
  scores: StudentScore[]
  maskingTypes: Record<string, string>
}

export interface StudentQueryResult {
  records: StudentRecord[]
  total: number
  pageNum: number
  pageSize: number
  username: string
  roles: string[]
  dataView: string
}

export function queryStudentsApi(data: StudentQueryRequest) {
  return request.post<unknown, ApiResponse<StudentQueryResult>>('/student/query', data)
}
