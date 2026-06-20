# 阶段 5 学生查询接口契约

## 学生信息查询与详情数据

| 项 | 内容 |
|---|---|
| 请求方法 | `POST` |
| 接口路径 | `/api/student/query` |
| 认证要求 | 需要 `Authorization: Bearer <token>` |
| 数据来源 | `student_info`、`student_score` |
| 规则来源 | `sensitive_field`、`masking_policy`、`masking_rule_assignment` |
| 审计行为 | 查询后写入 `access_log`，`operation_type = QUERY` |

请求示例：

```json
{
  "studentNo": "20240001",
  "name": "",
  "college": "",
  "major": "",
  "grade": "",
  "pageNum": 1,
  "pageSize": 10
}
```

响应 `data` 示例：

```json
{
  "records": [
    {
      "id": 1,
      "studentNo": "20240001",
      "name": "张三",
      "gender": "M",
      "phone": "138****5678",
      "email": "z***@school.edu.cn",
      "idCard": "510101********1234",
      "address": "四川省成都市***",
      "birthDate": "2003",
      "college": "网络空间安全学院",
      "major": "网络空间安全",
      "grade": "2023",
      "className": "网安2301",
      "gpa": 3.5,
      "familyIncome": "80000-90000",
      "bankCard": "************1234",
      "scores": [
        {
          "id": 1,
          "courseName": "数据库系统",
          "score": "80-90",
          "semester": "2024-2025-1"
        }
      ],
      "maskingTypes": {
        "student_info.phone": "KEEP_PREFIX_SUFFIX",
        "student_info.email": "EMAIL_MASK",
        "student_score.score": "GENERALIZATION"
      }
    }
  ],
  "total": 1,
  "pageNum": 1,
  "pageSize": 10,
  "username": "teacher01",
  "roles": ["TEACHER"],
  "dataView": "教师轻度脱敏视图"
}
```

## 已支持脱敏策略

| 策略编码 | 说明 |
|---|---|
| `NO_MASK` | 返回原始值 |
| `FULL_MASK` | 完全遮蔽为星号 |
| `KEEP_PREFIX` | 保留前缀 |
| `KEEP_SUFFIX` | 保留后缀 |
| `KEEP_PREFIX_SUFFIX` | 保留前后缀 |
| `EMAIL_MASK` | 邮箱用户名部分脱敏，保留域名 |
| `ADDRESS_LEVEL` | 地址按省/市层级泛化 |
| `GENERALIZATION` | 数值按步长泛化为区间 |
| `KEEP_YEAR` | 日期仅保留年份 |

## 阶段验收视图

| 账号 | 角色 | 期望数据视图 |
|---|---|---|
| `admin` | `SUPER_ADMIN` | 原始数据视图 |
| `teacher01` | `TEACHER` | 教师轻度脱敏视图 |
| `analyst01` | `ANALYST` | 分析员泛化视图 |
| `normal_user` | `NORMAL` | 普通用户高度脱敏视图 |
