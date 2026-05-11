"""fuzzy-lab CLI: launch the Dash visualizer pointed at an RpcService."""

import argparse
import sys
from pathlib import Path

from fuzzy_lab.schema import Model
from fuzzy_lab.viz.app import AppConfig, build_app
from fuzzy_lab.viz.rpc import FuzzyClient


def _default_fcl_dir() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        candidate = parent / "fcl"
        if candidate.is_dir():
            return candidate
    return Path.cwd() / "fcl"


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="fuzzy-lab")
    p.add_argument("--connect", default="http://127.0.0.1:8080",
                   help="Base URL of the Toit RpcService (default: http://127.0.0.1:8080)")
    p.add_argument("--port", type=int, default=8050, help="Dash port (default: 8050)")
    p.add_argument("--poll-ms", type=int, default=500, help="state poll interval (default: 500)")
    p.add_argument("--fcl-dir", default=str(_default_fcl_dir()),
                   help="directory scanned for *.fcl in the model picker")
    args = p.parse_args(argv)

    client = FuzzyClient(args.connect)
    try:
        model_dict = client.get_model()
        state = client.get_state()
    except Exception as exc:
        print(f"fuzzy-lab: failed to reach {args.connect}: {exc}", file=sys.stderr)
        return 1

    model = Model.from_dict(model_dict)
    config = AppConfig(base_url=args.connect, fcl_dir=Path(args.fcl_dir),
                       poll_ms=args.poll_ms)
    app = build_app(config, model, state, model_dict)
    app.run(debug=False, host="127.0.0.1", port=args.port)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
