--[[
    MidnightUI v3.0 "Monster Edition"
    - Neon Midnight Theme
    - Fluid CanvasGroup Page Transitions
    - Micro-Interactions with Scale & Color
    - Fully Responsive Grid Layout
    - Zero Empty Content Guarantee
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

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(8, 8, 12),
    Sidebar = Color3.fromRGB(5, 5, 9),
    Accent = Color3.fromRGB(170, 100, 255),
    AccentLight = Color3.fromRGB(212, 176, 255),
    AccentDark = Color3.fromRGB(130, 70, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(190, 190, 210),
    Element = Color3.fromRGB(18, 18, 24),
    ElementHover = Color3.fromRGB(25, 25, 34),
    Stroke = Color3.fromRGB(170, 100, 255),
    StrokeTransparency = 0.6,
    CornerRadius = UDim.new(0, 12),
    BlurIntensity = 12,
    MainSize = {X = 750, Y = 500},
    SidebarWidth = 180
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

local function Tween(obj, duration, properties, style, direction)
    if not obj then return end
    local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, properties)
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
    stroke.Thickness = thickness or 1.5
    stroke.Parent = parent
    return stroke
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
function MidnightUI:CreateWindow(title, enableBlur)
    local Window = {}
    Window.Tabs = {}
    Window.TabButtons = {}
    Window.ActiveTab = nil
    Window.Elements = {}
    Window.Pages = {}
    Window.PageGroups = {}
    
    -- Blur Effect
    if enableBlur ~= false then
        local blur = CreateBlur()
        blur.Enabled = true
        Window.Blur = blur
    end
    
    -- Parent Selection with fallback
    local parent = nil
    local success = pcall(function()
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
    ScreenGui.Name = "MidnightUI_Monster_" .. tostring(math.random(100000, 999999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent
    
    -- Main Frame (Stretched)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, Theme.MainSize.X, 0, Theme.MainSize.Y)
    MainFrame.Position = UDim2.new(0.5, -Theme.MainSize.X/2, 0.5, -Theme.MainSize.Y/2)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    MainFrame.ZIndex = 10
    
    AddCorner(MainFrame, UDim.new(0, 12))
    AddStroke(MainFrame, Theme.Stroke, 0.6, 1.5)
    
    -- Outer Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://7912134082"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.65
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(50, 50, 450, 450)
    Shadow.ZIndex = MainFrame.ZIndex - 1
    Shadow.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    TopBar.ZIndex = MainFrame.ZIndex + 1
    
    AddCorner(TopBar, UDim.new(0, 12))
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 250, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "MIDNIGHT UI"
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    TitleLabel.ZIndex = TopBar.ZIndex + 1
    
    -- Accent Badge
    local Badge = Instance.new("Frame")
    Badge.Size = UDim2.new(0, 60, 0, 24)
    Badge.Position = UDim2.new(0, 200, 0.5, -12)
    Badge.BackgroundColor3 = Theme.Accent
    Badge.BackgroundTransparency = 0.2
    Badge.Parent = TopBar
    AddCorner(Badge, UDim.new(0, 6))
    
    local BadgeText = Instance.new("TextLabel")
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Text = "MONSTER"
    BadgeText.TextColor3 = Theme.AccentLight
    BadgeText.TextSize = 10
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.Parent = Badge
    
    -- Control Buttons
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 80, 0, 32)
    Controls.Position = UDim2.new(1, -95, 0.5, -16)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar
    Controls.ZIndex = TopBar.ZIndex + 1
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(0, 0, 0, 0)
    MinBtn.BackgroundColor3 = Theme.Element
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.TextSize = 20
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = Controls
    AddCorner(MinBtn, UDim.new(0, 8))
    AddStroke(MinBtn, Theme.Stroke, 0.5)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(0, 40, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.TextSize = 22
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Controls
    AddCorner(CloseBtn, UDim.new(0, 8))
    AddStroke(CloseBtn, Theme.Stroke, 0.5)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, Theme.SidebarWidth, 1, -56)
    Sidebar.Position = UDim2.new(0, 8, 0, 54)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Sidebar.ZIndex = MainFrame.ZIndex + 1
    
    AddCorner(Sidebar, UDim.new(0, 12))
    AddStroke(Sidebar, Theme.Stroke, 0.5)
    
    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -12, 1, -12)
    TabContainer.Position = UDim2.new(0, 6, 0, 6)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 3
    TabContainer.ScrollBarImageColor3 = Theme.Accent
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    TabContainer.ZIndex = Sidebar.ZIndex + 1
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = TabContainer
    
    -- Content Container (Right Side)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -(Theme.SidebarWidth + 16), 1, -60)
    ContentContainer.Position = UDim2.new(0, Theme.SidebarWidth + 12, 0, 54)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    ContentContainer.ZIndex = MainFrame.ZIndex + 1
    ContentContainer.ClipsDescendants = true
    
    AddCorner(ContentContainer, UDim.new(0, 12))
    AddStroke(ContentContainer, Theme.Stroke, 0.4)
    
    -- Canvas Group Container for Fluid Page Transitions
    local CanvasContainer = Instance.new("Frame")
    CanvasContainer.Size = UDim2.new(1, 0, 1, 0)
    CanvasContainer.BackgroundTransparency = 1
    CanvasContainer.Parent = ContentContainer
    CanvasContainer.ZIndex = ContentContainer.ZIndex + 1
    
    -- Make draggable
    MakeDraggable(MainFrame, TopBar)
    
    -- Minimize Functionality
    local minimized = false
    local originalSize = MainFrame.Size
    local originalPos = MainFrame.Position
    
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, 0.4, {Size = UDim2.new(0, Theme.MainSize.X, 0, 52), Position = UDim2.new(0.5, -Theme.MainSize.X/2, 0.5, -26)})
            Tween(ContentContainer, 0.3, {BackgroundTransparency = 1})
            Tween(Sidebar, 0.3, {BackgroundTransparency = 1})
            task.delay(0.3, function()
                if minimized then
                    ContentContainer.Visible = false
                    Sidebar.Visible = false
                end
            end)
        else
            ContentContainer.Visible = true
            Sidebar.Visible = true
            Tween(ContentContainer, 0.3, {BackgroundTransparency = 0})
            Tween(Sidebar, 0.3, {BackgroundTransparency = 0})
            Tween(MainFrame, 0.4, {Size = originalSize, Position = originalPos})
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
    
    -- Hover Effects for Buttons
    local function applyHoverEffect(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            Tween(btn, 0.2, {BackgroundColor3 = hoverColor or Theme.AccentLight, Size = UDim2.new(0, 34, 0, 34)})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.2, {BackgroundColor3 = normalColor or Theme.Element, Size = UDim2.new(0, 32, 0, 32)})
        end)
    end
    
    applyHoverEffect(MinBtn, Theme.Element, Theme.Accent)
    applyHoverEffect(CloseBtn, Color3.fromRGB(220, 60, 60), Color3.fromRGB(255, 80, 80))
    
    -- Update Tab Canvas
    local function updateTabCanvas()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 20)
    end
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
    task.spawn(function() task.wait(0.1); updateTabCanvas() end)
    
    -- Create Tab Function
    function Window:CreateTab(name, iconId)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.VisibleElements = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -12, 0, 44)
        TabButton.BackgroundColor3 = Theme.Element
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        TabButton.ZIndex = TabContainer.ZIndex + 1
        
        AddCorner(TabButton, UDim.new(0, 8))
        AddStroke(TabButton, Theme.Stroke, 0.6)
        
        -- Icon
        local Icon = nil
        if iconId then
            Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(0, 12, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.Image = iconId
            Icon.ImageColor3 = Theme.TextDark
            Icon.Parent = TabButton
            Icon.ZIndex = TabButton.ZIndex + 1
        end
        
        -- Tab Name
        local TabName = Instance.new("TextLabel")
        TabName.Size = UDim2.new(1, (iconId and -40 or -12), 1, 0)
        TabName.Position = UDim2.new(0, iconId and 38 or 12, 0, 0)
        TabName.BackgroundTransparency = 1
        TabName.Text = string.upper(name)
        TabName.TextColor3 = Theme.TextDark
        TabName.TextSize = 12
        TabName.Font = Enum.Font.GothamBold
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.Parent = TabButton
        TabName.ZIndex = TabButton.ZIndex + 1
        
        -- Indicator
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.Position = UDim2.new(0, 0, 0.2, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabButton
        AddCorner(Indicator, UDim.new(0, 2))
        Indicator.ZIndex = TabButton.ZIndex + 1
        
        -- Page CanvasGroup (for fluid transitions)
        local PageGroup = Instance.new("CanvasGroup")
        PageGroup.Name = name .. "_Group"
        PageGroup.Size = UDim2.new(1, 0, 1, 0)
        PageGroup.BackgroundTransparency = 1
        PageGroup.GroupTransparency = 1
        PageGroup.Visible = false
        PageGroup.Parent = CanvasContainer
        PageGroup.ZIndex = CanvasContainer.ZIndex + 20
        
        -- Page Content with Grid Layout
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 4
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = PageGroup
        TabPage.ZIndex = PageGroup.ZIndex + 1
        
        -- Grid Layout (2 columns)
        local Grid = Instance.new("UIGridLayout")
        Grid.CellSize = UDim2.new(0.48, 0, 0, 48)
        Grid.CellPadding = UDim2.new(0, 12, 0, 12)
        Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Grid.Parent = TabPage
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 12)
        PagePadding.PaddingBottom = UDim.new(0, 12)
        PagePadding.PaddingLeft = UDim.new(0, 8)
        PagePadding.PaddingRight = UDim.new(0, 8)
        PagePadding.Parent = TabPage
        
        -- Canvas update
        local function updateCanvas()
            local childCount = 0
            for _, child in pairs(TabPage:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then
                    if child ~= Grid and child ~= PagePadding then
                        childCount = childCount + 1
                    end
                end
            end
            local rows = math.ceil(childCount / 2)
            local canvasHeight = rows * 60 + 24
            TabPage.CanvasSize = UDim2.new(0, 0, 0, math.max(canvasHeight, 200))
        end
        
        Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        
        -- Store references
        Window.Pages[name] = TabPage
        Window.PageGroups[name] = PageGroup
        
        -- Tab Selection with Fluid Animation
        local function selectTab()
            -- Animate out current page
            if Window.ActiveTab and Window.PageGroups[Window.ActiveTab.Name] then
                local oldGroup = Window.PageGroups[Window.ActiveTab.Name]
                Tween(oldGroup, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quad)
                task.delay(0.25, function()
                    if oldGroup and oldGroup.Parent then
                        oldGroup.Visible = false
                    end
                end)
            end
            
            -- Reset all tab buttons
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
            
            -- Highlight selected tab
            Tween(TabButton, 0.2, {BackgroundColor3 = Theme.ElementHover})
            Tween(Indicator, 0.2, {BackgroundTransparency = 0})
            Tween(TabName, 0.2, {TextColor3 = Theme.Text})
            if Icon then
                Tween(Icon, 0.2, {ImageColor3 = Theme.Accent})
            end
            
            -- Show and animate in new page
            PageGroup.Visible = true
            PageGroup.GroupTransparency = 1
            Tween(PageGroup, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
            
            -- Animate elements in sequence
            local elements = {}
            for _, child in pairs(TabPage:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then
                    if child ~= Grid and child ~= PagePadding then
                        table.insert(elements, child)
                    end
                end
            end
            for i, element in ipairs(elements) do
                element.BackgroundTransparency = 1
                element.Position = UDim2.new(0, 0, 0, -15)
                task.delay(i * 0.02, function()
                    if element and element.Parent then
                        Tween(element, 0.25, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
                    end
                end)
            end
            
            Window.ActiveTab = Tab
            updateCanvas()
        end
        
        TabButton.MouseButton1Click:Connect(selectTab)
        if UserInputService.TouchEnabled then
            TabButton.TouchTap:Connect(selectTab)
        end
        
        -- Hover with scale
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, 0.15, {BackgroundColor3 = Theme.ElementHover, Size = UDim2.new(1, -10, 0, 46)})
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, 0.15, {BackgroundColor3 = Theme.Element, Size = UDim2.new(1, -12, 0, 44)})
            end
        end)
        
        Window.TabButtons[name] = {
            Button = TabButton,
            Indicator = Indicator,
            Text = TabName,
            Icon = Icon
        }
        Window.Tabs[name] = Tab
        
        -- Select first tab by default (FIX: ensures content never empty)
        if not Window.ActiveTab then
            task.defer(function()
                selectTab()
            end)
        end
        
        updateTabCanvas()
        
        -- Element Creators
        local function addToPage(instance)
            instance.Parent = TabPage
            instance.ZIndex = TabPage.ZIndex + 20
            table.insert(Tab.VisibleElements, instance)
            updateCanvas()
            return instance
        end
        
        function Tab:CreateButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 48)
            btn.BackgroundColor3 = Theme.Element
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.BorderSizePixel = 0
            
            AddCorner(btn, UDim.new(0, 8))
            AddStroke(btn, Theme.Stroke, 0.6)
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -40, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = btn
            label.ZIndex = btn.ZIndex + 1
            
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 18, 0, 18)
            icon.Position = UDim2.new(1, -32, 0.5, -9)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://7072718362"
            icon.ImageColor3 = Theme.Accent
            icon.Parent = btn
            icon.ZIndex = btn.ZIndex + 1
            
            local function onClick()
                Tween(btn, 0.08, {Size = UDim2.new(0.96, 0, 0, 46)})
                Tween(btn, 0.12, {Size = UDim2.new(1, 0, 0, 48)}, Enum.EasingStyle.Back)
                callback()
            end
            
            btn.MouseButton1Click:Connect(onClick)
            
            btn.MouseEnter:Connect(function()
                Tween(btn, 0.2, {BackgroundColor3 = Theme.Accent})
                Tween(btn, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
                Tween(icon, 0.2, {ImageColor3 = Theme.Text})
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(btn, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
                Tween(icon, 0.2, {ImageColor3 = Theme.Accent})
            end)
            
            addToPage(btn)
            return btn
        end
        
        function Tab:CreateToggle(text, default, callback)
            local toggled = default or false
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 48)
            frame.BackgroundColor3 = Theme.Element
            frame.BorderSizePixel = 0
            
            AddCorner(frame, UDim.new(0, 8))
            AddStroke(frame, Theme.Stroke, 0.6)
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -80, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 52, 0, 28)
            toggleBtn.Position = UDim2.new(1, -65, 0.5, -14)
            toggleBtn.BackgroundColor3 = toggled and Theme.Accent or Theme.Element
            toggleBtn.Text = ""
            toggleBtn.AutoButtonColor = false
            toggleBtn.Parent = frame
            AddCorner(toggleBtn, UDim.new(1, 0))
            
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 22, 0, 22)
            circle.Position = toggled and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
            circle.BackgroundColor3 = Theme.Text
            circle.BorderSizePixel = 0
            circle.Parent = toggleBtn
            AddCorner(circle, UDim.new(1, 0))
            
            local function toggle()
                toggled = not toggled
                if toggled then
                    Tween(toggleBtn, 0.25, {BackgroundColor3 = Theme.Accent})
                    Tween(circle, 0.25, {Position = UDim2.new(1, -26, 0.5, -11)})
                else
                    Tween(toggleBtn, 0.25, {BackgroundColor3 = Theme.Element})
                    Tween(circle, 0.25, {Position = UDim2.new(0, 3, 0.5, -11)})
                end
                callback(toggled)
            end
            
            toggleBtn.MouseButton1Click:Connect(toggle)
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle()
                end
            end)
            
            frame.MouseEnter:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(frame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(frame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            addToPage(frame)
            
            local obj = {}
            function obj:Set(v) if toggled ~= v then toggle() end end
            function obj:Get() return toggled end
            return obj
        end
        
        function Tab:CreateSlider(text, minVal, maxVal, defaultVal, callback)
            minVal = minVal or 0
            maxVal = maxVal or 100
            local current = math.clamp(defaultVal or minVal, minVal, maxVal)
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 68)
            frame.BackgroundColor3 = Theme.Element
            frame.BorderSizePixel = 0
            
            AddCorner(frame, UDim.new(0, 8))
            AddStroke(frame, Theme.Stroke, 0.6)
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -80, 0, 24)
            label.Position = UDim2.new(0, 15, 0, 8)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 26)
            valueLabel.Position = UDim2.new(1, -65, 0, 6)
            valueLabel.BackgroundColor3 = Theme.Accent
            valueLabel.Text = tostring(current)
            valueLabel.TextColor3 = Theme.Text
            valueLabel.TextSize = 11
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.Parent = frame
            AddCorner(valueLabel, UDim.new(0, 6))
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -30, 0, 6)
            sliderBg.Position = UDim2.new(0, 15, 0, 46)
            sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = frame
            AddCorner(sliderBg, UDim.new(1, 0))
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((current - minVal) / (maxVal - minVal), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0
            fill.Parent = sliderBg
            AddCorner(fill, UDim.new(1, 0))
            
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = UDim2.new(1, -9, 0.5, -9)
            circle.BackgroundColor3 = Theme.Text
            circle.BorderSizePixel = 0
            circle.Parent = fill
            AddCorner(circle, UDim.new(1, 0))
            AddStroke(circle, Theme.Accent, 0, 2)
            
            local dragging = false
            
            local function update(input)
                local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                current = math.floor(minVal + (maxVal - minVal) * rel)
                Tween(fill, 0.1, {Size = UDim2.new(rel, 0, 1, 0)})
                valueLabel.Text = tostring(current)
                callback(current)
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input)
                end
            end)
            sliderBg.InputEnded:Connect(function() dragging = false end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            
            frame.MouseEnter:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(frame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(frame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            addToPage(frame)
            
            local obj = {}
            function obj:Set(v)
                v = math.clamp(v, minVal, maxVal)
                current = v
                local rel = (v - minVal) / (maxVal - minVal)
                Tween(fill, 0.2, {Size = UDim2.new(rel, 0, 1, 0)})
                valueLabel.Text = tostring(v)
                callback(v)
            end
            function obj:Get() return current end
            return obj
        end
        
        function Tab:CreateDropdown(text, options, defaultVal, callback)
            local selected = defaultVal or options[1] or "Select"
            local opened = false
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 48)
            frame.BackgroundColor3 = Theme.Element
            frame.BorderSizePixel = 0
            
            AddCorner(frame, UDim.new(0, 8))
            AddStroke(frame, Theme.Stroke, 0.6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.5, -10, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(0.45, 0, 0, 34)
            dropBtn.Position = UDim2.new(0.5, 5, 0.5, -17)
            dropBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            dropBtn.Text = selected
            dropBtn.TextColor3 = Theme.Text
            dropBtn.TextSize = 12
            dropBtn.Font = Enum.Font.GothamMedium
            dropBtn.AutoButtonColor = false
            dropBtn.Parent = frame
            AddCorner(dropBtn, UDim.new(0, 6))
            
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Theme.Accent
            arrow.TextSize = 10
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = dropBtn
            
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
            optionsFrame.Position = UDim2.new(0.5, 5, 1, 5)
            optionsFrame.BackgroundColor3 = Theme.Element
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            optionsFrame.ZIndex = 50
            optionsFrame.Parent = frame
            AddCorner(optionsFrame, UDim.new(0, 8))
            AddStroke(optionsFrame, Theme.Stroke, 0.5)
            
            local optLayout = Instance.new("UIListLayout")
            optLayout.Padding = UDim.new(0, 4)
            optLayout.Parent = optionsFrame
            
            local function createOption(opt)
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, -10, 0, 34)
                optBtn.Position = UDim2.new(0, 5, 0, 0)
                optBtn.BackgroundColor3 = Theme.Element
                optBtn.Text = opt
                optBtn.TextColor3 = Theme.TextDark
                optBtn.TextSize = 11
                optBtn.Font = Enum.Font.GothamMedium
                optBtn.AutoButtonColor = false
                optBtn.Parent = optionsFrame
                AddCorner(optBtn, UDim.new(0, 6))
                
                optBtn.MouseEnter:Connect(function()
                    Tween(optBtn, 0.1, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text})
                end)
                optBtn.MouseLeave:Connect(function()
                    Tween(optBtn, 0.1, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDark})
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    dropBtn.Text = opt
                    opened = false
                    Tween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 48)})
                    Tween(arrow, 0.2, {Rotation = 0})
                    optionsFrame.Visible = false
                    callback(opt)
                    updateCanvas()
                end)
            end
            
            for _, opt in ipairs(options) do
                createOption(opt)
            end
            
            local function toggle()
                opened = not opened
                if opened then
                    local cnt = #options
                    Tween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 48 + 10 + (cnt * 38) + 10)})
                    Tween(arrow, 0.2, {Rotation = 180})
                    optionsFrame.Size = UDim2.new(0.45, 0, 0, (cnt * 38) + 10)
                    optionsFrame.Visible = true
                else
                    Tween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 48)})
                    Tween(arrow, 0.2, {Rotation = 0})
                    task.delay(0.2, function()
                        if not opened then optionsFrame.Visible = false end
                    end)
                end
                updateCanvas()
            end
            
            dropBtn.MouseButton1Click:Connect(toggle)
            
            frame.MouseEnter:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(frame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(frame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            addToPage(frame)
            
            local obj = {}
            function obj:Set(v)
                if table.find(options, v) then
                    selected = v
                    dropBtn.Text = v
                    callback(v)
                end
            end
            function obj:Get() return selected end
            return obj
        end
        
        function Tab:CreateKeybind(text, defaultKey, callback)
            local currentKey = defaultKey or Enum.KeyCode.RightShift
            local listening = false
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 48)
            frame.BackgroundColor3 = Theme.Element
            frame.BorderSizePixel = 0
            
            AddCorner(frame, UDim.new(0, 8))
            AddStroke(frame, Theme.Stroke, 0.6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -110, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 95, 0, 34)
            keyBtn.Position = UDim2.new(1, -110, 0.5, -17)
            keyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            keyBtn.Text = currentKey.Name
            keyBtn.TextColor3 = Theme.Accent
            keyBtn.TextSize = 12
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.AutoButtonColor = false
            keyBtn.Parent = frame
            AddCorner(keyBtn, UDim.new(0, 6))
            
            local connection
            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyBtn.Text = "..."
                Tween(keyBtn, 0.1, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text})
                
                if connection then connection:Disconnect() end
                connection = UserInputService.InputBegan:Connect(function(input, gp)
                    if listening and not gp and input.KeyCode ~= Enum.KeyCode.Unknown then
                        listening = false
                        currentKey = input.KeyCode
                        keyBtn.Text = currentKey.Name
                        Tween(keyBtn, 0.1, {BackgroundColor3 = Color3.fromRGB(25, 25, 32), TextColor3 = Theme.Accent})
                        if connection then connection:Disconnect() end
                    end
                end)
                
                task.delay(5, function()
                    if listening then
                        listening = false
                        keyBtn.Text = currentKey.Name
                        Tween(keyBtn, 0.1, {BackgroundColor3 = Color3.fromRGB(25, 25, 32), TextColor3 = Theme.Accent})
                        if connection then connection:Disconnect() end
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if not gp and input.KeyCode == currentKey then
                    callback(currentKey)
                end
            end)
            
            frame.MouseEnter:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.ElementHover})
                Tween(frame, 0.15, {Position = UDim2.new(0, -2, 0, -1)})
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, 0.2, {BackgroundColor3 = Theme.Element})
                Tween(frame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
            end)
            
            addToPage(frame)
            
            local obj = {}
            function obj:Set(key) currentKey = key; keyBtn.Text = key.Name end
            function obj:Get() return currentKey end
            return obj
        end
        
        function Tab:CreateLabel(text)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 42)
            frame.BackgroundColor3 = Theme.Accent
            frame.BackgroundTransparency = 0.85
            frame.BorderSizePixel = 0
            
            AddCorner(frame, UDim.new(0, 8))
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = "✨ " .. text
            label.TextColor3 = Theme.Text
            label.TextSize = 12
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            addToPage(frame)
            
            local obj = {}
            function obj:Set(new) label.Text = "✨ " .. new end
            return obj
        end
        
        return Tab
    end
    
    -- Notification System
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 320, 1, 0)
    NotifContainer.Position = UDim2.new(1, -340, 0, 15)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui
    NotifContainer.ZIndex = 999
    
    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifLayout.Parent = NotifContainer
    
    function Window:Notify(title, message, duration, nType)
        duration = duration or 3
        nType = nType or "Info"
        
        local colors = {
            Info = Theme.Accent,
            Success = Color3.fromRGB(100, 255, 150),
            Warning = Color3.fromRGB(255, 200, 100),
            Error = Color3.fromRGB(255, 100, 100)
        }
        
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 310, 0, 70)
        notif.BackgroundColor3 = Theme.Sidebar
        notif.BackgroundTransparency = 0.1
        notif.Parent = NotifContainer
        AddCorner(notif, UDim.new(0, 8))
        AddStroke(notif, colors[nType], 0.4)
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 4, 1, -10)
        bar.Position = UDim2.new(0, 5, 0, 5)
        bar.BackgroundColor3 = colors[nType]
        bar.BorderSizePixel = 0
        bar.Parent = notif
        AddCorner(bar, UDim.new(0, 2))
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -25, 0, 24)
        titleLabel.Position = UDim2.new(0, 18, 0, 8)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Theme.Text
        titleLabel.TextSize = 13
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = notif
        
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -25, 0, 35)
        msgLabel.Position = UDim2.new(0, 18, 0, 32)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = message
        msgLabel.TextColor3 = Theme.TextDark
        msgLabel.TextSize = 11
        msgLabel.Font = Enum.Font.GothamMedium
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextWrapped = true
        msgLabel.Parent = notif
        
        local progressBg = Instance.new("Frame")
        progressBg.Size = UDim2.new(1, -20, 0, 3)
        progressBg.Position = UDim2.new(0, 10, 1, -8)
        progressBg.BackgroundColor3 = Theme.Element
        progressBg.BorderSizePixel = 0
        progressBg.Parent = notif
        AddCorner(progressBg, UDim.new(1, 0))
        
        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        progressFill.BackgroundColor3 = colors[nType]
        progressFill.BorderSizePixel = 0
        progressFill.Parent = progressBg
        AddCorner(progressFill, UDim.new(1, 0))
        
        notif.Position = UDim2.new(1, 50, 0, 0)
        Tween(notif, 0.3, {Position = UDim2.new(0, 0, 0, 0)})
        Tween(progressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)
        
        task.delay(duration, function()
            if notif and notif.Parent then
                Tween(notif, 0.3, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
                task.delay(0.3, function()
                    if notif then notif:Destroy() end
                end)
            end
        end)
    end
    
    -- Mobile Toggle
    local MobileToggle = Instance.new("TextButton")
    MobileToggle.Size = UDim2.new(0, 55, 0, 55)
    MobileToggle.Position = UDim2.new(0, 15, 1, -75)
    MobileToggle.BackgroundColor3 = Theme.Accent
    MobileToggle.Text = "☰"
    MobileToggle.TextColor3 = Theme.Text
    MobileToggle.TextSize = 24
    MobileToggle.Font = Enum.Font.GothamBold
    MobileToggle.Visible = UserInputService.TouchEnabled
    MobileToggle.Parent = ScreenGui
    AddCorner(MobileToggle, UDim.new(0, 12))
    AddStroke(MobileToggle, Theme.Text, 0.5)
    MakeDraggable(MobileToggle)
    
    local visible = true
    MobileToggle.MouseButton1Click:Connect(function()
        visible = not visible
        Tween(MainFrame, 0.3, {Size = visible and UDim2.new(0, Theme.MainSize.X, 0, Theme.MainSize.Y) or UDim2.new(0, 0, 0, 0)})
        Tween(MobileToggle, 0.2, {BackgroundColor3 = visible and Theme.Accent or Theme.Element})
        if Window.Blur then Window.Blur.Enabled = visible end
    end)
    
    -- Keyboard Toggle (Right Ctrl)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightControl then
            visible = not visible
            MainFrame.Visible = visible
            if Window.Blur then Window.Blur.Enabled = visible end
            Tween(MobileToggle, 0.2, {BackgroundColor3 = visible and Theme.Accent or Theme.Element})
        end
    end)
    
    -- Initial Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(MainFrame, 0.6, {Size = UDim2.new(0, Theme.MainSize.X, 0, Theme.MainSize.Y), Position = UDim2.new(0.5, -Theme.MainSize.X/2, 0.5, -Theme.MainSize.Y/2)}, Enum.EasingStyle.Back)
    
    return Window
end

return MidnightUI
