-- NovaUI 1.2.0 Example
-- Loader mode:
--   true  = fetch from GitHub with loadstring/game:HttpGet (executor-dependent).
--   false = normal Roblox Studio LocalScript + ModuleScript workflow.
-- Use the remote loader only when you trust the published source and have permission
-- to run scripts in the experience. Ordinary Studio LocalScripts do not support game:HttpGet.

local USE_GITHUB_LOADER = true
local NovaUI

if USE_GITHUB_LOADER then
    local sourceUrl = "https://raw.githubusercontent.com/CuteDevNya/NovaUI/main/NovaUI.lua"
    local source = game:HttpGet(sourceUrl)
    local compile, compileError = loadstring(source)
    assert(compile, "NovaUI compile failed: " .. tostring(compileError))
    NovaUI = compile()
else
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    NovaUI = require(ReplicatedStorage:WaitForChild("NovaUI"))
end

local Window = NovaUI:CreateWindow({
    Title = "NovaUI",
    Subtitle = "LIQUID GLASS INTERFACE",
    Width = 650,
    Height = 460,
    Theme = "Dark", -- Dark, Midnight, Ocean, Light
    AccentColor = Color3.fromRGB(104, 190, 255),
    ToggleKey = Enum.KeyCode.RightControl,
    ReducedMotion = false,
    Resizable = true,
    SnapToEdges = true,
    SnapDistance = 18,
    AnimationScale = 1,
    WindowTransparency = 0.14,
    CornerRadius = 16,

    -- Optional logo. Remove this field to show no logo.
    Logo = {
        Type = "Text",
        Text = "N",
    },

    -- Image logo alternative:
    -- Logo = { Type = "Image", Image = "rbxassetid://YOUR_IMAGE_ID" },
})

local savedConfig = nil

Window:RegisterCommand("Show success notification", function()
    Window:NotifySuccess("Settings saved successfully!", 3)
end, { "notification", "toast", "success" })
Window:RegisterCommand("Open appearance editor", function()
    Window:OpenThemeEditor()
end, { "theme", "colors", "customize" })

local Main = Window:CreateTab("Main")
Main:AddSection("INTERACTIONS")

Main:AddParagraph({
    Title = "Welcome to NovaUI",
    Content = "A reusable liquid-glass UI with springy controls, notifications, themes, tooltips, and two different minimize modes.",
})

Main:AddButton({
    Name = "Show success notification",
    Description = "A small glass toast slides in from the right.",
    Tooltip = "Notifications disappear automatically.",
    Callback = function()
        Window:Notify("Success", "Settings saved successfully!", 3)
    end,
})

Main:AddButton({
    Name = "Collapse to top bar",
    Tooltip = "The window keeps its width and shows only the title bar.",
    Callback = function()
        Window:CollapseBar()
    end,
})

Main:AddButton({
    Name = "Collapse to square icon",
    Tooltip = "The window folds into a small icon. Click the icon to fully expand it again.",
    Callback = function()
        Window:CollapseToSquare()
    end,
})

Main:AddToggle({
    Name = "Example feature",
    Default = false,
    Tooltip = "A toggle with a smooth animated switch.",
    Callback = function(enabled)
        print("Example feature:", enabled)
    end,
})

Main:AddSlider({
    Name = "Intensity",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Tooltip = "Drag the slider to change its value.",
    Callback = function(value)
        print("Intensity:", value)
    end,
})

Main:AddDropdown({
    Name = "Quality",
    Options = { "Low", "Medium", "High", "Ultra" },
    Default = "High",
    Tooltip = "The chevron is drawn from Frames instead of a special text glyph.",
    Callback = function(value)
        print("Quality:", value)
    end,
})

Main:AddMultiDropdown({
    Name = "Effects",
    Options = { "Bloom", "Motion blur", "Reflections", "Particles", "Shadows" },
    Default = { "Bloom", "Particles" },
    Tooltip = "Choose several options at once.",
    Callback = function(values)
        print("Enabled effects:", table.concat(values, ", "))
    end,
})

local progressDemo = Main:AddProgressBar({
    Name = "Demo progress",
    Min = 0,
    Max = 100,
    Default = 35,
})
Main:AddButton({
    Name = "Advance progress demo",
    Callback = function()
        progressDemo:Set(math.min(100, progressDemo:Get() + 15))
    end,
})

Main:AddRadioGroup({
    Name = "Performance preset",
    Options = { "Balanced", "Performance", "Quality" },
    Default = "Balanced",
    Callback = function(value)
        print("Performance preset:", value)
    end,
})

Main:AddButton({
    Name = "Dismissible notification",
    Callback = function()
        Window:Notify({
            Title = "Quick message",
            Text = "Close this toast with the small X.",
            Type = "Info",
            Duration = 8,
            ShowCloseButton = true,
        })
    end,
})

Main:AddTextBox({
    Name = "Nickname",
    Placeholder = "Enter a nickname...",
    Default = "Player",
    Tooltip = "The callback runs when the text box loses focus.",
    Callback = function(text, enterPressed)
        print("Nickname:", text, "Enter pressed:", enterPressed)
    end,
})

Main:AddKeybind({
    Name = "Example keybind",
    Default = Enum.KeyCode.F,
    Tooltip = "Click the key field and press any keyboard key to rebind it.",
    Callback = function(keyCode)
        print("Keybind action:", keyCode.Name)
    end,
})

local Appearance = Window:CreateTab("Appearance")
Appearance:AddSection("PERSONALIZATION")

Appearance:AddDropdown({
    Name = "Theme",
    Options = { "Dark", "Midnight", "Ocean", "Light" },
    Default = "Dark",
    Callback = function(themeName)
        Window:SetTheme(themeName)
    end,
})

Appearance:AddColorPicker({
    Name = "Accent color",
    Default = Color3.fromRGB(104, 190, 255),
    Tooltip = "Open the card and adjust the RGB channels.",
    Callback = function(color)
        Window:SetAccentColor(color)
    end,
})

Appearance:AddToggle({
    Name = "Reduce animations",
    Default = false,
    Callback = function(enabled)
        Window:SetReducedMotion(enabled)
    end,
})

Appearance:AddButton({
    Name = "Open live theme editor",
    Description = "Change theme, accent, glass and roundness.",
    Callback = function()
        Window:OpenThemeEditor()
    end,
})

Appearance:AddButton({
    Name = "Change logo to a star",
    Callback = function()
        Window:SetLogo("★", "Text")
        Window:SetTitle("NovaUI", "PERSONALIZED GLASS UI")
    end,
})

Appearance:AddButton({
    Name = "Remove logo",
    Callback = function()
        Window:SetLogo(nil)
        Window:SetTitle("NovaUI", "LIQUID GLASS INTERFACE")
    end,
})

local About = Window:CreateTab("About")
About:AddSection("NEW IN NOVAUI 1.2")
About:AddButton({
    Name = "Open command palette (Ctrl+K)",
    Description = "Search tabs and registered commands.",
    Callback = function()
        Window:OpenCommandPalette()
    end,
})

About:AddKeybindList({
    Name = "Live keybind list",
    Height = 130,
})

About:AddButton({
    Name = "Save UI config to memory",
    Callback = function()
        savedConfig = Window:GetConfig()
        Window:NotifySuccess("Configuration saved in memory.", 2)
    end,
})

About:AddButton({
    Name = "Restore saved UI config",
    Callback = function()
        if savedConfig then
            Window:ApplyConfig(savedConfig)
            Window:NotifySuccess("Configuration restored.", 2)
        else
            Window:NotifyWarning("Save a configuration first.", 2)
        end
    end,
})

About:AddButton({
    Name = "Try custom glass theme",
    Callback = function()
        Window:SetThemeConfig({
            Colors = {
                Background = Color3.fromRGB(16, 22, 36),
                Card = Color3.fromRGB(31, 43, 64),
            },
            AccentColor = Color3.fromRGB(125, 210, 255),
            WindowTransparency = 0.1,
            CornerRadius = 16,
            AnimationScale = 0.85,
        })
    end,
})

About:AddParagraph({
    Title = "Window controls",
    Content = "The top bar has separate buttons for collapsing to a title bar, collapsing to a square icon, and closing. Clicking the square icon always restores the full window, even if it was previously collapsed to a bar.",
})

About:AddLabel({
    Text = "Press RightControl to hide or show the window.",
    Height = 42,
})

About:AddDivider()
About:AddLabel("Ctrl+K opens the command palette. Drag the window to an edge to snap it; drag the lower-right grip to resize.")
About:AddLabel("Studio mode uses a ModuleScript. GitHub loadstring mode requires an executor that supports game:HttpGet/loadstring.")

Window:Notify({
    Title = "NovaUI ready",
    Text = "Your liquid-glass interface is ready.",
    Type = "Info",
    Duration = 3.5,
})