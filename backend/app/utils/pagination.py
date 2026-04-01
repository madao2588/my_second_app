from app.schemas.common import PageQuery


def get_offset_limit(page_query: PageQuery) -> tuple[int, int]:
    offset = (page_query.page - 1) * page_query.page_size
    return offset, page_query.page_size
