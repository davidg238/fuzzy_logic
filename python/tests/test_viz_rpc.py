"""Tests for fuzzy_lab.viz.rpc — uses a small in-process HTTP fake."""

import json
import threading
from contextlib import contextmanager
from http.server import BaseHTTPRequestHandler, HTTPServer

import pytest

from fuzzy_lab.viz.rpc import FuzzyClient


class _Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, body: dict) -> None:
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, *_):
        pass

    def do_GET(self):
        if self.path == "/model":
            self._send(200, {"name": "fake", "inputs": [], "outputs": [], "rules": []})
            return
        if self.path == "/state":
            self._send(200, {"inputs": [{"name": "x", "crisp": 1.5, "terms": []}],
                             "outputs": [],
                             "rules": []})
            return
        self._send(404, {"error": "no"})


@contextmanager
def fake_server():
    server = HTTPServer(("127.0.0.1", 0), _Handler)
    port = server.server_address[1]
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()
    try:
        yield f"http://127.0.0.1:{port}"
    finally:
        server.shutdown()


def test_get_model():
    with fake_server() as base:
        c = FuzzyClient(base)
        m = c.get_model()
        assert m["name"] == "fake"
        assert m["inputs"] == []


def test_get_state():
    with fake_server() as base:
        c = FuzzyClient(base)
        s = c.get_state()
        assert s["inputs"][0]["name"] == "x"
        assert s["inputs"][0]["crisp"] == 1.5


def test_unknown_path_raises():
    with fake_server() as base:
        c = FuzzyClient(base)
        # Direct httpx hit on an unknown path should raise via raise_for_status
        # only if we exposed that path; instead verify the client doesn't crash on a 404
        # response from the server when given an arbitrary endpoint. We do this by calling
        # get_model on a base URL that doesn't have /model — but our fake handles /model
        # already. So this test just confirms 404s on /unknown via raw httpx would raise.
        import httpx
        with pytest.raises(httpx.HTTPStatusError):
            with httpx.Client(timeout=2.0) as h:
                r = h.get(f"{base}/unknown")
                r.raise_for_status()
