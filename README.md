# NovaUI 1.2.1

A reusable liquid-glass GUI library for Roblox Studio projects, with springy controls, in-window search, a normal Appearance tab, shared control groups and responsive window controls.

## Files

- **[NovaUI.lua](./NovaUI.lua)** — current library source.
- **[NovaUI_Example.lua](./NovaUI_Example.lua)** — example with GitHub Raw loader option and the standard Studio fallback.
- **[NovaUI.txt](./NovaUI.txt)** — copy-friendly source mirror.
- **[NovaUI_README.txt](./NovaUI_README.txt)** — extended API guide.

## Loading

### Roblox Studio

Create a ModuleScript named `NovaUI` in `ReplicatedStorage`, paste in `NovaUI.lua`, and use:

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NovaUI = require(ReplicatedStorage:WaitForChild("NovaUI"))

### GitHub Raw loader (executor-dependent)

The example includes:

    local NovaUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/CuteDevNya/NovaUI/main/NovaUI.lua"
    ))()

This does not work in an ordinary Roblox Studio LocalScript. Only run source you trust and only test in experiences where you have permission.

## Quick start

    local Window = NovaUI:CreateWindow({
        Title = "NovaUI",
        Theme = "Dark",
        AccentColor = Color3.fromRGB(104, 190, 255),
    })

    local Main = Window:CreateTab("Main", {
        Icon = { Type = "Text", Text = "M" },
    })

    local Group = Main:AddGroup({
        Name = "PROGRESS",
        Icon = { Type = "Text", Text = "P" },
    })

    local progress = Group:AddProgressBar({
        Name = "Loading",
        Default = 25,
        Min = 0,
        Max = 100,
    })

    Group:AddButton({
        Name = "Advance",
        Icon = { Type = "Text", Text = "+" },
        Callback = function()
            progress:Set(math.min(100, progress:Get() + 10))
        end,
    })

    local Appearance = Window:CreateThemeEditorTab("Appearance", {
        Icon = { Type = "Text", Text = "A" },
    })
    local Search = Window:CreateSearchTab("Search", {
        Icon = { Type = "Text", Text = "S" },
    })

Search results are inside the Search tab and include tabs, registered commands and registered settings. Ctrl+K switches to that tab and focuses the search field; it does not open a separate command-palette window.

## What's new in 1.2.1

- The floating Command Palette and floating Theme Editor have been removed.
- `Window:CreateSearchTab("Search", options)` adds a regular in-window search tab for tabs, commands and settings.
- `Window:CreateThemeEditorTab("Appearance", options)` adds theme presets, accent, glass transparency, corner radius, animation scale and reduced-motion controls as a normal tab.
- Optional icons can be added to tabs, sections, labels, paragraphs and setting controls.
- Icon configuration supports text/symbols and images; icons have no background unless `BackgroundColor` or `Background = true` is supplied.
- `Tab:AddGroup({Name = "..."})` lets controls share one rounded glass background. Buttons inside groups use a smaller translucent white hover highlight.
- Multi-select dropdown scrolling now sizes its canvas from the actual option layout; long option lists can be scrolled.
- Text inputs have left/right text padding.
- Notifications remain toast overlays, with stacking, helper methods and optional `ShowCloseButton = true`.
- The library from 1.2.0 retains its configuration API, theme customization, additional controls, window snapping and resizing.

## Icons

Text/letter icon with no background:

    Icon = { Type = "Text", Text = "M" }

Image icon with no background:

    Icon = { Type = "Image", Image = "rbxassetid://YOUR_IMAGE_ID" }

Optional background:

    Icon = {
        Type = "Text",
        Text = "!",
        BackgroundColor = Color3.fromRGB(100, 180, 255),
        BackgroundTransparency = 0.15,
    }

Use this `Icon` option with `Window:CreateTab(...)`, `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiDropdown`, `AddTextBox`, `AddKeybind`, `AddColorPicker`, `AddProgressBar`, `AddRadioGroup`, `AddKeybindList`, `AddLabel`, `AddParagraph`, and `AddSection`.

## API overview

- **Tabs:** `Window:CreateTab(name, options)`
- **Search tab:** `Window:CreateSearchTab(name, options)`
- **Appearance tab:** `Window:CreateThemeEditorTab(name, options)`
- **Groups:** `local group = Tab:AddGroup({ Name = "Section" })`, then call controls on `group`
- **Search registration:** `Window:RegisterCommand(name, callback, keywords)`
- **Theme config:** `Window:SetThemeConfig(config)`, `Window:GetConfig()`, `Window:ApplyConfig(config)`
- **Notifications:** `NotifySuccess`, `NotifyWarning`, `NotifyError`, `NotifyInfo`, and `Window:Notify(config)`
- **Controls:** `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiDropdown`, `AddTextBox`, `AddKeybind`, `AddColorPicker`, `AddProgressBar`, `AddRadioGroup`, `AddKeybindList`, `AddLabel`, `AddParagraph`, `AddSection`, `AddDivider`
- **Window controls:** collapse to bar/icon, restore, drag/snap, resize, visibility shortcut, reduced motion, close/destroy.

Tooltips are opt-in. Add `Tooltip = "..." ` only to controls that need them.

The liquid-glass appearance is simulated with Roblox GUI transparency, gradients, strokes and highlights. Standard ScreenGui elements do not provide true per-panel blur of the 3D scene behind them.
