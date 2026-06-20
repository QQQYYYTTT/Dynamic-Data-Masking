USE dynamic_data_masking;

INSERT INTO student_info
(student_no, name, gender, phone, email, id_card, address, birth_date, college, major, grade, class_name, gpa, family_income, bank_card)
VALUES
('20230001', '张三', 'M', '13812345678', 'zhangsan@school.edu.cn', '510104200301012345', '四川省成都市武侯区一环路24号', '2003-01-01', '网络空间安全学院', '网络空间安全', '2023', '网安2301', 3.65, 86000.00, '6222021234567890123'),
('20230002', '李四', 'F', '13987654321', 'lisi@school.edu.cn', '510105200302022222', '四川省成都市锦江区人民南路88号', '2003-02-02', '计算机学院', '软件工程', '2023', '软工2302', 3.42, 120000.00, '6228489876543210987'),
('20220003', '王五', 'M', '13711112222', 'wangwu@school.edu.cn', '510106200203033333', '重庆市渝中区解放碑66号', '2002-03-03', '网络空间安全学院', '信息安全', '2022', '信安2201', 3.88, 54000.00, '6217001111222233334'),
('20210004', '赵六', 'F', '13633334444', 'zhaoliu@school.edu.cn', '510107200104044444', '北京市海淀区中关村大街1号', '2001-04-04', '数学学院', '数据科学', '2021', '数科2101', 3.21, 150000.00, '6227004444555566667'),
('20240005', '陈七', 'M', '13555556666', 'chenqi@school.edu.cn', '510108200405055555', '上海市浦东新区世纪大道100号', '2004-05-05', '计算机学院', '人工智能', '2024', '智能2401', 3.73, 98000.00, '6222605555666677778');

INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '数据库系统', 92.50, '2024-2025-1' FROM student_info WHERE student_no = '20230001';
INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '网络安全基础', 88.00, '2024-2025-1' FROM student_info WHERE student_no = '20230001';
INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '数据库系统', 85.00, '2024-2025-1' FROM student_info WHERE student_no = '20230002';
INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '软件工程', 90.00, '2024-2025-1' FROM student_info WHERE student_no = '20230002';
INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '密码学', 94.00, '2023-2024-2' FROM student_info WHERE student_no = '20220003';
INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '数据挖掘', 82.00, '2023-2024-2' FROM student_info WHERE student_no = '20210004';
INSERT INTO student_score (student_id, course_name, score, semester)
SELECT id, '人工智能导论', 91.00, '2025-2026-1' FROM student_info WHERE student_no = '20240005';
