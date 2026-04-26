#!/usr/bin/env python3
"""Validate the CP2K Made Simple runnable-example manifest."""

from __future__ import annotations

import csv
import math
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parent
MANIFEST = ROOT / "manifest.tsv"

EXPECTED_COLUMNS = [
    "file",
    "topic",
    "snippets",
    "test_status",
    "result",
    "check_pattern",
    "expected_value",
    "tolerance",
    "quick",
    "requires_feature",
]
VALID_QUICK = {"yes", "no"}
VALID_STATUS = {"passed", "not_run", "skipped"}
SNIPPET_RE = re.compile(r"\d{3}")


def fail(errors: list[str], line: int | None, message: str) -> None:
    prefix = f"line {line}: " if line is not None else ""
    errors.append(prefix + message)


def parse_float(errors: list[str], line: int, field: str, value: str) -> None:
    try:
        parsed = float(value)
    except ValueError:
        fail(errors, line, f"{field} is not a float: {value!r}")
        return
    if not math.isfinite(parsed):
        fail(errors, line, f"{field} is not finite: {value!r}")
    if field == "tolerance" and parsed < 0.0:
        fail(errors, line, f"{field} must be non-negative: {value!r}")


def manifest_rows(errors: list[str]) -> list[tuple[int, dict[str, str]]]:
    with MANIFEST.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if reader.fieldnames != EXPECTED_COLUMNS:
            fail(
                errors,
                1,
                f"unexpected columns: {reader.fieldnames!r}; expected {EXPECTED_COLUMNS!r}",
            )
            return []
        return [(line, row) for line, row in enumerate(reader, start=2)]


def runnable_inputs() -> set[str]:
    return {
        str(path.relative_to(ROOT))
        for path in ROOT.glob("*/*.inp")
        if path.is_file()
    }


def validate_row(errors: list[str], line: int, row: dict[str, str]) -> None:
    path = row["file"]
    if not path:
        fail(errors, line, "file is empty")
    elif path.startswith("/") or ".." in Path(path).parts:
        fail(errors, line, f"file must be relative and stay below runnable/: {path!r}")
    elif not path.endswith(".inp"):
        fail(errors, line, f"file should point to a .inp file: {path!r}")
    elif not (ROOT / path).is_file():
        fail(errors, line, f"file does not exist: {path!r}")

    for field in ("topic", "test_status", "result", "check_pattern"):
        if not row[field]:
            fail(errors, line, f"{field} is empty")

    snippets = [part.strip() for part in row["snippets"].split(",") if part.strip()]
    if not snippets:
        fail(errors, line, "snippets is empty")
    for snippet in snippets:
        if not SNIPPET_RE.fullmatch(snippet):
            fail(errors, line, f"invalid snippet id: {snippet!r}")

    if row["test_status"] not in VALID_STATUS:
        fail(errors, line, f"invalid test_status: {row['test_status']!r}")
    if row["quick"] not in VALID_QUICK:
        fail(errors, line, f"quick must be one of {sorted(VALID_QUICK)}: {row['quick']!r}")
    if not row["requires_feature"]:
        fail(errors, line, "requires_feature must be '-' or a feature note")

    parse_float(errors, line, "expected_value", row["expected_value"])
    parse_float(errors, line, "tolerance", row["tolerance"])


def validate_manifest() -> list[str]:
    errors: list[str] = []
    rows = manifest_rows(errors)

    seen: dict[str, int] = {}
    for line, row in rows:
        validate_row(errors, line, row)
        path = row["file"]
        if path in seen:
            fail(errors, line, f"duplicate file entry, first seen on line {seen[path]}: {path!r}")
        else:
            seen[path] = line

    manifest_files = set(seen)
    actual_files = runnable_inputs()
    for path in sorted(actual_files - manifest_files):
        fail(errors, None, f"input missing from manifest: {path}")
    for path in sorted(manifest_files - actual_files):
        fail(errors, seen[path], f"manifest entry has no matching input: {path}")

    return errors


def main() -> int:
    errors = validate_manifest()
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print(f"Validated {len(runnable_inputs())} runnable CP2K Made Simple inputs.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
