import {
  BarChart3,
  Database,
  FileClock,
  Gauge,
  KeyRound,
  ShieldCheck,
  SlidersHorizontal,
  UserCircle,
  UserCog,
  Users
} from 'lucide-vue-next'

export interface MenuItem {
  path: string
  title: string
  permission?: string
  icon: unknown
}

export const menus: MenuItem[] = [
  { path: '/dashboard', title: '首页仪表盘', permission: 'MENU:DASHBOARD', icon: Gauge },
  { path: '/profile', title: '个人中心', icon: UserCircle },
  { path: '/student/query', title: '学生信息查询', permission: 'MENU:STUDENT_QUERY', icon: Database },
  { path: '/sensitive-fields', title: '敏感字段管理', permission: 'MENU:SENSITIVE_FIELD', icon: ShieldCheck },
  { path: '/masking-rules', title: '脱敏规则管理', permission: 'MENU:MASKING_RULE', icon: SlidersHorizontal },
  { path: '/audit/logs', title: '安全审计日志', permission: 'MENU:AUDIT_LOG', icon: FileClock },
  { path: '/reports', title: '数据分析报表', permission: 'MENU:REPORT', icon: BarChart3 },
  { path: '/system/users', title: '用户管理', permission: 'MENU:USER_MANAGE', icon: Users },
  { path: '/system/roles', title: '角色权限管理', permission: 'MENU:ROLE_MANAGE', icon: UserCog },
  { path: '/system/permissions', title: '权限编码说明', permission: 'MENU:PERMISSION_MANAGE', icon: KeyRound }
]
