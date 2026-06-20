USE dynamic_data_masking;

DROP FUNCTION IF EXISTS FN_APPLY_MASK;

DELIMITER $$

CREATE FUNCTION FN_APPLY_MASK(
    p_value VARCHAR(500),
    p_mask_type VARCHAR(50),
    p_params JSON
)
RETURNS VARCHAR(500)
DETERMINISTIC
READS SQL DATA
COMMENT '统一脱敏函数：根据 type + params 对输入值执行脱敏'
BEGIN
    DECLARE v_len INT;
    DECLARE v_prefix INT;
    DECLARE v_suffix INT;
    DECLARE v_step INT;
    DECLARE v_percent INT;
    DECLARE v_level VARCHAR(20);
    DECLARE v_at_pos INT;

    IF p_value IS NULL THEN
        RETURN NULL;
    END IF;

    SET v_len = CHAR_LENGTH(p_value);

    CASE p_mask_type
        WHEN 'NO_MASK' THEN
            RETURN p_value;
        WHEN 'FULL_MASK' THEN
            RETURN REPEAT('*', v_len);
        WHEN 'KEEP_PREFIX' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.prefix')), '1') AS UNSIGNED);
            IF v_prefix >= v_len THEN
                RETURN p_value;
            END IF;
            RETURN CONCAT(LEFT(p_value, v_prefix), REPEAT('*', v_len - v_prefix));
        WHEN 'KEEP_SUFFIX' THEN
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.suffix')), '4') AS UNSIGNED);
            IF v_suffix >= v_len THEN
                RETURN p_value;
            END IF;
            RETURN CONCAT(REPEAT('*', v_len - v_suffix), RIGHT(p_value, v_suffix));
        WHEN 'KEEP_PREFIX_SUFFIX' THEN
            SET v_prefix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.prefix')), '3') AS UNSIGNED);
            SET v_suffix = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.suffix')), '4') AS UNSIGNED);
            IF v_prefix + v_suffix >= v_len THEN
                RETURN p_value;
            END IF;
            RETURN CONCAT(LEFT(p_value, v_prefix), REPEAT('*', v_len - v_prefix - v_suffix), RIGHT(p_value, v_suffix));
        WHEN 'EMAIL_MASK' THEN
            SET v_at_pos = INSTR(p_value, '@');
            IF v_at_pos <= 1 THEN
                RETURN REPEAT('*', v_len);
            END IF;
            RETURN CONCAT(LEFT(p_value, 1), REPEAT('*', v_at_pos - 2), SUBSTRING(p_value, v_at_pos));
        WHEN 'ADDRESS_LEVEL' THEN
            SET v_level = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.level')), 'city');
            IF v_level = 'province' THEN
                RETURN CONCAT(LEFT(p_value, 3), REPEAT('*', GREATEST(v_len - 3, 0)));
            ELSE
                RETURN CONCAT(LEFT(p_value, 6), REPEAT('*', GREATEST(v_len - 6, 0)));
            END IF;
        WHEN 'GENERALIZATION' THEN
            SET v_step = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.step')), '10000') AS UNSIGNED);
            RETURN CONCAT(
                FLOOR(CAST(p_value AS DECIMAL(12,2)) / v_step) * v_step,
                '-',
                (FLOOR(CAST(p_value AS DECIMAL(12,2)) / v_step) + 1) * v_step
            );
        WHEN 'HASH_MASK' THEN
            RETURN LEFT(MD5(p_value), 8);
        WHEN 'KEEP_YEAR' THEN
            RETURN CONCAT(LEFT(p_value, 4), '-**-**');
        WHEN 'NOISE' THEN
            SET v_percent = CAST(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_params, '$.percent')), '10') AS UNSIGNED);
            RETURN CONCAT(
                ROUND(CAST(p_value AS DECIMAL(12,2)) * (1 - v_percent / 100), 2),
                '-',
                ROUND(CAST(p_value AS DECIMAL(12,2)) * (1 + v_percent / 100), 2)
            );
        ELSE
            RETURN REPEAT('*', v_len);
    END CASE;
END$$

DELIMITER ;
