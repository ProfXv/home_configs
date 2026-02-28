---
name: nixdoc
description: Query and explore NixOS and home-manager configuration options. Use when the user wants to search for configuration options, view option details (type, default, description, examples), or browse option hierarchies. Supports both system-level (nixos-option) and user-level (home-manager option) configurations.
---

# NixDoc - NixOS Configuration Documentation Explorer

Query NixOS and home-manager configuration options with hierarchical browsing and search capabilities.

## Quick Reference

### Query specific option
```bash
nixos-option services.pipewire.enable
home-manager option programs.git.enable
```

### Browse option hierarchy
```bash
nixos-option services              # List all services options
home-manager option programs       # List all programs options
```

### Search for options
Use `man configuration.nix` or `man home-configuration.nix` with grep for keyword search.

## Usage Patterns

### 1. View Option Details

When user asks about a specific option:
- Use `nixos-option <option.path>` for system options
- Use `home-manager option <option.path>` for home-manager options
- Output includes: current value, default, type, description, example, declaration location

### 2. Browse Option Hierarchy

When user wants to explore a module:
- Query parent path to list children (e.g., `nixos-option services`)
- Present results in categorized format
- For large lists, suggest narrowing down the scope

### 3. Search for Options

When user searches by keyword:
1. Use `man configuration.nix` for NixOS options
2. Use `man home-configuration.nix` for home-manager options
3. Pipe through grep to find matching options
4. Extract option names and brief descriptions
5. Present as clickable list with option paths

## Output Format

### For single option query:
Present the complete information clearly:
```
Option: services.pipewire.enable
Value: true
Default: false
Type: boolean
Description: Whether to enable PipeWire service.
Example: true
```

### For hierarchy browsing:
Group and present options categorically:
```
programs (available options):
  - firefox
  - git
  - bash
  - zsh
  ...
```

### For search results:
List matching options with brief context:
```
Found 5 options matching 'bluetooth':
1. hardware.bluetooth.enable
2. services.blueman.enable
3. programs.bluetuith.enable
...
```

## Helper Scripts

The skill includes `scripts/search_options.sh` for efficient option searching.

## Notes

- Both commands require proper NIX_PATH configuration
- System options require NixOS (nixos-option)
- User options require home-manager
- Option paths use dot notation (e.g., `services.ssh.enable`)
- Use tab completion in shell for option path discovery
