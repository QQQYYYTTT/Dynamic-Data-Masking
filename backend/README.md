# 后端工程

本目录用于放置动态数据脱敏系统的 Java 后端代码。

当前技术栈：

- Java 17
- Spring Boot 3.x
- MyBatis
- MySQL
- Spring Security
- JWT 登录认证
- RBAC 权限控制
- 动态脱敏策略服务
- 访问审计与异常访问记录

## 当前接口

```text
GET /api/health
POST /api/auth/login
GET /api/auth/me
POST /api/auth/logout
```

`/api/health` 用于验证后端服务是否启动。认证接口依赖 MySQL 中的 `sys_user`、`sys_role`、`sys_permission` 等权限表。

## 运行方式

本目录是 Maven 工程。项目内已经安装 Maven 3.9.16，可在项目根目录执行：

```bash
.\mvnw.cmd -f backend\pom.xml spring-boot:run
```

测试命令：

```bash
.\mvnw.cmd -f backend\pom.xml test
```

登录测试示例：

```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"teacher01\",\"password\":\"123456\"}"
```
