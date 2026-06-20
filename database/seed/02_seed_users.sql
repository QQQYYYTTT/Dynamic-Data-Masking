USE dynamic_data_masking;

-- 测试账号密码统一为 123456。该 BCrypt 哈希来自原始设计文档。
SET @pwd_123456 = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi';

INSERT INTO sys_user (username, password, real_name) VALUES
('admin', @pwd_123456, '超级管理员'),
('system_admin', @pwd_123456, '系统管理员'),
('data_admin', @pwd_123456, '数据管理员'),
('security_admin', @pwd_123456, '安全管理员'),
('teacher01', @pwd_123456, '张老师'),
('analyst01', @pwd_123456, '李分析师'),
('auditor01', @pwd_123456, '王审计员'),
('normal_user', @pwd_123456, '普通用户');

INSERT INTO sys_user_role (user_id, role_id)
SELECT u.id, r.id FROM sys_user u JOIN sys_role r
WHERE (u.username = 'admin' AND r.role_code = 'SUPER_ADMIN')
   OR (u.username = 'system_admin' AND r.role_code = 'SYSTEM_ADMIN')
   OR (u.username = 'data_admin' AND r.role_code = 'DATA_ADMIN')
   OR (u.username = 'security_admin' AND r.role_code = 'SECURITY_ADMIN')
   OR (u.username = 'teacher01' AND r.role_code = 'TEACHER')
   OR (u.username = 'analyst01' AND r.role_code = 'ANALYST')
   OR (u.username = 'auditor01' AND r.role_code = 'AUDITOR')
   OR (u.username = 'normal_user' AND r.role_code = 'NORMAL');
