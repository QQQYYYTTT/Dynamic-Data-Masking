USE dynamic_data_masking;

DROP PROCEDURE IF EXISTS SP_QUERY_STUDENT_SCORES;

DELIMITER $$

CREATE PROCEDURE SP_QUERY_STUDENT_SCORES(IN p_role_code VARCHAR(50))
COMMENT '根据角色编码查询学生成绩，自动对 score 字段应用脱敏策略'
BEGIN
    IF p_role_code = 'SUPER_ADMIN' THEN
        SELECT
            ss.id,
            ss.student_id,
            si.student_no,
            si.name AS student_name,
            ss.course_name,
            ss.score,
            ss.semester,
            ss.create_time
        FROM student_score ss
        JOIN student_info si ON si.id = ss.student_id
        WHERE si.status = 1
        ORDER BY ss.student_id, ss.course_name;

        INSERT INTO access_log (role_code, operation_type, table_name, masking_applied, result_count, access_time)
        VALUES (p_role_code, 'QUERY', 'student_score', 0, (SELECT COUNT(*) FROM student_score), NOW());
    ELSE
    SELECT
        ss.id,
        ss.student_id,
        si.student_no,
        si.name AS student_name,
        ss.course_name,
        FN_APPLY_MASK(CAST(ss.score AS CHAR), COALESCE(assign.masking_type, def.masking_type, 'NO_MASK'), COALESCE(assign.params, def.params, JSON_OBJECT())) AS score,
        ss.semester,
        ss.create_time
    FROM student_score ss
    JOIN student_info si ON si.id = ss.student_id
    LEFT JOIN sensitive_field sf ON sf.table_name = 'student_score' AND sf.column_name = 'score'
    LEFT JOIN masking_policy def ON def.sensitive_field_id = sf.id AND def.is_default = 1 AND def.status = 1
    LEFT JOIN masking_rule_assignment mra ON mra.sensitive_field_id = sf.id AND mra.role_code = p_role_code AND mra.enabled = 1
    LEFT JOIN masking_policy assign ON assign.id = mra.policy_id AND assign.status = 1
    WHERE si.status = 1
    ORDER BY ss.student_id, ss.course_name;

    INSERT INTO access_log (role_code, operation_type, table_name, masking_applied, result_count, access_time)
    VALUES (p_role_code, 'QUERY', 'student_score', 1, (SELECT COUNT(*) FROM student_score), NOW());
    END IF;
END$$

DELIMITER ;
