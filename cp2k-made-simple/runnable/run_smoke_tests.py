#!/usr/bin/env python3
"""Run smoke tests for the CP2K Made Simple runnable inputs."""

from __future__ import annotations

import argparse
import concurrent.futures
import csv
import fnmatch
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass


ROOT = Path(__file__).resolve().parent
MANIFEST = ROOT / "manifest.tsv"


@dataclass(frozen=True)
class Example:
    index: int
    path: str
    check_pattern: str = ""
    expected_value: float | None = None
    tolerance: float | None = None
    quick: bool = False
    requires_feature: str = ""


@dataclass(frozen=True)
class Result:
    example: Example
    elapsed: float
    ok: bool
    returncode: int | None
    output: Path
    message: str


FLOAT_RE = re.compile(r"[-+]?(?:\d+\.\d*|\.\d+|\d+)(?:[Ee][-+]?\d+)?")


def find_cp2k(value: str | None) -> str:
    if value:
        cp2k = Path(value).expanduser()
        if cp2k.exists():
            return str(cp2k)
        found = shutil.which(value)
        if found:
            return found
        raise SystemExit(f"Could not find CP2K executable: {value}")

    for name in ("cp2k.psmp", "cp2k.ssmp", "cp2k"):
        found = shutil.which(name)
        if found:
            return found
    raise SystemExit("Set --cp2k or CP2K_BINARY to a CP2K executable.")


def read_manifest() -> list[Example]:
    with MANIFEST.open(newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        examples = []
        for i, row in enumerate(reader):
            expected = row.get("expected_value", "").strip()
            tolerance = row.get("tolerance", "").strip()
            requires_feature = row.get("requires_feature", "").strip()
            examples.append(
                Example(
                    index=i,
                    path=row["file"],
                    check_pattern=row.get("check_pattern", "").strip(),
                    expected_value=float(expected) if expected else None,
                    tolerance=float(tolerance) if tolerance else None,
                    quick=row.get("quick", "").strip().lower() in {"1", "true", "yes", "y"},
                    requires_feature="" if requires_feature == "-" else requires_feature,
                )
            )
        return examples


def select_examples(examples: list[Example], patterns: list[str], quick: bool) -> list[Example]:
    if quick:
        examples = [example for example in examples if example.quick]
    if not patterns:
        return examples
    selected = [
        example
        for example in examples
        if any(fnmatch.fnmatch(example.path, pattern) for pattern in patterns)
    ]
    if not selected:
        raise SystemExit(f"No examples matched: {', '.join(patterns)}")
    return selected


def matching_line(output: Path, pattern: str) -> str:
    match = ""
    with output.open(errors="replace") as handle:
        for line in handle:
            if pattern in line:
                match = line.strip()
    return match


def extract_last_number(line: str) -> float | None:
    matches = FLOAT_RE.findall(line)
    if not matches:
        return None
    return float(matches[-1])


def validate_output(example: Example, output: Path) -> tuple[bool, str]:
    if "PROGRAM ENDED" not in output.read_text(errors="replace"):
        return False, "missing PROGRAM ENDED"

    if not example.check_pattern:
        return True, summarize_output(output)

    line = matching_line(output, example.check_pattern)
    if not line:
        return False, f"missing marker: {example.check_pattern}"

    if example.expected_value is None:
        return True, line

    actual = extract_last_number(line)
    if actual is None:
        return False, f"marker has no numeric value: {line}"

    tolerance = example.tolerance if example.tolerance is not None else 0.0
    delta = abs(actual - example.expected_value)
    if delta > tolerance:
        return (
            False,
            f"value {actual:.16g} differs from expected {example.expected_value:.16g} "
            f"by {delta:.3g} > {tolerance:.3g}: {line}",
        )
    return True, line


def summarize_output(output: Path) -> str:
    markers = (
        "ENERGY| Total FORCE_EVAL",
        "Total energy:",
        "PINT| Total energy",
        "First singlet XAS excitation energy",
        "POLAR| xx,yy,zz",
        "Excitation energy",
        "Sca-Rel A_iso",
        "Localization  for spin",
    )
    summary = ""
    with output.open(errors="replace") as handle:
        for line in handle:
            if any(marker in line for marker in markers):
                summary = line.strip()
    return summary


def run_example(
    example: Example,
    cp2k: str,
    data_dir: str | None,
    work_root: Path,
    omp_threads: int,
    timeout: float | None,
) -> Result:
    stem = Path(example.path).with_suffix("").as_posix().replace("/", "__")
    work_dir = work_root / stem
    work_dir.mkdir(parents=True, exist_ok=True)
    output = work_dir / "out.txt"
    env = os.environ.copy()
    env["OMP_NUM_THREADS"] = str(omp_threads)
    if data_dir:
        env["CP2K_DATA_DIR"] = data_dir

    start = time.monotonic()
    try:
        completed = subprocess.run(
            [cp2k, "-i", str(ROOT / example.path), "-o", "out.txt"],
            cwd=work_dir,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        elapsed = time.monotonic() - start
        return Result(example, elapsed, False, None, output, "timed out")

    elapsed = time.monotonic() - start
    if completed.returncode != 0:
        return Result(example, elapsed, False, completed.returncode, output, "nonzero exit")
    if not output.exists():
        return Result(example, elapsed, False, completed.returncode, output, "missing output")

    ok, message = validate_output(example, output)
    return Result(example, elapsed, ok, completed.returncode, output, message)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cp2k", default=os.environ.get("CP2K_BINARY"))
    parser.add_argument("--data-dir", default=os.environ.get("CP2K_DATA_DIR"))
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--omp-threads", type=int, default=1)
    parser.add_argument("--timeout", type=float, default=0.0, help="seconds per input, 0 disables")
    parser.add_argument("--work-dir", type=Path, default=None)
    parser.add_argument("--keep", action="store_true", help="keep the temporary work directory")
    parser.add_argument("--list", action="store_true", help="list selected examples without running")
    parser.add_argument("--quick", action="store_true", help="run only the quick manifest subset")
    parser.add_argument("--only", action="append", default=[], help="glob for input paths")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.jobs < 1:
        raise SystemExit("--jobs must be at least 1")
    if args.omp_threads < 1:
        raise SystemExit("--omp-threads must be at least 1")

    examples = select_examples(read_manifest(), args.only, args.quick)
    if args.list:
        for example in examples:
            print(example.path)
        return 0

    cp2k = find_cp2k(args.cp2k)
    timeout = args.timeout if args.timeout > 0 else None
    created_temp = args.work_dir is None
    work_root = args.work_dir or Path(tempfile.mkdtemp(prefix="cp2k-made-simple-smoke."))
    work_root.mkdir(parents=True, exist_ok=True)

    print(f"CP2K: {cp2k}", flush=True)
    if args.data_dir:
        print(f"CP2K_DATA_DIR: {args.data_dir}", flush=True)
    print(f"Work directory: {work_root}", flush=True)
    print(f"Examples: {len(examples)}", flush=True)
    print(f"Jobs: {args.jobs}; OMP threads per job: {args.omp_threads}", flush=True)
    if args.quick:
        print("Mode: quick", flush=True)

    results: list[Result] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
        futures = [
            executor.submit(
                run_example,
                example,
                cp2k,
                args.data_dir,
                work_root,
                args.omp_threads,
                timeout,
            )
            for example in examples
        ]
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            results.append(result)
            status = "PASS" if result.ok else "FAIL"
            print(f"{status} {result.elapsed:7.2f}s {result.example.path}", flush=True)
            if result.message:
                print(f"     {result.message}", flush=True)

    results.sort(key=lambda result: result.example.index)
    failed = [result for result in results if not result.ok]
    if failed:
        print("\nFailures:", flush=True)
        for result in failed:
            print(f"- {result.example.path}: {result.message} ({result.output})", flush=True)
        return 1

    if created_temp and not args.keep:
        shutil.rmtree(work_root)
    print("\nAll smoke tests passed.", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
