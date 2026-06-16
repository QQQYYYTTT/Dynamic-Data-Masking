# 数据字典

本文件是项目的动态数据约定文档。每当修改数据库表、字段、关系、索引、视图、存储过程、触发器或种子数据契约时，必须在同一次会话中更新本文件。

## 1. 数据库设计来源

当前数据设计根据 `数据库建表数据结构v3.md` 整理。

系统共规划 14 张表和 6 类数据库对象：

| 体系 | 表 |
|---|---|
| 权限体系 | `sys_user`、`sys_role`、`sys_permission`、`sys_user_role`、`sys_role_permission` |
| 业务体系 | `student_info`、`student_score` |
| 脱敏配置体系 | `sensitive_field`、`masking_type_dict`、`masking_policy`、`masking_rule_assignment` |
| 审计体系 | `access_log`、`rule_change_log`、`abnormal_access` |

数据库对象：

- 函数：`FN_APPLY_MASK`
- 存储过程：`SP_QUERY_STUDENTS`、`SP_QUERY_STUDENT_SCORES`、`SP_DETECT_ABNORMAL`
- 触发器：`TRG_POLICY_CHANGE_LOG_INS`、`TRG_POLICY_CHANGE_LOG_UPD`、`TRG_POLICY_CHANGE_LOG_DEL`
- 视图：`V_MASKING_CONFIG`

## 2. 命名和设计约定

- 表名使用小写下划线。
- 字段名使用小写下划线。
- 主键统一使用 `id BIGINT AUTO_INCREMENT`。
- 逻辑状态字段优先使用 `status` 或 `enabled`。
- 创建时间字段使用 `create_time`。
- 更新时间字段使用 `update_time`。
- 敏感字段必须记录敏感类型、敏感等级和默认脱敏方式。
- 审计日志需要保留用户名、角色编码等快照字段，避免用户删除后日志失去上下文。

## 3. 表结构详情

### 3.1 `sys_user` 系统用户表

用途：保存系统登录用户信息。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 用户 ID |
| `username` | `VARCHAR(50)` | 非空，唯一 | 登录用户名 |
| `password` | `VARCHAR(255)` | 非空 | BCrypt 密码哈希 |
| `real_name` | `VARCHAR(50)` | 可空 | 真实姓名 |
| `status` | `TINYINT` | 默认 1 | 1 正常，0 禁用 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

索引：

- `username` 唯一索引，用于登录查询。

### 3.2 `sys_role` 系统角色表

用途：定义系统角色。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 角色 ID |
| `role_name` | `VARCHAR(50)` | 非空 | 角色名称 |
| `role_code` | `VARCHAR(50)` | 非空，唯一 | 角色编码 |
| `description` | `VARCHAR(255)` | 可空 | 角色描述 |
| `status` | `TINYINT` | 默认 1 | 1 正常，0 禁用 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

预置角色：

- `SUPER_ADMIN`
- `SYSTEM_ADMIN`
- `DATA_ADMIN`
- `SECURITY_ADMIN`
- `TEACHER`
- `ANALYST`
- `AUDITOR`
- `NORMAL`

### 3.3 `sys_permission` 系统权限表

用途：定义菜单权限、接口权限和数据权限。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 权限 ID |
| `permission_name` | `VARCHAR(100)` | 非空 | 权限名称 |
| `permission_code` | `VARCHAR(100)` | 非空，唯一 | 权限编码 |
| `permission_type` | `VARCHAR(20)` | 非空 | `MENU` / `API` / `DATA` |
| `parent_id` | `BIGINT` | 可空 | 父级权限 ID |
| `sort_order` | `INT` | 默认 0 | 排序 |
| `status` | `TINYINT` | 默认 1 | 1 正常，0 禁用 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |

索引：

- `permission_code` 唯一索引。
- `idx_parent_id(parent_id)`。

### 3.4 `sys_user_role` 用户角色关联表

用途：绑定用户和角色。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 关联 ID |
| `user_id` | `BIGINT` | 非空，外键 | 用户 ID |
| `role_id` | `BIGINT` | 非空，外键 | 角色 ID |

约束和索引：

- `uk_user_role(user_id, role_id)` 防止重复绑定。
- `fk_ur_user` 外键到 `sys_user(id)`，删除用户时级联删除。
- `fk_ur_role` 外键到 `sys_role(id)`，删除角色时级联删除。

### 3.5 `sys_role_permission` 角色权限关联表

用途：绑定角色和权限。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 关联 ID |
| `role_id` | `BIGINT` | 非空，外键 | 角色 ID |
| `permission_id` | `BIGINT` | 非空，外键 | 权限 ID |

约束和索引：

- `uk_role_permission(role_id, permission_id)` 防止重复绑定。
- `idx_role_id(role_id)`。
- `idx_permission_id(permission_id)`。

### 3.6 `student_info` 学生信息表

用途：系统脱敏保护的核心业务数据源。

| 字段 | 类型 | 约束 | 说明 | 敏感等级 | 默认脱敏方式 |
|---|---|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 主键 ID | - | - |
| `student_no` | `VARCHAR(30)` | 非空，唯一 | 学号 | 低 | 默认不脱敏 |
| `name` | `VARCHAR(50)` | 可空 | 姓名 | 中 | `KEEP_PREFIX` |
| `gender` | `CHAR(1)` | 可空 | 性别，M/F/U | 低 | 默认不脱敏 |
| `phone` | `VARCHAR(20)` | 可空 | 手机号 | 高 | `KEEP_PREFIX_SUFFIX` |
| `email` | `VARCHAR(100)` | 可空 | 邮箱 | 中 | `EMAIL_MASK` |
| `id_card` | `VARCHAR(30)` | 可空 | 身份证号 | 高 | `KEEP_PREFIX_SUFFIX` 或 `FULL_MASK` |
| `address` | `VARCHAR(255)` | 可空 | 家庭住址 | 高 | `ADDRESS_LEVEL` |
| `birth_date` | `DATE` | 可空 | 出生日期 | 高 | `KEEP_YEAR` |
| `college` | `VARCHAR(100)` | 可空 | 学院 | 低 | 默认不脱敏 |
| `major` | `VARCHAR(100)` | 可空 | 专业 | 低 | 默认不脱敏 |
| `grade` | `VARCHAR(20)` | 可空 | 年级 | 低 | 默认不脱敏 |
| `class_name` | `VARCHAR(100)` | 可空 | 班级 | 低 | 默认不脱敏 |
| `gpa` | `DECIMAL(3,2)` | 可空 | 绩点 | 中 | 按角色决定 |
| `family_income` | `DECIMAL(10,2)` | 可空 | 家庭年收入 | 高 | `GENERALIZATION` |
| `bank_card` | `VARCHAR(30)` | 可空 | 银行卡号 | 高 | `KEEP_SUFFIX` 或 `FULL_MASK` |
| `status` | `TINYINT` | 默认 1 | 1 正常，0 停用 | - | - |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 | - | - |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 | - | - |

索引：

- `student_no` 唯一索引。
- `idx_college_major_grade(college, major, grade)`。
- `idx_student_no(student_no)`。

设计说明：

- 年龄不单独存储，通过 `birth_date` 查询时计算，避免年龄数据过期。

### 3.7 `student_score` 学生成绩表

用途：存储学生各科成绩，与 `student_info` 拆分以满足第三范式。

| 字段 | 类型 | 约束 | 说明 | 敏感等级 | 默认脱敏方式 |
|---|---|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 成绩记录 ID | - | - |
| `student_id` | `BIGINT` | 非空，外键 | 学生 ID | - | - |
| `course_name` | `VARCHAR(100)` | 非空 | 课程名称 | 低 | 默认不脱敏 |
| `score` | `DECIMAL(5,2)` | 可空 | 分数 | 中 | `GENERALIZATION` 或按角色决定 |
| `semester` | `VARCHAR(20)` | 可空 | 学期 | 低 | 默认不脱敏 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 | - | - |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 | - | - |

索引：

- `idx_student_id(student_id)`。
- `idx_course_name(course_name)`。
- `idx_student_course(student_id, course_name)`。

外键：

- `student_id` 关联 `student_info(id)`，学生删除时成绩级联删除。

### 3.8 `sensitive_field` 敏感字段元数据表

用途：标记系统中哪些字段属于敏感字段，以及其敏感类型和等级。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 敏感字段 ID |
| `entity_name` | `VARCHAR(50)` | 非空 | 业务实体标签，如 `STUDENT` |
| `table_name` | `VARCHAR(100)` | 非空 | 数据库表名 |
| `column_name` | `VARCHAR(100)` | 非空 | 数据库字段名 |
| `column_comment` | `VARCHAR(255)` | 可空 | 字段中文说明 |
| `sensitive_type` | `VARCHAR(50)` | 非空 | `PHONE`、`ID_CARD`、`EMAIL` 等 |
| `sensitive_level` | `VARCHAR(20)` | 非空 | `LOW` / `MEDIUM` / `HIGH` |
| `identify_method` | `VARCHAR(50)` | 可空 | `MANUAL` / `FIELD_NAME` / `REGEX` |
| `enabled` | `TINYINT` | 默认 1 | 是否启用保护 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

约束和索引：

- `uk_field(table_name, column_name)`。
- `idx_entity_name(entity_name)`。
- `idx_table_name(table_name)`。
- `idx_enabled(enabled)`。

### 3.9 `masking_type_dict` 脱敏方式字典表

用途：统一定义系统支持的脱敏方式及参数结构。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 主键 ID |
| `type_code` | `VARCHAR(50)` | 非空，唯一 | 脱敏方式编码 |
| `type_name` | `VARCHAR(100)` | 可空 | 中文名称 |
| `description` | `VARCHAR(255)` | 可空 | 方式说明 |
| `param_schema` | `JSON` | 可空 | 参数结构描述 |
| `default_params` | `JSON` | 可空 | 默认参数模板 |
| `status` | `TINYINT` | 默认 1 | 1 启用，0 禁用 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

预置脱敏方式：

- `NO_MASK`
- `FULL_MASK`
- `KEEP_PREFIX`
- `KEEP_SUFFIX`
- `KEEP_PREFIX_SUFFIX`
- `EMAIL_MASK`
- `ADDRESS_LEVEL`
- `GENERALIZATION`
- `HASH_MASK`
- `KEEP_YEAR`
- `NOISE`

### 3.10 `masking_policy` 脱敏策略表

用途：定义“某个敏感字段应该如何脱敏”。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 策略 ID |
| `sensitive_field_id` | `BIGINT` | 非空，外键 | 敏感字段 ID |
| `policy_name` | `VARCHAR(80)` | 非空 | 策略名称 |
| `masking_type` | `VARCHAR(50)` | 非空，外键 | 脱敏方式编码 |
| `params` | `JSON` | 可空 | 脱敏参数 |
| `is_default` | `TINYINT` | 默认 0 | 是否字段默认策略 |
| `status` | `TINYINT` | 默认 1 | 1 启用，0 禁用 |
| `create_by` | `BIGINT` | 可空，外键 | 创建人 |
| `update_by` | `BIGINT` | 可空，外键 | 更新人 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

约束和索引：

- `uk_policy_field_name(sensitive_field_id, policy_name)`。
- `idx_sensitive_field_id(sensitive_field_id)`。
- `idx_masking_type(masking_type)`。
- `idx_is_default(is_default)`。

策略优先级：

```text
角色分配策略 > 字段默认策略 > 安全兜底全遮蔽
```

### 3.11 `masking_rule_assignment` 脱敏规则分配表

用途：将脱敏策略分配给具体角色，定义“谁用哪条策略”。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 分配 ID |
| `policy_id` | `BIGINT` | 非空，外键 | 脱敏策略 ID |
| `role_code` | `VARCHAR(50)` | 非空，外键 | 角色编码 |
| `sensitive_field_id` | `BIGINT` | 非空，外键 | 敏感字段 ID |
| `enabled` | `TINYINT` | 默认 1 | 是否启用 |
| `create_by` | `BIGINT` | 可空，外键 | 创建人 |
| `update_by` | `BIGINT` | 可空，外键 | 更新人 |
| `create_time` | `DATETIME` | 默认当前时间 | 创建时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

约束和索引：

- `uk_assignment_field_role(sensitive_field_id, role_code)` 保证同一角色对同一字段至多一条策略。
- `idx_policy_id(policy_id)`。
- `idx_role_code(role_code)`。

设计说明：

- `sensitive_field_id` 是可控冗余字段，用于建立唯一约束，保证规则分配的数据完整性。

### 3.12 `access_log` 访问审计日志表

用途：记录每一次敏感数据访问。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 日志 ID |
| `user_id` | `BIGINT` | 可空，外键 | 用户 ID |
| `username` | `VARCHAR(50)` | 可空 | 用户名快照 |
| `role_code` | `VARCHAR(50)` | 可空 | 角色编码快照 |
| `operation_type` | `VARCHAR(50)` | 可空 | `QUERY` / `EXPORT` / `LOGIN` |
| `sql_text` | `TEXT` | 可空 | 查询语句或查询条件 JSON |
| `table_name` | `VARCHAR(100)` | 可空 | 访问表名 |
| `accessed_columns` | `TEXT` | 可空 | 访问字段 |
| `sensitive_columns` | `TEXT` | 可空 | 涉及敏感字段 |
| `masking_applied` | `TINYINT` | 默认 0 | 是否执行脱敏 |
| `masking_snapshot` | `JSON` | 可空 | 脱敏快照 |
| `result_count` | `INT` | 可空 | 返回记录数 |
| `client_ip` | `VARCHAR(100)` | 可空 | 客户端 IP |
| `access_time` | `DATETIME` | 默认当前时间 | 访问时间 |

索引：

- `idx_user_time(user_id, access_time)`。
- `idx_role_time(role_code, access_time)`。
- `idx_table_name(table_name)`。
- `idx_operation_type(operation_type)`。

### 3.13 `rule_change_log` 策略变更日志表

用途：记录 `masking_policy` 的新增、修改、删除、启用和禁用。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 日志 ID |
| `policy_id` | `BIGINT` | 可空，外键 | 策略 ID |
| `operator_id` | `BIGINT` | 可空，外键 | 操作人 ID |
| `operator_name` | `VARCHAR(50)` | 可空 | 操作人快照 |
| `operation_type` | `VARCHAR(50)` | 可空 | `CREATE` / `UPDATE` / `DELETE` / `ENABLE` / `DISABLE` |
| `before_content` | `JSON` | 可空 | 修改前快照 |
| `after_content` | `JSON` | 可空 | 修改后快照 |
| `remark` | `VARCHAR(255)` | 可空 | 备注 |
| `operate_time` | `DATETIME` | 默认当前时间 | 操作时间 |

索引：

- `idx_policy_id(policy_id)`。
- `idx_operator_id(operator_id)`。
- `idx_operate_time(operate_time)`。

### 3.14 `abnormal_access` 异常访问记录表

用途：存储异常访问检测结果。

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | `BIGINT` | 主键，自增 | 记录 ID |
| `user_id` | `BIGINT` | 可空，外键 | 用户 ID |
| `username` | `VARCHAR(50)` | 可空 | 用户名快照 |
| `role_code` | `VARCHAR(50)` | 可空 | 角色编码快照 |
| `abnormal_type` | `VARCHAR(50)` | 非空 | 异常类型 |
| `trigger_source` | `VARCHAR(30)` | 可空 | `API` / `SQL` / `EXPORT` / `ADMIN` |
| `detail` | `TEXT` | 可空 | 异常详情 |
| `severity` | `VARCHAR(20)` | 非空 | `LOW` / `MEDIUM` / `HIGH` |
| `status` | `VARCHAR(20)` | 默认 `PENDING` | 处理状态 |
| `create_time` | `DATETIME` | 默认当前时间 | 发现时间 |
| `update_time` | `DATETIME` | 自动更新 | 更新时间 |

异常类型：

- `OVER_AUTH`：越权访问。
- `HIGH_FREQ`：高频查询。
- `SENSITIVE_FOCUS`：敏感字段集中访问。
- `LARGE_EXPORT`：大量导出。

处理状态：

- `PENDING`
- `CONFIRMED`
- `DISMISSED`
- `RESOLVED`
- `ESCALATED`

## 4. 外键和级联策略

| 级联类型 | 使用场景 | 含义 |
|---|---|---|
| `CASCADE` | 用户角色、角色权限、学生成绩、规则分配等纯关联关系 | 主表删除时关联记录跟随删除 |
| `RESTRICT` | 敏感字段、脱敏方式、角色等规则依赖对象 | 防止误删导致规则链断裂 |
| `SET NULL` | 日志表用户字段、策略创建人/更新人 | 保留日志，只清空已删除用户引用 |

## 5. 预置数据约定

### 5.1 预置用户

测试用户密码统一为 `123456`，数据库中保存 BCrypt 哈希。

| 用户名 | 角色 |
|---|---|
| `admin` | `SUPER_ADMIN` |
| `system_admin` | `SYSTEM_ADMIN` |
| `data_admin` | `DATA_ADMIN` |
| `security_admin` | `SECURITY_ADMIN` |
| `teacher01` | `TEACHER` |
| `analyst01` | `ANALYST` |
| `auditor01` | `AUDITOR` |
| `normal_user` | `NORMAL` |

### 5.2 预置敏感字段

| 表 | 字段 | 类型 | 等级 |
|---|---|---|---|
| `student_info` | `name` | `NAME` | `MEDIUM` |
| `student_info` | `phone` | `PHONE` | `HIGH` |
| `student_info` | `email` | `EMAIL` | `MEDIUM` |
| `student_info` | `id_card` | `ID_CARD` | `HIGH` |
| `student_info` | `address` | `ADDRESS` | `HIGH` |
| `student_info` | `birth_date` | `BIRTH_DATE` | `HIGH` |
| `student_info` | `family_income` | `INCOME` | `HIGH` |
| `student_info` | `bank_card` | `BANK_CARD` | `HIGH` |
| `student_score` | `score` | `SCORE` | `MEDIUM` |

## 6. 数据库对象

### 6.1 `FN_APPLY_MASK`

类型：函数。

用途：根据 `masking_type` 和 `params` 对输入值执行统一脱敏。

输入：

- `p_value`：原始值。
- `p_mask_type`：脱敏方式编码。
- `p_params`：JSON 参数。

输出：

- 脱敏后的字符串。

安全兜底：

- 未知脱敏方式默认返回全遮蔽结果。

### 6.2 `SP_QUERY_STUDENTS`

类型：存储过程。

用途：根据角色编码查询 `student_info`，自动应用角色脱敏策略或字段默认策略，并写入访问日志。

### 6.3 `SP_QUERY_STUDENT_SCORES`

类型：存储过程。

用途：根据角色编码查询学生成绩，并对 `student_score.score` 应用动态脱敏策略。

### 6.4 `SP_DETECT_ABNORMAL`

类型：存储过程。

用途：扫描 `access_log`，检测高频查询、敏感字段集中访问、大量导出和普通用户越权访问，并写入 `abnormal_access`。

### 6.5 `TRG_POLICY_CHANGE_LOG_INS/UPD/DEL`

类型：触发器。

用途：当 `masking_policy` 新增、修改、删除时，自动写入 `rule_change_log`。

后端约定：

- Java 后端在修改策略前需要设置数据库会话变量 `@current_user_id`，供触发器记录操作人。

### 6.6 `V_MASKING_CONFIG`

类型：视图。

用途：将敏感字段、脱敏策略、角色分配扁平化展示，便于管理页面查询和调试。

## 7. 策略优先级

动态脱敏执行时应遵循：

```text
1. 如果用户拥有 DATA:VIEW_RAW，直接返回原始数据，但仍需写访问日志。
2. 如果用户只有 DATA:VIEW_MASKED，先查角色分配策略。
3. 如果角色没有分配策略，使用字段默认策略。
4. 如果字段没有默认策略，采用安全兜底，全遮蔽或不返回该字段。
```

## 8. 后续维护要求

- 生成真实 SQL 脚本后，应将表结构与本文件保持一致。
- 如果后续为了实现方便调整字段，必须同步更新本文件。
- 如果接口返回字段与数据库字段映射不同，应在接口契约中补充说明。
