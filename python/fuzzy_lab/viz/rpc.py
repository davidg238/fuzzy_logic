"""HTTP client for the Toit RpcService."""

from __future__ import annotations

from typing import Any

import httpx


class FuzzyClient:
    """Synchronous client for the Toit fuzzy_logic RpcService.

    Endpoints:
      - GET  /model  → topology (one-shot at startup)
      - GET  /state  → runtime state (polled by the viz)
      - POST /input  → push a crisp input value: {var, value}
    """

    def __init__(self, base_url: str, *, timeout: float = 2.0) -> None:
        self._base = base_url.rstrip("/")
        self._timeout = timeout

    def get_model(self) -> dict[str, Any]:
        with httpx.Client(timeout=self._timeout) as h:
            r = h.get(f"{self._base}/model")
            r.raise_for_status()
            return r.json()

    def get_state(self) -> dict[str, Any]:
        with httpx.Client(timeout=self._timeout) as h:
            r = h.get(f"{self._base}/state")
            r.raise_for_status()
            return r.json()

    def post_input(self, var: str, value: float) -> None:
        with httpx.Client(timeout=self._timeout) as h:
            r = h.post(f"{self._base}/input", json={"var": var, "value": value})
            r.raise_for_status()
