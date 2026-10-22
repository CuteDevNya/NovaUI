NovaUI 1.2.1 - Liquid Glass GUI Library
=======================================

CHANGES IN 1.2.1
----------------
- Removed the floating Command Palette and floating Theme Editor.
- CreateSearchTab creates a normal tab with a search field and glass-styled results.
- Search results cover tabs, registered commands and registered settings.
- Ctrl+K switches to the Search tab and focuses its search input.
- CreateThemeEditorTab creates a normal Appearance tab for theme presets, accent, glass transparency, corner radius, animation speed and reduced motion.
- Icons can be added to tabs, sections, labels, paragraphs and controls.
- Text/symbol or image icons have no background by default; BackgroundColor or Background=true opts in to a background.
- AddGroup makes child controls share a rounded glass background. Buttons in a group show a soft inset white hover highlight.
- Multi-select dropdown canvas sizing is derived from its actual UIListLayout, so longer lists can scroll.
- Text inputs now have internal left/right padding.

INSTALLATION (Roblox Studio)
1. Create a ModuleScript named NovaUI inside ReplicatedStorage.
2. Paste the contents of NovaUI.lua into that ModuleScript.
3. Create a LocalScript inside StarterPlayer > StarterPlayerScripts.
4. Copy NovaUI_Example.lua into that LocalScript and set USE_GITHUB_LOADER = false.
5. Press Play.

GITHUB RAW LOADER (EXECUTOR-DEPENDENT)
The example includes:
  local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CuteDevNya/NovaUI/main/NovaUI.lua"))()

Ordinary Roblox Studio LocalScripts do not support game:HttpGet/loadstring.

SEARCH AND APPEARANCE TABS
  local Search = Window:CreateSearchTab("Search", {
      Icon = { Type = "Text", Text = "S" },
  })

  local Appearance = Window:CreateThemeEditorTab("Appearance", {
      Icon = { Type = "Text", Text = "A" },
  })

Ctrl+K switches to the in-GUI Search tab. It does not open a separate overlay.

ICONS
  Icon = { Type = "Text", Text = "M" }
  Icon = { Type = "Image", Image = "rbxassetid://YOUR_IMAGE_ID" }

Optional icon background:
  Icon = {
      Type = "Text",
      Text = "!",
      BackgroundColor = Color3.fromRGB(100, 180, 255),
      BackgroundTransparency = 0.15,
  }

GROUPED CONTROLS
  local group = Tab:AddGroup({
      Name = "PROGRESS",
      Icon = { Type = "Text", Text = "P" },
  })

  local progress = group:AddProgressBar({
      Name = "Loading",
      Min = 0,
      Max = 100,
      Default = 25,
  })

  group:AddButton({
      Name = "Advance",
      Callback = function()
          progress:Set(math.min(100, progress:Get() + 10))
      end,
  })

All controls added through the returned group use its shared background; interactive grouped buttons show a smaller translucent highlight on hover.

ICON OPTIONS
The optional Icon setting is supported by CreateTab, AddButton, AddToggle, AddSlider, AddDropdown, AddMultiDropdown, AddTextBox, AddKeybind, AddColorPicker, AddProgressBar, AddRadioGroup, AddKeybindList, AddLabel, AddParagraph and AddSection.
Icons have no background unless BackgroundColor or Background=true is supplied.

THEME AND CONFIG
  Window:SetTheme("Dark") -- Dark, Midnight, Ocean, Light
  Window:SetAccentColor(Color3.fromRGB(104, 190, 255))
  Window:SetThemeConfig({
      Theme = "Ocean",
      AccentColor = Color3.fromRGB(100, 200, 255),
      WindowTransparency = 0.12,
      CornerRadius = 16,
      AnimationScale = 0.9,
  })
  local saved = Window:GetConfig()
  Window:ApplyConfig(saved)

NOTIFICATIONS (TOAST OVERLAYS)
  Window:NotifySuccess("Saved!", 3)
  Window:NotifyWarning("Careful!", 3)
  Window:NotifyError("Something failed.", 3)
  Window:NotifyInfo("FYI", 3)
  Window:Notify({
      Title = "Saved",
      Text = "Your changes have been saved.",
      Type = "Success",
      Duration = 4,
      ShowCloseButton = true,
  })

EXISTING CONTROLS
  Tab:AddSection, AddLabel, AddParagraph, AddDivider
  Tab:AddButton, AddToggle, AddSlider, AddDropdown, AddMultiDropdown
  Tab:AddTextBox, AddKeybind, AddColorPicker
  Tab:AddProgressBar, AddRadioGroup, AddKeybindList, AddGroup

WINDOW OPTIONS
  Window:CollapseBar()
  Window:CollapseToSquare()
  Window:Expand()
  Window:SetVisible(false)
  Window:SetReducedMotion(true)
  Window:SetToggleKey(Enum.KeyCode.RightControl)
  Window:Close()
  Window:Destroy()

Tooltips are opt-in: add Tooltip = "Explanation" to a control to show one.
The liquid-glass appearance is simulated with transparency, gradients, strokes, and highlights.
