# Omarchy Quattro source

The shell, plugins, UI components, supporting commands, menu definitions, and
icon font in this directory are copied from `basecamp/omarchy` v4.0.0 at commit
`f0020448ca87329199de7cb12f2015ebc4a3e5e7`.

Upstream repository: <https://github.com/basecamp/omarchy>

Local changes are limited to profile isolation paths, the enabled bar layout,
the One Dark Pro theme, and two runtime-compatibility fixes:

- a menu result-process guard required by `noctalia-qs` 0.0.12. That runtime
  emits an initial `Process.onExited` event without a submitted command; the
  guard prevents it from closing the first menu opening;
- a workspace focus dispatcher. Upstream uses `hl.dsp.focus({ workspace = "N" })`,
  a dispatcher of the basecamp Hyprland fork that stock Hyprland rejects with
  `Invalid dispatcher`; the widget now uses the standard `workspace N` dispatch.

The upstream MIT license is preserved in `LICENSE`.
