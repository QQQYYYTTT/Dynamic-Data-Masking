# 项目进度记录

本文件由 Codex 在每次开发会话结束前维护。

## 2026-06-16

### 会话摘要

清理旧 C++ 原型项目后，初始化 Java 后端与 Vue 前端的新项目骨架，并建立项目文档治理结构。随后根据用户要求，将项目文档统一调整为中文。本次继续根据三份原始设计文档，系统性优化 PRD、项目宪法、接口契约和数据字典，使其更完整、更符合后续开发逻辑。

### 已完成事项

- 保留项目根目录下三份原始需求文档：
  - `项目业务逻辑设计v2.md`
  - `用户角色权限管理表v2.md`
  - `数据库建表数据结构v3.md`
- 创建初始目录：
  - `backend/`
  - `frontend/`
  - `database/`
  - `docs/`
  - `scripts/`
- 创建并中文化项目文档骨架：
  - `docs/README.md`
  - `docs/product/PRD.md`
  - `docs/constitution/PROJECT_CONSTITUTION.md`
  - `docs/progress/PROGRESS.md`
  - `docs/api/API_CONTRACT.md`
  - `docs/data/DATA_DICTIONARY.md`
- 在项目宪法中写入强制维护规则：
  - 每次开发会话结束必须更新进度文档。
  - 每次增删改接口必须更新接口契约。
  - 每次改动数据库结构或数据库对象必须更新数据字典。
- 根据三份原始文档补充并优化：
  - 产品定位、建设目标、角色边界、功能模块、演示流程。
  - 认证、学生信息、成绩、敏感字段、脱敏规则、报表、审计和系统管理接口契约。
  - 14 张表的数据字典、关键字段、敏感等级、默认脱敏方式、索引、外键和数据库对象。
  - 项目宪法中的架构方向、权限约定、脱敏约定和审计约定。

### 本次决策

- 使用项目根目录下已有三份 Markdown 作为原始需求依据。
- 后续协作文档统一使用中文。
- 后续开发方向为 Java 后端 + Vue 前端，不再沿用旧 C++ 代理/TCP 实现。
- PRD、接口契约、数据字典作为后续开发执行文档；原始三份文档作为需求来源和参考材料。
- 前端不得接收明文敏感数据后再自行脱敏，脱敏必须在后端或数据库侧完成。
- 脱敏策略优先级确定为：原始数据权限 > 角色分配策略 > 字段默认策略 > 安全兜底。

### 已知问题

- 后端和前端目前还只是目录骨架，尚未生成可运行工程。
- `database/` 目录下还没有从 `数据库建表数据结构v3.md` 拆分出的可执行 SQL 脚本。
- 接口契约已经形成初版，但具体请求/响应 DTO 仍需在后端实现时进一步细化。
- 数据字典已整理主要表结构，但后续如果实际 SQL 与文档存在差异，需要同步修订。

### 建议下一步

- 确认后端与前端具体技术版本，例如 Spring Boot 3、MyBatis、Vue 3、Vite、Element Plus。
- 生成最小可运行 Spring Boot 后端工程。
- 生成最小可运行 Vue 前端工程。
- 将 `数据库建表数据结构v3.md` 中的 DDL、预置数据、函数、存储过程、触发器和视图拆分到 `database/` 目录。
- 开始实现登录认证和 RBAC 基础模块。

## 2026-06-18

### 会话摘要

根据项目实际情况重新确定最终分工：Codex 负责开发全流程，成员 A 负责监工、决策确认和验收，成员 B 负责报告、数据库设计说明、PPT 和答辩材料。同时在项目根目录新增长期维护的分工与执行计划文档。

### 已完成事项

- 新增根目录文档 `分工与执行计划.md`。
- 明确三方职责：
  - Codex：开发全流程主力。
  - 成员 A：项目负责人、监工和验收。
  - 成员 B：报告、数据库模型、PPT 和答辩材料。
- 明确两天内优先完成可演示闭环，而不是完整大系统。
- 明确阶段 TODO，第一阶段为 Java 后端脚手架搭建。

### 本次决策

- 后续开发由 Codex 集中完成前端、后端、数据库脚本和文档同步。
- 人类成员不按前后端拆分，避免两天内沟通和定位成本过高。
- 功能优先级调整为：登录、角色权限、学生查询、动态脱敏、规则管理、访问日志。

### 已知问题

- 当前仍未生成真实 Java 后端工程和 Vue 前端工程。
- `开发流程1.md` 是已有未跟踪文件，本次未修改。

### 建议下一步

- 进入阶段 1：搭建 Java 后端脚手架。
- 生成 Spring Boot 3 + Java 17 + MyBatis + MySQL 的最小可运行后端工程。
- 完成统一响应、全局异常、基础配置和健康检查接口。

## 2026-06-18 阶段 1

### 会话摘要

按阶段 1 要求搭建 Java 后端脚手架。技术栈确定为 Spring Boot 3.3.5、Java 17、MyBatis、MySQL Driver、Spring Security、JWT 依赖预留，不使用 MyBatis-Plus。

### 已完成事项

- 新增后端 Maven 工程文件 `backend/pom.xml`。
- 新增 Spring Boot 启动类 `DynamicDataMaskingApplication`。
- 新增统一响应结构 `ApiResponse`。
- 新增业务异常 `BusinessException`。
- 新增全局异常处理 `GlobalExceptionHandler`。
- 新增跨域配置 `WebConfig`。
- 新增基础安全配置 `SecurityConfig`。
- 新增健康检查接口 `GET /api/health`。
- 新增配置文件 `backend/src/main/resources/application.yml`。
- 新增最小上下文测试类 `DynamicDataMaskingApplicationTests`。
- 更新 `docs/api/API_CONTRACT.md`，记录健康检查接口。

### 本次新增接口

| 接口 | 方法 | 说明 | 权限 | 审计 |
|---|---|---|---|---|
| `/api/health` | `GET` | 后端健康检查 | 无 | 否 |

### 接口测试用例

#### 用例 1：后端健康检查

请求：

```bash
curl -X GET http://localhost:8080/api/health
```

期望响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "UP",
    "service": "dynamic-data-masking-backend"
  }
}
```

验收标准：

- HTTP 状态码为 200。
- `code` 为 0。
- `data.status` 为 `UP`。
- `data.service` 为 `dynamic-data-masking-backend`。

### 验证情况

- 已确认本机 Java 版本为 Java 17。
- 项目内已安装 Maven 3.9.16，路径为 `tools/apache-maven-3.9.16`。
- 已新增根目录脚本 `mvnw.cmd`，用于调用项目内 Maven。
- 已执行 `.\tools\apache-maven-3.9.16\bin\mvn.cmd -f backend\pom.xml test`，后端测试通过，结果为 `BUILD SUCCESS`。

### 已知问题

- `application.yml` 中数据库账号密码目前是开发占位值，后续数据库初始化时需要按本机 MySQL 环境调整。
- `SecurityConfig` 当前为脚手架阶段配置，除健康检查和登录外，其他接口暂时放行；后续登录/JWT 阶段需要收紧权限控制。

### 建议下一步

- 进入阶段 2：拆分数据库 SQL 脚本并初始化 MySQL。

## 2026-06-19 阶段 2

### 会话摘要

进入阶段 2，按 `数据库建表数据结构v3.md` 和当前数据字典拆分 MySQL 8 数据库脚本。当前开发环境没有检测到 `mysql` 命令和 MySQL 服务，因此本次完成 SQL 脚本准备和执行说明，暂未实际导入数据库。

### 已完成事项

- 新增建表脚本 `database/ddl/01_schema.sql`。
- 新增角色权限预置数据脚本 `database/seed/01_seed_roles_permissions.sql`。
- 新增用户预置数据脚本 `database/seed/02_seed_users.sql`。
- 新增脱敏配置预置数据脚本 `database/seed/03_seed_masking_config.sql`。
- 新增学生与成绩测试数据脚本 `database/seed/04_seed_student_data.sql`。
- 新增统一脱敏函数脚本 `database/procedure/01_fn_apply_mask.sql`。
- 新增学生信息动态脱敏查询过程 `database/procedure/02_query_students.sql`。
- 新增学生成绩动态脱敏查询过程 `database/procedure/03_query_student_scores.sql`。
- 新增异常访问检测过程 `database/procedure/04_detect_abnormal.sql`。
- 新增策略变更日志触发器 `database/trigger/01_policy_change_log.sql`。
- 新增脱敏配置总览视图 `database/view/01_masking_config_view.sql`。
- 更新 `database/README.md`，写明脚本执行顺序。
- 更新 `docs/data/DATA_DICTIONARY.md`，记录 SQL 脚本落地状态。

### 数据库脚本执行顺序

```bash
mysql -u root -p < database/ddl/01_schema.sql
mysql -u root -p < database/seed/01_seed_roles_permissions.sql
mysql -u root -p < database/seed/02_seed_users.sql
mysql -u root -p < database/seed/03_seed_masking_config.sql
mysql -u root -p < database/seed/04_seed_student_data.sql
mysql -u root -p < database/procedure/01_fn_apply_mask.sql
mysql -u root -p < database/procedure/02_query_students.sql
mysql -u root -p < database/procedure/03_query_student_scores.sql
mysql -u root -p < database/procedure/04_detect_abnormal.sql
mysql -u root -p < database/trigger/01_policy_change_log.sql
mysql -u root -p < database/view/01_masking_config_view.sql
```

### 本次决策

- 数据库名统一为 `dynamic_data_masking`，与后端 `application.yml` 保持一致。
- SQL 脚本按职责拆分，便于报告说明和后续单独调试。
- 数据库侧存储过程保留课程展示价值；后续 Java 后端仍以自身业务逻辑作为主查询和脱敏路径。
- 修正数据库查询过程：`SUPER_ADMIN` 在 `SP_QUERY_STUDENTS` 和 `SP_QUERY_STUDENT_SCORES` 中直接返回原始数据，其他角色才执行动态脱敏。

### 验证情况

- 已静态检查 SQL 文件齐全、数据库名一致、README 执行顺序完整。
- 当前环境未检测到 `mysql` 命令。
- 当前环境未检测到 MySQL 服务。
- 因此本次未能实际执行 SQL 导入。

### 已知问题

- 需要安装 MySQL 8 或提供可用数据库连接后，才能真正初始化数据库并验证 SQL 语法。
- 触发器依赖会话变量 `@current_user_id` 记录操作人，后续 Java 后端修改脱敏策略前需要设置该变量。
- 测试用户密码哈希沿用原始设计文档，后续登录模块实现时需要用 BCrypt 实测确认。

### 建议下一步

- 安装 MySQL 8 或提供已有 MySQL 连接参数。
- 实际执行 `database/README.md` 中的 SQL 初始化顺序。
- 进入阶段 3：实现登录认证与权限加载。

## 2026-06-19 阶段 3

### 会话摘要

开始并完成登录认证与权限加载的后端基础实现。新增登录、当前用户、退出接口，使用 JWT 作为会话凭证，通过 MyBatis 从 `sys_user`、`sys_role`、`sys_permission`、`sys_user_role`、`sys_role_permission` 查询用户角色和权限。

### 已完成事项

- 新增 JWT 工具 `JwtTokenProvider`。
- 新增 JWT 过滤器 `JwtAuthenticationFilter`。
- 更新 `SecurityConfig`：
  - 放行 `/api/health`。
  - 放行 `/api/auth/login`。
  - 其他接口需要通过 JWT 认证。
  - 提供 BCrypt `PasswordEncoder`。
- 新增用户实体 `SysUser`。
- 新增 MyBatis Mapper `UserMapper`。
- 新增登录请求 DTO `LoginRequest`。
- 新增登录响应 DTO `LoginResponse`。
- 新增当前用户响应 DTO `AuthUserResponse`。
- 新增认证服务 `AuthService`。
- 新增认证控制器 `AuthController`。
- 更新 `docs/api/API_CONTRACT.md` 中 `/api/auth/me` 和 `/api/auth/logout` 的认证说明。
- 更新 `backend/README.md` 当前接口和登录测试示例。

### 本次新增/完善接口

| 接口 | 方法 | 说明 | 权限 | 审计 |
|---|---|---|---|---|
| `/api/auth/login` | `POST` | 用户登录，返回 JWT、用户、角色、权限 | 无 | 后续写入登录日志 |
| `/api/auth/me` | `GET` | 根据 JWT 获取当前用户、角色、权限 | 已登录 | 否 |
| `/api/auth/logout` | `POST` | 前端退出登录确认接口 | 已登录 | 可选 |

### 接口测试用例

#### 用例 1：用户登录成功

前置条件：

- 已完成 MySQL 初始化。
- `sys_user` 中存在 `teacher01`。
- `teacher01` 密码为 `123456`。

请求：

```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"teacher01\",\"password\":\"123456\"}"
```

期望响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "JWT字符串",
    "userId": 5,
    "username": "teacher01",
    "realName": "张老师",
    "roles": ["TEACHER"],
    "permissions": ["MENU:DASHBOARD", "MENU:STUDENT_QUERY"]
  }
}
```

验收标准：

- HTTP 状态码为 200。
- `code` 为 0。
- `data.token` 非空。
- `data.roles` 包含 `TEACHER`。
- `data.permissions` 非空。

#### 用例 2：用户登录失败

请求：

```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"teacher01\",\"password\":\"wrong-password\"}"
```

期望：

- HTTP 状态码为 401。
- 响应 `code` 为 401。
- 提示用户名或密码错误。

#### 用例 3：获取当前用户信息

请求：

```bash
curl -X GET http://localhost:8080/api/auth/me ^
  -H "Authorization: Bearer <登录接口返回的token>"
```

期望：

- HTTP 状态码为 200。
- `data.username` 为登录用户。
- `data.roles` 和 `data.permissions` 与登录接口返回一致。

#### 用例 4：缺少 Token 访问当前用户

请求：

```bash
curl -X GET http://localhost:8080/api/auth/me
```

期望：

- HTTP 状态码为 401 或 403。
- 请求被 Spring Security 拦截。

#### 用例 5：退出登录

请求：

```bash
curl -X POST http://localhost:8080/api/auth/logout ^
  -H "Authorization: Bearer <登录接口返回的token>"
```

期望响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "loggedOut": true
  }
}
```

### 验证情况

- 已执行 `.\mvnw.cmd -f backend\pom.xml test`。
- 后端编译通过。
- Spring Boot 上下文测试通过。
- 结果为 `BUILD SUCCESS`。
- 已用 Spring Security `BCryptPasswordEncoder` 验证数据库种子脚本中的密码哈希匹配 `123456`。

### 已知问题

- 当前环境尚未初始化 MySQL，因此登录接口还未进行真实数据库联调。
- JWT 过滤器目前只负责认证，不做细粒度 API 权限判断；接口级权限校验将在后续业务接口实现时补充。
- 登出接口当前为无状态 JWT 场景下的前端确认接口，不维护服务端 token 黑名单。

### 建议下一步

- 安装并初始化 MySQL，执行 `database/README.md` 中的脚本顺序。
- 使用真实数据库联调 `/api/auth/login` 和 `/api/auth/me`。
- 进入阶段 4：Vue 前端脚手架搭建，或先继续后端学生查询与脱敏核心。
- 随后进入阶段 3：实现登录认证与权限加载。

## 2026-06-19 Maven 配置

### 会话摘要

完成项目内 Maven 配置，避免依赖系统全局 `mvn` 命令。

### 已完成事项

- 确认 Maven 3.9.16 可用。
- 新增根目录脚本 `mvnw.cmd`，封装项目内 Maven 调用。
- 更新 `backend/README.md` 中的运行和测试命令。

### 验证命令

```bash
.\mvnw.cmd -version
.\mvnw.cmd -f backend\pom.xml test
```

### 验证结果

- Maven 版本：Apache Maven 3.9.16。
- Java 版本：Java 17.0.10。
- 后端测试：已通过。

### 建议下一步

- 进入阶段 2：拆分数据库 SQL 脚本并初始化 MySQL。

## 2026-06-19 阶段 4

### 会话摘要

完成 Vue 前端脚手架搭建。前端采用 Vue 3、Vite、TypeScript、Vue Router、Pinia、Axios、Element Plus 和 lucide-vue-next，已形成可运行、可构建的前端雏形。当前阶段重点是建立清晰结构、登录入口、主布局、权限菜单和业务页面框架，后续在 MySQL 初始化和后端接口完善后继续联调真实数据。

### 已完成事项

- 新增 `frontend/package.json`、`vite.config.ts`、`tsconfig.json`、`index.html` 等工程基础文件。
- 新增前端环境配置：
  - `frontend/.env.development`
  - `frontend/.env.production`
- 新增前端入口：
  - `frontend/src/main.ts`
  - `frontend/src/App.vue`
  - `frontend/src/styles/global.css`
- 新增 Axios 请求封装 `frontend/src/api/request.ts`。
- 新增认证接口封装 `frontend/src/api/auth.ts`。
- 新增认证状态管理 `frontend/src/stores/auth.ts`。
- 新增 Token 工具 `frontend/src/utils/token.ts`。
- 新增路由与权限菜单：
  - `frontend/src/router/index.ts`
  - `frontend/src/router/menu.ts`
- 新增主布局 `frontend/src/layout/AppLayout.vue`。
- 新增登录页 `frontend/src/views/login/LoginView.vue`。
- 新增业务页面雏形：
  - 首页仪表盘
  - 学生信息查询
  - 敏感字段管理
  - 脱敏规则管理
  - 安全审计日志
  - 数据分析报表
  - 用户管理
  - 角色权限管理
  - 权限编码说明
- 更新 `frontend/README.md`，记录运行命令、页面结构和已封装接口。
- 更新 `.gitignore`，忽略前端 TypeScript 构建缓存。

### 本阶段接口情况

本阶段未新增、删除或修改后端接口，因此 `docs/api/API_CONTRACT.md` 无需变更。

前端当前封装并调用既有接口：

| 前端封装 | 后端接口 | 说明 |
|---|---|---|
| `loginApi` | `POST /api/auth/login` | 登录并获取 JWT、用户、角色、权限 |
| `getCurrentUserApi` | `GET /api/auth/me` | 根据 JWT 获取当前用户权限信息 |
| `logoutApi` | `POST /api/auth/logout` | 退出登录确认 |

### 接口测试用例

#### 用例 1：登录页提交成功

前置条件：

- 后端服务已启动。
- MySQL 已初始化。
- 数据库存在 `admin / 123456` 测试账号。

操作：

1. 打开 `http://localhost:5173/login`。
2. 输入用户名 `admin`。
3. 输入密码 `123456`。
4. 点击“登录系统”。

期望结果：

- 前端调用 `POST /api/auth/login`。
- 登录成功后保存 JWT。
- 跳转到 `/dashboard`。
- 顶部显示当前用户和角色标签。

#### 用例 2：刷新后恢复当前用户

前置条件：

- 浏览器本地已保存有效 JWT。

操作：

1. 刷新 `http://localhost:5173/dashboard`。

期望结果：

- 前端调用 `GET /api/auth/me`。
- 恢复用户、角色和权限。
- 根据权限渲染侧边菜单。

#### 用例 3：退出登录

前置条件：

- 用户已登录。

操作：

1. 点击顶部退出按钮。

期望结果：

- 前端调用 `POST /api/auth/logout`。
- 清除本地 JWT。
- 跳转到 `/login`。

### 验证情况

- 已执行 `npm install --registry=https://registry.npmmirror.com` 完成依赖安装。
- 已执行 `npm run build`，构建通过。
- Vite 构建结果成功，存在大 chunk 提示，当前脚手架阶段可接受。
- 已启动前端开发服务，监听端口 `5173`。
- 已通过浏览器检查登录页：
  - 页面标题为“动态数据脱敏系统”。
  - H1 为“动态数据脱敏系统”。
  - 用户名输入框存在。
  - 密码输入框存在。

### 已知问题

- 当前后端尚未连接真实 MySQL，因此前端登录提交还不能完成真实数据库联调。
- 业务页面当前使用静态占位数据，后续需要随着后端学生查询、脱敏规则、审计接口实现后替换为真实接口。
- 登录页背景使用外部图片 URL，若验收环境无法联网，后续可改为本地静态图片。

### 建议下一步

- 安装并初始化 MySQL，按 `database/README.md` 导入 SQL 脚本。
- 启动后端服务并联调前端登录流程。
- 进入学生信息查询与动态脱敏核心接口实现。

## 2026-06-19 MySQL 初始化与登录闭环联调

### 会话摘要

完成本机 MySQL 安装/配置、数据库初始化、后端启动和前后端登录闭环验证。由于项目路径包含中文，MySQL 直接使用项目路径作为 `basedir/datadir` 时会解析失败，因此采用 MySQL 8.4.6 Windows ZIP 便携版，并在运行时复制到系统临时目录 `DDM-MySQL` 启动，不注册系统服务。

### 已完成事项

- 下载 MySQL 8.4.6 Windows ZIP 到项目 `tools/` 目录。
- 解压 MySQL 运行目录。
- 发现 MySQL 在 Windows 中文路径下解析 `basedir/datadir` 不稳定，改用系统临时目录运行。
- 初始化 MySQL 数据目录。
- 启动 MySQL，监听端口 `3306`。
- 设置 root 密码为 `root`，与后端 `application.yml` 保持一致。
- 按 `database/README.md` 顺序导入全部 SQL：
  - 建表脚本
  - 角色权限种子数据
  - 用户种子数据
  - 脱敏配置种子数据
  - 学生与成绩演示数据
  - 脱敏函数
  - 动态查询存储过程
  - 异常访问检测过程
  - 策略变更触发器
  - 脱敏配置视图
- 新增 `scripts/start-local-mysql.ps1`，用于后续快速启动本地便携版 MySQL。
- 更新 `database/README.md`，记录本地便携版 MySQL 启动方式。
- 修复后端权限查询 SQL 兼容性问题：
  - MySQL 8.4 不允许 `SELECT DISTINCT permission_code` 同时按未出现在 select list 中的 `sort_order/id` 排序。
  - 已改为 `GROUP BY permission_code ORDER BY MIN(sort_order), MIN(id)`。
- 增强全局异常处理器，未处理异常会写入后端日志，便于后续联调定位。
- 使用 jar 方式启动后端，避免 `spring-boot:run` 在当前路径下找不到主类的问题。
- 在前端页面完成真实登录验证。

### 数据库验证结果

| 验证项 | 结果 |
|---|---|
| MySQL 版本 | 8.4.6 |
| 监听端口 | `3306` |
| 数据库名 | `dynamic_data_masking` |
| `sys_user` 数量 | 8 |
| `sys_role` 数量 | 8 |
| `sys_permission` 数量 | 51 |
| `student_info` 数量 | 5 |
| 脱敏函数 | `FN_APPLY_MASK` 已创建 |
| 存储过程 | `SP_QUERY_STUDENTS`、`SP_QUERY_STUDENT_SCORES`、`SP_DETECT_ABNORMAL` 已创建 |

### 接口测试用例与结果

#### 用例 1：健康检查

请求：

```bash
curl -X GET http://localhost:8080/api/health
```

结果：

- `code = 0`
- `data.status = UP`

#### 用例 2：用户登录

请求：

```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"123456\"}"
```

结果：

- `code = 0`
- `username = admin`
- `roles = SUPER_ADMIN`
- 权限数量：51
- JWT 返回成功

#### 用例 3：当前用户信息

请求：

```bash
curl -X GET http://localhost:8080/api/auth/me ^
  -H "Authorization: Bearer <登录接口返回的token>"
```

结果：

- `code = 0`
- `username = admin`
- 角色和权限成功加载

#### 用例 4：前端登录闭环

操作：

1. 打开 `http://localhost:5173/login`。
2. 输入 `admin / 123456`。
3. 点击“登录系统”。

结果：

- 前端成功调用后端登录接口。
- 页面跳转到 `http://localhost:5173/dashboard`。
- 页面显示“超级管理员”和 `SUPER_ADMIN`。
- 首页仪表盘正常渲染。

### 本阶段接口情况

本阶段没有新增、删除或修改接口路径和请求/响应结构，因此 `docs/api/API_CONTRACT.md` 无需变更。

### 本阶段数据字典情况

本阶段没有修改表结构、字段或数据库对象定义，只执行既有 SQL 初始化，因此 `docs/data/DATA_DICTIONARY.md` 无需变更。

### 验证命令

```powershell
powershell -ExecutionPolicy Bypass -File scripts\start-local-mysql.ps1
.\mvnw.cmd -f backend\pom.xml package -DskipTests
java -jar backend\target\dynamic-data-masking-backend-0.1.0-SNAPSHOT.jar
npm run build
```

### 已知问题

- `spring-boot:run` 在当前环境下出现找不到主类的问题；目前采用 `package` 后 `java -jar` 方式启动，已验证可用。
- PowerShell 中直接打印中文 JSON 时可能出现终端编码显示问题；浏览器页面和数据库内容本身可正常显示中文。
- MySQL 运行目录在系统临时目录，若临时目录被清理，需要重新执行 `scripts/start-local-mysql.ps1` 并按 README 导入数据库脚本。

### 建议下一步

- 进入学生信息查询与动态脱敏核心接口实现。
- 将学生查询页面从静态数据切换为真实后端接口。
- 展示不同角色登录后访问同一学生信息时的脱敏差异。

## 2026-06-19 新增个人中心

### 会话摘要

根据用户要求，为前端新增“个人中心”页面，用于展示当前登录用户、角色身份和权限加载结果。该功能复用已有 `/api/auth/me` 登录态数据，不新增后端接口，也不修改数据库表结构。

### 已完成事项

- 新增个人中心页面 `frontend/src/views/profile/ProfileView.vue`。
- 新增路由 `/profile`。
- 新增侧边菜单“个人中心”。
- 顶部用户名增加可点击入口，可跳转到个人中心。
- 个人中心展示内容：
  - 用户ID
  - 用户名
  - 真实姓名
  - 当前角色
  - 菜单权限数量
  - 接口权限数量
  - 数据权限数量
  - MENU/API/DATA 权限明细
  - 修改密码功能占位说明
- 修复前端菜单、路由、主布局文件中的中文显示内容。
- 优化路由守卫：如果 token 失效或当前用户加载失败，直接跳转登录页，避免停留在“未加载用户”的业务页面。
- 更新 `frontend/README.md`，补充个人中心页面。

### 本阶段接口情况

本阶段没有新增、删除或修改后端接口。个人中心复用既有接口：

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/auth/me` | `GET` | 获取当前用户、角色和权限 |

因此 `docs/api/API_CONTRACT.md` 无需变更。

### 本阶段数据字典情况

本阶段没有修改表结构、字段、函数、存储过程、触发器或视图，因此 `docs/data/DATA_DICTIONARY.md` 无需变更。

### 验证情况

- 已执行 `npm run build`。
- 前端 TypeScript 检查通过。
- Vite 构建通过。

### 已知问题

- 修改密码当前只是前端占位，后续需要新增后端修改密码接口后再接入。
- 个人中心中的最近登录、最近访问记录需要等审计日志接口实现后再补充。

### 建议下一步

- 继续实现学生信息查询与动态脱敏核心接口。
- 后续在审计模块完成后，将个人中心补充为“账号信息 + 最近访问记录 + 权限明细”的完整页面。

## 2026-06-19 阶段 5

### 会话摘要

完成学生信息查询与动态脱敏核心闭环。后端新增 `POST /api/student/query`，从学生信息、成绩、敏感字段、脱敏策略和角色规则分配表动态加载数据与规则，并在服务层完成策略分发和脱敏处理。前端学生查询页已从静态占位切换为真实接口，支持筛选、分页、详情展开、成绩展示，并显示当前用户角色和数据视图。

### 已完成事项

- 实现学生信息查询接口 `POST /api/student/query`。
- 查询响应中直接返回学生详情数据和成绩列表，用于页面展开详情。
- 实现敏感字段与规则加载：`sensitive_field`、`masking_policy`、`masking_rule_assignment`。
- 实现脱敏策略接口 `MaskingStrategy` 和策略分发组件 `StudentMaskingEngine`。
- 已支持 `NO_MASK`、`FULL_MASK`、`KEEP_PREFIX`、`KEEP_SUFFIX`、`KEEP_PREFIX_SUFFIX`、`EMAIL_MASK`、`ADDRESS_LEVEL`、`GENERALIZATION`、`KEEP_YEAR`。
- 查询后写入 `access_log`，记录用户、角色、查询条件、涉及字段、脱敏快照、结果数量和客户端 IP。
- 前端实现学生信息查询页，展示当前用户、当前角色和数据视图。
- 新增 `docs/api/STAGE5_STUDENT_QUERY_CONTRACT.md`，补充阶段 5 实际接口契约。

### 阶段验收标准

| 账号 | 角色 | 验收视图 |
|---|---|---|
| `admin` | `SUPER_ADMIN` | 原始数据视图 |
| `teacher01` | `TEACHER` | 教师轻度脱敏视图 |
| `analyst01` | `ANALYST` | 分析员泛化视图 |
| `normal_user` | `NORMAL` | 普通用户高度脱敏视图 |

### 验证情况

- 已执行 `.\mvnw.cmd -f backend\pom.xml test`。
- 后端编译通过，Spring Boot 上下文测试通过，结果为 `BUILD SUCCESS`。
- 已执行 `npm run typecheck`。
- 前端 TypeScript 类型检查通过。
- 已执行 `npm run build`。
- 前端生产构建通过。
- 尝试执行 `.\mvnw.cmd -f backend\pom.xml package` 时，测试和普通 jar 生成已通过，但 Spring Boot `repackage` 因 8080 上正在运行的旧 jar 占用同名文件而失败；停止旧后端进程后重新执行即可生成最新可运行 jar。

### 已知问题

- 本次已完成编译和类型验证，尚未在浏览器中逐账号完成四角色视觉验收截图。
- 当前接口依赖数据库中阶段 2 的种子规则和测试数据，若重新初始化数据库，需要确保 `database/seed/03_seed_masking_config.sql` 和 `database/seed/04_seed_student_data.sql` 已导入。

### 建议下一步

- 启动后端和前端，用 `admin`、`teacher01`、`analyst01`、`normal_user` 四个账号逐一登录验收同一条学生数据。
- 如演示时间允许，补充审计日志页面真实查询接口，展示 `access_log` 中刚产生的查询记录。

