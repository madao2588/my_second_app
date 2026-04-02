# 后端开发说明

## 一、当前进度

项目目前已经完成以下两部分，并已开始进入下一阶段：

### 第一阶段：后端底层与数据库设计

已完成：

- 应用入口与基础配置
- 数据库引擎与会话管理
- 统一 API 响应结构
- 全局异常处理
- 核心数据模型设计
- 基础 Pydantic Schema
- 环境变量样例文件
- 第一阶段数据库建表 SQL
- 第一阶段种子数据 SQL

### 第二阶段：认证基础与权限底座

已完成：

- 登录接口 `/api/v1/auth/login`
- 当前用户接口 `/api/v1/auth/me`
- JWT 签发与解析
- 当前登录用户依赖 `get_current_user`
- 路由级权限依赖 `require_permission`

### 第三阶段：核心业务模块

当前已启动，并已完成第一条业务链：

- 员工管理基础 CRUD 接口
- 部门下拉选项接口
- 岗位下拉选项接口

## 二、目录结构

```text
backend/
  app/
    api/
      deps.py
      router.py
      v1/
        auth.py
        employees.py
        departments.py
        positions.py
    core/
      config.py
      database.py
      exceptions.py
      response.py
      security.py
    models/
    schemas/
    repositories/
    services/
    utils/
    main.py
  sql/
    init_phase1_schema.sql
    init_phase1_seed.sql
```

## 三、已提供的接口

### 1. 基础接口

- `GET /api/v1/health`

### 2. 认证接口

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

### 3. 员工接口

- `GET /api/v1/employees`
- `GET /api/v1/employees/{id}`
- `POST /api/v1/employees`
- `PUT /api/v1/employees/{id}`
- `DELETE /api/v1/employees/{id}`

### 4. 选项接口

- `GET /api/v1/departments/options`
- `GET /api/v1/positions/options`

## 四、数据模型说明

### 1. 部门 departments

- 支持树形结构
- 使用 `parent_id + level + path` 组织层级
- 可绑定部门负责人 `leader_employee_id`

### 2. 岗位 positions

- 使用平铺结构
- 支持岗位编码、岗位名称、职级、状态

### 3. 员工 employees

- 员工是核心业务表
- 关联部门与岗位
- 支持软删除：`is_deleted + deleted_at`
- 离职状态独立保存：`status + left_at`

### 4. 用户 users

- 用户与员工一对一关联
- 用户是系统账号主体，不和员工表直接合并

### 5. 角色 roles

- 角色用于聚合权限

### 6. 权限 permissions

- 支持三类权限：`menu / button / api`
- 用于实现菜单显隐、按钮显隐、接口权限校验

## 五、环境变量

将 `.env.example` 复制为 `.env` 后，根据本地环境修改：

- `APP_NAME`
- `APP_VERSION`
- `API_PREFIX`
- `DATABASE_URL`
- `DATABASE_ECHO`
- `AUTO_CREATE_TABLES`
- `SECRET_KEY`
- `ACCESS_TOKEN_EXPIRE_MINUTES`

## 六、安装与启动

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

### 2. 启动服务

```bash
uvicorn app.main:app --reload
```

### 3. 健康检查

```text
GET /api/v1/health
```

## 七、SQL 文件说明

### 1. 建表脚本

- `sql/init_phase1_schema.sql`

### 2. 种子数据脚本

- `sql/init_phase1_seed.sql`

默认管理员账号信息：

- 用户名：`admin`
- 初始密码：`123456`

## 八、当前可用能力

当前后端已具备：

- FastAPI 应用可导入运行
- SQLAlchemy 模型与元数据可建表
- 统一响应模型
- 全局异常封装
- JWT 登录与当前用户解析
- 路由级权限校验
- 员工管理第一版 CRUD

## 九、下一步建议

接下来建议继续推进第三阶段：

1. 部门管理 CRUD
2. 岗位管理 CRUD
3. 员工导出 Excel
4. Dashboard 聚合接口
5. 更完整的 RBAC 菜单与按钮权限管理
