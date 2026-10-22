# NovaUI

A reusable liquid-glass GUI library for Roblox Studio projects, with soft spring animations and an optional, customizable logo.

## Files

- **NovaUI.lua** — the library. Add it as a ModuleScript named NovaUI in ReplicatedStorage.
- **NovaUI_Example.lua** — example LocalScript for StarterPlayer > StarterPlayerScripts.
- **NovaUI.txt** — copy-friendly text copy of the library.
- **NovaUI_README.txt** — fuller API and installation notes.

## Quick start

1. Create a ModuleScript named NovaUI in ReplicatedStorage and paste in NovaUI.lua.
2. Create a LocalScript in StarterPlayer > StarterPlayerScripts.
3. Copy the example script into that LocalScript, then press Play.

Example usage:

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NovaUI = require(ReplicatedStorage:WaitForChild("NovaUI"))

    local Window = NovaUI:CreateWindow({
        Title = "My GUI",
        Theme = "Dark",
        AccentColor = Color3.fromRGB(104, 190, 255),
        -- Optional: Logo = { Type = "Text", Text = "★" },
    })

    local Main = Window:CreateTab("Main")
    Main:AddButton({
        Name = "Notify",
        Tooltip = "This tooltip appears because it is explicitly configured.",
        Callback = function()
            Window:Notify({
                Title = "Saved",
                Text = "Your changes have been saved.",
                Type = "Success",
                Duration = 3.5,
            })
        end,
    })

## Features

- Liquid-glass-inspired panels with transparency, gradients, outlines and highlights.
- Animated tabs, buttons, toggles, sliders and dropdowns.
- Text boxes, keybinds, color pickers, labels, paragraphs and sections.
- Notifications with rounded, inset progress bars and accent indicators.
- Tooltips are opt-in: set Tooltip = "..." on a control to show one. The window close/minimize controls have no default tooltips.
- Optional text or image logo; the example includes a star-logo action.
- Dark, Midnight, Ocean and Light themes; custom accent color and reduced-motion option.
- Separate collapse-to-top-bar and collapse-to-square modes.

The glass appearance is simulated with Roblox GUI transparency and styling. Standard ScreenGui elements do not provide a true per-panel blur of the 3D scene behind them.

NovaUI is intended for Roblox Studio experiences you own or are authorized to edit. A Pastebin URL is not a valid direct input to ordinary Roblox require().

## Version 1.1.3

- The compact icon now uses the window's top-left as its anchor point. Collapsing or restoring no longer pulls the window toward its center.
- Window dragging is clamped to the active viewport, including while in bar or square mode. Dragging the icon moves the future expanded window's origin.
- Width and height are recalculated when the viewport changes, and the current camera is rebound if Roblox replaces it.
- Collapse/restore resizing uses non-overshooting easing to avoid briefly crossing screen edges.
- Sidebar/content spacing adapts more aggressively to narrow screens.
