# Enterprise Admin Platform 企业基础信息管理平台

一个使用 Flutter 与 FastAPI 构建的企业基础信息管理原型，覆盖员工、部门、岗位、用户、角色权限和仪表盘等后台管理场景。

项目重点不是单个页面，而是把前端管理界面、后端 API、权限模型和数据结构组织成一套可继续扩展的业务系统。

## 核心能力

- 账号登录、会话保存与无权限页面
- 员工信息查询、创建、编辑、删除和分页
- 部门树、岗位、用户和角色管理页面
- 菜单、按钮、API 三类权限模型
- 仪表盘统计卡片与数据图表
- 统一的加载、空状态、错误状态和操作反馈组件
- 响应式侧边栏、面包屑和管理后台布局

## 技术栈

### 前端

- Flutter / Dart
- Riverpod
- GoRouter
- Dio
- fl_chart
- SharedPreferences

### 后端

- Python / FastAPI
- SQLAlchemy
- Pydantic
- JWT
- SQLite（本地演示）/ MySQL 兼容配置

## 项目结构

```text
.
├─ lib/
│  ├─ app/                  # 路由、主题、导航和整体布局
│  ├─ core/                 # 网络、权限、通用组件和常量
│  └─ features/             # 认证、仪表盘、员工、部门、岗位、用户、角色
├─ test/                    # Flutter 测试
├─ backend/
│  ├─ app/api/              # FastAPI 路由
│  ├─ app/core/             # 配置、数据库、安全与统一响应
│  ├─ app/models/           # SQLAlchemy 模型
│  ├─ app/services/         # 业务服务
│  └─ sql/                  # 建表与种子数据
└─ README.md
```

## 本地运行

### 1. 启动后端

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload
```

后端默认地址：

- API：`http://127.0.0.1:8000/api/v1`
- Swagger：`http://127.0.0.1:8000/docs`

本地种子数据包含演示管理员账号 `admin / 123456`，仅用于本地开发，不应直接用于部署环境。

### 2. 启动前端

```powershell
flutter pub get
flutter run -d chrome
```

## 测试与检查

```powershell
flutter analyze
flutter test

cd backend
python -m compileall app
```

仓库目前包含 Flutter 组件与页面测试；后端已做静态编译检查，正式交付前仍应补充接口和权限回归测试。

## 当前定位

这是一个可运行、可演示、可继续扩展的管理系统原型。正式部署前仍应补充生产数据库配置、密钥管理、HTTPS、监控告警和更完整的端到端测试。
