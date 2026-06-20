# 数据库脚本

本目录用于放置动态数据脱敏系统的 MySQL 8 数据库脚本。

## 执行前提

- MySQL 8.x。
- 已创建或拥有可创建数据库的用户。
- 默认数据库名：`dynamic_data_masking`。
- 后端配置文件 `backend/src/main/resources/application.yml` 默认连接该数据库。

## 本地便携版 MySQL

当前项目在 Windows 中文路径下运行 MySQL 时，MySQL 对 `basedir/datadir` 的中文路径解析不稳定。因此本项目采用“项目内保存 MySQL ZIP，运行时复制到系统临时目录”的方式启动本地 MySQL，不注册系统服务。

启动命令：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\start-local-mysql.ps1
```

默认连接信息：

```text
host: localhost
port: 3306
database: dynamic_data_masking
username: root
password: root
```

## 执行顺序

请在项目根目录或任意目录中使用 MySQL 客户端按以下顺序执行：

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

## 脚本说明

- `ddl/01_schema.sql`：创建数据库和 14 张核心表。
- `seed/01_seed_roles_permissions.sql`：初始化 8 类角色、MENU/API/DATA 权限和角色权限关系。
- `seed/02_seed_users.sql`：初始化演示用户，密码统一为 `123456`。
- `seed/03_seed_masking_config.sql`：初始化敏感字段、脱敏方式、脱敏策略和角色规则分配。
- `seed/04_seed_student_data.sql`：初始化学生和成绩演示数据。
- `procedure/01_fn_apply_mask.sql`：统一脱敏函数。
- `procedure/02_query_students.sql`：学生信息动态脱敏查询过程。
- `procedure/03_query_student_scores.sql`：学生成绩动态脱敏查询过程。
- `procedure/04_detect_abnormal.sql`：异常访问检测过程。
- `trigger/01_policy_change_log.sql`：脱敏策略变更日志触发器。
- `view/01_masking_config_view.sql`：脱敏配置总览视图。

## 当前环境说明

当前开发环境已使用 MySQL 8.4.6 Windows ZIP 便携版完成初始化，并已导入全部 SQL 脚本。MySQL 运行目录位于系统临时目录 `DDM-MySQL`，项目内的 MySQL ZIP 和解压目录已加入 `.gitignore`，避免提交大型二进制文件。
