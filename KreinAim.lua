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
    SkeletonESP = false,
    SkeletonThickness = 2,
    BoxESP = false,
    TracerESP = false,
    TracerThickness = 1,
    TracerOrigin = "Bottom",
    NameESP = false,
    NameSize = 14,
    HealthBar = false,
    TeamCheck = false,
    AimbotEnabled = false,
    AimbotLockPart = "Head",
    AimbotSensitivity = 0,
    AimbotTeamCheck = false,
    AimbotAliveCheck = true,
    AimbotWallCheck = false,
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
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = ignoreList
    rayParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction.Unit * (distance - 0.1), rayParams)
    return result ~= nil
end

--// =============================================
--// FOV CIRCLE (Drawing + GUI Fallback)
--// =============================================
local FOVDrawing = nil
local FOVGui = nil
local FOVFrame = nil
local FOVStroke = nil
local UseDrawingFOV = false

-- Try Drawing.new first
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
    UseDrawingFOV = true
end)

-- Always create GUI fallback
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

local function UpdateFOVCircle(visible, radius, thickness, color, locked)
    local centerX, centerY = GetViewportCenter()

    -- Update Drawing circle
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

    -- Update GUI circle
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
--// RGB + FOV updater (always running)
--// =============================================
AimbotModule = {} -- Forward declare
AimbotModule.Locked = nil
AimbotModule.TweenAnim = nil

Connections["rgb"] = RunService.RenderStepped:Connect(function()
    RGBHue = (RGBHue + 0.003) % 1
    RGBColor = Color3.fromHSV(RGBHue, 1, 1)
    Camera = workspace.CurrentCamera

    -- FOV Circle
    if Settings.AimbotEnabled and Settings.FOVEnabled and Settings.FOVVisible then
        local col = RGBColor
        if AimbotModule.Locked then
            col = Color3.fromRGB(255, 50, 50)
        end
        UpdateFOVCircle(true, Settings.FOVAmount, Settings.FOVThickness, col, AimbotModule.Locked)
    else
        UpdateFOVCircle(false, Settings.FOVAmount, Settings.FOVThickness, RGBColor, false)
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
--// NAME ESP
--// =============================================
local NameModule = {}

function NameModule:Enable()
    if Connections["name"] then return end
    Drawings["name"] = {}
    Connections["name"] = {}

    Connections["name"].render = RunService.RenderStepped:Connect(function()
        if not Settings.NameESP then
            for _, d in pairs(Drawings["name"]) do d.text.Visible = false end
            return
        end
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local alive = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsAlive(plr) and IsEnemy(plr, Settings.TeamCheck) then
                alive[plr] = true
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not Drawings["name"][plr] then
                    local d = {}
                    d.text = Drawing.new("Text")
                    d.text.Visible = false
                    d.text.Center = true
                    d.text.Outline = true
                    d.text.OutlineColor = Color3.new(0,0,0)
                    d.text.Size = Settings.NameSize
                    d.text.ZIndex = 5
                    Drawings["name"][plr] = d
                end
                local d = Drawings["name"][plr]
                if head and humanoid and hrp then
                    local screen, onScreen, depth = WorldToScreen(head.Position + Vector3.new(0,2,0))
                    if onScreen and depth > 0 then
                        local dist = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0
                        local hp = math.floor(humanoid.Health)
                        local maxHp = math.floor(humanoid.MaxHealth)
                        d.text.Text = plr.DisplayName .. " [" .. dist .. "m] [" .. hp .. "/" .. maxHp .. " HP]"
                        d.text.Position = screen
                        d.text.Color = RGBColor
                        d.text.Size = Settings.NameSize
                        d.text.Visible = true
                    else
                        d.text.Visible = false
                    end
                else
                    d.text.Visible = false
                end
            end
        end
        for plr, d in pairs(Drawings["name"]) do
            if not alive[plr] then d.text.Visible = false end
        end
    end)

    Connections["name"].removing = Players.PlayerRemoving:Connect(function(plr)
        if Drawings["name"] and Drawings["name"][plr] then
            pcall(function() Drawings["name"][plr].text:Remove() end)
            Drawings["name"][plr] = nil
        end
    end)
end

function NameModule:Disable()
    SafeDisconnect("name")
    if Drawings["name"] then
        for _, d in pairs(Drawings["name"]) do pcall(function() d.text:Remove() end) end
        Drawings["name"] = nil
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
--// AIMBOT MODULE
--// =============================================
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

        local cam = workspace.CurrentCamera
        if not cam then return end

        -- Validate
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
                if Settings.AimbotSensitivity > 0 then
                    if self.TweenAnim then pcall(function() self.TweenAnim:Cancel() end) end
                    self.TweenAnim = TweenService:Create(
                        cam,
                        TweenInfo.new(Settings.AimbotSensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        {CFrame = CFrame.new(cam.CFrame.Position, part.Position)}
                    )
                    self.TweenAnim:Play()
                else
                    cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position)
                end
            end
        end
    end)
end

function AimbotModule:Disable()
    self:CancelLock()
    SafeDisconnect("aimbot")
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

--// ESP TAB
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateSection("General")
ESPTab:CreateToggle({
    Name = "Team Check", CurrentValue = false, Flag = "TC_ESP",
    Callback = function(v) Settings.TeamCheck = v end,
})

ESPTab:CreateSection("Skeleton")
ToggleRefs.SkeletonESP = ESPTab:CreateToggle({
    Name = "Skeleton ESP", CurrentValue = false, Flag = "SKEL_T",
    Callback = function(v)
        Settings.SkeletonESP = v
        if v then SkeletonModule:Enable() else SkeletonModule:Disable() end
    end,
})
ESPTab:CreateSlider({
    Name = "Thickness", Range = {1,5}, Increment = 1, Suffix = "px",
    CurrentValue = 2, Flag = "SKEL_TH",
    Callback = function(v) Settings.SkeletonThickness = v end,
})

ESPTab:CreateSection("Box")
ToggleRefs.BoxESP = ESPTab:CreateToggle({
    Name = "Box ESP", CurrentValue = false, Flag = "BOX_T",
    Callback = function(v)
        Settings.BoxESP = v
        if v then BoxModule:Enable() else BoxModule:Disable() end
    end,
})

ESPTab:CreateSection("Tracer")
ToggleRefs.TracerESP = ESPTab:CreateToggle({
    Name = "Tracer ESP", CurrentValue = false, Flag = "TRAC_T",
    Callback = function(v)
        Settings.TracerESP = v
        if v then TracerModule:Enable() else TracerModule:Disable() end
    end,
})
ESPTab:CreateSlider({
    Name = "Thickness", Range = {1,5}, Increment = 1, Suffix = "px",
    CurrentValue = 1, Flag = "TRAC_TH",
    Callback = function(v) Settings.TracerThickness = v end,
})
ESPTab:CreateDropdown({
    Name = "Origin", Options = {"Bottom","Center","Top"},
    CurrentOption = {"Bottom"}, Flag = "TRAC_OR",
    Callback = function(v)
        if typeof(v) == "table" then Settings.TracerOrigin = v[1] else Settings.TracerOrigin = v end
    end,
})

ESPTab:CreateSection("Name + HP")
ToggleRefs.NameESP = ESPTab:CreateToggle({
    Name = "Name + Distance + HP", CurrentValue = false, Flag = "NAME_T",
    Callback = function(v)
        Settings.NameESP = v
        if v then NameModule:Enable() else NameModule:Disable() end
    end,
})
ESPTab:CreateSlider({
    Name = "Text Size", Range = {8,24}, Increment = 1, Suffix = "px",
    CurrentValue = 14, Flag = "NAME_SZ",
    Callback = function(v) Settings.NameSize = v end,
})

ESPTab:CreateSection("Health Bar")
ToggleRefs.HealthBar = ESPTab:CreateToggle({
    Name = "Health Bar", CurrentValue = false, Flag = "HP_T",
    Callback = function(v)
        Settings.HealthBar = v
        if v then HealthBarModule:Enable() else HealthBarModule:Disable() end
    end,
})

--// AIMBOT TAB
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

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
        if typeof(v) == "table" then Settings.AimbotLockPart = v[1] else Settings.AimbotLockPart = v end
        AimbotModule:CancelLock()
    end,
})
AimbotTab:CreateSlider({
    Name = "Smoothness", Range = {0,100}, Increment = 5, Suffix = "%",
    CurrentValue = 0, Flag = "AIM_SM",
    Callback = function(v) Settings.AimbotSensitivity = v / 100 end,
})

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

--// MISC TAB
local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateSection("Quick Actions")

MiscTab:CreateButton({
    Name = "Disable All ESP",
    Callback = function()
        Settings.SkeletonESP = false
        Settings.BoxESP = false
        Settings.TracerESP = false
        Settings.NameESP = false
        Settings.HealthBar = false
        SkeletonModule:Disable()
        BoxModule:Disable()
        TracerModule:Disable()
        NameModule:Disable()
        HealthBarModule:Disable()
        pcall(function() ToggleRefs.SkeletonESP:Set(false) end)
        pcall(function() ToggleRefs.BoxESP:Set(false) end)
        pcall(function() ToggleRefs.TracerESP:Set(false) end)
        pcall(function() ToggleRefs.NameESP:Set(false) end)
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
    Name = "Destroy Script",
    Callback = function()
        Settings.SkeletonESP = false
        Settings.BoxESP = false
        Settings.TracerESP = false
        Settings.NameESP = false
        Settings.HealthBar = false
        Settings.AimbotEnabled = false
        SkeletonModule:Disable()
        BoxModule:Disable()
        TracerModule:Disable()
        NameModule:Disable()
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
    Title = "KreinAim",
    Content = "RGB colors | Auto Aimbot\nFOV = outline circle (center screen)\nDual FOV: Drawing + GUI fallback\nWall Check = Raycast\nMobile & PC supported"
})

Rayfield:Notify({Title = "KreinAim", Content = "Loaded!", Duration = 3})
