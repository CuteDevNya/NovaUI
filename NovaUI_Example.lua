-- NovaUI 1.2.1 Example
-- Loader mode:
--   true  = fetch from GitHub Raw using loadstring/game:HttpGet (executor-dependent).
--   false = normal Roblox Studio LocalScript + ModuleScript workflow.
-- A normal Roblox Studio LocalScript does not support game:HttpGet/loadstring.

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
    Theme = "Dark",
    AccentColor = Color3.fromRGB(104, 190, 255),
    ToggleKey = Enum.KeyCode.RightControl,
    ReducedMotion = false,
    Resizable = true,
    SnapToEdges = true,
    SnapDistance = 18,
    AnimationScale = 1,
    WindowTransparency = 0.14,
    CornerRadius = 16,

    -- Text, letter or image. Remove this field for the no-logo appearance.
    Logo = { Type = "Text", Text = "N" },
    -- Image logo alternative:
    -- Logo = { Type = "Image", Image = "rbxassetid://YOUR_IMAGE_ID" },
})

local savedConfig = nil

Window:RegisterCommand("Show success notification", function()
    Window:NotifySuccess("Settings saved successfully!", 3)
end, { "notification", "toast", "success" })

Window:RegisterCommand("Show warning notification", function()
    Window:NotifyWarning("This is a warning.", 3)
end, { "notification", "toast", "warning" })

local Main = Window:CreateTab("Main", {
    Icon = { Type = "Text", Text = "M" },
})
Main:AddSection({
    Name = "INTERACTIONS",
    Icon = { Type = "Text", Text = "I" },
})

Main:AddParagraph({
    Title = "Welcome to NovaUI",
    Content = "Liquid-glass UI with responsive layout, grouped controls, optional icons, inline search and appearance settings.",
    Icon = { Type = "Text", Text = "N" },
})

Main:AddButton({
    Name = "Show success notification",
    Description = "A small glass toast slides in from the right.",
    Icon = { Type = "Text", Text = "!" },
    Tooltip = "Notifications disappear automatically.",
    Callback = function()
        Window:NotifySuccess("Settings saved successfully!", 3)
    end,
})

Main:AddButton({
    Name = "Collapse to top bar",
    Icon = { Type = "Text", Text = "-" },
    Tooltip = "The window keeps its width and shows only the title bar.",
    Callback = function()
        Window:CollapseBar()
    end,
})

Main:AddButton({
    Name = "Collapse to square icon",
    Icon = { Type = "Text", Text = "O" },
    Tooltip = "The window folds into a small icon. Click the icon to expand it.",
    Callback = function()
        Window:CollapseToSquare()
    end,
})

Main:AddToggle({
    Name = "Example feature",
    Icon = { Type = "Text", Text = "F" },
    Default = false,
    Tooltip = "A toggle with a smooth animated switch.",
    Callback = function(enabled)
        print("Example feature:", enabled)
    end,
})

Main:AddSlider({
    Name = "Intensity",
    Icon = { Type = "Text", Text = "I" },
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
    Icon = { Type = "Text", Text = "Q" },
    Options = { "Low", "Medium", "High", "Ultra" },
    Default = "High",
    Tooltip = "The chevron is drawn from rounded Frames.",
    Callback = function(value)
        print("Quality:", value)
    end,
})

Main:AddMultiDropdown({
    Name = "Effects",
    Icon = { Type = "Text", Text = "E" },
    Options = {
        "Bloom", "Motion blur", "Reflections", "Particles", "Shadows",
        "Ambient occlusion", "Depth of field", "Color correction",
        "Sun rays", "Lens flare", "Volumetric lighting", "Dynamic fog",
    },
    Default = { "Bloom", "Particles" },
    Tooltip = "Choose several options. Scroll within the dropdown to see the full list.",
    Callback = function(values)
        print("Enabled effects:", table.concat(values, ", "))
    end,
})

-- The progress display and its button share one card background.
local ProgressGroup = Main:AddGroup({
    Name = "PROGRESS DEMO",
    Icon = { Type = "Text", Text = "P" },
    BackgroundTransparency = 0.22,
})

local progressDemo = ProgressGroup:AddProgressBar({
    Name = "Demo progress",
    Icon = { Type = "Text", Text = "%" },
    Min = 0,
    Max = 100,
    Default = 35,
})

ProgressGroup:AddButton({
    Name = "Advance progress demo",
    Icon = { Type = "Text", Text = "+" },
    Description = "Hover to see the soft highlight inside the shared card.",
    Callback = function()
        progressDemo:Set(math.min(100, progressDemo:Get() + 15))
    end,
})

Main:AddRadioGroup({
    Name = "Performance preset",
    Icon = { Type = "Text", Text = "P" },
    Options = { "Balanced", "Performance", "Quality" },
    Default = "Balanced",
    Callback = function(value)
        print("Performance preset:", value)
    end,
})

Main:AddButton({
    Name = "Dismissible notification",
    Icon = { Type = "Text", Text = "B" },
    Callback = function()
        Window:Notify({
            Title = "Quick message",
            Text = "Close this toast with its small X.",
            Type = "Info",
            Duration = 8,
            ShowCloseButton = true,
        })
    end,
})

Main:AddTextBox({
    Name = "Nickname",
    Icon = { Type = "Text", Text = "N" },
    Placeholder = "Enter a nickname...",
    Default = "Player",
    Tooltip = "The callback runs when the text box loses focus.",
    Callback = function(text, enterPressed)
        print("Nickname:", text, "Enter pressed:", enterPressed)
    end,
})

Main:AddKeybind({
    Name = "Example keybind",
    Icon = { Type = "Text", Text = "K" },
    Default = Enum.KeyCode.F,
    Tooltip = "Click the key field and press a keyboard key to rebind it.",
    Callback = function(keyCode)
        print("Keybind action:", keyCode.Name)
    end,
})

-- Appearance is now a normal tab inside the window, not a floating editor.
local Appearance = Window:CreateThemeEditorTab("Appearance", {
    Icon = { Type = "Text", Text = "A" },
})

Appearance:AddButton({
    Name = "Change logo to a star",
    Icon = { Type = "Text", Text = "*" },
    Callback = function()
        Window:SetLogo("★", "Text")
        Window:SetTitle("NovaUI", "PERSONALIZED GLASS UI")
    end,
})

Appearance:AddButton({
    Name = "Remove logo",
    Icon = { Type = "Text", Text = "X" },
    Callback = function()
        Window:SetLogo(nil)
        Window:SetTitle("NovaUI", "LIQUID GLASS INTERFACE")
    end,
})

Appearance:AddButton({
    Name = "Use custom glass preset",
    Icon = { Type = "Text", Text = "C" },
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

local About = Window:CreateTab("About", {
    Icon = { Type = "Text", Text = "i" },
})
About:AddSection({ Name = "CONFIG & CONTROLS", Icon = { Type = "Text", Text = "C" } })

About:AddButton({
    Name = "Open in-window search",
    Icon = { Type = "Text", Text = "S" },
    Description = "Search tabs, commands and settings without opening another window.",
    Callback = function()
        Window:OpenSearchTab()
    end,
})

About:AddKeybindList({
    Name = "Live keybind list",
    Icon = { Type = "Text", Text = "K" },
    Height = 130,
})

About:AddButton({
    Name = "Save UI config to memory",
    Icon = { Type = "Text", Text = "S" },
    Callback = function()
        savedConfig = Window:GetConfig()
        Window:NotifySuccess("Configuration saved in memory.", 2)
    end,
})

About:AddButton({
    Name = "Restore saved UI config",
    Icon = { Type = "Text", Text = "R" },
    Callback = function()
        if savedConfig then
            Window:ApplyConfig(savedConfig)
            Window:NotifySuccess("Configuration restored.", 2)
        else
            Window:NotifyWarning("Save a configuration first.", 2)
        end
    end,
})

About:AddParagraph({
    Title = "Window controls",
    Content = "Collapse to the top bar or square icon. Drag windows to screen edges to snap them, or resize using the lower-right grip. Ctrl+K focuses the Search tab.",
    Icon = { Type = "Text", Text = "i" },
})

About:AddLabel({
    Text = "Studio mode uses a ModuleScript. GitHub loadstring mode requires an environment supporting game:HttpGet/loadstring.",
    Icon = { Type = "Text", Text = "!" },
    Height = 48,
})

-- Search is a regular tab. Results include tabs, registered commands and settings.
local Search = Window:CreateSearchTab("Search", {
    Icon = { Type = "Text", Text = "S" },
    SearchIcon = { Type = "Text", Text = "S" },
})

Window:Notify({
    Title = "NovaUI ready",
    Text = "Use Search to find tabs, commands and settings.",
    Type = "Info",
    Duration = 3.5,
})
