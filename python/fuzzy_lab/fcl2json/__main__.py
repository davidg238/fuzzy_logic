"""fcl2json CLI: convert FCL source files into the engine's JSON schema.

Usage:
  fcl2json <source.fcl> [--output OUT]
  fcl2json --all <dir> [--out-dir DIR]

In --all mode, files using unsupported membership functions (gbell, gauss,
sigm) are skipped with a stderr warning; the CLI still exits 0 unless every
file failed.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from fuzzy_lab.fcl2json.parser import parse_fcl


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="fcl2json", description="Convert FCL → JSON")
    p.add_argument("source", nargs="?", help="single .fcl path")
    p.add_argument("--all", dest="all_dir", help="convert every .fcl in <dir>")
    p.add_argument("--output", "-o", help="output JSON path (single-file mode)")
    p.add_argument("--out-dir", help="output dir for --all mode (default: <all-dir>/generated)")
    p.add_argument("--indent", type=int, default=2)
    args = p.parse_args(argv)

    if bool(args.source) == bool(args.all_dir):
        p.error("specify either a single source or --all, not both")

    try:
        if args.all_dir:
            return _convert_all(Path(args.all_dir), args.out_dir, args.indent)
        return _convert_one(Path(args.source), args.output, args.indent)
    except Exception as exc:
        print(f"fcl2json: {exc}", file=sys.stderr)
        return 1


def _convert_one(source: Path, output: str | None, indent: int) -> int:
    model = parse_fcl(source.read_text())
    text = json.dumps(model.to_dict(), indent=indent)
    if output:
        Path(output).write_text(text)
    else:
        sys.stdout.write(text + "\n")
    return 0


def _convert_all(src_dir: Path, out_dir: str | None, indent: int) -> int:
    out = Path(out_dir) if out_dir else src_dir / "generated"
    out.mkdir(parents=True, exist_ok=True)
    converted = 0
    skipped = 0
    for fcl in sorted(src_dir.glob("*.fcl")):
        try:
            model = parse_fcl(fcl.read_text())
        except NotImplementedError as exc:
            print(f"  skip {fcl.name}: {exc}", file=sys.stderr)
            skipped += 1
            continue
        (out / f"{fcl.stem}.json").write_text(json.dumps(model.to_dict(), indent=indent))
        print(f"  {fcl.name} -> {out / (fcl.stem + '.json')}")
        converted += 1
    if converted == 0:
        print(f"fcl2json: no files converted (skipped {skipped})", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
