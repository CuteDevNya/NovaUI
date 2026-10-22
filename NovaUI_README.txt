NovaUI 1.2.0 - Liquid Glass GUI Library
=======================================

CHANGES IN 1.2.0
----------------
- Command Palette: search registered commands and tabs with Ctrl+K.
- Live Theme Editor: theme presets, accent colors, glass transparency, corner radius and reduced motion.
- SetThemeConfig supports custom palette colors, accent, root transparency, corner radius and animation speed.
- Notification helpers: NotifySuccess, NotifyWarning, NotifyError and NotifyInfo.
- Notifications keep stacking behavior and can include ShowCloseButton = true.
- New controls: AddMultiDropdown, AddProgressBar, AddRadioGroup and AddKeybindList.
- KeybindList refreshes when a keybind changes.
- Window snapping and bottom-right resizing can be configured using SnapToEdges and Resizable.
- GetConfig and ApplyConfig save/restore theme and registered control state in memory.
- AnimationScale controls overall tween duration.

INSTALLATION (Roblox Studio)
1. Create a ModuleScript named NovaUI inside ReplicatedStorage.
2. Paste the full contents of NovaUI.lua into that ModuleScript.
3. Create a LocalScript inside StarterPlayer > StarterPlayerScripts.
4. Copy NovaUI_Example.lua into that LocalScript and set USE_GITHUB_LOADER = false.
5. Press Play.

GITHUB RAW LOADER (EXECUTOR-DEPENDENT)
The example also includes:
  local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CuteDevNya/NovaUI/main/NovaUI.lua"))()

This is not supported in a normal Roblox Studio LocalScript. Only run source you trust and only where you are permitted to test it.

QUICK EXAMPLE
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

NEW CONTROLS
  Tab:AddMultiDropdown({
      Name = "Effects",
      Options = { "Bloom", "Shadows" },
      Default = { "Bloom" },
      Callback = function(values) end,
  })

  local progress = Tab:AddProgressBar({
      Name = "Loading",
      Min = 0,
      Max = 100,
      Default = 20,
  })
  progress:Set(75)

  Tab:AddRadioGroup({
      Name = "Quality",
      Options = { "Low", "High" },
      Default = "High",
      Callback = function(value) end,
  })

  Tab:AddKeybindList({ Name = "Keybinds", Height = 150 })

COMMAND PALETTE
  Window:RegisterCommand("Open editor", function()
      Window:OpenThemeEditor()
  end, { "theme", "colors" })

  Window:OpenCommandPalette()
  -- Ctrl+K opens the Command Palette.

THEME AND CONFIG
  Window:SetThemeConfig({
      Theme = "Ocean",
      AccentColor = Color3.fromRGB(100, 200, 255),
      WindowTransparency = 0.12,
      CornerRadius = 16,
      AnimationScale = 0.9,
      Colors = {
          Background = Color3.fromRGB(18, 25, 40),
      },
  })

  local saved = Window:GetConfig()
  Window:ApplyConfig(saved)

  Window:NotifySuccess("Saved!", 3)
  Window:NotifyWarning("Careful!", 3)
  Window:NotifyError("Something failed.", 3)
  Window:NotifyInfo("FYI", 3)

EXISTING CONTROLS
  Tab:AddSection, AddLabel, AddParagraph, AddDivider
  Tab:AddButton, AddToggle, AddSlider, AddDropdown
  Tab:AddTextBox, AddKeybind, AddColorPicker

WINDOW OPTIONS
  Window:SetTitle(title, subtitle)
  Window:SetLogo(value, "Text")
  Window:SetLogo("rbxassetid://YOUR_IMAGE_ID", "Image")
  Window:SetTheme("Dark") -- Dark, Midnight, Ocean, Light
  Window:SetAccentColor(Color3.fromRGB(104, 190, 255))
  Window:SetToggleKey(Enum.KeyCode.RightControl)
  Window:SetReducedMotion(true)
  Window:CollapseBar()
  Window:CollapseToSquare()
  Window:Expand()
  Window:SetVisible(false)
  Window:Close()
  Window:Destroy()

Tooltips are opt-in: set Tooltip = "Explanation" on a control to show one.
The liquid-glass appearance is simulated with transparency, gradients, outlines,
and highlights; standard ScreenGui does not provide a true per-panel backdrop blur.
