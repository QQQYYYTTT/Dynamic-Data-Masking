USE dynamic_data_masking;

INSERT INTO masking_type_dict (type_code, type_name, description, param_schema, default_params) VALUES
('NO_MASK', '不脱敏', '直接返回原始值', JSON_OBJECT(), JSON_OBJECT()),
('FULL_MASK', '完全遮蔽', '将所有字符替换为等长星号', JSON_OBJECT(), JSON_OBJECT()),
('KEEP_PREFIX', '保留前缀', '保留前N个字符，其余替换为星号', JSON_OBJECT('prefix', 'int'), JSON_OBJECT('prefix', 1)),
('KEEP_SUFFIX', '保留后缀', '保留后N个字符，其余替换为星号', JSON_OBJECT('suffix', 'int'), JSON_OBJECT('suffix', 4)),
('KEEP_PREFIX_SUFFIX', '保留前后', '保留前M和后N个字符', JSON_OBJECT('prefix', 'int', 'suffix', 'int'), JSON_OBJECT('prefix', 3, 'suffix', 4)),
('EMAIL_MASK', '邮箱脱敏', '保留首字符和域名', JSON_OBJECT(), JSON_OBJECT()),
('ADDRESS_LEVEL', '地址层级', '按省市层级保留地址前缀', JSON_OBJECT('level', 'string'), JSON_OBJECT('level', 'city')),
('GENERALIZATION', '区间泛化', '将数值按步长映射到区间', JSON_OBJECT('step', 'int'), JSON_OBJECT('step', 10000)),
('HASH_MASK', '哈希脱敏', '返回哈希摘要片段', JSON_OBJECT(), JSON_OBJECT()),
('KEEP_YEAR', '保留年份', '日期仅保留年份', JSON_OBJECT(), JSON_OBJECT()),
('NOISE', '数值加噪', '按百分比输出扰动区间', JSON_OBJECT('percent', 'int'), JSON_OBJECT('percent', 10));

INSERT INTO sensitive_field (entity_name, table_name, column_name, column_comment, sensitive_type, sensitive_level, identify_method) VALUES
('STUDENT', 'student_info', 'name', '姓名', 'NAME', 'MEDIUM', 'MANUAL'),
('STUDENT', 'student_info', 'phone', '手机号', 'PHONE', 'HIGH', 'MANUAL'),
('STUDENT', 'student_info', 'email', '邮箱', 'EMAIL', 'MEDIUM', 'MANUAL'),
('STUDENT', 'student_info', 'id_card', '身份证号', 'ID_CARD', 'HIGH', 'MANUAL'),
('STUDENT', 'student_info', 'address', '家庭住址', 'ADDRESS', 'HIGH', 'MANUAL'),
('STUDENT', 'student_info', 'birth_date', '出生日期', 'BIRTH_DATE', 'HIGH', 'MANUAL'),
('STUDENT', 'student_info', 'family_income', '家庭收入', 'INCOME', 'HIGH', 'MANUAL'),
('STUDENT', 'student_info', 'bank_card', '银行卡号', 'BANK_CARD', 'HIGH', 'MANUAL'),
('STUDENT', 'student_score', 'score', '成绩分数', 'SCORE', 'MEDIUM', 'MANUAL');

INSERT INTO masking_policy (sensitive_field_id, policy_name, masking_type, params, is_default) VALUES
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'name'), '姓名保留姓氏', 'KEEP_PREFIX', JSON_OBJECT('prefix', 1), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'name'), '姓名完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'phone'), '手机号保留前后缀', 'KEEP_PREFIX_SUFFIX', JSON_OBJECT('prefix', 3, 'suffix', 4), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'phone'), '手机号完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'email'), '邮箱用户名脱敏', 'EMAIL_MASK', JSON_OBJECT(), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'email'), '邮箱完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'id_card'), '身份证保留前6后4', 'KEEP_PREFIX_SUFFIX', JSON_OBJECT('prefix', 6, 'suffix', 4), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'id_card'), '身份证完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'address'), '地址保留到市级', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'city'), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'address'), '地址保留到省级', 'ADDRESS_LEVEL', JSON_OBJECT('level', 'province'), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'address'), '地址完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'birth_date'), '生日保留年份', 'KEEP_YEAR', JSON_OBJECT(), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'family_income'), '收入区间泛化1万', 'GENERALIZATION', JSON_OBJECT('step', 10000), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'family_income'), '收入完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'bank_card'), '银行卡保留后4位', 'KEEP_SUFFIX', JSON_OBJECT('suffix', 4), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_info' AND column_name = 'bank_card'), '银行卡完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_score' AND column_name = 'score'), '成绩区间泛化10分', 'GENERALIZATION', JSON_OBJECT('step', 10), 1),
((SELECT id FROM sensitive_field WHERE table_name = 'student_score' AND column_name = 'score'), '成绩不脱敏', 'NO_MASK', JSON_OBJECT(), 0),
((SELECT id FROM sensitive_field WHERE table_name = 'student_score' AND column_name = 'score'), '成绩完全遮蔽', 'FULL_MASK', JSON_OBJECT(), 0);

-- TEACHER：教学相关字段轻度脱敏。
INSERT INTO masking_rule_assignment (policy_id, role_code, sensitive_field_id)
SELECT mp.id, 'TEACHER', mp.sensitive_field_id
FROM masking_policy mp
JOIN sensitive_field sf ON sf.id = mp.sensitive_field_id
WHERE sf.column_name IN ('phone', 'email', 'id_card', 'address', 'family_income', 'bank_card')
  AND mp.is_default = 1;

-- ANALYST：身份字段遮蔽或泛化，保留统计可用性。
INSERT INTO masking_rule_assignment (policy_id, role_code, sensitive_field_id)
SELECT mp.id, 'ANALYST', mp.sensitive_field_id
FROM masking_policy mp
JOIN sensitive_field sf ON sf.id = mp.sensitive_field_id
WHERE (sf.column_name = 'name' AND mp.policy_name = '姓名保留姓氏')
   OR (sf.column_name IN ('phone', 'email', 'family_income', 'bank_card', 'birth_date') AND mp.is_default = 1)
   OR (sf.column_name = 'id_card' AND mp.policy_name = '身份证完全遮蔽')
   OR (sf.column_name = 'address' AND mp.policy_name = '地址保留到省级')
   OR (sf.column_name = 'score' AND mp.policy_name = '成绩区间泛化10分');

-- NORMAL：敏感字段高度脱敏。
INSERT INTO masking_rule_assignment (policy_id, role_code, sensitive_field_id)
SELECT mp.id, 'NORMAL', mp.sensitive_field_id
FROM masking_policy mp
JOIN sensitive_field sf ON sf.id = mp.sensitive_field_id
WHERE mp.policy_name IN ('姓名完全遮蔽', '手机号完全遮蔽', '邮箱完全遮蔽', '身份证完全遮蔽', '地址完全遮蔽', '收入完全遮蔽', '银行卡完全遮蔽', '成绩完全遮蔽')
   OR (sf.column_name = 'birth_date' AND mp.policy_name = '生日保留年份');

-- DATA_ADMIN：按默认策略查看脱敏数据。
INSERT INTO masking_rule_assignment (policy_id, role_code, sensitive_field_id)
SELECT mp.id, 'DATA_ADMIN', mp.sensitive_field_id
FROM masking_policy mp
WHERE mp.is_default = 1;
