"""HTTP client for the Toit RpcService (view-only viz, GET only)."""

from __future__ import annotations

from typing import Any

import httpx


class FuzzyClient:
    """Synchronous GET-only client for the Toit fuzzy_logic RpcService.

    Two endpoints are exposed by the service:
      - GET /model  → topology (one-shot at startup)
      - GET /state  → runtime state (polled by the viz)
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
