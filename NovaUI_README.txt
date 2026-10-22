NovaUI 1.1.3 - Liquid Glass GUI Library
=================================


CHANGES IN 1.1.2
----------------
- Notification duration bars are inset from the bottom corners and use rounded ends.
- Notification accent strips are inset and rounded to match the liquid-glass style.
- Tooltips only appear when a control explicitly sets Tooltip = "...".
- Close, collapse-to-icon, and collapse-to-bar controls have no automatic tooltips.
- Keybind and color-picker hints are no longer forced on by default.
- The example logo button now actually changes the logo to a star (★), not the letter N.

BUGFIXES IN 1.1.1
-----------------
- CollapseBar hides the sidebar, tab pages, and header divider while collapsed.
- Square collapse hides the same content so only the compact icon remains visible.
- Expansion restores the saved position without drift caused by ordinary button clicks.
- The compact square can be dragged; the expanded window follows its new location.
- Dropdown chevron arms overlap cleanly and have rounded ends.

CHANGES IN 1.1.3
----------------
- The window now uses a fixed top-left anchor, so collapsing into the icon does not pull it toward the center.
- The compact icon and expanded window share the same origin. Restoring grows toward the right and bottom.
- Dragging the window or icon is clamped so the expanded window stays inside the current viewport.
- Window width and height adapt to viewport changes, including orientation changes.
- Sidebar spacing and title/subtitle widths adapt to narrower screens.
- Window collapse/restore uses non-overshooting easing to avoid crossing screen edges.

INSTALLATION (Roblox Studio)
1. Create a ModuleScript named NovaUI inside ReplicatedStorage.
2. Paste the full contents of NovaUI.lua into that ModuleScript.
3. Create a LocalScript inside StarterPlayer > StarterPlayerScripts.
4. Copy the contents of NovaUI_Example.lua into that LocalScript.
5. Play-test the experience.

OPTIONAL LOGO
Text / letter:
  Logo = { Type = "Text", Text = "N" }

Image:
  Logo = { Type = "Image", Image = "rbxassetid://YOUR_IMAGE_ID" }

No logo:
  Omit the Logo setting or use Logo = nil.

WINDOW COLLAPSE API
  Window:CollapseBar()          -- keeps the window width; only the title bar remains
  Window:ToggleBarCollapse()    -- collapse / expand the title bar mode
  Window:CollapseToSquare()    -- collapses the window to a square icon
  Window:ToggleSquareCollapse() -- toggles square collapse / full restore
  Window:Expand()               -- restores the full window from either mode
  Window:SetVisible(false)      -- hide the whole window
  Window:SetVisible(true)       -- show it again
  Window:Close()                -- animate then destroy the GUI
  Window:Destroy()              -- destroy immediately

WINDOW OPTIONS
  Window:SetTitle(title, subtitle)
  Window:SetLogo(value, "Text")
  Window:SetLogo("rbxassetid://YOUR_IMAGE_ID", "Image")
  Window:SetTheme("Dark")       -- Dark, Midnight, Ocean, Light
  Window:SetAccentColor(Color3.fromRGB(104, 190, 255))
  Window:SetToggleKey(Enum.KeyCode.RightControl)
  Window:SetToggleKey(nil)       -- disable the visibility shortcut
  Window:SetReducedMotion(true)
  Window:Notify("Success", "Saved!")

CONTROLS
  Tab:AddSection("SECTION")
  Tab:AddLabel("Text")
  Tab:AddParagraph({ Title = "Title", Content = "Description" })
  Tab:AddDivider()
  Tab:AddButton({ Name = "Run", Callback = function() end })
  Tab:AddToggle({ Name = "Enabled", Default = false, Callback = function(value) end })
  Tab:AddSlider({ Name = "Amount", Min = 0, Max = 100, Default = 50, Callback = function(value) end })
  Tab:AddDropdown({ Name = "Quality", Options = { "Low", "High" }, Default = "High", Callback = function(value) end })
  Tab:AddTextBox({ Name = "Name", Placeholder = "Type here...", Callback = function(text, enterPressed) end })
  Tab:AddKeybind({ Name = "Action key", Default = Enum.KeyCode.F, Callback = function(keyCode) end })
  Tab:AddColorPicker({ Name = "Accent", Default = Color3.fromRGB(100, 180, 255), Callback = function(color) end })

Tooltips are opt-in only: add Tooltip = "Explanation" to the individual control when you want one. Controls without Tooltip have no tooltip.

The liquid-glass appearance is simulated using transparency, gradients, strokes,
and animated highlights. A true per-panel blur of the 3D scene is not applied.