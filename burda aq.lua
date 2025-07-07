
local Library = {}
Library.__index = Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Gelişmiş Create fonksiyonu
local function Create(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then
                obj.Parent = v
            else
                local success, err = pcall(function()
                    obj[k] = v
                end)
                if not success then
                    if typeof(v) == "Color3" and (k == "BrickColor" or k:lower():find("brickcolor")) then
                        obj.BrickColor = BrickColor.new(v)
                    else
                        error(err)
                    end
                end
            end
        end
    end
    return obj
end

local function Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local Themes = {
    Default = {
        Background = Color3.fromRGB(35,35,40),
        Accent = Color3.fromRGB(120,90,255),
        Text = Color3.fromRGB(230,230,230),
        Section = Color3.fromRGB(45,45,50),
        Hover = Color3.fromRGB(70,70,80),
        ToggleOn = Color3.fromRGB(100,160,255),
        ToggleOff = Color3.fromRGB(70,70,70),
        DropdownBG = Color3.fromRGB(40,40,45),
        SliderFill = Color3.fromRGB(100,160,255),
        TextBoxBG = Color3.fromRGB(50,50,55),
        ButtonBG = Color3.fromRGB(80,80,90),
        OwnerTagBG = Color3.fromRGB(70, 70, 80),
        OwnerTagText = Color3.fromRGB(180, 180, 180),
        CloseBtnHover = Color3.fromRGB(255, 100, 100)
    }
}

local Gui = Create("ScreenGui", {Name = "EmirGuiLib", ResetOnSpawn = false})
Gui.Parent = CoreGui

local function MakeDraggable(frame, dragBar)
    dragBar = dragBar or frame
    local dragging = false
    local dragInput, mousePos, framePos

    local function waitForAbsoluteSize()
        while frame.AbsoluteSize.X == 0 or frame.AbsoluteSize.Y == 0 do
            RunService.Heartbeat:Wait()
        end
    end

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            waitForAbsoluteSize()

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

    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            local viewportSize = workspace.CurrentCamera.ViewportSize

            local guiWidth = frame.AbsoluteSize.X
            local guiHeight = frame.AbsoluteSize.Y

            local newX = framePos.X.Offset + delta.X
            local newY = framePos.Y.Offset + delta.Y

            newX = math.clamp(newX, 0, viewportSize.X - guiWidth)
            newY = math.clamp(newY, 0, viewportSize.Y - guiHeight)

            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

local function MakeScrollable(frame)
    local scroll = Create("ScrollingFrame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = Themes.Default.Accent,
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
        ZIndex = 5
    })
    local layout = Create("UIListLayout", {Parent = scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})
    local padding = Create("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6)})

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 6)
    end)

    return scroll
end

local Widget = {}
Widget.__index = Widget

local Window = {}
Window.__index = Window
setmetatable(Window, Widget)

function Window:new(title, ownerName)
    local self = setmetatable({}, Window)

    local viewport = workspace.CurrentCamera.ViewportSize
    local initialWidth = math.clamp(viewport.X * 0.8, 350, 480)
    local initialHeight = math.clamp(viewport.Y * 0.6, 250, 350)

    self.Frame = Create("Frame", {
        Parent = Gui,
        Size = UDim2.new(0, initialWidth, 0, initialHeight),
        Position = UDim2.new(0.5, -initialWidth/2, 1, -initialHeight - 24),
        BackgroundColor3 = Themes.Default.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 50
    })
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = self.Frame

    self.TitleBar = Create("Frame", {
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ZIndex = 51
    })
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar

    self.TitleLabel = Create("TextLabel", {
        Parent = self.TitleBar,
        Text = title or "Emir GUI",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52
    })

    self.OwnerTag = Create("TextLabel", {
        Parent = self.Frame,
        Text = ownerName or "Owner: Emir",
        TextColor3 = Themes.Default.OwnerTagText,
        BackgroundColor3 = Themes.Default.OwnerTagBG,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Size = UDim2.new(0, 110, 0, 20),
        Position = UDim2.new(1, -116, 1, -24),
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 70,
        ClipsDescendants = true
    })
    local ownerCorner = Instance.new("UICorner", self.OwnerTag)
    ownerCorner.CornerRadius = UDim.new(0, 6)

    -- YATAY KAYDIRMA İÇİN SCROLLING FRAME
    self.TabsHolder = Create("ScrollingFrame", {
        Parent = self.Frame,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Themes.Default.Accent,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 52
    })
    
    -- TAB BUTONLARI İÇİN KONTEYNER
    self.TabListContainer = Create("Frame", {
        Parent = self.TabsHolder,
        Size = UDim2.new(0, 0, 1, 0), -- Genişlik dinamik olarak ayarlanacak
        BackgroundTransparency = 1,
        ZIndex = 52
    })
    
    -- TABLARI YAN YANA DİZMEK İÇİN LAYOUT
    self.TabListLayout = Create("UIListLayout", {
        Parent = self.TabListContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    
    -- TAB BUTONLARININ BOYUTU DEĞİŞTİĞİNDE CANVAS BOYUTUNU GÜNCELLE
    self.TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentWidth = self.TabListLayout.AbsoluteContentSize.X
        self.TabListContainer.Size = UDim2.new(0, contentWidth, 1, 0)
        self.TabsHolder.CanvasSize = UDim2.new(0, contentWidth, 0, 0)
    end)

    self.ContentArea = Create("Frame", {
        Parent = self.Frame,
        Position = UDim2.new(0, 0, 0, 66),
        Size = UDim2.new(1, 0, 1, -66),
        BackgroundColor3 = Themes.Default.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 51
    })

    self.MinimizeBtn = Create("TextButton", {
        Parent = self.TitleBar,
        Text = "—",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, -72, 0, 0),
        ZIndex = 53,
        AutoButtonColor = false
    })

    self.CloseBtn = Create("TextButton", {
        Parent = self.TitleBar,
        Text = "×",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, -36, 0, 0),
        ZIndex = 53,
        AutoButtonColor = false
    })

    self.CloseBtn.MouseEnter:Connect(function()
        Tween(self.CloseBtn, {TextColor3 = Themes.Default.CloseBtnHover}, 0.15)
    end)
    self.CloseBtn.MouseLeave:Connect(function()
        Tween(self.CloseBtn, {TextColor3 = Themes.Default.Text}, 0.15)
    end)
    self.CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    self.Minimized = false
    local originalSize = self.Frame.Size

    self.MinimizeBtn.MouseEnter:Connect(function()
        Tween(self.MinimizeBtn, {TextColor3 = Color3.fromRGB(180,180,180)}, 0.15)
    end)
    self.MinimizeBtn.MouseLeave:Connect(function()
        Tween(self.MinimizeBtn, {TextColor3 = Themes.Default.Text}, 0.15)
    end)
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        if not self.Minimized then
            Tween(self.Frame, {Size = UDim2.new(0, originalSize.X.Offset, 0, 36)}, 0.3)
            self.TabsHolder.Visible = false
            self.ContentArea.Visible = false
            self.OwnerTag.Visible = false
            self.Minimized = true
        else
            Tween(self.Frame, {Size = originalSize}, 0.3)
            self.TabsHolder.Visible = true
            self.ContentArea.Visible = true
            self.OwnerTag.Visible = true
            self.Minimized = false
        end
    end)

    self.Tabs = {}
    self.SelectedTab = nil

    MakeDraggable(self.Frame, self.TitleBar)

    return self
end

function Window:AddTab(name)
    assert(type(name) == "string", "Tab name must be string")

    -- TextService tanımlaması (hata önleme)
    local TextService = game:GetService("TextService")
    
    -- Metin boyutunu hesapla
    local textSize = TextService:GetTextSize(
        name,
        15, -- Buton metin boyutu
        Enum.Font.GothamBold,
        Vector2.new(math.huge, math.huge) -- Sonsuz boyut
    )
    
    -- Buton genişliğini dinamik olarak ayarla
    local buttonWidth = math.clamp(
        textSize.X + 24,  -- Metin genişliği + padding
        80,               -- Minimum genişlik
        200               -- Maksimum genişlik
    )
    
    -- Tab butonunu oluştur
    local tabBtn = Create("TextButton", {
        Parent = self.TabListContainer,
        Text = name,
        TextTruncate = Enum.TextTruncate.AtEnd,  -- Uzun metinlerde ... göster
        BackgroundColor3 = Themes.Default.Section,
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        AutoButtonColor = false,
        Size = UDim2.new(0, buttonWidth, 1, -6), -- Dinamik genişlik
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),       -- Dikeyde ortala
        BorderSizePixel = 0,
        ZIndex = 54,
        TextWrapped = false                      -- Metni kaydırma
    })
    
    -- Buton köşelerini yuvarla
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    -- Tab içerik alanı
    local tabContent = Create("Frame", {
        Parent = self.ContentArea,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,          -- Başlangıçta gizli
        ClipsDescendants = true,  -- Taşan içeriği kes
        ZIndex = 51
    })

    -- Kaydırılabilir bölümler için canvas
    local sectionCanvas = MakeScrollable(tabContent)

    -- Tab nesnesi
    local tab = {
        Name = name,
        Button = tabBtn,
        Content = tabContent,
        SectionCanvas = sectionCanvas,
        Sections = {}
    }

    -- Tab seçme işlevi
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    -- Fare üzerine gelince efekt
    tabBtn.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            Tween(tabBtn, {BackgroundColor3 = Themes.Default.Hover}, 0.25)
        end
    end)
    
    -- Fare çıkınca eski haline dön
    tabBtn.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            Tween(tabBtn, {BackgroundColor3 = Themes.Default.Section}, 0.25)
        end
    end)

    -- Tabs listesine ekle
    table.insert(self.Tabs, tab)

    -- İlk tabı otomatik olarak seç
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end

    -- Canvas boyutunu güncelle
    task.defer(function()
        self.TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
        self.TabListContainer.Size = UDim2.new(0, self.TabListLayout.AbsoluteContentSize.X, 1, 0)
        self.TabsHolder.CanvasSize = UDim2.new(0, self.TabListLayout.AbsoluteContentSize.X, 0, 0)
    end)

    return tab
end


function Window:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then
            tab.Button.BackgroundColor3 = Themes.Default.Accent
            tab.Button.TextColor3 = Color3.new(1,1,1)
            tab.Content.Visible = true
            self.SelectedTab = tab
        else
            tab.Button.BackgroundColor3 = Themes.Default.Section
            tab.Button.TextColor3 = Themes.Default.Text
            tab.Content.Visible = false
        end
    end
end

local Section = {}
Section.__index = Section
setmetatable(Section, Widget)


function Section:AddToggle(text, callback)
    local toggle = {}
    toggle.State = false

    local container = Create("Frame", {
        Parent = self.WidgetsHolder,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ZIndex = 52
    })

    local label = Create("TextLabel", {
        Parent = container,
        Text = text,
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 5),
        Size = UDim2.new(1, -40, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53
    })

    local toggleBtn = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 36, 0, 20),
        Position = UDim2.new(1, -40, 0, 5),
        BackgroundColor3 = Themes.Default.ToggleOff,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 54
    })
    local corner = Instance.new("UICorner", toggleBtn)
    corner.CornerRadius = UDim.new(0, 12)

    local circle = Create("Frame", {
        Parent = toggleBtn,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(230,230,230),
        BorderSizePixel = 0,
        ZIndex = 55
    })
    local corner2 = Instance.new("UICorner", circle)
    corner2.CornerRadius = UDim.new(0, 8)

    local function setState(state)
        toggle.State = state
        if state then
            Tween(toggleBtn, {BackgroundColor3 = Themes.Default.ToggleOn}, 0.15)
            Tween(circle, {Position = UDim2.new(1, -18, 0, 2)}, 0.15)
        else
            Tween(toggleBtn, {BackgroundColor3 = Themes.Default.ToggleOff}, 0.15)
            Tween(circle, {Position = UDim2.new(0, 2, 0, 2)}, 0.15)
        end
        if callback then
            pcall(callback, state)
        end
    end

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setState(not toggle.State)
        end
    end)

    toggle.Instance = container
    toggle.SetState = setState
    toggle.GetState = function() return toggle.State end

    setState(false)

    return toggle
end

function Section:AddButton(text, callback)
    local btn = {}

    local container = Create("TextButton", {
        Parent = self.WidgetsHolder,
        Text = text,
        BackgroundColor3 = Themes.Default.ButtonBG,
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(1, 0, 0, 32),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 52
    })
    
    -- Butona yuvarlak köşe
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = container

    container.MouseEnter:Connect(function()
        Tween(container, {BackgroundColor3 = Themes.Default.Accent}, 0.1)
    end)
    container.MouseLeave:Connect(function()
        Tween(container, {BackgroundColor3 = Themes.Default.ButtonBG}, 0.1)
    end)

    container.MouseButton1Click:Connect(function()
        if callback then
            pcall(callback)
        end
    end)

    btn.Instance = container

    return btn
end

function Section:AddSlider(text, min, max, default, callback)
    local slider = {}
    local dragging = false
    local minVal = min or 0
    local maxVal = max or 100
    local value = default or minVal

    local container = Create("Frame", {
        Parent = self.WidgetsHolder,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ZIndex = 52
    })

    local label = Create("TextLabel", {
        Parent = container,
        Text = text .. ": " .. tostring(value),
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53
    })

    local sliderFrame = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, -12, 0, 16),
        Position = UDim2.new(0, 6, 0, 24),
        BackgroundColor3 = Themes.Default.ToggleOff,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 54
    })
    local corner = Instance.new("UICorner", sliderFrame)
    corner.CornerRadius = UDim.new(0, 8)

    local fill = Create("Frame", {
        Parent = sliderFrame,
        Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0),
        BackgroundColor3 = Themes.Default.SliderFill,
        BorderSizePixel = 0,
        ZIndex = 55
    })
    local corner2 = Instance.new("UICorner", fill)
    corner2.CornerRadius = UDim.new(0, 8)

    local function updateValueFromPos(x)
        local relativeX = math.clamp(x - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
        local newValue = minVal + (relativeX / sliderFrame.AbsoluteSize.X) * (maxVal - minVal)
        value = math.floor(newValue * 100) / 100
        fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
        if callback then
            pcall(callback, value)
        end
    end

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValueFromPos(input.Position.X)
        end
    end)

    sliderFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValueFromPos(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    slider.Instance = container
    slider.GetValue = function() return value end
    slider.SetValue = function(newVal)
        value = math.clamp(newVal, minVal, maxVal)
        fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
    end

    return slider
end

function Section:AddDropdown(text, options, callback)
    local dropdown = {}
    local open = false
    local selectedIndex = nil

    local container = Create("Frame", {
        Parent = self.WidgetsHolder,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 52
    })

    local label = Create("TextLabel", {
        Parent = container,
        Text = text,
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(0.5, -10, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53
    })

    local selectedLabel = Create("TextLabel", {
        Parent = container,
        Text = "Select...",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 5),
        Size = UDim2.new(0.5, -40, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53
    })

    local arrowBtn = Create("TextButton", {
        Parent = container,
        Text = "▼",
        BackgroundTransparency = 1,
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 4),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 54
    })

    -- Dropdown list container (ANA GUI'E BAĞLI)
    local listContainer = Create("ScrollingFrame", {
        Parent = Gui,
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Themes.Default.DropdownBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = Themes.Default.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local listContent = Create("Frame", {
        Parent = listContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 101
    })

    local listLayout = Create("UIListLayout", {
        Parent = listContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listContent.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
        listContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    local function updateDropdownPosition()
        if not listContainer.Visible then return end
        
        -- Butonun mutlak pozisyonunu al
        local buttonPos = arrowBtn.AbsolutePosition
        local buttonSize = arrowBtn.AbsoluteSize
        
        -- Dropdown genişliği
        local dropdownWidth = container.AbsoluteSize.X -- Container genişliği ile aynı
        
        -- Ekran boyutları
        local screenSize = workspace.CurrentCamera.ViewportSize
        
        -- Pozisyon hesapla: Butonun sol alt köşesi
        local posX = buttonPos.X - (dropdownWidth - buttonSize.X)
        local posY = buttonPos.Y + buttonSize.Y
        
        -- Sınır kontrolleri (sol)
        if posX < 0 then
            posX = 0
        end
        
        -- Sınır kontrolleri (sağ)
        if posX + dropdownWidth > screenSize.X then
            posX = screenSize.X - dropdownWidth
        end
        
        -- Yeterli alan yoksa yukarı aç
        local dropdownHeight = math.min(#options * 26, 120)
        if posY + dropdownHeight > screenSize.Y then
            posY = buttonPos.Y - dropdownHeight
        end
        
        -- Pozisyonu ayarla
        listContainer.Position = UDim2.new(0, posX, 0, posY)
        listContainer.Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
    end

    local function openDropdown()
        if open then return end
        open = true
        
        -- Konumu güncelle
        updateDropdownPosition()
        
        -- Animasyon için başlangıç boyutu
        listContainer.Size = UDim2.new(0, listContainer.Size.X.Offset, 0, 0)
        listContainer.Visible = true
        
        -- Animasyonlu açılış
        Tween(listContainer, {
            Size = UDim2.new(0, listContainer.Size.X.Offset, 0, math.min(#options * 26, 120))
        }, 0.2)
    end

    local function closeDropdown()
        if not open then return end
        open = false
        
        -- Animasyonlu kapanış
        Tween(listContainer, {
            Size = UDim2.new(0, listContainer.Size.X.Offset, 0, 0)
        }, 0.2)
        
        task.delay(0.2, function()
            if listContainer then
                listContainer.Visible = false
            end
        end)
    end

    -- Buton etkileşimleri
    arrowBtn.MouseButton1Click:Connect(function()
        if open then
            closeDropdown()
        else
            openDropdown()
        end
    end)

    -- Pencere taşındığında dropdown pozisyonunu güncelle
    self.ParentWindow.Frame:GetPropertyChangedSignal("Position"):Connect(function()
        if open then
            updateDropdownPosition()
        end
    end)

    -- Ekran boyutu değiştiğinde pozisyonu güncelle
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if open then
            updateDropdownPosition()
        end
    end)

    -- Seçenekleri oluştur
    for i, opt in ipairs(options) do
        local btn = Create("TextButton", {
            Parent = listContent,
            Text = opt,
            BackgroundColor3 = Themes.Default.Section,
            TextColor3 = Themes.Default.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Size = UDim2.new(1, -8, 0, 26),
            Position = UDim2.new(0, 4, 0, 0),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 102
        })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Themes.Default.Hover}, 0.2)
        end)
        
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Themes.Default.Section}, 0.2)
        end)
        
        btn.MouseButton1Click:Connect(function()
            selectedLabel.Text = opt
            selectedIndex = i
            closeDropdown()
            if callback then 
                pcall(callback, opt, i) 
            end
        end)
    end

    -- Dışarı tıklandığında kapat
    UserInputService.InputBegan:Connect(function(input)
        if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            if not listContainer.AbsoluteRect:ContainsPoint(mousePos) and 
               not arrowBtn.AbsoluteRect:ContainsPoint(mousePos) and
               not container.AbsoluteRect:ContainsPoint(mousePos) then
                closeDropdown()
            end
        end
    end)

    dropdown.Instance = container
    dropdown.GetValue = function() 
        return selectedLabel.Text, selectedIndex 
    end
    
    dropdown.SetSelected = function(_, option)
        for i, opt in ipairs(options) do
            if opt == option then
                selectedLabel.Text = option
                selectedIndex = i
                break
            end
        end
    end
    
    dropdown.RefreshOptions = function(_, newOptions)
        -- Mevcut seçenekleri temizle
        for _, child in ipairs(listContent:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Yeni seçenekleri ekle
        for i, opt in ipairs(newOptions) do
            local btn = Create("TextButton", {
                Parent = listContent,
                Text = opt,
                BackgroundColor3 = Themes.Default.Section,
                TextColor3 = Themes.Default.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Size = UDim2.new(1, -8, 0, 26),
                Position = UDim2.new(0, 4, 0, 0),
                BorderSizePixel = 0,
                AutoButtonColor = false,
                ZIndex = 102
            })
            
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Themes.Default.Hover}, 0.2)
            end)
            
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Themes.Default.Section}, 0.2)
            end)
            
            btn.MouseButton1Click:Connect(function()
                selectedLabel.Text = opt
                selectedIndex = i
                closeDropdown()
                if callback then 
                    pcall(callback, opt, i) 
                end
            end)
        end
    end
    
    return dropdown
end

function Section:AddTextBox(placeholder, callback)
    local textbox = {}

    local container = Create("Frame", {
        Parent = self.WidgetsHolder,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ZIndex = 52
    })

    local input = Create("TextBox", {
        Parent = container,
        Text = "",
        PlaceholderText = placeholder or "Enter text...",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundColor3 = Themes.Default.TextBoxBG,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -12, 1, -6),
        Position = UDim2.new(0, 6, 0, 3),
        ClearTextOnFocus = false,
        ZIndex = 53
    })
    
    local inputCorner = Instance.new("UICorner", input)
    inputCorner.CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            pcall(callback, input.Text)
        end
    end)

    textbox.Instance = container
    textbox.TextBox = input
    textbox.GetText = function()
        return input.Text
    end
    textbox.SetText = function(text)
        input.Text = text
    end

    return textbox
end

-- Section metatable'ını güncelle
function Section:new(parentCanvas, parentWindow, title, options) -- parentWindow parametresi eklendi
    local self = setmetatable({}, Section)
    self.ParentCanvas = parentCanvas
    self.ParentWindow = parentWindow -- EKLENDİ: Parent window kaydediliyor
    
    -- Seçenekleri işle (collapsed parametresi)
    local options = options or {}
    self.Collapsed = options.collapsed or false
    
    -- Ana konteyner
    self.Container = Create("Frame", {
        Parent = parentCanvas,
        Size = UDim2.new(1, -12, 0, 30),
        BackgroundColor3 = Themes.Default.Section,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 52
    })
    self.Container.Position = UDim2.new(0, 6, 0, 0)
    
    -- Section'a yuvarlak köşe
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = self.Container

    -- Başlık için container
    self.TitleContainer = Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 53
    })
    
    -- Başlık
    self.TitleLabel = Create("TextLabel", {
        Parent = self.TitleContainer,
        Text = title or "Section",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0), -- Collapse butonu için yer aç
        Position = UDim2.new(0, 6, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 54
    })

    -- Küçültme/büyütme butonu - Daha büyük ve tıklanabilir
    
    self.CollapseButton = Create("TextButton", {
        Parent = self.TitleContainer,
        Text = self.Collapsed and "+" or "−",
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        BackgroundColor3 = Themes.Default.Hover,
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, 0), -- Dikeyde ortalandı ve sağdan 40px içeri alındı
        AnchorPoint = Vector2.new(0.5, 0.5),   -- Tam ortalanması için anchor point
        AutoButtonColor = false,
        ZIndex = 55
    })
    
    -- Buton arkaplanına yuvarlak köşe
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.5, 0)
    btnCorner.Parent = self.CollapseButton
    
    -- Buton hover efekti
    self.CollapseButton.MouseEnter:Connect(function()
        self.CollapseButton.BackgroundTransparency = 0.3
        self.CollapseButton.TextColor3 = Themes.Default.Accent
    end)
    
    self.CollapseButton.MouseLeave:Connect(function()
        self.CollapseButton.BackgroundTransparency = 0.8
        self.CollapseButton.TextColor3 = Themes.Default.Text
    end)
    
    -- Widget'lar için tutucu
    self.WidgetsHolder = Create("Frame", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 0),
        Position = UDim2.new(0, 0, 0, 30),
        ZIndex = 52,
        Visible = not self.Collapsed -- Küçültülmüşse gizle
    })

    self.Layout = Create("UIListLayout", {
        Parent = self.WidgetsHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    
    -- Başlık container'ına tıklanabilirlik ekle
    self.TitleContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleCollapse()
        end
    end)
    
    -- Küçültme butonuna tıklama - daha güvenilir
    self.CollapseButton.MouseButton1Click:Connect(function()
        self:ToggleCollapse()
    end)

    -- Widget boyut değişikliklerini izle
    self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if self.Collapsed then return end
        
        local size = self.Layout.AbsoluteContentSize.Y
        self.WidgetsHolder.Size = UDim2.new(1, 0, 0, size)
        
        if not self.Resizing then
            self.Container.Size = UDim2.new(1, -12, 0, 30 + size + 12)
        end
        
        -- Ana kaydırma alanını güncelle
        local canvas = self.ParentCanvas
        if canvas.UIListLayout then
            canvas.CanvasSize = UDim2.new(0, 0, 0, canvas.UIListLayout.AbsoluteContentSize.Y + 12)
        end
    end)

    -- Başlangıç boyutunu ayarla
    if self.Collapsed then
        self.Container.Size = UDim2.new(1, -12, 0, 30)
    else
        -- İlk boyutu ayarlamak için layout'u tetikle
        task.spawn(function()
            self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
            self.Container.Size = UDim2.new(1, -12, 0, 30 + self.Layout.AbsoluteContentSize.Y + 12)
        end)
    end

    return self
end

-- Section küçültme/büyütme fonksiyonu (düzeltilmiş)
function Section:ToggleCollapse()
    self.Collapsed = not self.Collapsed
    self.Resizing = true -- Boyutlandırma işlemini işaretle
    
    if self.Collapsed then
        -- Küçültülmüş durum
        self.CollapseButton.Text = "+"
        self.WidgetsHolder.Visible = false
        
        -- Animasyonlu küçültme
        Tween(self.Container, {
            Size = UDim2.new(1, -12, 0, 30)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    else
        -- Büyütülmüş durum
        self.CollapseButton.Text = "−"
        self.WidgetsHolder.Visible = true
        
        -- Widget'ların boyutunu yeniden hesapla
        local size = self.Layout.AbsoluteContentSize.Y
        
        -- Animasyonlu büyütme
        Tween(self.Container, {
            Size = UDim2.new(1, -12, 0, 30 + size + 12)
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
    
    -- Ana kaydırma alanını güncelle
    local canvas = self.ParentCanvas
    if canvas.UIListLayout then
        canvas.CanvasSize = UDim2.new(0, 0, 0, canvas.UIListLayout.AbsoluteContentSize.Y + 12)
    end
    
    self.Resizing = false
end

-- Section'ı programlı olarak küçültme/büyütme
function Section:SetCollapsed(state)
    if self.Collapsed ~= state then
        self:ToggleCollapse()
    end
end

-- Section'ın küçültülme durumunu kontrol etme
function Section:IsCollapsed()
    return self.Collapsed
end

-- Window:AddSection fonksiyonunu güncelle
function Window:AddSection(name, options)
    assert(type(name) == "string", "Section name must be string")
    if not self.SelectedTab then
        error("No tab selected")
    end

    local tab = self.SelectedTab
    local section = Section:new(tab.SectionCanvas, self, name, options) -- DÜZELTİLDİ: self (window) eklendi
    table.insert(tab.Sections, section)
    return section
end

function Library:CreateWindow(title, ownerName)
    local window = Window:new(title, ownerName)
    return window
end
-- DSL Overrides Begin
local _origCreateWindow = Library.CreateWindow
function Library:CreateWindow(title, ownerName)
    local win = _origCreateWindow(self, title, ownerName)
    setmetatable(win, {__index = Window})
    return win
end

function Window:Section(name, options)
    return self:AddSection(name, options)
end

-- Make DSL
Make = setmetatable({}, {
    __index = function(_, key)
        local s = tostring(key)
        if s:match("Window$") then
            return function(_, title, ownerName)
                local win = Library:CreateWindow(title, ownerName)
                _G[s] = win
                return win
            end
        end
    end
})
-- DSL Overrides End


setmetatable(Library, {
    __call = function(_, title, ownerName)
        return Library:CreateWindow(title, ownerName)
    end
})

-- Library tablosuna Notify fonksiyonunu ekle (sağ alt için güncellendi)
function Library:Notify(title, message, duration, callback)
    duration = duration or 5
    
    -- Bildirim konteyneri oluştur (yoksa) - SAĞ ALT KÖŞE
    if not Gui:FindFirstChild("NotificationContainer") then
        local container = Create("Frame", {
            Name = "NotificationContainer",
            Parent = Gui,
            Position = UDim2.new(1, -10, 1, -10), -- Sağ alt köşe
            Size = UDim2.new(0, 320, 0, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            ZIndex = 200
        })
        
        Create("UIListLayout", {
            Parent = container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    end
    
    local container = Gui.NotificationContainer
    local theme = Themes.Default
    
    -- Bildirim çerçevesi
    local notification = Create("Frame", {
        LayoutOrder = #container:GetChildren(),
        BackgroundColor3 = theme.Section,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(1, 0, 1, 0), -- Başlangıçta sağ dışında ve altta
        AnchorPoint = Vector2.new(1, 1), -- Sağ alt köşe
        ClipsDescendants = true,
        ZIndex = 201
    })
    
    local corner = Instance.new("UICorner", notification)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- İçerik düzeni
    local layout = Create("UIListLayout", {
        Parent = notification,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local padding = Create("UIPadding", {
        Parent = notification,
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16)
    })
    
    -- Başlık
    local titleLabel = Create("TextLabel", {
        Text = title,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 1,
        ZIndex = 202
    })
    titleLabel.Parent = notification
    
    -- Mesaj
    local messageLabel = Create("TextLabel", {
        Text = message,
        TextColor3 = Color3.new(0.8, 0.8, 0.8),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 2,
        ZIndex = 202
    })
    messageLabel.Parent = notification
    
    -- İlerleme çubuğu
    local progressBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        ZIndex = 203
    })
    progressBar.Parent = notification
    
    -- Boyutları güncelle
    local function updateSizes()
        titleLabel.Size = UDim2.new(1, 0, 0, titleLabel.TextBounds.Y)
        messageLabel.Size = UDim2.new(1, 0, 0, messageLabel.TextBounds.Y)
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
        notification.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
    end
    
    -- Başlangıç animasyonu (SAĞ ALT KÖŞE)
    notification.Parent = container
    task.spawn(updateSizes)
    
    -- Bildirimi içeri kaydır (sağ alttan sağ alt köşeye)
    Tween(notification, {
        Position = UDim2.new(1, -10, 1, -10)
    }, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    -- İlerleme animasyonu
    Tween(progressBar, {
        Size = UDim2.new(0, 0, 0, 3)
    }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    
    -- Otomatik kapanma
    task.delay(duration, function()
        if notification.Parent then
            Tween(notification, {
                Position = UDim2.new(1, 0, 1, 0)
            }, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            
            wait(0.5)
            notification:Destroy()
            if callback then pcall(callback) end
        end
    end)
    
    -- Manuel kapatma
    notification.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Tween(notification, {
                Position = UDim2.new(1, 0, 1, 0)
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            wait(0.3)
            notification:Destroy()
            if callback then pcall(callback) end
        end
    end)
    
    return notification
end

-- Window objesine de Notify fonksiyonunu ekle
Window.Notify = function(self, ...)
    return Library:Notify(...)
end


function Section:AddLabel(text)
    local label = {}
    
    local container = Create("Frame", {
        Parent = self.WidgetsHolder,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 52
    })

    local textLabel = Create("TextLabel", {
        Parent = container,
        Text = text,
        TextColor3 = Themes.Default.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 0),
        Position = UDim2.new(0, 6, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 53
    })
    
    local function updateSize()
        local textHeight = textLabel.TextBounds.Y
        textLabel.Size = UDim2.new(1, -12, 0, textHeight)
        container.Size = UDim2.new(1, 0, 0, textHeight + 6)
        
        -- Fire() metodu kaldırıldı, yerine doğrudan layout yenileme
        if self.Layout then
            self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
        end
    end
    
    textLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
    textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
    
    updateSize()
    
    label.Instance = container
    label.TextLabel = textLabel
    
    label.SetText = function(_, newText)
        textLabel.Text = newText
    end
    
    label.SetColor = function(_, color)
        textLabel.TextColor3 = color
    end
    
    label.SetFont = function(_, font)
        textLabel.Font = font
    end
    
    label.SetTextSize = function(_, size)
        textLabel.TextSize = size
    end
    
    return label
end

function section:AddColorPicker(name, defaultColor, callback)
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = name
    colorPickerFrame.Size = UDim2.new(1, -10, 0, 160)
    colorPickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    colorPickerFrame.BorderSizePixel = 0
    colorPickerFrame.Parent = self._container -- section içindeki GUI konteyner

    local corner = Instance.new("UICorner", colorPickerFrame)
    corner.CornerRadius = UDim.new(0, 8)

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Text = name or "Color Picker"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = colorPickerFrame

    -- Soldaki gradyan renk kutusu
    local palette = Instance.new("ImageButton")
    palette.Size = UDim2.new(0, 120, 0, 100)
    palette.Position = UDim2.new(0, 10, 0, 30)
    palette.Image = "rbxassetid://6020299385" -- örnek gradient texture
    palette.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    palette.BorderSizePixel = 0
    palette.Parent = colorPickerFrame

    -- Dikey Hue Slider
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 20, 0, 100)
    hueBar.Position = UDim2.new(0, 140, 0, 30)
    hueBar.BorderSizePixel = 0
    hueBar.Parent = colorPickerFrame

    local gradient = Instance.new("UIGradient", hueBar)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    })

    -- RGB ve HEX input kutuları
    local hexBox = Instance.new("TextBox")
    hexBox.PlaceholderText = "#FFFFFF"
    hexBox.Text = ""
    hexBox.Size = UDim2.new(0, 80, 0, 24)
    hexBox.Position = UDim2.new(0, 170, 0, 30)
    hexBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    hexBox.TextColor3 = Color3.new(1, 1, 1)
    hexBox.Font = Enum.Font.Code
    hexBox.TextSize = 14
    hexBox.Parent = colorPickerFrame

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 24)
    preview.Position = UDim2.new(0, 260, 0, 30)
    preview.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
    preview.BorderSizePixel = 0
    preview.Parent = colorPickerFrame

    local previewCorner = Instance.new("UICorner", preview)
    previewCorner.CornerRadius = UDim.new(0, 4)

    -- Onay butonu
    local selectBtn = Instance.new("TextButton")
    selectBtn.Text = "Select"
    selectBtn.Size = UDim2.new(0, 100, 0, 28)
    selectBtn.Position = UDim2.new(0, 170, 0, 70)
    selectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    selectBtn.TextColor3 = Color3.new(1, 1, 1)
    selectBtn.Font = Enum.Font.GothamSemibold
    selectBtn.TextSize = 14
    selectBtn.Parent = colorPickerFrame

    local btnCorner = Instance.new("UICorner", selectBtn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    -- Tıklama olayı (şimdilik placeholder)
    selectBtn.MouseButton1Click:Connect(function()
        local selected = preview.BackgroundColor3
        if callback then
            callback(selected)
        end
    end)

    return colorPickerFrame
end

return Library 