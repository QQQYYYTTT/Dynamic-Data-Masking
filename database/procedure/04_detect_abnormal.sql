USE dynamic_data_masking;

DROP PROCEDURE IF EXISTS SP_DETECT_ABNORMAL;

DELIMITER $$

CREATE PROCEDURE SP_DETECT_ABNORMAL()
COMMENT '扫描 access_log 检测高频查询、敏感字段集中访问、大量导出和越权访问'
BEGIN
    INSERT INTO abnormal_access (user_id, username, role_code, abnormal_type, trigger_source, detail, severity)
    SELECT
        al.user_id,
        al.username,
        al.role_code,
        'HIGH_FREQ',
        'API',
        CONCAT('1小时内查询了 ', COUNT(*), ' 次'),
        CASE WHEN COUNT(*) > 200 THEN 'HIGH' ELSE 'MEDIUM' END
    FROM access_log al
    WHERE al.operation_type = 'QUERY'
      AND al.access_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
      AND al.user_id IS NOT NULL
    GROUP BY al.user_id, al.username, al.role_code
    HAVING COUNT(*) > 100;

    INSERT INTO abnormal_access (user_id, username, role_code, abnormal_type, trigger_source, detail, severity)
    SELECT
        al.user_id,
        al.username,
        al.role_code,
        'SENSITIVE_FOCUS',
        'API',
        CONCAT('1天内多次查询高敏感字段：', al.sensitive_columns),
        'HIGH'
    FROM access_log al
    WHERE al.operation_type = 'QUERY'
      AND al.access_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
      AND (al.sensitive_columns LIKE '%id_card%' OR al.sensitive_columns LIKE '%bank_card%')
      AND al.user_id IS NOT NULL
    GROUP BY al.user_id, al.username, al.role_code, al.sensitive_columns
    HAVING COUNT(*) > 50;

    INSERT INTO abnormal_access (user_id, username, role_code, abnormal_type, trigger_source, detail, severity)
    SELECT
        al.user_id,
        al.username,
        al.role_code,
        'LARGE_EXPORT',
        'EXPORT',
        CONCAT('单次导出 ', al.result_count, ' 条记录'),
        CASE WHEN al.result_count > 1000 THEN 'HIGH' ELSE 'MEDIUM' END
    FROM access_log al
    WHERE al.operation_type = 'EXPORT'
      AND al.result_count > 500
      AND al.access_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
      AND al.user_id IS NOT NULL;

    INSERT INTO abnormal_access (user_id, username, role_code, abnormal_type, trigger_source, detail, severity)
    SELECT
        al.user_id,
        al.username,
        al.role_code,
        'OVER_AUTH',
        'API',
        CONCAT('NORMAL 用户访问敏感字段：', al.sensitive_columns),
        'HIGH'
    FROM access_log al
    WHERE al.role_code = 'NORMAL'
      AND al.sensitive_columns IS NOT NULL
      AND al.sensitive_columns != ''
      AND al.access_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
      AND al.user_id IS NOT NULL;
END$$

DELIMITER ;
