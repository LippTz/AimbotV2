--// ============================================================
--// KreinAim v6 - KreinGui Edition
--// by @uniquadev
--// ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local KreinGui = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/LippTz/KreinGuiLibrary/refs/heads/main/KreinGui.lua"
))()

local Connections = {}
local Drawings    = {}
local RGBColor    = Color3.fromRGB(255,0,0)
local RGBHue      = 0

local Settings = {
    SkeletonESP=false,SkeletonThickness=2,BoxESP=false,CornerBoxESP=false,CornerBoxLength=6,
    TracerESP=false,TracerThickness=1,TracerOrigin="Bottom",NameESP=false,NameSize=10,
    HealthTextESP=false,HealthTextSize=10,DistanceESP=false,DistanceSize=10,HealthBar=false,TeamCheck=false,
    AimbotEnabled=false,AimbotLockPart="Head",AimbotSensitivity=0,AimbotTeamCheck=false,
    AimbotAliveCheck=true,AimbotWallCheck=false,AimbotPrediction=false,AimbotPredictionStrength=1.0,
    AimbotHoldKey=false,AimbotHoldKeyBind="Q",AimbotAutoShoot=false,AimbotAutoShootDelay=0.1,
    LookDirectionESP=false,LookDirectionLength=40,LookDirectionThickness=1.5,LookDirectionShowAngle=false,
    ChamsEnabled=false,ChamsFillColor=Color3.fromRGB(255,50,50),ChamsOutlineColor=Color3.fromRGB(255,255,255),
    ChamsFillTransparency=0.5,ChamsOutlineTransparency=0,ChamsWallCheck=false,
    RadarEnabled=false,RadarSize=180,RadarRange=150,RadarX=10,RadarY=150,
    Fullbright=false,NoFog=false,NoShadow=false,
    FOVEnabled=true,FOVVisible=true,FOVAmount=90,FOVThickness=2,FOVSides=60,
}

-- UTILITY
local function SafeDisconnect(key)
    if not Connections[key] then return end
    if typeof(Connections[key])=="table" then for _,c in pairs(Connections[key]) do if typeof(c)=="RBXScriptConnection" then pcall(function() c:Disconnect() end) end end
    elseif typeof(Connections[key])=="RBXScriptConnection" then pcall(function() Connections[key]:Disconnect() end) end
    Connections[key]=nil
end
local function IsAlive(p) if not p or not p.Parent then return false end; local c=p.Character; if not c then return false end; local h=c:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then return false end; return c:FindFirstChild("HumanoidRootPart")~=nil end
local function IsEnemy(p,tc) if not tc then return true end; if not p.Team or not LocalPlayer.Team then return true end; return p.Team~=LocalPlayer.Team end
local function W2S(pos) local cam=workspace.CurrentCamera; if not cam then return Vector2.new(0,0),false,0 end; local v,on=cam:WorldToViewportPoint(pos); return Vector2.new(v.X,v.Y),on,v.Z end
local function Center() local cam=workspace.CurrentCamera; if cam then return cam.ViewportSize.X/2,cam.ViewportSize.Y/2 end; return 0,0 end
local function WallBetween(o,t,ig) local d=t-o; local m=d.Magnitude; if m<=0 then return false end; local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances=ig; rp.IgnoreWater=true; return workspace:Raycast(o,d.Unit*(m-0.1),rp)~=nil end

-- VELOCITY PREDICTION
local PrevPos={}
local function PredictPos(plr,part) if not Settings.AimbotPrediction then return part.Position end; local now=tick(); local key=tostring(plr.UserId); local prev=PrevPos[key]; if prev then local dt=now-prev.time; if dt>0 and dt<0.2 then local vel=(part.Position-prev.pos)/dt; PrevPos[key]={pos=part.Position,time=now}; return part.Position+vel*Settings.AimbotPredictionStrength end end; PrevPos[key]={pos=part.Position,time=now}; return part.Position end
Players.PlayerRemoving:Connect(function(p) PrevPos[tostring(p.UserId)]=nil end)

-- FOV CIRCLE
local FOVD,FOVG,FOVF,FOVS=nil,nil,nil,nil
pcall(function() FOVD=Drawing.new("Circle");FOVD.Visible=false;FOVD.Filled=false;FOVD.Thickness=2;FOVD.NumSides=60;FOVD.Radius=90;FOVD.Color=Color3.fromRGB(255,255,255);FOVD.Transparency=1;FOVD.Position=Vector2.new(0,0) end)
pcall(function() local pg=LocalPlayer:WaitForChild("PlayerGui"); FOVG=Instance.new("ScreenGui");FOVG.Name="KreinAimFOV";FOVG.ResetOnSpawn=false;FOVG.IgnoreGuiInset=true;FOVG.DisplayOrder=999;FOVG.Parent=pg; FOVF=Instance.new("Frame");FOVF.BackgroundTransparency=1;FOVF.BorderSizePixel=0;FOVF.AnchorPoint=Vector2.new(0.5,0.5);FOVF.Parent=FOVG; Instance.new("UICorner",FOVF).CornerRadius=UDim.new(0.5,0); FOVS=Instance.new("UIStroke");FOVS.Thickness=2;FOVS.Color=Color3.fromRGB(255,255,255);FOVS.Transparency=0;FOVS.Parent=FOVF end)
local function UpdFOV(vis,r,th,col) local cx,cy=Center(); if FOVD then pcall(function() FOVD.Position=Vector2.new(cx,cy);FOVD.Radius=r;FOVD.Thickness=th;FOVD.NumSides=Settings.FOVSides;FOVD.Filled=false;FOVD.Transparency=1;FOVD.Color=col;FOVD.Visible=vis end) end; if FOVF and FOVS then pcall(function() local d=r*2;FOVF.Size=UDim2.fromOffset(d,d);FOVF.Position=UDim2.fromOffset(cx,cy);FOVF.Visible=vis;FOVS.Thickness=th;FOVS.Color=col;FOVS.Transparency=vis and 0 or 1 end) end end
local function DestroyFOV() if FOVD then pcall(function() FOVD:Remove() end);FOVD=nil end; if FOVG then pcall(function() FOVG:Destroy() end);FOVG=nil;FOVF=nil;FOVS=nil end end

-- AIMBOT MODULE (early declaration for rgb loop)
local AimbotModule={Locked=nil,TweenAnim=nil}
Connections["rgb"]=RunService.RenderStepped:Connect(function()
    RGBHue=(RGBHue+0.003)%1;RGBColor=Color3.fromHSV(RGBHue,1,1);Camera=workspace.CurrentCamera
    if Settings.AimbotEnabled and Settings.FOVEnabled and Settings.FOVVisible then UpdFOV(true,Settings.FOVAmount,Settings.FOVThickness,AimbotModule.Locked and Color3.fromRGB(255,50,50) or RGBColor)
    else UpdFOV(false,Settings.FOVAmount,Settings.FOVThickness,RGBColor) end
end)

-- SKELETON ESP
local SkeletonModule={}
function SkeletonModule:GetBones(c,h) local j,b={},{}; if h.RigType==Enum.HumanoidRigType.R15 then for _,n in ipairs({"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do j[n]=c:FindFirstChild(n) end; b={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}} else for _,n in ipairs({"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}) do j[n]=c:FindFirstChild(n) end; b={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}} end; return j,b end
function SkeletonModule:Enable()
    if Connections["sk"] then return end; Drawings["sk"]={};Connections["sk"]={}
    Connections["sk"].r=RunService.RenderStepped:Connect(function()
        if not Settings.SkeletonESP then for _,ls in pairs(Drawings["sk"]) do for _,l in pairs(ls) do l.Visible=false end end;return end
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local h=c:FindFirstChildOfClass("Humanoid"); local j,b=self:GetBones(c,h); if not Drawings["sk"][p] then Drawings["sk"][p]={} for i=1,#b do local l=Drawing.new("Line");l.Visible=false;Drawings["sk"][p][i]=l end end; local ls=Drawings["sk"][p]; while #ls<#b do ls[#ls+1]=Drawing.new("Line");ls[#ls].Visible=false end; while #ls>#b do ls[#ls]:Remove();ls[#ls]=nil end; for i,bn in ipairs(b) do local a,bb=j[bn[1]],j[bn[2]]; local l=ls[i]; if a and bb then local pA,onA=W2S(a.Position);local pB,onB=W2S(bb.Position); if onA and onB then l.From=pA;l.To=pB;l.Color=RGBColor;l.Thickness=Settings.SkeletonThickness;l.Visible=true else l.Visible=false end else l.Visible=false end end end end
        for p,ls in pairs(Drawings["sk"]) do if not av[p] then for _,l in pairs(ls) do l.Visible=false end end end
    end)
    Connections["sk"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["sk"] and Drawings["sk"][p] then for _,l in pairs(Drawings["sk"][p]) do pcall(function() l:Remove() end) end;Drawings["sk"][p]=nil end end)
end
function SkeletonModule:Disable() SafeDisconnect("sk"); if Drawings["sk"] then for _,ls in pairs(Drawings["sk"]) do for _,l in pairs(ls) do pcall(function() l:Remove() end) end end;Drawings["sk"]=nil end end

-- BOX ESP
local BoxModule={}
function BoxModule:Enable()
    if Connections["bx"] then return end; Drawings["bx"]={};Connections["bx"]={}
    Connections["bx"].r=RunService.RenderStepped:Connect(function()
        if not Settings.BoxESP then for _,d in pairs(Drawings["bx"]) do d.box.Visible=false;d.out.Visible=false end;return end
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hrp=c:FindFirstChild("HumanoidRootPart"); local hd=c:FindFirstChild("Head"); if not Drawings["bx"][p] then local d={}; d.box=Drawing.new("Square");d.box.Thickness=1;d.box.Filled=false;d.box.Visible=false;d.box.ZIndex=2; d.out=Drawing.new("Square");d.out.Thickness=3;d.out.Filled=false;d.out.Color=Color3.new(0,0,0);d.out.Visible=false;d.out.ZIndex=1; Drawings["bx"][p]=d end; local d=Drawings["bx"][p]; if hrp and hd then local top,ton,tz=W2S(hd.Position+Vector3.new(0,1,0)); local bot,bon,bz=W2S(hrp.Position-Vector3.new(0,3,0)); if ton and bon and tz>0 and bz>0 then local h=math.abs(bot.Y-top.Y);local w=h/1.8;local bx=math.floor(top.X-w/2);local by=math.floor(top.Y); d.box.Size=Vector2.new(math.floor(w),math.floor(h));d.box.Position=Vector2.new(bx,by);d.box.Color=RGBColor;d.box.Visible=true; d.out.Size=Vector2.new(math.floor(w)+2,math.floor(h)+2);d.out.Position=Vector2.new(bx-1,by-1);d.out.Visible=true else d.box.Visible=false;d.out.Visible=false end else d.box.Visible=false;d.out.Visible=false end end end
        for p,d in pairs(Drawings["bx"]) do if not av[p] then d.box.Visible=false;d.out.Visible=false end end
    end)
    Connections["bx"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["bx"] and Drawings["bx"][p] then pcall(function() Drawings["bx"][p].box:Remove() end);pcall(function() Drawings["bx"][p].out:Remove() end);Drawings["bx"][p]=nil end end)
end
function BoxModule:Disable() SafeDisconnect("bx"); if Drawings["bx"] then for _,d in pairs(Drawings["bx"]) do pcall(function() d.box:Remove() end);pcall(function() d.out:Remove() end) end;Drawings["bx"]=nil end end

-- CORNER BOX
local CornerBoxModule={}
local function MkCL() local ls={} for i=1,8 do local l=Drawing.new("Line");l.Visible=false;l.Thickness=1;ls[i]=l end;return ls end
function CornerBoxModule:Enable()
    if Connections["cb"] then return end; Drawings["cb"]={};Connections["cb"]={}
    Connections["cb"].r=RunService.RenderStepped:Connect(function()
        if not Settings.CornerBoxESP then for _,ls in pairs(Drawings["cb"]) do for _,l in ipairs(ls) do l.Visible=false end end;return end
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hrp=c:FindFirstChild("HumanoidRootPart"); local hd=c:FindFirstChild("Head"); if not Drawings["cb"][p] then Drawings["cb"][p]=MkCL() end; local L=Drawings["cb"][p]; if hrp and hd then local top,ton,tz=W2S(hd.Position+Vector3.new(0,1,0)); local bot,bon,bz=W2S(hrp.Position-Vector3.new(0,3,0)); if ton and bon and tz>0 and bz>0 then local h=math.abs(bot.Y-top.Y);local w=h/1.8; if h<4 or w<4 then for _,l in ipairs(L) do l.Visible=false end else local len=math.clamp(Settings.CornerBoxLength,2,math.floor(math.min(w,h)/2)); local x0=math.floor(top.X-w/2);local y0=math.floor(top.Y);local x1=x0+math.floor(w);local y1=y0+math.floor(h); L[1].From=Vector2.new(x0,y0);L[1].To=Vector2.new(x0+len,y0);L[2].From=Vector2.new(x0,y0);L[2].To=Vector2.new(x0,y0+len);L[3].From=Vector2.new(x1,y0);L[3].To=Vector2.new(x1-len,y0);L[4].From=Vector2.new(x1,y0);L[4].To=Vector2.new(x1,y0+len);L[5].From=Vector2.new(x0,y1);L[5].To=Vector2.new(x0+len,y1);L[6].From=Vector2.new(x0,y1);L[6].To=Vector2.new(x0,y1-len);L[7].From=Vector2.new(x1,y1);L[7].To=Vector2.new(x1-len,y1);L[8].From=Vector2.new(x1,y1);L[8].To=Vector2.new(x1,y1-len); for _,l in ipairs(L) do l.Color=RGBColor;l.Thickness=1;l.Visible=true end end else for _,l in ipairs(L) do l.Visible=false end end else for _,l in ipairs(L) do l.Visible=false end end end end
        for p,ls in pairs(Drawings["cb"]) do if not av[p] then for _,l in ipairs(ls) do l.Visible=false end end end
    end)
    Connections["cb"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["cb"] and Drawings["cb"][p] then for _,l in ipairs(Drawings["cb"][p]) do pcall(function() l:Remove() end) end;Drawings["cb"][p]=nil end end)
end
function CornerBoxModule:Disable() SafeDisconnect("cb"); if Drawings["cb"] then for _,ls in pairs(Drawings["cb"]) do for _,l in ipairs(ls) do pcall(function() l:Remove() end) end end;Drawings["cb"]=nil end end

-- TRACER
local TracerModule={}
function TracerModule:Enable()
    if Connections["tr"] then return end; Drawings["tr"]={};Connections["tr"]={}
    Connections["tr"].r=RunService.RenderStepped:Connect(function()
        if not Settings.TracerESP then for _,l in pairs(Drawings["tr"]) do l.Visible=false end;return end
        local vp=Camera.ViewportSize; local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hrp=c:FindFirstChild("HumanoidRootPart"); if not Drawings["tr"][p] then local l=Drawing.new("Line");l.Visible=false;l.Transparency=1;Drawings["tr"][p]=l end; local l=Drawings["tr"][p]; if hrp then local sc,on,d=W2S(hrp.Position); if on and d>0 then local fy=vp.Y; if Settings.TracerOrigin=="Top" then fy=0 elseif Settings.TracerOrigin=="Center" then fy=vp.Y/2 end; l.From=Vector2.new(vp.X/2,fy);l.To=sc;l.Color=RGBColor;l.Thickness=Settings.TracerThickness;l.Visible=true else l.Visible=false end else l.Visible=false end end end
        for p,l in pairs(Drawings["tr"]) do if not av[p] then l.Visible=false end end
    end)
    Connections["tr"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["tr"] and Drawings["tr"][p] then pcall(function() Drawings["tr"][p]:Remove() end);Drawings["tr"][p]=nil end end)
end
function TracerModule:Disable() SafeDisconnect("tr"); if Drawings["tr"] then for _,l in pairs(Drawings["tr"]) do pcall(function() l:Remove() end) end;Drawings["tr"]=nil end end

-- NAME ESP
local NameModule={}
function NameModule:Enable()
    if Connections["nm"] then return end; Drawings["nm"]={};Connections["nm"]={}
    Connections["nm"].r=RunService.RenderStepped:Connect(function()
        if not Settings.NameESP then for _,t in pairs(Drawings["nm"]) do t.Visible=false end;return end
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hd=c:FindFirstChild("Head"); if not Drawings["nm"][p] then local t=Drawing.new("Text");t.Visible=false;t.Center=true;t.Outline=true;t.OutlineColor=Color3.new(0,0,0);t.ZIndex=5;Drawings["nm"][p]=t end; local t=Drawings["nm"][p]; if hd then local sc,on,d=W2S(hd.Position+Vector3.new(0,2.4,0)); if on and d>0 then t.Text=p.DisplayName;t.Position=sc;t.Color=RGBColor;t.Size=Settings.NameSize;t.Visible=true else t.Visible=false end else t.Visible=false end end end
        for p,t in pairs(Drawings["nm"]) do if not av[p] then t.Visible=false end end
    end)
    Connections["nm"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["nm"] and Drawings["nm"][p] then pcall(function() Drawings["nm"][p]:Remove() end);Drawings["nm"][p]=nil end end)
end
function NameModule:Disable() SafeDisconnect("nm"); if Drawings["nm"] then for _,t in pairs(Drawings["nm"]) do pcall(function() t:Remove() end) end;Drawings["nm"]=nil end end

-- HP TEXT ESP
local HealthTextModule={}
function HealthTextModule:Enable()
    if Connections["ht"] then return end; Drawings["ht"]={};Connections["ht"]={}
    Connections["ht"].r=RunService.RenderStepped:Connect(function()
        if not Settings.HealthTextESP then for _,t in pairs(Drawings["ht"]) do t.Visible=false end;return end
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hd=c:FindFirstChild("Head"); local h=c:FindFirstChildOfClass("Humanoid"); if not Drawings["ht"][p] then local t=Drawing.new("Text");t.Visible=false;t.Center=true;t.Outline=true;t.OutlineColor=Color3.new(0,0,0);t.ZIndex=5;Drawings["ht"][p]=t end; local t=Drawings["ht"][p]; if hd and h then local sc,on,d=W2S(hd.Position+Vector3.new(0,2.4,0)); if on and d>0 then local pct=math.clamp(h.Health/h.MaxHealth,0,1); t.Text="["..math.floor(h.Health).."/"..math.floor(h.MaxHealth).." HP]"; t.Position=Vector2.new(sc.X,sc.Y+Settings.HealthTextSize+2); t.Color=Color3.fromRGB(255*(1-pct),255*pct,0); t.Size=Settings.HealthTextSize; t.Visible=true else t.Visible=false end else t.Visible=false end end end
        for p,t in pairs(Drawings["ht"]) do if not av[p] then t.Visible=false end end
    end)
    Connections["ht"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["ht"] and Drawings["ht"][p] then pcall(function() Drawings["ht"][p]:Remove() end);Drawings["ht"][p]=nil end end)
end
function HealthTextModule:Disable() SafeDisconnect("ht"); if Drawings["ht"] then for _,t in pairs(Drawings["ht"]) do pcall(function() t:Remove() end) end;Drawings["ht"]=nil end end

-- DISTANCE ESP
local DistanceModule={}
function DistanceModule:Enable()
    if Connections["dt"] then return end; Drawings["dt"]={};Connections["dt"]={}
    Connections["dt"].r=RunService.RenderStepped:Connect(function()
        if not Settings.DistanceESP then for _,t in pairs(Drawings["dt"]) do t.Visible=false end;return end
        local mhrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hd=c:FindFirstChild("Head"); local hrp=c:FindFirstChild("HumanoidRootPart"); if not Drawings["dt"][p] then local t=Drawing.new("Text");t.Visible=false;t.Center=true;t.Outline=true;t.OutlineColor=Color3.new(0,0,0);t.ZIndex=5;Drawings["dt"][p]=t end; local t=Drawings["dt"][p]; if hd and hrp then local sc,on,d=W2S(hd.Position+Vector3.new(0,2.4,0)); if on and d>0 then local dist=mhrp and math.floor((mhrp.Position-hrp.Position).Magnitude) or 0; local off=Settings.HealthTextESP and (Settings.HealthTextSize*2+4) or (Settings.NameESP and Settings.NameSize+2 or 0); t.Text="["..dist.."m]"; t.Position=Vector2.new(sc.X,sc.Y+Settings.DistanceSize+off); t.Color=Color3.fromRGB(180,220,255); t.Size=Settings.DistanceSize; t.Visible=true else t.Visible=false end else t.Visible=false end end end
        for p,t in pairs(Drawings["dt"]) do if not av[p] then t.Visible=false end end
    end)
    Connections["dt"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["dt"] and Drawings["dt"][p] then pcall(function() Drawings["dt"][p]:Remove() end);Drawings["dt"][p]=nil end end)
end
function DistanceModule:Disable() SafeDisconnect("dt"); if Drawings["dt"] then for _,t in pairs(Drawings["dt"]) do pcall(function() t:Remove() end) end;Drawings["dt"]=nil end end

-- HEALTH BAR
local HealthBarModule={}
function HealthBarModule:Enable()
    if Connections["hb"] then return end; Drawings["hb"]={};Connections["hb"]={}
    Connections["hb"].r=RunService.RenderStepped:Connect(function()
        if not Settings.HealthBar then for _,d in pairs(Drawings["hb"]) do d.o.Visible=false;d.bg.Visible=false;d.bar.Visible=false end;return end
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hrp=c:FindFirstChild("HumanoidRootPart"); local hd=c:FindFirstChild("Head"); local h=c:FindFirstChildOfClass("Humanoid"); if not Drawings["hb"][p] then local d={}; d.o=Drawing.new("Square");d.o.Filled=true;d.o.Color=Color3.new(0,0,0);d.o.Visible=false;d.o.ZIndex=1; d.bg=Drawing.new("Square");d.bg.Filled=true;d.bg.Color=Color3.fromRGB(40,40,40);d.bg.Visible=false;d.bg.ZIndex=2; d.bar=Drawing.new("Square");d.bar.Filled=true;d.bar.Visible=false;d.bar.ZIndex=3; Drawings["hb"][p]=d end; local d=Drawings["hb"][p]; if hrp and hd and h then local top,ton,tz=W2S(hd.Position+Vector3.new(0,1,0)); local bot,bon,bz=W2S(hrp.Position-Vector3.new(0,3,0)); if ton and bon and tz>0 and bz>0 then local bH2=math.abs(bot.Y-top.Y);local bW2=bH2/1.8;local bW=4;local bX=math.floor(top.X-bW2/2-bW-4);local bY=math.floor(top.Y); local pct=math.clamp(h.Health/h.MaxHealth,0,1);local fH=math.max(math.floor(bH2*pct),1);local col=Color3.fromRGB(255*(1-pct),255*pct,0); d.o.Size=Vector2.new(bW+2,math.floor(bH2)+2);d.o.Position=Vector2.new(bX-1,bY-1);d.o.Visible=true; d.bg.Size=Vector2.new(bW,math.floor(bH2));d.bg.Position=Vector2.new(bX,bY);d.bg.Visible=true; d.bar.Size=Vector2.new(bW,fH);d.bar.Position=Vector2.new(bX,bY+math.floor(bH2)-fH);d.bar.Color=col;d.bar.Visible=true else d.o.Visible=false;d.bg.Visible=false;d.bar.Visible=false end else d.o.Visible=false;d.bg.Visible=false;d.bar.Visible=false end end end
        for p,d in pairs(Drawings["hb"]) do if not av[p] then d.o.Visible=false;d.bg.Visible=false;d.bar.Visible=false end end
    end)
    Connections["hb"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["hb"] and Drawings["hb"][p] then pcall(function() Drawings["hb"][p].o:Remove() end);pcall(function() Drawings["hb"][p].bg:Remove() end);pcall(function() Drawings["hb"][p].bar:Remove() end);Drawings["hb"][p]=nil end end)
end
function HealthBarModule:Disable() SafeDisconnect("hb"); if Drawings["hb"] then for _,d in pairs(Drawings["hb"]) do pcall(function() d.o:Remove() end);pcall(function() d.bg:Remove() end);pcall(function() d.bar:Remove() end) end;Drawings["hb"]=nil end end

-- LOOK DIRECTION ESP
local LookDirectionModule={}
local function GetLookDot(eHRP,mHRP) if not eHRP or not mHRP then return 0 end; local toMe=(mHRP.Position-eHRP.Position); local len=toMe.Magnitude; if len<0.001 then return 0 end; toMe=toMe/len; local lv=eHRP.CFrame.LookVector; return lv.X*toMe.X+lv.Z*toMe.Z end
local function DotToCol(dot) if dot>0.6 then return Color3.fromRGB(255,50,50) elseif dot>0.1 then local t=(dot-0.1)/0.5; return Color3.fromRGB(255,math.floor(255*(1-t)),50) else return Color3.fromRGB(80,220,80) end end
function LookDirectionModule:Enable()
    if Connections["ld"] then return end; Drawings["ld"]={};Connections["ld"]={}
    Connections["ld"].r=RunService.RenderStepped:Connect(function()
        if not Settings.LookDirectionESP then for _,d in pairs(Drawings["ld"]) do d.line.Visible=false;d.tip1.Visible=false;d.tip2.Visible=false;if d.label then d.label.Visible=false end end;return end
        local myC=LocalPlayer.Character; local myHRP=myC and myC:FindFirstChild("HumanoidRootPart"); local av={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then
                av[p]=true; local c=p.Character; local hd=c:FindFirstChild("Head"); local hrp=c:FindFirstChild("HumanoidRootPart"); if not hd or not hrp then continue end
                if not Drawings["ld"][p] then local d={}; d.line=Drawing.new("Line");d.line.Visible=false;d.line.Transparency=1;d.line.ZIndex=6; d.tip1=Drawing.new("Line");d.tip1.Visible=false;d.tip1.Transparency=1;d.tip1.ZIndex=6; d.tip2=Drawing.new("Line");d.tip2.Visible=false;d.tip2.Transparency=1;d.tip2.ZIndex=6; d.label=Drawing.new("Text");d.label.Visible=false;d.label.Center=false;d.label.Outline=true;d.label.OutlineColor=Color3.new(0,0,0);d.label.Size=10;d.label.ZIndex=7; Drawings["ld"][p]=d end
                local d=Drawings["ld"][p]; local headPos=hd.Position+Vector3.new(0,0.8,0); local orig,onS,dep=W2S(headPos)
                if not onS or dep<=0 then d.line.Visible=false;d.tip1.Visible=false;d.tip2.Visible=false;d.label.Visible=false;continue end
                local distE=myHRP and (myHRP.Position-hrp.Position).Magnitude or 10; local ws=math.max(2,distE*0.08); local lv=hrp.CFrame.LookVector; local tipW=headPos+lv*ws; local tipS,tipOn=W2S(tipW)
                if not tipOn then local dir=tipS-orig; local len=dir.Magnitude; if len>0.1 then tipS=orig+(dir/len)*Settings.LookDirectionLength end else local dir=tipS-orig; local len=dir.Magnitude; local mx=Settings.LookDirectionLength; if len>mx then tipS=orig+(dir/len)*mx end; if len<8 then tipS=len<0.1 and orig+Vector2.new(0,-mx) or orig+(dir/len)*8 end end
                local dot=GetLookDot(hrp,myHRP); local col=DotToCol(dot)
                d.line.From=orig;d.line.To=tipS;d.line.Color=col;d.line.Thickness=Settings.LookDirectionThickness;d.line.Visible=true
                local dir2=tipS-orig; local dl=dir2.Magnitude
                if dl>2 then local nd=dir2/dl; local pd=Vector2.new(-nd.Y,nd.X); local as=math.clamp(Settings.LookDirectionLength*0.28,5,12); local wb=tipS-nd*as; d.tip1.From=tipS;d.tip1.To=wb+pd*as*0.6;d.tip1.Color=col;d.tip1.Thickness=Settings.LookDirectionThickness;d.tip1.Visible=true; d.tip2.From=tipS;d.tip2.To=wb-pd*as*0.6;d.tip2.Color=col;d.tip2.Thickness=Settings.LookDirectionThickness;d.tip2.Visible=true else d.tip1.Visible=false;d.tip2.Visible=false end
                if Settings.LookDirectionShowAngle then local ang=math.floor(math.acos(math.clamp(dot,-1,1))*(180/math.pi)); d.label.Text=ang.."°"; d.label.Position=tipS+Vector2.new(4,-6); d.label.Color=col; d.label.Visible=true else d.label.Visible=false end
            end
        end
        for p,d in pairs(Drawings["ld"]) do if not av[p] then d.line.Visible=false;d.tip1.Visible=false;d.tip2.Visible=false;d.label.Visible=false end end
    end)
    Connections["ld"].rm=Players.PlayerRemoving:Connect(function(p) if Drawings["ld"] and Drawings["ld"][p] then pcall(function() Drawings["ld"][p].line:Remove() end);pcall(function() Drawings["ld"][p].tip1:Remove() end);pcall(function() Drawings["ld"][p].tip2:Remove() end);pcall(function() Drawings["ld"][p].label:Remove() end);Drawings["ld"][p]=nil end end)
end
function LookDirectionModule:Disable() SafeDisconnect("ld"); if Drawings["ld"] then for _,d in pairs(Drawings["ld"]) do pcall(function() d.line:Remove() end);pcall(function() d.tip1:Remove() end);pcall(function() d.tip2:Remove() end);pcall(function() d.label:Remove() end) end;Drawings["ld"]=nil end end

-- CHAMS
local ChamsModule={}
local ChamsHL={}
function ChamsModule:Apply(plr) if ChamsHL[plr] then return end; local c=plr.Character; if not c then return end; local hl=Instance.new("Highlight"); hl.Name="KreinChams"; hl.FillColor=Settings.ChamsFillColor; hl.OutlineColor=Settings.ChamsOutlineColor; hl.FillTransparency=Settings.ChamsFillTransparency; hl.OutlineTransparency=Settings.ChamsOutlineTransparency; hl.DepthMode=Settings.ChamsWallCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=c; hl.Parent=c; ChamsHL[plr]=hl end
function ChamsModule:Remove(plr) if ChamsHL[plr] then pcall(function() ChamsHL[plr]:Destroy() end);ChamsHL[plr]=nil end end
function ChamsModule:UpdateAll() for _,hl in pairs(ChamsHL) do pcall(function() hl.FillColor=Settings.ChamsFillColor;hl.OutlineColor=Settings.ChamsOutlineColor;hl.FillTransparency=Settings.ChamsFillTransparency;hl.OutlineTransparency=Settings.ChamsOutlineTransparency;hl.DepthMode=Settings.ChamsWallCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop end) end end
function ChamsModule:Enable()
    if Connections["ch"] then return end; Connections["ch"]={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then self:Apply(p) end end
    Connections["ch"].r=RunService.RenderStepped:Connect(function()
        if not Settings.ChamsEnabled then for p in pairs(ChamsHL) do self:Remove(p) end;return end
        local ac={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then ac[p]=true; if not ChamsHL[p] then self:Apply(p) end; local hl=ChamsHL[p]; if hl and hl.Adornee~=p.Character then hl.Adornee=p.Character;hl.Parent=p.Character end end end
        for p in pairs(ChamsHL) do if not ac[p] then self:Remove(p) end end
    end)
    Connections["ch"].rm=Players.PlayerRemoving:Connect(function(p) self:Remove(p) end)
    Connections["ch"].ca={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then Connections["ch"].ca[p]=p.CharacterAdded:Connect(function() task.wait(0.5); if Settings.ChamsEnabled and IsEnemy(p,Settings.TeamCheck) then self:Remove(p);self:Apply(p) end end) end end
    Connections["ch"].pa=Players.PlayerAdded:Connect(function(p) if p==LocalPlayer then return end; Connections["ch"].ca[p]=p.CharacterAdded:Connect(function() task.wait(0.5); if Settings.ChamsEnabled and IsEnemy(p,Settings.TeamCheck) then self:Remove(p);self:Apply(p) end end) end)
end
function ChamsModule:Disable() for p in pairs(ChamsHL) do self:Remove(p) end; if Connections["ch"] and Connections["ch"].ca then for _,c in pairs(Connections["ch"].ca) do pcall(function() c:Disconnect() end) end end; SafeDisconnect("ch") end

-- RADAR 2D
local RadarModule={}
local RadarGui,RadarBg,RadarDots,RadarLines=nil,nil,{},{}
local function MkDot(col,sz) local d=Instance.new("Frame");d.Size=UDim2.fromOffset(sz,sz);d.AnchorPoint=Vector2.new(0.5,0.5);d.BackgroundColor3=col;d.BorderSizePixel=0;d.ZIndex=12;Instance.new("UICorner",d).CornerRadius=UDim.new(1,0);local s=Instance.new("UIStroke",d);s.Thickness=1;s.Color=Color3.new(0,0,0);s.Transparency=0.3;return d end
function RadarModule:Build()
    if RadarGui then return end; local pg=LocalPlayer:WaitForChild("PlayerGui")
    RadarGui=Instance.new("ScreenGui");RadarGui.Name="KreinRadar";RadarGui.ResetOnSpawn=false;RadarGui.IgnoreGuiInset=true;RadarGui.DisplayOrder=998;RadarGui.Parent=pg
    local S=Settings.RadarSize; local wrap=Instance.new("Frame");wrap.Size=UDim2.fromOffset(S+24,S+24);wrap.Position=UDim2.fromOffset(Settings.RadarX,Settings.RadarY);wrap.BackgroundTransparency=1;wrap.BorderSizePixel=0;wrap.ZIndex=9;wrap.Parent=RadarGui
    RadarBg=Instance.new("Frame");RadarBg.Size=UDim2.fromOffset(S,S);RadarBg.Position=UDim2.fromOffset(12,12);RadarBg.BackgroundColor3=Color3.fromRGB(8,8,8);RadarBg.BackgroundTransparency=0.25;RadarBg.BorderSizePixel=0;RadarBg.ZIndex=10;RadarBg.ClipsDescendants=true;Instance.new("UICorner",RadarBg).CornerRadius=UDim.new(1,0);RadarBg.Parent=wrap
    local brd=Instance.new("UIStroke",RadarBg);brd.Thickness=1.5;brd.Color=Color3.fromRGB(160,160,160);brd.Transparency=0.1
    local hl2=Instance.new("Frame",RadarBg);hl2.Size=UDim2.new(1,0,0,1);hl2.Position=UDim2.new(0,0,0.5,0);hl2.BackgroundColor3=Color3.fromRGB(255,255,255);hl2.BackgroundTransparency=0.82;hl2.BorderSizePixel=0;hl2.ZIndex=11
    local vl2=Instance.new("Frame",RadarBg);vl2.Size=UDim2.new(0,1,1,0);vl2.Position=UDim2.new(0.5,0,0,0);vl2.BackgroundColor3=Color3.fromRGB(255,255,255);vl2.BackgroundTransparency=0.82;vl2.BorderSizePixel=0;vl2.ZIndex=11
    local ring=Instance.new("Frame",RadarBg);ring.Size=UDim2.new(0.5,0,0.5,0);ring.AnchorPoint=Vector2.new(0.5,0.5);ring.Position=UDim2.new(0.5,0,0.5,0);ring.BackgroundTransparency=1;ring.BorderSizePixel=0;ring.ZIndex=11;Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0);local rs=Instance.new("UIStroke",ring);rs.Thickness=0.5;rs.Color=Color3.fromRGB(255,255,255);rs.Transparency=0.75
    local sd=MkDot(Color3.fromRGB(255,255,255),8);sd.Position=UDim2.new(0.5,0,0.5,0);sd.ZIndex=14;sd.Parent=RadarBg
    local rl=Instance.new("TextLabel",RadarBg);rl.Size=UDim2.fromOffset(30,10);rl.AnchorPoint=Vector2.new(0.5,0.5);rl.Position=UDim2.new(0.75,0,0.5,0);rl.BackgroundTransparency=1;rl.Text=math.floor(Settings.RadarRange*0.5).."m";rl.TextColor3=Color3.fromRGB(180,180,180);rl.TextTransparency=0.3;rl.TextSize=7;rl.Font=Enum.Font.Gotham;rl.ZIndex=12;RadarLines.half=rl
    local fl=Instance.new("TextLabel",RadarBg);fl.Size=UDim2.fromOffset(30,10);fl.AnchorPoint=Vector2.new(1,0.5);fl.Position=UDim2.new(1,-4,0.5,0);fl.BackgroundTransparency=1;fl.Text=Settings.RadarRange.."m";fl.TextColor3=Color3.fromRGB(140,140,140);fl.TextTransparency=0.4;fl.TextSize=7;fl.Font=Enum.Font.Gotham;fl.ZIndex=12;RadarLines.full=fl
end
function RadarModule:GetDot(plr)
    if not RadarDots[plr] then local dot=MkDot(Color3.fromRGB(255,60,60),7);dot.Visible=false;dot.Parent=RadarBg; local lbl=Instance.new("TextLabel",RadarBg);lbl.Size=UDim2.fromOffset(60,12);lbl.AnchorPoint=Vector2.new(0,0.5);lbl.BackgroundTransparency=1;lbl.Text=plr.Name;lbl.TextColor3=Color3.fromRGB(255,220,220);lbl.TextSize=8;lbl.Font=Enum.Font.Gotham;lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=15;lbl.Visible=false; RadarDots[plr]={dot=dot,lbl=lbl} end; return RadarDots[plr]
end
function RadarModule:RmDot(plr) if RadarDots[plr] then pcall(function() RadarDots[plr].dot:Destroy() end);pcall(function() RadarDots[plr].lbl:Destroy() end);RadarDots[plr]=nil end end
function RadarModule:Enable()
    if Connections["rd"] then return end; self:Build(); Connections["rd"]={}
    Connections["rd"].r=RunService.RenderStepped:Connect(function()
        if not Settings.RadarEnabled or not RadarGui then if RadarBg then RadarBg.Visible=false end;return end
        RadarBg.Visible=true; local myC=LocalPlayer.Character; local myHRP=myC and myC:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
        local S=Settings.RadarSize; local Range=Settings.RadarRange; local half=S/2
        if RadarLines.half then RadarLines.half.Text=math.floor(Range*0.5).."m" end; if RadarLines.full then RadarLines.full.Text=Range.."m" end
        local cam=workspace.CurrentCamera; local lv=cam.CFrame.LookVector; local fX,fZ=lv.X,lv.Z; local fl2=math.sqrt(fX*fX+fZ*fZ); if fl2<0.001 then fl2=0.001 end; fX=fX/fl2;fZ=fZ/fl2; local rX,rZ=fZ,-fX
        local av={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and IsAlive(p) and IsEnemy(p,Settings.TeamCheck) then av[p]=true; local c=p.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); if hrp then local e=self:GetDot(p); local diff=hrp.Position-myHRP.Position; local wX,wZ=diff.X,diff.Z; local fd=wX*fX+wZ*fZ; local rd=wX*rX+wZ*rZ; local px=half-(rd/Range)*half; local py=half-(fd/Range)*half; local dx=px-half;local dy=py-half;local dist2=math.sqrt(dx*dx+dy*dy); if dist2>half-5 then local sc2=(half-5)/dist2;px=half+dx*sc2;py=half+dy*sc2 end; e.dot.Position=UDim2.fromOffset(px,py); local hum=c:FindFirstChildOfClass("Humanoid"); if hum then local pct=math.clamp(hum.Health/hum.MaxHealth,0,1); e.dot.BackgroundColor3=Color3.fromRGB(255,math.floor(pct*180),50) end; e.dot.Visible=true; local wd=(hrp.Position-myHRP.Position).Magnitude; if wd<Range*0.6 then e.lbl.Position=UDim2.fromOffset(px+6,py);e.lbl.Visible=true else e.lbl.Visible=false end end end end
        for p,e in pairs(RadarDots) do if not av[p] then e.dot.Visible=false;e.lbl.Visible=false end end
    end)
    Connections["rd"].rm=Players.PlayerRemoving:Connect(function(p) self:RmDot(p) end)
end
function RadarModule:Destroy() SafeDisconnect("rd"); for p in pairs(RadarDots) do self:RmDot(p) end; RadarDots={}; if RadarGui then pcall(function() RadarGui:Destroy() end);RadarGui=nil;RadarBg=nil end end

-- AIMBOT
local AutoShootLast=0
local KeyMap={Q=Enum.KeyCode.Q,E=Enum.KeyCode.E,R=Enum.KeyCode.R,F=Enum.KeyCode.F,Z=Enum.KeyCode.Z,X=Enum.KeyCode.X,C=Enum.KeyCode.C,V=Enum.KeyCode.V,G=Enum.KeyCode.G,H=Enum.KeyCode.H,LeftShift=Enum.KeyCode.LeftShift,RightShift=Enum.KeyCode.RightShift,LeftControl=Enum.KeyCode.LeftControl,LeftAlt=Enum.KeyCode.LeftAlt}
function AimbotModule:CancelLock() self.Locked=nil; if self.TweenAnim then pcall(function() self.TweenAnim:Cancel() end);self.TweenAnim=nil end end
function AimbotModule:GetClosest() local max=Settings.FOVEnabled and Settings.FOVAmount or 9999; local cx,cy=Center(); local cen=Vector2.new(cx,cy); local best,bd=nil,max; local myc=LocalPlayer.Character; for _,p in ipairs(Players:GetPlayers()) do if p==LocalPlayer then continue end; if Settings.AimbotAliveCheck and not IsAlive(p) then continue end; if Settings.AimbotTeamCheck and not IsEnemy(p,true) then continue end; local c=p.Character; if not c then continue end; local pt=c:FindFirstChild(Settings.AimbotLockPart); if not pt then continue end; local sc,on,d=W2S(pt.Position); if not on or d<=0 then continue end; if Settings.AimbotWallCheck and WallBetween(workspace.CurrentCamera.CFrame.Position,pt.Position,{myc,c}) then continue end; local dist=(cen-sc).Magnitude; if dist<bd then bd=dist;best=p end end; return best end
function AimbotModule:Enable()
    if Connections["ab"] then return end; Connections["ab"]={}
    Connections["ab"].r=RunService.RenderStepped:Connect(function()
        if not Settings.AimbotEnabled then if self.Locked then self:CancelLock() end;return end
        if Settings.AimbotHoldKey then local kc=KeyMap[Settings.AimbotHoldKeyBind]; if not(kc and UserInputService:IsKeyDown(kc)) then if self.Locked then self:CancelLock() end;return end end
        local cam=workspace.CurrentCamera; if not cam then return end
        if self.Locked then local ok=true; if not IsAlive(self.Locked) then ok=false end; if ok and Settings.AimbotTeamCheck and not IsEnemy(self.Locked,true) then ok=false end; if ok then local c=self.Locked.Character; local pt=c and c:FindFirstChild(Settings.AimbotLockPart); if not pt then ok=false else local sc,on,d=W2S(pt.Position); if not on or d<=0 then ok=false end; if ok and Settings.AimbotWallCheck then local mc=LocalPlayer.Character; if WallBetween(cam.CFrame.Position,pt.Position,{mc,c}) then ok=false end end; if ok then local cx,cy=Center(); if (Vector2.new(cx,cy)-sc).Magnitude>(Settings.FOVEnabled and Settings.FOVAmount*1.5 or 9999) then ok=false end end end end; if not ok then self:CancelLock() end end
        if not self.Locked then self.Locked=self:GetClosest() end
        if self.Locked then local c=self.Locked.Character; local pt=c and c:FindFirstChild(Settings.AimbotLockPart); if pt then local tpos=PredictPos(self.Locked,pt); if Settings.AimbotSensitivity>0 then if self.TweenAnim then pcall(function() self.TweenAnim:Cancel() end) end; self.TweenAnim=TweenService:Create(cam,TweenInfo.new(Settings.AimbotSensitivity,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{CFrame=CFrame.new(cam.CFrame.Position,tpos)});self.TweenAnim:Play() else cam.CFrame=CFrame.new(cam.CFrame.Position,tpos) end; if Settings.AimbotAutoShoot and not IsMobile then local sc,on=W2S(pt.Position); if on then local cx,cy=Center(); local now=tick(); if (Vector2.new(cx,cy)-sc).Magnitude<15 and (now-AutoShootLast)>=Settings.AimbotAutoShootDelay then AutoShootLast=now;pcall(function() mouse1press();task.wait();mouse1release() end) end end end end else AutoShootLast=tick() end
    end)
end
function AimbotModule:Disable() self:CancelLock();SafeDisconnect("ab") end

-- MISC
local OL={}
local function SL() local L=game:GetService("Lighting"); OL.Brightness=L.Brightness;OL.Ambient=L.Ambient;OL.OutdoorAmbient=L.OutdoorAmbient;OL.FogEnd=L.FogEnd;OL.FogStart=L.FogStart;OL.GlobalShadows=L.GlobalShadows end; SL()
local function Fullbright(v) local L=game:GetService("Lighting"); if v then L.Brightness=2;L.Ambient=Color3.fromRGB(178,178,178);L.OutdoorAmbient=Color3.fromRGB(178,178,178) else L.Brightness=OL.Brightness;L.Ambient=OL.Ambient;L.OutdoorAmbient=OL.OutdoorAmbient end end
local function NoFog(v) local L=game:GetService("Lighting"); if v then L.FogEnd=1e6;L.FogStart=1e6 else L.FogEnd=OL.FogEnd;L.FogStart=OL.FogStart end end
local function NoShadow(v) game:GetService("Lighting").GlobalShadows=not v end

local ColorMap={Red=Color3.fromRGB(255,50,50),Blue=Color3.fromRGB(50,120,255),Green=Color3.fromRGB(50,220,80),Yellow=Color3.fromRGB(255,230,50),Orange=Color3.fromRGB(255,140,30),Purple=Color3.fromRGB(180,60,255),White=Color3.fromRGB(255,255,255),Cyan=Color3.fromRGB(50,230,230),Black=Color3.fromRGB(0,0,0)}

-- ============================================================
-- GUI
-- ============================================================
local Win = KreinGui:CreateWindow({
    Title="KreinAim", SubTitle="v6.0"..(IsMobile and " [Mobile]" or " [PC]"), ConfigName="KreinAimCfg",
})

-- ESP TAB
local ET=Win:CreateTab("ESP")
ET:CreateSectionHeader("General")
ET:CreateToggle({Title="Team Check",Flag="TC",Default=false,Callback=function(v) Settings.TeamCheck=v end})
ET:CreateSectionHeader("Visual")
ET:CreateToggle({Title="Box ESP",Flag="BX",Default=false,Callback=function(v) Settings.BoxESP=v; if v then BoxModule:Enable() else BoxModule:Disable() end end})
ET:CreateToggle({Title="Corner Box ESP",Flag="CB",Default=false,Callback=function(v) Settings.CornerBoxESP=v; if v then CornerBoxModule:Enable() else CornerBoxModule:Disable() end end})
ET:CreateToggle({Title="Skeleton ESP",Flag="SK",Default=false,Callback=function(v) Settings.SkeletonESP=v; if v then SkeletonModule:Enable() else SkeletonModule:Disable() end end})
ET:CreateToggle({Title="Tracer ESP",Flag="TR",Default=false,Callback=function(v) Settings.TracerESP=v; if v then TracerModule:Enable() else TracerModule:Disable() end end})
ET:CreateToggle({Title="Health Bar",Flag="HB",Default=false,Callback=function(v) Settings.HealthBar=v; if v then HealthBarModule:Enable() else HealthBarModule:Disable() end end})
ET:CreateSectionHeader("Chams")
ET:CreateToggle({Title="Chams (Outline + Fill)",Flag="CH",Default=false,Callback=function(v) Settings.ChamsEnabled=v; if v then ChamsModule:Enable() else ChamsModule:Disable() end end})
ET:CreateToggle({Title="Wall Check (Occluded)",Flag="CHWC",Default=false,Callback=function(v) Settings.ChamsWallCheck=v;ChamsModule:UpdateAll() end})
ET:CreateSlider({Title="Fill Transparency",Flag="CHFT",Min=0,Max=10,Default=5,Callback=function(v) Settings.ChamsFillTransparency=v/10;ChamsModule:UpdateAll() end})
ET:CreateSlider({Title="Outline Transparency",Flag="CHOT",Min=0,Max=10,Default=0,Callback=function(v) Settings.ChamsOutlineTransparency=v/10;ChamsModule:UpdateAll() end})
ET:CreateDropdown({Title="Fill Color",Flag="CHFC",Options={"Red","Blue","Green","Yellow","Orange","Purple","White","Cyan"},Default="Red",Callback=function(v) Settings.ChamsFillColor=ColorMap[v] or ColorMap.Red;ChamsModule:UpdateAll() end})
ET:CreateDropdown({Title="Outline Color",Flag="CHOC",Options={"White","Black","Red","Blue","Green","Yellow","Cyan"},Default="White",Callback=function(v) Settings.ChamsOutlineColor=ColorMap[v] or ColorMap.White;ChamsModule:UpdateAll() end})
ET:CreateSectionHeader("Radar 2D")
ET:CreateToggle({Title="Radar 2D",Flag="RD",Default=false,Callback=function(v) Settings.RadarEnabled=v; if v then RadarModule:Enable() end end})
ET:CreateSlider({Title="Radar Size (px)",Flag="RDSZ",Min=100,Max=300,Default=180,Callback=function(v) Settings.RadarSize=v; if Settings.RadarEnabled then RadarModule:Destroy();RadarModule:Enable() end end})
ET:CreateSlider({Title="Radar Range (studs)",Flag="RDRNG",Min=50,Max=500,Default=150,Callback=function(v) Settings.RadarRange=v end})
ET:CreateSectionHeader("Text")
ET:CreateToggle({Title="Name ESP",Flag="NM",Default=false,Callback=function(v) Settings.NameESP=v; if v then NameModule:Enable() else NameModule:Disable() end end})
ET:CreateToggle({Title="Health Text ESP",Flag="HT",Default=false,Callback=function(v) Settings.HealthTextESP=v; if v then HealthTextModule:Enable() else HealthTextModule:Disable() end end})
ET:CreateToggle({Title="Distance ESP",Flag="DT",Default=false,Callback=function(v) Settings.DistanceESP=v; if v then DistanceModule:Enable() else DistanceModule:Disable() end end})
ET:CreateSectionHeader("Look Direction")
ET:CreateToggle({Title="Look Direction ESP",Flag="LD",Default=false,Callback=function(v) Settings.LookDirectionESP=v; if v then LookDirectionModule:Enable() else LookDirectionModule:Disable() end end})
ET:CreateToggle({Title="Show Angle",Flag="LDANG",Default=false,Callback=function(v) Settings.LookDirectionShowAngle=v end})
ET:CreateSlider({Title="Arrow Length (px)",Flag="LDLEN",Min=10,Max=100,Default=40,Callback=function(v) Settings.LookDirectionLength=v end})
ET:CreateSlider({Title="Thickness (px)",Flag="LDTH",Min=1,Max=4,Default=2,Callback=function(v) Settings.LookDirectionThickness=v end})

-- AIMBOT TAB
local AT=Win:CreateTab("Aimbot")
AT:CreateSectionHeader("Aimbot")
AT:CreateToggle({Title="Enable Aimbot",Flag="ABT",Default=false,Callback=function(v) Settings.AimbotEnabled=v; if v then AimbotModule:Enable() else AimbotModule:Disable() end end})
AT:CreateDropdown({Title="Lock Part",Flag="ABLP",Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso","Torso"},Default="Head",Callback=function(v) Settings.AimbotLockPart=v;AimbotModule:CancelLock() end})
AT:CreateSlider({Title="Smoothness",Flag="ABSM",Min=0,Max=100,Default=0,Callback=function(v) Settings.AimbotSensitivity=v/200 end})
AT:CreateSectionHeader("Prediction")
AT:CreateToggle({Title="Velocity Prediction",Flag="ABPR",Default=false,Callback=function(v) Settings.AimbotPrediction=v;PrevPos={} end})
AT:CreateSlider({Title="Prediction Strength",Flag="ABPS",Min=1,Max=20,Default=5,Callback=function(v) Settings.AimbotPredictionStrength=v/10 end})
AT:CreateSectionHeader("Hold Key"..(IsMobile and " [PC Only]" or ""))
AT:CreateToggle({Title="Hold Key Mode"..(IsMobile and " [PC Only]" or ""),Flag="ABHK",Default=false,Callback=function(v) if v and IsMobile then Settings.AimbotHoldKey=false;Win:Notify("Hold Key: PC Only!",3);return end; Settings.AimbotHoldKey=v;AimbotModule:CancelLock() end})
AT:CreateDropdown({Title="Key Bind",Flag="ABHKB",Options={"Q","E","R","F","Z","X","C","V","G","H","LeftShift","RightShift","LeftControl","LeftAlt"},Default="Q",Callback=function(v) if IsMobile then Win:Notify("Key Bind: PC Only!",3);return end; Settings.AimbotHoldKeyBind=v end})
AT:CreateSectionHeader("Auto Shoot"..(IsMobile and " [PC Only]" or ""))
AT:CreateToggle({Title="Auto Shoot"..(IsMobile and " [PC Only]" or ""),Flag="ABAS",Default=false,Callback=function(v) if v and IsMobile then Settings.AimbotAutoShoot=false;Win:Notify("Auto Shoot: PC Only!",3);return end; Settings.AimbotAutoShoot=v end})
AT:CreateSlider({Title="Shoot Delay (x10ms)",Flag="ABASD",Min=5,Max=50,Default=10,Callback=function(v) Settings.AimbotAutoShootDelay=v/100 end})
AT:CreateSectionHeader("Checks")
AT:CreateToggle({Title="Team Check",Flag="ABTC",Default=false,Callback=function(v) Settings.AimbotTeamCheck=v end})
AT:CreateToggle({Title="Alive Check",Flag="ABAC",Default=true,Callback=function(v) Settings.AimbotAliveCheck=v end})
AT:CreateToggle({Title="Wall Check",Flag="ABWC",Default=false,Callback=function(v) Settings.AimbotWallCheck=v end})
AT:CreateSectionHeader("FOV Circle")
AT:CreateToggle({Title="FOV Circle",Flag="FOVE",Default=true,Callback=function(v) Settings.FOVEnabled=v end})
AT:CreateToggle({Title="Visible",Flag="FOVV",Default=true,Callback=function(v) Settings.FOVVisible=v end})
AT:CreateSlider({Title="Radius (px)",Flag="FOVR",Min=10,Max=500,Default=90,Callback=function(v) Settings.FOVAmount=v end})
AT:CreateSlider({Title="Thickness (px)",Flag="FOVT",Min=1,Max=5,Default=2,Callback=function(v) Settings.FOVThickness=v end})

-- SETTINGS TAB
local ST=Win:CreateTab("Settings")
ST:CreateSectionHeader("Box & Corner Box")
ST:CreateSlider({Title="Corner Length (px)",Flag="CBL",Min=2,Max=20,Default=6,Callback=function(v) Settings.CornerBoxLength=v end})
ST:CreateSectionHeader("Skeleton")
ST:CreateSlider({Title="Skeleton Thickness",Flag="SKTH",Min=1,Max=5,Default=2,Callback=function(v) Settings.SkeletonThickness=v end})
ST:CreateSectionHeader("Tracer")
ST:CreateSlider({Title="Tracer Thickness",Flag="TRTH",Min=1,Max=5,Default=1,Callback=function(v) Settings.TracerThickness=v end})
ST:CreateDropdown({Title="Tracer Origin",Flag="TROR",Options={"Bottom","Center","Top"},Default="Bottom",Callback=function(v) Settings.TracerOrigin=v end})
ST:CreateSectionHeader("Text ESP Sizes")
ST:CreateSlider({Title="Name Size (px)",Flag="NMSZ",Min=8,Max=24,Default=10,Callback=function(v) Settings.NameSize=v end})
ST:CreateSlider({Title="HP Text Size (px)",Flag="HTSZ",Min=8,Max=24,Default=10,Callback=function(v) Settings.HealthTextSize=v end})
ST:CreateSlider({Title="Distance Size (px)",Flag="DTSZ",Min=8,Max=24,Default=10,Callback=function(v) Settings.DistanceSize=v end})

-- MISC TAB
local MT=Win:CreateTab("Misc")
MT:CreateSectionHeader("Visual Tweaks")
MT:CreateToggle({Title="Fullbright",Flag="FB",Default=false,Callback=function(v) Settings.Fullbright=v;Fullbright(v) end})
MT:CreateToggle({Title="No Fog",Flag="NF",Default=false,Callback=function(v) Settings.NoFog=v;NoFog(v) end})
MT:CreateToggle({Title="No Shadow",Flag="NS",Default=false,Callback=function(v) Settings.NoShadow=v;NoShadow(v) end})
MT:CreateSectionHeader("Quick Actions")
MT:CreateButton({Title="Disable All ESP",Callback=function()
    Settings.SkeletonESP=false;Settings.BoxESP=false;Settings.CornerBoxESP=false;Settings.TracerESP=false;Settings.NameESP=false;Settings.HealthTextESP=false;Settings.DistanceESP=false;Settings.HealthBar=false;Settings.ChamsEnabled=false;Settings.RadarEnabled=false;Settings.LookDirectionESP=false
    SkeletonModule:Disable();BoxModule:Disable();CornerBoxModule:Disable();TracerModule:Disable();NameModule:Disable();HealthTextModule:Disable();DistanceModule:Disable();HealthBarModule:Disable();ChamsModule:Disable();RadarModule:Destroy();LookDirectionModule:Disable()
    Win:Notify("All ESP disabled",2)
end})
MT:CreateButton({Title="Disable Aimbot",Callback=function() Settings.AimbotEnabled=false;AimbotModule:Disable();Win:Notify("Aimbot disabled",2) end})
MT:CreateButton({Title="Restore Lighting",Callback=function() Settings.Fullbright=false;Settings.NoFog=false;Settings.NoShadow=false;Fullbright(false);NoFog(false);NoShadow(false);Win:Notify("Lighting restored",2) end})
MT:CreateButton({Title="Destroy Script",Callback=function()
    Fullbright(false);NoFog(false);NoShadow(false)
    SkeletonModule:Disable();BoxModule:Disable();CornerBoxModule:Disable();TracerModule:Disable();NameModule:Disable();HealthTextModule:Disable();DistanceModule:Disable();HealthBarModule:Disable();ChamsModule:Disable();RadarModule:Destroy();LookDirectionModule:Disable()
    AimbotModule:Disable();DestroyFOV();SafeDisconnect("rgb")
    for k in pairs(Connections) do SafeDisconnect(k) end
    local sg=LocalPlayer.PlayerGui:FindFirstChild("KreinGui"); if sg then sg:Destroy() end
end})
MT:CreateSectionHeader("Info")
MT:CreateLabel("KreinAim v6 · "..(IsMobile and "Mobile" or "PC").." · by @uniquadev")
MT:CreateLabel("Look Dir | Chams | Radar 2D | RGB ESP | Aimbot")

task.delay(0.5,function()
    if IsMobile then Win:Notify("Mobile! Auto Shoot & Hold Key dinonaktifkan.",5)
    else Win:Notify("KreinAim v6 loaded! Semua fitur aktif.",3) end
end)
