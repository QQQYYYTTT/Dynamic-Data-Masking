export interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp?: string
}

export interface PageResult<T> {
  records: T[]
  total: number
  pageNum: number
  pageSize: number
}
