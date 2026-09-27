# Changelog

## 0.1.0

* Initial release of `agent_thinking_orbs` for Flutter.
* Complete geometry engine ported with 100% mathematical parity against the React/TypeScript specification.
* 9 distinct cognitive states supported:
  - `working` (Globe)
  - `searching` (Wave)
  - `solving` (Rubik)
  - `listening` (Morph)
  - `connecting` (Web)
  - `weaving` (Braid)
  - `composing` (Ribbon)
  - `breathing` (Ring)
  - `shaping` (Orbits)
* Native support for `OrbSize.large` (64px) and `OrbSize.small` (20px).
* Automatic dark/light theme detection with manual override (`OrbTheme.dark`, `OrbTheme.light`, `OrbTheme.auto`).
* Synchronized animation clocking across multiple orbs via `OrbClock`.
* Accessibility support with `Semantics` and `MediaQuery.disableAnimations` reduced motion handling.
* Golden test suite validating all 72 test vectors from `spec/orbs-golden.json` within `< 1e-4` precision.
