--[[
    MidnightUI Library v1.1 - FIXED
    Premium Roblox UI Library
    Mobile & PC & Executor Compatible
    Tüm hatalar düzeltildi.
]]

local MidnightUI = {}
MidnightUI.__index = MidnightUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(10, 10, 12),
    Sidebar = Color3.fromRGB(7, 7, 9),
    Accent = Color3.fromRGB(170, 100, 255),
    AccentDark = Color3.fromRGB(130, 70, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Element = Color3.fromRGB(18, 18, 22),
    ElementHover = Color3.fromRGB(25, 25, 30),
    Stroke = Color3.fromRGB(60, 60, 70),
    Success = Color3.fromRGB(100, 255, 150),
    CornerRadius = UDim.new(0, 8),
    StrokeTransparency = 0.6
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
    local tweenInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
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

local function AddPadding(parent, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding or 8)
    pad.PaddingBottom = UDim.new(0, padding or 8)
    pad.PaddingLeft = UDim.new(0, padding or 8)
    pad.PaddingRight = UDim.new(0, padding or 8)
    pad.Parent = parent
    return pad
end

-- Dragging System (Mobile + PC)
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

-- Ripple Effect
local function CreateRipple(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    AddCorner(ripple, UDim.new(1, 0))
    
    local mousePos = UserInputService:GetMouseLocation()
    local buttonPos = button.AbsolutePosition
    local relativePos = Vector2.new(mousePos.X - buttonPos.X, mousePos.Y - buttonPos.Y - 36)
    
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, relativePos.X, 0, relativePos.Y)
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Tween(ripple, 0.5, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, relativePos.X - maxSize/2, 0, relativePos.Y - maxSize/2),
        BackgroundTransparency = 1
    })
    
    task.delay(0.5, function()
        if ripple and ripple.Parent then
            ripple:Destroy()
        end
    end)
end

-- Main Library
function MidnightUI:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.TabButtons = {}
    Window.ActiveTab = nil
    Window.NotificationContainer = nil
    
    -- Parent Selection (CoreGui -> PlayerGui fallback) - FIXED
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
    ScreenGui.Name = "MidnightUI_" .. tostring(math.random(100000, 999999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    
    AddCorner(MainFrame, UDim.new(0, 10))
    AddStroke(MainFrame, Theme.Accent, 0.8, 1.5)
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 50, 1, 50)
    Shadow.Position = UDim2.new(0, -25, 0, -25)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://7912134082"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(50, 50, 450, 450)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    AddCorner(TopBar, UDim.new(0, 10))
    
    -- Fix corner overlap
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Name = "Fix"
    TopBarFix.Size = UDim2.new(1, 0, 0, 15)
    TopBarFix.Position = UDim2.new(0, 0, 1, -15)
    TopBarFix.BackgroundColor3 = Theme.Sidebar
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "MidnightUI"
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    -- Version Badge
    local VersionBadge = Instance.new("TextLabel")
    VersionBadge.Name = "Version"
    VersionBadge.Size = UDim2.new(0, 40, 0, 20)
    VersionBadge.Position = UDim2.new(0, 220, 0.5, -10)
    VersionBadge.BackgroundColor3 = Theme.Accent
    VersionBadge.Text = "v1.1"
    VersionBadge.TextColor3 = Theme.Text
    VersionBadge.TextSize = 11
    VersionBadge.Font = Enum.Font.GothamBold
    VersionBadge.Parent = TopBar
    
    AddCorner(VersionBadge, UDim.new(0, 5))
    
    -- Control Buttons Container
    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Name = "Controls"
    ControlsContainer.Size = UDim2.new(0, 70, 0, 25)
    ControlsContainer.Position = UDim2.new(1, -85, 0.5, -12.5)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = TopBar
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
    MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    MinimizeBtn.BackgroundColor3 = Theme.Element
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Theme.Text
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = ControlsContainer
    
    AddCorner(MinimizeBtn, UDim.new(0, 6))
    AddStroke(MinimizeBtn)
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 25)
    CloseBtn.Position = UDim2.new(0, 35, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = ControlsContainer
    
    AddCorner(CloseBtn, UDim.new(0, 6))
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -55)
    Sidebar.Position = UDim2.new(0, 5, 0, 50)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    AddCorner(Sidebar)
    AddStroke(Sidebar)
    
    -- Tab Container in Sidebar
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Theme.Accent
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabContainer
    
    -- FIXED: TabContainer canvas size update
    local function updateTabCanvas()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
    task.spawn(function()
        task.wait(0.1)
        updateTabCanvas()
    end)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -160, 1, -55)
    ContentContainer.Position = UDim2.new(0, 150, 0, 50)
    ContentContainer.BackgroundColor3 = Theme.Element
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    AddCorner(ContentContainer)
    AddStroke(ContentContainer)
    
    -- Page Container (replacing UIPageLayout with manual system for better compatibility)
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, 0, 1, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentContainer
    
    -- Make window draggable
    MakeDraggable(MainFrame, TopBar)
    
    -- Minimize functionality
    local minimized = false
    local originalSize = MainFrame.Size
    local originalPos = MainFrame.Position
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, 0.3, {Size = UDim2.new(0, 550, 0, 45), Position = UDim2.new(0.5, -275, 0.5, -190)})
            ContentContainer.Visible = false
            Sidebar.Visible = false
        else
            Tween(MainFrame, 0.3, {Size = originalSize, Position = originalPos})
            task.delay(0.2, function()
                ContentContainer.Visible = true
                Sidebar.Visible = true
            end)
        end
    end)
    
    -- Close functionality
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
        task.delay(0.3, function()
            ScreenGui:Destroy()
        end)
    end)
    
    -- Hover effects
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, 0.2, {BackgroundColor3 = Theme.ElementHover})
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, 0.2, {BackgroundColor3 = Theme.Element})
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)})
    end)
    
    -- Create Tab Function
    function Window:CreateTab(name, iconID)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.Page = nil
        Tab.Button = nil
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "_Button"
        TabButton.Size = UDim2.new(1, -10, 0, 38)
        TabButton.BackgroundColor3 = Theme.Element
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        
        AddCorner(TabButton)
        AddStroke(TabButton)
        
        -- Icon
        local Icon = nil
        if iconID then
            Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Position = UDim2.new(0, 10, 0.5, -9)
            Icon.BackgroundTransparency = 1
            Icon.Image = iconID
            Icon.ImageColor3 = Theme.TextDark
            Icon.Parent = TabButton
        end
        
        -- Tab Name
        local TabName = Instance.new("TextLabel")
        TabName.Name = "TabName"
        TabName.Size = UDim2.new(1, (iconID and -40 or -10), 1, 0)
        TabName.Position = UDim2.new(0, iconID and 35 or 10, 0, 0)
        TabName.BackgroundTransparency = 1
        TabName.Text = name
        TabName.TextColor3 = Theme.TextDark
        TabName.TextSize = 13
        TabName.Font = Enum.Font.GothamMedium
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.Parent = TabButton
        
        -- Accent Indicator
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.Position = UDim2.new(0, 0, 0.2, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabButton
        
        AddCorner(Indicator, UDim.new(0, 2))
        
        -- Tab Page (Content)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Visible = false
        TabPage.Parent = PageContainer
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.Parent = TabPage
        
        local PageListLayout = Instance.new("UIListLayout")
        PageListLayout.Padding = UDim.new(0, 8)
        PageListLayout.Parent = TabPage
        
        -- FIXED: Auto-resize canvas
        local function updateCanvasSize()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 20)
        end
        PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        task.spawn(function()
            task.wait(0.1)
            updateCanvasSize()
        end)
        
        -- Tab Selection
        local function selectTab()
            -- Hide all pages
            for _, child in pairs(PageContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Deselect all tabs
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
            
            -- Select this tab
            Tween(TabButton, 0.2, {BackgroundColor3 = Theme.ElementHover})
            Tween(Indicator, 0.2, {BackgroundTransparency = 0})
            Tween(TabName, 0.2, {TextColor3 = Theme.Text})
            if Icon then
                Tween(Icon, 0.2, {ImageColor3 = Theme.Accent})
            end
            
            -- Show this page
            TabPage.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(selectTab)
        if UserInputService.TouchEnabled then
            TabButton.TouchTap:Connect(selectTab)
        end
        
        -- Hover effect
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, 0.2, {BackgroundColor3 = Theme.ElementHover})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, 0.2, {BackgroundColor3 = Theme.Element})
            end
        end)
        
        -- Store references
        Window.TabButtons[name] = {
            Button = TabButton,
            Indicator = Indicator,
            Text = TabName,
            Icon = Icon
        }
        Window.Tabs[name] = Tab
        Tab.Page = TabPage
        Tab.Button = TabButton
        
        -- Select first tab by default
        if not Window.ActiveTab then
            selectTab()
        end
        
        -- Update tab container canvas
        updateTabCanvas()
        
        -- Toggle Element
        function Tab:CreateToggle(text, default, callback)
            callback = callback or function() end
            local toggled = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = text .. "_Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
            ToggleFrame.BackgroundColor3 = Theme.Sidebar
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabPage
            
            AddCorner(ToggleFrame)
            AddStroke(ToggleFrame)
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.TextSize = 14
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "Toggle"
            ToggleButton.Size = UDim2.new(0, 44, 0, 24)
            ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
            ToggleButton.BackgroundColor3 = toggled and Theme.Accent or Theme.Element
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = ToggleFrame
            
            AddCorner(ToggleButton, UDim.new(1, 0))
            AddStroke(ToggleButton)
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "Circle"
            ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
            ToggleCircle.Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            ToggleCircle.BackgroundColor3 = Theme.Text
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            
            AddCorner(ToggleCircle, UDim.new(1, 0))
            
            local function toggle()
                toggled = not toggled
                
                if toggled then
                    Tween(ToggleButton, 0.2, {BackgroundColor3 = Theme.Accent})
                    Tween(ToggleCircle, 0.2, {Position = UDim2.new(1, -21, 0.5, -9)})
                else
                    Tween(ToggleButton, 0.2, {BackgroundColor3 = Theme.Element})
                    Tween(ToggleCircle, 0.2, {Position = UDim2.new(0, 3, 0.5, -9)})
                end
                
                callback(toggled)
            end
            
            ToggleButton.MouseButton1Click:Connect(toggle)
            if UserInputService.TouchEnabled then
                ToggleButton.TouchTap:Connect(toggle)
            end
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggle()
                end
            end)
            
            -- Hover effect
            ToggleFrame.MouseEnter:Connect(function()
                Tween(ToggleFrame, 0.2, {BackgroundColor3 = Theme.Element})
            end)
            ToggleFrame.MouseLeave:Connect(function()
                Tween(ToggleFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
            end)
            
            local ToggleObject = {}
            function ToggleObject:Set(value)
                if toggled ~= value then
                    toggle()
                end
            end
            function ToggleObject:Get()
                return toggled
            end
            
            updateCanvasSize()
            return ToggleObject
        end
        
        -- Slider Element
        function Tab:CreateSlider(text, min, max, default, callback)
            callback = callback or function() end
            min = min or 0
            max = max or 100
            default = math.clamp(default or min, min, max)
            local currentValue = default
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = text .. "_Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            SliderFrame.BackgroundColor3 = Theme.Sidebar
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabPage
            
            AddCorner(SliderFrame)
            AddStroke(SliderFrame)
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Size = UDim2.new(1, -70, 0, 25)
            SliderLabel.Position = UDim2.new(0, 15, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = text
            SliderLabel.TextColor3 = Theme.Text
            SliderLabel.TextSize = 14
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "Value"
            ValueLabel.Size = UDim2.new(0, 50, 0, 25)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundColor3 = Theme.Accent
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Theme.Text
            ValueLabel.TextSize = 12
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Parent = SliderFrame
            
            AddCorner(ValueLabel, UDim.new(0, 5))
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Name = "SliderBG"
            SliderBG.Size = UDim2.new(1, -30, 0, 8)
            SliderBG.Position = UDim2.new(0, 15, 0, 40)
            SliderBG.BackgroundColor3 = Theme.Element
            SliderBG.BorderSizePixel = 0
            SliderBG.Parent = SliderFrame
            
            AddCorner(SliderBG, UDim.new(1, 0))
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBG
            
            AddCorner(SliderFill, UDim.new(1, 0))
            
            local SliderCircle = Instance.new("Frame")
            SliderCircle.Name = "Circle"
            SliderCircle.Size = UDim2.new(0, 16, 0, 16)
            SliderCircle.Position = UDim2.new(1, -8, 0.5, -8)
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
                end
            end
            
            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            SliderBG.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            -- Hover effect
            SliderFrame.MouseEnter:Connect(function()
                Tween(SliderFrame, 0.2, {BackgroundColor3 = Theme.Element})
            end)
            SliderFrame.MouseLeave:Connect(function()
                Tween(SliderFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
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
            function SliderObject:Get()
                return currentValue
            end
            
            updateCanvasSize()
            return SliderObject
        end
        
        -- Button Element
        function Tab:CreateButton(text, callback)
            callback = callback or function() end
            
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = text .. "_Button"
            ButtonFrame.Size = UDim2.new(1, 0, 0, 45)
            ButtonFrame.BackgroundColor3 = Theme.Sidebar
            ButtonFrame.Text = ""
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Parent = TabPage
            
            AddCorner(ButtonFrame)
            AddStroke(ButtonFrame)
            
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Name = "Label"
            ButtonLabel.Size = UDim2.new(1, -50, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 15, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = text
            ButtonLabel.TextColor3 = Theme.Text
            ButtonLabel.TextSize = 14
            ButtonLabel.Font = Enum.Font.GothamMedium
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.Parent = ButtonFrame
            
            local ButtonIcon = Instance.new("ImageLabel")
            ButtonIcon.Name = "Icon"
            ButtonIcon.Size = UDim2.new(0, 20, 0, 20)
            ButtonIcon.Position = UDim2.new(1, -35, 0.5, -10)
            ButtonIcon.BackgroundTransparency = 1
            ButtonIcon.Image = "rbxassetid://7072718362"
            ButtonIcon.ImageColor3 = Theme.Accent
            ButtonIcon.Parent = ButtonFrame
            
            local function onClick()
                CreateRipple(ButtonFrame)
                
                Tween(ButtonFrame, 0.1, {BackgroundColor3 = Theme.Accent})
                task.delay(0.1, function()
                    if ButtonFrame and ButtonFrame.Parent then
                        Tween(ButtonFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
                    end
                end)
                
                callback()
            end
            
            ButtonFrame.MouseButton1Click:Connect(onClick)
            if UserInputService.TouchEnabled then
                ButtonFrame.TouchTap:Connect(onClick)
            end
            
            -- Hover effect
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(ButtonIcon, 0.2, {ImageColor3 = Theme.Text})
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
                Tween(ButtonIcon, 0.2, {ImageColor3 = Theme.Accent})
            end)
            
            updateCanvasSize()
            return ButtonFrame
        end
        
        -- Dropdown Element
        function Tab:CreateDropdown(text, options, default, callback)
            callback = callback or function() end
            options = options or {}
            local selected = default or options[1] or "Select..."
            local opened = false
            local dropdownFrame = nil
            local optionsFrame = nil
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = text .. "_Dropdown"
            DropdownFrame.Size = UDim2.new(1, 0, 0, 45)
            DropdownFrame.BackgroundColor3 = Theme.Sidebar
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabPage
            
            AddCorner(DropdownFrame)
            AddStroke(DropdownFrame)
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "Label"
            DropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 15, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = text
            DropdownLabel.TextColor3 = Theme.Text
            DropdownLabel.TextSize = 14
            DropdownLabel.Font = Enum.Font.GothamMedium
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "Button"
            DropdownButton.Size = UDim2.new(0.45, 0, 0, 30)
            DropdownButton.Position = UDim2.new(0.5, 5, 0.5, -15)
            DropdownButton.BackgroundColor3 = Theme.Element
            DropdownButton.Text = selected
            DropdownButton.TextColor3 = Theme.TextDark
            DropdownButton.TextSize = 12
            DropdownButton.Font = Enum.Font.GothamMedium
            DropdownButton.AutoButtonColor = false
            DropdownButton.Parent = DropdownFrame
            
            AddCorner(DropdownButton)
            AddStroke(DropdownButton)
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Name = "Arrow"
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -25, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.Accent
            Arrow.TextSize = 10
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Parent = DropdownButton
            
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "Options"
            OptionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
            OptionsFrame.Position = UDim2.new(0.5, 5, 1, 5)
            OptionsFrame.BackgroundColor3 = Theme.Sidebar
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.Visible = false
            OptionsFrame.ZIndex = 10
            OptionsFrame.Parent = DropdownFrame
            
            AddCorner(OptionsFrame)
            AddStroke(OptionsFrame, Theme.Accent, 0.5)
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Padding = UDim.new(0, 2)
            OptionsLayout.Parent = OptionsFrame
            
            local OptionsPadding = Instance.new("UIPadding")
            OptionsPadding.PaddingTop = UDim.new(0, 5)
            OptionsPadding.PaddingBottom = UDim.new(0, 5)
            OptionsPadding.PaddingLeft = UDim.new(0, 5)
            OptionsPadding.PaddingRight = UDim.new(0, 5)
            OptionsPadding.Parent = OptionsFrame
            
            local function createOption(optionText)
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = optionText
                OptionButton.Size = UDim2.new(1, 0, 0, 28)
                OptionButton.BackgroundColor3 = Theme.Element
                OptionButton.Text = optionText
                OptionButton.TextColor3 = Theme.TextDark
                OptionButton.TextSize = 11
                OptionButton.Font = Enum.Font.GothamMedium
                OptionButton.AutoButtonColor = false
                OptionButton.ZIndex = 11
                OptionButton.Parent = OptionsFrame
                
                AddCorner(OptionButton, UDim.new(0, 5))
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, 0.15, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text})
                end)
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, 0.15, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDark})
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    selected = optionText
                    DropdownButton.Text = optionText
                    opened = false
                    Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 45)})
                    Tween(Arrow, 0.2, {Rotation = 0})
                    OptionsFrame.Visible = false
                    callback(optionText)
                end)
            end
            
            for _, option in ipairs(options) do
                createOption(option)
            end
            
            local function toggleDropdown()
                opened = not opened
                
                if opened then
                    local optionCount = #options
                    local targetHeight = 45 + 10 + (optionCount * 30) + 10
                    Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, targetHeight)})
                    Tween(Arrow, 0.2, {Rotation = 180})
                    OptionsFrame.Size = UDim2.new(0.45, 0, 0, (optionCount * 30) + 10)
                    OptionsFrame.Visible = true
                    updateCanvasSize()
                else
                    Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 45)})
                    Tween(Arrow, 0.2, {Rotation = 0})
                    task.delay(0.2, function()
                        if not opened and OptionsFrame then
                            OptionsFrame.Visible = false
                            updateCanvasSize()
                        end
                    end)
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(toggleDropdown)
            if UserInputService.TouchEnabled then
                DropdownButton.TouchTap:Connect(toggleDropdown)
            end
            
            -- Hover effect
            DropdownFrame.MouseEnter:Connect(function()
                Tween(DropdownFrame, 0.2, {BackgroundColor3 = Theme.Element})
            end)
            DropdownFrame.MouseLeave:Connect(function()
                Tween(DropdownFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
            end)
            
            local DropdownObject = {}
            function DropdownObject:Set(value)
                if table.find(options, value) then
                    selected = value
                    DropdownButton.Text = value
                    callback(value)
                end
            end
            function DropdownObject:Get()
                return selected
            end
            function DropdownObject:Refresh(newOptions)
                for _, child in pairs(OptionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                options = newOptions
                for _, option in ipairs(options) do
                    createOption(option)
                end
            end
            
            updateCanvasSize()
            return DropdownObject
        end
        
        -- TextBox Element
        function Tab:CreateTextBox(text, placeholder, callback)
            callback = callback or function() end
            
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Name = text .. "_TextBox"
            TextBoxFrame.Size = UDim2.new(1, 0, 0, 45)
            TextBoxFrame.BackgroundColor3 = Theme.Sidebar
            TextBoxFrame.BorderSizePixel = 0
            TextBoxFrame.Parent = TabPage
            
            AddCorner(TextBoxFrame)
            AddStroke(TextBoxFrame)
            
            local TextBoxLabel = Instance.new("TextLabel")
            TextBoxLabel.Name = "Label"
            TextBoxLabel.Size = UDim2.new(0.4, -10, 1, 0)
            TextBoxLabel.Position = UDim2.new(0, 15, 0, 0)
            TextBoxLabel.BackgroundTransparency = 1
            TextBoxLabel.Text = text
            TextBoxLabel.TextColor3 = Theme.Text
            TextBoxLabel.TextSize = 14
            TextBoxLabel.Font = Enum.Font.GothamMedium
            TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxLabel.Parent = TextBoxFrame
            
            local InputBox = Instance.new("TextBox")
            InputBox.Name = "Input"
            InputBox.Size = UDim2.new(0.55, 0, 0, 30)
            InputBox.Position = UDim2.new(0.4, 5, 0.5, -15)
            InputBox.BackgroundColor3 = Theme.Element
            InputBox.Text = ""
            InputBox.PlaceholderText = placeholder or "Enter text..."
            InputBox.PlaceholderColor3 = Theme.TextDark
            InputBox.TextColor3 = Theme.Text
            InputBox.TextSize = 12
            InputBox.Font = Enum.Font.GothamMedium
            InputBox.ClearTextOnFocus = false
            InputBox.Parent = TextBoxFrame
            
            AddCorner(InputBox)
            AddStroke(InputBox)
            
            InputBox.Focused:Connect(function()
                Tween(InputBox, 0.2, {BackgroundColor3 = Theme.ElementHover})
            end)
            
            InputBox.FocusLost:Connect(function(enterPressed)
                Tween(InputBox, 0.2, {BackgroundColor3 = Theme.Element})
                if enterPressed then
                    callback(InputBox.Text)
                end
            end)
            
            -- Hover effect
            TextBoxFrame.MouseEnter:Connect(function()
                Tween(TextBoxFrame, 0.2, {BackgroundColor3 = Theme.Element})
            end)
            TextBoxFrame.MouseLeave:Connect(function()
                Tween(TextBoxFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
            end)
            
            local TextBoxObject = {}
            function TextBoxObject:Set(value)
                InputBox.Text = value
            end
            function TextBoxObject:Get()
                return InputBox.Text
            end
            
            updateCanvasSize()
            return TextBoxObject
        end
        
        -- Label Element
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = "Label"
            LabelFrame.Size = UDim2.new(1, 0, 0, 35)
            LabelFrame.BackgroundColor3 = Theme.Accent
            LabelFrame.BackgroundTransparency = 0.8
            LabelFrame.BorderSizePixel = 0
            LabelFrame.Parent = TabPage
            
            AddCorner(LabelFrame)
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Name = "Text"
            LabelText.Size = UDim2.new(1, -20, 1, 0)
            LabelText.Position = UDim2.new(0, 10, 0, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.Text = "ℹ️ " .. text
            LabelText.TextColor3 = Theme.Text
            LabelText.TextSize = 13
            LabelText.Font = Enum.Font.GothamMedium
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.Parent = LabelFrame
            
            local LabelObject = {}
            function LabelObject:Set(newText)
                LabelText.Text = "ℹ️ " .. newText
            end
            
            updateCanvasSize()
            return LabelObject
        end
        
        -- Keybind Element
        function Tab:CreateKeybind(text, default, callback)
            callback = callback or function() end
            local currentKey = default or Enum.KeyCode.RightShift
            local listening = false
            
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = text .. "_Keybind"
            KeybindFrame.Size = UDim2.new(1, 0, 0, 45)
            KeybindFrame.BackgroundColor3 = Theme.Sidebar
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Parent = TabPage
            
            AddCorner(KeybindFrame)
            AddStroke(KeybindFrame)
            
            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Name = "Label"
            KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 15, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = text
            KeybindLabel.TextColor3 = Theme.Text
            KeybindLabel.TextSize = 14
            KeybindLabel.Font = Enum.Font.GothamMedium
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.Parent = KeybindFrame
            
            local KeybindButton = Instance.new("TextButton")
            KeybindButton.Name = "Button"
            KeybindButton.Size = UDim2.new(0, 80, 0, 28)
            KeybindButton.Position = UDim2.new(1, -95, 0.5, -14)
            KeybindButton.BackgroundColor3 = Theme.Element
            KeybindButton.Text = currentKey.Name or "None"
            KeybindButton.TextColor3 = Theme.Accent
            KeybindButton.TextSize = 12
            KeybindButton.Font = Enum.Font.GothamBold
            KeybindButton.AutoButtonColor = false
            KeybindButton.Parent = KeybindFrame
            
            AddCorner(KeybindButton)
            AddStroke(KeybindButton, Theme.Accent, 0.5)
            
            local connection
            KeybindButton.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                KeybindButton.Text = "..."
                Tween(KeybindButton, 0.2, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text})
                
                if connection then connection:Disconnect() end
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
                        listening = false
                        currentKey = input.KeyCode
                        KeybindButton.Text = currentKey.Name
                        Tween(KeybindButton, 0.2, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.Accent})
                        if connection then connection:Disconnect() end
                    end
                end)
                
                task.delay(5, function()
                    if listening then
                        listening = false
                        KeybindButton.Text = currentKey.Name
                        Tween(KeybindButton, 0.2, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.Accent})
                        if connection then connection:Disconnect() end
                    end
                end)
            end)
            
            -- Keybind handler
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == currentKey then
                    callback(currentKey)
                end
            end)
            
            -- Hover effect
            KeybindFrame.MouseEnter:Connect(function()
                Tween(KeybindFrame, 0.2, {BackgroundColor3 = Theme.Element})
            end)
            KeybindFrame.MouseLeave:Connect(function()
                Tween(KeybindFrame, 0.2, {BackgroundColor3 = Theme.Sidebar})
            end)
            
            local KeybindObject = {}
            function KeybindObject:Set(key)
                currentKey = key
                KeybindButton.Text = key.Name
            end
            function KeybindObject:Get()
                return currentKey
            end
            
            updateCanvasSize()
            return KeybindObject
        end
        
        return Tab
    end
    
    -- Notification System
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "Notifications"
    NotificationContainer.Size = UDim2.new(0, 280, 1, 0)
    NotificationContainer.Position = UDim2.new(1, -290, 0, 10)
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
        
        local notifColors = {
            Info = Theme.Accent,
            Success = Color3.fromRGB(100, 255, 150),
            Warning = Color3.fromRGB(255, 200, 100),
            Error = Color3.fromRGB(255, 100, 100)
        }
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "Notification"
        NotifFrame.Size = UDim2.new(0, 270, 0, 70)
        NotifFrame.BackgroundColor3 = Theme.Sidebar
        NotifFrame.BackgroundTransparency = 0.1
        NotifFrame.Parent = NotificationContainer
        
        AddCorner(NotifFrame, UDim.new(0, 8))
        AddStroke(NotifFrame, notifColors[notifType], 0.3)
        
        local AccentBar = Instance.new("Frame")
        AccentBar.Name = "Accent"
        AccentBar.Size = UDim2.new(0, 4, 1, -10)
        AccentBar.Position = UDim2.new(0, 5, 0, 5)
        AccentBar.BackgroundColor3 = notifColors[notifType]
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = NotifFrame
        
        AddCorner(AccentBar, UDim.new(0, 2))
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Name = "Title"
        NotifTitle.Size = UDim2.new(1, -25, 0, 22)
        NotifTitle.Position = UDim2.new(0, 18, 0, 8)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = title
        NotifTitle.TextColor3 = Theme.Text
        NotifTitle.TextSize = 14
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = NotifFrame
        
        local NotifMessage = Instance.new("TextLabel")
        NotifMessage.Name = "Message"
        NotifMessage.Size = UDim2.new(1, -25, 0, 35)
        NotifMessage.Position = UDim2.new(0, 18, 0, 28)
        NotifMessage.BackgroundTransparency = 1
        NotifMessage.Text = message
        NotifMessage.TextColor3 = Theme.TextDark
        NotifMessage.TextSize = 12
        NotifMessage.Font = Enum.Font.GothamMedium
        NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
        NotifMessage.TextWrapped = true
        NotifMessage.Parent = NotifFrame
        
        -- Progress bar
        local ProgressBG = Instance.new("Frame")
        ProgressBG.Name = "ProgressBG"
        ProgressBG.Size = UDim2.new(1, -20, 0, 3)
        ProgressBG.Position = UDim2.new(0, 10, 1, -8)
        ProgressBG.BackgroundColor3 = Theme.Element
        ProgressBG.BorderSizePixel = 0
        ProgressBG.Parent = NotifFrame
        
        AddCorner(ProgressBG, UDim.new(1, 0))
        
        local ProgressFill = Instance.new("Frame")
        ProgressFill.Name = "Fill"
        ProgressFill.Size = UDim2.new(1, 0, 1, 0)
        ProgressFill.BackgroundColor3 = notifColors[notifType]
        ProgressFill.BorderSizePixel = 0
        ProgressFill.Parent = ProgressBG
        
        AddCorner(ProgressFill, UDim.new(1, 0))
        
        -- Animate in
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        Tween(NotifFrame, 0.3, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back)
        
        -- Progress animation
        Tween(ProgressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)
        
        -- Animate out
        task.delay(duration, function()
            if NotifFrame and NotifFrame.Parent then
                Tween(NotifFrame, 0.3, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
                task.delay(0.3, function()
                    if NotifFrame and NotifFrame.Parent then
                        NotifFrame:Destroy()
                    end
                end)
            end
        end)
    end
    
    -- Toggle UI visibility (Mobile button)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleUI"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 15, 0.5, -25)
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
        MainFrame.Visible = uiVisible
        Tween(ToggleButton, 0.2, {BackgroundColor3 = uiVisible and Theme.Accent or Theme.Element})
    end)
    
    -- Keyboard toggle (Right Ctrl)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
            if ToggleButton then
                Tween(ToggleButton, 0.2, {BackgroundColor3 = uiVisible and Theme.Accent or Theme.Element})
            end
        end
    end)
    
    -- Initial animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(MainFrame, 0.5, {Size = UDim2.new(0, 550, 0, 380), Position = UDim2.new(0.5, -275, 0.5, -190)}, Enum.EasingStyle.Back)
    
    return Window
end

return MidnightUI
