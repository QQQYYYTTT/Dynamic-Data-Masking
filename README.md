# Dynamic Data Masking

一个基于 C++、MySQL 和字段级策略配置实现的动态数据脱敏原型。系统以 TCP 服务形式接收客户端请求，在用户登录后解析 SQL 查询字段，执行数据库查询，并根据当前账号身份对应的 JSON 规则对结果进行脱敏后返回。

本仓库当前聚焦于动态脱敏核心链路。项目设计文档进一步规划了面向高校学生信息场景的 RBAC 权限管理、敏感字段管理、审计与报表等完整业务能力。

## 项目定位

项目面向高校学生信息保护场景。姓名、手机号、邮箱、家庭住址、年龄、收入等字段具有不同敏感程度，不同身份访问同一查询结果时，应看到不同的数据粒度。

当前原型支持三种配置身份：

| 身份 | 配置文件 | 当前策略 |
| --- | --- | --- |
| `master` | `master-configuration.json` | 返回原始值 |
| `detector` | `detector-configuration.json` | 地址分级保留，年龄和收入区间泛化 |
| `normal` | `normal-configuration.json` | 姓名替换，其余敏感字段以星号遮蔽 |

完整业务设计规划了 `SUPER_ADMIN`、`SYSTEM_ADMIN`、`DATA_ADMIN`、`SECURITY_ADMIN`、`TEACHER`、`ANALYST`、`AUDITOR` 和 `NORMAL` 八类角色，详见：

- [项目业务逻辑设计v2.md](./项目业务逻辑设计v2.md)
- [用户角色权限管理表v2.md](./用户角色权限管理表v2.md)

## 当前实现状态

### 已实现

- 基于 libevent 的 TCP 服务，默认监听 `9876` 端口
- MySQL 查询执行与结果读取
- 基于 libsodium Argon2id 哈希的账号密码校验
- 基于 SQL Parser 的 `SELECT` 字段识别
- 按账号身份加载独立 JSON 脱敏策略
- 查询结果返回前的字段级动态脱敏
- 星号遮蔽、地址脱敏、邮箱脱敏、区间泛化、数据替换、结构保持和数值加噪等算法
- 中文姓名语料驱动的随机替换

### 规划中

- 完整 RBAC 用户、角色和权限模型
- 菜单、接口和数据三级权限控制
- 学生信息管理与条件查询
- 敏感字段自动扫描和分级管理
- 脱敏规则可视化配置
- 访问日志、规则变更日志和异常访问审计
- 数据分析报表与脱敏结果导出
- Web 前端与 REST API

## 工作流程

```mermaid
flowchart LR
    A["客户端连接 TCP 9876"] --> B["提交账号密码"]
    B --> C["AccountManager 校验 Argon2id 哈希"]
    C --> D["确定身份并加载 JSON 策略"]
    D --> E["客户端提交 SELECT SQL"]
    E --> F["SQL Parser 提取查询字段"]
    F --> G["MysqlOperator 执行查询"]
    G --> H["SensitiveFieldsManager 匹配字段规则"]
    H --> I["执行字段级脱敏"]
    I --> J["返回脱敏后的文本结果"]
```

## 技术栈

- C++17
- CMake 3.10+
- MySQL Client Library
- libevent
- Hyrise SQL Parser
- libsodium
- nlohmann/json，已以单头文件形式包含在仓库中

当前代码和构建产物以 Linux 环境为主，源码使用了 `arpa/inet.h` 等 POSIX 网络接口。

## 目录结构

```text
.
├── CMakeLists.txt
├── src/
│   ├── dynamic_main.cpp              # TCP 服务入口
│   ├── AccountManager.cpp            # 登录与身份识别
│   ├── MysqlOperator.cpp             # MySQL 查询执行
│   ├── SensitiveFieldsManager.cpp    # SQL 字段识别、规则加载与脱敏调度
│   ├── *Masking.cpp                  # 各类脱敏算法
│   ├── *Detector.cpp                 # 敏感信息检测器原型
│   └── include/                      # 头文件与 json.hpp
├── mask-configuration/
│   ├── account-configuration.json
│   ├── master-configuration.json
│   ├── detector-configuration.json
│   └── normal-configuration.json
├── replace-data/
│   └── Chinese_Names_Corpus（120W）.txt
├── util/
│   ├── gen-hash.cpp                  # 密码哈希辅助程序
│   └── testTime.cpp                  # 脱敏算法性能实验
├── 项目业务逻辑设计v2.md
└── 用户角色权限管理表v2.md
```

## 快速开始

### 1. 准备依赖

请在 Linux 环境安装以下开发依赖：

- C++17 编译器
- CMake
- MySQL Server 和 MySQL Client 开发库
- libevent 开发库
- libsodium 开发库
- Hyrise SQL Parser，并确保 `hsql/SQLParser.h` 和 `libsqlparser` 可被编译器及链接器找到

以 Debian/Ubuntu 为例，除 SQL Parser 外的常用依赖可通过系统包管理器安装：

```bash
sudo apt update
sudo apt install build-essential cmake libevent-dev default-libmysqlclient-dev libsodium-dev
```

### 2. 初始化示例数据库

当前服务端在 `src/dynamic_main.cpp` 中使用以下默认连接信息：

```text
host: localhost
port: 3306
user: root
password: 空
database: bisheInformation
```

可创建一张与默认配置匹配的示例表：

```sql
CREATE DATABASE IF NOT EXISTS bisheInformation
  DEFAULT CHARACTER SET utf8mb4;

USE bisheInformation;

CREATE TABLE studentInformation (
    sid INT PRIMARY KEY AUTO_INCREMENT,
    sname VARCHAR(50),
    sphone VARCHAR(20),
    saddress VARCHAR(255),
    semail VARCHAR(100),
    sps VARCHAR(255),
    sage INT,
    salary DECIMAL(12, 2)
);

INSERT INTO studentInformation
    (sname, sphone, saddress, semail, sps, sage, salary)
VALUES
    ('张三', '13812345678', '四川省成都市武侯区一环路24号',
     'zhangsan@example.com', '示例备注', 21, 86000);
```

如需使用其他数据库账号、库名或端口，请修改 `src/dynamic_main.cpp` 顶部的 `DB_HOST`、`DB_USER`、`DB_PASS`、`DB_NAME` 和 `DB_PORT`。

### 3. 编译

```bash
cmake -S . -B build
cmake --build build
```

构建成功后生成 `build/server`。

### 4. 启动服务

程序使用相对路径读取配置和姓名语料，因此应从项目根目录启动：

```bash
./build/server
```

正常启动时会输出：

```text
Server is running on port 9876, waiting for connections...
```

### 5. 登录并查询

可使用 `nc` 连接服务：

```bash
nc 127.0.0.1 9876
```

登录报文格式为：

```text
loginusername:<用户名>;password:<密码>
```

仓库内置的演示账号如下：

| 用户名 | 密码 | 身份 |
| --- | --- | --- |
| `User` | `123456` | `normal` |
| `Master` | `654321` | `master` |
| `Detector` | `654321` | `detector` |

例如：

```text
loginusername:User;password:123456
```

登录成功后提交查询：

```sql
SELECT sid, sname, sphone, saddress, semail, sps, sage, salary
FROM studentInformation;
```

也可以使用：

```sql
SELECT * FROM studentInformation;
```

服务端按空格分隔列、按换行分隔记录并返回结果。使用 `User` 登录时，姓名会被替换，其他配置为 `StarMasking(5)` 的字段统一返回五个星号；使用 `Master` 登录时返回原始值。

## 脱敏规则配置

每个身份对应一个 `<identity>-configuration.json` 文件。当前配置结构如下：

```json
[
  {
    "DataBaseName": "bisheInformation",
    "tables": [
      {
        "tableName": "studentInformation",
        "fields": [
          {
            "fieldName": "sphone",
            "mask": "StarMasking",
            "parameter": [3, 4]
          }
        ]
      }
    ]
  }
]
```

支持的脱敏方式：

| 策略 | 参数示例 | 作用 |
| --- | --- | --- |
| `NoMasking` | `[]` | 保留原始值 |
| `StarMasking` | `[]` | 将全部字符替换为 `*` |
| `StarMasking` | `[5]` | 固定返回 5 个 `*` |
| `StarMasking` | `[3, 4]` | 保留前 3 位和后 4 位 |
| `AddressMasking` | `[2]` | 按省、市、区层级保留地址 |
| `EmailMasking` | `["@"]` | 遮蔽分隔符前的邮箱用户名 |
| `GeneralizationMasking` | `[5000]` | 将数值映射到宽度为 5000 的区间 |
| `ReplaceMasking` | `["name"]` | 从姓名语料中随机选择替代值 |
| `ReplaceMasking` | `["number"]` | 生成等长随机数字 |
| `ReplaceMasking` | `["Aa1"]` | 生成等长字母、数字和下划线 |
| `StructureMasking` | `["Email", "keep site"]` | 保持部分结构并随机替换其他部分 |
| `NoiseMasking` | `[0.1]` | 在原数值上下 10% 范围内随机扰动 |

修改配置后，新的查询会重新创建 `SensitiveFieldsManager` 并读取对应身份的策略文件。

## 账号配置

账号保存在 `mask-configuration/account-configuration.json`：

```json
{
  "username": "User",
  "hashed-password": "$argon2id$...",
  "identity": "normal"
}
```

登录校验使用 libsodium 的 `crypto_pwhash_str_verify`。`util/gen-hash.cpp` 可用于生成新的 Argon2id 哈希。当前实现会在哈希前为密码追加固定字符串 `viva odden`，新增账号时必须使用相同逻辑。

配置文件中的 `password` 字段仅用于演示说明，程序实际读取的是 `hashed-password`。生产环境不应保存明文密码，应删除该字段并使用安全的密钥及账号管理方案。

## 当前限制与安全说明

本项目目前是教学和实验性质的原型，不应直接部署到生产环境。

- 数据库连接参数硬编码在源码中。
- 登录状态和身份是进程级全局变量，不同客户端连接之间没有会话隔离。
- 服务端允许客户端直接提交 SQL，当前仅验证语法是否有效，未限制为只读查询，也未进行完整的授权和注入防护。
- `SELECT *` 的字段列表被硬编码为示例表的八个字段。
- 查询别名、表达式、连接查询和复杂 SQL 的字段映射支持有限。
- TCP 协议没有消息长度、请求 ID、结构化响应和 TLS 加密。
- 部分算法仍属于实验实现，边界检查、UTF-8 字符处理和随机替换逻辑需要进一步完善。
- 当前未实现设计文档中的完整 RBAC、审计、异常检测和 Web 管理界面。

建议后续优先完成会话隔离、只读 SQL 白名单、数据库配置外置、结构化协议、审计日志和自动化测试，再扩展完整 RBAC 业务模块。

## 开发说明

仓库同时保留了两套构建入口：

- 根目录 `CMakeLists.txt`：使用 C++17，推荐使用。
- `src/Makefile`：历史构建方式，使用 C++11。

`util/testTime.cpp` 用于不同脱敏算法的简单耗时实验，不属于服务端主程序。`DetectorManager` 和 `PhoneDetector` 提供内容检测式脱敏的早期原型，当前主查询链路主要使用 SQL 字段名与 JSON 策略匹配。

## 路线图

1. 将数据库连接、监听地址和配置目录迁移到环境变量或独立配置文件。
2. 为每个 TCP 连接维护独立认证上下文，并限制可执行 SQL 类型和数据范围。
3. 将身份配置升级为设计文档中的 RBAC 模型，落实 `MENU`、`API` 和 `DATA` 权限。
4. 增加敏感字段扫描、规则管理、访问审计和异常访问检测。
5. 建设 REST API 与 Vue 管理界面，支持学生查询、规则配置和审计展示。
6. 增加单元测试、集成测试、协议测试和脱敏算法性能基准。

## License

本项目采用 [MIT License](./LICENSE)。
