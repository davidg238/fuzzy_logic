"""fuzzy-lab CLI: launch the view-only Dash visualizer pointed at an RpcService."""

import argparse
import sys

from fuzzy_lab.schema import Model
from fuzzy_lab.viz.app import AppConfig, build_app
from fuzzy_lab.viz.rpc import FuzzyClient


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="fuzzy-lab")
    p.add_argument("--connect", default="http://127.0.0.1:8080",
                   help="Base URL of the Toit RpcService (default: http://127.0.0.1:8080)")
    p.add_argument("--port", type=int, default=8050, help="Dash port (default: 8050)")
    p.add_argument("--poll-ms", type=int, default=500, help="state poll interval (default: 500)")
    args = p.parse_args(argv)

    client = FuzzyClient(args.connect)
    try:
        model_dict = client.get_model()
        state = client.get_state()
    except Exception as exc:
        print(f"fuzzy-lab: failed to reach {args.connect}: {exc}", file=sys.stderr)
        return 1

    model = Model.from_dict(model_dict)
    config = AppConfig(base_url=args.connect, poll_ms=args.poll_ms)
    app = build_app(config, model, state)
    app.run(debug=False, host="127.0.0.1", port=args.port)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
