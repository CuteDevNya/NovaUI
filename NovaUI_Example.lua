-- NovaUI Example
-- Put NovaUI.lua in a ModuleScript named "NovaUI" inside ReplicatedStorage.
-- Put this example in a LocalScript inside StarterPlayerScripts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NovaUI = require(ReplicatedStorage:WaitForChild("NovaUI"))

local Window = NovaUI:CreateWindow({
    Title = "NovaUI",
    Subtitle = "LIQUID GLASS INTERFACE",
    Width = 650,
    Height = 460,
    Theme = "Dark", -- Dark, Midnight, Ocean, Light
    AccentColor = Color3.fromRGB(104, 190, 255),
    ToggleKey = Enum.KeyCode.RightControl,
    ReducedMotion = false,

    -- Optional logo. Remove this field to show no logo.
    Logo = {
        Type = "Text",
        Text = "N",
    },

    -- Image logo alternative:
    -- Logo = { Type = "Image", Image = "rbxassetid://YOUR_IMAGE_ID" },
})

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
About:AddParagraph({
    Title = "Window controls",
    Content = "The top bar has separate buttons for collapsing to a title bar, collapsing to a square icon, and closing. Clicking the square icon always restores the full window, even if it was previously collapsed to a bar.",
})

About:AddLabel({
    Text = "Press RightControl to hide or show the window.",
    Height = 42,
})

About:AddDivider()
About:AddLabel("This example is intended for a LocalScript in your own Roblox experience.")

Window:Notify({
    Title = "NovaUI ready",
    Text = "Your liquid-glass interface is ready.",
    Type = "Info",
    Duration = 3.5,
})