import logging
from typing import Dict
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.models.task import Task

logger = logging.getLogger("task.resequencer")


def resequence_all_tasks(db: Session) -> Dict[int, int]:
    """
    Re-sequences all tasks in SQLite so their IDs are consecutive: 1, 2, ..., N.
    Returns a dictionary of {old_id: new_id} for all tasks whose ID changed.
    Also updates the SQLite autoincrement sequence so the next created task gets N + 1.
    """
    remaining_tasks = db.query(Task).order_by(Task.created_at.asc(), Task.id.asc()).all()
    n = len(remaining_tasks)

    if n == 0:
        try:
            db.execute(text("DELETE FROM sqlite_sequence WHERE name = 'tasks'"))
            db.commit()
        except Exception as e:
            logger.warning(f"Could not reset sqlite_sequence: {e}")
        return {}

    mapping: Dict[int, int] = {}
    changes = []
    for i, t in enumerate(remaining_tasks):
        target_id = i + 1
        mapping[t.id] = target_id
        if t.id != target_id:
            changes.append((t.id, target_id))

    if not changes:
        try:
            db.execute(text("UPDATE sqlite_sequence SET seq = :max_id WHERE name = 'tasks'"), {"max_id": n})
            db.commit()
        except Exception as e:
            logger.warning(f"Could not update sqlite_sequence: {e}")
        return {}

    # Phase 1: Assign temporary large non-colliding IDs (1000000 + i) to avoid PK uniqueness collision
    for i, (old_id, new_id) in enumerate(changes):
        db.execute(
            text("UPDATE tasks SET id = :temp_id WHERE id = :old_id"),
            {"temp_id": 1000000 + i, "old_id": old_id}
        )
    db.commit()

    # Phase 2: Set final sequential IDs (1..N)
    for i, (old_id, new_id) in enumerate(changes):
        db.execute(
            text("UPDATE tasks SET id = :new_id WHERE id = :temp_id"),
            {"new_id": new_id, "temp_id": 1000000 + i}
        )
    db.commit()

    # Phase 3: Set sqlite_sequence so future auto-increments start at N + 1
    try:
        db.execute(
            text("UPDATE sqlite_sequence SET seq = :max_id WHERE name = 'tasks'"),
            {"max_id": n}
        )
        db.commit()
    except Exception as e:
        logger.warning(f"Could not update sqlite_sequence: {e}")

    logger.info(f"[Resequencer] Successfully re-sequenced {len(changes)} tasks to contiguous range 1..{n}.")
    return {old_id: new_id for old_id, new_id in mapping.items() if old_id != new_id}
