CREATE TABLE departments (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  dept_code VARCHAR(50) NOT NULL,
  dept_name VARCHAR(100) NOT NULL,
  parent_id BIGINT NULL,
  leader_employee_id BIGINT NULL,
  level INT NOT NULL DEFAULT 1,
  path VARCHAR(255) NOT NULL DEFAULT '/',
  sort_order INT NOT NULL DEFAULT 0,
  status INT NOT NULL DEFAULT 1,
  remark VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by INT NULL,
  updated_by INT NULL,
  CONSTRAINT uk_departments_dept_code UNIQUE (dept_code)
);

CREATE TABLE positions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  position_code VARCHAR(50) NOT NULL,
  position_name VARCHAR(100) NOT NULL,
  level_name VARCHAR(50) NULL,
  status INT NOT NULL DEFAULT 1,
  remark VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by INT NULL,
  updated_by INT NULL,
  CONSTRAINT uk_positions_position_code UNIQUE (position_code)
);

CREATE TABLE employees (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  emp_no VARCHAR(50) NOT NULL,
  name VARCHAR(50) NOT NULL,
  gender VARCHAR(10) NOT NULL,
  phone VARCHAR(20) NULL,
  email VARCHAR(100) NULL,
  dept_id BIGINT NOT NULL,
  position_id BIGINT NOT NULL,
  leader_id BIGINT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  hire_date DATE NOT NULL,
  left_at DATETIME NULL,
  deleted_at DATETIME NULL,
  birth_date DATE NULL,
  address VARCHAR(255) NULL,
  remark VARCHAR(255) NULL,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by INT NULL,
  updated_by INT NULL,
  CONSTRAINT uk_employees_emp_no UNIQUE (emp_no)
);

CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  real_name VARCHAR(50) NOT NULL,
  phone VARCHAR(20) NULL,
  email VARCHAR(100) NULL,
  employee_id BIGINT NULL,
  status INT NOT NULL DEFAULT 1,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by INT NULL,
  updated_by INT NULL,
  CONSTRAINT uk_users_username UNIQUE (username),
  CONSTRAINT uk_users_employee_id UNIQUE (employee_id)
);

CREATE TABLE roles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  role_code VARCHAR(50) NOT NULL,
  role_name VARCHAR(50) NOT NULL,
  status INT NOT NULL DEFAULT 1,
  remark VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by INT NULL,
  updated_by INT NULL,
  CONSTRAINT uk_roles_role_code UNIQUE (role_code)
);

CREATE TABLE permissions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  perm_code VARCHAR(100) NOT NULL,
  perm_name VARCHAR(100) NOT NULL,
  perm_type VARCHAR(20) NOT NULL,
  parent_id BIGINT NULL,
  route_path VARCHAR(200) NULL,
  icon VARCHAR(100) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  status INT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by INT NULL,
  updated_by INT NULL,
  CONSTRAINT uk_permissions_perm_code UNIQUE (perm_code)
);

CREATE TABLE user_roles (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_permissions (
  role_id BIGINT NOT NULL,
  permission_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, permission_id)
);

ALTER TABLE departments
  ADD CONSTRAINT fk_departments_parent_id_departments
  FOREIGN KEY (parent_id) REFERENCES departments(id);

ALTER TABLE departments
  ADD CONSTRAINT fk_departments_leader_employee_id_employees
  FOREIGN KEY (leader_employee_id) REFERENCES employees(id);

ALTER TABLE employees
  ADD CONSTRAINT fk_employees_dept_id_departments
  FOREIGN KEY (dept_id) REFERENCES departments(id);

ALTER TABLE employees
  ADD CONSTRAINT fk_employees_position_id_positions
  FOREIGN KEY (position_id) REFERENCES positions(id);

ALTER TABLE employees
  ADD CONSTRAINT fk_employees_leader_id_employees
  FOREIGN KEY (leader_id) REFERENCES employees(id);

ALTER TABLE users
  ADD CONSTRAINT fk_users_employee_id_employees
  FOREIGN KEY (employee_id) REFERENCES employees(id);

ALTER TABLE permissions
  ADD CONSTRAINT fk_permissions_parent_id_permissions
  FOREIGN KEY (parent_id) REFERENCES permissions(id);

ALTER TABLE user_roles
  ADD CONSTRAINT fk_user_roles_user_id_users
  FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE user_roles
  ADD CONSTRAINT fk_user_roles_role_id_roles
  FOREIGN KEY (role_id) REFERENCES roles(id);

ALTER TABLE role_permissions
  ADD CONSTRAINT fk_role_permissions_role_id_roles
  FOREIGN KEY (role_id) REFERENCES roles(id);

ALTER TABLE role_permissions
  ADD CONSTRAINT fk_role_permissions_permission_id_permissions
  FOREIGN KEY (permission_id) REFERENCES permissions(id);

CREATE INDEX idx_departments_parent_id ON departments(parent_id);
CREATE INDEX idx_employees_name ON employees(name);
CREATE INDEX idx_employees_dept_id ON employees(dept_id);
CREATE INDEX idx_employees_position_id ON employees(position_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_is_deleted ON employees(is_deleted);
