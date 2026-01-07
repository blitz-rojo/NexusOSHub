
-- =============================================
-- NEXUS OS - THEME MANAGER
-- Arquivo: ThemeManager.lua
-- Local: src/UI/ThemeManager.lua
-- =============================================

local ThemeManager = {
    Name = "ThemeManager",
    Version = "2.0.0",
    Description = "Sistema avançado de gerenciamento de temas para Nexus OS",
    Author = "Nexus Team",
    
    Config = {},
    State = {
        Initialized = false,
        CurrentTheme = "Dark",
        Themes = {},
        ThemeObjects = {},
        CustomColors = {},
        GradientPresets = {},
        Animations = {},
        Fonts = {}
    },
    
    Dependencies = {"RayfieldAdapter"}
}

-- ============ DEFINIÇÃO DE TEMAS PRÉ-DEFINIDOS ============
ThemeManager.DefaultThemes = {
    Dark = {
        Name = "Dark",
        Type = "Dark",
        Colors = {
            Primary = Color3.fromRGB(52, 152, 219),
            Secondary = Color3.fromRGB(46, 204, 113),
            Accent = Color3.fromRGB(155, 89, 182),
            Danger = Color3.fromRGB(231, 76, 60),
            Warning = Color3.fromRGB(241, 196, 15),
            Success = Color3.fromRGB(46, 204, 113),
            Info = Color3.fromRGB(52, 152, 219),
            
            Background = {
                Primary = Color3.fromRGB(25, 25, 25),
                Secondary = Color3.fromRGB(40, 40, 40),
                Tertiary = Color3.fromRGB(60, 60, 60),
                Header = Color3.fromRGB(30, 30, 30),
                Footer = Color3.fromRGB(35, 35, 35)
            },
            
            Text = {
                Primary = Color3.fromRGB(240, 240, 240),
                Secondary = Color3.fromRGB(200, 200, 200),
                Disabled = Color3.fromRGB(150, 150, 150),
                Link = Color3.fromRGB(52, 152, 219),
                Error = Color3.fromRGB(231, 76, 60),
                Success = Color3.fromRGB(46, 204, 113)
            },
            
            Border = {
                Primary = Color3.fromRGB(60, 60, 60),
                Secondary = Color3.fromRGB(80, 80, 80),
                Focus = Color3.fromRGB(52, 152, 219),
                Error = Color3.fromRGB(231, 76, 60)
            },
            
            Button = {
                Primary = Color3.fromRGB(52, 152, 219),
                PrimaryHover = Color3.fromRGB(41, 128, 185),
                PrimaryText = Color3.fromRGB(255, 255, 255),
                
                Secondary = Color3.fromRGB(108, 117, 125),
                SecondaryHover = Color3.fromRGB(84, 91, 98),
                SecondaryText = Color3.fromRGB(255, 255, 255),
                
                Success = Color3.fromRGB(46, 204, 113),
                SuccessHover = Color3.fromRGB(39, 174, 96),
                SuccessText = Color3.fromRGB(255, 255, 255),
                
                Danger = Color3.fromRGB(231, 76, 60),
                DangerHover = Color3.fromRGB(192, 57, 43),
                DangerText = Color3.fromRGB(255, 255, 255),
                
                Warning = Color3.fromRGB(241, 196, 15),
                WarningHover = Color3.fromRGB(230, 126, 34),
                WarningText = Color3.fromRGB(0, 0, 0)
            },
            
            Input = {
                Background = Color3.fromRGB(45, 45, 45),
                BackgroundHover = Color3.fromRGB(50, 50, 50),
                BackgroundFocus = Color3.fromRGB(55, 55, 55),
                Border = Color3.fromRGB(80, 80, 80),
                BorderHover = Color3.fromRGB(100, 100, 100),
                BorderFocus = Color3.fromRGB(52, 152, 219),
                Text = Color3.fromRGB(240, 240, 240),
                Placeholder = Color3.fromRGB(150, 150, 150)
            },
            
            Card = {
                Background = Color3.fromRGB(35, 35, 35),
                Border = Color3.fromRGB(60, 60, 60),
                Shadow = Color3.fromRGB(0, 0, 0, 0.3)
            },
            
            Slider = {
                Track = Color3.fromRGB(60, 60, 60),
                TrackFill = Color3.fromRGB(52, 152, 219),
                Thumb = Color3.fromRGB(240, 240, 240),
                ThumbHover = Color3.fromRGB(255, 255, 255)
            },
            
            Toggle = {
                OffBackground = Color3.fromRGB(60, 60, 60),
                OnBackground = Color3.fromRGB(46, 204, 113),
                Thumb = Color3.fromRGB(240, 240, 240),
                Border = Color3.fromRGB(80, 80, 80)
            }
        },
        
        Properties = {
            Transparency = 0.95,
            Blur = 0,
            ShadowSize = 5,
            ShadowTransparency = 0.5,
            BorderSize = 1,
            BorderRadius = 8,
            AnimationSpeed = 1,
            FontSize = 14,
            LineHeight = 1.5
        },
        
        Fonts = {
            Primary = "Gotham",
            Secondary = "Roboto",
            Monospace = "RobotoMono",
            Icons = "FontAwesome"
        },
        
        Effects = {
            HoverEffect = "Lighten",
            ActiveEffect = "Darken",
            FocusEffect = "Glow",
            TransitionEffect = "Fade",
            RippleEffect = true,
            GradientEffects = false
        }
    },
    
    Light = {
        Name = "Light",
        Type = "Light",
        Colors = {
            Primary = Color3.fromRGB(41, 128, 185),
            Secondary = Color3.fromRGB(39, 174, 96),
            Accent = Color3.fromRGB(142, 68, 173),
            Danger = Color3.fromRGB(192, 57, 43),
            Warning = Color3.fromRGB(230, 126, 34),
            Success = Color3.fromRGB(39, 174, 96),
            Info = Color3.fromRGB(41, 128, 185),
            
            Background = {
                Primary = Color3.fromRGB(240, 240, 240),
                Secondary = Color3.fromRGB(255, 255, 255),
                Tertiary = Color3.fromRGB(245, 245, 245),
                Header = Color3.fromRGB(250, 250, 250),
                Footer = Color3.fromRGB(235, 235, 235)
            },
            
            Text = {
                Primary = Color3.fromRGB(30, 30, 30),
                Secondary = Color3.fromRGB(80, 80, 80),
                Disabled = Color3.fromRGB(150, 150, 150),
                Link = Color3.fromRGB(41, 128, 185),
                Error = Color3.fromRGB(192, 57, 43),
                Success = Color3.fromRGB(39, 174, 96)
            },
            
            Border = {
                Primary = Color3.fromRGB(220, 220, 220),
                Secondary = Color3.fromRGB(200, 200, 200),
                Focus = Color3.fromRGB(41, 128, 185),
                Error = Color3.fromRGB(192, 57, 43)
            },
            
            Button = {
                Primary = Color3.fromRGB(41, 128, 185),
                PrimaryHover = Color3.fromRGB(52, 152, 219),
                PrimaryText = Color3.fromRGB(255, 255, 255),
                
                Secondary = Color3.fromRGB(108, 117, 125),
                SecondaryHover = Color3.fromRGB(134, 142, 150),
                SecondaryText = Color3.fromRGB(255, 255, 255),
                
                Success = Color3.fromRGB(39, 174, 96),
                SuccessHover = Color3.fromRGB(46, 204, 113),
                SuccessText = Color3.fromRGB(255, 255, 255),
                
                Danger = Color3.fromRGB(192, 57, 43),
                DangerHover = Color3.fromRGB(231, 76, 60),
                DangerText = Color3.fromRGB(255, 255, 255),
                
                Warning = Color3.fromRGB(230, 126, 34),
                WarningHover = Color3.fromRGB(241, 196, 15),
                WarningText = Color3.fromRGB(0, 0, 0)
            },
            
            Input = {
                Background = Color3.fromRGB(255, 255, 255),
                BackgroundHover = Color3.fromRGB(250, 250, 250),
                BackgroundFocus = Color3.fromRGB(245, 245, 245),
                Border = Color3.fromRGB(220, 220, 220),
                BorderHover = Color3.fromRGB(200, 200, 200),
                BorderFocus = Color3.fromRGB(41, 128, 185),
                Text = Color3.fromRGB(30, 30, 30),
                Placeholder = Color3.fromRGB(150, 150, 150)
            },
            
            Card = {
                Background = Color3.fromRGB(255, 255, 255),
                Border = Color3.fromRGB(220, 220, 220),
                Shadow = Color3.fromRGB(0, 0, 0, 0.1)
            },
            
            Slider = {
                Track = Color3.fromRGB(220, 220, 220),
                TrackFill = Color3.fromRGB(41, 128, 185),
                Thumb = Color3.fromRGB(255, 255, 255),
                ThumbHover = Color3.fromRGB(245, 245, 245)
            },
            
            Toggle = {
                OffBackground = Color3.fromRGB(220, 220, 220),
                OnBackground = Color3.fromRGB(39, 174, 96),
                Thumb = Color3.fromRGB(255, 255, 255),
                Border = Color3.fromRGB(200, 200, 200)
            }
        },
        
        Properties = {
            Transparency = 0.98,
            Blur = 0.2,
            ShadowSize = 3,
            ShadowTransparency = 0.3,
            BorderSize = 1,
            BorderRadius = 6,
            AnimationSpeed = 1.2,
            FontSize = 14,
            LineHeight = 1.5
        },
        
        Fonts = {
            Primary = "SourceSans",
            Secondary = "Roboto",
            Monospace = "RobotoMono",
            Icons = "FontAwesome"
        },
        
        Effects = {
            HoverEffect = "Darken",
            ActiveEffect = "Lighten",
            FocusEffect = "Glow",
            TransitionEffect = "Fade",
            RippleEffect = true,
            GradientEffects = true
        }
    },
    
    Blue = {
        Name = "Blue",
        Type = "Dark",
        Colors = {
            Primary = Color3.fromRGB(86, 152, 255),
            Secondary = Color3.fromRGB(72, 219, 176),
            Accent = Color3.fromRGB(255, 96, 122),
            Danger = Color3.fromRGB(255, 96, 122),
            Warning = Color3.fromRGB(255, 193, 86),
            Success = Color3.fromRGB(72, 219, 176),
            Info = Color3.fromRGB(86, 152, 255),
            
            Background = {
                Primary = Color3.fromRGB(15, 30, 50),
                Secondary = Color3.fromRGB(25, 45, 70),
                Tertiary = Color3.fromRGB(35, 60, 90),
                Header = Color3.fromRGB(20, 40, 65),
                Footer = Color3.fromRGB(10, 25, 45)
            },
            
            Text = {
                Primary = Color3.fromRGB(220, 230, 255),
                Secondary = Color3.fromRGB(180, 200, 230),
                Disabled = Color3.fromRGB(120, 140, 170),
                Link = Color3.fromRGB(86, 152, 255),
                Error = Color3.fromRGB(255, 96, 122),
                Success = Color3.fromRGB(72, 219, 176)
            },
            
            Border = {
                Primary = Color3.fromRGB(40, 65, 100),
                Secondary = Color3.fromRGB(60, 85, 120),
                Focus = Color3.fromRGB(86, 152, 255),
                Error = Color3.fromRGB(255, 96, 122)
            },
            
            Button = {
                Primary = Color3.fromRGB(86, 152, 255),
                PrimaryHover = Color3.fromRGB(106, 172, 255),
                PrimaryText = Color3.fromRGB(255, 255, 255),
                
                Secondary = Color3.fromRGB(72, 219, 176),
                SecondaryHover = Color3.fromRGB(92, 239, 196),
                SecondaryText = Color3.fromRGB(15, 30, 50),
                
                Success = Color3.fromRGB(72, 219, 176),
                SuccessHover = Color3.fromRGB(92, 239, 196),
                SuccessText = Color3.fromRGB(15, 30, 50),
                
                Danger = Color3.fromRGB(255, 96, 122),
                DangerHover = Color3.fromRGB(255, 116, 142),
                DangerText = Color3.fromRGB(255, 255, 255),
                
                Warning = Color3.fromRGB(255, 193, 86),
                WarningHover = Color3.fromRGB(255, 213, 106),
                WarningText = Color3.fromRGB(15, 30, 50)
            },
            
            Input = {
                Background = Color3.fromRGB(35, 60, 90),
                BackgroundHover = Color3.fromRGB(40, 70, 105),
                BackgroundFocus = Color3.fromRGB(45, 80, 120),
                Border = Color3.fromRGB(60, 85, 120),
                BorderHover = Color3.fromRGB(80, 105, 140),
                BorderFocus = Color3.fromRGB(86, 152, 255),
                Text = Color3.fromRGB(220, 230, 255),
                Placeholder = Color3.fromRGB(120, 140, 170)
            },
            
            Card = {
                Background = Color3.fromRGB(30, 55, 85),
                Border = Color3.fromRGB(50, 75, 110),
                Shadow = Color3.fromRGB(0, 10, 30, 0.5)
            },
            
            Slider = {
                Track = Color3.fromRGB(50, 75, 110),
                TrackFill = Color3.fromRGB(86, 152, 255),
                Thumb = Color3.fromRGB(220, 230, 255),
                ThumbHover = Color3.fromRGB(255, 255, 255)
            },
            
            Toggle = {
                OffBackground = Color3.fromRGB(50, 75, 110),
                OnBackground = Color3.fromRGB(72, 219, 176),
                Thumb = Color3.fromRGB(220, 230, 255),
                Border = Color3.fromRGB(70, 95, 130)
            }
        },
        
        Properties = {
            Transparency = 0.95,
            Blur = 0.1,
            ShadowSize = 8,
            ShadowTransparency = 0.4,
            BorderSize = 1,
            BorderRadius = 10,
            AnimationSpeed = 0.8,
            FontSize = 14,
            LineHeight = 1.5
        },
        
        Fonts = {
            Primary = "Gotham",
            Secondary = "Roboto",
            Monospace = "FiraCode",
            Icons = "MaterialIcons"
        },
        
        Effects = {
            HoverEffect = "Glow",
            ActiveEffect = "Pulse",
            FocusEffect = "Glow",
            TransitionEffect = "Slide",
            RippleEffect = true,
            GradientEffects = true
        }
    }
}

-- ============ SISTEMA DE GRADIENTES ============
local GradientSystem = {
    Presets = {
        Ocean = {
            Colors = {
                Color3.fromRGB(0, 184, 217),
                Color3.fromRGB(0, 140, 255),
                Color3.fromRGB(0, 89, 255)
            },
            Rotation = 45,
            Transparency = 0.2
        },
        Sunset = {
            Colors = {
                Color3.fromRGB(255, 94, 98),
                Color3.fromRGB(255, 153, 102),
                Color3.fromRGB(255, 201, 99)
            },
            Rotation = 135,
            Transparency = 0.3
        },
        Forest = {
            Colors = {
                Color3.fromRGB(33, 147, 88),
                Color3.fromRGB(39, 174, 96),
                Color3.fromRGB(111, 207, 151)
            },
            Rotation = 90,
            Transparency = 0.2
        },
        Galaxy = {
            Colors = {
                Color3.fromRGB(67, 97, 238),
                Color3.fromRGB(155, 81, 224),
                Color3.fromRGB(41, 205, 255)
            },
            Rotation = 180,
            Transparency = 0.4
        }
    },
    
    ActiveGradients = {},
    GradientCache = {}
}

function GradientSystem:CreateGradient(name, colors, rotation, transparency)
    local gradient = {
        Name = name,
        Colors = colors or {Color3.new(1, 1, 1), Color3.new(0.5, 0.5, 0.5)},
        Rotation = rotation or 0,
        Transparency = transparency or 0,
        UIGradient = nil
    }
    
    self.ActiveGradients[name] = gradient
    return gradient
end

function GradientSystem:ApplyGradientToObject(object, gradientName)
    if not object then
        return nil, "Object is nil"
    end
    
    local gradient = self.ActiveGradients[gradientName]
    if not gradient then
        gradient = self.Presets[gradientName]
        if not gradient then
            return nil, "Gradient not found"
        end
    end
    
    -- Criar ou reutilizar UIGradient
    local uiGradient = object:FindFirstChild("NexusGradient")
    if not uiGradient then
        uiGradient = Instance.new("UIGradient")
        uiGradient.Name = "NexusGradient"
    end
    
    -- Configurar gradiente
    uiGradient.Color = ColorSequence.new(gradient.Colors)
    uiGradient.Rotation = gradient.Rotation
    uiGradient.Transparency = NumberSequence.new(gradient.Transparency)
    uiGradient.Enabled = true
    
    uiGradient.Parent = object
    
    gradient.UIGradient = uiGradient
    
    return uiGradient
end

function GradientSystem:RemoveGradientFromObject(object)
    if not object then
        return false
    end
    
    local gradient = object:FindFirstChild("NexusGradient")
    if gradient then
        gradient:Destroy()
        return true
    end
    
    return false
end

function GradientSystem:UpdateGradient(gradientName, newProperties)
    local gradient = self.ActiveGradients[gradientName]
    if not gradient then
        return false, "Gradient not found"
    end
    
    -- Atualizar propriedades
    for key, value in pairs(newProperties) do
        if gradient[key] ~= nil then
            gradient[key] = value
        end
    end
    
    -- Atualizar UIGradient se existir
    if gradient.UIGradient and gradient.UIGradient.Parent then
        if newProperties.Colors then
            gradient.UIGradient.Color = ColorSequence.new(newProperties.Colors)
        end
        
        if newProperties.Rotation then
            gradient.UIGradient.Rotation = newProperties.Rotation
        end
        
        if newProperties.Transparency then
            gradient.UIGradient.Transparency = NumberSequence.new(newProperties.Transparency)
        end
    end
    
    return true
end

-- ============ SISTEMA DE ANIMAÇÕES ============
local AnimationSystem = {
    Animations = {},
    ActiveAnimations = {},
    AnimationQueue = {},
    DefaultEasing = Enum.EasingStyle.Quad,
    DefaultDirection = Enum.EasingDirection.Out
}

function AnimationSystem:CreateAnimation(name, target, properties, duration, easingStyle, easingDirection)
    local animation = {
        Name = name,
        Target = target,
        Properties = properties,
        Duration = duration or 0.3,
        EasingStyle = easingStyle or self.DefaultEasing,
        EasingDirection = easingDirection or self.DefaultDirection,
        Tween = nil,
        Playing = false,
        Looping = false,
        LoopCount = 0
    }
    
    self.Animations[name] = animation
    return animation
end

function AnimationSystem:PlayAnimation(name, loopCount)
    local animation = self.Animations[name]
    if not animation then
        return false, "Animation not found"
    end
    
    if animation.Playing then
        return false, "Animation already playing"
    end
    
    if not animation.Target or not animation.Target.Parent then
        return false, "Animation target not valid"
    end
    
    -- Criar tween
    local tweenInfo = TweenInfo.new(
        animation.Duration,
        animation.EasingStyle,
        animation.EasingDirection
    )
    
    local tween = game:GetService("TweenService"):Create(
        animation.Target,
        tweenInfo,
        animation.Properties
    )
    
    animation.Tween = tween
    animation.Playing = true
    
    if loopCount then
        animation.Looping = true
        animation.LoopCount = loopCount
    end
    
    -- Iniciar animação
    tween:Play()
    
    -- Configurar eventos
    tween.Completed:Connect(function()
        animation.Playing = false
        
        if animation.Looping then
            if animation.LoopCount > 0 then
                animation.LoopCount = animation.LoopCount - 1
                if animation.LoopCount > 0 then
                    self:PlayAnimation(name, animation.LoopCount)
                else
                    animation.Looping = false
                end
            else
                -- Loop infinito
                self:PlayAnimation(name, 0)
            end
        end
    end)
    
    self.ActiveAnimations[name] = animation
    
    return true
end

function AnimationSystem:StopAnimation(name)
    local animation = self.Animations[name]
    if not animation then
        return false, "Animation not found"
    end
    
    if animation.Tween then
        animation.Tween:Cancel()
    end
    
    animation.Playing = false
    animation.Looping = false
    self.ActiveAnimations[name] = nil
    
    return true
end

function AnimationSystem:StopAllAnimations()
    for name, animation in pairs(self.ActiveAnimations) do
        self:StopAnimation(name)
    end
    
    self.ActiveAnimations = {}
    return true
end

function AnimationSystem:CreateHoverAnimation(object, hoverProperties, normalProperties)
    if not object then
        return false, "Object is nil"
    end
    
    local animationName = object.Name .. "_HoverAnimation"
    
    -- Criar animação de hover
    local hoverAnimation = self:CreateAnimation(
        animationName .. "_Hover",
        object,
        hoverProperties,
        0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    -- Criar animação de normal
    local normalAnimation = self:CreateAnimation(
        animationName .. "_Normal",
        object,
        normalProperties,
        0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    -- Configurar eventos de mouse
    local mouseEnter = object.MouseEnter:Connect(function()
        self:StopAnimation(normalAnimation.Name)
        self:PlayAnimation(hoverAnimation.Name)
    end)
    
    local mouseLeave = object.MouseLeave:Connect(function()
        self:StopAnimation(hoverAnimation.Name)
        self:PlayAnimation(normalAnimation.Name)
    end)
    
    -- Armazenar conexões
    animationName.Connections = {
        MouseEnter = mouseEnter,
        MouseLeave = mouseLeave
    }
    
    return true
end

-- ============ SISTEMA DE FONTES ============
local FontSystem = {
    Fonts = {},
    FontCache = {},
    DefaultFonts = {
        Gotham = "rbxasset://fonts/families/GothamSSm.json",
        Roboto = "rbxasset://fonts/families/Roboto.json",
        RobotoMono = "rbxasset://fonts/families/RobotoMono.json",
        SourceSans = "rbxasset://fonts/families/SourceSansPro.json",
        FiraCode = "rbxasset://fonts/families/FiraCode.json",
        FontAwesome = "rbxasset://fonts/families/FontAwesome.otf",
        MaterialIcons = "rbxasset://fonts/families/MaterialIconsRound.otf"
    }
}

function FontSystem:LoadFont(fontName, fontUrl)
    if self.Fonts[fontName] then
        return self.Fonts[fontName]
    end
    
    local font = nil
    
    -- Tentar carregar fonte personalizada
    if fontUrl then
        local success, result = pcall(function()
            return game:GetService("ContentProvider"):PreloadAsync({fontUrl})
        end)
        
        if success then
            font = Instance.new("Font")
            font.Family = fontUrl
            self.Fonts[fontName] = font
            return font
        end
    end
    
    -- Usar fonte padrão
    local defaultUrl = self.DefaultFonts[fontName]
    if defaultUrl then
        font = Instance.new("Font")
        font.Family = defaultUrl
        self.Fonts[fontName] = font
        return font
    end
    
    -- Fallback para fonte do sistema
    font = Enum.Font.SourceSans
    self.Fonts[fontName] = font
    
    return font
end

function FontSystem:ApplyFontToObject(object, fontName, fontSize, fontStyle)
    if not object then
        return false, "Object is nil"
    end
    
    local font = self.Fonts[fontName]
    if not font then
        font = self:LoadFont(fontName)
    end
    
    if not font then
        return false, "Font not found"
    end
    
    -- Aplicar fonte
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        if typeof(font) == "Font" then
            object.FontFace = font
        elseif typeof(font) == "EnumItem" then
            object.Font = font
        end
        
        if fontSize then
            object.TextSize = fontSize
        end
        
        if fontStyle then
            object.FontStyle = fontStyle
        end
    end
    
    return true
end

function FontSystem:ApplyFontToDescendants(parent, fontName, fontSize, fontStyle)
    if not parent then
        return false, "Parent is nil"
    end
    
    local applied = 0
    
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            local success = self:ApplyFontToObject(descendant, fontName, fontSize, fontStyle)
            if success then
                applied = applied + 1
            end
        end
    end
    
    return applied
end

-- ============ FUNÇÕES PRINCIPAIS DO THEME MANAGER ============
function ThemeManager:LoadTheme(themeName)
    local theme = self.State.Themes[themeName]
    
    if not theme then
        -- Carregar tema pré-definido
        theme = self.DefaultThemes[themeName]
        
        if not theme then
            return false, "Theme not found"
        end
        
        self.State.Themes[themeName] = theme
    end
    
    self.State.CurrentTheme = themeName
    
    -- Carregar gradientes
    for name, preset in pairs(GradientSystem.Presets) do
        GradientSystem:CreateGradient(name, preset.Colors, preset.Rotation, preset.Transparency)
    end
    
    -- Carregar fontes
    for fontName, _ in pairs(theme.Fonts) do
        FontSystem:LoadFont(fontName)
    end
    
    return true, theme
end

function ThemeManager:ApplyTheme(themeName)
    local success, theme = self:LoadTheme(themeName)
    if not success then
        return false, theme -- theme contém a mensagem de erro
    end
    
    print("[ThemeManager] Applying theme:", themeName)
    
    -- Aplicar tema à RayfieldAdapter
    if _G.NexusUI then
        _G.NexusUI:ApplyTheme(themeName)
    end
    
    -- Aplicar tema a todos os objetos registrados
    self:ApplyToRegisteredObjects(theme)
    
    -- Notificar outros sistemas
    if _G.NexusOS and _G.NexusOS.EventSystem then
        _G.NexusOS.EventSystem:Trigger("ThemeChanged", themeName, theme)
    end
    
    return true
end

function ThemeManager:ApplyToRegisteredObjects(theme)
    for objectName, objectData in pairs(self.State.ThemeObjects) do
        local object = objectData.Object
        local objectType = objectData.Type
        
        if object and object.Parent then
            self:ApplyThemeToObject(object, objectType, theme)
        else
            -- Remover objeto se não existir mais
            self.State.ThemeObjects[objectName] = nil
        end
    end
end

function ThemeManager:ApplyThemeToObject(object, objectType, theme)
    if not object or not theme then
        return false
    end
    
    -- Aplicar cores baseadas no tipo de objeto
    if objectType == "Window" then
        if object:IsA("Frame") then
            object.BackgroundColor3 = theme.Colors.Background.Primary
            object.BackgroundTransparency = 1 - theme.Properties.Transparency
        end
    elseif objectType == "Button" then
        if object:IsA("TextButton") then
            local buttonStyle = object:GetAttribute("ButtonStyle") or "Primary"
            
            if theme.Colors.Button[buttonStyle] then
                object.BackgroundColor3 = theme.Colors.Button[buttonStyle]
            end
            
            if theme.Colors.Button[buttonStyle .. "Text"] then
                object.TextColor3 = theme.Colors.Button[buttonStyle .. "Text"]
            end
            
            -- Configurar animações de hover
            local hoverColor = theme.Colors.Button[buttonStyle .. "Hover"]
            if hoverColor and not object:GetAttribute("HasHoverAnimation") then
                AnimationSystem:CreateHoverAnimation(
                    object,
                    {BackgroundColor3 = hoverColor},
                    {BackgroundColor3 = theme.Colors.Button[buttonStyle]}
                )
                object:SetAttribute("HasHoverAnimation", true)
            end
        end
    elseif objectType == "Text" then
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            object.TextColor3 = theme.Colors.Text.Primary
            
            -- Aplicar fonte
            local fontCategory = object:GetAttribute("FontCategory") or "Primary"
            local fontName = theme.Fonts[fontCategory]
            if fontName then
                FontSystem:ApplyFontToObject(object, fontName, theme.Properties.FontSize)
            end
        end
    elseif objectType == "Input" then
        if object:IsA("TextBox") then
            object.BackgroundColor3 = theme.Colors.Input.Background
            object.TextColor3 = theme.Colors.Input.Text
            object.PlaceholderColor3 = theme.Colors.Input.Placeholder
            
            -- Adicionar borda
            local stroke = object:FindFirstChild("UIStroke")
            if not stroke then
                stroke = Instance.new("UIStroke")
                stroke.Name = "ThemeBorder"
                stroke.Parent = object
            end
            
            stroke.Color = theme.Colors.Input.Border
            stroke.Thickness = theme.Properties.BorderSize
        end
    elseif objectType == "Card" then
        if object:IsA("Frame") then
            object.BackgroundColor3 = theme.Colors.Card.Background
            
            -- Adicionar borda
            local stroke = object:FindFirstChild("UIStroke")
            if not stroke then
                stroke = Instance.new("UIStroke")
                stroke.Name = "ThemeBorder"
                stroke.Parent = object
            end
            
            stroke.Color = theme.Colors.Card.Border
            stroke.Thickness = theme.Properties.BorderSize
            
            -- Adicionar sombra (simulada)
            if theme.Colors.Card.Shadow then
                object.BackgroundTransparency = 0.95
            end
            
            -- Adicionar cantos arredondados
            local corner = object:FindFirstChild("UICorner")
            if not corner then
                corner = Instance.new("UICorner")
                corner.Name = "ThemeCorner"
                corner.Parent = object
            end
            
            corner.CornerRadius = UDim.new(0, theme.Properties.BorderRadius)
        end
    end
    
    return true
end

function ThemeManager:RegisterObject(object, objectType, category)
    if not object then
        return false, "Object is nil"
    end
    
    local objectName = object.Name .. "_" .. tostring(os.time())
    
    self.State.ThemeObjects[objectName] = {
        Object = object,
        Type = objectType,
        Category = category or "General",
        Registered = os.time()
    }
    
    -- Aplicar tema atual imediatamente
    local currentTheme = self.State.Themes[self.State.CurrentTheme]
    if currentTheme then
        self:ApplyThemeToObject(object, objectType, currentTheme)
    end
    
    return true, objectName
end

function ThemeManager:UnregisterObject(objectName)
    if self.State.ThemeObjects[objectName] then
        self.State.ThemeObjects[objectName] = nil
        return true
    end
    
    return false
end

function ThemeManager:CreateCustomTheme(themeName, baseTheme, customizations)
    if self.State.Themes[themeName] then
        return false, "Theme already exists"
    end
    
    local base = baseTheme and self.State.Themes[baseTheme] or self.DefaultThemes["Dark"]
    if not base then
        return false, "Base theme not found"
    end
    
    -- Deep copy do tema base
    local newTheme = game:GetService("HttpService"):JSONDecode(
        game:GetService("HttpService"):JSONEncode(base)
    )
    
    newTheme.Name = themeName
    
    -- Aplicar customizações
    if customizations then
        for category, values in pairs(customizations) do
            if newTheme[category] then
                if category == "Colors" then
                    for subCategory, color in pairs(values) do
                        if type(color) == "table" then
                            for key, value in pairs(color) do
                                if newTheme[category][subCategory][key] ~= nil then
                                    newTheme[category][subCategory][key] = value
                                end
                            end
                        else
                            if newTheme[category][subCategory] ~= nil then
                                newTheme[category][subCategory] = color
                            end
                        end
                    end
                else
                    for key, value in pairs(values) do
                        if newTheme[category][key] ~= nil then
                            newTheme[category][key] = value
                        end
                    end
                end
            end
        end
    end
    
    -- Adicionar metadados
    newTheme.Metadata = {
        Created = os.time(),
        Modified = os.time(),
        Author = game:GetService("Players").LocalPlayer.Name,
        BasedOn = baseTheme or "Dark",
        IsCustom = true
    }
    
    self.State.Themes[themeName] = newTheme
    
    -- Salvar tema em arquivo
    self:SaveThemeToFile(themeName)
    
    return true, newTheme
end

function ThemeManager:SaveThemeToFile(themeName)
    local theme = self.State.Themes[themeName]
    if not theme then
        return false, "Theme not found"
    end
    
    local themesPath = "NexusOS/Themes/"
    if not isfolder(themesPath) then
        makefolder(themesPath)
    end
    
    local filePath = themesPath .. themeName .. ".json"
    local jsonData = game:GetService("HttpService"):JSONEncode(theme)
    
    pcall(writefile, filePath, jsonData)
    
    return true, filePath
end

function ThemeManager:LoadThemeFromFile(themeName)
    local filePath = "NexusOS/Themes/" .. themeName .. ".json"
    
    local success, fileData = pcall(readfile, filePath)
    if not success then
        return false, "Theme file not found"
    end
    
    local success, theme = pcall(game:GetService("HttpService").JSONDecode, 
        game:GetService("HttpService"), fileData)
    
    if not success then
        return false, "Invalid theme file"
    end
    
    theme.Name = themeName
    theme.Metadata = theme.Metadata or {
        Created = os.time(),
        Modified = os.time(),
        IsCustom = true
    }
    
    self.State.Themes[themeName] = theme
    
    return true, theme
end

function ThemeManager:GetCurrentTheme()
    return self.State.Themes[self.State.CurrentTheme]
end

function ThemeManager:GetThemeColor(category, subCategory, key)
    local theme = self:GetCurrentTheme()
    if not theme then
        return nil
    end
    
    if theme.Colors[category] then
        if subCategory and theme.Colors[category][subCategory] then
            if key then
                return theme.Colors[category][subCategory][key]
            else
                return theme.Colors[category][subCategory]
            end
        elseif not subCategory then
            return theme.Colors[category]
        end
    end
    
    return nil
end

function ThemeManager:UpdateAccentColor(newColor)
    local theme = self:GetCurrentTheme()
    if not theme then
        return false
    end
    
    theme.Colors.Primary = newColor
    theme.Colors.Button.Primary = newColor
    theme.Colors.Button.PrimaryHover = self:DarkenColor(newColor, 0.2)
    theme.Colors.Border.Focus = newColor
    theme.Colors.Text.Link = newColor
    
    -- Reaplicar tema
    self:ApplyTheme(self.State.CurrentTheme)
    
    return true
end

function ThemeManager:DarkenColor(color, amount)
    amount = amount or 0.2
    return Color3.new(
        math.max(0, color.R - amount),
        math.max(0, color.G - amount),
        math.max(0, color.B - amount)
    )
end

function ThemeManager:LightenColor(color, amount)
    amount = amount or 0.2
    return Color3.new(
        math.min(1, color.R + amount),
        math.min(1, color.G + amount),
        math.min(1, color.B + amount)
    )
end

function ThemeManager:Initialize()
    print("[ThemeManager] Initializing...")
    
    -- Carregar temas pré-definidos
    for themeName, theme in pairs(self.DefaultThemes) do
        self.State.Themes[themeName] = theme
    end
    
    -- Carregar temas personalizados
    local themesPath = "NexusOS/Themes/"
    if isfolder(themesPath) then
        -- Esta é uma implementação simulada
        print("[ThemeManager] Loading custom themes from:", themesPath)
    end
    
    -- Aplicar tema padrão
    self.State.CurrentTheme = "Dark"
    self:ApplyTheme("Dark")
    
    self.State.Initialized = true
    
    print("[ThemeManager] Initialization complete")
    
    return true
end

function ThemeManager:Shutdown()
    print("[ThemeManager] Shutting down...")
    
    -- Parar todas as animações
    AnimationSystem:StopAllAnimations()
    
    -- Salvar temas personalizados
    for themeName, theme in pairs(self.State.Themes) do
        if theme.Metadata and theme.Metadata.IsCustom then
            self:SaveThemeToFile(themeName)
        end
    end
    
    -- Limpar estado
    self.State.Initialized = false
    self.State.ThemeObjects = {}
    self.State.CustomColors = {}
    self.State.GradientPresets = {}
    self.State.Animations = {}
    self.State.Fonts = {}
    
    print("[ThemeManager] Shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusThemeManager then
    _G.NexusThemeManager = ThemeManager
end

return ThemeManager
