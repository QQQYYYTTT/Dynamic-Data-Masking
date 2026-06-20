package com.ddm.module.student.entity;

public class MaskingRule {

    private Long sensitiveFieldId;
    private String tableName;
    private String columnName;
    private String maskingType;
    private String params;
    private String roleCode;

    public Long getSensitiveFieldId() {
        return sensitiveFieldId;
    }

    public void setSensitiveFieldId(Long sensitiveFieldId) {
        this.sensitiveFieldId = sensitiveFieldId;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getColumnName() {
        return columnName;
    }

    public void setColumnName(String columnName) {
        this.columnName = columnName;
    }

    public String getMaskingType() {
        return maskingType;
    }

    public void setMaskingType(String maskingType) {
        this.maskingType = maskingType;
    }

    public String getParams() {
        return params;
    }

    public void setParams(String params) {
        this.params = params;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }
}
