# NovaUI 1.2.0

A reusable liquid-glass GUI library for Roblox Studio projects, with springy controls, themes, notifications, command search, and responsive window controls.

## Files

- **NovaUI.lua** — the library source.
- **NovaUI_Example.lua** — a complete feature showcase, including a GitHub loadstring(game:HttpGet(...)) loader option.
- **NovaUI.txt** — copy-friendly mirror of the library.
- **NovaUI_README.txt** — extended API guide.

## Loading the library

### Roblox Studio

Create a ModuleScript named NovaUI in ReplicatedStorage, paste in NovaUI.lua, and use:

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NovaUI = require(ReplicatedStorage:WaitForChild("NovaUI"))

### GitHub Raw loader

The example includes this executor-dependent option:

    local NovaUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/CuteDevNya/NovaUI/main/NovaUI.lua"
    ))()

This is not supported by an ordinary Roblox Studio LocalScript. Only run remote code you trust and only in experiences where you have permission to test it.

## Quick example

    local Window = NovaUI:CreateWindow({
        Title = "NovaUI",
        Theme = "Dark",
        AccentColor = Color3.fromRGB(104, 190, 255),
        Resizable = true,
        SnapToEdges = true,
    })

    local Main = Window:CreateTab("Main")
    Main:AddButton({
        Name = "Notify",
        Callback = function()
            Window:NotifySuccess("Saved!", 3)
        end,
    })

    Window:RegisterCommand("Open appearance editor", function()
        Window:OpenThemeEditor()
    end, { "theme", "colors" })

Press Ctrl+K to open the Command Palette.

## What's new in 1.2.0

- Command Palette with search for registered commands and tabs; Ctrl+K shortcut.
- Live Theme Editor for preset themes, accent colors, glass transparency, corner radius, and reduced motion.
- Custom theme configuration through Window:SetThemeConfig({...}).
- Notification convenience methods: NotifySuccess, NotifyWarning, NotifyError, and NotifyInfo; optional ShowCloseButton = true. Notifications stack and the oldest is removed when the maximum stack is exceeded.
- New controls: AddMultiDropdown, AddProgressBar, AddRadioGroup, and AddKeybindList.
- AddKeybindList updates when registered keybinds are changed.
- Window snapping and bottom-right resize grip. Set Resizable = false or SnapToEdges = false to disable them.
- Window:GetConfig() and Window:ApplyConfig(config) capture and restore current theme plus registered control states in memory.
- Animation speed multiplier via AnimationScale / SetThemeConfig({ AnimationScale = 0.85 }).
- Existing GUI features and APIs from 1.1.x remain available.

## Theme and config API

- Window:SetTheme("Dark") — Dark, Midnight, Ocean, or Light.
- Window:SetAccentColor(Color3.fromRGB(...))
- Window:SetThemeConfig({ Theme = "Ocean", AccentColor = Color3.fromRGB(100, 200, 255), WindowTransparency = 0.12, CornerRadius = 16, AnimationScale = 0.9, Colors = { Background = Color3.fromRGB(...) } })
- Window:GetConfig() returns a Lua table with the theme and registered control values.
- Window:ApplyConfig(savedConfig) restores that table. In the example, the save is intentionally kept in memory; persistence across sessions requires a suitable storage system.

## Controls

Existing controls: AddSection, AddLabel, AddParagraph, AddDivider, AddButton, AddToggle, AddSlider, AddDropdown, AddTextBox, AddKeybind, and AddColorPicker.

New controls:

    Tab:AddMultiDropdown({ Name = "Effects", Options = { "Bloom", "Shadows" }, Default = { "Bloom" }, Callback = function(values) end })

    Tab:AddProgressBar({ Name = "Loading", Min = 0, Max = 100, Default = 20 })
    -- Returns an object with Get() and Set(value).

    Tab:AddRadioGroup({ Name = "Quality", Options = { "Low", "High" }, Default = "High", Callback = function(value) end })

    Tab:AddKeybindList({ Name = "Keybinds", Height = 150 })

Tooltips remain opt-in: set Tooltip = "..." on a control to show one.

## Window API

- Window:OpenCommandPalette(), Window:RegisterCommand(name, callback, keywords)
- Window:OpenThemeEditor(), Window:SetThemeConfig(config)
- Window:NotifySuccess(message, duration), NotifyWarning, NotifyError, NotifyInfo
- Window:GetConfig(), Window:ApplyConfig(config)
- Window:CollapseBar(), Window:CollapseToSquare(), Window:Expand(), Window:SetVisible(bool)
- Window:SetLogo(value, "Text"), Window:SetLogo("rbxassetid://...", "Image")
- Window:Close(), Window:Destroy()

The glass appearance is simulated with Roblox GUI transparency, gradients, strokes and highlights. Standard ScreenGui elements do not provide a true per-panel blur of the 3D scene.
