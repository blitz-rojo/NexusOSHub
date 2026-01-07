-- =============================================
-- NEXUS OS - MOBILE BUTTON SYSTEM
-- Arquivo: MobileButton.lua
-- Local: src/UI/MobileButton.lua
-- =============================================

local MobileButton = {
    Name = "MobileButton",
    Version = "2.0.0",
    Description = "Sistema de interface para dispositivos móveis",
    Author = "Nexus Team",
    
    Config = {},
    State = {
        Initialized = false,
        Buttons = {},
        VirtualJoystick = nil,
        GestureRecognizer = nil,
        MobileMode = false,
        ScreenSize = Vector2.new(0, 0)
    },
    
    Dependencies = {"RayfieldAdapter"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
MobileButton.DefaultConfig = {
    FloatingButton = {
        Enabled = true,
        Position = "BottomRight",
        Offset = Vector2.new(-20, -20),
        Size = UDim2.new(0, 56, 0, 56),
        Icon = "rbxassetid://10734984567",
        BackgroundColor = Color3.fromRGB(52, 152, 219),
        BackgroundTransparency = 0.2,
        RippleEffect = true
    },
    VirtualJoystick = {
        Enabled = true,
        Position = "Left",
        Offset = Vector2.new(30, 0),
        Size = UDim2.new(0, 120, 0, 120),
        OuterColor = Color3.fromRGB(255, 255, 255),
        InnerColor = Color3.fromRGB(52, 152, 219),
        Transparency = 0.5,
        Deadzone = 0.2
    },
    ButtonPad = {
        Enabled = true,
        Position = "Right",
        Offset = Vector2.new(-30, 0),
        Size = UDim2.new(0, 180, 0, 180),
        ButtonSize = UDim2.new(0, 60, 0, 60),
        ButtonSpacing = 10,
        Buttons = {
            {Name = "A", Key = "Space", Icon = "↑"},
            {Name = "B", Key = "E", Icon = "E"},
            {Name = "X", Key = "R", Icon = "R"},
            {Name = "Y", Key = "F", Icon = "F"}
        }
    },
    Gestures = {
        Enabled = true,
        SwipeUp = "ToggleMenu",
        SwipeDown = "CloseMenu",
        SwipeLeft = "PreviousTab",
        SwipeRight = "NextTab",
        DoubleTap = "QuickAction",
        LongPress = "ContextMenu",
        Sensitivity = 1.0
    },
    Menu = {
        Enabled = true,
        Position = "Center",
        Size = UDim2.new(0.8, 0, 0.7, 0),
        BackgroundColor = Color3.fromRGB(30, 30, 30),
        BackgroundTransparency = 0.1,
        ButtonHeight = 40,
        ButtonSpacing = 5,
        AnimationSpeed = 0.3
    }
}

-- ============ SISTEMA DE BOTÃO FLUTUANTE ============
local FloatingButtonSystem = {
    Button = nil,
    Connections = {},
    State = {
        Visible = true,
        Dragging = false,
        DragStart = nil,
        OriginalPosition = nil
    }
}

function FloatingButtonSystem:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusMobileFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local button = Instance.new("ImageButton")
    button.Name = "FloatingButton"
    button.Size = MobileButton.Config.FloatingButton.Size
    button.BackgroundColor3 = MobileButton.Config.FloatingButton.BackgroundColor
    button.BackgroundTransparency = MobileButton.Config.FloatingButton.BackgroundTransparency
    button.Image = MobileButton.Config.FloatingButton.Icon
    button.ScaleType = Enum.ScaleType.Fit
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Posicionar
    local position = MobileButton.Config.FloatingButton.Position
    if position == "TopLeft" then
        button.Position = UDim2.new(0, 20, 0, 20)
    elseif position == "TopRight" then
        button.Position = UDim2.new(1, -20, 0, 20)
    elseif position == "BottomLeft" then
        button.Position = UDim2.new(0, 20, 1, -20)
    elseif position == "BottomRight" then
        button.Position = UDim2.new(1, -20, 1, -20)
    else -- Center
        button.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    
    -- Aplicar offset
    local offset = MobileButton.Config.FloatingButton.Offset
    button.Position = UDim2.new(
        button.Position.X.Scale,
        button.Position.X.Offset + offset.X,
        button.Position.Y.Scale,
        button.Position.Y.Offset + offset.Y
    )
    
    -- Estilo
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    -- Efeito de ripple
    if MobileButton.Config.FloatingButton.RippleEffect then
        button.MouseButton1Down:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Name = "Ripple"
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.7
            ripple.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = ripple
            
            ripple.Parent = button
            
            local tweenService = game:GetService("TweenService")
            local tween = tweenService:Create(ripple, TweenInfo.new(0.5), {
                Size = UDim2.new(2, 0, 2, 0),
                BackgroundTransparency = 1
            })
            
            tween:Play()
            tween.Completed:Connect(function()
                ripple:Destroy()
            end)
        end)
    end
    
    -- Interações
    self.Connections.ButtonClick = button.MouseButton1Click:Connect(function()
        MobileButton:ToggleMenu()
    end)
    
    -- Arrastar
    self.Connections.InputBegan = button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            self.State.Dragging = true
            self.State.DragStart = input.Position
            self.State.OriginalPosition = button.Position
        end
    end)
    
    self.Connections.InputChanged = button.InputChanged:Connect(function(input)
        if self.State.Dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - self.State.DragStart
            button.Position = UDim2.new(
                self.State.OriginalPosition.X.Scale,
                self.State.OriginalPosition.X.Offset + delta.X,
                self.State.OriginalPosition.Y.Scale,
                self.State.OriginalPosition.Y.Offset + delta.Y
            )
        end
    end)
    
    self.Connections.InputEnded = button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            self.State.Dragging = false
        end
    end)
    
    button.Parent = screenGui
    screenGui.Parent = game:GetService("CoreGui")
    
    self.Button = button
    self.ScreenGui = screenGui
    
    return button
end

function FloatingButtonSystem:Toggle(visible)
    if self.Button then
        self.Button.Visible = visible
        self.State.Visible = visible
    end
end

function FloatingButtonSystem:Destroy()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    self.Button = nil
    self.ScreenGui = nil
end

-- ============ SISTEMA DE JOYSTICK VIRTUAL ============
local VirtualJoystickSystem = {
    Joystick = nil,
    Connections = {},
    State = {
        Active = false,
        Position = Vector2.new(0, 0),
        Direction = Vector2.new(0, 0),
        Magnitude = 0
    }
}

function VirtualJoystickSystem:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusVirtualJoystick"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Base do joystick
    local base = Instance.new("Frame")
    base.Name = "JoystickBase"
    base.Size = MobileButton.Config.VirtualJoystick.Size
    base.BackgroundColor3 = MobileButton.Config.VirtualJoystick.OuterColor
    base.BackgroundTransparency = MobileButton.Config.VirtualJoystick.Transparency
    base.BorderSizePixel = 0
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Posicionar
    local position = MobileButton.Config.VirtualJoystick.Position
    if position == "Left" then
        base.Position = UDim2.new(0, 30, 0.5, 0)
    elseif position == "Right" then
        base.Position = UDim2.new(1, -30, 0.5, 0)
    else -- Center
        base.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    
    -- Aplicar offset
    local offset = MobileButton.Config.VirtualJoystick.Offset
    base.Position = UDim2.new(
        base.Position.X.Scale,
        base.Position.X.Offset + offset.X,
        base.Position.Y.Scale,
        base.Position.Y.Offset + offset.Y
    )
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = base
    
    -- Alça do joystick
    local handle = Instance.new("Frame")
    handle.Name = "JoystickHandle"
    handle.Size = UDim2.new(0.5, 0, 0.5, 0)
    handle.Position = UDim2.new(0.25, 0, 0.25, 0)
    handle.BackgroundColor3 = MobileButton.Config.VirtualJoystick.InnerColor
    handle.BackgroundTransparency = 0.3
    handle.BorderSizePixel = 0
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    handle.Parent = base
    base.Parent = screenGui
    screenGui.Parent = game:GetService("CoreGui")
    
    self.Joystick = {
        Base = base,
        Handle = handle,
        ScreenGui = screenGui
    }
    
    -- Conexões de input
    self.Connections.InputBegan = base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            self.State.Active = true
            self:UpdateJoystick(input.Position)
        end
    end)
    
    self.Connections.InputChanged = base.InputChanged:Connect(function(input)
        if self.State.Active and input.UserInputType == Enum.UserInputType.Touch then
            self:UpdateJoystick(input.Position)
        end
    end)
    
    self.Connections.InputEnded = base.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            self.State.Active = false
            self:ResetJoystick()
        end
    end)
    
    return self.Joystick
end

function VirtualJoystickSystem:UpdateJoystick(touchPosition)
    local base = self.Joystick.Base
    local handle = self.Joystick.Handle
    
    local basePosition = base.AbsolutePosition
    local baseSize = base.AbsoluteSize
    local center = basePosition + baseSize / 2
    
    local relative = touchPosition - center
    local maxDistance = baseSize.X / 2
    
    -- Calcular direção e magnitude
    local magnitude = math.min(relative.Magnitude, maxDistance)
    local direction = relative.Magnitude > 0 and relative.Unit or Vector2.new(0, 0)
    
    -- Aplicar deadzone
    local deadzone = MobileButton.Config.VirtualJoystick.Deadzone
    if magnitude < maxDistance * deadzone then
        magnitude = 0
        direction = Vector2.new(0, 0)
    end
    
    -- Atualizar posição da alça
    local handlePosition = direction * magnitude
    handle.Position = UDim2.new(
        0.5,
        handlePosition.X,
        0.5,
        handlePosition.Y
    )
    
    -- Atualizar estado
    self.State.Position = touchPosition
    self.State.Direction = direction
    self.State.Magnitude = magnitude / maxDistance
    
    -- Enviar input para o jogo
    self:SendMovementInput()
end

function VirtualJoystickSystem:ResetJoystick()
    local handle = self.Joystick.Handle
    
    -- Resetar posição da alça
    handle.Position = UDim2.new(0.25, 0, 0.25, 0)
    
    -- Resetar estado
    self.State.Direction = Vector2.new(0, 0)
    self.State.Magnitude = 0
    
    -- Parar movimento
    self:SendMovementInput()
end

function VirtualJoystickSystem:SendMovementInput()
    local direction = self.State.Direction
    local magnitude = self.State.Magnitude
    
    -- Simular input de teclado (WASD)
    local UserInputService = game:GetService("UserInputService")
    
    -- Esta é uma implementação simulada
    -- Em produção, enviaria inputs reais
    if magnitude > 0 then
        -- Calcular direções baseadas na câmera
        local camera = workspace.CurrentCamera
        if camera then
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            
            -- Mapear direção 2D para 3D
            local moveDirection = (forward * direction.Y) + (right * direction.X)
            
            -- Aqui você enviaria o movimento para o personagem
            -- Por simplicidade, apenas logamos
            print(string.format("Joystick: Direction=(%.2f, %.2f), Magnitude=%.2f", 
                direction.X, direction.Y, magnitude))
        end
    end
end

function VirtualJoystickSystem:Destroy()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    
    if self.Joystick and self.Joystick.ScreenGui then
        self.Joystick.ScreenGui:Destroy()
    end
    
    self.Joystick = nil
end

-- ============ SISTEMA DE RECONHECIMENTO DE GESTOS ============
local GestureRecognizer = {
    State = {
        LastTap = 0,
        TapPosition = Vector2.new(0, 0),
        SwipeStart = nil,
        SwipeDirection = nil,
        LongPressActive = false,
        LongPressTimer = nil
    },
    Thresholds = {
        DoubleTapTime = 0.3,
        SwipeThreshold = 50,
        LongPressTime = 0.5
    },
    Callbacks = {}
}

function GestureRecognizer:Initialize()
    local UserInputService = game:GetService("UserInputService")
    
    -- Input começou
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        
        local position = input.Position
        
        -- Tap simples
        local currentTime = tick()
        if currentTime - self.State.LastTap < self.Thresholds.DoubleTapTime then
            -- Double tap
            self:TriggerGesture("DoubleTap", position)
            self.State.LastTap = 0
        else
            self.State.LastTap = currentTime
            self.State.TapPosition = position
        end
        
        -- Iniciar swipe
        self.State.SwipeStart = position
        
        -- Iniciar long press
        self.State.LongPressActive = true
        self.State.LongPressTimer = tick()
    end)
    
    -- Input mudou
    UserInputService.InputChanged:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not self.State.SwipeStart then return end
        
        local currentPos = input.Position
        local delta = currentPos - self.State.SwipeStart
        
        -- Detectar swipe
        if delta.Magnitude > self.Thresholds.SwipeThreshold then
            self.State.LongPressActive = false
            
            -- Determinar direção
            local absX = math.abs(delta.X)
            local absY = math.abs(delta.Y)
            
            if absX > absY then
                self.State.SwipeDirection = delta.X > 0 and "Right" or "Left"
            else
                self.State.SwipeDirection = delta.Y > 0 and "Down" or "Up"
            end
        end
    end)
    
    -- Input terminou
    UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        
        local position = input.Position
        
        -- Processar swipe
        if self.State.SwipeDirection then
            self:TriggerGesture("Swipe" .. self.State.SwipeDirection, position)
            self.State.SwipeDirection = nil
        end
        
        -- Processar long press
        if self.State.LongPressActive then
            local pressTime = tick() - self.State.LongPressTimer
            if pressTime >= self.Thresholds.LongPressTime then
                self:TriggerGesture("LongPress", position)
            end
        end
        
        -- Resetar estado
        self.State.SwipeStart = nil
        self.State.LongPressActive = false
        self.State.LongPressTimer = nil
    end)
end

function GestureRecognizer:TriggerGesture(gestureName, position)
    print("[GestureRecognizer]", gestureName, "at", position)
    
    -- Executar callback se registrado
    if self.Callbacks[gestureName] then
        self.Callbacks[gestureName](position)
    end
    
    -- Executar ação mapeada
    local action = MobileButton.Config.Gestures[gestureName]
    if action then
        MobileButton:ExecuteGestureAction(action, position)
    end
end

function GestureRecognizer:RegisterCallback(gestureName, callback)
    self.Callbacks[gestureName] = callback
end

-- ============ SISTEMA DE MENU MOBILE ============
local MobileMenuSystem = {
    Menu = nil,
    State = {
        Visible = false,
        CurrentPage = 1,
        Pages = {}
    }
}

function MobileMenuSystem:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusMobileMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = false
    
    -- Container principal
    local container = Instance.new("Frame")
    container.Name = "MenuContainer"
    container.Size = MobileButton.Config.Menu.Size
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = MobileButton.Config.Menu.BackgroundColor
    container.BackgroundTransparency = MobileButton.Config.Menu.BackgroundTransparency
    container.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = container
    
    -- Cabeçalho
    local header = Instance.new("Frame")
    header.Name = "MenuHeader"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel")
    title.Name = "MenuTitle"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "NEXUS OS v18.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 5)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    closeButton.BackgroundTransparency = 0.2
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.5, 0)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        MobileMenuSystem:Hide()
    end)
    
    title.Parent = header
    closeButton.Parent = header
    header.Parent = container
    
    -- Área de conteúdo
    local content = Instance.new("ScrollingFrame")
    content.Name = "MenuContent"
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 5
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, MobileButton.Config.Menu.ButtonSpacing)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    content.Parent = container
    container.Parent = screenGui
    screenGui.Parent = game:GetService("CoreGui")
    
    self.Menu = {
        ScreenGui = screenGui,
        Container = container,
        Content = content,
        Header = header
    }
    
    return self.Menu
end

function MobileMenuSystem:Show()
    if not self.Menu then
        self:Create()
    end
    
    self.Menu.ScreenGui.Enabled = true
    self.State.Visible = true
    
    -- Animação de entrada
    local container = self.Menu.Container
    container.Size = UDim2.new(0, 0, 0, 0)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenService = game:GetService("TweenService")
    local tween = tweenService:Create(container, TweenInfo.new(0.3), {
        Size = MobileButton.Config.Menu.Size
    })
    
    tween:Play()
    
    -- Carregar conteúdo
    self:LoadMenuContent()
end

function MobileMenuSystem:Hide()
    if not self.Menu then
        return
    end
    
    -- Animação de saída
    local container = self.Menu.Container
    local tweenService = game:GetService("TweenService")
    local tween = tweenService:Create(container, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        self.Menu.ScreenGui.Enabled = false
        self.State.Visible = false
    end)
end

function MobileMenuSystem:LoadMenuContent()
    local content = self.Menu.Content
    if not content then
        return
    end
    
    -- Limpar conteúdo anterior
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Criar botões para módulos
    local modules = {
        {Name = "Physics & Movement", Module = "PhysicsAndMovement", Icon = "🏃"},
        {Name = "Visual Debugger", Module = "VisualDebugger", Icon = "👁️"},
        {Name = "Automation", Module = "AutomationAndInteraction", Icon = "⚙️"},
        {Name = "Player Utilities", Module = "PlayerAndUtility", Icon = "👤"},
        {Name = "Configuration", Module = "ConfigAndSystem", Icon = "⚙️"}
    }
    
    for _, module in ipairs(modules) do
        local button = Instance.new("TextButton")
        button.Name = module.Name
        button.Size = UDim2.new(1, 0, 0, MobileButton.Config.Menu.ButtonHeight)
        button.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        button.BackgroundTransparency = 0.3
        button.Text = string.format("%s %s", module.Icon, module.Name)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 16
        button.Font = Enum.Font.Gotham
        button.AutoButtonColor = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.1, 0)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            MobileButton:OpenModule(module.Module)
        end)
        
        button.Parent = content
    end
end

function MobileMenuSystem:OpenModule(moduleName)
    print("[MobileMenu] Opening module:", moduleName)
    
    -- Fechar menu
    self:Hide()
    
    -- Abrir módulo na UI principal
    if _G.NexusUI and _G.NexusUI.State.Window then
        -- Esta é uma implementação simulada
        print("Module would open:", moduleName)
    end
end

function MobileMenuSystem:Destroy()
    if self.Menu and self.Menu.ScreenGui then
        self.Menu.ScreenGui:Destroy()
    end
    
    self.Menu = nil
end

-- ============ FUNÇÕES PRINCIPAIS DO MOBILE BUTTON ============
function MobileButton:Initialize()
    print("[MobileButton] Initializing mobile interface...")
    
    -- Verificar se é mobile
    local UserInputService = game:GetService("UserInputService")
    self.State.MobileMode = UserInputService.TouchEnabled
    
    if not self.State.MobileMode then
        print("[MobileButton] Not a mobile device, skipping initialization")
        return false
    end
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Obter tamanho da tela
    self.State.ScreenSize = workspace.CurrentCamera.ViewportSize
    
    -- Inicializar sistemas
    if self.Config.FloatingButton.Enabled then
        FloatingButtonSystem:Create()
    end
    
    if self.Config.VirtualJoystick.Enabled then
        VirtualJoystickSystem:Create()
    end
    
    if self.Config.Gestures.Enabled then
        GestureRecognizer:Initialize()
        
        -- Registrar callbacks para gestos
        GestureRecognizer:RegisterCallback("SwipeUp", function()
            self:ExecuteGestureAction("ToggleMenu")
        end)
        
        GestureRecognizer:RegisterCallback("SwipeDown", function()
            self:ExecuteGestureAction("CloseMenu")
        end)
    end
    
    -- Criar menu (mas não mostrar ainda)
    MobileMenuSystem:Create()
    MobileMenuSystem:Hide()
    
    self.State.Initialized = true
    
    print("[MobileButton] Mobile interface initialized")
    
    return true
end

function MobileButton:ExecuteGestureAction(action, position)
    print("[MobileButton] Executing gesture action:", action)
    
    if action == "ToggleMenu" then
        self:ToggleMenu()
    elseif action == "CloseMenu" then
        MobileMenuSystem:Hide()
    elseif action == "PreviousTab" then
        -- Navegar para tab anterior
        print("Previous Tab")
    elseif action == "NextTab" then
        -- Navegar para próxima tab
        print("Next Tab")
    elseif action == "QuickAction" then
        -- Ação rápida (ex: ativar/desativar feature)
        print("Quick Action at", position)
    elseif action == "ContextMenu" then
        -- Mostrar menu contextual
        print("Context Menu at", position)
    end
end

function MobileButton:ToggleMenu()
    if MobileMenuSystem.State.Visible then
        MobileMenuSystem:Hide()
    else
        MobileMenuSystem:Show()
    end
end

function MobileButton:OpenModule(moduleName)
    MobileMenuSystem:OpenModule(moduleName)
end

function MobileButton:UpdateConfig(newConfig)
    for category, settings in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(settings) do
                self.Config[category][key] = value
            end
        end
    end
    
    -- Reaplicar configurações
    if self.State.Initialized then
        self:Shutdown()
        self:Initialize()
    end
    
    return true
end

function MobileButton:Shutdown()
    print("[MobileButton] Shutting down mobile interface...")
    
    -- Destruir sistemas
    FloatingButtonSystem:Destroy()
    VirtualJoystickSystem:Destroy()
    MobileMenuSystem:Destroy()
    
    -- Limpar estado
    self.State.Initialized = false
    self.State.MobileMode = false
    
    print("[MobileButton] Mobile interface shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusMobile then
    _G.NexusMobile = MobileButton
end

return MobileButton
