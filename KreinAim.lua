--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera

--// Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Storage
local Connections = {}
local Drawings = {}
local ToggleRefs = {}

--// RGB
local RGBColor = Color3.fromRGB(255, 0, 0)
local RGBHue = 0

--// Settings
local Settings = {
    -- Skeleton
    SkeletonESP = false,
    SkeletonThickness = 2,
    -- Box
    BoxESP = false,
    -- Corner Box
    CornerBoxESP = false,
    CornerBoxLength = 6,
    -- Tracer
    TracerESP = false,
    TracerThickness = 1,
    TracerOrigin = "Bottom",
    -- Name ESP (dipisah)
    NameESP = false,
    NameSize = 10,
    HealthTextESP = false,
    HealthTextSize = 10,
    DistanceESP = false,
    DistanceSize = 10,
    -- Health Bar
    HealthBar = false,
    -- General
    TeamCheck = false,
    -- Aimbot
    AimbotEnabled = false,
    AimbotLockPart = "Head",
    AimbotSensitivity = 0,
    AimbotTeamCheck = false,
    AimbotAliveCheck = true,
    AimbotWallCheck = false,
    AimbotPrediction = false,
    AimbotPredictionStrength = 1.0,
    AimbotHoldKey = false,
    AimbotHoldKeyBind = "Q",
    AimbotAutoShoot = false,
    AimbotAutoShootDelay = 0.1,
    -- Misc
    Fullbright = false,
    NoFog = false,
    NoShadow = false,
    -- FOV
    FOVEnabled = true,
    FOVVisible = true,
    FOVAmount = 90,
    FOVThickness = 2,
    FOVSides = 60,
}

--// =============================================
--// UTILITY
--// =============================================
local function SafeDisconnect(key)
    if Connections[key] then
        if typeof(Connections[key]) == "table" then
            for _, conn in pairs(Connections[key]) do
                if typeof(conn) == "RBXScriptConnection" then
                    pcall(function() conn:Disconnect() end)
                end
            end
        elseif typeof(Connections[key]) == "RBXScriptConnection" then
            pcall(function() Connections[key]:Disconnect() end)
        end
        Connections[key] = nil
    end
end

local function IsAlive(player)
    if not player then return false end
    if not player.Parent then return false end
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    if not char:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

local function IsEnemy(player, teamCheck)
    if not teamCheck then return true end
    if not player.Team then return true end
    if not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function WorldToScreen(position)
    local cam = workspace.CurrentCamera
    if not cam then return Vector2.new(0, 0), false, 0 end
    local vec, onScreen = cam:WorldToViewportPoint(position)
    return Vector2.new(vec.X, vec.Y), onScreen, vec.Z
end

local function GetViewportCenter()
    local cam = workspace.CurrentCamera
    if cam then
        return cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
    end
    return 0, 0
end

local function IsWallBetween(origin, targetPos, ignoreList)
    local direction = targetPos - origin
    local distance = direction.Magnitude
    if distance <= 0 then return false end
    local rayParams = RaycastParams.new()
    -- Gunakan Exclude (pengganti Blacklist yang deprecated)
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    rayParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction.Unit * (distance - 0.1), rayParams)
    return result ~= nil
end

--// =============================================
--// VELOCITY PREDICTION HELPER
--// =============================================
-- Menyimpan posisi sebelumnya untuk hitung velocity tiap player
local PrevPositions = {}

local function GetPredictedPosition(player, part)
    if not Settings.AimbotPrediction then
        return part.Position
    end

    local now = tick()
    local key = tostring(player.UserId)
    local prev = PrevPositions[key]

    if prev then
        local dt = now - prev.time
        if dt > 0 and dt < 0.2 then
            -- Hitung velocity (stud/s) lalu project ke depan
            local velocity = (part.Position - prev.pos) / dt
            -- Strength mengontrol seberapa jauh prediksi
            local predictedPos = part.Position + velocity * Settings.AimbotPredictionStrength
            PrevPositions[key] = { pos = part.Position, time = now }
            return predictedPos
        end
    end

    PrevPositions[key] = { pos = part.Position, time = now }
    return part.Position
end

-- Bersihkan data saat player pergi
Players.PlayerRemoving:Connect(function(plr)
    PrevPositions[tostring(plr.UserId)] = nil
end)

--// =============================================
--// FOV CIRCLE (Drawing + GUI Fallback, keduanya aktif)
--// =============================================
local FOVDrawing = nil
local FOVGui = nil
local FOVFrame = nil
local FOVStroke = nil

-- Buat Drawing circle
pcall(function()
    FOVDrawing = Drawing.new("Circle")
    FOVDrawing.Visible = false
    FOVDrawing.Filled = false
    FOVDrawing.Thickness = 2
    FOVDrawing.NumSides = 60
    FOVDrawing.Radius = 90
    FOVDrawing.Color = Color3.fromRGB(255, 255, 255)
    FOVDrawing.Transparency = 1
    FOVDrawing.Position = Vector2.new(0, 0)
end)

-- Selalu buat GUI fallback juga
pcall(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    FOVGui = Instance.new("ScreenGui")
    FOVGui.Name = "KreinAimFOV"
    FOVGui.ResetOnSpawn = false
    FOVGui.IgnoreGuiInset = true
    FOVGui.DisplayOrder = 999
    FOVGui.Parent = playerGui

    FOVFrame = Instance.new("Frame")
    FOVFrame.Name = "FOVCircle"
    FOVFrame.BackgroundTransparency = 1
    FOVFrame.BorderSizePixel = 0
    FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVFrame.Parent = FOVGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = FOVFrame

    FOVStroke = Instance.new("UIStroke")
    FOVStroke.Thickness = 2
    FOVStroke.Color = Color3.fromRGB(255, 255, 255)
    FOVStroke.Transparency = 0
    FOVStroke.Parent = FOVFrame
end)

local function UpdateFOVCircle(visible, radius, thickness, color)
    local centerX, centerY = GetViewportCenter()

    if FOVDrawing then
        pcall(function()
            FOVDrawing.Position = Vector2.new(centerX, centerY)
            FOVDrawing.Radius = radius
            FOVDrawing.Thickness = thickness
            FOVDrawing.NumSides = Settings.FOVSides
            FOVDrawing.Filled = false
            FOVDrawing.Transparency = 1
            FOVDrawing.Color = color
            FOVDrawing.Visible = visible
        end)
    end

    if FOVFrame and FOVStroke then
        pcall(function()
            local diameter = radius * 2
            FOVFrame.Size = UDim2.fromOffset(diameter, diameter)
            FOVFrame.Position = UDim2.fromOffset(centerX, centerY)
            FOVFrame.Visible = visible
            FOVStroke.Thickness = thickness
            FOVStroke.Color = color
            FOVStroke.Transparency = visible and 0 or 1
        end)
    end
end

local function DestroyFOV()
    if FOVDrawing then
        pcall(function() FOVDrawing:Remove() end)
        FOVDrawing = nil
    end
    if FOVGui then
        pcall(function() FOVGui:Destroy() end)
        FOVGui = nil
        FOVFrame = nil
        FOVStroke = nil
    end
end

--// =============================================
--// RGB + FOV UPDATER
--// =============================================
local AimbotModule = {}
AimbotModule.Locked = nil
AimbotModule.TweenAnim = nil

Connections["rgb"] = RunService.RenderStepped:Connect(function()
    RGBHue = (RGBHue + 0.003) % 1
    RGBColor = Color3.fromHSV(RGBHue, 1, 1)
    Camera = workspace.CurrentCamera

    if Settings.AimbotEnabled and Settings.FOVEnabled and Settings.FOVVisible then
        local col = AimbotModule.Locked and Color3.fromRGB(255, 50, 50) or RGBColor
        UpdateFOVCircle(true, Settings.FOVAmount, Settings.FOVThickness, col)
    else
        UpdateFOVCircle(false, Settings.FOVAmount, Settings.FOVThickness, RGBColor)
    end
end)

--// =============================================
--// SKELETON ESP
--// =============================================
local SkeletonModule = {}

function SkeletonModule:GetBones(character, humanoid)
    local joints = {}
    local bones = {}
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        for _, name in ipairs({
            "Head","UpperTorso","LowerTorso",
            "LeftUpperArm","LeftLowerArm","LeftHand",
            "RightUpperArm","RightLowerArm","RightHand",
            "LeftUpperLeg","LeftLowerLeg","LeftFoot",
            "RightUpperLeg","RightLowerLeg","RightFoot"
        }) do
            joints[name] = character:FindFirstChild(name)
        end
        bones = {
            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
            {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
            {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
        }
    else
        joints["Head"] = character:FindFirstChild("Head")
        joints["Torso"] = character:FindFirstChild("Torso")
        joints["Left Arm"] = character:FindFirstChild("Left Arm")
        joints["Right Arm"] = character:FindFirstChild("Right Arm")
        joints["Left Leg"] = character:FindFirstChild("Left Leg")
        joints["Right Leg"] = character:FindFirstChild("Right Leg")
        bones = {
            {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
            {"Torso","Left Leg"},{"Torso","Right Leg"},
        }
    end
    return joints, bones
end

function SkeletonModule:Enable()
    if Connections["skeleton"] then return end
    Drawings["skeleton"] = {}
    Connections["skeleton"] = {}

    Connections["skeleton"].render = RunService.RenderStepped:Connect(function()
        if not Settings.SkeletonESP then
            for _, lines in pairs(Drawings["skeleton"]) do
                for _, l in pairs(lines) do l.Visible = false end
            end
            return
        end
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local joints, bones = self:GetBones(char, hum)
                if not Drawings["skeleton"][plr] then
                    Drawings["skeleton"][plr] = {}
                    for i = 1, #bones do
                        local line = Drawing.new("Line")
                        line.Visible = false
                        Drawings["skeleton"][plr][i] = line
                    end
                end
                local lines = Drawings["skeleton"][plr]
                while #lines < #bones do
                    lines[#lines+1] = Drawing.new("Line")
                    lines[#lines].Visible = false
                end
                while #lines > #bones do
                    lines[#lines]:Remove()
                    lines[#lines] = nil
                end
                for i, bone in ipairs(bones) do
                    local a = joints[bone[1]]
                    local b = joints[bone[2]]
                    local line = lines[i]
                    if a and b then
                        local pA, onA = WorldToScreen(a.Position)
                        local pB, onB = WorldToScreen(b.Position)
                        if onA and onB then
                            line.From = pA
                            line.To = pB
                            line.Color = RGBColor
                            line.Thickness = Settings.SkeletonThickness
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            end
        end
        for plr, lines in pairs(Drawings["skeleton"]) do
            if not alive[plr] then
                for _, l in pairs(lines) do l.Visible = false end
            end
        end
    end)

    Connections["skeleton"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["skeleton"] and Drawings["skeleton"][plr] then
            for _, l in pairs(Drawings["skeleton"][plr]) do pcall(function() l:Remove() end) end
            Drawings["skeleton"][plr] = nil
        end
    end)
end

function SkeletonModule:Disable()
    SafeDisconnect("skeleton")
    if Drawings["skeleton"] then
        for _, lines in pairs(Drawings["skeleton"]) do
            for _, l in pairs(lines) do pcall(function() l:Remove() end) end
        end
        Drawings["skeleton"] = nil
    end
end

--// =============================================
--// BOX ESP
--// =============================================
local BoxModule = {}

function BoxModule:Enable()
    if Connections["box"] then return end
    Drawings["box"] = {}
    Connections["box"] = {}

    Connections["box"].render = RunService.RenderStepped:Connect(function()
        if not Settings.BoxESP then
            for _, d in pairs(Drawings["box"]) do
                d.box.Visible = false
                d.outline.Visible = false
            end
            return
        end
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if not Drawings["box"][plr] then
                    local d = {}
                    d.box = Drawing.new("Square")
                    d.box.Thickness = 1
                    d.box.Filled = false
                    d.box.Visible = false
                    d.box.ZIndex = 2
                    d.outline = Drawing.new("Square")
                    d.outline.Thickness = 3
                    d.outline.Filled = false
                    d.outline.Color = Color3.new(0,0,0)
                    d.outline.Visible = false
                    d.outline.ZIndex = 1
                    Drawings["box"][plr] = d
                end
                local d = Drawings["box"][plr]
                if hrp and head then
                    local top, topOn, topZ = WorldToScreen(head.Position + Vector3.new(0,1,0))
                    local bot, botOn, botZ = WorldToScreen(hrp.Position - Vector3.new(0,3,0))
                    if topOn and botOn and topZ > 0 and botZ > 0 then
                        local h = math.abs(bot.Y - top.Y)
                        local w = h / 1.8
                        local bx = math.floor(top.X - w/2)
                        local by = math.floor(top.Y)
                        d.box.Size = Vector2.new(math.floor(w), math.floor(h))
                        d.box.Position = Vector2.new(bx, by)
                        d.box.Color = RGBColor
                        d.box.Visible = true
                        d.outline.Size = Vector2.new(math.floor(w)+2, math.floor(h)+2)
                        d.outline.Position = Vector2.new(bx-1, by-1)
                        d.outline.Visible = true
                    else
                        d.box.Visible = false
                        d.outline.Visible = false
                    end
                else
                    d.box.Visible = false
                    d.outline.Visible = false
                end
            end
        end
        for plr, d in pairs(Drawings["box"]) do
            if not alive[plr] then
                d.box.Visible = false
                d.outline.Visible = false
            end
        end
    end)

    Connections["box"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["box"] and Drawings["box"][plr] then
            pcall(function() Drawings["box"][plr].box:Remove() end)
            pcall(function() Drawings["box"][plr].outline:Remove() end)
            Drawings["box"][plr] = nil
        end
    end)
end

function BoxModule:Disable()
    SafeDisconnect("box")
    if Drawings["box"] then
        for _, d in pairs(Drawings["box"]) do
            pcall(function() d.box:Remove() end)
            pcall(function() d.outline:Remove() end)
        end
        Drawings["box"] = nil
    end
end

--// =============================================
--// CORNER BOX ESP
--// =============================================
local CornerBoxModule = {}

local function MakeCornerLines()
    local lines = {}
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1
        lines[i] = l
    end
    return lines
end

function CornerBoxModule:Enable()
    if Connections["cornerbox"] then return end
    Drawings["cornerbox"] = {}
    Connections["cornerbox"] = {}

    Connections["cornerbox"].render = RunService.RenderStepped:Connect(function()
        if not Settings.CornerBoxESP then
            for _, lines in pairs(Drawings["cornerbox"]) do
                for _, l in ipairs(lines) do l.Visible = false end
            end
            return
        end

        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")

                if not Drawings["cornerbox"][plr] then
                    Drawings["cornerbox"][plr] = MakeCornerLines()
                end
                local L = Drawings["cornerbox"][plr]

                if hrp and head then
                    local top, topOn, topZ = WorldToScreen(head.Position + Vector3.new(0, 1, 0))
                    local bot, botOn, botZ = WorldToScreen(hrp.Position - Vector3.new(0, 3, 0))

                    if topOn and botOn and topZ > 0 and botZ > 0 then
                        local h = math.abs(bot.Y - top.Y)
                        local w = h / 1.8
                        -- Pastikan minimum ukuran agar len tidak 0
                        if h < 4 or w < 4 then
                            for _, l in ipairs(L) do l.Visible = false end
                        else
                            local len = math.clamp(Settings.CornerBoxLength, 2, math.floor(math.min(w, h) / 2))
                            local x0 = math.floor(top.X - w / 2)
                            local y0 = math.floor(top.Y)
                            local x1 = x0 + math.floor(w)
                            local y1 = y0 + math.floor(h)

                            -- Sudut TL
                            L[1].From = Vector2.new(x0, y0); L[1].To = Vector2.new(x0 + len, y0)
                            L[2].From = Vector2.new(x0, y0); L[2].To = Vector2.new(x0, y0 + len)
                            -- Sudut TR
                            L[3].From = Vector2.new(x1, y0); L[3].To = Vector2.new(x1 - len, y0)
                            L[4].From = Vector2.new(x1, y0); L[4].To = Vector2.new(x1, y0 + len)
                            -- Sudut BL
                            L[5].From = Vector2.new(x0, y1); L[5].To = Vector2.new(x0 + len, y1)
                            L[6].From = Vector2.new(x0, y1); L[6].To = Vector2.new(x0, y1 - len)
                            -- Sudut BR
                            L[7].From = Vector2.new(x1, y1); L[7].To = Vector2.new(x1 - len, y1)
                            L[8].From = Vector2.new(x1, y1); L[8].To = Vector2.new(x1, y1 - len)

                            for _, l in ipairs(L) do
                                l.Color = RGBColor
                                l.Thickness = 1
                                l.Visible = true
                            end
                        end
                    else
                        for _, l in ipairs(L) do l.Visible = false end
                    end
                else
                    for _, l in ipairs(L) do l.Visible = false end
                end
            end
        end

        for plr, lines in pairs(Drawings["cornerbox"]) do
            if not alive[plr] then
                for _, l in ipairs(lines) do l.Visible = false end
            end
        end
    end)

    Connections["cornerbox"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["cornerbox"] and Drawings["cornerbox"][plr] then
            for _, l in ipairs(Drawings["cornerbox"][plr]) do
                pcall(function() l:Remove() end)
            end
            Drawings["cornerbox"][plr] = nil
        end
    end)
end

function CornerBoxModule:Disable()
    SafeDisconnect("cornerbox")
    if Drawings["cornerbox"] then
        for _, lines in pairs(Drawings["cornerbox"]) do
            for _, l in ipairs(lines) do pcall(function() l:Remove() end) end
        end
        Drawings["cornerbox"] = nil
    end
end

--// =============================================
--// TRACER ESP
--// =============================================
local TracerModule = {}

function TracerModule:Enable()
    if Connections["tracer"] then return end
    Drawings["tracer"] = {}
    Connections["tracer"] = {}

    Connections["tracer"].render = RunService.RenderStepped:Connect(function()
        if not Settings.TracerESP then
            for _, line in pairs(Drawings["tracer"]) do line.Visible = false end
            return
        end
        local vpSize = Camera.ViewportSize
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not Drawings["tracer"][plr] then
                    local line = Drawing.new("Line")
                    line.Visible = false
                    line.Transparency = 1
                    Drawings["tracer"][plr] = line
                end
                local line = Drawings["tracer"][plr]
                if hrp then
                    local screen, onScreen, depth = WorldToScreen(hrp.Position)
                    if onScreen and depth > 0 then
                        local fromY = vpSize.Y
                        if Settings.TracerOrigin == "Top" then fromY = 0
                        elseif Settings.TracerOrigin == "Center" then fromY = vpSize.Y/2 end
                        line.From = Vector2.new(vpSize.X/2, fromY)
                        line.To = screen
                        line.Color = RGBColor
                        line.Thickness = Settings.TracerThickness
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end
        for plr, line in pairs(Drawings["tracer"]) do
            if not alive[plr] then line.Visible = false end
        end
    end)

    Connections["tracer"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["tracer"] and Drawings["tracer"][plr] then
            pcall(function() Drawings["tracer"][plr]:Remove() end)
            Drawings["tracer"][plr] = nil
        end
    end)
end

function TracerModule:Disable()
    SafeDisconnect("tracer")
    if Drawings["tracer"] then
        for _, line in pairs(Drawings["tracer"]) do pcall(function() line:Remove() end) end
        Drawings["tracer"] = nil
    end
end

--// =============================================
--// NAME ESP (hanya nama saja)
--// =============================================
local NameModule = {}

function NameModule:Enable()
    if Connections["name"] then return end
    Drawings["name"] = {}
    Connections["name"] = {}

    Connections["name"].render = RunService.RenderStepped:Connect(function()
        if not Settings.NameESP then
            for _, d in pairs(Drawings["name"]) do d.Visible = false end
            return
        end
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not Drawings["name"][plr] then
                    local t = Drawing.new("Text")
                    t.Visible = false
                    t.Center = true
                    t.Outline = true
                    t.OutlineColor = Color3.new(0,0,0)
                    t.Size = Settings.NameSize
                    t.ZIndex = 5
                    Drawings["name"][plr] = t
                end
                local t = Drawings["name"][plr]
                if head and hrp then
                    local screen, onScreen, depth = WorldToScreen(head.Position + Vector3.new(0, 2.4, 0))
                    if onScreen and depth > 0 then
                        t.Text = plr.DisplayName
                        t.Position = screen
                        t.Color = RGBColor
                        t.Size = Settings.NameSize
                        t.Visible = true
                    else
                        t.Visible = false
                    end
                else
                    t.Visible = false
                end
            end
        end
        for plr, t in pairs(Drawings["name"]) do
            if not alive[plr] then t.Visible = false end
        end
    end)

    Connections["name"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["name"] and Drawings["name"][plr] then
            pcall(function() Drawings["name"][plr]:Remove() end)
            Drawings["name"][plr] = nil
        end
    end)
end

function NameModule:Disable()
    SafeDisconnect("name")
    if Drawings["name"] then
        for _, t in pairs(Drawings["name"]) do pcall(function() t:Remove() end) end
        Drawings["name"] = nil
    end
end

--// =============================================
--// HEALTH TEXT ESP (hanya teks HP)
--// =============================================
local HealthTextModule = {}

function HealthTextModule:Enable()
    if Connections["healthtext"] then return end
    Drawings["healthtext"] = {}
    Connections["healthtext"] = {}

    Connections["healthtext"].render = RunService.RenderStepped:Connect(function()
        if not Settings.HealthTextESP then
            for _, t in pairs(Drawings["healthtext"]) do t.Visible = false end
            return
        end
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not Drawings["healthtext"][plr] then
                    local t = Drawing.new("Text")
                    t.Visible = false
                    t.Center = true
                    t.Outline = true
                    t.OutlineColor = Color3.new(0,0,0)
                    t.Size = Settings.HealthTextSize
                    t.ZIndex = 5
                    Drawings["healthtext"][plr] = t
                end
                local t = Drawings["healthtext"][plr]
                if head and hrp and humanoid then
                    -- Tampil di bawah nama (offset lebih ke bawah)
                    local screen, onScreen, depth = WorldToScreen(head.Position + Vector3.new(0, 2.4, 0))
                    if onScreen and depth > 0 then
                        local hp = math.floor(humanoid.Health)
                        local maxHp = math.floor(humanoid.MaxHealth)
                        -- Warna berubah sesuai persentase HP
                        local pct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local hpColor = Color3.fromRGB(255*(1-pct), 255*pct, 0)
                        t.Text = "[" .. hp .. "/" .. maxHp .. " HP]"
                        t.Position = Vector2.new(screen.X, screen.Y + Settings.HealthTextSize + 2)
                        t.Color = hpColor
                        t.Size = Settings.HealthTextSize
                        t.Visible = true
                    else
                        t.Visible = false
                    end
                else
                    t.Visible = false
                end
            end
        end
        for plr, t in pairs(Drawings["healthtext"]) do
            if not alive[plr] then t.Visible = false end
        end
    end)

    Connections["healthtext"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["healthtext"] and Drawings["healthtext"][plr] then
            pcall(function() Drawings["healthtext"][plr]:Remove() end)
            Drawings["healthtext"][plr] = nil
        end
    end)
end

function HealthTextModule:Disable()
    SafeDisconnect("healthtext")
    if Drawings["healthtext"] then
        for _, t in pairs(Drawings["healthtext"]) do pcall(function() t:Remove() end) end
        Drawings["healthtext"] = nil
    end
end

--// =============================================
--// DISTANCE ESP (hanya jarak)
--// =============================================
local DistanceModule = {}

function DistanceModule:Enable()
    if Connections["distance"] then return end
    Drawings["distance"] = {}
    Connections["distance"] = {}

    Connections["distance"].render = RunService.RenderStepped:Connect(function()
        if not Settings.DistanceESP then
            for _, t in pairs(Drawings["distance"]) do t.Visible = false end
            return
        end
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not Drawings["distance"][plr] then
                    local t = Drawing.new("Text")
                    t.Visible = false
                    t.Center = true
                    t.Outline = true
                    t.OutlineColor = Color3.new(0,0,0)
                    t.Size = Settings.DistanceSize
                    t.ZIndex = 5
                    Drawings["distance"][plr] = t
                end
                local t = Drawings["distance"][plr]
                if head and hrp then
                    local screen, onScreen, depth = WorldToScreen(head.Position + Vector3.new(0, 2.4, 0))
                    if onScreen and depth > 0 then
                        local dist = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0
                        -- Offset di bawah HP text (atau nama jika HP off)
                        local offsetY = Settings.HealthTextESP
                            and (Settings.HealthTextSize * 2 + 4)
                            or (Settings.NameESP and Settings.NameSize + 2 or 0)
                        t.Text = "[" .. dist .. "m]"
                        t.Position = Vector2.new(screen.X, screen.Y + Settings.DistanceSize + offsetY)
                        t.Color = Color3.fromRGB(180, 220, 255)
                        t.Size = Settings.DistanceSize
                        t.Visible = true
                    else
                        t.Visible = false
                    end
                else
                    t.Visible = false
                end
            end
        end
        for plr, t in pairs(Drawings["distance"]) do
            if not alive[plr] then t.Visible = false end
        end
    end)

    Connections["distance"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["distance"] and Drawings["distance"][plr] then
            pcall(function() Drawings["distance"][plr]:Remove() end)
            Drawings["distance"][plr] = nil
        end
    end)
end

function DistanceModule:Disable()
    SafeDisconnect("distance")
    if Drawings["distance"] then
        for _, t in pairs(Drawings["distance"]) do pcall(function() t:Remove() end) end
        Drawings["distance"] = nil
    end
end

--// =============================================
--// HEALTH BAR ESP
--// =============================================
local HealthBarModule = {}

function HealthBarModule:Enable()
    if Connections["healthbar"] then return end
    Drawings["healthbar"] = {}
    Connections["healthbar"] = {}

    Connections["healthbar"].render = RunService.RenderStepped:Connect(function()
        if not Settings.HealthBar then
            for _, d in pairs(Drawings["healthbar"]) do
                d.bgOutline.Visible = false
                d.bg.Visible = false
                d.bar.Visible = false
            end
            return
        end
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not Drawings["healthbar"][plr] then
                    local d = {}
                    d.bgOutline = Drawing.new("Square")
                    d.bgOutline.Filled = true
                    d.bgOutline.Color = Color3.new(0,0,0)
                    d.bgOutline.Visible = false
                    d.bgOutline.ZIndex = 1
                    d.bg = Drawing.new("Square")
                    d.bg.Filled = true
                    d.bg.Color = Color3.fromRGB(40,40,40)
                    d.bg.Visible = false
                    d.bg.ZIndex = 2
                    d.bar = Drawing.new("Square")
                    d.bar.Filled = true
                    d.bar.Visible = false
                    d.bar.ZIndex = 3
                    Drawings["healthbar"][plr] = d
                end
                local d = Drawings["healthbar"][plr]
                if hrp and head and humanoid then
                    local top, topOn, topZ = WorldToScreen(head.Position + Vector3.new(0,1,0))
                    local bot, botOn, botZ = WorldToScreen(hrp.Position - Vector3.new(0,3,0))
                    if topOn and botOn and topZ > 0 and botZ > 0 then
                        local boxH = math.abs(bot.Y - top.Y)
                        local boxW = boxH / 1.8
                        local bW = 4
                        local bX = math.floor(top.X - boxW/2 - bW - 4)
                        local bY = math.floor(top.Y)
                        local pct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local bH = math.max(math.floor(boxH * pct), 1)
                        local col = Color3.fromRGB(255*(1-pct), 255*pct, 0)
                        d.bgOutline.Size = Vector2.new(bW+2, math.floor(boxH)+2)
                        d.bgOutline.Position = Vector2.new(bX-1, bY-1)
                        d.bgOutline.Visible = true
                        d.bg.Size = Vector2.new(bW, math.floor(boxH))
                        d.bg.Position = Vector2.new(bX, bY)
                        d.bg.Visible = true
                        d.bar.Size = Vector2.new(bW, bH)
                        d.bar.Position = Vector2.new(bX, bY + math.floor(boxH) - bH)
                        d.bar.Color = col
                        d.bar.Visible = true
                    else
                        d.bgOutline.Visible = false
                        d.bg.Visible = false
                        d.bar.Visible = false
                    end
                else
                    d.bgOutline.Visible = false
                    d.bg.Visible = false
                    d.bar.Visible = false
                end
            end
        end
        for plr, d in pairs(Drawings["healthbar"]) do
            if not alive[plr] then
                d.bgOutline.Visible = false
                d.bg.Visible = false
                d.bar.Visible = false
            end
        end
    end)

    Connections["healthbar"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["healthbar"] and Drawings["healthbar"][plr] then
            pcall(function() Drawings["healthbar"][plr].bgOutline:Remove() end)
            pcall(function() Drawings["healthbar"][plr].bg:Remove() end)
            pcall(function() Drawings["healthbar"][plr].bar:Remove() end)
            Drawings["healthbar"][plr] = nil
        end
    end)
end

function HealthBarModule:Disable()
    SafeDisconnect("healthbar")
    if Drawings["healthbar"] then
        for _, d in pairs(Drawings["healthbar"]) do
            pcall(function() d.bgOutline:Remove() end)
            pcall(function() d.bg:Remove() end)
            pcall(function() d.bar:Remove() end)
        end
        Drawings["healthbar"] = nil
    end
end

--// =============================================
--// AIMBOT MODULE (dengan Velocity Prediction)
--// =============================================
-- State untuk Hold Key dan Auto Shoot
local AimbotHoldActive = false
local AutoShootLastTime = 0

-- Mapping nama key ke KeyCode
local KeyMap = {
    Q = Enum.KeyCode.Q,
    E = Enum.KeyCode.E,
    R = Enum.KeyCode.R,
    F = Enum.KeyCode.F,
    Z = Enum.KeyCode.Z,
    X = Enum.KeyCode.X,
    C = Enum.KeyCode.C,
    V = Enum.KeyCode.V,
    G = Enum.KeyCode.G,
    H = Enum.KeyCode.H,
    LeftShift = Enum.KeyCode.LeftShift,
    RightShift = Enum.KeyCode.RightShift,
    LeftControl = Enum.KeyCode.LeftControl,
    LeftAlt = Enum.KeyCode.LeftAlt,
}
function AimbotModule:CancelLock()
    self.Locked = nil
    if self.TweenAnim then
        pcall(function() self.TweenAnim:Cancel() end)
        self.TweenAnim = nil
    end
end

function AimbotModule:GetClosestPlayer()
    local maxDist = Settings.FOVEnabled and Settings.FOVAmount or 9999
    local centerX, centerY = GetViewportCenter()
    local center = Vector2.new(centerX, centerY)
    local best = nil
    local bestDist = maxDist
    local myChar = LocalPlayer.Character

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.AimbotAliveCheck and not IsAlive(plr) then continue end
        if Settings.AimbotTeamCheck and not IsEnemy(plr, true) then continue end
        local char = plr.Character
        if not char then continue end
        local part = char:FindFirstChild(Settings.AimbotLockPart)
        if not part then continue end
        local screen, onScreen, depth = WorldToScreen(part.Position)
        if not onScreen or depth <= 0 then continue end
        if Settings.AimbotWallCheck then
            local camPos = workspace.CurrentCamera.CFrame.Position
            if IsWallBetween(camPos, part.Position, {myChar, char}) then continue end
        end
        local dist = (center - screen).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = plr
        end
    end
    return best
end

function AimbotModule:Enable()
    if Connections["aimbot"] then return end
    Connections["aimbot"] = {}

    Connections["aimbot"].render = RunService.RenderStepped:Connect(function()
        if not Settings.AimbotEnabled then
            if self.Locked then self:CancelLock() end
            return
        end

        -- Hold Key check: jika mode hold aktif, cek apakah tombol sedang ditekan
        if Settings.AimbotHoldKey then
            local kc = KeyMap[Settings.AimbotHoldKeyBind]
            local held = kc and UserInputService:IsKeyDown(kc) or false
            if not held then
                if self.Locked then self:CancelLock() end
                return
            end
        end

        local cam = workspace.CurrentCamera
        if not cam then return end

        -- Validasi target
        if self.Locked then
            local valid = true
            if not IsAlive(self.Locked) then valid = false end
            if valid and Settings.AimbotTeamCheck and not IsEnemy(self.Locked, true) then valid = false end
            if valid then
                local char = self.Locked.Character
                local part = char and char:FindFirstChild(Settings.AimbotLockPart)
                if not part then
                    valid = false
                else
                    local screen, onScreen, depth = WorldToScreen(part.Position)
                    if not onScreen or depth <= 0 then valid = false end
                    if valid and Settings.AimbotWallCheck then
                        local myChar = LocalPlayer.Character
                        if IsWallBetween(cam.CFrame.Position, part.Position, {myChar, char}) then valid = false end
                    end
                    if valid then
                        local centerX, centerY = GetViewportCenter()
                        local center = Vector2.new(centerX, centerY)
                        local dist = (center - screen).Magnitude
                        local maxDist = Settings.FOVEnabled and (Settings.FOVAmount * 1.5) or 9999
                        if dist > maxDist then valid = false end
                    end
                end
            end
            if not valid then self:CancelLock() end
        end

        if not self.Locked then
            self.Locked = self:GetClosestPlayer()
        end

        if self.Locked then
            local char = self.Locked.Character
            local part = char and char:FindFirstChild(Settings.AimbotLockPart)
            if part then
                local targetPos = GetPredictedPosition(self.Locked, part)

                if Settings.AimbotSensitivity > 0 then
                    if self.TweenAnim then pcall(function() self.TweenAnim:Cancel() end) end
                    self.TweenAnim = TweenService:Create(
                        cam,
                        TweenInfo.new(Settings.AimbotSensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        {CFrame = CFrame.new(cam.CFrame.Position, targetPos)}
                    )
                    self.TweenAnim:Play()
                else
                    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
                end

                -- Auto Shoot: hanya jalan kalau:
                -- 1. self.Locked ada (sudah dicek di atas)
                -- 2. AimbotAutoShoot aktif
                -- 3. Part target on-screen
                -- 4. Aim sudah dekat ke target (< 15px dari tengah layar)
                -- 5. Cooldown sudah lewat
                if Settings.AimbotAutoShoot then
                    local screenPos, onScreen = WorldToScreen(part.Position)
                    if onScreen then
                        local centerX, centerY = GetViewportCenter()
                        local distToCenter = (Vector2.new(centerX, centerY) - screenPos).Magnitude
                        local now = tick()
                        if distToCenter < 15 and (now - AutoShootLastTime) >= Settings.AimbotAutoShootDelay then
                            AutoShootLastTime = now
                            pcall(function() mouse1click() end)
                        end
                    end
                end
            end
        else
            -- Tidak ada target terkunci — pastikan auto shoot tidak jalan
            AutoShootLastTime = tick()
        end
    end)
end

function AimbotModule:Disable()
    self:CancelLock()
    SafeDisconnect("aimbot")
end

--// =============================================
--// MISC MODULES
--// =============================================

-- Simpan nilai asli Lighting
local OriginalLighting = {}

local function SaveLighting()
    local L = game:GetService("Lighting")
    OriginalLighting.Brightness      = L.Brightness
    OriginalLighting.Ambient         = L.Ambient
    OriginalLighting.OutdoorAmbient  = L.OutdoorAmbient
    OriginalLighting.FogEnd          = L.FogEnd
    OriginalLighting.FogStart        = L.FogStart
    OriginalLighting.GlobalShadows   = L.GlobalShadows
end
SaveLighting()

local function SetFullbright(enabled)
    local L = game:GetService("Lighting")
    if enabled then
        L.Brightness     = 2
        L.Ambient        = Color3.fromRGB(178, 178, 178)
        L.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        L.Brightness     = OriginalLighting.Brightness
        L.Ambient        = OriginalLighting.Ambient
        L.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

local function SetNoFog(enabled)
    local L = game:GetService("Lighting")
    if enabled then
        L.FogEnd   = 1e6
        L.FogStart = 1e6
    else
        L.FogEnd   = OriginalLighting.FogEnd
        L.FogStart = OriginalLighting.FogStart
    end
end

local function SetNoShadow(enabled)
    local L = game:GetService("Lighting")
    L.GlobalShadows = not enabled
end

--// =============================================
--// RAYFIELD GUI
--// =============================================
local Window = Rayfield:CreateWindow({
    Name = "KreinAim",
    LoadingTitle = "KreinAim",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

--// ========================
--// ESP TAB — hanya toggle on/off
--// ========================
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateSection("General")
ESPTab:CreateToggle({
    Name = "Team Check", CurrentValue = false, Flag = "TC_ESP",
    Callback = function(v) Settings.TeamCheck = v end,
})

ESPTab:CreateSection("Visual")
ToggleRefs.BoxESP = ESPTab:CreateToggle({
    Name = "Box ESP", CurrentValue = false, Flag = "BOX_T",
    Callback = function(v)
        Settings.BoxESP = v
        if v then BoxModule:Enable() else BoxModule:Disable() end
    end,
})
ToggleRefs.CornerBoxESP = ESPTab:CreateToggle({
    Name = "Corner Box ESP", CurrentValue = false, Flag = "CBOX_T",
    Callback = function(v)
        Settings.CornerBoxESP = v
        if v then CornerBoxModule:Enable() else CornerBoxModule:Disable() end
    end,
})
ToggleRefs.SkeletonESP = ESPTab:CreateToggle({
    Name = "Skeleton ESP", CurrentValue = false, Flag = "SKEL_T",
    Callback = function(v)
        Settings.SkeletonESP = v
        if v then SkeletonModule:Enable() else SkeletonModule:Disable() end
    end,
})
ToggleRefs.TracerESP = ESPTab:CreateToggle({
    Name = "Tracer ESP", CurrentValue = false, Flag = "TRAC_T",
    Callback = function(v)
        Settings.TracerESP = v
        if v then TracerModule:Enable() else TracerModule:Disable() end
    end,
})
ToggleRefs.HealthBar = ESPTab:CreateToggle({
    Name = "Health Bar", CurrentValue = false, Flag = "HP_T",
    Callback = function(v)
        Settings.HealthBar = v
        if v then HealthBarModule:Enable() else HealthBarModule:Disable() end
    end,
})

ESPTab:CreateSection("Text")
ToggleRefs.NameESP = ESPTab:CreateToggle({
    Name = "Name ESP", CurrentValue = false, Flag = "NAME_T",
    Callback = function(v)
        Settings.NameESP = v
        if v then NameModule:Enable() else NameModule:Disable() end
    end,
})
ToggleRefs.HealthTextESP = ESPTab:CreateToggle({
    Name = "Health Text ESP", CurrentValue = false, Flag = "HPT_T",
    Callback = function(v)
        Settings.HealthTextESP = v
        if v then HealthTextModule:Enable() else HealthTextModule:Disable() end
    end,
})
ToggleRefs.DistanceESP = ESPTab:CreateToggle({
    Name = "Distance ESP", CurrentValue = false, Flag = "DIST_T",
    Callback = function(v)
        Settings.DistanceESP = v
        if v then DistanceModule:Enable() else DistanceModule:Disable() end
    end,
})

--// ========================
--// AIMBOT TAB
--// ========================
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

-- Main
AimbotTab:CreateSection("Aimbot")
ToggleRefs.Aimbot = AimbotTab:CreateToggle({
    Name = "Enable Aimbot", CurrentValue = false, Flag = "AIM_T",
    Callback = function(v)
        Settings.AimbotEnabled = v
        if v then AimbotModule:Enable() else AimbotModule:Disable() end
    end,
})
AimbotTab:CreateDropdown({
    Name = "Lock Part",
    Options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso","Torso"},
    CurrentOption = {"Head"}, Flag = "AIM_LP",
    Callback = function(v)
        Settings.AimbotLockPart = typeof(v) == "table" and v[1] or v
        AimbotModule:CancelLock()
    end,
})
AimbotTab:CreateSlider({
    Name = "Smoothness", Range = {0,100}, Increment = 5, Suffix = "%",
    CurrentValue = 0, Flag = "AIM_SM",
    Callback = function(v) Settings.AimbotSensitivity = v / 200 end,
})

-- Prediction
AimbotTab:CreateSection("Prediction")
ToggleRefs.Prediction = AimbotTab:CreateToggle({
    Name = "Velocity Prediction", CurrentValue = false, Flag = "AIM_PRED",
    Callback = function(v)
        Settings.AimbotPrediction = v
        PrevPositions = {}
    end,
})
AimbotTab:CreateSlider({
    Name = "Prediction Strength", Range = {1,20}, Increment = 1, Suffix = "x",
    CurrentValue = 5, Flag = "AIM_PRED_STR",
    Callback = function(v)
        Settings.AimbotPredictionStrength = v / 10
    end,
})

-- Hold Key
AimbotTab:CreateSection("Hold Key")
ToggleRefs.HoldKey = AimbotTab:CreateToggle({
    Name = "Hold Key Mode", CurrentValue = false, Flag = "AIM_HK",
    Callback = function(v)
        Settings.AimbotHoldKey = v
        AimbotModule:CancelLock()
    end,
})
AimbotTab:CreateDropdown({
    Name = "Key Bind",
    Options = {"Q","E","R","F","Z","X","C","V","G","H","LeftShift","RightShift","LeftControl","LeftAlt"},
    CurrentOption = {"Q"}, Flag = "AIM_HK_KEY",
    Callback = function(v)
        Settings.AimbotHoldKeyBind = typeof(v) == "table" and v[1] or v
    end,
})

-- Auto Shoot
AimbotTab:CreateSection("Auto Shoot")
ToggleRefs.AutoShoot = AimbotTab:CreateToggle({
    Name = "Auto Shoot", CurrentValue = false, Flag = "AIM_AS",
    Callback = function(v) Settings.AimbotAutoShoot = v end,
})
AimbotTab:CreateSlider({
    Name = "Shoot Delay", Range = {1,20}, Increment = 1, Suffix = "x10ms",
    CurrentValue = 10, Flag = "AIM_AS_DL",
    Callback = function(v) Settings.AimbotAutoShootDelay = v / 100 end,
})

-- Checks
AimbotTab:CreateSection("Checks")
AimbotTab:CreateToggle({
    Name = "Team Check", CurrentValue = false, Flag = "AIM_TC",
    Callback = function(v) Settings.AimbotTeamCheck = v end,
})
AimbotTab:CreateToggle({
    Name = "Alive Check", CurrentValue = true, Flag = "AIM_AC",
    Callback = function(v) Settings.AimbotAliveCheck = v end,
})
AimbotTab:CreateToggle({
    Name = "Wall Check", CurrentValue = false, Flag = "AIM_WC",
    Callback = function(v) Settings.AimbotWallCheck = v end,
})

-- FOV Circle
AimbotTab:CreateSection("FOV Circle")
ToggleRefs.FOV = AimbotTab:CreateToggle({
    Name = "FOV Circle", CurrentValue = true, Flag = "FOV_E",
    Callback = function(v) Settings.FOVEnabled = v end,
})
AimbotTab:CreateToggle({
    Name = "Visible", CurrentValue = true, Flag = "FOV_V",
    Callback = function(v) Settings.FOVVisible = v end,
})
AimbotTab:CreateSlider({
    Name = "Radius", Range = {10,500}, Increment = 5, Suffix = "px",
    CurrentValue = 90, Flag = "FOV_R",
    Callback = function(v) Settings.FOVAmount = v end,
})
AimbotTab:CreateSlider({
    Name = "Thickness", Range = {1,5}, Increment = 1, Suffix = "px",
    CurrentValue = 2, Flag = "FOV_TH",
    Callback = function(v) Settings.FOVThickness = v end,
})

--// ========================
--// SETTINGS TAB (setelah Aimbot)
--// ========================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Box & Corner Box")
SettingsTab:CreateSlider({
    Name = "Corner Length", Range = {2,20}, Increment = 1, Suffix = "px",
    CurrentValue = 6, Flag = "CBOX_LEN",
    Callback = function(v) Settings.CornerBoxLength = v end,
})

SettingsTab:CreateSection("Skeleton")
SettingsTab:CreateSlider({
    Name = "Skeleton Thickness", Range = {1,5}, Increment = 1, Suffix = "px",
    CurrentValue = 2, Flag = "SKEL_TH",
    Callback = function(v) Settings.SkeletonThickness = v end,
})

SettingsTab:CreateSection("Tracer")
SettingsTab:CreateSlider({
    Name = "Tracer Thickness", Range = {1,5}, Increment = 1, Suffix = "px",
    CurrentValue = 1, Flag = "TRAC_TH",
    Callback = function(v) Settings.TracerThickness = v end,
})
SettingsTab:CreateDropdown({
    Name = "Tracer Origin", Options = {"Bottom","Center","Top"},
    CurrentOption = {"Bottom"}, Flag = "TRAC_OR",
    Callback = function(v)
        Settings.TracerOrigin = typeof(v) == "table" and v[1] or v
    end,
})

SettingsTab:CreateSection("Text ESP")
SettingsTab:CreateSlider({
    Name = "Name Size", Range = {8,24}, Increment = 1, Suffix = "px",
    CurrentValue = 10, Flag = "NAME_SZ",
    Callback = function(v) Settings.NameSize = v end,
})
SettingsTab:CreateSlider({
    Name = "HP Text Size", Range = {8,24}, Increment = 1, Suffix = "px",
    CurrentValue = 10, Flag = "HPT_SZ",
    Callback = function(v) Settings.HealthTextSize = v end,
})
SettingsTab:CreateSlider({
    Name = "Distance Size", Range = {8,24}, Increment = 1, Suffix = "px",
    CurrentValue = 10, Flag = "DIST_SZ",
    Callback = function(v) Settings.DistanceSize = v end,
})

--// ========================
--// MISC TAB
--// ========================
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Visual Tweaks")
MiscTab:CreateToggle({
    Name = "Fullbright", CurrentValue = false, Flag = "MISC_FB",
    Callback = function(v)
        Settings.Fullbright = v
        SetFullbright(v)
    end,
})
MiscTab:CreateToggle({
    Name = "No Fog", CurrentValue = false, Flag = "MISC_NF",
    Callback = function(v)
        Settings.NoFog = v
        SetNoFog(v)
    end,
})
MiscTab:CreateToggle({
    Name = "No Shadow", CurrentValue = false, Flag = "MISC_NS",
    Callback = function(v)
        Settings.NoShadow = v
        SetNoShadow(v)
    end,
})

MiscTab:CreateSection("Quick Actions")
MiscTab:CreateButton({
    Name = "Disable All ESP",
    Callback = function()
        Settings.SkeletonESP   = false
        Settings.BoxESP        = false
        Settings.CornerBoxESP  = false
        Settings.TracerESP     = false
        Settings.NameESP       = false
        Settings.HealthTextESP = false
        Settings.DistanceESP   = false
        Settings.HealthBar     = false
        SkeletonModule:Disable()
        BoxModule:Disable()
        CornerBoxModule:Disable()
        TracerModule:Disable()
        NameModule:Disable()
        HealthTextModule:Disable()
        DistanceModule:Disable()
        HealthBarModule:Disable()
        pcall(function() ToggleRefs.SkeletonESP:Set(false) end)
        pcall(function() ToggleRefs.BoxESP:Set(false) end)
        pcall(function() ToggleRefs.CornerBoxESP:Set(false) end)
        pcall(function() ToggleRefs.TracerESP:Set(false) end)
        pcall(function() ToggleRefs.NameESP:Set(false) end)
        pcall(function() ToggleRefs.HealthTextESP:Set(false) end)
        pcall(function() ToggleRefs.DistanceESP:Set(false) end)
        pcall(function() ToggleRefs.HealthBar:Set(false) end)
        Rayfield:Notify({Title = "KreinAim", Content = "All ESP disabled", Duration = 2})
    end,
})

MiscTab:CreateButton({
    Name = "Disable Aimbot",
    Callback = function()
        Settings.AimbotEnabled = false
        AimbotModule:Disable()
        pcall(function() ToggleRefs.Aimbot:Set(false) end)
        Rayfield:Notify({Title = "KreinAim", Content = "Aimbot disabled", Duration = 2})
    end,
})

MiscTab:CreateButton({
    Name = "Restore Lighting",
    Callback = function()
        Settings.Fullbright = false
        Settings.NoFog      = false
        Settings.NoShadow   = false
        SetFullbright(false)
        SetNoFog(false)
        SetNoShadow(false)
        Rayfield:Notify({Title = "KreinAim", Content = "Lighting restored", Duration = 2})
    end,
})

MiscTab:CreateButton({
    Name = "Destroy Script",
    Callback = function()
        SetFullbright(false)
        SetNoFog(false)
        SetNoShadow(false)
        SkeletonModule:Disable()
        BoxModule:Disable()
        CornerBoxModule:Disable()
        TracerModule:Disable()
        NameModule:Disable()
        HealthTextModule:Disable()
        DistanceModule:Disable()
        HealthBarModule:Disable()
        AimbotModule:Disable()
        DestroyFOV()
        SafeDisconnect("rgb")
        for key in pairs(Connections) do SafeDisconnect(key) end
        Rayfield:Destroy()
    end,
})

MiscTab:CreateSection("Info")
MiscTab:CreateParagraph({
    Title = "KreinAim v4",
    Content = "✓ ESP Tab: toggle bersih\n✓ Settings Tab: slider ESP (setelah Aimbot)\n✓ Corner Box ESP (fixed)\n✓ Fullbright | No Fog | No Shadow\n✓ Velocity Prediction | Hold Key | Auto Shoot\n✓ Name / HP / Distance ESP terpisah\n✓ FOV dual render | RGB colors"
})

Rayfield:Notify({Title = "KreinAim", Content = "Loaded! v4", Duration = 3})
