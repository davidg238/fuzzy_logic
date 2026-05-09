from pathlib import Path
import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]


@pytest.fixture
def fcl_dir() -> Path:
    return REPO_ROOT / "fcl"


@pytest.fixture
def sample_tipper_dict() -> dict:
    return {
        "name": "tipper",
        "defuzz_method": "COG",
        "inputs": [
            {
                "name": "service",
                "terms": [
                    {"name": "poor",      "a": 0, "b": 0, "c": 0, "d": 4},
                    {"name": "good",      "a": 1, "b": 4, "c": 6, "d": 9},
                    {"name": "excellent", "a": 6, "b": 9, "c": 9, "d": 9},
                ],
            },
        ],
        "outputs": [
            {
                "name": "tip",
                "terms": [
                    {"name": "cheap",   "a": 0,  "b": 5,  "c": 5,  "d": 10},
                    {"name": "average", "a": 10, "b": 15, "c": 15, "d": 20},
                ],
            },
        ],
        "rules": [
            {
                "if":   {"op": "is", "var": "service", "term": "poor"},
                "then": [{"var": "tip", "term": "cheap"}],
            },
        ],
    }
