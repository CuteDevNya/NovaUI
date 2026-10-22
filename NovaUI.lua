--[[
    NovaUI 1.1.2 - Liquid Glass GUI Library for Roblox
    Intended for a LocalScript + ModuleScript in an experience you own or are authorized to edit.

    Quick start:
      local NovaUI = require(game:GetService("ReplicatedStorage"):WaitForChild("NovaUI"))
      local Window = NovaUI:CreateWindow({ Title = "My GUI", Subtitle = "Liquid Glass", AccentColor = Color3.fromRGB(100, 190, 255) })
      local Main = Window:CreateTab("Main")
      Main:AddButton({ Name = "Say hello", Callback = function() print("Hello!") end })
      Main:AddToggle({ Name = "Example toggle", Default = false, Callback = function(enabled) print(enabled) end })
      Main:AddSlider({ Name = "Volume", Min = 0, Max = 100, Default = 50, Step = 1, Callback = function(value) print(value) end })
      Main:AddDropdown({ Name = "Quality", Options = { "Low", "Medium", "High" }, Default = "Medium", Callback = function(value) print(value) end })

    Extra controls:
      Tab:AddParagraph, AddTextBox, AddKeybind, AddColorPicker
      Window:Notify, SetTheme, SetAccentColor, SetReducedMotion, SetToggleKey
      Window:CollapseBar, CollapseToSquare, Expand, SetLogo

    Note: the liquid-glass look is simulated with transparency, gradients and highlights. Roblox
    ScreenGui elements cannot apply a true per-panel backdrop blur to the 3D scene behind them.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local NovaUI = {}
NovaUI.__index = NovaUI

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local COLORS = {
    Background = Color3.fromRGB(19, 25, 38),
    BackgroundLight = Color3.fromRGB(29, 38, 55),
    Card = Color3.fromRGB(38, 48, 67),
    CardHover = Color3.fromRGB(48, 61, 83),
    Text = Color3.fromRGB(240, 245, 255),
    Muted = Color3.fromRGB(155, 170, 192),
    Outline = Color3.fromRGB(156, 184, 220),
    Off = Color3.fromRGB(67, 80, 101),
    White = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(104, 190, 255),
}

local THEMES = {
    Dark = {
        Background = Color3.fromRGB(19, 25, 38),
        BackgroundLight = Color3.fromRGB(29, 38, 55),
        Card = Color3.fromRGB(38, 48, 67),
        CardHover = Color3.fromRGB(48, 61, 83),
        Text = Color3.fromRGB(240, 245, 255),
        Muted = Color3.fromRGB(155, 170, 192),
        Outline = Color3.fromRGB(156, 184, 220),
        Off = Color3.fromRGB(67, 80, 101),
        White = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(104, 190, 255),
    },
    Midnight = {
        Background = Color3.fromRGB(13, 15, 28),
        BackgroundLight = Color3.fromRGB(22, 25, 44),
        Card = Color3.fromRGB(29, 32, 53),
        CardHover = Color3.fromRGB(43, 47, 74),
        Text = Color3.fromRGB(244, 244, 255),
        Muted = Color3.fromRGB(157, 160, 190),
        Outline = Color3.fromRGB(147, 149, 206),
        Off = Color3.fromRGB(66, 68, 98),
        White = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(164, 145, 255),
    },
    Ocean = {
        Background = Color3.fromRGB(10, 29, 39),
        BackgroundLight = Color3.fromRGB(17, 44, 57),
        Card = Color3.fromRGB(24, 56, 69),
        CardHover = Color3.fromRGB(31, 73, 87),
        Text = Color3.fromRGB(234, 250, 255),
        Muted = Color3.fromRGB(147, 186, 196),
        Outline = Color3.fromRGB(124, 202, 215),
        Off = Color3.fromRGB(55, 91, 105),
        White = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(77, 220, 215),
    },
    Light = {
        Background = Color3.fromRGB(224, 233, 244),
        BackgroundLight = Color3.fromRGB(239, 245, 252),
        Card = Color3.fromRGB(250, 252, 255),
        CardHover = Color3.fromRGB(230, 239, 250),
        Text = Color3.fromRGB(30, 42, 60),
        Muted = Color3.fromRGB(91, 108, 130),
        Outline = Color3.fromRGB(120, 142, 170),
        Off = Color3.fromRGB(174, 188, 205),
        White = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(36, 125, 221),
    },
}

local function normalizeThemeName(name)
    if type(name) == "string" then
        for knownName in pairs(THEMES) do
            if string.lower(knownName) == string.lower(name) then
                return knownName
            end
        end
    end
    return "Dark"
end

local function copyTheme(name)
    local source = THEMES[normalizeThemeName(name)] or THEMES.Dark
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function create(className, properties, parent)
    local instance = Instance.new(className)
    for key, value in pairs(properties or {}) do
        instance[key] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function addCorner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 12),
    }, parent)
end

local function addStroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or COLORS.Outline,
        Transparency = transparency == nil and 0.72 or transparency,
        Thickness = thickness or 1,
    }, parent)
end

local function addConnection(window, signal, callback)
    local connection = signal:Connect(callback)
    if window and window._connections then
        table.insert(window._connections, connection)
    end
    return connection
end

local function playTween(object, duration, easingStyle, easingDirection, properties)
    if not object or not object.Parent then
        return nil
    end

    local ancestor = object
    while ancestor do
        if ancestor:GetAttribute("NovaReducedMotion") == true then
            for key, value in pairs(properties or {}) do
                pcall(function()
                    object[key] = value
                end)
            end
            return nil
        end
        ancestor = ancestor.Parent
    end

    local info = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local function safeCallback(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end
    local ok, errorMessage = pcall(callback, ...)
    if not ok then
        warn("[NovaUI] Callback error: " .. tostring(errorMessage))
    end
end

local function createText(parent, text, size, color, properties)
    local props = {
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        Font = Enum.Font.GothamMedium,
        TextSize = size or 14,
        TextColor3 = color or COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BorderSizePixel = 0,
    }
    for key, value in pairs(properties or {}) do
        props[key] = value
    end
    return create("TextLabel", props, parent)
end

-- Adds a small spring-like hover/press effect to clickable objects.
local function addInteractive(button, window, stroke)
    local scale = create("UIScale", { Scale = 1 }, button)
    local pressed = false

    addConnection(window, button.MouseEnter, function()
        if not pressed then
            playTween(scale, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1.018 })
            if stroke then
                playTween(stroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Transparency = 0.38,
                    Color = window.AccentColor,
                })
            end
        end
    end)

    addConnection(window, button.MouseLeave, function()
        pressed = false
        playTween(scale, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
        if stroke then
            playTween(stroke, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Transparency = 0.72,
                Color = (window.Colors and window.Colors.Outline) or COLORS.Outline,
            })
        end
    end)

    addConnection(window, button.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            pressed = true
            playTween(scale, 0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 0.965 })
        end
    end)

    addConnection(window, button.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            pressed = false
            -- Back easing gives the object a short, controlled bounce on release.
            playTween(scale, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
        end
    end)

    return scale
end

local function makeCard(parent, height, window)
    local colors = (window and window.Colors) or COLORS
    local card = create("Frame", {
        Name = "ControlCard",
        Size = UDim2.new(1, -2, 0, height),
        BackgroundColor3 = colors.Card,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    addCorner(card, 12)
    local stroke = addStroke(card, colors.Outline, 0.82, 1)
    return card, stroke
end

local function formatNumber(value, decimals)
    decimals = math.clamp(math.floor(decimals or 0), 0, 4)
    return string.format("%." .. tostring(decimals) .. "f", value)
end

local attachTooltip

function WindowMethods:SelectTab(tabToSelect)
    if self._destroyed then
        return
    end
    for _, tab in ipairs(self._tabs) do
        local selected = tab == tabToSelect
        tab.Page.Visible = selected
        playTween(tab.Button, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundTransparency = selected and 0.18 or 1,
            BackgroundColor3 = selected and self.Colors.CardHover or self.Colors.Card,
        })
        playTween(tab.Indicator, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            BackgroundTransparency = selected and 0 or 1,
            Size = selected and UDim2.new(0, 3, 0, 22) or UDim2.new(0, 3, 0, 8),
        })
        playTween(tab.Label, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            TextColor3 = selected and self.Colors.Text or self.Colors.Muted,
        })
    end
    self._selectedTab = tabToSelect
    if tabToSelect and tabToSelect.Page then
        tabToSelect.Page.CanvasPosition = Vector2.new(0, 0)
    end
end

function WindowMethods:SetTitle(title, subtitle)
    if self._titleLabel then
        self._titleLabel.Text = tostring(title or "NovaUI")
    end
    if subtitle ~= nil and self._subtitleLabel then
        self._subtitleLabel.Text = tostring(subtitle)
        self._subtitleLabel.Visible = subtitle ~= ""
        self._hasSubtitle = subtitle ~= ""
        self._titleLabel.Position = UDim2.new(0, self._logoConfig and 54 or 18, 0, self._hasSubtitle and 5 or 0)
        self._titleLabel.Size = UDim2.new(1, self._logoConfig and -164 or -128, 0, self._hasSubtitle and 27 or self._topbarHeight)
    end
end

local function colorRole(color, palette)
    local keys = { "Background", "BackgroundLight", "Card", "CardHover", "Text", "Muted", "Outline", "Off", "White", "Accent" }
    for _, key in ipairs(keys) do
        if palette[key] and color == palette[key] then
            return key
        end
    end
    return nil
end

function WindowMethods:SetTheme(themeName)
    if self._destroyed then
        return
    end
    themeName = normalizeThemeName(themeName)
    local newPalette = copyTheme(themeName)
    newPalette.Accent = self.AccentColor
    local oldPalette = self.Colors or COLORS

    for _, descendant in ipairs(self._screenGui:GetDescendants()) do
        if descendant:IsA("GuiObject") then
            local oldBackground = descendant.BackgroundColor3
            local role = colorRole(oldBackground, oldPalette) or colorRole(oldBackground, COLORS)
            if role and newPalette[role] then
                descendant.BackgroundColor3 = newPalette[role]
            elseif oldBackground == self._lastThemeAccent then
                descendant.BackgroundColor3 = self.AccentColor
            end
        end
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            local oldText = descendant.TextColor3
            local role = colorRole(oldText, oldPalette) or colorRole(oldText, COLORS)
            if role and newPalette[role] then
                descendant.TextColor3 = newPalette[role]
            elseif oldText == self._lastThemeAccent then
                descendant.TextColor3 = self.AccentColor
            end
        end
        if descendant:IsA("UIStroke") then
            local oldStroke = descendant.Color
            local role = colorRole(oldStroke, oldPalette) or colorRole(oldStroke, COLORS)
            if role and newPalette[role] then
                descendant.Color = newPalette[role]
            elseif oldStroke == self._lastThemeAccent then
                descendant.Color = self.AccentColor
            end
        end
        if descendant:IsA("ScrollingFrame") then
            local oldScroll = descendant.ScrollBarImageColor3
            if oldScroll == self._lastThemeAccent or oldScroll == self.AccentColor then
                descendant.ScrollBarImageColor3 = self.AccentColor
            end
        end
    end

    self.Colors = newPalette
    self.Theme = THEMES[themeName] and themeName or "Dark"
    self._lastThemeAccent = self.AccentColor

    local rootGradient = self._root and self._root:FindFirstChild("WindowGradient")
    if rootGradient and rootGradient:IsA("UIGradient") then
        rootGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, newPalette.BackgroundLight),
            ColorSequenceKeypoint.new(0.52, newPalette.Background),
            ColorSequenceKeypoint.new(1, newPalette.Card),
        })
    end
    local glintGradient = self._root and self._root:FindFirstChild("GlassGlintGradient", true)
    if glintGradient and glintGradient:IsA("UIGradient") then
        glintGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.AccentColor),
            ColorSequenceKeypoint.new(0.5, newPalette.White),
            ColorSequenceKeypoint.new(1, self.AccentColor),
        })
    end
end

function WindowMethods:SetAccentColor(color)
    if self._destroyed or typeof(color) ~= "Color3" then
        return
    end
    local oldAccent = self.AccentColor
    self.AccentColor = color
    self.Colors.Accent = color
    for _, descendant in ipairs(self._screenGui:GetDescendants()) do
        if descendant:IsA("GuiObject") and descendant.BackgroundColor3 == oldAccent then
            descendant.BackgroundColor3 = color
        end
        if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox"))
            and descendant.TextColor3 == oldAccent then
            descendant.TextColor3 = color
        end
        if descendant:IsA("UIStroke") and descendant.Color == oldAccent then
            descendant.Color = color
        end
        if descendant:IsA("ScrollingFrame") and descendant.ScrollBarImageColor3 == oldAccent then
            descendant.ScrollBarImageColor3 = color
        end
    end
    if self._rootStroke then
        self._rootStroke.Color = color
    end
    for _, tab in ipairs(self._tabs) do
        tab.Indicator.BackgroundColor3 = color
        tab.Page.ScrollBarImageColor3 = color
    end
    local glintGradient = self._root and self._root:FindFirstChild("GlassGlintGradient", true)
    if glintGradient and glintGradient:IsA("UIGradient") then
        glintGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(0.5, self.Colors.White),
            ColorSequenceKeypoint.new(1, color),
        })
    end
    self._lastThemeAccent = color
end

function WindowMethods:SetReducedMotion(enabled)
    if self._screenGui then
        self._screenGui:SetAttribute("NovaReducedMotion", enabled == true)
    end
    self.ReducedMotion = enabled == true
end

function WindowMethods:SetToggleKey(keyCode)
    if keyCode ~= nil and typeof(keyCode) ~= "EnumItem" then
        if type(keyCode) == "string" then
            keyCode = Enum.KeyCode[keyCode]
        end
    end
    if keyCode ~= nil and (typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode) then
        warn("[NovaUI] SetToggleKey expects an Enum.KeyCode or nil")
        return
    end
    self.ToggleKey = keyCode
end

local function setCollapsedBodyVisible(self, visible)
    -- Explicit visibility is more reliable than relying on ClipsDescendants alone:
    -- ScrollingFrames and their descendants can otherwise remain visible during a resize tween.
    if self._sidebar then self._sidebar.Visible = visible end
    if self._content then self._content.Visible = visible end
    if self._headerDivider then self._headerDivider.Visible = visible end
end

function WindowMethods:CollapseBar()
    if self._destroyed or self._collapseMode == "bar" then
        return
    end
    if self._collapseMode == nil then
        self._expandedPosition = self._root.Position
    end
    self._collapseMode = "bar"
    setCollapsedBodyVisible(self, false)
    self._topbar.Size = UDim2.new(1, 0, 0, self._topbarHeight)
    self._titleLabel.Visible = true
    self._subtitleLabel.Visible = self._hasSubtitle
    if self._logoFrame then self._logoFrame.Visible = true end
    self._closeButton.Visible = true
    self._barCollapseButton.Visible = true
    self._squareCollapseButton.Visible = true
    self._squareRestoreButton.Visible = false

    -- Keep the top edge fixed while the window shrinks. Expansion restores the exact
    -- saved center position; it is not recalculated from transient tween positions.
    local collapseOffset = math.max(0, (self._expandedSize.Y.Offset - self._topbarHeight) / 2)
    local targetPosition = self._expandedPosition + UDim2.fromOffset(0, -collapseOffset)
    local targetSize = UDim2.new(self._expandedSize.X.Scale, self._expandedSize.X.Offset, 0, self._topbarHeight)
    local tween = playTween(self._root, 0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        Size = targetSize,
        Position = targetPosition,
    })
    if not tween then
        self._root.Size = targetSize
        self._root.Position = targetPosition
    end
end

function WindowMethods:ToggleBarCollapse()
    if self._collapseMode == "bar" then
        self:Expand()
    else
        self:CollapseBar()
    end
end

function WindowMethods:CollapseToSquare()
    if self._destroyed or self._collapseMode == "square" then
        return
    end
    if self._collapseMode == nil then
        self._expandedPosition = self._root.Position
    end
    self._collapseMode = "square"
    setCollapsedBodyVisible(self, false)
    self._topbar.Size = UDim2.fromScale(1, 1)
    self._titleLabel.Visible = false
    self._subtitleLabel.Visible = false
    if self._logoFrame then self._logoFrame.Visible = false end
    self._closeButton.Visible = false
    self._barCollapseButton.Visible = false
    self._squareCollapseButton.Visible = false
    self._squareRestoreButton.Visible = true
    self._squareRestoreButton.Size = UDim2.fromScale(1, 1)
    local size = self._compactSize
    local tween = playTween(self._root, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, {
        Size = UDim2.fromOffset(size, size),
    })
    if not tween then
        self._root.Size = UDim2.fromOffset(size, size)
    end
end

function WindowMethods:ToggleSquareCollapse()
    if self._collapseMode == "square" then
        self:Expand()
    else
        self:CollapseToSquare()
    end
end

function WindowMethods:Expand()
    if self._destroyed then
        return
    end
    self._collapseMode = nil
    setCollapsedBodyVisible(self, true)
    self._topbar.Size = UDim2.new(1, 0, 0, self._topbarHeight)
    self._titleLabel.Visible = true
    self._subtitleLabel.Visible = self._hasSubtitle
    if self._logoFrame then self._logoFrame.Visible = true end
    self._closeButton.Visible = true
    self._barCollapseButton.Visible = true
    self._squareCollapseButton.Visible = true
    self._squareRestoreButton.Visible = false
    local target = self._expandedSize
    local targetPosition = self._expandedPosition or self._root.Position
    local tween = playTween(self._root, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        Size = target,
        Position = targetPosition,
    })
    if not tween then
        self._root.Size = target
        self._root.Position = targetPosition
    end
end

local function normalizeLogo(logo, logoType)
    if type(logo) == "table" then
        logoType = logo.Type or logoType
        logo = logo.Image or logo.Text or logo.Value
    end
    if logo == nil or tostring(logo) == "" then
        return nil, nil
    end
    if not logoType then
        if type(logo) == "number" or tostring(logo):match("^rbxassetid://") then
            logoType = "Image"
        else
            logoType = "Text"
        end
    end
    logoType = string.lower(tostring(logoType))
    if logoType == "image" then
        local image = tostring(logo)
        if not image:match("^rbxassetid://") and image:match("^%d+$") then
            image = "rbxassetid://" .. image
        end
        return image, "Image"
    end
    return tostring(logo), "Text"
end

local function createLogoVisual(parent, logoValue, logoType, size, colors)
    if not logoValue then
        return nil
    end
    local holder = create("Frame", {
        Name = "LogoVisual",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = colors.Card,
        BackgroundTransparency = logoType == "Image" and 1 or 0.2,
        BorderSizePixel = 0,
    }, parent)
    addCorner(holder, math.floor(size * 0.28))
    if logoType == "Image" then
        create("ImageLabel", {
            Name = "LogoImage",
            BackgroundTransparency = 1,
            Image = logoValue,
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, -3, 1, -3),
            BorderSizePixel = 0,
        }, holder)
    else
        createText(holder, logoValue, math.max(12, math.floor(size * 0.52)), colors.Text, {
            Name = "LogoText",
            Size = UDim2.fromScale(1, 1),
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
        })
    end
    return holder
end

function WindowMethods:SetLogo(logo, logoType)
    if self._destroyed then
        return
    end
    local value, kind = normalizeLogo(logo, logoType)
    self._logoConfig = value and { Value = value, Type = kind } or nil
    if self._logoFrame then
        self._logoFrame:Destroy()
        self._logoFrame = nil
    end
    if value then
        self._logoFrame = createLogoVisual(self._topbar, value, kind, 30, self.Colors)
        self._logoFrame.Position = UDim2.new(0, 15, 0.5, 0)
        self._logoFrame.AnchorPoint = Vector2.new(0, 0.5)
    end
    if self._titleLabel then
        self._titleLabel.Position = UDim2.new(0, value and 54 or 18, 0, self._hasSubtitle and 5 or 0)
        self._titleLabel.Size = UDim2.new(1, value and -164 or -128, 0, self._hasSubtitle and 27 or self._topbarHeight)
    end
    if self._subtitleLabel then
        self._subtitleLabel.Position = UDim2.new(0, value and 55 or 19, 0, 31)
        self._subtitleLabel.Size = UDim2.new(1, value and -170 or -135, 0, 17)
    end
    local restoreLogo = self._squareRestoreButton and self._squareRestoreButton:FindFirstChild("LogoVisual")
    if restoreLogo then restoreLogo:Destroy() end
    if self._squareRestoreButton then
        for _, child in ipairs(self._squareRestoreButton:GetChildren()) do
            if child.Name == "RestoreGlyph" then child:Destroy() end
        end
        if value then
            createLogoVisual(self._squareRestoreButton, value, kind, math.floor(self._compactSize * 0.56), self.Colors)
        else
            local glyph = create("Frame", {
                Name = "RestoreGlyph",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(16, 16),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, self._squareRestoreButton)
            local color = self.Colors.Text
            for _, item in ipairs({
                {0, 0, 6, 2, 0}, {0, 0, 2, 6, 0},
                {10, 0, 6, 2, 0}, {14, 0, 2, 6, 0},
                {0, 14, 6, 2, 0}, {0, 10, 2, 6, 0},
                {10, 14, 6, 2, 0}, {14, 10, 2, 6, 0},
            }) do
                create("Frame", {
                    Position = UDim2.fromOffset(item[1], item[2]),
                    Size = UDim2.fromOffset(item[3], item[4]),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                }, glyph)
            end
        end
    end
    if self._collapseMode == "square" and self._logoFrame then
        self._logoFrame.Visible = false
    end
end

local function repositionNotifications(window)
    for index, notification in ipairs(window._notifications or {}) do
        if notification.Frame and notification.Frame.Parent then
            playTween(notification.Frame, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                Position = UDim2.new(1, -24, 0, 22 + (index - 1) * 84),
            })
        end
    end
end

function WindowMethods:Notify(config, message, duration)
    if self._destroyed then
        return nil
    end
    if type(config) ~= "table" then
        local label = tostring(config or "NovaUI")
        local normalized = string.lower(label)
        local toastType = ({ success = "Success", warning = "Warning", error = "Error", info = "Info" })[normalized]
        config = { Title = label, Text = tostring(message or ""), Type = toastType or "Info", Duration = duration }
    end
    config = config or {}
    local kind = string.lower(tostring(config.Type or "Info"))
    local colorByType = {
        success = Color3.fromRGB(92, 222, 158),
        warning = Color3.fromRGB(255, 198, 92),
        error = Color3.fromRGB(255, 110, 130),
        info = self.AccentColor,
    }
    local accent = colorByType[kind] or self.AccentColor
    local toast = create("Frame", {
        Name = "NovaNotification",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 36, 0, 22),
        Size = UDim2.fromOffset(300, 72),
        BackgroundColor3 = self.Colors.Card,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 200,
    }, self._screenGui)
    addCorner(toast, 13)
    local outline = addStroke(toast, accent, 0.35, 1.1)
    local accentBar = create("Frame", {
        Name = "NotificationAccent",
        Position = UDim2.new(0, 7, 0, 14),
        Size = UDim2.new(0, 4, 1, -28),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 201,
    }, toast)
    addCorner(accentBar, 3)
    createText(toast, config.Title or "NovaUI", 13, self.Colors.Text, {
        Name = "NotificationTitle",
        Position = UDim2.new(0, 19, 0, 8),
        Size = UDim2.new(1, -31, 0, 22),
        Font = Enum.Font.GothamBold,
        ZIndex = 202,
    })
    createText(toast, config.Text or config.Message or "", 11, self.Colors.Muted, {
        Name = "NotificationMessage",
        Position = UDim2.new(0, 19, 0, 31),
        Size = UDim2.new(1, -31, 0, 32),
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 202,
    })
    -- Keep the duration indicator inside the toast's rounded silhouette.
    -- Insets prevent the bar from poking into the rounded bottom corners.
    local progress = create("Frame", {
        Name = "NotificationProgress",
        Position = UDim2.new(0, 14, 1, -7),
        Size = UDim2.new(1, -28, 0, 3),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 203,
    }, toast)
    addCorner(progress, 3)

    local record = { Frame = toast, Stroke = outline }
    table.insert(self._notifications, record)
    while #self._notifications > 4 do
        local oldest = table.remove(self._notifications, 1)
        if oldest.Frame then oldest.Frame:Destroy() end
    end
    repositionNotifications(self)
    local entrance = playTween(toast, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        Position = UDim2.new(1, -24, 0, 22 + (#self._notifications - 1) * 84),
    })

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        for index, item in ipairs(self._notifications) do
            if item == record then
                table.remove(self._notifications, index)
                break
            end
        end
        if toast.Parent then
            local outTween = playTween(toast, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                Position = UDim2.new(1, 35, 0, toast.Position.Y.Offset),
                BackgroundTransparency = 1,
            })
            if outTween then
                outTween.Completed:Connect(function()
                    if toast.Parent then toast:Destroy() end
                    repositionNotifications(self)
                end)
            else
                toast:Destroy()
                repositionNotifications(self)
            end
        end
    end
    record.Dismiss = dismiss

    local seconds = math.max(0.75, tonumber(config.Duration) or 3.5)
    playTween(progress, seconds, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {
        Size = UDim2.new(0, 0, 0, 2),
    })
    task.delay(seconds, function()
        if not self._destroyed then dismiss() end
    end)
    return { Instance = toast, Dismiss = dismiss }
end

function WindowMethods:SetVisible(visible)
    if self._destroyed then
        return
    end
    visible = not not visible
    self._hidden = not visible
    if self._visibilityTween then
        pcall(function() self._visibilityTween:Cancel() end)
        self._visibilityTween = nil
    end
    if visible then
        self._root.Visible = true
        self._rootScale.Scale = 0.92
        self._visibilityTween = playTween(self._rootScale, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
    else
        local closingTween = playTween(self._rootScale, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Scale = 0.92 })
        self._visibilityTween = closingTween
        if closingTween then
            closingTween.Completed:Connect(function(playbackState)
                if playbackState == Enum.PlaybackState.Completed and not self._destroyed and self._hidden then
                    self._root.Visible = false
                end
            end)
        else
            self._root.Visible = false
        end
    end
end

function WindowMethods:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(self._connections)
    if self._screenGui then
        self._screenGui:Destroy()
    end
end

function WindowMethods:Close()
    if self._destroyed or self._closing then
        return
    end
    self._closing = true
    local closingTween = playTween(self._rootScale, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In, { Scale = 0.88 })
    playTween(self._root, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { BackgroundTransparency = 1 })
    if closingTween then
        closingTween.Completed:Connect(function()
            self:Destroy()
        end)
    else
        self:Destroy()
    end
end

function WindowMethods:CreateTab(tabName)
    assert(not self._destroyed, "Cannot add a tab to a destroyed NovaUI window")
    tabName = tostring(tabName or ("Tab " .. tostring(#self._tabs + 1)))

    local tabButton = create("TextButton", {
        Name = "TabButton_" .. tabName,
        Size = UDim2.new(1, -4, 0, 42),
        BackgroundColor3 = self.Colors.CardHover,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #self._tabs + 1,
    }, self._tabList)
    addCorner(tabButton, 10)

    local indicator = create("Frame", {
        Name = "ActiveIndicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 8),
        BackgroundColor3 = self.AccentColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, tabButton)
    addCorner(indicator, 3)

    local label = createText(tabButton, tabName, 13, self.Colors.Muted, {
        Name = "TabLabel",
        Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local page = create("ScrollingFrame", {
        Name = "Page_" .. tabName,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    }, self._content)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 8),
    }, page)

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    local tab = setmetatable({
        Window = self,
        Name = tabName,
        Button = tabButton,
        Indicator = indicator,
        Label = label,
        Page = page,
        Layout = layout,
    }, TabMethods)

    table.insert(self._tabs, tab)

    addConnection(self, layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if page.Parent then
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
        end
    end)

    addInteractive(tabButton, self)
    addConnection(self, tabButton.Activated, function()
        self:SelectTab(tab)
    end)

    if #self._tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function TabMethods:AddSection(sectionName)
    local frame = create("Frame", {
        Name = "Section",
        Size = UDim2.new(1, -2, 0, 26),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, self.Page)
    createText(frame, tostring(sectionName or "SECTION"):upper(), 11, self.Window.AccentColor, {
        Position = UDim2.new(0, 3, 0, 0),
        Size = UDim2.new(1, -6, 1, 0),
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return frame
end

function TabMethods:AddLabel(config)
    if type(config) == "string" then
        config = { Text = config }
    end
    config = config or {}
    local card = makeCard(self.Page, config.Height or 42, self.Window)
    card.BackgroundTransparency = 0.48
    createText(card, config.Text or config.Name or "Label", config.TextSize or 13, config.TextColor or self.Window.Colors.Muted, {
        Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.new(1, -26, 1, 0),
        TextWrapped = true,
        Font = Enum.Font.Gotham,
    })
    return card
end

function TabMethods:AddDivider()
    local divider = create("Frame", {
        Name = "Divider",        Size = UDim2.new(1, -8, 0, 1),
        BackgroundColor3 = self.Window.Colors.Outline,
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
    }, self.Page)
    return divider
end

function TabMethods:AddButton(config)
    if type(config) == "string" then
        config = { Name = config }
    end
    config = config or {}

    local height = config.Description and 66 or 52
    local card, stroke = makeCard(self.Page, height, self.Window)
    local button = create("TextButton", {
        Name = "ButtonHitbox",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)

    createText(card, config.Name or "Button", 14, self.Window.Colors.Text, {
        Position = UDim2.new(0, 14, 0, config.Description and 7 or 0),
        Size = UDim2.new(1, -28, 0, config.Description and 25 or height),
        Font = Enum.Font.GothamMedium,
    })

    if config.Description then
        createText(card, config.Description, 11, self.Window.Colors.Muted, {
            Position = UDim2.new(0, 14, 0, 32),
            Size = UDim2.new(1, -28, 0, 23),
            Font = Enum.Font.Gotham,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
    end

    addInteractive(button, self.Window, stroke)
    addConnection(self.Window, button.Activated, function()
        safeCallback(config.Callback)
    end)
    attachTooltip(button, self.Window, config.Tooltip)

    return {
        Instance = card,
        Button = button,
    }
end

function TabMethods:AddToggle(config)
    config = config or {}
    local card, stroke = makeCard(self.Page, 54, self.Window)
    local state = config.Default == true

    local hitbox = create("TextButton", {
        Name = "ToggleHitbox",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)

    createText(card, config.Name or "Toggle", 13, self.Window.Colors.Text, {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -78, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local switch = create("Frame", {
        Name = "SwitchTrack",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
        Size = UDim2.new(0, 44, 0, 24),
        BackgroundColor3 = state and self.Window.AccentColor or self.Window.Colors.Off,
        BorderSizePixel = 0,
    }, card)
    addCorner(switch, 20)

    local knob = create("Frame", {
        Name = "SwitchKnob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, state and 32 or 12, 0.5, 0),
        Size = UDim2.new(0, 17, 0, 17),
        BackgroundColor3 = self.Window.Colors.White,
        BorderSizePixel = 0,
    }, switch)
    addCorner(knob, 20)
    create("UIStroke", { Color = self.Window.Colors.White, Transparency = 0.65, Thickness = 1 }, knob)

    local function setState(value, silent)
        state = not not value
        playTween(switch, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundColor3 = state and self.Window.AccentColor or self.Window.Colors.Off,
        })
        playTween(knob, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Position = UDim2.new(0, state and 32 or 12, 0.5, 0),
        })
        if not silent then
            safeCallback(config.Callback, state)
        end
    end

    addInteractive(hitbox, self.Window, stroke)
    addConnection(self.Window, hitbox.Activated, function()
        setState(not state, false)
    end)
    attachTooltip(hitbox, self.Window, config.Tooltip)

    return {
        Instance = card,
        Get = function()
            return state
        end,
        Set = function(_, value, silent)
            setState(value, silent == true)
        end,
    }
end

function TabMethods:AddSlider(config)
    config = config or {}
    local minimum = tonumber(config.Min) or 0
    local maximum = tonumber(config.Max) or 100
    if maximum < minimum then
        minimum, maximum = maximum, minimum
    end
    if maximum == minimum then
        maximum = minimum + 1
    end
    local step = math.abs(tonumber(config.Step) or 1)
    if step == 0 then
        step = 1
    end

    local decimals = config.Decimals
    if decimals == nil then
        decimals = ((step % 1) == 0 and (minimum % 1) == 0 and (maximum % 1) == 0) and 0 or 2
    end

    local card, stroke = makeCard(self.Page, 76, self.Window)
    local value = math.clamp(tonumber(config.Default) or minimum, minimum, maximum)
    local title = createText(card, config.Name or "Slider", 13, self.Window.Colors.Text, {
        Position = UDim2.new(0, 14, 0, 5),
        Size = UDim2.new(1, -100, 0, 24),
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local valueLabel = createText(card, formatNumber(value, decimals), 12, self.Window.AccentColor, {
        Position = UDim2.new(1, -90, 0, 5),
        Size = UDim2.new(0, 76, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamBold,
    })

    local track = create("Frame", {
        Name = "SliderTrack",
        Active = true,
        Position = UDim2.new(0, 14, 0, 48),
        Size = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = self.Window.Colors.Off,
        BorderSizePixel = 0,
    }, card)
    addCorner(track, 8)

    local alpha = (value - minimum) / (maximum - minimum)
    local fill = create("Frame", {
        Name = "SliderFill",
        Size = UDim2.new(alpha, 0, 1, 0),
        BackgroundColor3 = self.Window.AccentColor,
        BorderSizePixel = 0,
    }, track)
    addCorner(fill, 8)

    local knob = create("Frame", {
        Name = "SliderKnob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(alpha, 0, 0.5, 0),
        Size = UDim2.new(0, 15, 0, 15),
        BackgroundColor3 = self.Window.Colors.White,
        BorderSizePixel = 0,
    }, track)
    addCorner(knob, 12)
    addStroke(knob, self.Window.AccentColor, 0.15, 1)

    local function setValue(newValue, fireCallback)
        newValue = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
        newValue = minimum + math.floor(((newValue - minimum) / step) + 0.5) * step
        newValue = math.clamp(newValue, minimum, maximum)
        value = newValue
        local newAlpha = (value - minimum) / (maximum - minimum)
        valueLabel.Text = formatNumber(value, decimals)
        playTween(fill, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            Size = UDim2.new(newAlpha, 0, 1, 0),
        })
        playTween(knob, 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Position = UDim2.new(newAlpha, 0, 0.5, 0),
        })
        if fireCallback then
            safeCallback(config.Callback, value)
        end
    end

    local dragging = false
    local activeTouch = nil
    local function updateFromX(x)
        if not track.Parent or track.AbsoluteSize.X <= 0 then
            return
        end
        local fraction = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setValue(minimum + (maximum - minimum) * fraction, true)
    end

    addConnection(self.Window, track.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
            updateFromX(input.Position.X)
            playTween(knob, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Size = UDim2.new(0, 18, 0, 18),
            })
        end
    end)

    addConnection(self.Window, UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or (activeTouch and input == activeTouch) then
            updateFromX(input.Position.X)
        end
    end)

    addConnection(self.Window, UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or (activeTouch and input == activeTouch)
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            activeTouch = nil
            if knob.Parent then
                playTween(knob, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, 15, 0, 15),
                })
            end
        end
    end)

    addConnection(self.Window, track.MouseEnter, function()
        playTween(stroke, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 0.48 })
    end)
    addConnection(self.Window, track.MouseLeave, function()
        playTween(stroke, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 0.82 })
    end)
    attachTooltip(card, self.Window, config.Tooltip)

    return {
        Instance = card,
        Get = function()
            return value
        end,
        Set = function(_, newValue, silent)
            setValue(newValue, silent ~= true)
        end,
    }
end

function TabMethods:AddDropdown(config)
    config = config or {}
    local options = config.Options or {}
    local selected = config.Default
    local optionStrings = {}
    for _, option in ipairs(options) do
        table.insert(optionStrings, tostring(option))
    end
    if selected == nil and #optionStrings > 0 then
        selected = optionStrings[1]
    else
        selected = selected ~= nil and tostring(selected) or "Select an option"
    end

    local card, stroke = makeCard(self.Page, 50, self.Window)
    card.Name = "DropdownCard"
    local header = create("TextButton", {
        Name = "DropdownHeader",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)

    createText(card, config.Name or "Dropdown", 13, self.Window.Colors.Text, {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.48, -10, 0, 50),
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local selectedLabel = createText(card, selected, 12, self.Window.AccentColor, {
        Position = UDim2.new(0.48, 0, 0, 0),
        Size = UDim2.new(0.52, -35, 0, 50),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local arrow = create("Frame", {
        Name = "DropdownChevron",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -22, 0, 25),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, card)
    local chevronLeft = create("Frame", {
        Name = "ChevronLeft",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(5, 6),
        Size = UDim2.fromOffset(7, 2),
        Rotation = 45,
        BackgroundColor3 = self.Window.Colors.Muted,
        BorderSizePixel = 0,
    }, arrow)
    addCorner(chevronLeft, 1)
    local chevronRight = create("Frame", {
        Name = "ChevronRight",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(9, 6),
        Size = UDim2.fromOffset(7, 2),
        Rotation = -45,
        BackgroundColor3 = self.Window.Colors.Muted,
        BorderSizePixel = 0,
    }, arrow)
    addCorner(chevronRight, 1)

    local shownCount = math.min(#optionStrings, 5)
    local optionsHeight = shownCount * 30 + math.max(0, shownCount - 1) * 4
    local optionsScroll = create("ScrollingFrame", {
        Name = "OptionsList",
        Position = UDim2.new(0, 8, 0, 50),
        Size = UDim2.new(1, -16, 0, optionsHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Window.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    }, card)

    local optionsLayout = create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, optionsScroll)
    addConnection(self.Window, optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if optionsScroll.Parent then
            optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 2)
        end
    end)

    local expanded = false
    local optionButtons = {}
    local function setExpanded(value)
        expanded = value
        if expanded then
            optionsScroll.Visible = true
            playTween(arrow, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Rotation = 180 })
            playTween(card, 0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                Size = UDim2.new(1, -2, 0, 58 + optionsHeight),
            })
        else
            playTween(arrow, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Rotation = 0 })
            local closeTween = playTween(card, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Size = UDim2.new(1, -2, 0, 50),
            })
            if closeTween then
                closeTween.Completed:Connect(function()
                    if not expanded and optionsScroll.Parent then
                        optionsScroll.Visible = false
                    end
                end)
            else
                optionsScroll.Visible = false
            end
        end
    end

    local function chooseOption(option)
        selected = option
        selectedLabel.Text = option
        setExpanded(false)
        safeCallback(config.Callback, selected)
    end

    for index, option in ipairs(optionStrings) do
        local selectedOption = option
        local optionIndex = index
        local optionButton = create("TextButton", {
            Name = "Option_" .. tostring(optionIndex),
            Size = UDim2.new(1, -4, 0, 30),
            BackgroundColor3 = self.Window.Colors.CardHover,
            BackgroundTransparency = 0.42,
            BorderSizePixel = 0,
            Text = selectedOption,
            TextColor3 = self.Window.Colors.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextTruncate = Enum.TextTruncate.AtEnd,
            AutoButtonColor = false,
            LayoutOrder = index,
        }, optionsScroll)
        addCorner(optionButton, 8)
        addInteractive(optionButton, self.Window)
        addConnection(self.Window, optionButton.Activated, function()
            chooseOption(selectedOption)
        end)
        table.insert(optionButtons, optionButton)
    end

    addInteractive(header, self.Window, stroke)
    addConnection(self.Window, header.Activated, function()
        setExpanded(not expanded)
    end)
    attachTooltip(header, self.Window, config.Tooltip)

    return {
        Instance = card,
        Get = function()
            return selected
        end,
        Set = function(_, newValue, silent)
            selected = tostring(newValue)
            selectedLabel.Text = selected
            setExpanded(false)
            if not silent then
                safeCallback(config.Callback, selected)
            end
        end,
    }
end


-- AddTooltip can be attached to any GUI object without requiring special fonts or glyphs.
attachTooltip = function(target, window, tooltipText)
    if not tooltipText or tostring(tooltipText) == "" or not target or not window then
        return
    end
    local tooltip = create("Frame", {
        Name = "NovaTooltip",
        Size = UDim2.fromOffset(230, 34),
        BackgroundColor3 = window.Colors.Card,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 240,
    }, window._screenGui)
    addCorner(tooltip, 9)
    addStroke(tooltip, window.AccentColor, 0.38, 1)
    createText(tooltip, tostring(tooltipText), 11, window.Colors.Text, {
        Name = "TooltipText",
        Position = UDim2.new(0, 10, 0, 2),
        Size = UDim2.new(1, -20, 1, -4),
        TextWrapped = true,
        Font = Enum.Font.Gotham,
        ZIndex = 241,
    })

    local function positionTooltip(position)
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local x = math.clamp(position.X + 14, 8, math.max(8, viewport.X - 238))
        local y = math.clamp(position.Y + 14, 8, math.max(8, viewport.Y - 42))
        tooltip.Position = UDim2.fromOffset(x, y)
    end

    addConnection(window, target.MouseEnter, function()
        if window._destroyed then return end
        positionTooltip(UserInputService:GetMouseLocation())
        tooltip.Visible = true
        tooltip.BackgroundTransparency = 0.35
        playTween(tooltip, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            BackgroundTransparency = 0.08,
        })
    end)
    addConnection(window, target.MouseLeave, function()
        tooltip.Visible = false
    end)
    addConnection(window, UserInputService.InputChanged, function(input)
        if tooltip.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
            positionTooltip(input.Position)
        end
    end)
end

function TabMethods:AddParagraph(config)
    if type(config) == "string" then
        config = { Content = config }
    end
    config = config or {}
    local heading = tostring(config.Title or config.Name or "")
    local content = tostring(config.Content or config.Text or "")
    local height = tonumber(config.Height) or math.clamp(36 + math.ceil(#content / 58) * 15 + (heading ~= "" and 20 or 0), 54, 180)
    local card = makeCard(self.Page, height, self.Window)
    card.BackgroundTransparency = 0.36
    if heading ~= "" then
        createText(card, heading, 13, self.Window.Colors.Text, {
            Name = "ParagraphTitle",
            Position = UDim2.new(0, 13, 0, 6),
            Size = UDim2.new(1, -26, 0, 22),
            Font = Enum.Font.GothamBold,
        })
    end
    createText(card, content, 12, self.Window.Colors.Muted, {
        Name = "ParagraphContent",
        Position = UDim2.new(0, 13, 0, heading ~= "" and 29 or 7),
        Size = UDim2.new(1, -26, 1, heading ~= "" and -35 or -14),
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    attachTooltip(card, self.Window, config.Tooltip)
    return { Instance = card }
end

function TabMethods:AddTextBox(config)
    config = config or {}
    local multiline = config.Multiline == true or config.MultiLine == true
    local height = multiline and (tonumber(config.Height) or 104) or 58
    local card, stroke = makeCard(self.Page, height, self.Window)
    local titleHeight = multiline and 25 or height
    createText(card, config.Name or "Text input", 13, self.Window.Colors.Text, {
        Name = "TextBoxTitle",
        Position = UDim2.new(0, 13, 0, multiline and 5 or 0),
        Size = UDim2.new(1, -26, 0, titleHeight),
        Font = Enum.Font.GothamMedium,
    })
    local textBox = create("TextBox", {
        Name = "TextInput",
        Position = UDim2.new(0, 12, 0, multiline and 32 or 10),
        Size = multiline and UDim2.new(1, -24, 1, -42) or UDim2.new(0.52, -8, 0, 36),
        AnchorPoint = multiline and Vector2.new(0, 0) or Vector2.new(1, 0.5),
        BackgroundColor3 = self.Window.Colors.BackgroundLight,
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
        ClearTextOnFocus = config.ClearOnFocus == true,
        MultiLine = multiline,
        Text = tostring(config.Default or ""),
        PlaceholderText = tostring(config.Placeholder or "Enter text..."),
        PlaceholderColor3 = self.Window.Colors.Muted,
        TextColor3 = self.Window.Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        TextWrapped = multiline,
    }, card)
    if not multiline then
        textBox.Position = UDim2.new(1, -12, 0.5, 0)
        textBox.Size = UDim2.new(0.53, -10, 0, 34)
    end
    addCorner(textBox, 9)
    addStroke(textBox, self.Window.Colors.Outline, 0.78, 1)
    addConnection(self.Window, textBox.FocusLost, function(enterPressed)
        if config.FireOnFocusLost ~= false then
            safeCallback(config.Callback, textBox.Text, enterPressed)
        end
    end)
    attachTooltip(textBox, self.Window, config.Tooltip)
    return {
        Instance = card,
        TextBox = textBox,
        Get = function() return textBox.Text end,
        Set = function(_, value, fireCallback)
            textBox.Text = tostring(value or "")
            if fireCallback then safeCallback(config.Callback, textBox.Text, false) end
        end,
    }
end

local function normalizeKeyCode(value)
    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
        return value
    end
    if type(value) == "string" then
        return Enum.KeyCode[value]
    end
    return nil
end

function TabMethods:AddKeybind(config)
    config = config or {}
    local card, stroke = makeCard(self.Page, 54, self.Window)
    local keyCode = normalizeKeyCode(config.Default) or Enum.KeyCode.Unknown
    local listening = false
    createText(card, config.Name or "Keybind", 13, self.Window.Colors.Text, {
        Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local hitbox = create("TextButton", {
        Name = "KeybindButton",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(90, 32),
        BackgroundColor3 = self.Window.Colors.BackgroundLight,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Text = keyCode == Enum.KeyCode.Unknown and "None" or keyCode.Name,
        TextColor3 = self.Window.Colors.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, card)
    addCorner(hitbox, 9)
    local keyStroke = addStroke(hitbox, self.Window.Colors.Outline, 0.72, 1)

    addInteractive(hitbox, self.Window, keyStroke)
    addConnection(self.Window, hitbox.Activated, function()
        listening = true
        self.Window._listeningKeybind = true
        hitbox.Text = "Press a key..."
        playTween(keyStroke, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            Color = self.Window.AccentColor,
            Transparency = 0.18,
        })
    end)
    addConnection(self.Window, UserInputService.InputBegan, function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    listening = false
                    self.Window._listeningKeybind = false
                    hitbox.Text = keyCode == Enum.KeyCode.Unknown and "None" or keyCode.Name
                else
                    keyCode = input.KeyCode
                    listening = false
                    self.Window._listeningKeybind = false
                    hitbox.Text = keyCode.Name
                    safeCallback(config.Callback, keyCode)
                end
                playTween(keyStroke, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Color = self.Window.Colors.Outline,
                    Transparency = 0.72,
                })
            end
            return
        end
        if self.Window._listeningKeybind or gameProcessed or UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and keyCode ~= Enum.KeyCode.Unknown and input.KeyCode == keyCode then
            safeCallback(config.Callback, keyCode)
        end
    end)
    attachTooltip(hitbox, self.Window, config.Tooltip)
    return {
        Instance = card,
        Get = function() return keyCode end,
        Set = function(_, value, silent)
            keyCode = normalizeKeyCode(value) or Enum.KeyCode.Unknown
            hitbox.Text = keyCode == Enum.KeyCode.Unknown and "None" or keyCode.Name
            if not silent then safeCallback(config.Callback, keyCode) end
        end,
    }
end

function TabMethods:AddColorPicker(config)
    config = config or {}
    local initial = typeof(config.Default) == "Color3" and config.Default or Color3.fromRGB(104, 190, 255)
    local r = math.floor(initial.R * 255 + 0.5)
    local g = math.floor(initial.G * 255 + 0.5)
    local b = math.floor(initial.B * 255 + 0.5)
    local currentColor = Color3.fromRGB(r, g, b)
    local card, stroke = makeCard(self.Page, 52, self.Window)
    card.Name = "ColorPickerCard"
    local header = create("TextButton", {
        Name = "ColorPickerHeader",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)
    createText(card, config.Name or "Color", 13, self.Window.Colors.Text, {
        Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.new(1, -82, 0, 52),
        Font = Enum.Font.GothamMedium,
    })
    local swatch = create("Frame", {
        Name = "ColorPreview",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0, 26),
        Size = UDim2.fromOffset(32, 24),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
    }, card)
    addCorner(swatch, 7)
    addStroke(swatch, self.Window.Colors.White, 0.45, 1)

    local expanded = false
    local channelControls = {}
    local function syncColor(fireCallback)
        currentColor = Color3.fromRGB(r, g, b)
        swatch.BackgroundColor3 = currentColor
        if fireCallback then safeCallback(config.Callback, currentColor) end
    end
    local function setExpanded(value)
        expanded = value
        local targetHeight = expanded and 145 or 52
        playTween(card, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Size = UDim2.new(1, -2, 0, targetHeight),
        })
        for _, control in ipairs(channelControls) do
            control.Row.Visible = expanded
        end
    end

    local channelNames = { "R", "G", "B" }
    local initialValues = { r, g, b }
    for index, name in ipairs(channelNames) do
        local channelIndex = index
        local rowY = 55 + (channelIndex - 1) * 28
        local row = create("Frame", {
            Name = "Channel_" .. name,
            Position = UDim2.new(0, 10, 0, rowY),
            Size = UDim2.new(1, -20, 0, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
        }, card)
        createText(row, name, 11, self.Window.Colors.Muted, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.fromOffset(22, 22),
            Font = Enum.Font.GothamBold,
        })
        local track = create("Frame", {
            Name = "ChannelTrack",
            Active = true,
            Position = UDim2.new(0, 26, 0.5, -3),
            Size = UDim2.new(1, -65, 0, 6),
            BackgroundColor3 = self.Window.Colors.Off,
            BorderSizePixel = 0,
        }, row)
        addCorner(track, 5)
        local value = initialValues[channelIndex]
        local fill = create("Frame", {
            Name = "ChannelFill",
            Size = UDim2.new(value / 255, 0, 1, 0),
            BackgroundColor3 = self.Window.AccentColor,
            BorderSizePixel = 0,
        }, track)
        addCorner(fill, 5)
        local number = createText(row, tostring(value), 10, self.Window.Colors.Text, {
            Position = UDim2.new(1, -32, 0, 0),
            Size = UDim2.fromOffset(30, 22),
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.Gotham,
        })
        local control = { Row = row, Track = track, Fill = fill, ValueLabel = number, Value = value, Index = channelIndex }
        table.insert(channelControls, control)

        local function updateFromX(x)
            if not track.Parent or track.AbsoluteSize.X <= 0 then return end
            local amount = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local newValue = math.floor(amount * 255 + 0.5)
            control.Value = newValue
            number.Text = tostring(newValue)
            playTween(fill, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Size = UDim2.new(newValue / 255, 0, 1, 0),
            })
            if channelIndex == 1 then r = newValue elseif channelIndex == 2 then g = newValue else b = newValue end
            syncColor(true)
        end
        local activeTouch = nil
        local dragging = false
        addConnection(self.Window, track.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                activeTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
                updateFromX(input.Position.X)
            end
        end)
        addConnection(self.Window, UserInputService.InputChanged, function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or (activeTouch and input == activeTouch) then
                updateFromX(input.Position.X)
            end
        end)
        addConnection(self.Window, UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                activeTouch = nil
            end
        end)
    end

    addInteractive(header, self.Window, stroke)
    addConnection(self.Window, header.Activated, function() setExpanded(not expanded) end)
    attachTooltip(header, self.Window, config.Tooltip)
    return {
        Instance = card,
        Get = function() return currentColor end,
        Set = function(_, value, silent)
            if typeof(value) ~= "Color3" then return end
            r = math.floor(value.R * 255 + 0.5)
            g = math.floor(value.G * 255 + 0.5)
            b = math.floor(value.B * 255 + 0.5)
            for _, control in ipairs(channelControls) do
                local channelValue = control.Index == 1 and r or (control.Index == 2 and g or b)
                control.Value = channelValue
                control.ValueLabel.Text = tostring(channelValue)
                playTween(control.Fill, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Size = UDim2.new(channelValue / 255, 0, 1, 0),
                })
            end
            syncColor(not silent)
        end,
    }
end


function NovaUI:CreateWindow(config)
    config = config or {}
    local player = Players.LocalPlayer
    assert(player, "NovaUI:CreateWindow must be called from a client LocalScript")

    local playerGui = player:WaitForChild("PlayerGui")
    local guiName = config.GuiName or "NovaUI"
    local existing = playerGui:FindFirstChild(guiName)
    if existing then
        existing:Destroy()
    end

    local palette = copyTheme(config.Theme or "Dark")
    local accent = config.AccentColor
    if typeof(accent) ~= "Color3" then
        accent = palette.Accent or Color3.fromRGB(104, 190, 255)
    end
    palette.Accent = accent

    local desiredWidth = math.max(280, tonumber(config.Width) or 650)
    local desiredHeight = math.max(220, tonumber(config.Height) or 450)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local width = math.min(desiredWidth, math.max(280, viewport.X - 24))
    local height = math.min(desiredHeight, math.max(220, viewport.Y - 24))

    local screenGui = create("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = tonumber(config.DisplayOrder) or 50,
    }, playerGui)
    screenGui:SetAttribute("NovaReducedMotion", config.ReducedMotion == true)

    local root = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = palette.Background,
        BackgroundTransparency = 0.14,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, screenGui)
    addCorner(root, 16)
    local rootStroke = addStroke(root, accent, 0.28, 1.2)
    create("UIGradient", {
        Name = "WindowGradient",
        Rotation = 25,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, palette.BackgroundLight),
            ColorSequenceKeypoint.new(0.52, palette.Background),
            ColorSequenceKeypoint.new(1, palette.Card),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.03),
            NumberSequenceKeypoint.new(1, 0.13),
        }),
    }, root)

    local rootScale = create("UIScale", { Scale = 0.9 }, root)
    local glint = create("Frame", {
        Name = "GlassHighlight",
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -32, 0, 2),
        BackgroundColor3 = palette.White,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    }, root)
    create("UIGradient", {
        Name = "GlassGlintGradient",
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(0.5, palette.White),
            ColorSequenceKeypoint.new(1, accent),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(0.5, 0.12),
            NumberSequenceKeypoint.new(1, 0.85),
        }),
    }, glint)

    local topbarHeight = 57
    local topbar = create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, topbarHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
    }, root)

    local logoValue, logoType = normalizeLogo(config.Logo, config.LogoType)
    local hasLogo = logoValue ~= nil
    local logoFrame = nil
    if hasLogo then
        logoFrame = createLogoVisual(topbar, logoValue, logoType, 30, palette)
        logoFrame.Position = UDim2.new(0, 15, 0.5, 0)
        logoFrame.AnchorPoint = Vector2.new(0, 0.5)
    end

    local titleX = hasLogo and 54 or 18
    local titleRightPadding = hasLogo and -164 or -128
    local titleLabel = createText(topbar, config.Title or "NovaUI", 16, palette.Text, {
        Name = "Title",
        Position = UDim2.new(0, titleX, 0, config.Subtitle and 5 or 0),
        Size = UDim2.new(1, titleRightPadding, 0, config.Subtitle and 27 or topbarHeight),
        Font = Enum.Font.GothamBold,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local subtitleLabel = createText(topbar, config.Subtitle or "LIQUID GLASS INTERFACE", 10, palette.Muted, {
        Name = "Subtitle",
        Position = UDim2.new(0, hasLogo and 55 or 19, 0, 31),
        Size = UDim2.new(1, hasLogo and -170 or -135, 0, 17),
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    if not config.Subtitle then subtitleLabel.Visible = false end

    local function createIconButton(name, rightOffset)
        local button = create("TextButton", {
            Name = name,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, rightOffset, 0.5, 0),
            Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = palette.CardHover,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, topbar)
        addCorner(button, 9)
        local stroke = addStroke(button, palette.Outline, 0.7, 1)
        return button, stroke
    end

    local closeButton, closeStroke = createIconButton("CloseButton", -12)
    for _, rotation in ipairs({ 45, -45 }) do
        create("Frame", {
            Name = "CloseLine",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(12, 2),
            Rotation = rotation,
            BackgroundColor3 = palette.Text,
            BorderSizePixel = 0,
        }, closeButton)
    end

    local squareCollapseButton, squareStroke = createIconButton("SquareCollapseButton", -44)
    local squareOutline = create("Frame", {
        Name = "SquareCollapseGlyph",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, squareCollapseButton)
    addStroke(squareOutline, palette.Text, 0.12, 1.4)

    local barCollapseButton, barStroke = createIconButton("BarCollapseButton", -76)
    create("Frame", {
        Name = "BarCollapseGlyph",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 2),
        BackgroundColor3 = palette.Text,
        BorderSizePixel = 0,
    }, barCollapseButton)

    local compactSize = math.clamp(tonumber(config.CompactSize) or 58, 48, 76)
    local squareRestoreButton = create("TextButton", {
        Name = "SquareRestoreButton",
        Size = UDim2.fromScale(1, 1),        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 20,
    }, root)
    if hasLogo then
        createLogoVisual(squareRestoreButton, logoValue, logoType, math.floor(compactSize * 0.56), palette)
    else
        local glyph = create("Frame", {
            Name = "RestoreGlyph",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, squareRestoreButton)
        for _, item in ipairs({
            {0, 0, 6, 2}, {0, 0, 2, 6}, {10, 0, 6, 2}, {14, 0, 2, 6},
            {0, 14, 6, 2}, {0, 10, 2, 6}, {10, 14, 6, 2}, {14, 10, 2, 6},
        }) do
            create("Frame", {
                Position = UDim2.fromOffset(item[1], item[2]),
                Size = UDim2.fromOffset(item[3], item[4]),
                BackgroundColor3 = palette.Text,
                BorderSizePixel = 0,
            }, glyph)
        end
    end

    local headerDivider = create("Frame", {
        Name = "HeaderDivider",
        Position = UDim2.new(0, 14, 0, topbarHeight),
        Size = UDim2.new(1, -28, 0, 1),
        BackgroundColor3 = palette.Outline,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
    }, root)

    local sidebarWidth = width < 480 and 104 or 142
    local contentLeft = sidebarWidth + 20
    local sidebar = create("Frame", {
        Name = "Sidebar",
        Position = UDim2.new(0, 12, 0, 68),
        Size = UDim2.new(0, sidebarWidth, 1, -80),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, root)
    local tabList = create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, sidebar)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 4),
    }, tabList)
    create("UIListLayout", {
        Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, contentLeft, 0, 66),
        Size = UDim2.new(1, -(contentLeft + 12), 1, -76),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, root)

    local window = setmetatable({
        _screenGui = screenGui,
        _root = root,
        _rootScale = rootScale,
        _rootStroke = rootStroke,
        _titleLabel = titleLabel,
        _subtitleLabel = subtitleLabel,
        _hasSubtitle = config.Subtitle ~= nil and config.Subtitle ~= "",
        _logoFrame = logoFrame,
        _logoConfig = hasLogo and { Value = logoValue, Type = logoType } or nil,
        _topbar = topbar,
        _topbarHeight = topbarHeight,
        _closeButton = closeButton,
        _barCollapseButton = barCollapseButton,
        _squareCollapseButton = squareCollapseButton,
        _squareRestoreButton = squareRestoreButton,
        _compactSize = compactSize,
        _expandedSize = UDim2.fromOffset(width, height),
        _expandedPosition = root.Position,
        _tabList = tabList,
        _content = content,
        _sidebar = sidebar,
        _headerDivider = headerDivider,
        _tabs = {},
        _connections = {},
        _notifications = {},
        _destroyed = false,
        _closing = false,
        _hidden = false,
        _collapseMode = nil,
        _squareWasDragged = false,
        AccentColor = accent,
        Colors = palette,
        Theme = normalizeThemeName(config.Theme or "Dark"),
        ToggleKey = config.ToggleKey == nil and Enum.KeyCode.RightControl or config.ToggleKey,
        ReducedMotion = config.ReducedMotion == true,
        _lastThemeAccent = accent,
    }, WindowMethods)

    if type(window.ToggleKey) == "string" then
        window.ToggleKey = Enum.KeyCode[window.ToggleKey]
    end

    -- Register window actions after the window instance exists so every connection is cleaned up.
    local function registerInteractive(button, stroke)
        addInteractive(button, window, stroke)
    end
    registerInteractive(closeButton, closeStroke)
    registerInteractive(squareCollapseButton, squareStroke)
    registerInteractive(barCollapseButton, barStroke)
    addInteractive(squareRestoreButton, window)
    addConnection(window, closeButton.Activated, function() window:Close() end)
    addConnection(window, squareCollapseButton.Activated, function() window:CollapseToSquare() end)
    addConnection(window, barCollapseButton.Activated, function() window:ToggleBarCollapse() end)
    addConnection(window, squareRestoreButton.Activated, function()
        if window._squareWasDragged then
            window._squareWasDragged = false
            return
        end
        window:Expand()
    end)

    -- Dragging supports mouse and touch in all modes, including the compact icon.
    -- Only commit a drag after a small threshold so taps still activate controls.
    local dragging = false
    local dragMoved = false
    local dragStart = nil
    local startPosition = nil
    local startExpandedPosition = nil
    local dragMode = nil
    local DRAG_THRESHOLD = 5

    local function beginDrag(input, source)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if source == "square" and window._collapseMode ~= "square" then return end
        if source == "window" and window._collapseMode == "square" then return end
        if UserInputService:GetFocusedTextBox() then return end

        if source == "window" then
            local relativeX = input.Position.X - root.AbsolutePosition.X
            -- Keep the three action buttons clickable without starting a drag.
            if relativeX >= root.AbsoluteSize.X - 110 then return end
        end

        dragging = true
        dragMoved = false
        dragStart = input.Position
        startPosition = root.Position
        startExpandedPosition = window._expandedPosition or root.Position
        dragMode = source
    end

    addConnection(window, topbar.InputBegan, function(input)
        beginDrag(input, "window")
    end)
    addConnection(window, squareRestoreButton.InputBegan, function(input)
        beginDrag(input, "square")
    end)

    addConnection(window, UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        if not dragMoved and delta.Magnitude < DRAG_THRESHOLD then
            return
        end
        dragMoved = true
        local offset = UDim2.fromOffset(delta.X, delta.Y)
        local nextPosition = startPosition + offset
        root.Position = nextPosition

        if dragMode == "square" then
            -- Move the future expanded window by the same delta as the square icon.
            window._expandedPosition = startExpandedPosition + offset
            window._squareWasDragged = true
        elseif window._collapseMode == "bar" then
            local restoreOffset = math.max(0, (window._expandedSize.Y.Offset - topbarHeight) / 2)
            window._expandedPosition = nextPosition + UDim2.fromOffset(0, restoreOffset)
        elseif window._collapseMode ~= "square" then
            window._expandedPosition = nextPosition
        end
    end)

    addConnection(window, UserInputService.InputEnded, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local wasMoved = dragMoved
        local finishedMode = dragMode
        dragging = false
        dragStart = nil
        startPosition = nil
        startExpandedPosition = nil
        dragMode = nil
        dragMoved = false

        -- Don't rewrite the saved position after a simple click. This prevents the
        -- previous position drift caused by button clicks being mistaken for drags.
        if wasMoved and finishedMode == "window" then
            if window._collapseMode == "bar" then
                local restoreOffset = math.max(0, (window._expandedSize.Y.Offset - topbarHeight) / 2)
                window._expandedPosition = root.Position + UDim2.fromOffset(0, restoreOffset)
            elseif window._collapseMode ~= "square" then
                window._expandedPosition = root.Position
            end
        elseif wasMoved and finishedMode == "square" then
            -- Some Roblox clients do not fire Activated after a drag; clear this guard
            -- shortly afterward in either case, while allowing Activated to ignore drag-release.
            task.delay(0.24, function()
                if window and not window._destroyed then
                    window._squareWasDragged = false
                end
            end)
        end
    end)

    addConnection(window, UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed or UserInputService:GetFocusedTextBox() or window._listeningKeybind then return end
        if window.ToggleKey and typeof(window.ToggleKey) == "EnumItem"
            and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == window.ToggleKey then
            window:SetVisible(window._hidden == true)
        end
    end)

    if camera then
        addConnection(window, camera:GetPropertyChangedSignal("ViewportSize"), function()
            if window._destroyed then return end
            local viewportNow = camera.ViewportSize
            local resizedWidth = math.min(desiredWidth, math.max(280, viewportNow.X - 24))
            local resizedHeight = math.min(desiredHeight, math.max(220, viewportNow.Y - 24))
            window._expandedSize = UDim2.fromOffset(resizedWidth, resizedHeight)
            local responsiveSidebarWidth = resizedWidth < 480 and 104 or 142
            sidebar.Size = UDim2.new(0, responsiveSidebarWidth, 1, -80)
            content.Position = UDim2.new(0, responsiveSidebarWidth + 20, 0, 66)
            content.Size = UDim2.new(1, -(responsiveSidebarWidth + 32), 1, -76)
            if not window._collapseMode then
                root.Size = window._expandedSize
            elseif window._collapseMode == "bar" then
                root.Size = UDim2.new(0, resizedWidth, 0, topbarHeight)
            end
        end)
    end

    -- Useful runtime theme and accent methods start from the selected palette.
    if normalizeThemeName(config.Theme or "Dark") ~= "Dark" then
        window:SetTheme(config.Theme)
    end
    window:SetReducedMotion(config.ReducedMotion == true)
    playTween(rootScale, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
    playTween(rootStroke, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 0.18 })
    playTween(glint, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.1 })
    return window
end

function NovaUI:Notify(window, config, message, duration)
    assert(window and typeof(window.Notify) == "function", "NovaUI:Notify expects a window returned by CreateWindow")
    return window:Notify(config, message, duration)
end

return NovaUI