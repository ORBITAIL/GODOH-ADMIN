-- ============================================
--  GODOH ADMIN v8 — кнопка скрытия вместо RightCtrl
-- ============================================
print("[Godoh] старт…")

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")

local player = Players.LocalPlayer
if not player then return warn("[Godoh] нет LocalPlayer") end

local gui, frame, header
local consolePage, commandsPage, quickPage
local consoleTab, commandsTab, quickTab
local output, inputBox, miniBtn
local commandList, log, executeCommand, setTab, buildCommandsPage
local current67Track, currentMapFolder
local guiVisible = true

local state = {
    flyEnabled=false, flySpeed=60,
    noclip=false,
    speedEnabled=false, speed=100,
    infJump=false,
    espEnabled=false,
    jpEnabled=false, jumpPower=100,
    godmode=false,
    fullbright=false,
}

local function getHum() local c = player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c = player.Character; return c and c:FindFirstChild("HumanoidRootPart") end

-- FLY
local flyBV, flyBG, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local hum = getHum(); if hum then hum.PlatformStand = false end
end
local function startFly()
    stopFly()
    local hrp, hum = getHRP(), getHum()
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); flyBG.P = 5000; flyBG.D = 500
    flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not state.flyEnabled then return end
        local h = getHRP(); if not h or not flyBV or not flyBG then return end
        local cam = workspace.CurrentCamera and workspace.CurrentCamera.CFrame
        if not cam then return end
        local mv = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0,1,0) end
        flyBV.Velocity = mv.Magnitude > 0 and (mv.Unit * state.flySpeed) or Vector3.zero
        flyBG.CFrame = CFrame.new(h.Position, h.Position + cam.LookVector)
    end)
end

local function applyNoclip()
    local char = player.Character; if not char then return end
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = not state.noclip end
    end
end

pcall(function()
    UIS.JumpRequest:Connect(function()
        if state.infJump then
            local hum = getHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

-- ESP
local function createESP(p)
    if p == player then return end
    local char = p.Character
    if not char or char:FindFirstChild("GodohESP") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "GodohESP"; hl.Adornee = char
    hl.FillColor = Color3.fromRGB(255,70,70); hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bb = Instance.new("BillboardGui")
        bb.Name = "GodohESPName"; bb.Adornee = hrp
        bb.Size = UDim2.new(0,200,0,24); bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true; bb.Parent = hrp
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
        tl.Text = p.Name; tl.TextColor3 = Color3.fromRGB(255,120,120)
        tl.TextStrokeTransparency = 0
        tl.Font = Enum.Font.GothamBold; tl.TextSize = 14; tl.Parent = bb
    end
end
local function removeESP(p)
    local char = p.Character; if not char then return end
    local hl = char:FindFirstChild("GodohESP"); if hl then hl:Destroy() end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bb = hrp:FindFirstChild("GodohESPName"); if bb then bb:Destroy() end
    end
end
local function clearAllESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then removeESP(p) end
    end
end

-- 67
local function play67(animationId)
    animationId = tostring(animationId):gsub("rbxassetid://", ""):gsub("%D", "")
    if animationId == "" then return "❌ Пустой ID" end
    local char = player.Character; if not char then return "❌ Нет персонажа" end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return "❌ Нет Humanoid" end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = Instance.new("Animator"); animator.Parent = hum end
    if current67Track then pcall(function() current67Track:Stop() end); current67Track = nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animationId
    local track
    pcall(function() track = animator:LoadAnimation(anim) end)
    if not track then return "❌ LoadAnimation провалился" end
    pcall(function()
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
    end)
    current67Track = track
    return ("✅ 67 | Rig: %s"):format(hum.RigType.Name)
end

-- MAP
local function randomColor() return Color3.fromHSV(math.random(), 0.6, 1) end
local function createRandomMap()
    if currentMapFolder and currentMapFolder.Parent then currentMapFolder:Destroy() end
    local hrp = getHRP(); if not hrp then return "❌ Нет персонажа" end
    local folder = Instance.new("Folder")
    folder.Name = "GodohRandomMap_" .. tick()
    folder.Parent = workspace; currentMapFolder = folder
    local origin = hrp.Position + hrp.CFrame.LookVector * 25 + Vector3.new(0, -5, 0)
    local count = 0
    local function mp(cf, sz, col, mat, shape)
        local p = Instance.new("Part")
        p.Size = sz; p.CFrame = cf; p.Anchored = true; p.CanCollide = true
        p.Color = col or randomColor(); p.Material = mat or Enum.Material.SmoothPlastic
        if shape then p.Shape = shape end
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = folder; count = count + 1
    end
    mp(CFrame.new(origin), Vector3.new(60,2,60), Color3.fromRGB(60,180,90), Enum.Material.Grass)
    for i = 1, math.random(5,10) do
        local off = Vector3.new(math.random(-80,80), math.random(8,40), math.random(-80,80))
        mp(CFrame.new(origin + off), Vector3.new(math.random(6,15), math.random(1,2), math.random(6,15)))
    end
    local th, ts = math.random(30,60), math.random(8,15)
    for i = 1, ts do
        mp(CFrame.new(origin + Vector3.new(0, (th/ts)*i, 0)), Vector3.new(8,1.5,8), nil, Enum.Material.Neon)
    end
    for i = 1, 20 do
        local a, r = i * math.rad(20), 20
        mp(CFrame.new(origin + Vector3.new(math.cos(a)*r, i*2, math.sin(a)*r)) * CFrame.Angles(0,a,0),
            Vector3.new(5,0.8,3), Color3.fromRGB(255,200,100), Enum.Material.Wood)
    end
    for i = 1, math.random(10,20) do
        local off = Vector3.new(math.random(-50,50), math.random(2,6), math.random(-50,50))
        mp(CFrame.new(origin + off) * CFrame.Angles(0, math.random()*math.pi*2, 0),
            Vector3.new(math.random(2,6), math.random(2,8), math.random(2,6)), nil, Enum.Material.Concrete)
    end
    for i = 1, math.random(3,8) do
        local off = Vector3.new(math.random(-70,70), math.random(50,100), math.random(-70,70))
        local r = math.random(3,8)
        mp(CFrame.new(origin + off), Vector3.new(r,r,r), nil, Enum.Material.Neon, Enum.PartType.Ball)
    end
    hrp.CFrame = CFrame.new(origin + Vector3.new(0, 8, 0))
    return ("✅ Карта: %d партов"):format(count)
end
local function deleteRandomMap()
    if currentMapFolder and currentMapFolder.Parent then
        local n = currentMapFolder.Name
        currentMapFolder:Destroy(); currentMapFolder = nil
        return "🗑 Удалено: " .. n
    end
    return "ℹ️ Карты нет"
end

-- КОМАНДЫ
commandList = {
    fly = { cat = "Movement", desc = "Полёт вкл/выкл", fn = function()
        state.flyEnabled = not state.flyEnabled
        if state.flyEnabled then startFly() else stopFly() end
        return "Fly: " .. (state.flyEnabled and "ON" or "OFF")
    end },
    noclip = { cat = "Movement", desc = "Сквозь стены", fn = function()
        state.noclip = not state.noclip; applyNoclip()
        return "Noclip: " .. (state.noclip and "ON" or "OFF")
    end },
    speed = { cat = "Movement", desc = "speed <n>", fn = function(args)
        local v = tonumber(args[1]); if not v then return "Usage: speed <n>" end
        state.speed, state.speedEnabled = v, true
        local hum = getHum(); if hum then hum.WalkSpeed = v end
        return "Speed → " .. v
    end },
    stopspeed = { cat = "Movement", desc = "Выключить скорость", fn = function()
        state.speedEnabled = false
        local hum = getHum(); if hum then hum.WalkSpeed = 16 end
        return "✅ Speed OFF (16)"
    end },
    jp = { cat = "Movement", desc = "jp <n>", fn = function(args)
        local v = tonumber(args[1]); if not v then return "Usage: jp <n>" end
        state.jumpPower, state.jpEnabled = v, true
        local hum = getHum(); if hum then hum.JumpPower = v end
        return "JumpPower → " .. v
    end },
    infjump = { cat = "Movement", desc = "Беск. прыжок", fn = function()
        state.infJump = not state.infJump
        return "InfJump: " .. (state.infJump and "ON" or "OFF")
    end },
    tp = { cat = "Players", desc = "tp <player>", fn = function(args)
        local q = args[1]; if not q then return "Usage: tp <player>" end
        q = q:lower()
        local myHRP = getHRP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Name:lower():sub(1, #q) == q then
                local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and t then
                    myHRP.CFrame = t.CFrame + Vector3.new(0,3,0)
                    return "TP → " .. p.Name
                end
            end
        end
        return "Player not found"
    end },
    goto = { cat = "Players", desc = "goto <x> <y> <z>", fn = function(args)
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if not (x and y and z) then return "Usage: goto <x> <y> <z>" end
        local h = getHRP(); if not h then return "No character" end
        h.CFrame = CFrame.new(x, y, z)
        return ("TP → %.1f, %.1f, %.1f"):format(x, y, z)
    end },
    void = { cat = "Players", desc = "Упасть за карту", fn = function()
        local h = getHRP(); if h then h.CFrame = CFrame.new(0, -500, 0) end
        return "Dropping..."
    end },
    heal = { cat = "Health", desc = "Восстановить HP", fn = function()
        local hum = getHum(); if not hum then return "No humanoid" end
        hum.Health = hum.MaxHealth; return "Healed"
    end },
    respawn = { cat = "Health", desc = "Респавн", fn = function()
        local hum = getHum(); if hum then hum.Health = 0 end
        return "Respawning..."
    end },
    god = { cat = "Health", desc = "Godmode", fn = function()
        state.godmode = not state.godmode
        local hum = getHum()
        if hum then
            if state.godmode then hum.MaxHealth = math.huge; hum.Health = math.huge
            else hum.MaxHealth = 100; hum.Health = 100 end
        end
        return "God: " .. (state.godmode and "ON" or "OFF")
    end },
    esp = { cat = "Visual", desc = "Подсветка", fn = function()
        state.espEnabled = not state.espEnabled
        if state.espEnabled then
            for _, p in pairs(Players:GetPlayers()) do createESP(p) end
        else clearAllESP() end
        return "ESP: " .. (state.espEnabled and "ON" or "OFF")
    end },
    fullbright = { cat = "Visual", desc = "Осветлить сцену", fn = function()
        state.fullbright = not state.fullbright
        if state.fullbright then
            Lighting.Brightness = 3; Lighting.ClockTime = 12
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
        end
        return "Fullbright: " .. (state.fullbright and "ON" or "OFF")
    end },
    ["67"] = { cat = "Fun", desc = "67 <id> — танец", fn = function(args)
        local id = args[1]; if not id then return "Usage: 67 <id>" end
        return play67(id)
    end },
    stop67 = { cat = "Fun", desc = "Стоп 67", fn = function()
        if current67Track then pcall(function() current67Track:Stop() end); current67Track = nil
            return "⏹ 67 остановлен"
        end
        return "ℹ️ Ничего"
    end },
    createmap = { cat = "Map", desc = "Создать карту", fn = createRandomMap },
    delmap = { cat = "Map", desc = "Удалить карту", fn = deleteRandomMap },
    help = { cat = "Utility", desc = "Список команд", fn = function() return "__HELP__" end },
    clear = { cat = "Utility", desc = "Очистить консоль", fn = function() return "__CLEAR__" end },
    hide = { cat = "Utility", desc = "Скрыть/показать панель", fn = function()
        guiVisible = not guiVisible
        if frame then frame.Visible = guiVisible end
        if miniBtn then miniBtn.Visible = not guiVisible end
        return "GUI: " .. (guiVisible and "ON" or "OFF")
    end },
    destroy = { cat = "Utility", desc = "Удалить GUI", fn = function() return "__DESTROY__" end },
    stopall = { cat = "Utility", desc = "Выключить всё", fn = function()
        state.speedEnabled = false; state.flyEnabled = false
        state.noclip = false; state.espEnabled = false
        stopFly(); clearAllESP()
        local hum = getHum(); if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        return "✅ Всё выключено"
    end },
}

executeCommand = function(input)
    if input == "" then return end
    local args = {}
    for w in input:gmatch("%S+") do table.insert(args, w) end
    local cmd = args[1]:lower(); table.remove(args, 1)
    if commandList[cmd] then
        local ok, result = pcall(commandList[cmd].fn, args)
        return ok and tostring(result or "OK") or ("Error: " .. tostring(result))
    end
    return "Unknown: " .. cmd
end

-- GUI
local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("GodohAdmin"); if old then old:Destroy() end

gui = Instance.new("ScreenGui")
gui.Name = "GodohAdmin"; gui.ResetOnSpawn = false; gui.Parent = pg

frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 720, 0, 500)
frame.Position = UDim2.new(0.5, -360, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0; frame.Active = true; frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
header.BorderSizePixel = 0; header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 1, 0); title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GODOH ADMIN"
title.TextColor3 = Color3.fromRGB(120, 220, 255)
title.Font = Enum.Font.GothamBold; title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header

-- 🆕 кнопка СКРЫТЬ в шапке
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 30, 0, 30)
hideBtn.Position = UDim2.new(1, -80, 0, 5)
hideBtn.BackgroundColor3 = Color3.fromRGB(90, 120, 180)
hideBtn.Text = "—"
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.GothamBold; hideBtn.TextSize = 18
hideBtn.Parent = header
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text = "✕"; closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- 🆕 Плавающая мини-кнопка (видна когда панель скрыта)
miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(0, 20, 0, 20)
miniBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
miniBtn.Text = "⚡"
miniBtn.TextColor3 = Color3.new(1, 1, 1)
miniBtn.Font = Enum.Font.GothamBold; miniBtn.TextSize = 24
miniBtn.Visible = false
miniBtn.Active = true
miniBtn.Parent = gui
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 25)

-- перетаскивание мини-кнопки
local miniDrag, miniStart
miniBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
       or i.UserInputType == Enum.UserInputType.Touch then
        miniDrag = true; miniStart = i.Position
    end
end)
miniBtn.InputChanged:Connect(function(i)
    if miniDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
       or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - miniStart
        miniBtn.Position = UDim2.new(0, miniBtn.Position.X.Offset + d.X, 0, miniBtn.Position.Y.Offset + d.Y)
        miniStart = i.Position
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
       or i.UserInputType == Enum.UserInputType.Touch then
        miniDrag = false
    end
end)

-- обработчики скрыть/показать
local function setGuiVisible(v)
    guiVisible = v
    if frame then frame.Visible = v end
    if miniBtn then miniBtn.Visible = not v end
end

hideBtn.MouseButton1Click:Connect(function() setGuiVisible(false) end)
miniBtn.MouseButton1Click:Connect(function() setGuiVisible(true) end)

-- табы
local function makeTab(text, xPos, active)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 90, 0, 28)
    t.Position = UDim2.new(0, xPos, 0, 6)
    t.BackgroundColor3 = active and Color3.fromRGB(60,60,75) or Color3.fromRGB(40,40,55)
    t.Text = text; t.TextColor3 = Color3.new(1,1,1)
    t.Font = Enum.Font.GothamBold; t.TextSize = 13
    t.Parent = header
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
    return t
end
consoleTab  = makeTab("Console",  330, true)
commandsTab = makeTab("Commands", 425, false)
quickTab    = makeTab("⚡ Quick",  520, false)

-- CONSOLE
consolePage = Instance.new("Frame")
consolePage.Size = UDim2.new(1, -30, 1, -100)
consolePage.Position = UDim2.new(0, 15, 0, 55)
consolePage.BackgroundTransparency = 1; consolePage.Parent = frame

output = Instance.new("ScrollingFrame")
output.Size = UDim2.new(1, 0, 1, -50)
output.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
output.BorderSizePixel = 0
output.CanvasSize = UDim2.new(0, 0, 0, 0)
output.ScrollBarThickness = 6; output.Parent = consolePage
Instance.new("UICorner", output).CornerRadius = UDim.new(0, 6)

local outputLayout = Instance.new("UIListLayout")
outputLayout.Padding = UDim.new(0, 2); outputLayout.Parent = output

log = function(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = "> " .. text
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Code; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = output
    output.CanvasSize = UDim2.new(0, 0, 0, outputLayout.AbsoluteContentSize.Y)
    output.CanvasPosition = Vector2.new(0, outputLayout.AbsoluteContentSize.Y)
end

inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -90, 0, 32)
inputBox.Position = UDim2.new(0, 0, 1, -40)
inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
inputBox.PlaceholderText = "Enter command… (↑/↓ — история)"
inputBox.Text = ""; inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.Font = Enum.Font.Code; inputBox.TextSize = 14
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = false; inputBox.Parent = consolePage
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0, 80, 0, 32)
execBtn.Position = UDim2.new(1, -80, 1, -40)
execBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
execBtn.Text = "RUN"; execBtn.TextColor3 = Color3.new(1,1,1)
execBtn.Font = Enum.Font.GothamBold; execBtn.TextSize = 13
execBtn.Parent = consolePage
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 6)

-- COMMANDS
commandsPage = Instance.new("Frame")
commandsPage.Size = UDim2.new(1, -30, 1, -100)
commandsPage.Position = UDim2.new(0, 15, 0, 55)
commandsPage.BackgroundTransparency = 1
commandsPage.Visible = false; commandsPage.Parent = frame

local cmdScroll = Instance.new("ScrollingFrame")
cmdScroll.Size = UDim2.new(1, 0, 1, 0)
cmdScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
cmdScroll.BorderSizePixel = 0
cmdScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cmdScroll.ScrollBarThickness = 6; cmdScroll.Parent = commandsPage
Instance.new("UICorner", cmdScroll).CornerRadius = UDim.new(0, 6)

local cmdListLayout = Instance.new("UIListLayout")
cmdListLayout.Padding = UDim.new(0, 4)
cmdListLayout.SortOrder = Enum.SortOrder.LayoutOrder; cmdListLayout.Parent = cmdScroll

local cmdPad = Instance.new("UIPadding")
cmdPad.PaddingTop = UDim.new(0, 6)
cmdPad.PaddingLeft = UDim.new(0, 8)
cmdPad.PaddingRight = UDim.new(0, 8)
cmdPad.Parent = cmdScroll

-- QUICK
quickPage = Instance.new("Frame")
quickPage.Size = UDim2.new(1, -30, 1, -100)
quickPage.Position = UDim2.new(0, 15, 0, 55)
quickPage.BackgroundTransparency = 1
quickPage.Visible = false; quickPage.Parent = frame

local quickGrid = Instance.new("Frame")
quickGrid.Size = UDim2.new(1, 0, 1, 0)
quickGrid.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
quickGrid.BorderSizePixel = 0; quickGrid.Parent = quickPage
Instance.new("UICorner", quickGrid).CornerRadius = UDim.new(0, 6)

local gridPad = Instance.new("UIPadding")
gridPad.PaddingTop = UDim.new(0, 10)
gridPad.PaddingLeft = UDim.new(0, 10)
gridPad.PaddingRight = UDim.new(0, 10)
gridPad.PaddingBottom = UDim.new(0, 10)
gridPad.Parent = quickGrid

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.5, -6, 0, 46)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = quickGrid

local quickCommands = {
    { "✈️  Fly",        "fly",            Color3.fromRGB(80, 140, 220) },
    { "🚪  Noclip",     "noclip",         Color3.fromRGB(120, 100, 200) },
    { "💨  Speed 100",  "speed 100",      Color3.fromRGB(80, 180, 120) },
    { "⚡  Speed 250",  "speed 250",      Color3.fromRGB(80, 200, 100) },
    { "🛑  Stop Speed", "stopspeed",      Color3.fromRGB(180, 60, 60)  },
    { "👁️  ESP",        "esp",            Color3.fromRGB(220, 80, 80)  },
    { "🛡️  God",        "god",            Color3.fromRGB(200, 160, 60) },
    { "💚  Heal",       "heal",           Color3.fromRGB(60, 180, 60)  },
    { "💀  Respawn",    "respawn",        Color3.fromRGB(180, 60, 60)  },
    { "🦘  InfJump",    "infjump",        Color3.fromRGB(180, 140, 60) },
    { "🌞  Fullbright", "fullbright",     Color3.fromRGB(220, 200, 60) },
    { "🏗️  Createmap",  "createmap",      Color3.fromRGB(140, 120, 200) },
    { "🗑️  Delmap",     "delmap",         Color3.fromRGB(140, 100, 100) },
    { "🕺  Dance 67",   "67 85409308399700", Color3.fromRGB(220, 100, 180) },
    { "⏹️  Stop 67",    "stop67",         Color3.fromRGB(100, 100, 120) },
    { "⛔  Stop All",   "stopall",        Color3.fromRGB(160, 40, 40)  },
}

local function runQuickCmd(cmd)
    log(cmd, Color3.fromRGB(100, 200, 255))
    local result = executeCommand(cmd)
    if result == "__CLEAR__" then
        for _, c in pairs(output:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        output.CanvasSize = UDim2.new(0, 0, 0, 0)
    elseif result == "__DESTROY__" then
        stopFly(); if gui then gui:Destroy() end
    elseif result == "__HELP__" then
        local byCat = {}
        for name, d in pairs(commandList) do
            local c = d.cat or "Other"
            byCat[c] = byCat[c] or {}; table.insert(byCat[c], name)
        end
        local cats = {}; for c in pairs(byCat) do table.insert(cats, c) end; table.sort(cats)
        for _, c in ipairs(cats) do
            log("[" .. c .. "]", Color3.fromRGB(255, 200, 100))
            table.sort(byCat[c])
            for _, n in ipairs(byCat[c]) do
                log("  " .. n .. " — " .. (commandList[n].desc or ""), Color3.fromRGB(180, 220, 180))
            end
        end
    elseif result then
        log(result, Color3.fromRGB(120, 220, 120))
    end
end

for i, q in ipairs(quickCommands) do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = q[3]
    btn.Text = q[1]
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = i
    btn.Parent = quickGrid
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() runQuickCmd(q[2]) end)
end

setTab = function(tab)
    consolePage.Visible  = tab == "console"
    commandsPage.Visible = tab == "commands"
    quickPage.Visible    = tab == "quick"
    consoleTab.BackgroundColor3  = (tab == "console") and Color3.fromRGB(60,60,75) or Color3.fromRGB(40,40,55)
    commandsTab.BackgroundColor3 = (tab == "commands") and Color3.fromRGB(60,60,75) or Color3.fromRGB(40,40,55)
    quickTab.BackgroundColor3    = (tab == "quick") and Color3.fromRGB(60,60,75) or Color3.fromRGB(40,40,55)
end
consoleTab.MouseButton1Click:Connect(function() setTab("console") end)
commandsTab.MouseButton1Click:Connect(function() setTab("commands") end)
quickTab.MouseButton1Click:Connect(function() setTab("quick") end)

buildCommandsPage = function()
    for _, c in pairs(cmdScroll:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    local categories = {}
    for name, data in pairs(commandList) do
        local cat = data.cat or "Other"
        categories[cat] = categories[cat] or {}
        table.insert(categories[cat], name)
    end
    local order = 0
    local catNames = {}; for cat in pairs(categories) do table.insert(catNames, cat) end
    table.sort(catNames)
    for _, cat in ipairs(catNames) do
        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(1, 0, 0, 22); cl.BackgroundTransparency = 1
        cl.Text = "▸ " .. cat
        cl.TextColor3 = Color3.fromRGB(120, 220, 255)
        cl.Font = Enum.Font.GothamBold; cl.TextSize = 14
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.LayoutOrder = order; order = order + 1
        cl.Parent = cmdScroll
        table.sort(categories[cat])
        for _, name in ipairs(categories[cat]) do
            local data = commandList[name]
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
            btn.Text = ""
            btn.LayoutOrder = order; order = order + 1
            btn.Parent = cmdScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

            local nl = Instance.new("TextLabel")
            nl.Size = UDim2.new(0, 120, 1, 0); nl.Position = UDim2.new(0, 8, 0, 0)
            nl.BackgroundTransparency = 1
            nl.Text = name; nl.TextColor3 = Color3.fromRGB(120, 220, 120)
            nl.Font = Enum.Font.Code; nl.TextSize = 13
            nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Parent = btn

            local dl = Instance.new("TextLabel")
            dl.Size = UDim2.new(1, -140, 1, 0); dl.Position = UDim2.new(0, 135, 0, 0)
            dl.BackgroundTransparency = 1
            dl.Text = data.desc or ""; dl.TextColor3 = Color3.fromRGB(180, 180, 190)
            dl.Font = Enum.Font.Gotham; dl.TextSize = 12
            dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Parent = btn

            btn.MouseButton1Click:Connect(function()
                inputBox.Text = name .. " "
                setTab("console")
                inputBox:CaptureFocus()
            end)
        end
    end
    cmdScroll.CanvasSize = UDim2.new(0, 0, 0, cmdListLayout.AbsoluteContentSize.Y + 20)
end

-- История
local history, historyIndex = {}, 0
local function pushHistory(cmd)
    if cmd == "" then return end
    if #history > 0 and history[#history] == cmd then return end
    table.insert(history, cmd)
    if #history > 50 then table.remove(history, 1) end
    historyIndex = 0
end

local function submitCommand()
    local text = inputBox.Text
    if text == "" then return end
    pushHistory(text)
    log(text, Color3.fromRGB(100, 200, 255))
    local result = executeCommand(text)
    if result == "__CLEAR__" then
        for _, c in pairs(output:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        output.CanvasSize = UDim2.new(0, 0, 0, 0)
    elseif result == "__DESTROY__" then
        stopFly(); if gui then gui:Destroy() end; return
    elseif result == "__HELP__" then
        local byCat = {}
        for name, d in pairs(commandList) do
            local c = d.cat or "Other"
            byCat[c] = byCat[c] or {}; table.insert(byCat[c], name)
        end
        local cats = {}; for c in pairs(byCat) do table.insert(cats, c) end; table.sort(cats)
        for _, c in ipairs(cats) do
            log("[" .. c .. "]", Color3.fromRGB(255, 200, 100))
            table.sort(byCat[c])
            for _, n in ipairs(byCat[c]) do
                log("  " .. n .. " — " .. (commandList[n].desc or ""), Color3.fromRGB(180, 220, 180))
            end
        end
    elseif result then
        log(result, Color3.fromRGB(120, 220, 120))
    end
    inputBox.Text = ""
    historyIndex = 0
end

execBtn.MouseButton1Click:Connect(submitCommand)
inputBox.FocusLost:Connect(function(enter) if enter then submitCommand() end end)
closeBtn.MouseButton1Click:Connect(function() stopFly(); if gui then gui:Destroy() end end)

-- история ↑/↓
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not (inputBox and inputBox:IsFocused()) then return end
    if input.KeyCode == Enum.KeyCode.Up then
        if #history == 0 then return end
        if historyIndex == 0 then historyIndex = #history
        elseif historyIndex > 1 then historyIndex = historyIndex - 1 end
        inputBox.Text = history[historyIndex] or ""
    elseif input.KeyCode == Enum.KeyCode.Down then
        if historyIndex == 0 then return end
        if historyIndex < #history then
            historyIndex = historyIndex + 1
            inputBox.Text = history[historyIndex] or ""
        else
            historyIndex = 0; inputBox.Text = ""
        end
    end
end)

-- перетаскивание окна
local dragging = false
local dragStart, startPos
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, i.Position, frame.Position
    end
end)
header.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                   startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- главный цикл
RunService.RenderStepped:Connect(function()
    if state.speedEnabled then
        local hum = getHum(); if hum then hum.WalkSpeed = state.speed end
    end
    if state.jpEnabled then
        local hum = getHum(); if hum then hum.JumpPower = state.jumpPower end
    end
    if state.noclip then applyNoclip() end
    if state.flyEnabled and getHRP() and not flyBV then startFly() end
    if state.espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then createESP(p) end
        end
    end
end)

player.CharacterAdded:Connect(function()
    stopFly(); current67Track = nil
    if state.flyEnabled then task.wait(1); startFly() end
end)

-- старт
buildCommandsPage()
local total = 0; for _ in pairs(commandList) do total = total + 1 end
log("Godoh Admin v8 — " .. total .. " команд", Color3.fromRGB(120, 220, 120))
log("Кнопка '—' в шапке — скрыть панель", Color3.fromRGB(150, 200, 255))
log("Плавающая '⚡' — показать обратно", Color3.fromRGB(255, 200, 120))
print("[Godoh] загружено OK — " .. total .. " команд")
