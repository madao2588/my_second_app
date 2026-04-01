INSERT INTO departments (
  id, dept_code, dept_name, parent_id, leader_employee_id, level, path, sort_order, status, remark
) VALUES
  (1, 'ROOT', '总部', NULL, NULL, 1, '/1/', 1, 1, '企业根部门'),
  (2, 'HR', '人力资源部', 1, NULL, 2, '/1/2/', 2, 1, '负责人事与组织管理'),
  (3, 'TECH', '技术部', 1, NULL, 2, '/1/3/', 3, 1, '负责研发与技术支持'),
  (4, 'FIN', '财务部', 1, NULL, 2, '/1/4/', 4, 1, '负责财务与预算');

INSERT INTO positions (
  id, position_code, position_name, level_name, status, remark
) VALUES
  (1, 'GM', '总经理', 'P6', 1, '企业负责人'),
  (2, 'HR_MANAGER', 'HR经理', 'P4', 1, '负责招聘与人事'),
  (3, 'FE_ENGINEER', '前端工程师', 'P3', 1, '负责前端开发'),
  (4, 'BE_ENGINEER', '后端工程师', 'P3', 1, '负责后端开发'),
  (5, 'FIN_SPECIALIST', '财务专员', 'P2', 1, '负责财务处理');

INSERT INTO employees (
  id, emp_no, name, gender, phone, email, dept_id, position_id, leader_id, status, hire_date, left_at,
  deleted_at, birth_date, address, remark, is_deleted
) VALUES
  (1, 'EMP0001', '王总', 'male', '13800000001', 'wangzong@example.com', 1, 1, NULL, 'active',
   '2024-01-01', NULL, NULL, '1985-05-10', '上海市浦东新区', '系统初始化管理员员工', FALSE),
  (2, 'EMP0002', '李敏', 'female', '13800000002', 'limin@example.com', 2, 2, 1, 'active',
   '2024-02-01', NULL, NULL, '1990-03-12', '上海市徐汇区', 'HR负责人', FALSE),
  (3, 'EMP0003', '张晨', 'male', '13800000003', 'zhangchen@example.com', 3, 3, 1, 'active',
   '2024-03-01', NULL, NULL, '1996-07-18', '上海市闵行区', '前端工程师', FALSE),
  (4, 'EMP0004', '周凯', 'male', '13800000004', 'zhoukai@example.com', 3, 4, 1, 'active',
   '2024-03-15', NULL, NULL, '1994-11-21', '上海市杨浦区', '后端工程师', FALSE),
  (5, 'EMP0005', '陈薇', 'female', '13800000005', 'chenwei@example.com', 4, 5, 1, 'active',
   '2024-04-01', NULL, NULL, '1993-09-09', '上海市静安区', '财务专员', FALSE);

UPDATE departments SET leader_employee_id = 1 WHERE id = 1;
UPDATE departments SET leader_employee_id = 2 WHERE id = 2;
UPDATE departments SET leader_employee_id = 4 WHERE id = 3;
UPDATE departments SET leader_employee_id = 5 WHERE id = 4;

INSERT INTO roles (
  id, role_code, role_name, status, remark
) VALUES
  (1, 'super_admin', '超级管理员', 1, '系统默认超级管理员'),
  (2, 'hr_admin', 'HR管理员', 1, '负责人事模块'),
  (3, 'dept_manager', '部门主管', 1, '负责本部门数据'),
  (4, 'normal_user', '普通用户', 1, '普通只读用户');

INSERT INTO permissions (
  id, perm_code, perm_name, perm_type, parent_id, route_path, icon, sort_order, status
) VALUES
  (1, 'dashboard:view', '仪表盘', 'menu', NULL, '/dashboard', 'dashboard', 1, 1),
  (2, 'emp:view', '员工管理', 'menu', NULL, '/employees', 'groups', 10, 1),
  (3, 'emp:add', '新增员工', 'button', 2, NULL, NULL, 11, 1),
  (4, 'emp:edit', '编辑员工', 'button', 2, NULL, NULL, 12, 1),
  (5, 'emp:delete', '删除员工', 'button', 2, NULL, NULL, 13, 1),
  (6, 'emp:export', '导出员工', 'button', 2, NULL, NULL, 14, 1),
  (7, 'dept:view', '部门管理', 'menu', NULL, '/departments', 'account_tree', 20, 1),
  (8, 'dept:add', '新增部门', 'button', 7, NULL, NULL, 21, 1),
  (9, 'dept:edit', '编辑部门', 'button', 7, NULL, NULL, 22, 1),
  (10, 'dept:delete', '删除部门', 'button', 7, NULL, NULL, 23, 1),
  (11, 'position:view', '岗位管理', 'menu', NULL, '/positions', 'badge', 30, 1),
  (12, 'position:add', '新增岗位', 'button', 11, NULL, NULL, 31, 1),
  (13, 'position:edit', '编辑岗位', 'button', 11, NULL, NULL, 32, 1),
  (14, 'position:delete', '删除岗位', 'button', 11, NULL, NULL, 33, 1),
  (15, 'user:view', '用户管理', 'menu', NULL, '/users', 'person', 40, 1),
  (16, 'role:view', '角色权限', 'menu', NULL, '/roles', 'shield', 50, 1),
  (17, 'api:health', '健康检查接口', 'api', NULL, '/api/v1/health', NULL, 99, 1);

INSERT INTO users (
  id, username, password_hash, real_name, phone, email, employee_id, status, last_login_at
) VALUES
  (1, 'admin', '$2b$12$J0xYn3g7qeycUGysX0Jxyuc7UCbVQBjvlgTBxEdj/0OosTfj1qg3u', '系统管理员',
   '13800009999', 'admin@example.com', 1, 1, NULL);

INSERT INTO user_roles (user_id, role_id) VALUES
  (1, 1);

INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

INSERT INTO role_permissions (role_id, permission_id) VALUES
  (2, 1),
  (2, 2),
  (2, 3),
  (2, 4),
  (2, 6),
  (2, 7),
  (2, 8),
  (2, 9),
  (2, 11),
  (2, 15),
  (3, 1),
  (3, 2),
  (3, 4),
  (3, 7),
  (3, 11),
  (4, 1);
