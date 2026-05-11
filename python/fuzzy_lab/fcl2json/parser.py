"""Parse FCL source text into a Model dataclass.

Reads grammar.lark sibling and walks the resulting tree with a Lark
Transformer. Point-list TERMs are normalised to (a, b, c, d) by the
canonical-shape recogniser in _points_to_abcd. Non-trapezoidal MF
types (gbell, gauss, sigm) are reported as NotImplementedError —
the engine schema is (a, b, c, d) only.
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

from lark import Lark, Transformer, Token
from lark.exceptions import VisitError

from fuzzy_lab.schema import Consequent, FuzzyVar, Model, Rule, Term

GRAMMAR = (Path(__file__).parent / "grammar.lark").read_text()
_PARSER = Lark(GRAMMAR, start="function_block", parser="earley")


def parse_fcl(text: str) -> Model:
    tree = _PARSER.parse(text)
    try:
        return _ToModel().transform(tree)
    except VisitError as exc:
        # Lark wraps transformer exceptions in VisitError; unwrap so callers
        # see the original NotImplementedError / ValueError directly.
        raise exc.orig_exc from None


def _num(token: Token) -> float:
    return float(token)


def _points_to_abcd(points: list[tuple[float, float]]) -> tuple[float, float, float, float]:
    """Recognise standard membership shapes.

    Trapezoid (4 pts): (a,0)(b,1)(c,1)(d,0).
    Triangle (3 pts): (a,0)(b,1)(d,0) → (a, b, b, d).
    Left-plateau (3 pts): (a,1)(b,1)(c,0) → (a, a, b, c)  [e.g. rancid in tipper].
    Right-shoulder (2 pts): (a,0)(b,1) → (a, b, b, b).
    Left-shoulder (2 pts):  (a,1)(b,0) → (a, a, a, b).
    """
    pts = sorted(points, key=lambda p: p[0])
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]

    if len(pts) == 4 and ys == [0, 1, 1, 0]:
        return (xs[0], xs[1], xs[2], xs[3])
    if len(pts) == 3 and ys == [0, 1, 0]:
        return (xs[0], xs[1], xs[1], xs[2])
    if len(pts) == 3 and ys == [1, 1, 0]:
        # Left-plateau falling shoulder: full membership from a to b, then falls to 0 at c.
        return (xs[0], xs[0], xs[1], xs[2])
    if len(pts) == 3 and ys == [0, 1, 1]:
        # Right-plateau rising shoulder: rises from a to b, then full membership to c.
        return (xs[0], xs[1], xs[2], xs[2])
    if len(pts) == 2:
        if ys == [0, 1]:
            return (xs[0], xs[1], xs[1], xs[1])
        if ys == [1, 0]:
            return (xs[0], xs[0], xs[0], xs[1])

    raise NotImplementedError(
        f"fcl2json: point-list with shape {pts} cannot be represented as a "
        f"(a, b, c, d) trapezoid; only standard 2/3/4-point trapezoid/triangle/"
        f"shoulder shapes are supported in v1."
    )


class _ToModel(Transformer):
    def NAME(self, t: Token) -> str:
        return str(t)

    def RULE_ID(self, t: Token) -> str:
        return str(t)

    def SIGNED_NUMBER(self, t: Token) -> float:
        return _num(t)

    # Term bodies.
    def term_trape(self, items):
        a, b, c, d = items
        return ("abcd", (a, b, c, d))

    def term_trian(self, items):
        a, b, c = items
        return ("abcd", (a, b, b, c))

    def term_singleton(self, items):
        n, = items
        return ("abcd", (n, n, n, n))

    def point(self, items):
        x, y = items
        return (x, y)

    def term_points(self, items):
        return ("abcd", _points_to_abcd(list(items)))

    def term_body(self, items):
        return items[0]

    def term_decl(self, items):
        name = items[0]
        _, abcd = items[1]
        return Term(name=name, a=abcd[0], b=abcd[1], c=abcd[2], d=abcd[3])

    # Unsupported membership function types.
    def term_gbell(self, items):
        raise NotImplementedError(
            "fcl2json: 'gbell' membership functions are not supported in v1; "
            "only trapezoid/triangle/point-list/singleton are. Affected: this term."
        )

    def term_gauss(self, items):
        raise NotImplementedError(
            "fcl2json: 'gauss' membership functions are not supported in v1; "
            "only trapezoid/triangle/point-list/singleton are. Affected: this term."
        )

    def term_sigm(self, items):
        raise NotImplementedError(
            "fcl2json: 'sigm' membership functions are not supported in v1; "
            "only trapezoid/triangle/point-list/singleton are. Affected: this term."
        )

    # Variable declarations.
    def var_decl(self, items):
        return items[0]

    def var_input(self, items):
        return ("inputs", list(items))

    def var_output(self, items):
        return ("outputs", list(items))

    # Accept-and-discard metadata.
    def range_decl(self, _):
        return None

    def accu_decl(self, _):
        return None

    # Fuzzify / Defuzzify.
    def fuzzify(self, items):
        name = items[0]
        terms = [x for x in items[1:] if isinstance(x, Term)]
        return ("fuzzify", FuzzyVar(name=name, terms=terms))

    def defuzzify(self, items):
        name = items[0]
        terms = [x for x in items[1:] if isinstance(x, Term)]
        method = "COG"
        for x in items[1:]:
            if isinstance(x, dict) and "method" in x:
                method = x["method"]
        return ("defuzzify", FuzzyVar(name=name, terms=terms), method)

    def method_decl(self, items):
        return {"method": items[0]}

    def default_decl(self, items):
        return None

    def defuzzify_extra(self, items):
        return items[0]

    # Rules.
    def is_expr(self, items):
        var, term = items
        return {"op": "is", "var": var, "term": term}

    def is_not_expr(self, items):
        var, term = items
        return {"op": "not", "arg": {"op": "is", "var": var, "term": term}}

    def not_expr(self, items):
        inner, = items
        return {"op": "not", "arg": inner}

    def and_expr(self, items):
        return _fold("and", list(items))

    def or_expr(self, items):
        return _fold("or", list(items))

    def consequent(self, items):
        var, term = items
        return Consequent(var=var, term=term)

    def consequent_list(self, items):
        return list(items)

    def rule(self, items):
        if len(items) == 4:
            name, expr, then, weight = items
        else:
            name, expr, then = items
            weight = 1.0
        return Rule(if_=expr, then=list(then), name=str(name), weight=float(weight))

    def op_decl(self, items):
        return None

    def ruleblock_extra(self, items):
        return items[0]

    def ruleblock(self, items):
        return [r for r in items[1:] if isinstance(r, Rule)]

    def function_block(self, items):
        name = items[0]
        inputs: list[FuzzyVar] = []
        outputs: list[FuzzyVar] = []
        rules: list[Rule] = []
        defuzz_method = "COG"
        for child in items[1:]:
            if isinstance(child, tuple):
                kind = child[0]
                if kind == "fuzzify":
                    inputs.append(child[1])
                elif kind == "defuzzify":
                    outputs.append(child[1])
                    defuzz_method = child[2]
            elif isinstance(child, list) and (not child or isinstance(child[0], Rule)):
                rules.extend(child)

        for idx, r in enumerate(rules, start=1):
            if not r.name or r.name.isdigit():
                r.name = f"R{idx}: {_expr_str(r.if_)} → {_then_str(r.then)}"

        if defuzz_method != "COG":
            print(f"warning: defuzz method '{defuzz_method}' is recorded but only COG is honored",
                  file=sys.stderr)

        return Model(name=name, inputs=inputs, outputs=outputs,
                     rules=rules, defuzz_method=defuzz_method)


def _fold(op: str, args: list[Any]) -> Any:
    if len(args) == 1:
        return args[0]
    left = args[0]
    for right in args[1:]:
        left = {"op": op, "args": [left, right]}
    return left


def _expr_str(expr: Any) -> str:
    if not isinstance(expr, dict):
        return str(expr)
    op = expr.get("op")
    if op == "is":
        return f"{expr['var']} is {expr['term']}"
    if op == "not":
        return f"NOT {_expr_str(expr['arg'])}"
    if op in ("and", "or"):
        return f" {op.upper()} ".join(_expr_str(a) for a in expr["args"])
    return str(expr)


def _then_str(consequents: list[Consequent]) -> str:
    return ", ".join(f"{c.var} is {c.term}" for c in consequents)
