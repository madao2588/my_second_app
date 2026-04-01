from sqlalchemy.orm import Session

from app.repositories.permission_repository import PermissionRepository
from app.schemas.permission import PermissionNode


class PermissionService:
    def __init__(self, db: Session):
        self.repository = PermissionRepository(db)

    def get_tree(self) -> list[PermissionNode]:
        permissions = self.repository.list_active_permissions()
        node_map: dict[int, PermissionNode] = {}
        roots: list[PermissionNode] = []

        for item in permissions:
            node_map[item.id] = PermissionNode(
                id=item.id,
                perm_code=item.perm_code,
                perm_name=item.perm_name,
                perm_type=item.perm_type,
                parent_id=item.parent_id,
                route_path=item.route_path,
                icon=item.icon,
                sort_order=item.sort_order,
                status=item.status,
                created_at=item.created_at,
                updated_at=item.updated_at,
                created_by=item.created_by,
                updated_by=item.updated_by,
                children=[],
            )

        for item in permissions:
            node = node_map[item.id]
            if item.parent_id and item.parent_id in node_map:
                node_map[item.parent_id].children.append(node)
            else:
                roots.append(node)

        return roots
