import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/login/LoginView.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    component: () => import('@/layout/AppLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        component: () => import('@/views/dashboard/DashboardView.vue'),
        meta: { title: '首页仪表盘', permission: 'MENU:DASHBOARD' }
      },
      {
        path: 'profile',
        component: () => import('@/views/profile/ProfileView.vue'),
        meta: { title: '个人中心' }
      },
      {
        path: 'student/query',
        component: () => import('@/views/student/StudentQueryView.vue'),
        meta: { title: '学生信息查询', permission: 'MENU:STUDENT_QUERY' }
      },
      {
        path: 'sensitive-fields',
        component: () => import('@/views/sensitive-field/SensitiveFieldView.vue'),
        meta: { title: '敏感字段管理', permission: 'MENU:SENSITIVE_FIELD' }
      },
      {
        path: 'masking-rules',
        component: () => import('@/views/masking-rule/MaskingRuleView.vue'),
        meta: { title: '脱敏规则管理', permission: 'MENU:MASKING_RULE' }
      },
      {
        path: 'audit/logs',
        component: () => import('@/views/audit/AuditLogView.vue'),
        meta: { title: '安全审计日志', permission: 'MENU:AUDIT_LOG' }
      },
      {
        path: 'reports',
        component: () => import('@/views/report/ReportView.vue'),
        meta: { title: '数据分析报表', permission: 'MENU:REPORT' }
      },
      {
        path: 'system/users',
        component: () => import('@/views/system/user/UserView.vue'),
        meta: { title: '用户管理', permission: 'MENU:USER_MANAGE' }
      },
      {
        path: 'system/roles',
        component: () => import('@/views/system/role/RoleView.vue'),
        meta: { title: '角色权限管理', permission: 'MENU:ROLE_MANAGE' }
      },
      {
        path: 'system/permissions',
        component: () => import('@/views/system/permission/PermissionView.vue'),
        meta: { title: '权限编码说明', permission: 'MENU:PERMISSION_MANAGE' }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  if (to.meta.public) return true
  if (!auth.isLogin) return { path: '/login', query: { redirect: to.fullPath } }
  if (!auth.loaded) {
    await auth.loadCurrentUser().catch(() => undefined)
  }
  if (!auth.user) return { path: '/login', query: { redirect: to.fullPath } }
  const permission = to.meta.permission as string | undefined
  if (permission && auth.loaded && !auth.hasPermission(permission)) {
    return '/dashboard'
  }
  return true
})

export default router
