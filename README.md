# Piecius RPChat

RP chat commands with 3D hint bubbles, color-coded message types, and admin global actions.

## Features

- **RP Commands** — `/me`, `/do`, `/try`, `/ooc`, `/med`, `/twi`, `/dw`, `/globaldo`
- **3D Hint Bubbles** — Floating text bubbles above player heads
- **Color-Coded Types** — Each command type has unique colors (me=purple, do=green, try=orange, med=pink)
- **Range-Based** — Configurable message range per command type
- **Global Do** — `/globaldo` with admin approval queue
- **Chat Suggestions** — Auto-suggestions for all RP commands

## Dependencies

- [chat](https://docs.fivem.net/docs/scripting-reference/resource-manifest/resource-manifest/#dependency)
- **ESX** or **QBCore** (auto-detected)

## Installation

1. Copy `Piecius_rpchat` to your server's `resources` folder
2. Add `ensure Piecius_rpchat` to your `server.cfg`
3. Configure ranges and settings in `config.lua`

## Configuration

Edit `config.lua` to customize:

- Chat ranges per command type (`/me`, `/do`, `/try`, `/ooc`, `/med`, `/twi`, `/dw`)
- Global do settings

## Commands

| Command | Description | Range |
|---------|-------------|-------|
| `/me [text]` | Action text (purple) | Configurable |
| `/do [text]` | Environment description (green) | Configurable |
| `/try [text]` | Attempt action with random success/fail (orange) | Configurable |
| `/ooc [text]` | Out of character chat | Configurable |
| `/med [text]` | Medical action (pink, job-restricted) | Configurable |
| `/twi [text]` | Twitter message | Global |
| `/dw [text]` | Dark web message | Global |
| `/globaldo [text]` | Global do (requires admin approval) | Global |

## Framework Support

Supports both **ESX** and **QBCore** via auto-detection bridge.
