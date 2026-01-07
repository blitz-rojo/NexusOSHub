-- =============================================
-- NEXUS OS - NETWORK SERVICE WITH ANTI-DETECTION
-- Arquivo: Network.lua
-- Local: src/Services/Network.lua
-- =============================================

local Network = {
    Name = "Network",
    Version = "2.0.0",
    Description = "Serviço de rede com proteção avançada e anti-detecção",
    Author = "Nexus Security Team",
    
    Config = {},
    State = {
        Initialized = false,
        SecureMode = false,
        EncryptedConnections = {},
        ProxyConnections = {},
        RequestHistory = {},
        LastRequestTime = 0,
        RequestCount = 0,
        SecurityViolations = 0
    },
    
    Dependencies = {"Crypto", "StateManager"}
}

-- ============ CONFIGURAÇÕES DE SEGURANÇA DE REDE ============
Network.DefaultConfig = {
    Security = {
        EncryptAllTraffic = true,
        EncryptionMethod = "AES",
        UseProxies = false,
        ProxyList = {
            "proxy1.nexusos.com:8080",
            "proxy2.nexusos.com:8080",
            "proxy3.nexusos.com:8080"
        },
        RotateProxies = true,
        ProxyRotationInterval = 300,
        
        RequestThrottling = {
            Enabled = true,
            MaxRequestsPerMinute = 60,
            MinDelayBetweenRequests = 0.5,
            BurstProtection = true,
            BurstLimit = 10
        },
        
        Headers = {
            RandomizeUserAgent = true,
            UserAgents = {
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15",
                "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
                "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15"
            },
            CustomHeaders = {
                ["Accept"] = "application/json, text/html, */*",
                ["Accept-Language"] = "en-US,en;q=0.9",
                ["Accept-Encoding"] = "gzip, deflate, br",
                ["Connection"] = "keep-alive",
                ["Cache-Control"] = "no-cache",
                ["Pragma"] = "no-cache"
            }
        },
        
        AntiDetection = {
            MimicBrowserBehavior = true,
            HandleCookies = true,
            RespectRobotsTxt = false,
            AvoidSuspiciousPatterns = true,
            RandomizeRequestTiming = true,
            RequestJitter = 0.3
        }
    },
    
    Performance = {
        Timeout = 30,
        RetryAttempts = 3,
        RetryDelay = 2,
        ConcurrentLimit = 5,
        CacheResponses = true,
        CacheDuration = 300,
        Compression = true
    },
    
    Monitoring = {
        LogAllRequests = false,
        LogErrors = true,
        AlertOnSuspicious = true,
        SuspiciousPatterns = {
            "detection",
            "anti-cheat",
            "ban",
            "security",
            "monitor"
        }
    }
}

-- ============ SISTEMA DE REQUISIÇÕES SEGURAS ============
local SecureRequestSystem = {
    ActiveRequests = {},
    RequestQueue = {},
    CurrentProxyIndex = 1,
    LastProxyRotation = 0
}

function SecureRequestSystem:GenerateRequestId()
    return "REQ_" .. tostring(math.random(100000, 999999)) .. "_" .. tostring(os.time())
end

function SecureRequestSystem:ThrottleRequest()
    if not Network.Config.Security.RequestThrottling.Enabled then
        return true
    end
    
    local currentTime = os.time()
    local config = Network.Config.Security.RequestThrottling
    
    -- Verificar limite de burst
    if config.BurstProtection then
        local recentRequests = 0
        for _, req in pairs(Network.State.RequestHistory) do
            if currentTime - req.timestamp < 10 then -- Últimos 10 segundos
                recentRequests = recentRequests + 1
            end
        end
        
        if recentRequests >= config.BurstLimit then
            Network:LogSecurityEvent("BURST_LIMIT_EXCEEDED", 
                "Recent requests: " .. recentRequests)
            return false, "Burst limit exceeded"
        end
    end
    
    -- Verificar taxa de requisições por minuto
    local minuteAgo = currentTime - 60
    local requestsThisMinute = 0
    
    for _, req in pairs(Network.State.RequestHistory) do
        if req.timestamp > minuteAgo then
            requestsThisMinute = requestsThisMinute + 1
        end
    end
    
    if requestsThisMinute >= config.MaxRequestsPerMinute then
        Network:LogSecurityEvent("RATE_LIMIT_EXCEEDED",
            "Requests this minute: " .. requestsThisMinute)
        return false, "Rate limit exceeded"
    end
    
    -- Aplicar delay entre requisições
    local timeSinceLastRequest = currentTime - Network.State.LastRequestTime
    local minDelay = config.MinDelayBetweenRequests
    
    if timeSinceLastRequest < minDelay then
        local waitTime = minDelay - timeSinceLastRequest
        if Network.Config.Security.AntiDetection.RandomizeRequestTiming then
            waitTime = waitTime * (1 + (math.random() * 2 - 1) * Network.Config.Security.AntiDetection.RequestJitter)
        end
        wait(waitTime)
    end
    
    return true
end

function SecureRequestSystem:GetRandomUserAgent()
    if not Network.Config.Security.Headers.RandomizeUserAgent then
        return "Roblox/" .. game:GetService("NetworkClient").ClientVersion
    end
    
    local agents = Network.Config.Security.Headers.UserAgents
    return agents[math.random(1, #agents)]
end

function SecureRequestSystem:GetHeaders()
    local headers = {}
    
    -- Headers customizados
    for key, value in pairs(Network.Config.Security.Headers.CustomHeaders) do
        headers[key] = value
    end
    
    -- User-Agent aleatório
    headers["User-Agent"] = self:GetRandomUserAgent()
    
    -- Adicionar headers de segurança
    if Network.State.SecureMode then
        headers["X-Security-Token"] = _G.NexusCrypto and _G.NexusCrypto:GetHWID() or "unknown"
        headers["X-Session-ID"] = Network.State.SessionId or "unknown"
    end
    
    return headers
end

function SecureRequestSystem:EncryptRequestData(data)
    if not Network.Config.Security.EncryptAllTraffic then
        return data
    end
    
    if _G.NexusCrypto then
        local encrypted = _G.NexusCrypto:Encrypt(
            game:GetService("HttpService"):JSONEncode(data),
            Network.Config.Security.EncryptionMethod
        )
        return {encrypted = encrypted}
    end
    
    return data
end

function SecureRequestSystem:DecryptResponseData(data)
    if not Network.Config.Security.EncryptAllTraffic then
        return data
    end
    
    if type(data) == "table" and data.encrypted and _G.NexusCrypto then
        local decrypted = _G.NexusCrypto:Decrypt(
            data.encrypted,
            Network.Config.Security.EncryptionMethod
        )
        
        local success, result = pcall(game:GetService("HttpService").JSONDecode,
            game:GetService("HttpService"), decrypted)
        
        if success then
            return result
        end
    end
    
    return data
end

function SecureRequestSystem:CheckSuspiciousResponse(response)
    if not Network.Config.Monitoring.AlertOnSuspicious then
        return false
    end
    
    local responseText = tostring(response)
    
    for _, pattern in ipairs(Network.Config.Monitoring.SuspiciousPatterns) do
        if string.find(string.lower(responseText), string.lower(pattern)) then
            Network:LogSecurityEvent("SUSPICIOUS_RESPONSE",
                "Pattern detected: " .. pattern)
            return true
        end
    end
    
    return false
end

function SecureRequestSystem:MakeRequest(url, method, data, headers)
    local requestId = self:GenerateRequestId()
    
    -- Throttling
    local throttleOk, throttleError = self:ThrottleRequest()
    if not throttleOk then
        return nil, throttleError
    end
    
    -- Preparar dados
    method = method or "GET"
    data = data or {}
    headers = headers or self:GetHeaders()
    
    -- Criptografar dados se necessário
    if method == "POST" or method == "PUT" then
        data = self:EncryptRequestData(data)
    end
    
    -- Registrar requisição
    Network.State.RequestHistory[requestId] = {
        url = url,
        method = method,
        timestamp = os.time(),
        headers = headers
    }
    
    Network.State.LastRequestTime = os.time()
    Network.State.RequestCount = Network.State.RequestCount + 1
    
    -- Fazer requisição
    local success, response = pcall(function()
        local requestFunc
        
        if method == "GET" then
            requestFunc = game.HttpGet
        elseif method == "POST" then
            requestFunc = game.HttpPost
        elseif method == "PUT" then
            -- Implementação simplificada para PUT
            requestFunc = function(game, url, data)
                return game:GetService("HttpService"):PostAsync(url, data)
            end
        else
            error("Unsupported method: " .. method)
        end
        
        return requestFunc(game, url, data)
    end)
    
    -- Processar resposta
    if success then
        -- Verificar resposta suspeita
        if self:CheckSuspiciousResponse(response) then
            Network.State.SecurityViolations = Network.State.SecurityViolations + 1
        end
        
        -- Descriptografar se necessário
        response = self:DecryptResponseData(response)
        
        -- Limitar histórico
        if #Network.State.RequestHistory > 100 then
            local oldestKey = nil
            for key, _ in pairs(Network.State.RequestHistory) do
                if not oldestKey then
                    oldestKey = key
                end
            end
            if oldestKey then
                Network.State.RequestHistory[oldestKey] = nil
            end
        end
        
        return response
    else
        Network:LogSecurityEvent("REQUEST_FAILED",
            "URL: " .. url .. ", Error: " .. response)
        return nil, response
    end
end

function SecureRequestSystem:RotateProxy()
    if not Network.Config.Security.UseProxies then
        return nil
    end
    
    local currentTime = os.time()
    local interval = Network.Config.Security.ProxyRotationInterval
    
    if currentTime - self.LastProxyRotation >= interval then
        self.CurrentProxyIndex = self.CurrentProxyIndex + 1
        
        if self.CurrentProxyIndex > #Network.Config.Security.ProxyList then
            self.CurrentProxyIndex = 1
        end
        
        self.LastProxyRotation = currentTime
        
        Network:LogSecurityEvent("PROXY_ROTATED",
            "New proxy: " .. Network.Config.Security.ProxyList[self.CurrentProxyIndex])
    end
    
    return Network.Config.Security.ProxyList[self.CurrentProxyIndex]
end

-- ============ SISTEMA DE WEBSOCKET SEGURO ============
local SecureWebSocketSystem = {
    Connections = {},
    MessageQueue = {},
    ReconnectAttempts = {}
}

function SecureWebSocketSystem:CreateSecureConnection(url, options)
    options = options or {}
    
    local connectionId = "WS_" .. tostring(math.random(100000, 999999))
    
    local connection = {
        id = connectionId,
        url = url,
        options = options,
        socket = nil,
        connected = false,
        lastHeartbeat = 0,
        messageCallback = nil,
        errorCallback = nil,
        reconnectAttempts = 0,
        maxReconnectAttempts = options.maxReconnectAttempts or 5
    }
    
    self.Connections[connectionId] = connection
    
    return connectionId
end

function SecureWebSocketSystem:Connect(connectionId)
    local connection = self.Connections[connectionId]
    if not connection then
        return false, "Connection not found"
    end
    
    -- Em Roblox, WebSockets não são nativamente suportados
    -- Esta é uma implementação simulada para demonstração
    print("[WebSocket] Secure connection established to:", connection.url)
    
    connection.connected = true
    connection.lastHeartbeat = os.time()
    
    -- Simular handshake de segurança
    if Network.State.SecureMode then
        print("[WebSocket] Security handshake completed")
    end
    
    return true
end

function SecureWebSocketSystem:Send(connectionId, data, encrypted)
    local connection = self.Connections[connectionId]
    if not connection or not connection.connected then
        return false, "Not connected"
    end
    
    -- Criptografar mensagem se necessário
    local message = data
    if encrypted and _G.NexusCrypto then
        message = _G.NexusCrypto:Encrypt(
            game:GetService("HttpService"):JSONEncode(data),
            "AES"
        )
    end
    
    -- Em produção, enviaria via WebSocket real
    print("[WebSocket] Secure message sent:", message)
    
    return true
end

function SecureWebSocketSystem:Close(connectionId)
    local connection = self.Connections[connectionId]
    if not connection then
        return false
    end
    
    connection.connected = false
    connection.socket = nil
    
    print("[WebSocket] Connection closed:", connectionId)
    
    return true
end

-- ============ SISTEMA DE MONITORAMENTO DE REDE ============
local NetworkMonitor = {
    TrafficLog = {},
    SuspiciousActivities = {},
    BandwidthUsage = {incoming = 0, outgoing = 0}
}

function NetworkMonitor:LogTraffic(direction, size, url, metadata)
    local logEntry = {
        timestamp = os.time(),
        direction = direction, -- "incoming" or "outgoing"
        size = size,
        url = url,
        metadata = metadata or {}
    }
    
    table.insert(self.TrafficLog, logEntry)
    
    -- Atualizar uso de banda
    if direction == "incoming" then
        self.BandwidthUsage.incoming = self.BandwidthUsage.incoming + size
    else
        self.BandwidthUsage.outgoing = self.BandwidthUsage.outgoing + size
    end
    
    -- Limitar logs
    if #self.TrafficLog > 1000 then
        table.remove(self.TrafficLog, 1)
    end
end

function NetworkMonitor:DetectAnomalies()
    local anomalies = {}
    local currentTime = os.time()
    
    -- Verificar tráfego excessivo
    local trafficLastMinute = 0
    for _, log in ipairs(self.TrafficLog) do
        if currentTime - log.timestamp < 60 then
            trafficLastMinute = trafficLastMinute + log.size
        end
    end
    
    if trafficLastMinute > 10 * 1024 * 1024 then -- 10MB por minuto
        table.insert(anomalies, {
            type = "HIGH_BANDWIDTH",
            details = "Traffic in last minute: " .. trafficLastMinute .. " bytes"
        })
    end
    
    -- Verificar padrões suspeitos
    local recentRequests = {}
    for _, log in ipairs(self.TrafficLog) do
        if currentTime - log.timestamp < 10 then
            table.insert(recentRequests, log.url)
        end
    end
    
    -- Verificar requisições repetidas
    local urlCounts = {}
    for _, url in ipairs(recentRequests) do
        urlCounts[url] = (urlCounts[url] or 0) + 1
        if urlCounts[url] > 5 then -- Mais de 5 requisições para mesma URL em 10 segundos
            table.insert(anomalies, {
                type = "REPETITIVE_REQUESTS",
                details = "URL: " .. url .. ", Count: " .. urlCounts[url]
            })
        end
    end
    
    return anomalies
end

function NetworkMonitor:GenerateReport()
    local report = {
        timestamp = os.time(),
        bandwidthUsage = {
            incoming = self.BandwidthUsage.incoming,
            outgoing = self.BandwidthUsage.outgoing,
            total = self.BandwidthUsage.incoming + self.BandwidthUsage.outgoing
        },
        trafficCount = #self.TrafficLog,
        recentActivities = {},
        anomalies = self:DetectAnomalies()
    }
    
    -- Coletar atividades recentes (últimos 5 minutos)
    local fiveMinutesAgo = os.time() - 300
    for _, log in ipairs(self.TrafficLog) do
        if log.timestamp > fiveMinutesAgo then
            table.insert(report.recentActivities, log)
        end
    end
    
    return report
end

-- ============ FUNÇÕES PRINCIPAIS DO SERVIÇO DE REDE ============
function Network:SecureGet(url, headers)
    return SecureRequestSystem:MakeRequest(url, "GET", nil, headers)
end

function Network:SecurePost(url, data, headers)
    return SecureRequestSystem:MakeRequest(url, "POST", data, headers)
end

function Network:SecurePut(url, data, headers)
    return SecureRequestSystem:MakeRequest(url, "PUT", data, headers)
end

function Network:CreateWebSocket(url, options)
    return SecureWebSocketSystem:CreateSecureConnection(url, options)
end

function Network:ConnectWebSocket(connectionId)
    return SecureWebSocketSystem:Connect(connectionId)
end

function Network:SendWebSocket(connectionId, data, encrypted)
    return SecureWebSocketSystem:Send(connectionId, data, encrypted)
end

function Network:CloseWebSocket(connectionId)
    return SecureWebSocketSystem:Close(connectionId)
end

function Network:LogSecurityEvent(eventType, details)
    if not Network.Config.Monitoring.LogErrors then
        return
    end
    
    print("[Network Security]", eventType, "-", details)
    
    -- Notificar sistema de segurança principal
    if _G.NexusCrypto then
        _G.NexusCrypto:LogSecurityEvent("NETWORK_" .. eventType, details)
    end
    
    -- Notificar usuário se for crítico
    if string.find(eventType, "SUSPICIOUS") or string.find(eventType, "LIMIT") then
        if _G.NexusNotifications then
            _G.NexusNotifications:Warning(
                "Network Security",
                eventType .. ": " .. details,
                5
            )
        end
    end
end

function Network:GetNetworkReport()
    return NetworkMonitor:GenerateReport()
end

function Network:GetRequestStats()
    return {
        totalRequests = Network.State.RequestCount,
        lastRequestTime = Network.State.LastRequestTime,
        securityViolations = Network.State.SecurityViolations,
        activeConnections = #SecureWebSocketSystem.Connections
    }
end

function Network:EnableSecureMode()
    Network.State.SecureMode = true
    
    -- Ativar todas as proteções
    Network.Config.Security.EncryptAllTraffic = true
    Network.Config.Security.RequestThrottling.Enabled = true
    Network.Config.Security.AntiDetection.MimicBrowserBehavior = true
    
    print("[Network] Secure mode enabled")
    
    return true
end

function Network:DisableSecureMode()
    Network.State.SecureMode = false
    
    -- Desativar proteções (para performance)
    Network.Config.Security.EncryptAllTraffic = false
    Network.Config.Security.RequestThrottling.Enabled = false
    
    print("[Network] Secure mode disabled")
    
    return true
end

function Network:Initialize()
    print("[Network] Initializing secure network service...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Gerar ID de sessão
    self.State.SessionId = tostring(math.random(100000, 999999)) .. "_" .. tostring(os.time())
    
    -- Inicializar sistemas
    SecureRequestSystem:GetHeaders() -- Pré-carregar headers
    
    -- Configurar monitoramento
    if self.Config.Monitoring.LogAllRequests then
        print("[Network] Request logging enabled")
    end
    
    self.State.Initialized = true
    
    print("[Network] Secure network service initialized")
    print("[Network] Session ID:", self.State.SessionId)
    
    return true
end

function Network:Shutdown()
    print("[Network] Shutting down network service...")
    
    -- Fechar todas as conexões WebSocket
    for connectionId, _ in pairs(SecureWebSocketSystem.Connections) do
        SecureWebSocketSystem:Close(connectionId)
    end
    
    -- Limpar estado
    SecureWebSocketSystem.Connections = {}
    SecureRequestSystem.ActiveRequests = {}
    Network.State.RequestHistory = {}
    
    self.State.Initialized = false
    self.State.SecureMode = false
    
    print("[Network] Network service shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusNetwork then
    _G.NexusNetwork = Network
end

return Network
