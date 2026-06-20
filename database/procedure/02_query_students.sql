USE dynamic_data_masking;

DROP PROCEDURE IF EXISTS SP_QUERY_STUDENTS;

DELIMITER $$

CREATE PROCEDURE SP_QUERY_STUDENTS(IN p_role_code VARCHAR(50))
COMMENT '根据角色编码查询 student_info，自动应用脱敏策略'
BEGIN
    IF p_role_code = 'SUPER_ADMIN' THEN
        SELECT
            si.id,
            si.student_no,
            si.name,
            si.gender,
            si.phone,
            si.email,
            si.id_card,
            si.address,
            CAST(si.birth_date AS CHAR) AS birth_date,
            TIMESTAMPDIFF(YEAR, si.birth_date, CURDATE()) AS age,
            si.college,
            si.major,
            si.grade,
            si.class_name,
            si.gpa,
            CAST(si.family_income AS CHAR) AS family_income,
            si.bank_card
        FROM student_info si
        WHERE si.status = 1
        ORDER BY si.id;

        INSERT INTO access_log (role_code, operation_type, table_name, masking_applied, result_count, access_time)
        VALUES (p_role_code, 'QUERY', 'student_info', 0, (SELECT COUNT(*) FROM student_info WHERE status = 1), NOW());
    ELSE
    SELECT
        si.id,
        si.student_no,
        FN_APPLY_MASK(si.name, COALESCE(name_assign.masking_type, name_def.masking_type, 'NO_MASK'), COALESCE(name_assign.params, name_def.params, JSON_OBJECT())) AS name,
        si.gender,
        FN_APPLY_MASK(si.phone, COALESCE(phone_assign.masking_type, phone_def.masking_type, 'NO_MASK'), COALESCE(phone_assign.params, phone_def.params, JSON_OBJECT())) AS phone,
        FN_APPLY_MASK(si.email, COALESCE(email_assign.masking_type, email_def.masking_type, 'NO_MASK'), COALESCE(email_assign.params, email_def.params, JSON_OBJECT())) AS email,
        FN_APPLY_MASK(si.id_card, COALESCE(id_card_assign.masking_type, id_card_def.masking_type, 'NO_MASK'), COALESCE(id_card_assign.params, id_card_def.params, JSON_OBJECT())) AS id_card,
        FN_APPLY_MASK(si.address, COALESCE(address_assign.masking_type, address_def.masking_type, 'NO_MASK'), COALESCE(address_assign.params, address_def.params, JSON_OBJECT())) AS address,
        FN_APPLY_MASK(CAST(si.birth_date AS CHAR), COALESCE(birth_assign.masking_type, birth_def.masking_type, 'NO_MASK'), COALESCE(birth_assign.params, birth_def.params, JSON_OBJECT())) AS birth_date,
        TIMESTAMPDIFF(YEAR, si.birth_date, CURDATE()) AS age,
        si.college,
        si.major,
        si.grade,
        si.class_name,
        si.gpa,
        FN_APPLY_MASK(CAST(si.family_income AS CHAR), COALESCE(income_assign.masking_type, income_def.masking_type, 'NO_MASK'), COALESCE(income_assign.params, income_def.params, JSON_OBJECT())) AS family_income,
        FN_APPLY_MASK(si.bank_card, COALESCE(bank_assign.masking_type, bank_def.masking_type, 'NO_MASK'), COALESCE(bank_assign.params, bank_def.params, JSON_OBJECT())) AS bank_card
    FROM student_info si
    LEFT JOIN sensitive_field name_sf ON name_sf.table_name = 'student_info' AND name_sf.column_name = 'name'
    LEFT JOIN masking_policy name_def ON name_def.sensitive_field_id = name_sf.id AND name_def.is_default = 1 AND name_def.status = 1
    LEFT JOIN masking_rule_assignment name_mra ON name_mra.sensitive_field_id = name_sf.id AND name_mra.role_code = p_role_code AND name_mra.enabled = 1
    LEFT JOIN masking_policy name_assign ON name_assign.id = name_mra.policy_id AND name_assign.status = 1
    LEFT JOIN sensitive_field phone_sf ON phone_sf.table_name = 'student_info' AND phone_sf.column_name = 'phone'
    LEFT JOIN masking_policy phone_def ON phone_def.sensitive_field_id = phone_sf.id AND phone_def.is_default = 1 AND phone_def.status = 1
    LEFT JOIN masking_rule_assignment phone_mra ON phone_mra.sensitive_field_id = phone_sf.id AND phone_mra.role_code = p_role_code AND phone_mra.enabled = 1
    LEFT JOIN masking_policy phone_assign ON phone_assign.id = phone_mra.policy_id AND phone_assign.status = 1
    LEFT JOIN sensitive_field email_sf ON email_sf.table_name = 'student_info' AND email_sf.column_name = 'email'
    LEFT JOIN masking_policy email_def ON email_def.sensitive_field_id = email_sf.id AND email_def.is_default = 1 AND email_def.status = 1
    LEFT JOIN masking_rule_assignment email_mra ON email_mra.sensitive_field_id = email_sf.id AND email_mra.role_code = p_role_code AND email_mra.enabled = 1
    LEFT JOIN masking_policy email_assign ON email_assign.id = email_mra.policy_id AND email_assign.status = 1
    LEFT JOIN sensitive_field id_card_sf ON id_card_sf.table_name = 'student_info' AND id_card_sf.column_name = 'id_card'
    LEFT JOIN masking_policy id_card_def ON id_card_def.sensitive_field_id = id_card_sf.id AND id_card_def.is_default = 1 AND id_card_def.status = 1
    LEFT JOIN masking_rule_assignment id_card_mra ON id_card_mra.sensitive_field_id = id_card_sf.id AND id_card_mra.role_code = p_role_code AND id_card_mra.enabled = 1
    LEFT JOIN masking_policy id_card_assign ON id_card_assign.id = id_card_mra.policy_id AND id_card_assign.status = 1
    LEFT JOIN sensitive_field address_sf ON address_sf.table_name = 'student_info' AND address_sf.column_name = 'address'
    LEFT JOIN masking_policy address_def ON address_def.sensitive_field_id = address_sf.id AND address_def.is_default = 1 AND address_def.status = 1
    LEFT JOIN masking_rule_assignment address_mra ON address_mra.sensitive_field_id = address_sf.id AND address_mra.role_code = p_role_code AND address_mra.enabled = 1
    LEFT JOIN masking_policy address_assign ON address_assign.id = address_mra.policy_id AND address_assign.status = 1
    LEFT JOIN sensitive_field birth_sf ON birth_sf.table_name = 'student_info' AND birth_sf.column_name = 'birth_date'
    LEFT JOIN masking_policy birth_def ON birth_def.sensitive_field_id = birth_sf.id AND birth_def.is_default = 1 AND birth_def.status = 1
    LEFT JOIN masking_rule_assignment birth_mra ON birth_mra.sensitive_field_id = birth_sf.id AND birth_mra.role_code = p_role_code AND birth_mra.enabled = 1
    LEFT JOIN masking_policy birth_assign ON birth_assign.id = birth_mra.policy_id AND birth_assign.status = 1
    LEFT JOIN sensitive_field income_sf ON income_sf.table_name = 'student_info' AND income_sf.column_name = 'family_income'
    LEFT JOIN masking_policy income_def ON income_def.sensitive_field_id = income_sf.id AND income_def.is_default = 1 AND income_def.status = 1
    LEFT JOIN masking_rule_assignment income_mra ON income_mra.sensitive_field_id = income_sf.id AND income_mra.role_code = p_role_code AND income_mra.enabled = 1
    LEFT JOIN masking_policy income_assign ON income_assign.id = income_mra.policy_id AND income_assign.status = 1
    LEFT JOIN sensitive_field bank_sf ON bank_sf.table_name = 'student_info' AND bank_sf.column_name = 'bank_card'
    LEFT JOIN masking_policy bank_def ON bank_def.sensitive_field_id = bank_sf.id AND bank_def.is_default = 1 AND bank_def.status = 1
    LEFT JOIN masking_rule_assignment bank_mra ON bank_mra.sensitive_field_id = bank_sf.id AND bank_mra.role_code = p_role_code AND bank_mra.enabled = 1
    LEFT JOIN masking_policy bank_assign ON bank_assign.id = bank_mra.policy_id AND bank_assign.status = 1
    WHERE si.status = 1
    ORDER BY si.id;

    INSERT INTO access_log (role_code, operation_type, table_name, masking_applied, result_count, access_time)
    VALUES (p_role_code, 'QUERY', 'student_info', 1, (SELECT COUNT(*) FROM student_info WHERE status = 1), NOW());
    END IF;
END$$

DELIMITER ;
