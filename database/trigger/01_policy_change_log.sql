USE dynamic_data_masking;

DROP TRIGGER IF EXISTS TRG_POLICY_CHANGE_LOG_INS;
DROP TRIGGER IF EXISTS TRG_POLICY_CHANGE_LOG_UPD;
DROP TRIGGER IF EXISTS TRG_POLICY_CHANGE_LOG_DEL;

DELIMITER $$

CREATE TRIGGER TRG_POLICY_CHANGE_LOG_INS
AFTER INSERT ON masking_policy
FOR EACH ROW
BEGIN
    INSERT INTO rule_change_log (policy_id, operator_id, operator_name, operation_type, after_content, remark)
    VALUES (
        NEW.id,
        @current_user_id,
        (SELECT real_name FROM sys_user WHERE id = @current_user_id),
        'CREATE',
        JSON_OBJECT(
            'policy_name', NEW.policy_name,
            'sensitive_field_id', NEW.sensitive_field_id,
            'masking_type', NEW.masking_type,
            'params', NEW.params,
            'is_default', NEW.is_default,
            'status', NEW.status
        ),
        '新建脱敏策略'
    );
END$$

CREATE TRIGGER TRG_POLICY_CHANGE_LOG_UPD
AFTER UPDATE ON masking_policy
FOR EACH ROW
BEGIN
    INSERT INTO rule_change_log (policy_id, operator_id, operator_name, operation_type, before_content, after_content, remark)
    VALUES (
        NEW.id,
        @current_user_id,
        (SELECT real_name FROM sys_user WHERE id = @current_user_id),
        IF(NEW.status != OLD.status, IF(NEW.status = 1, 'ENABLE', 'DISABLE'), 'UPDATE'),
        JSON_OBJECT(
            'policy_name', OLD.policy_name,
            'sensitive_field_id', OLD.sensitive_field_id,
            'masking_type', OLD.masking_type,
            'params', OLD.params,
            'is_default', OLD.is_default,
            'status', OLD.status
        ),
        JSON_OBJECT(
            'policy_name', NEW.policy_name,
            'sensitive_field_id', NEW.sensitive_field_id,
            'masking_type', NEW.masking_type,
            'params', NEW.params,
            'is_default', NEW.is_default,
            'status', NEW.status
        ),
        '修改脱敏策略'
    );
END$$

CREATE TRIGGER TRG_POLICY_CHANGE_LOG_DEL
AFTER DELETE ON masking_policy
FOR EACH ROW
BEGIN
    INSERT INTO rule_change_log (policy_id, operator_id, operator_name, operation_type, before_content, remark)
    VALUES (
        OLD.id,
        @current_user_id,
        (SELECT real_name FROM sys_user WHERE id = @current_user_id),
        'DELETE',
        JSON_OBJECT(
            'policy_name', OLD.policy_name,
            'sensitive_field_id', OLD.sensitive_field_id,
            'masking_type', OLD.masking_type,
            'params', OLD.params,
            'is_default', OLD.is_default,
            'status', OLD.status
        ),
        '删除脱敏策略'
    );
END$$

DELIMITER ;
