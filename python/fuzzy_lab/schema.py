"""Dataclasses for the fuzzy_logic JSON model schema.

Single source of truth shared by fcl2json and the visualizer; mirrors
the shape the Toit json_loader.toit consumes.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class Term:
    name: str
    a: float
    b: float
    c: float
    d: float

    @classmethod
    def from_dict(cls, d: dict) -> "Term":
        return cls(name=d["name"], a=float(d["a"]), b=float(d["b"]),
                   c=float(d["c"]), d=float(d["d"]))

    def to_dict(self) -> dict:
        return {"name": self.name, "a": _num(self.a), "b": _num(self.b),
                "c": _num(self.c), "d": _num(self.d)}


@dataclass
class FuzzyVar:
    name: str
    terms: list[Term] = field(default_factory=list)

    @classmethod
    def from_dict(cls, d: dict) -> "FuzzyVar":
        return cls(name=d["name"], terms=[Term.from_dict(t) for t in d["terms"]])

    def to_dict(self) -> dict:
        return {"name": self.name, "terms": [t.to_dict() for t in self.terms]}


@dataclass
class Consequent:
    var: str
    term: str

    @classmethod
    def from_dict(cls, d: dict) -> "Consequent":
        return cls(var=d["var"], term=d["term"])

    def to_dict(self) -> dict:
        return {"var": self.var, "term": self.term}


@dataclass
class Rule:
    if_: dict   # expression tree {op, ...}
    then: list[Consequent]
    name: str = ""
    weight: float = 1.0

    @classmethod
    def from_dict(cls, d: dict) -> "Rule":
        return cls(
            if_=d["if"],
            then=[Consequent.from_dict(c) for c in d["then"]],
            name=d.get("name", ""),
            weight=float(d.get("weight", 1.0)),
        )

    def to_dict(self) -> dict:
        out: dict[str, Any] = {}
        if self.name:
            out["name"] = self.name
        if self.weight != 1.0:
            out["weight"] = _num(self.weight)
        out["if"] = self.if_
        out["then"] = [c.to_dict() for c in self.then]
        return out


@dataclass
class Model:
    name: str
    inputs: list[FuzzyVar] = field(default_factory=list)
    outputs: list[FuzzyVar] = field(default_factory=list)
    rules: list[Rule] = field(default_factory=list)
    defuzz_method: str = "COG"

    @classmethod
    def from_dict(cls, d: dict) -> "Model":
        return cls(
            name=d["name"],
            defuzz_method=d.get("defuzz_method", "COG"),
            inputs=[FuzzyVar.from_dict(v) for v in d.get("inputs", [])],
            outputs=[FuzzyVar.from_dict(v) for v in d.get("outputs", [])],
            rules=[Rule.from_dict(r) for r in d.get("rules", [])],
        )

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "defuzz_method": self.defuzz_method,
            "inputs": [v.to_dict() for v in self.inputs],
            "outputs": [v.to_dict() for v in self.outputs],
            "rules": [r.to_dict() for r in self.rules],
        }

    @classmethod
    def from_json_file(cls, path: Path) -> "Model":
        return cls.from_dict(json.loads(Path(path).read_text()))

    def to_json_file(self, path: Path, *, indent: int = 2) -> None:
        Path(path).write_text(json.dumps(self.to_dict(), indent=indent))


def _num(x: float) -> float | int:
    """Render whole floats as ints in JSON output (matches FCL aesthetics)."""
    if x == int(x):
        return int(x)
    return x
