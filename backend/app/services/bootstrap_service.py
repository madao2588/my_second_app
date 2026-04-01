from datetime import date

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import get_password_hash
from app.models.department import Department
from app.models.employee import Employee
from app.models.permission import Permission
from app.models.position import Position
from app.models.role import Role
from app.models.user import User


class BootstrapService:
    def __init__(self, db: Session):
        self.db = db

    def seed_if_needed(self) -> None:
        self._seed_departments()
        self._seed_positions()
        self._seed_employees()
        self._seed_permissions()
        self._seed_roles()
        self._seed_users()
        self.db.commit()

    def _seed_departments(self) -> None:
        records = [
            {
                "id": 1,
                "dept_code": "ROOT",
                "dept_name": "总部",
                "parent_id": None,
                "level": 1,
                "path": "/1/",
                "sort_order": 1,
                "status": 1,
                "remark": "企业根部门",
            },
            {
                "id": 2,
                "dept_code": "HR",
                "dept_name": "人力资源部",
                "parent_id": 1,
                "level": 2,
                "path": "/1/2/",
                "sort_order": 2,
                "status": 1,
                "remark": "负责招聘与组织管理",
            },
            {
                "id": 3,
                "dept_code": "TECH",
                "dept_name": "技术部",
                "parent_id": 1,
                "level": 2,
                "path": "/1/3/",
                "sort_order": 3,
                "status": 1,
                "remark": "负责产品研发与技术支持",
            },
            {
                "id": 4,
                "dept_code": "FIN",
                "dept_name": "财务部",
                "parent_id": 1,
                "level": 2,
                "path": "/1/4/",
                "sort_order": 4,
                "status": 1,
                "remark": "负责财务管理与预算",
            },
        ]
        for item in records:
            department = self.db.execute(
                select(Department).where(Department.dept_code == item["dept_code"])
            ).scalar_one_or_none()
            if department is None:
                self.db.add(Department(**item))
        self.db.flush()

    def _seed_positions(self) -> None:
        records = [
            {
                "id": 1,
                "position_code": "GM",
                "position_name": "总经理",
                "level_name": "P6",
                "status": 1,
                "remark": "企业负责人",
            },
            {
                "id": 2,
                "position_code": "HR_MANAGER",
                "position_name": "HR经理",
                "level_name": "P4",
                "status": 1,
                "remark": "负责人事管理",
            },
            {
                "id": 3,
                "position_code": "FE_ENGINEER",
                "position_name": "前端工程师",
                "level_name": "P3",
                "status": 1,
                "remark": "负责前端开发",
            },
            {
                "id": 4,
                "position_code": "BE_ENGINEER",
                "position_name": "后端工程师",
                "level_name": "P3",
                "status": 1,
                "remark": "负责后端开发",
            },
            {
                "id": 5,
                "position_code": "FIN_SPECIALIST",
                "position_name": "财务专员",
                "level_name": "P2",
                "status": 1,
                "remark": "负责财务处理",
            },
        ]
        for item in records:
            position = self.db.execute(
                select(Position).where(Position.position_code == item["position_code"])
            ).scalar_one_or_none()
            if position is None:
                self.db.add(Position(**item))
        self.db.flush()

    def _seed_employees(self) -> None:
        records = [
            {
                "id": 1,
                "emp_no": "EMP0001",
                "name": "王总",
                "gender": "male",
                "phone": "13800000001",
                "email": "wangzong@example.com",
                "dept_id": 1,
                "position_id": 1,
                "leader_id": None,
                "status": "active",
                "hire_date": date(2024, 1, 1),
                "birth_date": date(1985, 5, 10),
                "address": "上海市浦东新区",
                "remark": "系统初始化管理员员工",
                "is_deleted": False,
            },
            {
                "id": 2,
                "emp_no": "EMP0002",
                "name": "李敏",
                "gender": "female",
                "phone": "13800000002",
                "email": "limin@example.com",
                "dept_id": 2,
                "position_id": 2,
                "leader_id": 1,
                "status": "active",
                "hire_date": date(2024, 2, 1),
                "birth_date": date(1990, 3, 12),
                "address": "上海市徐汇区",
                "remark": "HR负责人",
                "is_deleted": False,
            },
            {
                "id": 3,
                "emp_no": "EMP0003",
                "name": "张晨",
                "gender": "male",
                "phone": "13800000003",
                "email": "zhangchen@example.com",
                "dept_id": 3,
                "position_id": 3,
                "leader_id": 1,
                "status": "active",
                "hire_date": date(2024, 3, 1),
                "birth_date": date(1996, 7, 18),
                "address": "上海市闵行区",
                "remark": "前端工程师",
                "is_deleted": False,
            },
            {
                "id": 4,
                "emp_no": "EMP0004",
                "name": "周凯",
                "gender": "male",
                "phone": "13800000004",
                "email": "zhoukai@example.com",
                "dept_id": 3,
                "position_id": 4,
                "leader_id": 1,
                "status": "active",
                "hire_date": date(2024, 3, 15),
                "birth_date": date(1994, 11, 21),
                "address": "上海市杨浦区",
                "remark": "后端工程师",
                "is_deleted": False,
            },
            {
                "id": 5,
                "emp_no": "EMP0005",
                "name": "陈薇",
                "gender": "female",
                "phone": "13800000005",
                "email": "chenwei@example.com",
                "dept_id": 4,
                "position_id": 5,
                "leader_id": 1,
                "status": "active",
                "hire_date": date(2024, 4, 1),
                "birth_date": date(1993, 9, 9),
                "address": "上海市静安区",
                "remark": "财务专员",
                "is_deleted": False,
            },
        ]
        for item in records:
            employee = self.db.execute(
                select(Employee).where(Employee.emp_no == item["emp_no"])
            ).scalar_one_or_none()
            if employee is None:
                self.db.add(Employee(**item))
        self.db.flush()

        leaders = {1: 1, 2: 2, 3: 4, 4: 5}
        for dept_id, leader_employee_id in leaders.items():
            department = self.db.get(Department, dept_id)
            if department is not None:
                department.leader_employee_id = leader_employee_id

    def _seed_permissions(self) -> None:
        records = [
            {
                "perm_code": "dashboard:view",
                "perm_name": "仪表盘",
                "perm_type": "menu",
                "parent_id": None,
                "route_path": "/dashboard",
                "icon": "dashboard",
                "sort_order": 1,
                "status": 1,
            },
            {
                "perm_code": "emp:view",
                "perm_name": "员工管理",
                "perm_type": "menu",
                "parent_id": None,
                "route_path": "/employees",
                "icon": "groups",
                "sort_order": 10,
                "status": 1,
            },
            {
                "perm_code": "emp:add",
                "perm_name": "新增员工",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 11,
                "status": 1,
            },
            {
                "perm_code": "emp:edit",
                "perm_name": "编辑员工",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 12,
                "status": 1,
            },
            {
                "perm_code": "emp:delete",
                "perm_name": "删除员工",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 13,
                "status": 1,
            },
            {
                "perm_code": "emp:export",
                "perm_name": "导出员工",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 14,
                "status": 1,
            },
            {
                "perm_code": "dept:view",
                "perm_name": "部门管理",
                "perm_type": "menu",
                "parent_id": None,
                "route_path": "/departments",
                "icon": "account_tree",
                "sort_order": 20,
                "status": 1,
            },
            {
                "perm_code": "dept:add",
                "perm_name": "新增部门",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 21,
                "status": 1,
            },
            {
                "perm_code": "dept:edit",
                "perm_name": "编辑部门",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 22,
                "status": 1,
            },
            {
                "perm_code": "dept:delete",
                "perm_name": "删除部门",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 23,
                "status": 1,
            },
            {
                "perm_code": "position:view",
                "perm_name": "岗位管理",
                "perm_type": "menu",
                "parent_id": None,
                "route_path": "/positions",
                "icon": "badge",
                "sort_order": 30,
                "status": 1,
            },
            {
                "perm_code": "position:add",
                "perm_name": "新增岗位",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 31,
                "status": 1,
            },
            {
                "perm_code": "position:edit",
                "perm_name": "编辑岗位",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 32,
                "status": 1,
            },
            {
                "perm_code": "position:delete",
                "perm_name": "删除岗位",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 33,
                "status": 1,
            },
            {
                "perm_code": "user:view",
                "perm_name": "用户管理",
                "perm_type": "menu",
                "parent_id": None,
                "route_path": "/users",
                "icon": "person",
                "sort_order": 40,
                "status": 1,
            },
            {
                "perm_code": "user:add",
                "perm_name": "新增用户",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 41,
                "status": 1,
            },
            {
                "perm_code": "user:edit",
                "perm_name": "编辑用户",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 42,
                "status": 1,
            },
            {
                "perm_code": "user:delete",
                "perm_name": "删除用户",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 43,
                "status": 1,
            },
            {
                "perm_code": "user:assign-role",
                "perm_name": "分配角色",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 44,
                "status": 1,
            },
            {
                "perm_code": "role:view",
                "perm_name": "角色权限",
                "perm_type": "menu",
                "parent_id": None,
                "route_path": "/roles",
                "icon": "shield",
                "sort_order": 50,
                "status": 1,
            },
            {
                "perm_code": "role:add",
                "perm_name": "新增角色",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 51,
                "status": 1,
            },
            {
                "perm_code": "role:edit",
                "perm_name": "编辑角色",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 52,
                "status": 1,
            },
            {
                "perm_code": "role:delete",
                "perm_name": "删除角色",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 53,
                "status": 1,
            },
            {
                "perm_code": "role:assign-permission",
                "perm_name": "分配权限",
                "perm_type": "button",
                "parent_id": None,
                "route_path": None,
                "icon": None,
                "sort_order": 54,
                "status": 1,
            },
        ]

        code_to_id: dict[str, int] = {}
        for item in records:
            permission = self.db.execute(
                select(Permission).where(Permission.perm_code == item["perm_code"])
            ).scalar_one_or_none()
            if permission is None:
                permission = Permission(
                    perm_code=item["perm_code"],
                    perm_name=item["perm_name"],
                    perm_type=item["perm_type"],
                    route_path=item["route_path"],
                    icon=item["icon"],
                    sort_order=item["sort_order"],
                    status=item["status"],
                )
                self.db.add(permission)
                self.db.flush()

            permission.perm_name = item["perm_name"]
            permission.perm_type = item["perm_type"]
            permission.route_path = item["route_path"]
            permission.icon = item["icon"]
            permission.sort_order = item["sort_order"]
            permission.status = item["status"]
            code_to_id[item["perm_code"]] = permission.id

        parent_map = {
            "emp:add": "emp:view",
            "emp:edit": "emp:view",
            "emp:delete": "emp:view",
            "emp:export": "emp:view",
            "dept:add": "dept:view",
            "dept:edit": "dept:view",
            "dept:delete": "dept:view",
            "position:add": "position:view",
            "position:edit": "position:view",
            "position:delete": "position:view",
            "user:add": "user:view",
            "user:edit": "user:view",
            "user:delete": "user:view",
            "user:assign-role": "user:view",
            "role:add": "role:view",
            "role:edit": "role:view",
            "role:delete": "role:view",
            "role:assign-permission": "role:view",
        }
        for child_code, parent_code in parent_map.items():
            child = self.db.execute(
                select(Permission).where(Permission.perm_code == child_code)
            ).scalar_one()
            child.parent_id = code_to_id[parent_code]
        self.db.flush()

    def _seed_roles(self) -> None:
        role_records = [
            {
                "role_code": "super_admin",
                "role_name": "超级管理员",
                "status": 1,
                "remark": "系统默认超级管理员",
            },
            {
                "role_code": "hr_admin",
                "role_name": "HR管理员",
                "status": 1,
                "remark": "负责人事模块",
            },
        ]
        for item in role_records:
            role = self.db.execute(
                select(Role).where(Role.role_code == item["role_code"])
            ).scalar_one_or_none()
            if role is None:
                role = Role(**item)
                self.db.add(role)
                self.db.flush()
            role.role_name = item["role_name"]
            role.status = item["status"]
            role.remark = item["remark"]

        permissions = list(self.db.execute(select(Permission)).scalars().all())
        permission_map = {item.perm_code: item for item in permissions}

        super_admin = self.db.execute(
            select(Role).where(Role.role_code == "super_admin")
        ).scalar_one()
        super_admin.permissions = permissions

        hr_admin = self.db.execute(select(Role).where(Role.role_code == "hr_admin")).scalar_one()
        hr_admin.permissions = [
            permission_map[code]
            for code in [
                "dashboard:view",
                "emp:view",
                "emp:add",
                "emp:edit",
                "dept:view",
                "position:view",
                "user:view",
            ]
            if code in permission_map
        ]
        self.db.flush()

    def _seed_users(self) -> None:
        admin = self.db.execute(
            select(User).where(User.username == "admin")
        ).scalar_one_or_none()
        if admin is None:
            admin = User(
                username="admin",
                password_hash=get_password_hash("123456"),
                real_name="系统管理员",
                phone="13800009999",
                email="admin@example.com",
                employee_id=1,
                status=1,
            )
            self.db.add(admin)
            self.db.flush()

        admin.real_name = "系统管理员"
        admin.phone = "13800009999"
        admin.email = "admin@example.com"
        admin.employee_id = 1
        admin.status = 1

        role = self.db.execute(
            select(Role).where(Role.role_code == "super_admin")
        ).scalar_one_or_none()
        if role is not None and role not in admin.roles:
            admin.roles.append(role)
        self.db.flush()
