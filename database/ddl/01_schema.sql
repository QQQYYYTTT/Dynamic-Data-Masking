CREATE DATABASE IF NOT EXISTS dynamic_data_masking
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE dynamic_data_masking;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS sys_user_role;
DROP TABLE IF EXISTS sys_role_permission;
DROP TABLE IF EXISTS masking_rule_assignment;
DROP TABLE IF EXISTS rule_change_log;
DROP TABLE IF EXISTS access_log;
DROP TABLE IF EXISTS abnormal_access;
DROP TABLE IF EXISTS masking_policy;
DROP TABLE IF EXISTS masking_type_dict;
DROP TABLE IF EXISTS sensitive_field;
DROP TABLE IF EXISTS student_score;
DROP TABLE IF EXISTS student_info;
DROP TABLE IF EXISTS sys_permission;
DROP TABLE IF EXISTS sys_role;
DROP TABLE IF EXISTS sys_user;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码，BCrypt加密存储',
    real_name VARCHAR(50) COMMENT '真实姓名',
    status TINYINT DEFAULT 1 COMMENT '状态：1正常，0禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='系统用户表';

CREATE TABLE sys_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name VARCHAR(50) NOT NULL COMMENT '角色名称',
    role_code VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    description VARCHAR(255) COMMENT '角色描述',
    status TINYINT DEFAULT 1 COMMENT '状态：1正常，0禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='系统角色表';

CREATE TABLE sys_permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    permission_name VARCHAR(100) NOT NULL COMMENT '权限名称',
    permission_code VARCHAR(100) NOT NULL UNIQUE COMMENT '权限编码',
    permission_type VARCHAR(20) NOT NULL COMMENT '权限类型：MENU/API/DATA',
    parent_id BIGINT DEFAULT NULL COMMENT '父级权限ID',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态：1正常，0禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_parent_id (parent_id)
) COMMENT='系统权限表';

CREATE TABLE sys_user_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    UNIQUE KEY uk_user_role (user_id, role_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES sys_role(id) ON DELETE CASCADE
) COMMENT='用户角色关联表';

CREATE TABLE sys_role_permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    permission_id BIGINT NOT NULL COMMENT '权限ID',
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES sys_role(id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES sys_permission(id) ON DELETE CASCADE
) COMMENT='角色权限关联表';

CREATE TABLE student_info (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    student_no VARCHAR(30) NOT NULL UNIQUE COMMENT '学号',
    name VARCHAR(50) COMMENT '姓名',
    gender CHAR(1) COMMENT '性别：M-男，F-女，U-未知',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    id_card VARCHAR(30) COMMENT '身份证号',
    address VARCHAR(255) COMMENT '家庭住址',
    birth_date DATE COMMENT '出生日期',
    college VARCHAR(100) COMMENT '学院',
    major VARCHAR(100) COMMENT '专业',
    grade VARCHAR(20) COMMENT '年级',
    class_name VARCHAR(100) COMMENT '班级',
    gpa DECIMAL(3,2) COMMENT '绩点',
    family_income DECIMAL(10,2) COMMENT '家庭年收入',
    bank_card VARCHAR(30) COMMENT '银行卡号',
    status TINYINT DEFAULT 1 COMMENT '状态：1正常，0停用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_college_major_grade (college, major, grade),
    INDEX idx_student_no (student_no)
) COMMENT='学生信息表';

CREATE TABLE student_score (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成绩记录ID',
    student_id BIGINT NOT NULL COMMENT '学生ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    score DECIMAL(5,2) COMMENT '分数',
    semester VARCHAR(20) COMMENT '学期',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_student_id (student_id),
    INDEX idx_course_name (course_name),
    INDEX idx_student_course (student_id, course_name),
    CONSTRAINT fk_ss_student FOREIGN KEY (student_id) REFERENCES student_info(id) ON DELETE CASCADE
) COMMENT='学生成绩表';

CREATE TABLE sensitive_field (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '敏感字段ID',
    entity_name VARCHAR(50) NOT NULL COMMENT '业务实体标签',
    table_name VARCHAR(100) NOT NULL COMMENT '数据库表名',
    column_name VARCHAR(100) NOT NULL COMMENT '数据库字段名',
    column_comment VARCHAR(255) COMMENT '字段中文说明',
    sensitive_type VARCHAR(50) NOT NULL COMMENT '敏感类型',
    sensitive_level VARCHAR(20) NOT NULL COMMENT '敏感等级：LOW/MEDIUM/HIGH',
    identify_method VARCHAR(50) COMMENT '识别方式：MANUAL/FIELD_NAME/REGEX',
    enabled TINYINT DEFAULT 1 COMMENT '是否启用保护：1启用，0禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_field (table_name, column_name),
    INDEX idx_entity_name (entity_name),
    INDEX idx_table_name (table_name),
    INDEX idx_enabled (enabled)
) COMMENT='敏感字段元数据表';

CREATE TABLE masking_type_dict (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    type_code VARCHAR(50) NOT NULL UNIQUE COMMENT '脱敏方式编码',
    type_name VARCHAR(100) COMMENT '脱敏方式中文名称',
    description VARCHAR(255) COMMENT '脱敏方式说明',
    param_schema JSON COMMENT '参数结构描述',
    default_params JSON COMMENT '默认参数模板',
    status TINYINT DEFAULT 1 COMMENT '状态：1启用，0禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='脱敏方式字典表';

CREATE TABLE masking_policy (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '策略ID',
    sensitive_field_id BIGINT NOT NULL COMMENT '敏感字段ID',
    policy_name VARCHAR(80) NOT NULL COMMENT '策略名称',
    masking_type VARCHAR(50) NOT NULL COMMENT '脱敏方式编码',
    params JSON COMMENT '脱敏参数',
    is_default TINYINT DEFAULT 0 COMMENT '是否字段默认策略',
    status TINYINT DEFAULT 1 COMMENT '状态：1启用，0禁用',
    create_by BIGINT COMMENT '创建人用户ID',
    update_by BIGINT COMMENT '更新人用户ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_policy_field_name (sensitive_field_id, policy_name),
    INDEX idx_sensitive_field_id (sensitive_field_id),
    INDEX idx_masking_type (masking_type),
    INDEX idx_is_default (is_default),
    CONSTRAINT fk_mp_sf FOREIGN KEY (sensitive_field_id) REFERENCES sensitive_field(id) ON DELETE RESTRICT,
    CONSTRAINT fk_mp_mt FOREIGN KEY (masking_type) REFERENCES masking_type_dict(type_code) ON DELETE RESTRICT,
    CONSTRAINT fk_mp_cb FOREIGN KEY (create_by) REFERENCES sys_user(id) ON DELETE SET NULL,
    CONSTRAINT fk_mp_ub FOREIGN KEY (update_by) REFERENCES sys_user(id) ON DELETE SET NULL
) COMMENT='脱敏策略表';

CREATE TABLE masking_rule_assignment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分配ID',
    policy_id BIGINT NOT NULL COMMENT '策略ID',
    role_code VARCHAR(50) NOT NULL COMMENT '角色编码',
    sensitive_field_id BIGINT NOT NULL COMMENT '敏感字段ID',
    enabled TINYINT DEFAULT 1 COMMENT '是否启用：1启用，0禁用',
    create_by BIGINT COMMENT '创建人用户ID',
    update_by BIGINT COMMENT '更新人用户ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_assignment_field_role (sensitive_field_id, role_code),
    INDEX idx_policy_id (policy_id),
    INDEX idx_role_code (role_code),
    CONSTRAINT fk_mra_policy FOREIGN KEY (policy_id) REFERENCES masking_policy(id) ON DELETE CASCADE,
    CONSTRAINT fk_mra_role FOREIGN KEY (role_code) REFERENCES sys_role(role_code) ON DELETE RESTRICT,
    CONSTRAINT fk_mra_sf FOREIGN KEY (sensitive_field_id) REFERENCES sensitive_field(id) ON DELETE RESTRICT,
    CONSTRAINT fk_mra_cb FOREIGN KEY (create_by) REFERENCES sys_user(id) ON DELETE SET NULL,
    CONSTRAINT fk_mra_ub FOREIGN KEY (update_by) REFERENCES sys_user(id) ON DELETE SET NULL
) COMMENT='脱敏规则分配表';

CREATE TABLE access_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT COMMENT '用户ID',
    username VARCHAR(50) COMMENT '用户名快照',
    role_code VARCHAR(50) COMMENT '角色编码快照',
    operation_type VARCHAR(50) COMMENT '操作类型：QUERY/EXPORT/LOGIN',
    sql_text TEXT COMMENT '查询语句或查询条件JSON',
    table_name VARCHAR(100) COMMENT '访问表名',
    accessed_columns TEXT COMMENT '访问字段列表',
    sensitive_columns TEXT COMMENT '涉及敏感字段列表',
    masking_applied TINYINT DEFAULT 0 COMMENT '是否执行脱敏',
    masking_snapshot JSON COMMENT '脱敏结果快照',
    result_count INT COMMENT '返回记录数',
    client_ip VARCHAR(100) COMMENT '客户端IP',
    access_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
    INDEX idx_user_time (user_id, access_time),
    INDEX idx_role_time (role_code, access_time),
    INDEX idx_table_name (table_name),
    INDEX idx_operation_type (operation_type),
    CONSTRAINT fk_al_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE SET NULL
) COMMENT='访问审计日志表';

CREATE TABLE rule_change_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    policy_id BIGINT COMMENT '变更策略ID',
    operator_id BIGINT COMMENT '操作人用户ID',
    operator_name VARCHAR(50) COMMENT '操作人名称快照',
    operation_type VARCHAR(50) COMMENT '操作类型：CREATE/UPDATE/DELETE/ENABLE/DISABLE',
    before_content JSON COMMENT '修改前内容',
    after_content JSON COMMENT '修改后内容',
    remark VARCHAR(255) COMMENT '备注',
    operate_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    INDEX idx_policy_id (policy_id),
    INDEX idx_operator_id (operator_id),
    INDEX idx_operate_time (operate_time),
    CONSTRAINT fk_rcl_policy FOREIGN KEY (policy_id) REFERENCES masking_policy(id) ON DELETE SET NULL,
    CONSTRAINT fk_rcl_op FOREIGN KEY (operator_id) REFERENCES sys_user(id) ON DELETE SET NULL
) COMMENT='脱敏策略变更日志表';

CREATE TABLE abnormal_access (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT COMMENT '涉及用户ID',
    username VARCHAR(50) COMMENT '用户名快照',
    role_code VARCHAR(50) COMMENT '角色编码快照',
    abnormal_type VARCHAR(50) NOT NULL COMMENT '异常类型',
    trigger_source VARCHAR(30) COMMENT '触发来源：API/SQL/EXPORT/ADMIN',
    detail TEXT COMMENT '异常详情',
    severity VARCHAR(20) NOT NULL COMMENT '严重程度：LOW/MEDIUM/HIGH',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '处理状态',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发现时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_create_time (create_time),
    INDEX idx_abnormal_type (abnormal_type),
    CONSTRAINT fk_aa_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE SET NULL
) COMMENT='异常访问记录表';
