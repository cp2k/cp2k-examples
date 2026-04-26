#!/usr/bin/env python3
"""Generate the runnable-example tables in README.md from manifest.tsv."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parent
MANIFEST = ROOT / "manifest.tsv"
README = ROOT / "README.md"
BEGIN_MARKER = "<!-- BEGIN GENERATED EXAMPLES -->"
END_MARKER = "<!-- END GENERATED EXAMPLES -->"

CHAPTER_TITLES = {
    "02-total-energy-and-force-methods": "2. Total Energy and Force Methods",
    "03-electronic-band-structure": "3. Electronic Band Structure",
    "04-embedding-methods": "4. Embedding Methods",
    "05-magnetic-resonance": "5. Magnetic Resonance",
    "06-optical-spectroscopy": "6. Optical Spectroscopy",
    "07-excited-state-dynamics": "7. Excited-State Dynamics",
    "08-x-ray-spectroscopy": "8. X-Ray Spectroscopy",
    "09-energy-decomposition-analysis": "9. Energy Decomposition Analysis",
    "10-finite-temperature-effects": "10. Finite-Temperature Effects",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail if README.md is stale")
    return parser.parse_args()


def read_manifest() -> list[dict[str, str]]:
    with MANIFEST.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def markdown_cell(value: str) -> str:
    return value.replace("|", r"\|")


def format_snippets(value: str) -> str:
    return ", ".join(part.strip() for part in value.split(",") if part.strip())


def chapter_key(row: dict[str, str]) -> str:
    return row["file"].split("/", 1)[0]


def generate_examples(rows: list[dict[str, str]]) -> str:
    lines = [BEGIN_MARKER]
    current_chapter = None
    for row in rows:
        chapter = chapter_key(row)
        if chapter != current_chapter:
            if current_chapter is not None:
                lines.append("")
            current_chapter = chapter
            lines.extend(
                [
                    f"### {CHAPTER_TITLES.get(chapter, chapter)}",
                    "",
                    "| input | topic | based on snippets | local test result | quick |",
                    "| --- | --- | --- | --- | --- |",
                ]
            )

        quick = "yes" if row.get("quick", "").strip().lower() == "yes" else "-"
        lines.append(
            "| "
            + " | ".join(
                [
                    f"`{markdown_cell(row['file'])}`",
                    markdown_cell(row["topic"]),
                    markdown_cell(format_snippets(row["snippets"])),
                    markdown_cell(row["result"]),
                    quick,
                ]
            )
            + " |"
        )
    lines.extend(["", END_MARKER])
    return "\n".join(lines)


def replace_generated_block(readme: str, generated: str) -> str:
    before, marker, rest = readme.partition(BEGIN_MARKER)
    if not marker:
        raise SystemExit(f"Missing marker in {README}: {BEGIN_MARKER}")
    _, marker, after = rest.partition(END_MARKER)
    if not marker:
        raise SystemExit(f"Missing marker in {README}: {END_MARKER}")
    return before.rstrip() + "\n\n" + generated + "\n\n" + after.lstrip()


def main() -> int:
    args = parse_args()
    readme = README.read_text(encoding="utf-8")
    generated = generate_examples(read_manifest())
    updated = replace_generated_block(readme, generated)

    if args.check:
        if updated != readme:
            print(
                "README.md is stale; run cp2k-made-simple/runnable/generate_readme.py.",
                file=sys.stderr,
            )
            return 1
        return 0

    README.write_text(updated, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
