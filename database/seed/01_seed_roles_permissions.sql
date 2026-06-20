USE dynamic_data_masking;

INSERT INTO sys_role (role_name, role_code, description) VALUES
('超级管理员', 'SUPER_ADMIN', '拥有全部权限，用于系统最高管理'),
('系统管理员', 'SYSTEM_ADMIN', '管理用户、角色、权限，不接触业务数据'),
('数据管理员', 'DATA_ADMIN', '管理学生数据资源、字段、数据质量'),
('安全管理员', 'SECURITY_ADMIN', '管理敏感字段、脱敏规则、安全策略'),
('教师/教务人员', 'TEACHER', '查询学生信息，用于教学和教务管理'),
('数据分析师', 'ANALYST', '使用脱敏或泛化数据做统计分析'),
('安全审计员', 'AUDITOR', '查看访问日志、规则变更日志和异常访问'),
('普通用户', 'NORMAL', '低权限用户，只能查看高度脱敏数据');

INSERT INTO sys_permission (permission_name, permission_code, permission_type, parent_id, sort_order) VALUES
('首页仪表盘', 'MENU:DASHBOARD', 'MENU', NULL, 1),
('学生信息查询', 'MENU:STUDENT_QUERY', 'MENU', NULL, 2),
('学生数据管理', 'MENU:STUDENT_MANAGE', 'MENU', NULL, 3),
('数据分析报表', 'MENU:REPORT', 'MENU', NULL, 4),
('脱敏规则管理', 'MENU:MASKING_RULE', 'MENU', NULL, 5),
('敏感字段管理', 'MENU:SENSITIVE_FIELD', 'MENU', NULL, 6),
('安全审计日志', 'MENU:AUDIT_LOG', 'MENU', NULL, 7),
('用户管理', 'MENU:USER_MANAGE', 'MENU', NULL, 8),
('角色管理', 'MENU:ROLE_MANAGE', 'MENU', NULL, 9),
('权限管理', 'MENU:PERMISSION_MANAGE', 'MENU', NULL, 10);

INSERT INTO sys_permission (permission_name, permission_code, permission_type, sort_order) VALUES
('学生查询接口', 'API:STUDENT_QUERY', 'API', 11),
('学生详情接口', 'API:STUDENT_DETAIL', 'API', 12),
('学生新增接口', 'API:STUDENT_CREATE', 'API', 13),
('学生修改接口', 'API:STUDENT_UPDATE', 'API', 14),
('学生删除接口', 'API:STUDENT_DELETE', 'API', 15),
('生成统计报表接口', 'API:REPORT_GENERATE', 'API', 16),
('导出分析报表接口', 'API:REPORT_EXPORT', 'API', 17),
('查看脱敏规则接口', 'API:MASKING_RULE_LIST', 'API', 18),
('新增脱敏规则接口', 'API:MASKING_RULE_CREATE', 'API', 19),
('修改脱敏规则接口', 'API:MASKING_RULE_UPDATE', 'API', 20),
('删除脱敏规则接口', 'API:MASKING_RULE_DELETE', 'API', 21),
('查看敏感字段接口', 'API:SENSITIVE_FIELD_LIST', 'API', 22),
('扫描敏感字段接口', 'API:SENSITIVE_FIELD_SCAN', 'API', 23),
('访问日志接口', 'API:AUDIT_LOG_LIST', 'API', 24),
('规则变更日志接口', 'API:RULE_CHANGE_LOG_LIST', 'API', 25),
('异常访问记录接口', 'API:ABNORMAL_ACCESS_LIST', 'API', 26),
('导出审计报告接口', 'API:AUDIT_REPORT_EXPORT', 'API', 27),
('用户列表接口', 'API:USER_LIST', 'API', 28),
('新增用户接口', 'API:USER_CREATE', 'API', 29),
('修改用户接口', 'API:USER_UPDATE', 'API', 30),
('删除用户接口', 'API:USER_DELETE', 'API', 31),
('角色列表接口', 'API:ROLE_LIST', 'API', 32),
('新增角色接口', 'API:ROLE_CREATE', 'API', 33),
('修改角色接口', 'API:ROLE_UPDATE', 'API', 34),
('删除角色接口', 'API:ROLE_DELETE', 'API', 35),
('权限列表接口', 'API:PERMISSION_LIST', 'API', 36),
('权限分配接口', 'API:PERMISSION_ASSIGN', 'API', 37);

INSERT INTO sys_permission (permission_name, permission_code, permission_type, sort_order) VALUES
('查看原始数据', 'DATA:VIEW_RAW', 'DATA', 38),
('查看脱敏数据', 'DATA:VIEW_MASKED', 'DATA', 39),
('查询全部学生', 'DATA:QUERY_ALL_STUDENTS', 'DATA', 40),
('查询本人信息', 'DATA:QUERY_OWN_INFO', 'DATA', 41),
('查询敏感字段', 'DATA:QUERY_SENSITIVE', 'DATA', 42),
('管理学生数据', 'DATA:MANAGE_STUDENT', 'DATA', 43),
('使用分析报表', 'DATA:ANALYSIS_REPORT', 'DATA', 44),
('导出脱敏数据', 'DATA:EXPORT_MASKED', 'DATA', 45),
('配置脱敏规则', 'DATA:CONFIG_MASKING', 'DATA', 46),
('配置敏感字段', 'DATA:CONFIG_SENSITIVE_FIELD', 'DATA', 47),
('查看访问审计', 'DATA:AUDIT_ACCESS', 'DATA', 48),
('查看规则变更审计', 'DATA:AUDIT_RULE_CHANGE', 'DATA', 49),
('导出审计报告', 'DATA:EXPORT_AUDIT_REPORT', 'DATA', 50),
('管理用户角色权限', 'DATA:MANAGE_USER_ROLE', 'DATA', 51);

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'SUPER_ADMIN';

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'SYSTEM_ADMIN'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:USER_MANAGE', 'MENU:ROLE_MANAGE', 'MENU:PERMISSION_MANAGE',
    'API:USER_LIST', 'API:USER_CREATE', 'API:USER_UPDATE', 'API:USER_DELETE',
    'API:ROLE_LIST', 'API:ROLE_CREATE', 'API:ROLE_UPDATE', 'API:ROLE_DELETE',
    'API:PERMISSION_LIST', 'API:PERMISSION_ASSIGN',
    'DATA:MANAGE_USER_ROLE'
  );

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'DATA_ADMIN'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:STUDENT_QUERY', 'MENU:STUDENT_MANAGE', 'MENU:SENSITIVE_FIELD',
    'API:STUDENT_QUERY', 'API:STUDENT_DETAIL', 'API:STUDENT_CREATE', 'API:STUDENT_UPDATE', 'API:STUDENT_DELETE',
    'API:SENSITIVE_FIELD_LIST',
    'DATA:VIEW_MASKED', 'DATA:QUERY_ALL_STUDENTS', 'DATA:QUERY_SENSITIVE', 'DATA:MANAGE_STUDENT'
  );

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'SECURITY_ADMIN'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:MASKING_RULE', 'MENU:SENSITIVE_FIELD',
    'API:MASKING_RULE_LIST', 'API:MASKING_RULE_CREATE', 'API:MASKING_RULE_UPDATE', 'API:MASKING_RULE_DELETE',
    'API:SENSITIVE_FIELD_LIST', 'API:SENSITIVE_FIELD_SCAN', 'API:RULE_CHANGE_LOG_LIST',
    'DATA:CONFIG_MASKING', 'DATA:CONFIG_SENSITIVE_FIELD', 'DATA:AUDIT_RULE_CHANGE'
  );

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'TEACHER'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:STUDENT_QUERY',
    'API:STUDENT_QUERY', 'API:STUDENT_DETAIL',
    'DATA:VIEW_MASKED', 'DATA:QUERY_ALL_STUDENTS', 'DATA:QUERY_SENSITIVE'
  );

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'ANALYST'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:STUDENT_QUERY', 'MENU:REPORT',
    'API:STUDENT_QUERY', 'API:REPORT_GENERATE', 'API:REPORT_EXPORT',
    'DATA:VIEW_MASKED', 'DATA:QUERY_ALL_STUDENTS', 'DATA:QUERY_SENSITIVE',
    'DATA:ANALYSIS_REPORT', 'DATA:EXPORT_MASKED'
  );

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'AUDITOR'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:AUDIT_LOG',
    'API:AUDIT_LOG_LIST', 'API:RULE_CHANGE_LOG_LIST', 'API:ABNORMAL_ACCESS_LIST', 'API:AUDIT_REPORT_EXPORT',
    'DATA:AUDIT_ACCESS', 'DATA:AUDIT_RULE_CHANGE', 'DATA:EXPORT_AUDIT_REPORT'
  );

INSERT INTO sys_role_permission (role_id, permission_id)
SELECT r.id, p.id FROM sys_role r, sys_permission p
WHERE r.role_code = 'NORMAL'
  AND p.permission_code IN (
    'MENU:DASHBOARD', 'MENU:STUDENT_QUERY',
    'API:STUDENT_QUERY',
    'DATA:VIEW_MASKED'
  );
