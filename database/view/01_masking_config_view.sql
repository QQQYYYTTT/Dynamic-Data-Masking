USE dynamic_data_masking;

DROP VIEW IF EXISTS V_MASKING_CONFIG;

CREATE VIEW V_MASKING_CONFIG AS
SELECT
    sf.id AS sensitive_field_id,
    sf.entity_name,
    sf.table_name,
    sf.column_name,
    sf.column_comment,
    sf.sensitive_type,
    sf.sensitive_level,
    sf.enabled AS field_enabled,
    mp.id AS policy_id,
    mp.policy_name,
    mp.masking_type,
    mtd.type_name AS masking_type_name,
    mp.params,
    mp.is_default,
    mp.status AS policy_status,
    mra.role_code,
    mra.enabled AS assignment_enabled
FROM sensitive_field sf
LEFT JOIN masking_policy mp ON mp.sensitive_field_id = sf.id
LEFT JOIN masking_type_dict mtd ON mtd.type_code = mp.masking_type
LEFT JOIN masking_rule_assignment mra ON mra.policy_id = mp.id;
