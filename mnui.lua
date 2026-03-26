--[[
    MidnightUI Premium v2.0
    - Blur Effect & Shadow Depth
    - Micro-Animations with Bounce & Scale
    - Grid Layout System (2 Columns)
    - Search Bar with Real-time Filter
    - Smooth Loading Animations
    - Tooltip System for Sliders
    - Modern Toggle with Ripple Wave
]]

local MidnightUI = {}
MidnightUI.__index = MidnightUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(8, 8, 12),
    Sidebar = Color3.fromRGB(5, 5, 8),
    Accent = Color3.fromRGB(170, 100, 255),
    AccentLight = Color3.fromRGB(190, 130, 255),
    AccentDark = Color3.fromRGB(130, 70, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 200),
    Element = Color3.fromRGB(18, 18, 24),
    ElementHover = Color3.fromRGB(25, 25, 32),
    Stroke = Color3.fromRGB(80, 70, 100),
    Success = Color3.fromRGB(100, 255, 150),
    CornerRadius = UDim.new(0, 12),
    StrokeTransparency = 0.5,
    BlurIntensity = 12
}

-- Animation Presets
local Easing = {
    Smooth = Enum.EasingStyle.Quad,
    Bounce = Enum.EasingStyle.Back,
    Elastic = Enum.EasingStyle.Elastic,
    Exponential = Enum.EasingStyle.Exponential
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(object, duration, properties, style, direction)
    if not object then return end
    local tweenInfo = TweenInfo.new(duration or 0.4, style or Easing.Exponential, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function TweenSequence(objects, properties, delay, style)
    for i, obj in ipairs(objects) do
        task.delay((i-1) * (delay or 0.03), function()
            if obj and obj.Parent then
                Tween(obj, 0.3, properties, style or Easing.Smooth)
            end
        end)
    end
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerRadius
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Stroke
    stroke.Transparency = transparency or Theme.StrokeTransparency
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function AddGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1 or Theme.Accent),
        ColorSequenceKeypoint.new(1, color2 or Theme.AccentDark)
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

-- Tooltip System
local Tooltip = nil
local function CreateTooltip()
    if Tooltip then return Tooltip end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "TooltipGui"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 80, 0, 28)
    frame.BackgroundColor3 = Theme.Accent
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 999
    frame.Parent = gui
    
    AddCorner(frame, UDim.new(0, 6))
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    Tooltip = {frame = frame, label = label}
    
    return Tooltip
end

local function ShowTooltip(text, position)
    local tooltip = CreateTooltip()
    tooltip.label.Text = text
    tooltip.frame.Position = UDim2.new(0, position.X + 10, 0, position.Y - 30)
    tooltip.frame.Visible = true
    tooltip.frame.BackgroundTransparency = 0.1
    Tween(tooltip.frame, 0.15, {BackgroundTransparency = 0}, Easing.Smooth)
    
    if tooltip.hideConnection then tooltip.hideConnection:Disconnect() end
    tooltip.hideConnection = task.delay(2, function()
        Tween(tooltip.frame, 0.2, {BackgroundTransparency = 1}, Easing.Smooth)
        task.delay(0.2, function()
            if tooltip.frame then tooltip.frame.Visible = false end
        end)
    end)
end

-- Blur Effect
local BlurEffect = nil
local function CreateBlur()
    if BlurEffect then return BlurEffect end
    
    local blur = Instance.new("BlurEffect")
    blur.Name = "MidnightUI_Blur"
    blur.Size = Theme.BlurIntensity
    blur.Enabled = false
    blur.Parent = Lighting
    
    BlurEffect = blur
    return blur
end

-- Dragging System
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Main Library
function MidnightUI:CreateWindow(title, showBlur)
    local Window = {}
    Window.Tabs = {}
    Window.TabButtons = {}
    Window.ActiveTab = nil
    Window.Elements = {}
    
    -- Blur Effect
    if showBlur ~= false then
        local blur = CreateBlur()
        blur.Enabled = true
        Window.Blur = blur
    end
    
    -- Parent Selection
    local parent = nil
    local success, err = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        test:Destroy()
        parent = CoreGui
    end)
    if not success or not parent then
        parent = Player:WaitForChild("PlayerGui")
    end
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MidnightUI_Premium_" .. tostring(math.random(100000, 999999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent
    
    -- Main Frame with Shadow
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    
    AddCorner(MainFrame, UDim.new(0, 12))
    
    -- Gradient Stroke
    local stroke = AddStroke(MainFrame, Theme.Accent, 0.6, 1.5)
    AddGradient(stroke, Theme.Accent, Theme.AccentDark, 45)
    
    -- Outer Shadow (ImageLabel)
    local ShadowImage = Instance.new("ImageLabel")
    ShadowImage.Name = "Shadow"
    ShadowImage.Size = UDim2.new(1, 40, 1, 40)
    ShadowImage.Position = UDim2.new(0, -20, 0, -20)
    ShadowImage.BackgroundTransparency = 1
    ShadowImage.Image = "rbxassetid://7912134082"
    ShadowImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ShadowImage.ImageTransparency = 0.6
    ShadowImage.ScaleType = Enum.ScaleType.Slice
    ShadowImage.SliceCenter = Rect.new(50, 50, 450, 450)
    ShadowImage.ZIndex = -1
    ShadowImage.Parent = MainFrame
    
    -- Top Bar with Gradient
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    AddCorner(TopBar, UDim.new(0, 12))
    AddGradient(TopBar, Color3.fromRGB(10, 10, 15), Color3.fromRGB(5, 5, 10), 0)
    
    -- Title with Glow
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 250, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "MidnightUI"
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 20
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    -- Search Bar
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "Search"
    SearchBox.Size = UDim2.new(0, 200, 0, 32)
    SearchBox.Position = UDim2.new(0.5, -100, 0.5, -16)
    SearchBox.BackgroundColor3 = Theme.Element
    SearchBox.PlaceholderText = "🔍 Search features..."
    SearchBox.PlaceholderColor3 = Theme.TextDark
    SearchBox.TextColor3 = Theme.Text
    SearchBox.TextSize = 12
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = TopBar
    
    AddCorner(SearchBox, UDim.new(0, 8))
    AddStroke(SearchBox, Theme.Accent, 0.5)
    
    -- Control Buttons
    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Size = UDim2.new(0, 80, 0, 32)
    ControlsContainer.Position = UDim2.new(1, -95, 0.5, -16)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = TopBar
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    MinimizeBtn.BackgroundColor3 = Theme.Element
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Theme.Text
    MinimizeBtn.TextSize = 18
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = ControlsContainer
    AddCorner(MinimizeBtn, UDim.new(0, 8))
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(0, 40, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = ControlsContainer
    AddCorner(CloseBtn, UDim.new(0, 8))
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -60)
    Sidebar.Position = UDim2.new(0, 5, 0, 55)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    AddCorner(Sidebar, UDim.new(0, 12))
    AddStroke(Sidebar)
    
    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 3
    TabContainer.ScrollBarImageColor3 = Theme.Accent
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -180, 1, -60)
    ContentContainer.Position = UDim2.new(0, 170, 0, 55)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    AddCorner(ContentContainer, UDim.new(0, 12))
    AddStroke(ContentContainer, Theme.Accent, 0.3)
    
    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -20, 1, -20)
    PageContainer.Position = UDim2.new(0, 10, 0, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentContainer
    
    -- Make draggable
    MakeDraggable(MainFrame, TopBar)
    
    -- Minimize Functionality
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, 0.4, {Size = UDim2.new(0, 700, 0, 50), Position = UDim2.new(0.5, -350, 0.5, -25)})
            Tween(ContentContainer, 0.3, {BackgroundTransparency = 1})
            Tween(Sidebar, 0.3, {BackgroundTransparency = 1})
            task.delay(0.3, function()
                ContentContainer.Visible = false
                Sidebar.Visible = false
            end)
        else
            ContentContainer.Visible = true
            Sidebar.Visible = true
            Tween(ContentContainer, 0.3, {BackgroundTransparency = 0})
            Tween(Sidebar, 0.3, {BackgroundTransparency = 0})
            Tween(MainFrame, 0.4, {Size = UDim2.new(0, 700, 0, 500), Position = UDim2.new(0.5, -350, 0.5, -250)})
        end
    end)
    
    -- Close Functionality
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
        task.delay(0.3, function()
            if Window.Blur then Window.Blur.Enabled = false end
            ScreenGui:Destroy()
        end)
    end)
    
    -- Hover Effects
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, 0.2, {BackgroundColor3 = Theme.ElementHover})
        Tween(MinimizeBtn, 0.2, {Size = UDim2.new(0, 34, 0, 34)}, Easing.Smooth)
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, 0.2, {BackgroundColor3 = Theme.Element})
        Tween(MinimizeBtn, 0.2, {Size = UDim2.new(0, 32, 0, 32)})
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)})
        Tween(CloseBtn, 0.2, {Size = UDim2.new(0, 34, 0, 34)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)})
        Tween(CloseBtn, 0.2, {Size = UDim2.new(0, 32, 0, 32)})
    end)
    
    -- Create Tab Function
    function Window:CreateTab(name, iconID)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.VisibleElements = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 42)
        TabButton.BackgroundColor3 = Theme.Element
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        AddCorner(TabButton, UDim.new(0, 8))
        AddStroke(TabButton)
        
        -- Icon
        local Icon = nil
        if iconID then
            Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(0, 12, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.Image = iconID
            Icon.ImageColor3 = Theme.TextDark
            Icon.Parent = TabButton
        end
        
        -- Tab Name
        local TabName = Instance.new("TextLabel")
        TabName.Size = UDim2.new(1, (iconID and -40 or -15), 1, 0)
        TabName.Position = UDim2.new(0, iconID and 38 or 12, 0, 0)
        TabName.BackgroundTransparency = 1
        TabName.Text = name
        TabName.TextColor3 = Theme.TextDark
        TabName.TextSize = 13
        TabName.Font = Enum.Font.GothamMedium
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.Parent = TabButton
        
        -- Indicator
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.Position = UDim2.new(0, 0, 0.2, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabButton
        AddCorner(Indicator, UDim.new(0, 2))
        
        -- Tab Page with Grid Layout
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 4
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Visible = false
        TabPage.Parent = PageContainer
        
        -- Grid Layout (2 Columns)
        local GridLayout = Instance.new("UIGridLayout")
        GridLayout.CellSize = UDim2.new(0.47, 0, 0, 45)
        GridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        GridLayout.Parent = TabPage
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = TabPage
        
        -- Canvas update
        local function updateCanvasSize()
            local count = 0
            for _, child in pairs(TabPage:GetChildren()) do
                if child:IsA("Frame") and child ~= GridLayout and child ~= PagePadding then
                    count = count + 1
                end
            end
            local rows = math.ceil(count / 2)
            local canvasHeight = rows * 55 + 20
            TabPage.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
        end
        
        GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        
        -- Search filter
        local function filterElements(searchText)
            if searchText == "" then
                for _, element in pairs(Tab.VisibleElements) do
                    if element then element.Visible = true end
                end
                return
            end
            
            local lowerSearch = string.lower(searchText)
            for _, element in pairs(Tab.VisibleElements) do
                if element and element:IsA("Frame") then
                    local label = element:FindFirstChild("Label")
                    local text = label and string.lower(label.Text) or ""
                    local visible = string.find(text, lowerSearch) ~= nil
                    element.Visible = visible
                end
            end
            updateCanvasSize()
        end
        
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            filterElements(SearchBox.Text)
        end)
        
        -- Tab Selection
        local function selectTab()
            for _, child in pairs(PageContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    Tween(child, 0.2, {BackgroundTransparency = 1})
                    task.delay(0.15, function() child.Visible = false end)
                end
            end
            
            for _, btnData in pairs(Window.TabButtons) do
                if btnData.Button then
                    Tween(btnData.Button, 0.2, {BackgroundColor3 = Theme.Element})
                    if btnData.Indicator then
                        Tween(btnData.Indicator, 0.2, {BackgroundTransparency = 1})
                    end
                    if btnData.Text then
                        Tween(btnData.Text, 0.2, {TextColor3 = Theme.TextDark})
                    end
                    if btnData.Icon then
                        Tween(btnData.Icon, 0.2, {ImageColor3 = Theme.TextDark})
                    end
                end
            end
            
            Tween(TabButton, 0.2, {BackgroundColor3 = Theme.ElementHover})
            Tween(Indicator, 0.2, {BackgroundTransparency = 0})
            Tween(TabName, 0.2, {TextColor3 = Theme.Text})
            if Icon then Tween(Icon, 0.2, {ImageColor3 = Theme.Accent}) end
            
            TabPage.Visible = true
            TabPage.BackgroundTransparency = 0
            TabPage.CanvasPosition = 0
            
            -- Animate elements in
            local elements = {}
            for _, child in pairs(TabPage:GetChildren()) do
                if child:IsA("Frame") and child ~= GridLayout and child ~= PagePadding then
                    table.insert(elements, child)
                end
            end
            for i, element in ipairs(elements) do
                element.BackgroundTransparency = 1
                element.Position = UDim2.new(0, 0, 0, -20)
                task.delay(i * 0.03, function()
                    if element and element.Parent then
                        Tween(element, 0.3, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
                    end
                end)
            end
            
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(selectTab)
        if UserInputService.TouchEnabled then
            TabButton.TouchTap:Connect(selectTab)
        end
        
        -- Hover effect with scale
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(TabButton, 0.15, {Size = UDim2.new(1, -8, 0, 44)}, Easing.Smooth)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(TabButton, 0.15, {Size = UDim2.new(1, -10, 0, 42)})
            end
        end)
        
        Window.TabButtons[name] = {
            Button = TabButton,
            Indicator = Indicator,
            Text = TabName,
            Icon = Icon
        }
        Window.Tabs[name] = Tab
        
        if not Window.ActiveTab then
            selectTab()
        end
        
        -- Update tab container canvas
        local function updateTabCanvas()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
        end
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
        task.spawn(function() task.wait(0.1); updateTabCanvas() end)
        
        -- Element Creators
        function Tab:CreateButton(text, callback)
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 45)
            ButtonFrame.BackgroundColor3 = Theme.Element
            ButtonFrame.Text = ""
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Parent = TabPage
            
            AddCorner(ButtonFrame, UDim.new(0, 8))
            AddStroke(ButtonFrame)
            
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Name = "Label"
            ButtonLabel.Size = UDim2.new(1, -40, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 15, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = text
            ButtonLabel.TextColor3 = Theme.Text
            ButtonLabel.TextSize = 13
            ButtonLabel.Font = Enum.Font.GothamMedium
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.Parent = ButtonFrame
            
            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Position = UDim2.new(1, -30, 0.5, -9)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://7072718362"
            Icon.ImageColor3 = Theme.Accent
            Icon.Parent = ButtonFrame
            
            local function onClick()
                Tween(ButtonFrame, 0.08, {Size = UDim2.new(0.98, 0, 0, 43)})
                Tween(ButtonFrame, 0.12, {Size = UDim2.new(1, 0, 0, 45)}, Easing.Bounce)
                callback()
            end
            
            ButtonFrame.MouseButton1Click:Connect(onClick)
            
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(ButtonFrame, 0.15, {Position = UDim2.new(0, -2, 0, -1)}, Easing.Smooth)
                Tween(Icon, 0.2, {ImageColor3 = Theme.Text})
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(ButtonFrame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
                Tween(Icon, 0.2, {ImageColor3 = Theme.Accent})
            end)
            
            table.insert(Tab.VisibleElements, ButtonFrame)
            updateCanvasSize()
            return ButtonFrame
        end
        
        function Tab:CreateToggle(text, default, callback)
            local toggled = default or false
            local rippleFrame = nil
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
            ToggleFrame.BackgroundColor3 = Theme.Element
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabPage
            
            AddCorner(ToggleFrame, UDim.new(0, 8))
            AddStroke(ToggleFrame)
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 50, 0, 26)
            ToggleButton.Position = UDim2.new(1, -60, 0.5, -13)
            ToggleButton.BackgroundColor3 = toggled and Theme.Accent or Theme.Element
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = ToggleFrame
            
            AddCorner(ToggleButton, UDim.new(1, 0))
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
            ToggleCircle.Position = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            ToggleCircle.BackgroundColor3 = Theme.Text
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            AddCorner(ToggleCircle, UDim.new(1, 0))
            
            local function createRipple()
                if rippleFrame then rippleFrame:Destroy() end
                rippleFrame = Instance.new("Frame")
                rippleFrame.Size = UDim2.new(0, 0, 0, 0)
                rippleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                rippleFrame.BackgroundColor3 = Theme.Accent
                rippleFrame.BackgroundTransparency = 0.5
                rippleFrame.BorderSizePixel = 0
                rippleFrame.ZIndex = 2
                rippleFrame.Parent = ToggleButton
                AddCorner(rippleFrame, UDim.new(1, 0))
                
                Tween(rippleFrame, 0.3, {
                    Size = UDim2.new(2, 0, 2, 0),
                    BackgroundTransparency = 1
                })
                task.delay(0.3, function()
                    if rippleFrame then rippleFrame:Destroy() end
                end)
            end
            
            local function toggle()
                toggled = not toggled
                
                if toggled then
                    Tween(ToggleButton, 0.25, {BackgroundColor3 = Theme.Accent})
                    Tween(ToggleCircle, 0.25, {Position = UDim2.new(1, -23, 0.5, -10)})
                else
                    Tween(ToggleButton, 0.25, {BackgroundColor3 = Theme.Element})
                    Tween(ToggleCircle, 0.25, {Position = UDim2.new(0, 3, 0.5, -10)})
                end
                createRipple()
                callback(toggled)
            end
            
            ToggleButton.MouseButton1Click:Connect(toggle)
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle()
                end
            end)
            
            ToggleFrame.MouseEnter:Connect(function()
                Tween(ToggleFrame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(ToggleFrame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            ToggleFrame.MouseLeave:Connect(function()
                Tween(ToggleFrame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(ToggleFrame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            local ToggleObject = {}
            function ToggleObject:Set(value)
                if toggled ~= value then toggle() end
            end
            function ToggleObject:Get() return toggled end
            
            table.insert(Tab.VisibleElements, ToggleFrame)
            updateCanvasSize()
            return ToggleObject
        end
        
        function Tab:CreateSlider(text, min, max, default, callback)
            min = min or 0
            max = max or 100
            local currentValue = math.clamp(default or min, min, max)
            local tooltipActive = false
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 65)
            SliderFrame.BackgroundColor3 = Theme.Element
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabPage
            
            AddCorner(SliderFrame, UDim.new(0, 8))
            AddStroke(SliderFrame)
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Size = UDim2.new(1, -70, 0, 22)
            SliderLabel.Position = UDim2.new(0, 15, 0, 8)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = text
            SliderLabel.TextColor3 = Theme.Text
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 45, 0, 24)
            ValueLabel.Position = UDim2.new(1, -60, 0, 6)
            ValueLabel.BackgroundColor3 = Theme.Accent
            ValueLabel.Text = tostring(currentValue)
            ValueLabel.TextColor3 = Theme.Text
            ValueLabel.TextSize = 11
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Parent = SliderFrame
            AddCorner(ValueLabel, UDim.new(0, 6))
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -30, 0, 6)
            SliderBG.Position = UDim2.new(0, 15, 0, 42)
            SliderBG.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            SliderBG.BorderSizePixel = 0
            SliderBG.Parent = SliderFrame
            AddCorner(SliderBG, UDim.new(1, 0))
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBG
            AddCorner(SliderFill, UDim.new(1, 0))
            
            local SliderCircle = Instance.new("Frame")
            SliderCircle.Size = UDim2.new(0, 18, 0, 18)
            SliderCircle.Position = UDim2.new(1, -9, 0.5, -9)
            SliderCircle.BackgroundColor3 = Theme.Text
            SliderCircle.BorderSizePixel = 0
            SliderCircle.ZIndex = 2
            SliderCircle.Parent = SliderFill
            AddCorner(SliderCircle, UDim.new(1, 0))
            AddStroke(SliderCircle, Theme.Accent, 0, 2)
            
            local dragging = false
            
            local function updateSlider(input)
                local pos = input.Position
                local sliderPos = SliderBG.AbsolutePosition
                local sliderSize = SliderBG.AbsoluteSize
                
                if sliderSize.X > 0 then
                    local relative = math.clamp((pos.X - sliderPos.X) / sliderSize.X, 0, 1)
                    currentValue = math.floor(min + (max - min) * relative)
                    
                    Tween(SliderFill, 0.1, {Size = UDim2.new(relative, 0, 1, 0)})
                    ValueLabel.Text = tostring(currentValue)
                    callback(currentValue)
                    
                    if tooltipActive then
                        ShowTooltip(tostring(currentValue), pos)
                    end
                end
            end
            
            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            SliderBG.InputEnded:Connect(function()
                dragging = false
            end)
            
            SliderBG.MouseEnter:Connect(function()
                tooltipActive = true
            end)
            SliderBG.MouseLeave:Connect(function()
                tooltipActive = false
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            SliderFrame.MouseEnter:Connect(function()
                Tween(SliderFrame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(SliderFrame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            SliderFrame.MouseLeave:Connect(function()
                Tween(SliderFrame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(SliderFrame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            local SliderObject = {}
            function SliderObject:Set(value)
                value = math.clamp(value, min, max)
                currentValue = value
                local relative = (value - min) / (max - min)
                Tween(SliderFill, 0.2, {Size = UDim2.new(relative, 0, 1, 0)})
                ValueLabel.Text = tostring(value)
                callback(value)
            end
            function SliderObject:Get() return currentValue end
            
            table.insert(Tab.VisibleElements, SliderFrame)
            updateCanvasSize()
            return SliderObject
        end
        
        function Tab:CreateDropdown(text, options, default, callback)
            local selected = default or options[1] or "Select..."
            local opened = false
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 45)
            DropdownFrame.BackgroundColor3 = Theme.Element
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabPage
            
            AddCorner(DropdownFrame, UDim.new(0, 8))
            AddStroke(DropdownFrame)
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "Label"
            DropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 15, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = text
            DropdownLabel.TextColor3 = Theme.Text
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.GothamMedium
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0.45, 0, 0, 32)
            DropdownButton.Position = UDim2.new(0.5, 5, 0.5, -16)
            DropdownButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            DropdownButton.Text = selected
            DropdownButton.TextColor3 = Theme.Text
            DropdownButton.TextSize = 12
            DropdownButton.Font = Enum.Font.GothamMedium
            DropdownButton.AutoButtonColor = false
            DropdownButton.Parent = DropdownFrame
            AddCorner(DropdownButton, UDim.new(0, 6))
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -25, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.Accent
            Arrow.TextSize = 10
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Parent = DropdownButton
            
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
            OptionsFrame.Position = UDim2.new(0.5, 5, 1, 5)
            OptionsFrame.BackgroundColor3 = Theme.Element
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.Visible = false
            OptionsFrame.ZIndex = 10
            OptionsFrame.Parent = DropdownFrame
            AddCorner(OptionsFrame, UDim.new(0, 8))
            AddStroke(OptionsFrame, Theme.Accent, 0.5)
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Padding = UDim.new(0, 4)
            OptionsLayout.Parent = OptionsFrame
            
            local function createOption(optionText)
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, -10, 0, 32)
                OptionButton.Position = UDim2.new(0, 5, 0, 0)
                OptionButton.BackgroundColor3 = Theme.Element
                OptionButton.Text = optionText
                OptionButton.TextColor3 = Theme.TextDark
                OptionButton.TextSize = 11
                OptionButton.Font = Enum.Font.GothamMedium
                OptionButton.AutoButtonColor = false
                OptionButton.Parent = OptionsFrame
                AddCorner(OptionButton, UDim.new(0, 6))
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, 0.1, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text})
                end)
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, 0.1, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDark})
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    selected = optionText
                    DropdownButton.Text = optionText
                    opened = false
                    Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 45)})
                    Tween(Arrow, 0.2, {Rotation = 0})
                    OptionsFrame.Visible = false
                    callback(optionText)
                    updateCanvasSize()
                end)
            end
            
            for _, option in ipairs(options) do
                createOption(option)
            end
            
            local function toggleDropdown()
                opened = not opened
                if opened then
                    local optionCount = #options
                    local targetHeight = 45 + 10 + (optionCount * 36) + 10
                    Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, targetHeight)})
                    Tween(Arrow, 0.2, {Rotation = 180})
                    OptionsFrame.Size = UDim2.new(0.45, 0, 0, (optionCount * 36) + 10)
                    OptionsFrame.Visible = true
                else
                    Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 45)})
                    Tween(Arrow, 0.2, {Rotation = 0})
                    task.delay(0.2, function()
                        if not opened then OptionsFrame.Visible = false end
                    end)
                end
                updateCanvasSize()
            end
            
            DropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            DropdownFrame.MouseEnter:Connect(function()
                Tween(DropdownFrame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(DropdownFrame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            DropdownFrame.MouseLeave:Connect(function()
                Tween(DropdownFrame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(DropdownFrame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            local DropdownObject = {}
            function DropdownObject:Set(value)
                if table.find(options, value) then
                    selected = value
                    DropdownButton.Text = value
                    callback(value)
                end
            end
            function DropdownObject:Get() return selected end
            
            table.insert(Tab.VisibleElements, DropdownFrame)
            updateCanvasSize()
            return DropdownObject
        end
        
        function Tab:CreateKeybind(text, default, callback)
            local currentKey = default or Enum.KeyCode.RightShift
            local listening = false
            
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Size = UDim2.new(1, 0, 0, 45)
            KeybindFrame.BackgroundColor3 = Theme.Element
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Parent = TabPage
            
            AddCorner(KeybindFrame, UDim.new(0, 8))
            AddStroke(KeybindFrame)
            
            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Name = "Label"
            KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 15, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = text
            KeybindLabel.TextColor3 = Theme.Text
            KeybindLabel.TextSize = 13
            KeybindLabel.Font = Enum.Font.GothamMedium
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.Parent = KeybindFrame
            
            local KeybindButton = Instance.new("TextButton")
            KeybindButton.Size = UDim2.new(0, 90, 0, 32)
            KeybindButton.Position = UDim2.new(1, -105, 0.5, -16)
            KeybindButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            KeybindButton.Text = currentKey.Name
            KeybindButton.TextColor3 = Theme.Accent
            KeybindButton.TextSize = 12
            KeybindButton.Font = Enum.Font.GothamBold
            KeybindButton.AutoButtonColor = false
            KeybindButton.Parent = KeybindFrame
            AddCorner(KeybindButton, UDim.new(0, 6))
            
            local connection
            KeybindButton.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                KeybindButton.Text = "..."
                Tween(KeybindButton, 0.1, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text})
                
                if connection then connection:Disconnect() end
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
                        listening = false
                        currentKey = input.KeyCode
                        KeybindButton.Text = currentKey.Name
                        Tween(KeybindButton, 0.1, {BackgroundColor3 = Color3.fromRGB(25, 25, 30), TextColor3 = Theme.Accent})
                        if connection then connection:Disconnect() end
                    end
                end)
                
                task.delay(5, function()
                    if listening then
                        listening = false
                        KeybindButton.Text = currentKey.Name
                        Tween(KeybindButton, 0.1, {BackgroundColor3 = Color3.fromRGB(25, 25, 30), TextColor3 = Theme.Accent})
                        if connection then connection:Disconnect() end
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == currentKey then
                    callback(currentKey)
                end
            end)
            
            KeybindFrame.MouseEnter:Connect(function()
                Tween(KeybindFrame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(KeybindFrame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            KeybindFrame.MouseLeave:Connect(function()
                Tween(KeybindFrame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(KeybindFrame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            local KeybindObject = {}
            function KeybindObject:Set(key) currentKey = key; KeybindButton.Text = key.Name end
            function KeybindObject:Get() return currentKey end
            
            table.insert(Tab.VisibleElements, KeybindFrame)
            updateCanvasSize()
            return KeybindObject
        end
        
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 38)
            LabelFrame.BackgroundColor3 = Theme.Accent
            LabelFrame.BackgroundTransparency = 0.85
            LabelFrame.BorderSizePixel = 0
            LabelFrame.Parent = TabPage
            AddCorner(LabelFrame, UDim.new(0, 8))
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Name = "Label"
            LabelText.Size = UDim2.new(1, -20, 1, 0)
            LabelText.Position = UDim2.new(0, 12, 0, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.Text = "✨ " .. text
            LabelText.TextColor3 = Theme.Text
            LabelText.TextSize = 12
            LabelText.Font = Enum.Font.GothamMedium
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.Parent = LabelFrame
            
            local LabelObject = {}
            function LabelObject:Set(newText) LabelText.Text = "✨ " .. newText end
            
            table.insert(Tab.VisibleElements, LabelFrame)
            updateCanvasSize()
            return LabelObject
        end
        
        return Tab
    end
    
    -- Notification System
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
    NotificationContainer.Position = UDim2.new(1, -320, 0, 10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent = ScreenGui
    
    local NotificationLayout = Instance.new("UIListLayout")
    NotificationLayout.Padding = UDim.new(0, 8)
    NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotificationLayout.Parent = NotificationContainer
    
    function Window:Notify(title, message, duration, notifType)
        duration = duration or 3
        notifType = notifType or "Info"
        
        local colors = {
            Info = Theme.Accent,
            Success = Color3.fromRGB(100, 255, 150),
            Warning = Color3.fromRGB(255, 200, 100),
            Error = Color3.fromRGB(255, 100, 100)
        }
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(0, 290, 0, 70)
        NotifFrame.BackgroundColor3 = Theme.Sidebar
        NotifFrame.BackgroundTransparency = 0.1
        NotifFrame.Parent = NotificationContainer
        AddCorner(NotifFrame, UDim.new(0, 8))
        AddStroke(NotifFrame, colors[notifType], 0.4)
        
        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 4, 1, -10)
        AccentBar.Position = UDim2.new(0, 5, 0, 5)
        AccentBar.BackgroundColor3 = colors[notifType]
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = NotifFrame
        AddCorner(AccentBar, UDim.new(0, 2))
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Size = UDim2.new(1, -25, 0, 22)
        NotifTitle.Position = UDim2.new(0, 18, 0, 8)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = title
        NotifTitle.TextColor3 = Theme.Text
        NotifTitle.TextSize = 13
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = NotifFrame
        
        local NotifMessage = Instance.new("TextLabel")
        NotifMessage.Size = UDim2.new(1, -25, 0, 35)
        NotifMessage.Position = UDim2.new(0, 18, 0, 30)
        NotifMessage.BackgroundTransparency = 1
        NotifMessage.Text = message
        NotifMessage.TextColor3 = Theme.TextDark
        NotifMessage.TextSize = 11
        NotifMessage.Font = Enum.Font.GothamMedium
        NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
        NotifMessage.TextWrapped = true
        NotifMessage.Parent = NotifFrame
        
        local ProgressBG = Instance.new("Frame")
        ProgressBG.Size = UDim2.new(1, -20, 0, 3)
        ProgressBG.Position = UDim2.new(0, 10, 1, -8)
        ProgressBG.BackgroundColor3 = Theme.Element
        ProgressBG.BorderSizePixel = 0
        ProgressBG.Parent = NotifFrame
        AddCorner(ProgressBG, UDim.new(1, 0))
        
        local ProgressFill = Instance.new("Frame")
        ProgressFill.Size = UDim2.new(1, 0, 1, 0)
        ProgressFill.BackgroundColor3 = colors[notifType]
        ProgressFill.BorderSizePixel = 0
        ProgressFill.Parent = ProgressBG
        AddCorner(ProgressFill, UDim.new(1, 0))
        
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        Tween(NotifFrame, 0.3, {Position = UDim2.new(0, 0, 0, 0)}, Easing.Smooth)
        Tween(ProgressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)
        
        task.delay(duration, function()
            if NotifFrame and NotifFrame.Parent then
                Tween(NotifFrame, 0.3, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
                task.delay(0.3, function()
                    if NotifFrame then NotifFrame:Destroy() end
                end)
            end
        end)
    end
    
    -- Mobile Toggle Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 55, 0, 55)
    ToggleButton.Position = UDim2.new(0, 15, 1, -70)
    ToggleButton.BackgroundColor3 = Theme.Accent
    ToggleButton.Text = "☰"
    ToggleButton.TextColor3 = Theme.Text
    ToggleButton.TextSize = 24
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Visible = UserInputService.TouchEnabled
    ToggleButton.Parent = ScreenGui
    AddCorner(ToggleButton, UDim.new(0, 12))
    AddStroke(ToggleButton, Theme.Text, 0.5)
    MakeDraggable(ToggleButton)
    
    local uiVisible = true
    ToggleButton.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        Tween(MainFrame, 0.3, {Size = uiVisible and UDim2.new(0, 700, 0, 500) or UDim2.new(0, 0, 0, 0)})
        Tween(ToggleButton, 0.2, {BackgroundColor3 = uiVisible and Theme.Accent or Theme.Element})
        if Window.Blur then Window.Blur.Enabled = uiVisible end
    end)
    
    -- Keyboard Toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
            if Window.Blur then Window.Blur.Enabled = uiVisible end
            Tween(ToggleButton, 0.2, {BackgroundColor3 = uiVisible and Theme.Accent or Theme.Element})
        end
    end)
    
    -- Initial Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(MainFrame, 0.5, {Size = UDim2.new(0, 700, 0, 500), Position = UDim2.new(0.5, -350, 0.5, -250)}, Easing.Bounce)
    
    return Window
end

return MidnightUI
