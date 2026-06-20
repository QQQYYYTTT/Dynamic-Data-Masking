# 前端工程

本目录是动态数据脱敏系统的 Vue 前端工程。

## 技术栈

- Vue 3
- Vite
- TypeScript
- Vue Router
- Pinia
- Axios
- Element Plus
- lucide-vue-next

## 已搭建内容

- 登录页
- 个人中心
- 主布局
- 侧边菜单
- 路由守卫
- JWT Token 本地保存
- Axios 请求封装
- 当前用户与权限状态管理
- 首页仪表盘
- 个人中心页面
- 学生信息查询页面
- 敏感字段管理页面
- 脱敏规则管理页面
- 安全审计日志页面
- 数据分析报表页面
- 用户管理页面
- 角色权限管理页面
- 权限编码说明页面

## 运行命令

```bash
npm install
npm run dev
```

默认访问地址：

```text
http://localhost:5173
```

## 构建检查

```bash
npm run build
```

## 接口约定

开发环境默认请求：

```text
http://localhost:8080/api
```

当前前端已封装接口：

- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/logout`

这些接口均来自 `docs/api/API_CONTRACT.md`，本阶段未新增后端接口。
