-- =============================================
-- NEXUS OS - NOTIFICATION SYSTEM
-- Arquivo: NotificationSystem.lua
-- Local: src/UI/NotificationSystem.lua
-- =============================================

local NotificationSystem = {
    Name = "NotificationSystem",
    Version = "2.0.0",
    Description = "Sistema avançado de notificações para Nexus OS",
    Author = "Nexus Team",
    
    Config = {},
    State = {
        Initialized = false,
        Notifications = {},
        Queue = {},
        ScreenGui = nil,
        NotificationContainer = nil,
        ActiveNotifications = 0,
        MaxNotifications = 5,
        Connections = {}
    },
    
    Dependencies = {"ThemeManager"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
NotificationSystem.DefaultConfig = {
    Position = "TopRight", -- TopRight, TopLeft, BottomRight, BottomLeft, TopCenter, BottomCenter
    MaxNotifications = 5,
    Spacing = 10,
    Width = 300,
    AnimationSpeed = 0.3,
    DefaultDuration = 5,
    Stacking = true,
    SoundEffects = true,
    VisualEffects = true,
    
    NotificationTypes = {
        INFO = {
            Color = Color3.fromRGB(52, 152, 219),
            Icon = "rbxassetid://10734987654",
            Sound = "rbxassetid://9090894989"
        },
        SUCCESS = {
            Color = Color3.fromRGB(46, 204, 113),
            Icon = "rbxassetid://10734988765",
            Sound = "rbxassetid://9090894990"
        },
        WARNING = {
            Color = Color3.fromRGB(241, 196, 15),
            Icon = "rbxassetid://10734989876",
            Sound = "rbxassetid://9090894991"
        },
        ERROR = {
            Color = Color3.fromRGB(231, 76, 60),
            Icon = "rbxassetid://10734990987",
            Sound = "rbxassetid://9090894992"
        },
        CUSTOM = {
            Color = Color3.fromRGB(155, 89, 182),
            Icon = "rbxassetid://10734992098",
            Sound = "rbxassetid://9090894993"
        }
    },
    
    Animations = {
        Entrance = "Slide", -- Slide, Fade, Scale, Bounce
        Exit = "Slide", -- Slide, Fade, Scale
        Hover = "Scale", -- Scale, Glow, None
        ProgressBar = true
    },
    
    Mobile = {
        Position = "TopCenter",
        Width = 280,
        MaxNotifications = 3,
        TouchDismiss = true
    }
}

-- ============ SISTEMA DE NOTIFICAÇÕES ============
local NotificationQueue = {
    Queue = {},
    Processing = false,
    Paused = false
}

function NotificationQueue:Add(notificationData)
    table.insert(self.Queue, notificationData)
    
    if not self.Processing and not self.Paused then
        self:ProcessNext()
    end
    
    return #self.Queue
end

function NotificationQueue:ProcessNext()
    if #self.Queue == 0 or self.Paused then
        self.Processing = false
        return
    end
    
    self.Processing = true
    
    local notificationData = table.remove(self.Queue, 1)
    
    -- Criar notificação
    local notification = NotificationSystem:CreateNotification(notificationData)
    if notification then
        -- Adicionar à lista ativa
        NotificationSystem.State.Notifications[notification.Id] = notification
        
        -- Iniciar timer de duração
        if notificationData.Duration and notificationData.Duration > 0 then
            notification:StartTimer()
        end
    end
    
    -- Processar próxima notificação após delay
    task.wait(0.1)
    self:ProcessNext()
end

function NotificationQueue:Clear()
    self.Queue = {}
end

function NotificationQueue:Pause()
    self.Paused = true
end

function NotificationQueue:Resume()
    self.Paused = false
    if #self.Queue > 0 then
        self:ProcessNext()
    end
end

function NotificationQueue:GetQueueLength()
    return #self.Queue
end

-- ============ CLASSE DE NOTIFICAÇÃO ============
local Notification = {}
Notification.__index = Notification

function Notification.new(data)
    local self = setmetatable({}, Notification)
    
    self.Id = data.Id or tostring(math.random(100000, 999999))
    self.Title = data.Title or "Notification"
    self.Text = data.Text or ""
    self.Type = data.Type or "INFO"
    self.Duration = data.Duration or NotificationSystem.Config.DefaultDuration
    self.Timestamp = os.time()
    self.Created = tick()
    
    -- Configurações do tipo
    local typeConfig = NotificationSystem.Config.NotificationTypes[self.Type] or 
                       NotificationSystem.Config.NotificationTypes.INFO
    
    self.Color = data.Color or typeConfig.Color
    self.Icon = data.Icon or typeConfig.Icon
    self.Sound = data.Sound or typeConfig.Sound
    
    -- Callbacks
    self.OnClick = data.OnClick
    self.OnDismiss = data.OnDismiss
    self.OnTimeout = data.OnTimeout
    
    -- Estado
    self.Visible = false
    self.Dismissed = false
    self.Pinned = data.Pinned or false
    self.Progress = 0
    self.Timer = nil
    self.Gui = nil
    
    return self
end

function Notification:CreateGui()
    if self.Gui then
        return self.Gui
    end
    
    local container = NotificationSystem.State.NotificationContainer
    if not container then
        return nil
    end
    
    -- Configurações
    local config = NotificationSystem.Config
    local width = config.Width
    local isMobile = NotificationSystem.State.IsMobile
    
    if isMobile then
        width = config.Mobile.Width
    end
    
    -- Criar frame principal
    local frame = Instance.new("Frame")
    frame.Name = "Notification_" .. self.Id
    frame.Size = UDim2.new(0, width, 0, 0)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.ZIndex = 1000
    
    -- Background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 0, 80)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    background.BackgroundTransparency = 0.1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = background
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Color
    stroke.Thickness = 2
    stroke.Parent = background
    
    -- Barra lateral colorida
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 4, 1, -16)
    accentBar.Position = UDim2.new(0, 6, 0, 8)
    accentBar.BackgroundColor3 = self.Color
    accentBar.BorderSizePixel = 0
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentBar
    
    -- Ícone
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 20, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Image = self.Icon
    icon.ImageColor3 = self.Color
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 0, 24)
    title.Position = UDim2.new(0, 60, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Texto
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Size = UDim2.new(1, -60, 0, 40)
    text.Position = UDim2.new(0, 60, 0, 36)
    text.BackgroundTransparency = 1
    text.Text = self.Text
    text.TextColor3 = Color3.fromRGB(200, 200, 200)
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Font = Enum.Font.Gotham
    text.TextWrapped = true
    text.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -30, 0, 12)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    
    -- Barra de progresso (para duração)
    if config.Animations.ProgressBar and self.Duration > 0 and not self.Pinned then
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(1, -12, 0, 2)
        progressBar.Position = UDim2.new(0, 6, 1, -6)
        progressBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        progressBar.BorderSizePixel = 0
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.CornerRadius = UDim.new(1, 0)
        progressCorner.Parent = progressBar
        
        local progressFill = Instance.new("Frame")
        progressFill.Name = "ProgressFill"
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        progressFill.BackgroundColor3 = self.Color
        progressFill.BorderSizePixel = 0
        
        local progressFillCorner = Instance.new("UICorner")
        progressFillCorner.CornerRadius = UDim.new(1, 0)
        progressFillCorner.Parent = progressFill
        
        progressFill.Parent = progressBar
        progressBar.Parent = background
    end
    
    -- Adicionar filhos
    accentBar.Parent = background
    icon.Parent = background
    title.Parent = background
    text.Parent = background
    closeButton.Parent = background
    background.Parent = frame
    
    -- Eventos
    closeButton.MouseButton1Click:Connect(function()
        self:Dismiss()
    end)
    
    background.MouseButton1Click:Connect(function()
        if self.OnClick then
            self.OnClick(self)
        end
    end)
    
    -- Hover effects
    if config.VisualEffects then
        background.MouseEnter:Connect(function()
            if not self.Dismissed then
                game:GetService("TweenService"):Create(
                    background,
                    TweenInfo.new(0.2),
                    {BackgroundTransparency = 0}
                ):Play()
            end
        end)
        
        background.MouseLeave:Connect(function()
            if not self.Dismissed then
                game:GetService("TweenService"):Create(
                    background,
                    TweenInfo.new(0.2),
                    {BackgroundTransparency = 0.1}
                ):Play()
            end
        end)
    end
    
    -- Para mobile: dismiss ao tocar (se configurado)
    if NotificationSystem.State.IsMobile and config.Mobile.TouchDismiss then
        local touchCount = 0
        local lastTouch = 0
        
        background.TouchTap:Connect(function()
            local now = tick()
            if now - lastTouch < 0.5 then
                touchCount = touchCount + 1
                if touchCount >= 2 then
                    self:Dismiss()
                end
            else
                touchCount = 1
            end
            lastTouch = now
        end)
    end
    
    frame.Parent = container
    self.Gui = frame
    
    return frame
end

function Notification:Show()
    if self.Dismissed or not self.Gui then
        return false
    end
    
    self.Visible = true
    
    -- Animação de entrada
    local animation = NotificationSystem.Config.Animations.Entrance
    local frame = self.Gui
    
    if animation == "Slide" then
        -- Posição inicial fora da tela
        local startPos = UDim2.new(1, 10, 0, 0)
        local endPos = UDim2.new(0, 0, 0, 0)
        
        if NotificationSystem.Config.Position == "TopRight" or 
           NotificationSystem.Config.Position == "BottomRight" then
            startPos = UDim2.new(1, 10, 0, 0)
            endPos = UDim2.new(0, 0, 0, 0)
        elseif NotificationSystem.Config.Position == "TopLeft" or 
               NotificationSystem.Config.Position == "BottomLeft" then
            startPos = UDim2.new(-1, -10, 0, 0)
            endPos = UDim2.new(0, 0, 0, 0)
        end
        
        frame.Position = startPos
        frame.Visible = true
        
        game:GetService("TweenService"):Create(
            frame,
            TweenInfo.new(NotificationSystem.Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = endPos}
        ):Play()
        
    elseif animation == "Fade" then
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = true
        
        game:GetService("TweenService"):Create(
            frame,
            TweenInfo.new(NotificationSystem.Config.AnimationSpeed),
            {BackgroundTransparency = 0}
        ):Play()
        
    elseif animation == "Scale" then
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.Size = UDim2.new(0, 0, 0, 80)
        frame.Visible = true
        
        game:GetService("TweenService"):Create(
            frame,
            TweenInfo.new(NotificationSystem.Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, NotificationSystem.Config.Width, 0, 80)}
        ):Play()
    end
    
    -- Som
    if NotificationSystem.Config.SoundEffects and self.Sound then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = self.Sound
            sound.Volume = 0.3
            sound.Parent = workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end)
    end
    
    -- Reorganizar notificações
    NotificationSystem:RearrangeNotifications()
    
    return true
end

function Notification:StartTimer()
    if self.Duration <= 0 or self.Pinned or self.Dismissed then
        return
    end
    
    local startTime = tick()
    local endTime = startTime + self.Duration
    
    -- Atualizar barra de progresso
    local function updateProgress()
        if not self.Gui or self.Dismissed then
            return
        end
        
        local currentTime = tick()
        local elapsed = currentTime - startTime
        self.Progress = elapsed / self.Duration
        
        -- Atualizar visual da barra de progresso
        local progressBar = self.Gui:FindFirstChild("Background"):FindFirstChild("ProgressBar")
        if progressBar then
            local progressFill = progressBar:FindFirstChild("ProgressFill")
            if progressFill then
                progressFill.Size = UDim2.new(self.Progress, 0, 1, 0)
            end
        end
        
        if currentTime >= endTime then
            self:Timeout()
            return
        end
    end
    
    -- Timer usando RunService
    self.Timer = game:GetService("RunService").RenderStepped:Connect(updateProgress)
end

function Notification:Timeout()
    if self.Dismissed then
        return
    end
    
    if self.OnTimeout then
        self.OnTimeout(self)
    end
    
    self:Dismiss()
end

function Notification:Dismiss()
    if self.Dismissed then
        return
    end
    
    self.Dismissed = true
    
    -- Parar timer
    if self.Timer then
        self.Timer:Disconnect()
        self.Timer = nil
    end
    
    -- Animação de saída
    local animation = NotificationSystem.Config.Animations.Exit
    local frame = self.Gui
    
    if frame then
        if animation == "Slide" then
            local endPos = UDim2.new(1, 10, 0, 0)
            
            if NotificationSystem.Config.Position == "TopLeft" or 
               NotificationSystem.Config.Position == "BottomLeft" then
                endPos = UDim2.new(-1, -10, 0, 0)
            end
            
            local tween = game:GetService("TweenService"):Create(
                frame,
                TweenInfo.new(NotificationSystem.Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = endPos}
            )
            
            tween:Play()
            tween.Completed:Wait()
            
        elseif animation == "Fade" then
            local tween = game:GetService("TweenService"):Create(
                frame,
                TweenInfo.new(NotificationSystem.Config.AnimationSpeed),
                {BackgroundTransparency = 1}
            )
            
            tween:Play()
            tween.Completed:Wait()
            
        elseif animation == "Scale" then
            local tween = game:GetService("TweenService"):Create(
                frame,
                TweenInfo.new(NotificationSystem.Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Size = UDim2.new(0, 0, 0, 80)}
            )
            
            tween:Play()
            tween.Completed:Wait()
        end
        
        frame:Destroy()
    end
    
    -- Remover da lista ativa
    NotificationSystem.State.Notifications[self.Id] = nil
    
    -- Callback
    if self.OnDismiss then
        self.OnDismiss(self)
    end
    
    -- Reorganizar notificações restantes
    NotificationSystem:RearrangeNotifications()
end

-- ============ FUNÇÕES PRINCIPAIS DO SISTEMA ============
function NotificationSystem:CreateNotification(data)
    local notification = Notification.new(data)
    
    -- Criar GUI
    local gui = notification:CreateGui()
    if not gui then
        return nil
    end
    
    -- Mostrar
    notification:Show()
    
    return notification
end

function NotificationSystem:Notify(data)
    if not self.State.Initialized then
        print("[NotificationSystem] Not initialized, queuing notification:", data.Title)
        table.insert(self.State.Queue, data)
        return nil
    end
    
    -- Validar dados
    data = data or {}
    data.Id = data.Id or tostring(math.random(100000, 999999))
    data.Title = data.Title or "Notification"
    data.Text = data.Text or ""
    data.Type = data.Type or "INFO"
    data.Duration = data.Duration or self.Config.DefaultDuration
    
    -- Adicionar à fila
    local queuePosition = NotificationQueue:Add(data)
    
    -- Log
    if _G.NexusOS and _G.NexusOS.Logger then
        _G.NexusOS.Logger:Log("INFO", 
            string.format("Notification queued: %s (%s)", data.Title, data.Type),
            "NotificationSystem")
    end
    
    return data.Id, queuePosition
end

function NotificationSystem:RearrangeNotifications()
    local container = self.State.NotificationContainer
    if not container then
        return
    end
    
    local notifications = {}
    
    -- Coletar notificações visíveis
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("Notification_") then
            table.insert(notifications, child)
        end
    end
    
    -- Ordenar por ordem de criação (mais antiga primeiro)
    table.sort(notifications, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    
    -- Reposicionar
    local spacing = self.Config.Spacing
    local position = self.Config.Position
    local isMobile = self.State.IsMobile
    
    if isMobile then
        spacing = spacing * 0.8
        position = self.Config.Mobile.Position
    end
    
    local startY = spacing
    local startX = spacing
    
    if position == "TopRight" then
        startX = container.AbsoluteSize.X - self.Config.Width - spacing
    elseif position == "TopCenter" then
        startX = (container.AbsoluteSize.X - self.Config.Width) / 2
    elseif position == "BottomRight" then
        startY = container.AbsoluteSize.Y - (80 * #notifications) - (spacing * (#notifications + 1))
    elseif position == "BottomLeft" then
        startY = container.AbsoluteSize.Y - (80 * #notifications) - (spacing * (#notifications + 1))
    elseif position == "BottomCenter" then
        startX = (container.AbsoluteSize.X - self.Config.Width) / 2
        startY = container.AbsoluteSize.Y - (80 * #notifications) - (spacing * (#notifications + 1))
    end
    
    for i, notification in ipairs(notifications) do
        local targetY = startY + ((i - 1) * (80 + spacing))
        
        game:GetService("TweenService"):Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, startX, 0, targetY)}
        ):Play()
        
        notification.LayoutOrder = i
    end
end

function NotificationSystem:DismissNotification(notificationId)
    local notification = self.State.Notifications[notificationId]
    if notification then
        notification:Dismiss()
        return true
    end
    
    -- Procurar na fila
    for i, queued in ipairs(NotificationQueue.Queue) do
        if queued.Id == notificationId then
            table.remove(NotificationQueue.Queue, i)
            return true
        end
    end
    
    return false
end

function NotificationSystem:DismissAll()
    -- Dismiss todas as notificações ativas
    for id, notification in pairs(self.State.Notifications) do
        notification:Dismiss()
    end
    
    -- Limpar fila
    NotificationQueue:Clear()
    
    return true
end

function NotificationSystem:PauseNotifications()
    NotificationQueue:Pause()
    return true
end

function NotificationSystem:ResumeNotifications()
    NotificationQueue:Resume()
    return true
end

function NotificationSystem:GetActiveNotifications()
    local active = {}
    
    for id, notification in pairs(self.State.Notifications) do
        table.insert(active, {
            Id = notification.Id,
            Title = notification.Title,
            Type = notification.Type,
            Duration = notification.Duration,
            Progress = notification.Progress,
            Timestamp = notification.Timestamp
        })
    end
    
    return active
end

function NotificationSystem:GetQueueLength()
    return NotificationQueue:GetQueueLength()
end

function NotificationSystem:CreateScreenGui()
    if self.State.ScreenGui then
        return self.State.ScreenGui
    end
    
    -- Criar ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusNotifications"
    screenGui.DisplayOrder = 1000
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    -- Container para notificações
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = screenGui
    
    -- Adicionar ao PlayerGui
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    screenGui.Parent = playerGui
    
    self.State.ScreenGui = screenGui
    self.State.NotificationContainer = container
    
    return screenGui
end

function NotificationSystem:Initialize()
    print("[NotificationSystem] Initializing...")
    
    -- Detectar se é mobile
    local UserInputService = game:GetService("UserInputService")
    self.State.IsMobile = UserInputService.TouchEnabled
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Ajustar para mobile
    if self.State.IsMobile then
        self.Config.Position = self.Config.Mobile.Position
        self.Config.Width = self.Config.Mobile.Width
        self.Config.MaxNotifications = self.Config.Mobile.MaxNotifications
    end
    
    -- Criar GUI
    self:CreateScreenGui()
    
    -- Processar notificações na fila
    for _, queued in ipairs(self.State.Queue) do
        NotificationQueue:Add(queued)
    end
    self.State.Queue = {}
    
    -- Configurar eventos do sistema
    if _G.NexusOS and _G.NexusOS.EventSystem then
        self.State.Connections.ThemeChanged = _G.NexusOS.EventSystem:AddListener(
            "ThemeChanged",
            function(themeName, theme)
                self:OnThemeChanged(theme)
            end
        )
    end
    
    self.State.Initialized = true
    
    print("[NotificationSystem] Initialization complete")
    
    return true
end

function NotificationSystem:OnThemeChanged(theme)
    -- Atualizar cores das notificações baseadas no tema
    if theme and theme.Colors then
        self.Config.NotificationTypes.INFO.Color = theme.Colors.Info or theme.Colors.Primary
        self.Config.NotificationTypes.SUCCESS.Color = theme.Colors.Success
        self.Config.NotificationTypes.WARNING.Color = theme.Colors.Warning
        self.Config.NotificationTypes.ERROR.Color = theme.Colors.Danger
    end
end

function NotificationSystem:Shutdown()
    print("[NotificationSystem] Shutting down...")
    
    -- Dismiss todas as notificações
    self:DismissAll()
    
    -- Desconectar conexões
    for _, connection in pairs(self.State.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Remover ScreenGui
    if self.State.ScreenGui then
        self.State.ScreenGui:Destroy()
        self.State.ScreenGui = nil
        self.State.NotificationContainer = nil
    end
    
    -- Limpar estado
    self.State.Initialized = false
    self.State.Notifications = {}
    self.State.Queue = {}
    self.State.ActiveNotifications = 0
    self.State.Connections = {}
    
    print("[NotificationSystem] Shutdown complete")
end

-- ============ FUNÇÕES DE CONVENIÊNCIA ============
function NotificationSystem:Info(title, text, duration)
    return self:Notify({
        Title = title,
        Text = text,
        Type = "INFO",
        Duration = duration
    })
end

function NotificationSystem:Success(title, text, duration)
    return self:Notify({
        Title = title,
        Text = text,
        Type = "SUCCESS",
        Duration = duration
    })
end

function NotificationSystem:Warning(title, text, duration)
    return self:Notify({
        Title = title,
        Text = text,
        Type = "WARNING",
        Duration = duration
    })
end

function NotificationSystem:Error(title, text, duration)
    return self:Notify({
        Title = title,
        Text = text,
        Type = "ERROR",
        Duration = duration
    })
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusNotifications then
    _G.NexusNotifications = NotificationSystem
end

return NotificationSystem
