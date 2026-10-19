# Changelog

All notable changes to this project will be documented in this file.

## [0.1.1] - TBD

### Added

- Add a color scheme demo to demonstrate key event recognition and slideshow control.
- Add `KeyEvent.match()` to match recent events against a sequence of key event specifications.

### Changed

- Move logging to optional `logger.nvim`; logging is disabled by default.

### Fixed

- Count `ng_repeat` when a hold interval follows a repeat interval.

### Refactoring

- Rename and reorganize internal functions for clarity and consistency.

## [0.1.0] - 2026-09-25

Initial release of `keyevent.nvim`.

`keyevent.nvim` provides time-based key event detection for Neovim.

It detects keyboard input and classifies consecutive key presses as clicks, taps, holds, and repeats. The generated events include timing, key sequence, modifier, and repeat information that can be used by other plugins.

### Features

- Detect clicks, taps, hold starts, and key repeats
- Measure intervals between key events
- Track tap, hold, and repeat counts
- Track key sequences and modifier keys
- Use key event information from `on_event()`
- Use the same event information from expression mappings with `keymap_event()`
- Provide key repeat timing diagnosis
- Automatically obtain keyboard repeat timing from supported operating systems
- Fall back to statistically estimated timing when OS information is unavailable

### Examples

Two small examples are included:

- `on_event` — use key events to implement `kj` as an Insert mode escape sequence
- `keymap_event` — use timing information in an expression mapping to show search history when `n` is held

### Related

`keyevent.nvim` was originally developed as part of [rush.nvim](https://github.com/kibi2/rush.nvim).

It is now provided as a separate plugin so that other plugins can use the same time-based key event detection.

### Requirements

- Neovim 0.10+
- A system with key repeat support

### License

MIT
