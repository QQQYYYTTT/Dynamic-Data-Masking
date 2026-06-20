# 接口契约

本文件是项目的动态接口约定文档。后续每次新增、删除、重命名接口，或修改请求参数、响应结构、权限要求、审计行为时，必须在同一次会话中更新本文件。

## 1. 全局约定

### 1.1 基础路径

后端接口统一使用 `/api` 前缀。

### 1.2 认证方式

计划使用 JWT。

除登录接口外，受保护接口需要在请求头中携带：

```text
Authorization: Bearer <token>
```

### 1.3 统一响应结构

后端实现时建议统一响应格式：

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "timestamp": "2026-06-16 10:00:00"
}
```

约定：

- `code = 0` 表示成功。
- 非 0 表示失败。
- `message` 返回错误或提示信息。
- `data` 承载业务数据。

### 1.4 分页响应结构

列表接口建议使用：

```json
{
  "records": [],
  "total": 0,
  "pageNum": 1,
  "pageSize": 10
}
```

### 1.5 审计约定

涉及以下行为的接口必须写入审计日志：

- 登录。
- 查询学生信息或成绩。
- 导出数据或报表。
- 新增、修改、删除脱敏策略。
- 查看或处理异常访问记录。

## 2. 权限编码索引

### 2.1 菜单权限

| 权限编码 | 页面 |
|---|---|
| `MENU:DASHBOARD` | 首页仪表盘 |
| `MENU:STUDENT_QUERY` | 学生信息查询 |
| `MENU:STUDENT_MANAGE` | 学生数据管理 |
| `MENU:REPORT` | 数据分析报表 |
| `MENU:MASKING_RULE` | 脱敏规则管理 |
| `MENU:SENSITIVE_FIELD` | 敏感字段管理 |
| `MENU:AUDIT_LOG` | 审计日志 |
| `MENU:USER_MANAGE` | 用户管理 |
| `MENU:ROLE_MANAGE` | 角色管理 |
| `MENU:PERMISSION_MANAGE` | 权限管理 |

### 2.2 数据权限

| 权限编码 | 含义 |
|---|---|
| `DATA:VIEW_RAW` | 查看原始数据 |
| `DATA:VIEW_MASKED` | 查看脱敏数据 |
| `DATA:QUERY_ALL_STUDENTS` | 查询全部学生 |
| `DATA:QUERY_OWN_INFO` | 只查询本人信息 |
| `DATA:QUERY_SENSITIVE` | 查询包含敏感字段的数据 |
| `DATA:MANAGE_STUDENT` | 管理学生数据 |
| `DATA:ANALYSIS_REPORT` | 使用分析报表 |
| `DATA:EXPORT_MASKED` | 导出脱敏数据 |
| `DATA:CONFIG_MASKING` | 配置脱敏规则 |
| `DATA:CONFIG_SENSITIVE_FIELD` | 配置敏感字段 |
| `DATA:AUDIT_ACCESS` | 查看访问审计 |
| `DATA:AUDIT_RULE_CHANGE` | 查看规则变更审计 |
| `DATA:EXPORT_AUDIT_REPORT` | 导出审计报告 |
| `DATA:MANAGE_USER_ROLE` | 管理用户角色权限 |

## 3. 登录认证接口

### 3.0 健康检查

| 项 | 内容 |
|---|---|
| 接口名称 | 后端健康检查 |
| 请求方法 | `GET` |
| 接口路径 | `/api/health` |
| 所需权限 | 无 |
| 是否写入审计 | 否 |
| 是否返回脱敏数据 | 否 |

响应字段：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "UP",
    "service": "dynamic-data-masking-backend"
  },
  "timestamp": "2026-06-18 23:20:00"
}
```

### 3.1 用户登录

| 项 | 内容 |
|---|---|
| 接口名称 | 用户登录 |
| 请求方法 | `POST` |
| 接口路径 | `/api/auth/login` |
| 所需权限 | 无 |
| 是否写入审计 | 是，记录 `LOGIN` |
| 是否返回脱敏数据 | 否 |

请求参数：

```json
{
  "username": "teacher01",
  "password": "123456"
}
```

响应字段：

```json
{
  "token": "jwt-token",
  "userId": 5,
  "username": "teacher01",
  "realName": "张老师",
  "roles": ["TEACHER"],
  "permissions": [
    "MENU:DASHBOARD",
    "MENU:STUDENT_QUERY",
    "API:STUDENT_QUERY",
    "DATA:VIEW_MASKED"
  ]
}
```

### 3.2 用户退出

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/auth/logout` |
| 所需权限 | 已登录，需要 `Authorization: Bearer <token>` |
| 是否写入审计 | 可选 |
| 是否返回脱敏数据 | 否 |

响应字段：

```json
{
  "loggedOut": true
}
```

### 3.3 当前用户信息

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/auth/me` |
| 所需权限 | 已登录，需要 `Authorization: Bearer <token>` |
| 是否写入审计 | 否 |
| 是否返回脱敏数据 | 否 |

返回当前用户、角色、权限和前端菜单所需信息。

响应字段：

```json
{
  "userId": 5,
  "username": "teacher01",
  "realName": "张老师",
  "roles": ["TEACHER"],
  "permissions": [
    "MENU:DASHBOARD",
    "MENU:STUDENT_QUERY",
    "API:STUDENT_QUERY",
    "DATA:VIEW_MASKED"
  ]
}
```

## 4. 学生信息接口

### 4.1 查询学生信息

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/student/query` |
| 所需权限 | `API:STUDENT_QUERY` |
| 数据权限 | `DATA:VIEW_RAW` 或 `DATA:VIEW_MASKED`；查询全量需 `DATA:QUERY_ALL_STUDENTS` |
| 是否写入审计 | 是，记录 `QUERY` |
| 是否返回脱敏数据 | 视角色和数据权限决定 |

请求参数：

```json
{
  "studentNo": "20240001",
  "name": "张三",
  "college": "网络空间安全学院",
  "major": "网络空间安全",
  "grade": "2023",
  "className": "网安2301",
  "pageNum": 1,
  "pageSize": 10
}
```

响应字段：

```json
{
  "records": [
    {
      "id": 1,
      "studentNo": "20240001",
      "name": "张*",
      "gender": "M",
      "phone": "138****5678",
      "email": "z****@school.edu.cn",
      "idCard": "******************",
      "address": "四川省****",
      "birthDate": "2003-**-**",
      "age": 22,
      "college": "网络空间安全学院",
      "major": "网络空间安全",
      "grade": "2023",
      "className": "网安2301",
      "gpa": "3.50",
      "familyIncome": "80000-90000",
      "bankCard": "*******************"
    }
  ],
  "total": 1,
  "pageNum": 1,
  "pageSize": 10
}
```

### 4.2 查看学生详情

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/student/{id}` |
| 所需权限 | `API:STUDENT_DETAIL` |
| 数据权限 | `DATA:VIEW_RAW` 或 `DATA:VIEW_MASKED` |
| 是否写入审计 | 是 |
| 是否返回脱敏数据 | 视角色和数据权限决定 |

### 4.3 新增学生

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/student` |
| 所需权限 | `API:STUDENT_CREATE` |
| 数据权限 | `DATA:MANAGE_STUDENT` |
| 是否写入审计 | 是 |

### 4.4 修改学生

| 项 | 内容 |
|---|---|
| 请求方法 | `PUT` |
| 接口路径 | `/api/student/{id}` |
| 所需权限 | `API:STUDENT_UPDATE` |
| 数据权限 | `DATA:MANAGE_STUDENT` |
| 是否写入审计 | 是 |

### 4.5 删除学生

| 项 | 内容 |
|---|---|
| 请求方法 | `DELETE` |
| 接口路径 | `/api/student/{id}` |
| 所需权限 | `API:STUDENT_DELETE` |
| 数据权限 | `DATA:MANAGE_STUDENT` |
| 是否写入审计 | 是 |

## 5. 学生成绩接口

### 5.1 查询学生成绩

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/student/scores/query` |
| 所需权限 | `API:STUDENT_QUERY` |
| 数据权限 | `DATA:VIEW_RAW` 或 `DATA:VIEW_MASKED` |
| 是否写入审计 | 是 |
| 是否返回脱敏数据 | 视角色和成绩字段脱敏策略决定 |

请求参数：

```json
{
  "studentId": 1,
  "studentNo": "20240001",
  "courseName": "数据库系统",
  "semester": "2024-2025-1",
  "pageNum": 1,
  "pageSize": 10
}
```

## 6. 敏感字段接口

### 6.1 查看敏感字段列表

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/sensitive/fields` |
| 所需权限 | `API:SENSITIVE_FIELD_LIST` |
| 数据权限 | `DATA:CONFIG_SENSITIVE_FIELD` 或只读查看权限 |
| 是否写入审计 | 否 |

### 6.2 扫描敏感字段

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/sensitive/scan` |
| 所需权限 | `API:SENSITIVE_FIELD_SCAN` |
| 数据权限 | `DATA:CONFIG_SENSITIVE_FIELD` |
| 是否写入审计 | 是 |

### 6.3 修改敏感字段配置

| 项 | 内容 |
|---|---|
| 请求方法 | `PUT` |
| 接口路径 | `/api/sensitive/fields/{id}` |
| 所需权限 | 暂定 `API:SENSITIVE_FIELD_LIST`，后续可拆分为更新权限 |
| 数据权限 | `DATA:CONFIG_SENSITIVE_FIELD` |
| 是否写入审计 | 是 |

## 7. 脱敏规则接口

### 7.1 查看脱敏规则列表

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/masking/rules` |
| 所需权限 | `API:MASKING_RULE_LIST` |
| 数据权限 | `DATA:CONFIG_MASKING` |
| 是否写入审计 | 否 |

### 7.2 新增脱敏规则

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/masking/rules` |
| 所需权限 | `API:MASKING_RULE_CREATE` |
| 数据权限 | `DATA:CONFIG_MASKING` |
| 是否写入审计 | 是，写入规则变更日志 |

### 7.3 修改脱敏规则

| 项 | 内容 |
|---|---|
| 请求方法 | `PUT` |
| 接口路径 | `/api/masking/rules/{id}` |
| 所需权限 | `API:MASKING_RULE_UPDATE` |
| 数据权限 | `DATA:CONFIG_MASKING` |
| 是否写入审计 | 是，写入规则变更日志 |

### 7.4 删除脱敏规则

| 项 | 内容 |
|---|---|
| 请求方法 | `DELETE` |
| 接口路径 | `/api/masking/rules/{id}` |
| 所需权限 | `API:MASKING_RULE_DELETE` |
| 数据权限 | `DATA:CONFIG_MASKING` |
| 是否写入审计 | 是，写入规则变更日志 |

### 7.5 测试脱敏效果

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/masking/test` |
| 所需权限 | `API:MASKING_RULE_LIST` |
| 数据权限 | `DATA:CONFIG_MASKING` |
| 是否写入审计 | 可选 |

请求参数：

```json
{
  "value": "13812345678",
  "maskingType": "KEEP_PREFIX_SUFFIX",
  "params": {
    "prefix": 3,
    "suffix": 4
  }
}
```

## 8. 报表接口

### 8.1 生成统计报表

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/report/generate` |
| 所需权限 | `API:REPORT_GENERATE` |
| 数据权限 | `DATA:ANALYSIS_REPORT` |
| 是否写入审计 | 是 |
| 是否返回脱敏数据 | 是，不返回原始敏感字段 |

### 8.2 导出分析报表

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/report/export` |
| 所需权限 | `API:REPORT_EXPORT` |
| 数据权限 | `DATA:EXPORT_MASKED` |
| 是否写入审计 | 是，记录 `EXPORT` |
| 是否返回脱敏数据 | 是 |

## 9. 审计接口

### 9.1 查看访问日志

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/audit/logs` |
| 所需权限 | `API:AUDIT_LOG_LIST` |
| 数据权限 | `DATA:AUDIT_ACCESS` |
| 是否写入审计 | 可选 |

### 9.2 查看规则变更日志

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/audit/rule-change-logs` |
| 所需权限 | `API:RULE_CHANGE_LOG_LIST` |
| 数据权限 | `DATA:AUDIT_RULE_CHANGE` |
| 是否写入审计 | 可选 |

### 9.3 查看异常访问记录

| 项 | 内容 |
|---|---|
| 请求方法 | `GET` |
| 接口路径 | `/api/audit/abnormal-access` |
| 所需权限 | `API:ABNORMAL_ACCESS_LIST` |
| 数据权限 | `DATA:AUDIT_ACCESS` |
| 是否写入审计 | 可选 |

### 9.4 导出审计报告

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/audit/export` |
| 所需权限 | `API:AUDIT_REPORT_EXPORT` |
| 数据权限 | `DATA:EXPORT_AUDIT_REPORT` |
| 是否写入审计 | 是，记录 `EXPORT` |

## 10. 系统管理接口

### 10.1 用户管理

| 接口 | 方法 | 权限 | 说明 |
|---|---|---|---|
| `/api/system/users` | `GET` | `API:USER_LIST` + `DATA:MANAGE_USER_ROLE` | 用户列表 |
| `/api/system/users` | `POST` | `API:USER_CREATE` + `DATA:MANAGE_USER_ROLE` | 新增用户 |
| `/api/system/users/{id}` | `PUT` | `API:USER_UPDATE` + `DATA:MANAGE_USER_ROLE` | 修改用户 |
| `/api/system/users/{id}` | `DELETE` | `API:USER_DELETE` + `DATA:MANAGE_USER_ROLE` | 删除或禁用用户 |

### 10.2 角色管理

| 接口 | 方法 | 权限 | 说明 |
|---|---|---|---|
| `/api/system/roles` | `GET` | `API:ROLE_LIST` + `DATA:MANAGE_USER_ROLE` | 角色列表 |
| `/api/system/roles` | `POST` | `API:ROLE_CREATE` + `DATA:MANAGE_USER_ROLE` | 新增角色 |
| `/api/system/roles/{id}` | `PUT` | `API:ROLE_UPDATE` + `DATA:MANAGE_USER_ROLE` | 修改角色 |
| `/api/system/roles/{id}` | `DELETE` | `API:ROLE_DELETE` + `DATA:MANAGE_USER_ROLE` | 删除或禁用角色 |
| `/api/system/roles/{id}/permissions` | `POST` | `API:PERMISSION_ASSIGN` + `DATA:MANAGE_USER_ROLE` | 分配角色权限 |

### 10.3 权限管理

| 接口 | 方法 | 权限 | 说明 |
|---|---|---|---|
| `/api/system/permissions` | `GET` | `API:PERMISSION_LIST` + `DATA:MANAGE_USER_ROLE` | 权限列表 |

## 11. 待确认事项

- 是否将敏感字段新增、删除接口拆分为独立权限。
- 是否开放高级 SQL 查询接口；若开放，必须先设计 SQL 白名单和安全校验。
- 报表接口的具体统计维度和返回结构待实现时细化。
