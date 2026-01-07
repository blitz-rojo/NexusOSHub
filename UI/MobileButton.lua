-- =============================================
-- NEXUS OS - MOBILE BUTTON SYSTEM
-- Arquivo: MobileButton.lua
-- Local: src/UI/MobileButton.lua
-- =============================================

local MobileButton = {
    Name = "MobileButton",
    Version = "2.0.0",
    Description = "Sistema de botões e controles para dispositivos móveis",
    Author = "Nexus Team",
    
    Config = {},
    State = {
        Initialized = false,
        Buttons = {},
        Joysticks = {},
        Gestures = {},
        Active = false,
        ScreenGui = nil,
        Connections = {}
    },
    
    Dependencies = {"RayfieldAdapter"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
MobileButton.DefaultConfig = {
    Layout = {
        Position = "BottomRight", -- BottomRight, BottomLeft, TopRight, TopLeft, Center
        Spacing = 10,
        ButtonSize = 56,
        ButtonRadius = 28,
        Opacity = 0.8,
        AnimationSpeed = 0.2
    },
    FloatingButton = {
        Enabled = true,
        Position = Vector2.new(0.9, 0.9), -- Posição relativa (0-1)
        Size = 56,
        Icon = "rbxassetid://10734987654",
        Color = Color3.fromRGB(52, 152, 219),
        AutoHide = false,
        HideDelay = 3
    },
    Joystick = {
        Enabled = true,
        Position = Vector2.new(0.1, 0.7),
        Size = 120,
        OuterColor = Color3.fromRGB(40, 40, 40),
        InnerColor = Color3.fromRGB(255, 255, 255),
        Opacity = 0.7,
        Deadzone = 0.1,
        MaxDistance = 50
    },
    ActionButtons = {
        Size = 48,
        Columns = 3,
        Rows = 3,
        Spacing = 5,
        Icons = {
            "rbxassetid://10734987654", -- Main
            "rbxassetid://10734988765", -- Visuals
            "rbxassetid://10734989876", -- Automation
            "rbxassetid://10734990987", -- Player
            "rbxassetid://10734992098", -- Config
            "rbxassetid://10734993209", -- Fly
            "rbxassetid://10734994310", -- Speed
            "rbxassetid://10734995421", -- ESP
            "rbxassetid://10734996532"  -- Menu
        }
    },
    Gestures = {
        Enabled = true,
        SwipeSensitivity = 50,
        TapMaxDuration = 0.3,
        DoubleTapInterval = 0.5,
        LongPressDuration = 1.0
    }
}

-- ============ SISTEMA DE DETECÇÃO DE DISPOSITIVO ============
local DeviceDetector = {
    DeviceType = "Unknown",
    ScreenSize = Vector2.new(0, 0),
    DPI = 1,
    TouchEnabled = false,
    GyroEnabled = false,
    AccelerometerEnabled = false
}

function DeviceDetector:Detect()
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    
    self.TouchEnabled = UserInputService.TouchEnabled
    self.GyroEnabled = UserInputService.GyroEnabled
    self.AccelerometerEnabled = UserInputService.AccelerometerEnabled
    
    -- Obter tamanho da tela
    local camera = workspace.CurrentCamera
    if camera then
        self.ScreenSize = camera.ViewportSize
    end
    
    -- Determinar tipo de dispositivo
    if self.TouchEnabled then
        if self.ScreenSize.X < 768 then -- Smartphone
            self.DeviceType = "Phone"
            self.DPI = 2
        elseif self.ScreenSize.X < 1024 then -- Tablet pequeno
            self.DeviceType = "TabletSmall"
            self.DPI = 1.5
        else -- Tablet grande
            self.DeviceType = "TabletLarge"
            self.DPI = 1.2
        end
    else
        self.DeviceType = "Desktop"
        self.DPI = 1
    end
    
    return self.DeviceType
end

function DeviceDetector:IsMobile()
    return self.TouchEnabled
end

function DeviceDetector:GetAdjustedSize(baseSize)
    return baseSize * self.DPI
end

function DeviceDetector:GetScreenCenter()
    return Vector2.new(self.ScreenSize.X / 2, self.ScreenSize.Y / 2)
end

-- ============ SISTEMA DE JOYSTICK VIRTUAL ============
local VirtualJoystick = {
    Joystick = nil,
    Outer = nil,
    Inner = nil,
    Position = Vector2.new(0, 0),
    Active = false,
    CurrentInput = Vector2.new(0, 0),
    TouchId = nil,
    Connection = nil
}

function VirtualJoystick:Create(position, size)
    if not DeviceDetector:IsMobile() then
        return nil, "Not a mobile device"
    end
    
    -- Criar container do joystick
    local screenGui = MobileButton.State.ScreenGui
    if not screenGui then
        return nil, "ScreenGui not created"
    end
    
    -- Criar parte externa
    local outer = Instance.new("Frame")
    outer.Name = "JoystickOuter"
    outer.Size = UDim2.new(0, size, 0, size)
    outer.Position = UDim2.new(position.X, 0, position.Y, 0)
    outer.BackgroundColor3 = MobileButton.Config.Joystick.OuterColor
    outer.BackgroundTransparency = 1 - MobileButton.Config.Joystick.Opacity
    outer.AnchorPoint = Vector2.new(0.5, 0.5)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = outer
    
    -- Criar parte interna
    local inner = Instance.new("Frame")
    inner.Name = "JoystickInner"
    inner.Size = UDim2.new(0, size * 0.5, 0, size * 0.5)
    inner.Position = UDim2.new(0.5, 0, 0.5, 0)
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.BackgroundColor3 = MobileButton.Config.Joystick.InnerColor
    inner.BackgroundTransparency = 0.2
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = inner
    
    inner.Parent = outer
    outer.Parent = screenGui
    
    self.Joystick = outer
    self.Outer = outer
    self.Inner = inner
    self.Position = position
    self.Size = size
    
    -- Configurar input
    self:SetupInput()
    
    MobileButton.State.Joysticks["Main"] = self
    
    return self
end

function VirtualJoystick:SetupInput()
    local UserInputService = game:GetService("UserInputService")
    
    self.Connection = UserInputService.TouchStarted:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Verificar se o toque está dentro do joystick
        local touchPosition = Vector2.new(input.Position.X, input.Position.Y)
        local joystickPosition = self.Outer.AbsolutePosition
        local joystickSize = self.Outer.AbsoluteSize
        
        local isWithin = touchPosition.X >= joystickPosition.X and
                         touchPosition.X <= joystickPosition.X + joystickSize.X and
                         touchPosition.Y >= joystickPosition.Y and
                         touchPosition.Y <= joystickPosition.Y + joystickSize.Y
        
        if isWithin then
            self.Active = true
            self.TouchId = input
            self:UpdateJoystick(touchPosition)
        end
    end)
    
    local movedConnection = UserInputService.TouchMoved:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if self.Active and self.TouchId == input then
            local touchPosition = Vector2.new(input.Position.X, input.Position.Y)
            self:UpdateJoystick(touchPosition)
        end
    end)
    
    local endedConnection = UserInputService.TouchEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if self.Active and self.TouchId == input then
            self:ResetJoystick()
        end
    end)
    
    table.insert(MobileButton.State.Connections, self.Connection)
    table.insert(MobileButton.State.Connections, movedConnection)
    table.insert(MobileButton.State.Connections, endedConnection)
end

function VirtualJoystick:UpdateJoystick(touchPosition)
    local joystickCenter = Vector2.new(
        self.Outer.AbsolutePosition.X + self.Outer.AbsoluteSize.X / 2,
        self.Outer.AbsolutePosition.Y + self.Outer.AbsoluteSize.Y / 2
    )
    
    -- Calcular direção
    local delta = touchPosition - joystickCenter
    local distance = delta.Magnitude
    local maxDistance = MobileButton.Config.Joystick.MaxDistance
    
    -- Aplicar deadzone
    if distance < MobileButton.Config.Joystick.Deadzone * maxDistance then
        self.CurrentInput = Vector2.new(0, 0)
        self.Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
        return
    end
    
    -- Limitar distância
    if distance > maxDistance then
        delta = delta.Unit * maxDistance
        distance = maxDistance
    end
    
    -- Calcular input normalizado
    self.CurrentInput = delta / maxDistance
    
    -- Atualizar posição visual
    local relativePosition = delta / maxDistance
    self.Inner.Position = UDim2.new(
        0.5, relativePosition.X * maxDistance,
        0.5, relativePosition.Y * maxDistance
    )
    
    -- Enviar input para o sistema de movimento
    self:SendInputToSystem()
end

function VirtualJoystick:SendInputToSystem()
    -- Enviar input para o módulo de física
    if _G.NexusModules and _G.NexusModules.PhysicsAndMovement then
        -- Esta é uma implementação simulada
        -- Em produção, enviaria o input para o sistema de movimento
    end
    
    -- Log do input (para debug)
    if MobileButton.Config.Debug then
        print(string.format("Joystick Input: X=%.2f, Y=%.2f", 
            self.CurrentInput.X, self.CurrentInput.Y))
    end
end

function VirtualJoystick:ResetJoystick()
    self.Active = false
    self.TouchId = nil
    self.CurrentInput = Vector2.new(0, 0)
    
    -- Animação de retorno
    local tweenInfo = TweenInfo.new(
        MobileButton.Config.Layout.AnimationSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = game:GetService("TweenService"):Create(
        self.Inner,
        tweenInfo,
        {Position = UDim2.new(0.5, 0, 0.5, 0)}
    )
    
    tween:Play()
end

function VirtualJoystick:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    if self.Joystick and self.Joystick.Parent then
        self.Joystick:Destroy()
    end
    
    self.Joystick = nil
    self.Outer = nil
    self.Inner = nil
end

-- ============ SISTEMA DE BOTÕES FLUTUANTES ============
local FloatingButtonSystem = {
    Buttons = {},
    MainButton = nil,
    MenuOpen = false,
    AnimationQueue = {}
}

function FloatingButtonSystem:CreateMainButton()
    if not DeviceDetector:IsMobile() then
        return nil, "Not a mobile device"
    end
    
    local screenGui = MobileButton.State.ScreenGui
    if not screenGui then
        return nil, "ScreenGui not created"
    end
    
    local config = MobileButton.Config.FloatingButton
    local size = DeviceDetector:GetAdjustedSize(config.Size)
    
    -- Criar botão principal
    local button = Instance.new("TextButton")
    button.Name = "FloatingMainButton"
    button.Size = UDim2.new(0, size, 0, size)
    button.Position = UDim2.new(config.Position.X, -size/2, config.Position.Y, -size/2)
    button.BackgroundColor3 = config.Color
    button.BackgroundTransparency = 0.2
    button.Text = ""
    button.ZIndex = 100
    
    -- Adicionar ícone
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.7, 0, 0.7, 0)
    icon.Position = UDim2.new(0.15, 0, 0.15, 0)
    icon.BackgroundTransparency = 1
    icon.Image = config.Icon
    icon.ImageColor3 = Color3.new(1, 1, 1)
    icon.Parent = button
    
    -- Estilização
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = button
    
    -- Eventos
    button.MouseButton1Click:Connect(function()
        self:OnMainButtonClick()
    end)
    
    button.Parent = screenGui
    
    self.MainButton = button
    self.Buttons["Main"] = button
    
    -- Configurar auto-hide
    if config.AutoHide then
        self:SetupAutoHide()
    end
    
    return button
end

function FloatingButtonSystem:OnMainButtonClick()
    self.MenuOpen = not self.MenuOpen
    
    if self.MenuOpen then
        self:OpenActionMenu()
    else
        self:CloseActionMenu()
    end
    
    -- Animar botão
    self:AnimateMainButton(self.MenuOpen)
end

function FloatingButtonSystem:AnimateMainButton(open)
    local button = self.MainButton
    if not button then return end
    
    local tweenInfo = TweenInfo.new(
        0.2,
        Enum.EasingStyle.Back,
        open and Enum.EasingDirection.Out or Enum.EasingDirection.In
    )
    
    local scale = open and 1.1 or 1.0
    local rotation = open and 45 or 0
    
    local tween = game:GetService("TweenService"):Create(
        button,
        tweenInfo,
        {
            Size = UDim2.new(0, button.AbsoluteSize.X * scale, 0, button.AbsoluteSize.Y * scale),
            Rotation = rotation
        }
    )
    
    tween:Play()
end

function FloatingButtonSystem:OpenActionMenu()
    local config = MobileButton.Config.ActionButtons
    local mainButton = self.MainButton
    local screenGui = MobileButton.State.ScreenGui
    
    if not mainButton or not screenGui then return end
    
    local mainPosition = Vector2.new(
        mainButton.AbsolutePosition.X + mainButton.AbsoluteSize.X / 2,
        mainButton.AbsolutePosition.Y + mainButton.AbsoluteSize.Y / 2
    )
    
    local size = DeviceDetector:GetAdjustedSize(config.Size)
    local spacing = DeviceDetector:GetAdjustedSize(config.Spacing)
    
    -- Calcular posições em círculo
    local radius = DeviceDetector:GetAdjustedSize(100)
    local count = #config.Icons
    
    for i = 1, count do
        local angle = (2 * math.pi / count) * (i - 1)
        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius
        
        local button = self:CreateActionButton(i, config.Icons[i])
        if button then
            -- Posição inicial (escondida atrás do botão principal)
            button.Position = UDim2.new(0, mainPosition.X - size/2, 0, mainPosition.Y - size/2)
            button.Visible = true
            
            -- Posição final
            local targetPosition = UDim2.new(
                0, mainPosition.X + x - size/2,
                0, mainPosition.Y + y - size/2
            )
            
            -- Animar
            self:AnimateButtonTo(button, targetPosition, i * 0.05)
        end
    end
end

function FloatingButtonSystem:CreateActionButton(index, icon)
    local config = MobileButton.Config.ActionButtons
    local size = DeviceDetector:GetAdjustedSize(config.Size)
    
    local button = Instance.new("TextButton")
    button.Name = "ActionButton_" .. index
    button.Size = UDim2.new(0, size, 0, size)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BackgroundTransparency = 0.3
    button.Text = ""
    button.Visible = false
    button.ZIndex = 99
    
    -- Ícone
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
    iconLabel.Position = UDim2.new(0.2, 0, 0.2, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = icon
    iconLabel.ImageColor3 = Color3.new(1, 1, 1)
    iconLabel.Parent = button
    
    -- Estilização
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = button
    
    -- Evento de clique
    button.MouseButton1Click:Connect(function()
        self:OnActionButtonClick(index)
    end)
    
    button.Parent = MobileButton.State.ScreenGui
    self.Buttons["Action_" .. index] = button
    
    return button
end

function FloatingButtonSystem:OnActionButtonClick(index)
    print("Action button clicked:", index)
    
    -- Executar ação baseada no índice
    local actions = {
        [1] = function() -- Main Menu
            if _G.NexusUI then
                _G.NexusUI:ToggleWindow()
            end
        end,
        [2] = function() -- Visuals
            if _G.NexusModules and _G.NexusModules.VisualDebugger then
                _G.NexusModules.VisualDebugger:ToggleFeature(1) -- ESP
            end
        end,
        [3] = function() -- Automation
            print("Automation button pressed")
        end,
        [4] = function() -- Player
            if _G.NexusModules and _G.NexusModules.PlayerAndUtility then
                _G.NexusModules.PlayerAndUtility:ToggleFeature(1) -- God Mode
            end
        end,
        [5] = function() -- Config
            if _G.NexusUI then
                _G.NexusUI:SwitchToTab("Configuration")
            end
        end,
        [6] = function() -- Fly
            if _G.NexusModules and _G.NexusModules.PhysicsAndMovement then
                _G.NexusModules.PhysicsAndMovement:ToggleFeature(1) -- Superman Flight
            end
        end,
        [7] = function() -- Speed
            if _G.NexusModules and _G.NexusModules.PhysicsAndMovement then
                _G.NexusModules.PhysicsAndMovement:ToggleFeature(3) -- Speed Control
            end
        end,
        [8] = function() -- ESP
            if _G.NexusModules and _G.NexusModules.VisualDebugger then
                _G.NexusModules.VisualDebugger:ToggleFeature(1) -- ESP Box
            end
        end,
        [9] = function() -- Menu
            self:CloseActionMenu()
            self.MenuOpen = false
            self:AnimateMainButton(false)
        end
    }
    
    if actions[index] then
        actions[index]()
    end
    
    -- Feedback visual
    self:AnimateButtonClick(self.Buttons["Action_" .. index])
end

function FloatingButtonSystem:AnimateButtonTo(button, targetPosition, delay)
    if not button then return end
    
    task.wait(delay or 0)
    
    local tweenInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )
    
    local tween = game:GetService("TweenService"):Create(
        button,
        tweenInfo,
        {Position = targetPosition}
    )
    
    tween:Play()
end

function FloatingButtonSystem:AnimateButtonClick(button)
    if not button then return end
    
    local originalSize = button.Size
    
    -- Animação de clique
    local tweenInfo = TweenInfo.new(
        0.1,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween1 = game:GetService("TweenService"):Create(
        button,
        tweenInfo,
        {Size = originalSize * 0.8}
    )
    
    local tween2 = game:GetService("TweenService"):Create(
        button,
        tweenInfo,
        {Size = originalSize}
    )
    
    tween1:Play()
    tween1.Completed:Wait()
    tween2:Play()
end

function FloatingButtonSystem:CloseActionMenu()
    local mainButton = self.MainButton
    if not mainButton then return end
    
    local mainPosition = Vector2.new(
        mainButton.AbsolutePosition.X + mainButton.AbsoluteSize.X / 2,
        mainButton.AbsolutePosition.Y + mainButton.AbsoluteSize.Y / 2
    )
    
    -- Animar todos os botões de volta para a posição principal
    for name, button in pairs(self.Buttons) do
        if name ~= "Main" then
            self:AnimateButtonTo(button, UDim2.new(0, mainPosition.X, 0, mainPosition.Y), 0)
            
            -- Remover após animação
            task.wait(0.3)
            if button and button.Parent then
                button:Destroy()
            end
        end
    end
    
    -- Limpar botões de ação
    for name, button in pairs(self.Buttons) do
        if name ~= "Main" then
            self.Buttons[name] = nil
        end
    end
end

function FloatingButtonSystem:SetupAutoHide()
    local config = MobileButton.Config.FloatingButton
    if not config.AutoHide then return end
    
    local button = self.MainButton
    if not button then return end
    
    local lastInteraction = tick()
    local hidden = false
    
    local function checkAutoHide()
        while button and button.Parent do
            local currentTime = tick()
            
            if currentTime - lastInteraction > config.HideDelay then
                if not hidden then
                    -- Esconder
                    button.Visible = false
                    hidden = true
                end
            else
                if hidden then
                    -- Mostrar
                    button.Visible = true
                    hidden = false
                end
            end
            
            task.wait(1)
        end
    end
    
    -- Atualizar tempo de interação
    button.MouseEnter:Connect(function()
        lastInteraction = tick()
    end)
    
    button.MouseButton1Click:Connect(function()
        lastInteraction = tick()
    end)
    
    -- Iniciar verificação
    task.spawn(checkAutoHide)
end

function FloatingButtonSystem:Destroy()
    for name, button in pairs(self.Buttons) do
        if button and button.Parent then
            button:Destroy()
        end
    end
    
    self.Buttons = {}
    self.MainButton = nil
    self.MenuOpen = false
end

-- ============ SISTEMA DE GESTOS ============
local GestureSystem = {
    ActiveGestures = {},
    TouchStartPositions = {},
    TouchStartTimes = {},
    LastTapTime = 0,
    LastTapPosition = Vector2.new(0, 0)
}

function GestureSystem:Initialize()
    if not DeviceDetector:IsMobile() then
        return false
    end
    
    local UserInputService = game:GetService("UserInputService")
    
    -- Touch Started
    local touchStarted = UserInputService.TouchStarted:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local touchId = tostring(input)
        local position = Vector2.new(input.Position.X, input.Position.Y)
        local time = tick()
        
        self.TouchStartPositions[touchId] = position
        self.TouchStartTimes[touchId] = time
        
        -- Verificar double tap
        if time - self.LastTapTime < MobileButton.Config.Gestures.DoubleTapInterval then
            local distance = (position - self.LastTapPosition).Magnitude
            if distance < 50 then -- pixels
                self:OnGesture("DoubleTap", position)
                self.LastTapTime = 0 -- Reset para evitar múltiplos triggers
                return
            end
        end
    end)
    
    -- Touch Ended
    local touchEnded = UserInputService.TouchEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local touchId = tostring(input)
        local startTime = self.TouchStartTimes[touchId]
        local startPos = self.TouchStartPositions[touchId]
        
        if not startTime or not startPos then return end
        
        local endTime = tick()
        local endPos = Vector2.new(input.Position.X, input.Position.Y)
        local duration = endTime - startTime
        local distance = (endPos - startPos).Magnitude
        
        -- Determinar tipo de gesto
        if duration < MobileButton.Config.Gestures.TapMaxDuration then
            if distance < 10 then -- Tap simples
                self.LastTapTime = endTime
                self.LastTapPosition = endPos
                self:OnGesture("Tap", endPos)
            end
        elseif duration > MobileButton.Config.Gestures.LongPressDuration then
            self:OnGesture("LongPress", endPos)
        end
        
        -- Limpar
        self.TouchStartPositions[touchId] = nil
        self.TouchStartTimes[touchId] = nil
    end)
    
    -- Touch Moved (para swipe)
    local touchMoved = UserInputService.TouchMoved:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local touchId = tostring(input)
        local startPos = self.TouchStartPositions[touchId]
        
        if not startPos then return end
        
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentPos - startPos
        
        -- Verificar se é um swipe
        if delta.Magnitude > MobileButton.Config.Gestures.SwipeSensitivity then
            local direction = "Unknown"
            
            if math.abs(delta.X) > math.abs(delta.Y) then
                direction = delta.X > 0 and "Right" or "Left"
            else
                direction = delta.Y > 0 and "Down" or "Up"
            end
            
            self:OnGesture("Swipe" .. direction, currentPos)
            
            -- Limpar para evitar múltiplos swipes
            self.TouchStartPositions[touchId] = nil
            self.TouchStartTimes[touchId] = nil
        end
    end)
    
    table.insert(MobileButton.State.Connections, touchStarted)
    table.insert(MobileButton.State.Connections, touchEnded)
    table.insert(MobileButton.State.Connections, touchMoved)
    
    return true
end

function GestureSystem:OnGesture(gestureType, position)
    print("Gesture detected:", gestureType, "at", position)
    
    -- Mapear gestos para ações
    local gestureActions = {
        SwipeUp = function()
            if _G.NexusUI then
                _G.NexusUI:ToggleWindow()
            end
        end,
        SwipeDown = function()
            if MobileButton.State.Active then
                MobileButton:ToggleVisibility(false)
            end
        end,
        SwipeLeft = function()
            if _G.NexusUI then
                _G.NexusUI:SwitchToTab("Visuals")
            end
        end,
        SwipeRight = function()
            if _G.NexusUI then
                _G.NexusUI:SwitchToTab("Player")
            end
        end,
        DoubleTap = function()
            -- Toggle joystick visibility
            local joystick = MobileButton.State.Joysticks["Main"]
            if joystick and joystick.Joystick then
                joystick.Joystick.Visible = not joystick.Joystick.Visible
            end
        end,
        LongPress = function()
            -- Mostrar menu rápido
            FloatingButtonSystem:OnMainButtonClick()
        end
    }
    
    if gestureActions[gestureType] then
        gestureActions[gestureType]()
    end
    
    -- Notificar outros sistemas
    if _G.NexusOS and _G.NexusOS.EventSystem then
        _G.NexusOS.EventSystem:Trigger("GestureDetected", gestureType, position)
    end
end

function GestureSystem:Destroy()
    self.ActiveGestures = {}
    self.TouchStartPositions = {}
    self.TouchStartTimes = {}
end

-- ============ FUNÇÕES PRINCIPAIS DO SISTEMA MOBILE ============
function MobileButton:CreateScreenGui()
    if self.State.ScreenGui then
        return self.State.ScreenGui
    end
    
    -- Criar ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusMobileUI"
    screenGui.DisplayOrder = 100
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Adicionar ao PlayerGui
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    screenGui.Parent = playerGui
    
    self.State.ScreenGui = screenGui
    
    return screenGui
end

function MobileButton:Initialize()
    print("[MobileButton] Initializing mobile interface...")
    
    -- Detectar dispositivo
    DeviceDetector:Detect()
    
    if not DeviceDetector:IsMobile() then
        print("[MobileButton] Not a mobile device, skipping initialization")
        return false
    end
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Ajustar configurações baseadas no dispositivo
    if DeviceDetector.DeviceType == "Phone" then
        self.Config.FloatingButton.Size = 50
        self.Config.ActionButtons.Size = 42
        self.Config.Joystick.Size = 100
    elseif DeviceDetector.DeviceType == "TabletSmall" then
        self.Config.FloatingButton.Size = 60
        self.Config.ActionButtons.Size = 52
        self.Config.Joystick.Size = 140
    end
    
    -- Criar ScreenGui
    self:CreateScreenGui()
    
    -- Inicializar sistemas
    if self.Config.Joystick.Enabled then
        local joystickPosition = self.Config.Joystick.Position
        local screenSize = DeviceDetector.ScreenSize
        local absolutePosition = Vector2.new(
            screenSize.X * joystickPosition.X,
            screenSize.Y * joystickPosition.Y
        )
        
        VirtualJoystick:Create(absolutePosition, DeviceDetector:GetAdjustedSize(self.Config.Joystick.Size))
    end
    
    if self.Config.FloatingButton.Enabled then
        FloatingButtonSystem:CreateMainButton()
    end
    
    if self.Config.Gestures.Enabled then
        GestureSystem:Initialize()
    end
    
    self.State.Active = true
    self.State.Initialized = true
    
    print("[MobileButton] Mobile interface initialized for", DeviceDetector.DeviceType)
    
    return true
end

function MobileButton:ToggleVisibility(visible)
    if visible == nil then
        visible = not self.State.Active
    end
    
    self.State.Active = visible
    
    if self.State.ScreenGui then
        self.State.ScreenGui.Enabled = visible
    end
    
    -- Notificar outros sistemas
    if _G.NexusOS and _G.NexusOS.EventSystem then
        _G.NexusOS.EventSystem:Trigger("MobileUIToggled", visible)
    end
    
    return visible
end

function MobileButton:UpdateLayout()
    -- Atualizar layout baseado na orientação da tela
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenSize = camera.ViewportSize
    
    -- Atualizar posições relativas
    -- (implementação simplificada)
    
    return true
end

function MobileButton:Shutdown()
    print("[MobileButton] Shutting down mobile interface...")
    
    -- Destruir sistemas
    VirtualJoystick:Destroy()
    FloatingButtonSystem:Destroy()
    GestureSystem:Destroy()
    
    -- Desconectar conexões
    for _, connection in ipairs(self.State.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Remover ScreenGui
    if self.State.ScreenGui then
        self.State.ScreenGui:Destroy()
        self.State.ScreenGui = nil
    end
    
    -- Limpar estado
    self.State.Initialized = false
    self.State.Active = false
    self.State.Buttons = {}
    self.State.Joysticks = {}
    self.State.Gestures = {}
    self.State.Connections = {}
    
    print("[MobileButton] Mobile interface shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusMobile then
    _G.NexusMobile = MobileButton
end

return MobileButton
