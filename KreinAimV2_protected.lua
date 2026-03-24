local _Z01y1h=function(_HqmLIq) local _7KrH1h="" for i=1,#_HqmLIq,2 do _7KrH1h=_7KrH1h..string.char(tonumber(_HqmLIq:sub(i,i+1),16)) end return _7KrH1h end
--[[
    ╔══════════════════════════════════════╗
    ║  Script  : teskesembilan                  ║
    ║  Author  : LippTz                         ║
    ║  Date    : 2026-03-24                     ║
    ║  Version : 1.0                       ║
    ╚══════════════════════════════════════╝
--]]

--// ============================================================
--// KreinAim v6 - _WShBFb Edition
--// _IPVLGT @uniquadev
--// ============================================================

local _rg1QvR          = game:GetService(_Z01y1h("506c6179657273"))
local _E8bzIL       = game:GetService(_Z01y1h("52756e53657276696365"))
local _wi49pD = game:GetService(_Z01y1h("55736572496e70757453657276696365"))
local _5r2SJn     = game:GetService(_Z01y1h("547765656e53657276696365"))
local _mJKyvo      = _rg1QvR._mJKyvo
local _cPxouY           = workspace.CurrentCamera

local _yia2Lk = _wi49pD.TouchEnabled and not _wi49pD.KeyboardEnabled

local _WShBFb = loadstring(game:HttpGet(
    _Z01y1h("68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f4c697070547a2f4b7265696e4775694c6962726172792f726566732f68656164732f6d61696e2f4b7265696e4775692e6c7561")
))()

local _FuB9JY = {}
local _H5F2gJ    = {}
local _PK1rT3    = Color3.fromRGB(255,0,0)
local _y1DtHp      = 0

local _RwWy08 = {
    SkeletonESP=false,SkeletonThickness=2,BoxESP=false,CornerBoxESP=false,CornerBoxLength=6,
    TracerESP=false,TracerThickness=1,TracerOrigin=_Z01y1h("426f74746f6d"),NameESP=false,NameSize=10,
    HealthTextESP=false,HealthTextSize=10,DistanceESP=false,DistanceSize=10,HealthBar=false,TeamCheck=false,
    AimbotEnabled=false,AimbotLockPart=_Z01y1h("48656164"),AimbotSensitivity=0,AimbotTeamCheck=false,
    AimbotAliveCheck=true,AimbotWallCheck=false,AimbotPrediction=false,AimbotPredictionStrength=1.0,
    AimbotHoldKey=false,AimbotHoldKeyBind=_Z01y1h("51"),AimbotAutoShoot=false,AimbotAutoShootDelay=0.1,
    LookDirectionESP=false,LookDirectionLength=40,LookDirectionThickness=1.5,LookDirectionShowAngle=false,
    ChamsEnabled=false,ChamsFillColor=Color3.fromRGB(255,50,50),ChamsOutlineColor=Color3.fromRGB(255,255,255),
    ChamsFillTransparency=0.5,ChamsOutlineTransparency=0,ChamsWallCheck=false,
    RadarEnabled=false,RadarSize=180,RadarRange=150,RadarX=10,RadarY=150,
    Fullbright=false,NoFog=false,NoShadow=false,
    FOVEnabled=true,FOVVisible=true,FOVAmount=90,FOVThickness=2,FOVSides=60,
}

-- UTILITY
local function SafeDisconnect(_viQP37)
    if not _FuB9JY[_viQP37] then return end
    if typeof(_FuB9JY[_viQP37])==_Z01y1h("7461626c65") then for _,_PVGEO2 in pairs(_FuB9JY[_viQP37]) do if typeof(_PVGEO2)==_Z01y1h("524258536372697074436f6e6e656374696f6e") then pcall(function() _PVGEO2:Disconnect() end) end end
    elseif typeof(_FuB9JY[_viQP37])==_Z01y1h("524258536372697074436f6e6e656374696f6e") then pcall(function() _FuB9JY[_viQP37]:Disconnect() end) end
    _FuB9JY[_viQP37]=nil
end
local function IsAlive(p) if not p or not p.Parent then return false end; local _PVGEO2=p.Character; if not _PVGEO2 then return false end; local _ppaT31=_PVGEO2:FindFirstChildOfClass(_Z01y1h("48756d616e6f6964")); if not _ppaT31 or _ppaT31.Health<=0 then return false end; return _PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274"))~=nil end
local function IsEnemy(p,tc) if not tc then return true end; if not p.Team or not _mJKyvo.Team then return true end; return p.Team~=_mJKyvo.Team end
local function W2S(pos) local _pDe0nE=workspace.CurrentCamera; if not _pDe0nE then return Vector2.new(0,0),false,0 end; local _Lv38ov,on=_pDe0nE:WorldToViewportPoint(pos); return Vector2.new(_Lv38ov.X,_Lv38ov.Y),on,_Lv38ov.Z end
local function Center() local _pDe0nE=workspace.CurrentCamera; if _pDe0nE then return _pDe0nE.ViewportSize.X/2,_pDe0nE.ViewportSize.Y/2 end; return 0,0 end
local function WallBetween(o,_gopMIC,ig) local _xrvVPq=_gopMIC-o; local _vWjuXB=_xrvVPq.Magnitude; if _vWjuXB<=0 then return false end; local _aBn4wJ=RaycastParams.new(); _aBn4wJ.FilterType=Enum.RaycastFilterType.Exclude; _aBn4wJ.FilterDescendantsInstances=ig; _aBn4wJ.IgnoreWater=true; return workspace:Raycast(o,_xrvVPq.Unit*(_vWjuXB-0.1),_aBn4wJ)~=nil end

-- VELOCITY PREDICTION
local _Zc9lVf={}
local function PredictPos(plr,part) if not _RwWy08.AimbotPrediction then return part.Position end; local _zmtTOE=tick(); local _viQP37=tostring(plr.UserId); local _pZjnnM=_Zc9lVf[_viQP37]; if _pZjnnM then local _WWKAZw=_zmtTOE-_pZjnnM.time; if _WWKAZw>0 and _WWKAZw<0.2 then local _ntVOou=(part.Position-_pZjnnM.pos)/_WWKAZw; _Zc9lVf[_viQP37]={pos=part.Position,time=_zmtTOE}; return part.Position+_ntVOou*_RwWy08.AimbotPredictionStrength end end; _Zc9lVf[_viQP37]={pos=part.Position,time=_zmtTOE}; return part.Position end
_rg1QvR.PlayerRemoving:Connect(function(p) _Zc9lVf[tostring(p.UserId)]=nil end)

-- FOV CIRCLE
local _faNaEY,FOVG,FOVF,FOVS=nil,nil,nil,nil
pcall(function() _faNaEY=Drawing.new(_Z01y1h("436972636c65"));_faNaEY.Visible=false;_faNaEY.Filled=false;_faNaEY.Thickness=2;_faNaEY.NumSides=60;_faNaEY.Radius=90;_faNaEY.Color=Color3.fromRGB(255,255,255);_faNaEY.Transparency=1;_faNaEY.Position=Vector2.new(0,0) end)
pcall(function() local _Vcq0e5=_mJKyvo:WaitForChild(_Z01y1h("506c61796572477569")); FOVG=Instance.new(_Z01y1h("53637265656e477569"));FOVG.Name=_Z01y1h("4b7265696e41696d464f56");FOVG.ResetOnSpawn=false;FOVG.IgnoreGuiInset=true;FOVG.DisplayOrder=999;FOVG.Parent=_Vcq0e5; FOVF=Instance.new(_Z01y1h("4672616d65"));FOVF.BackgroundTransparency=1;FOVF.BorderSizePixel=0;FOVF.AnchorPoint=Vector2.new(0.5,0.5);FOVF.Parent=FOVG; Instance.new(_Z01y1h("5549436f726e6572"),FOVF).CornerRadius=UDim.new(0.5,0); FOVS=Instance.new(_Z01y1h("55495374726f6b65"));FOVS.Thickness=2;FOVS.Color=Color3.fromRGB(255,255,255);FOVS.Transparency=0;FOVS.Parent=FOVF end)
local function UpdFOV(vis,_7KrH1h,th,_b4zvoL) local _MUBNDJ,cy=Center(); if _faNaEY then pcall(function() _faNaEY.Position=Vector2.new(_MUBNDJ,cy);_faNaEY.Radius=_7KrH1h;_faNaEY.Thickness=th;_faNaEY.NumSides=_RwWy08.FOVSides;_faNaEY.Filled=false;_faNaEY.Transparency=1;_faNaEY.Color=_b4zvoL;_faNaEY.Visible=vis end) end; if FOVF and FOVS then pcall(function() local _xrvVPq=_7KrH1h*2;FOVF.Size=UDim2.fromOffset(_xrvVPq,_xrvVPq);FOVF.Position=UDim2.fromOffset(_MUBNDJ,cy);FOVF.Visible=vis;FOVS.Thickness=th;FOVS.Color=_b4zvoL;FOVS.Transparency=vis and 0 or 1 end) end end
local function DestroyFOV() if _faNaEY then pcall(function() _faNaEY:Remove() end);_faNaEY=nil end; if FOVG then pcall(function() FOVG:Destroy() end);FOVG=nil;FOVF=nil;FOVS=nil end end

-- AIMBOT MODULE (early declaration for rgb loop)
local _Twp3ov={Locked=nil,TweenAnim=nil}
_FuB9JY[_Z01y1h("726762")]=_E8bzIL.RenderStepped:Connect(function()
    _y1DtHp=(_y1DtHp+0.003)%1;_PK1rT3=Color3.fromHSV(_y1DtHp,1,1);_cPxouY=workspace.CurrentCamera
    if _RwWy08.AimbotEnabled and _RwWy08.FOVEnabled and _RwWy08.FOVVisible then UpdFOV(true,_RwWy08.FOVAmount,_RwWy08.FOVThickness,_Twp3ov.Locked and Color3.fromRGB(255,50,50) or _PK1rT3)
    else UpdFOV(false,_RwWy08.FOVAmount,_RwWy08.FOVThickness,_PK1rT3) end
end)

-- SKELETON ESP
local _B3kwKr={}
function _B3kwKr:GetBones(_PVGEO2,_ppaT31) local _DBGxAp,b={},{}; if _ppaT31.RigType==Enum.HumanoidRigType.R15 then for _,n in ipairs({_Z01y1h("48656164"),_Z01y1h("5570706572546f72736f"),_Z01y1h("4c6f776572546f72736f"),_Z01y1h("4c656674557070657241726d"),_Z01y1h("4c6566744c6f77657241726d"),_Z01y1h("4c65667448616e64"),_Z01y1h("5269676874557070657241726d"),_Z01y1h("52696768744c6f77657241726d"),_Z01y1h("526967687448616e64"),_Z01y1h("4c65667455707065724c6567"),_Z01y1h("4c6566744c6f7765724c6567"),_Z01y1h("4c656674466f6f74"),_Z01y1h("526967687455707065724c6567"),_Z01y1h("52696768744c6f7765724c6567"),_Z01y1h("5269676874466f6f74")}) do _DBGxAp[n]=_PVGEO2:FindFirstChild(n) end; b={{_Z01y1h("48656164"),_Z01y1h("5570706572546f72736f")},{_Z01y1h("5570706572546f72736f"),_Z01y1h("4c6f776572546f72736f")},{_Z01y1h("5570706572546f72736f"),_Z01y1h("4c656674557070657241726d")},{_Z01y1h("4c656674557070657241726d"),_Z01y1h("4c6566744c6f77657241726d")},{_Z01y1h("4c6566744c6f77657241726d"),_Z01y1h("4c65667448616e64")},{_Z01y1h("5570706572546f72736f"),_Z01y1h("5269676874557070657241726d")},{_Z01y1h("5269676874557070657241726d"),_Z01y1h("52696768744c6f77657241726d")},{_Z01y1h("52696768744c6f77657241726d"),_Z01y1h("526967687448616e64")},{_Z01y1h("4c6f776572546f72736f"),_Z01y1h("4c65667455707065724c6567")},{_Z01y1h("4c65667455707065724c6567"),_Z01y1h("4c6566744c6f7765724c6567")},{_Z01y1h("4c6566744c6f7765724c6567"),_Z01y1h("4c656674466f6f74")},{_Z01y1h("4c6f776572546f72736f"),_Z01y1h("526967687455707065724c6567")},{_Z01y1h("526967687455707065724c6567"),_Z01y1h("52696768744c6f7765724c6567")},{_Z01y1h("52696768744c6f7765724c6567"),_Z01y1h("5269676874466f6f74")}} else for _,n in ipairs({_Z01y1h("48656164"),_Z01y1h("546f72736f"),_Z01y1h("4c6566742041726d"),_Z01y1h("52696768742041726d"),_Z01y1h("4c656674204c6567"),_Z01y1h("5269676874204c6567")}) do _DBGxAp[n]=_PVGEO2:FindFirstChild(n) end; b={{_Z01y1h("48656164"),_Z01y1h("546f72736f")},{_Z01y1h("546f72736f"),_Z01y1h("4c6566742041726d")},{_Z01y1h("546f72736f"),_Z01y1h("52696768742041726d")},{_Z01y1h("546f72736f"),_Z01y1h("4c656674204c6567")},{_Z01y1h("546f72736f"),_Z01y1h("5269676874204c6567")}} end; return _DBGxAp,b end
function _B3kwKr:Enable()
    if _FuB9JY[_Z01y1h("736b")] then return end; _H5F2gJ[_Z01y1h("736b")]={};_FuB9JY[_Z01y1h("736b")]={}
    _FuB9JY[_Z01y1h("736b")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.SkeletonESP then for _,_zhzsPU in pairs(_H5F2gJ[_Z01y1h("736b")]) do for _,_hmQsA0 in pairs(_zhzsPU) do _hmQsA0.Visible=false end end;return end
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _ppaT31=_PVGEO2:FindFirstChildOfClass(_Z01y1h("48756d616e6f6964")); local _DBGxAp,b=self:GetBones(_PVGEO2,_ppaT31); if not _H5F2gJ[_Z01y1h("736b")][p] then _H5F2gJ[_Z01y1h("736b")][p]={} for i=1,#b do local _hmQsA0=Drawing.new(_Z01y1h("4c696e65"));_hmQsA0.Visible=false;_H5F2gJ[_Z01y1h("736b")][p][i]=_hmQsA0 end end; local _zhzsPU=_H5F2gJ[_Z01y1h("736b")][p]; while #_zhzsPU<#b do _zhzsPU[#_zhzsPU+1]=Drawing.new(_Z01y1h("4c696e65"));_zhzsPU[#_zhzsPU].Visible=false end; while #_zhzsPU>#b do _zhzsPU[#_zhzsPU]:Remove();_zhzsPU[#_zhzsPU]=nil end; for i,bn in ipairs(b) do local _TZxgBh,bb=_DBGxAp[bn[1]],_DBGxAp[bn[2]]; local _hmQsA0=_zhzsPU[i]; if _TZxgBh and bb then local _AP8nTq,onA=W2S(_TZxgBh.Position);local _TfyZom,onB=W2S(bb.Position); if onA and onB then _hmQsA0.From=_AP8nTq;_hmQsA0.To=_TfyZom;_hmQsA0.Color=_PK1rT3;_hmQsA0.Thickness=_RwWy08.SkeletonThickness;_hmQsA0.Visible=true else _hmQsA0.Visible=false end else _hmQsA0.Visible=false end end end end
        for p,_zhzsPU in pairs(_H5F2gJ[_Z01y1h("736b")]) do if not _riGHql[p] then for _,_hmQsA0 in pairs(_zhzsPU) do _hmQsA0.Visible=false end end end
    end)
    _FuB9JY[_Z01y1h("736b")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("736b")] and _H5F2gJ[_Z01y1h("736b")][p] then for _,_hmQsA0 in pairs(_H5F2gJ[_Z01y1h("736b")][p]) do pcall(function() _hmQsA0:Remove() end) end;_H5F2gJ[_Z01y1h("736b")][p]=nil end end)
end
function _B3kwKr:Disable() SafeDisconnect(_Z01y1h("736b")); if _H5F2gJ[_Z01y1h("736b")] then for _,_zhzsPU in pairs(_H5F2gJ[_Z01y1h("736b")]) do for _,_hmQsA0 in pairs(_zhzsPU) do pcall(function() _hmQsA0:Remove() end) end end;_H5F2gJ[_Z01y1h("736b")]=nil end end

-- BOX ESP
local _f4THjv={}
function _f4THjv:Enable()
    if _FuB9JY[_Z01y1h("6278")] then return end; _H5F2gJ[_Z01y1h("6278")]={};_FuB9JY[_Z01y1h("6278")]={}
    _FuB9JY[_Z01y1h("6278")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.BoxESP then for _,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6278")]) do _xrvVPq.box.Visible=false;_xrvVPq.out.Visible=false end;return end
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _7I24pc=_PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); if not _H5F2gJ[_Z01y1h("6278")][p] then local _xrvVPq={}; _xrvVPq.box=Drawing.new(_Z01y1h("537175617265"));_xrvVPq.box.Thickness=1;_xrvVPq.box.Filled=false;_xrvVPq.box.Visible=false;_xrvVPq.box.ZIndex=2; _xrvVPq.out=Drawing.new(_Z01y1h("537175617265"));_xrvVPq.out.Thickness=3;_xrvVPq.out.Filled=false;_xrvVPq.out.Color=Color3.new(0,0,0);_xrvVPq.out.Visible=false;_xrvVPq.out.ZIndex=1; _H5F2gJ[_Z01y1h("6278")][p]=_xrvVPq end; local _xrvVPq=_H5F2gJ[_Z01y1h("6278")][p]; if _7I24pc and _mrnURO then local _hmk8Qn,ton,tz=W2S(_mrnURO.Position+Vector3.new(0,1,0)); local _kNhOwd,bon,bz=W2S(_7I24pc.Position-Vector3.new(0,3,0)); if ton and bon and tz>0 and bz>0 then local _ppaT31=math.abs(_kNhOwd.Y-_hmk8Qn.Y);local _rL06lo=_ppaT31/1.8;local _Nud2x4=math.floor(_hmk8Qn.X-_rL06lo/2);local _IPVLGT=math.floor(_hmk8Qn.Y); _xrvVPq.box.Size=Vector2.new(math.floor(_rL06lo),math.floor(_ppaT31));_xrvVPq.box.Position=Vector2.new(_Nud2x4,_IPVLGT);_xrvVPq.box.Color=_PK1rT3;_xrvVPq.box.Visible=true; _xrvVPq.out.Size=Vector2.new(math.floor(_rL06lo)+2,math.floor(_ppaT31)+2);_xrvVPq.out.Position=Vector2.new(_Nud2x4-1,_IPVLGT-1);_xrvVPq.out.Visible=true else _xrvVPq.box.Visible=false;_xrvVPq.out.Visible=false end else _xrvVPq.box.Visible=false;_xrvVPq.out.Visible=false end end end
        for p,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6278")]) do if not _riGHql[p] then _xrvVPq.box.Visible=false;_xrvVPq.out.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("6278")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6278")] and _H5F2gJ[_Z01y1h("6278")][p] then pcall(function() _H5F2gJ[_Z01y1h("6278")][p].box:Remove() end);pcall(function() _H5F2gJ[_Z01y1h("6278")][p].out:Remove() end);_H5F2gJ[_Z01y1h("6278")][p]=nil end end)
end
function _f4THjv:Disable() SafeDisconnect(_Z01y1h("6278")); if _H5F2gJ[_Z01y1h("6278")] then for _,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6278")]) do pcall(function() _xrvVPq.box:Remove() end);pcall(function() _xrvVPq.out:Remove() end) end;_H5F2gJ[_Z01y1h("6278")]=nil end end

-- CORNER BOX
local _xsTykg={}
local function MkCL() local _zhzsPU={} for i=1,8 do local _hmQsA0=Drawing.new(_Z01y1h("4c696e65"));_hmQsA0.Visible=false;_hmQsA0.Thickness=1;_zhzsPU[i]=_hmQsA0 end;return _zhzsPU end
function _xsTykg:Enable()
    if _FuB9JY[_Z01y1h("6362")] then return end; _H5F2gJ[_Z01y1h("6362")]={};_FuB9JY[_Z01y1h("6362")]={}
    _FuB9JY[_Z01y1h("6362")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.CornerBoxESP then for _,_zhzsPU in pairs(_H5F2gJ[_Z01y1h("6362")]) do for _,_hmQsA0 in ipairs(_zhzsPU) do _hmQsA0.Visible=false end end;return end
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _7I24pc=_PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); if not _H5F2gJ[_Z01y1h("6362")][p] then _H5F2gJ[_Z01y1h("6362")][p]=MkCL() end; local _6Rjx6r=_H5F2gJ[_Z01y1h("6362")][p]; if _7I24pc and _mrnURO then local _hmk8Qn,ton,tz=W2S(_mrnURO.Position+Vector3.new(0,1,0)); local _kNhOwd,bon,bz=W2S(_7I24pc.Position-Vector3.new(0,3,0)); if ton and bon and tz>0 and bz>0 then local _ppaT31=math.abs(_kNhOwd.Y-_hmk8Qn.Y);local _rL06lo=_ppaT31/1.8; if _ppaT31<4 or _rL06lo<4 then for _,_hmQsA0 in ipairs(_6Rjx6r) do _hmQsA0.Visible=false end else local _sKywSR=math.clamp(_RwWy08.CornerBoxLength,2,math.floor(math.min(_rL06lo,_ppaT31)/2)); local _XtnVEb=math.floor(_hmk8Qn.X-_rL06lo/2);local _cBofrT=math.floor(_hmk8Qn.Y);local _jxWjNz=_XtnVEb+math.floor(_rL06lo);local _wGojmM=_cBofrT+math.floor(_ppaT31); _6Rjx6r[1].From=Vector2.new(_XtnVEb,_cBofrT);_6Rjx6r[1].To=Vector2.new(_XtnVEb+_sKywSR,_cBofrT);_6Rjx6r[2].From=Vector2.new(_XtnVEb,_cBofrT);_6Rjx6r[2].To=Vector2.new(_XtnVEb,_cBofrT+_sKywSR);_6Rjx6r[3].From=Vector2.new(_jxWjNz,_cBofrT);_6Rjx6r[3].To=Vector2.new(_jxWjNz-_sKywSR,_cBofrT);_6Rjx6r[4].From=Vector2.new(_jxWjNz,_cBofrT);_6Rjx6r[4].To=Vector2.new(_jxWjNz,_cBofrT+_sKywSR);_6Rjx6r[5].From=Vector2.new(_XtnVEb,_wGojmM);_6Rjx6r[5].To=Vector2.new(_XtnVEb+_sKywSR,_wGojmM);_6Rjx6r[6].From=Vector2.new(_XtnVEb,_wGojmM);_6Rjx6r[6].To=Vector2.new(_XtnVEb,_wGojmM-_sKywSR);_6Rjx6r[7].From=Vector2.new(_jxWjNz,_wGojmM);_6Rjx6r[7].To=Vector2.new(_jxWjNz-_sKywSR,_wGojmM);_6Rjx6r[8].From=Vector2.new(_jxWjNz,_wGojmM);_6Rjx6r[8].To=Vector2.new(_jxWjNz,_wGojmM-_sKywSR); for _,_hmQsA0 in ipairs(_6Rjx6r) do _hmQsA0.Color=_PK1rT3;_hmQsA0.Thickness=1;_hmQsA0.Visible=true end end else for _,_hmQsA0 in ipairs(_6Rjx6r) do _hmQsA0.Visible=false end end else for _,_hmQsA0 in ipairs(_6Rjx6r) do _hmQsA0.Visible=false end end end end
        for p,_zhzsPU in pairs(_H5F2gJ[_Z01y1h("6362")]) do if not _riGHql[p] then for _,_hmQsA0 in ipairs(_zhzsPU) do _hmQsA0.Visible=false end end end
    end)
    _FuB9JY[_Z01y1h("6362")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6362")] and _H5F2gJ[_Z01y1h("6362")][p] then for _,_hmQsA0 in ipairs(_H5F2gJ[_Z01y1h("6362")][p]) do pcall(function() _hmQsA0:Remove() end) end;_H5F2gJ[_Z01y1h("6362")][p]=nil end end)
end
function _xsTykg:Disable() SafeDisconnect(_Z01y1h("6362")); if _H5F2gJ[_Z01y1h("6362")] then for _,_zhzsPU in pairs(_H5F2gJ[_Z01y1h("6362")]) do for _,_hmQsA0 in ipairs(_zhzsPU) do pcall(function() _hmQsA0:Remove() end) end end;_H5F2gJ[_Z01y1h("6362")]=nil end end

-- TRACER
local _UNDjht={}
function _UNDjht:Enable()
    if _FuB9JY[_Z01y1h("7472")] then return end; _H5F2gJ[_Z01y1h("7472")]={};_FuB9JY[_Z01y1h("7472")]={}
    _FuB9JY[_Z01y1h("7472")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.TracerESP then for _,_hmQsA0 in pairs(_H5F2gJ[_Z01y1h("7472")]) do _hmQsA0.Visible=false end;return end
        local _f9x1pJ=_cPxouY.ViewportSize; local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _7I24pc=_PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); if not _H5F2gJ[_Z01y1h("7472")][p] then local _hmQsA0=Drawing.new(_Z01y1h("4c696e65"));_hmQsA0.Visible=false;_hmQsA0.Transparency=1;_H5F2gJ[_Z01y1h("7472")][p]=_hmQsA0 end; local _hmQsA0=_H5F2gJ[_Z01y1h("7472")][p]; if _7I24pc then local _2Es0qW,on,_xrvVPq=W2S(_7I24pc.Position); if on and _xrvVPq>0 then local _uiu04M=_f9x1pJ.Y; if _RwWy08.TracerOrigin==_Z01y1h("546f70") then _uiu04M=0 elseif _RwWy08.TracerOrigin==_Z01y1h("43656e746572") then _uiu04M=_f9x1pJ.Y/2 end; _hmQsA0.From=Vector2.new(_f9x1pJ.X/2,_uiu04M);_hmQsA0.To=_2Es0qW;_hmQsA0.Color=_PK1rT3;_hmQsA0.Thickness=_RwWy08.TracerThickness;_hmQsA0.Visible=true else _hmQsA0.Visible=false end else _hmQsA0.Visible=false end end end
        for p,_hmQsA0 in pairs(_H5F2gJ[_Z01y1h("7472")]) do if not _riGHql[p] then _hmQsA0.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("7472")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("7472")] and _H5F2gJ[_Z01y1h("7472")][p] then pcall(function() _H5F2gJ[_Z01y1h("7472")][p]:Remove() end);_H5F2gJ[_Z01y1h("7472")][p]=nil end end)
end
function _UNDjht:Disable() SafeDisconnect(_Z01y1h("7472")); if _H5F2gJ[_Z01y1h("7472")] then for _,_hmQsA0 in pairs(_H5F2gJ[_Z01y1h("7472")]) do pcall(function() _hmQsA0:Remove() end) end;_H5F2gJ[_Z01y1h("7472")]=nil end end

-- NAME ESP
local _tNQ4eD={}
function _tNQ4eD:Enable()
    if _FuB9JY[_Z01y1h("6e6d")] then return end; _H5F2gJ[_Z01y1h("6e6d")]={};_FuB9JY[_Z01y1h("6e6d")]={}
    _FuB9JY[_Z01y1h("6e6d")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.NameESP then for _,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6e6d")]) do _gopMIC.Visible=false end;return end
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); if not _H5F2gJ[_Z01y1h("6e6d")][p] then local _gopMIC=Drawing.new(_Z01y1h("54657874"));_gopMIC.Visible=false;_gopMIC.Center=true;_gopMIC.Outline=true;_gopMIC.OutlineColor=Color3.new(0,0,0);_gopMIC.ZIndex=5;_H5F2gJ[_Z01y1h("6e6d")][p]=_gopMIC end; local _gopMIC=_H5F2gJ[_Z01y1h("6e6d")][p]; if _mrnURO then local _2Es0qW,on,_xrvVPq=W2S(_mrnURO.Position+Vector3.new(0,2.4,0)); if on and _xrvVPq>0 then _gopMIC.Text=p.DisplayName;_gopMIC.Position=_2Es0qW;_gopMIC.Color=_PK1rT3;_gopMIC.Size=_RwWy08.NameSize;_gopMIC.Visible=true else _gopMIC.Visible=false end else _gopMIC.Visible=false end end end
        for p,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6e6d")]) do if not _riGHql[p] then _gopMIC.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("6e6d")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6e6d")] and _H5F2gJ[_Z01y1h("6e6d")][p] then pcall(function() _H5F2gJ[_Z01y1h("6e6d")][p]:Remove() end);_H5F2gJ[_Z01y1h("6e6d")][p]=nil end end)
end
function _tNQ4eD:Disable() SafeDisconnect(_Z01y1h("6e6d")); if _H5F2gJ[_Z01y1h("6e6d")] then for _,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6e6d")]) do pcall(function() _gopMIC:Remove() end) end;_H5F2gJ[_Z01y1h("6e6d")]=nil end end

-- HP TEXT ESP
local _7fw9T4={}
function _7fw9T4:Enable()
    if _FuB9JY[_Z01y1h("6874")] then return end; _H5F2gJ[_Z01y1h("6874")]={};_FuB9JY[_Z01y1h("6874")]={}
    _FuB9JY[_Z01y1h("6874")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.HealthTextESP then for _,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6874")]) do _gopMIC.Visible=false end;return end
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); local _ppaT31=_PVGEO2:FindFirstChildOfClass(_Z01y1h("48756d616e6f6964")); if not _H5F2gJ[_Z01y1h("6874")][p] then local _gopMIC=Drawing.new(_Z01y1h("54657874"));_gopMIC.Visible=false;_gopMIC.Center=true;_gopMIC.Outline=true;_gopMIC.OutlineColor=Color3.new(0,0,0);_gopMIC.ZIndex=5;_H5F2gJ[_Z01y1h("6874")][p]=_gopMIC end; local _gopMIC=_H5F2gJ[_Z01y1h("6874")][p]; if _mrnURO and _ppaT31 then local _2Es0qW,on,_xrvVPq=W2S(_mrnURO.Position+Vector3.new(0,2.4,0)); if on and _xrvVPq>0 then local _oHdw6m=math.clamp(_ppaT31.Health/_ppaT31.MaxHealth,0,1); _gopMIC.Text=_Z01y1h("5b")..math.floor(_ppaT31.Health).._Z01y1h("2f")..math.floor(_ppaT31.MaxHealth).._Z01y1h("2048505d"); _gopMIC.Position=Vector2.new(_2Es0qW.X,_2Es0qW.Y+_RwWy08.HealthTextSize+2); _gopMIC.Color=Color3.fromRGB(255*(1-_oHdw6m),255*_oHdw6m,0); _gopMIC.Size=_RwWy08.HealthTextSize; _gopMIC.Visible=true else _gopMIC.Visible=false end else _gopMIC.Visible=false end end end
        for p,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6874")]) do if not _riGHql[p] then _gopMIC.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("6874")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6874")] and _H5F2gJ[_Z01y1h("6874")][p] then pcall(function() _H5F2gJ[_Z01y1h("6874")][p]:Remove() end);_H5F2gJ[_Z01y1h("6874")][p]=nil end end)
end
function _7fw9T4:Disable() SafeDisconnect(_Z01y1h("6874")); if _H5F2gJ[_Z01y1h("6874")] then for _,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6874")]) do pcall(function() _gopMIC:Remove() end) end;_H5F2gJ[_Z01y1h("6874")]=nil end end

-- DISTANCE ESP
local _qPyLi8={}
function _qPyLi8:Enable()
    if _FuB9JY[_Z01y1h("6474")] then return end; _H5F2gJ[_Z01y1h("6474")]={};_FuB9JY[_Z01y1h("6474")]={}
    _FuB9JY[_Z01y1h("6474")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.DistanceESP then for _,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6474")]) do _gopMIC.Visible=false end;return end
        local _lOhcZT=_mJKyvo.Character and _mJKyvo.Character:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); local _7I24pc=_PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); if not _H5F2gJ[_Z01y1h("6474")][p] then local _gopMIC=Drawing.new(_Z01y1h("54657874"));_gopMIC.Visible=false;_gopMIC.Center=true;_gopMIC.Outline=true;_gopMIC.OutlineColor=Color3.new(0,0,0);_gopMIC.ZIndex=5;_H5F2gJ[_Z01y1h("6474")][p]=_gopMIC end; local _gopMIC=_H5F2gJ[_Z01y1h("6474")][p]; if _mrnURO and _7I24pc then local _2Es0qW,on,_xrvVPq=W2S(_mrnURO.Position+Vector3.new(0,2.4,0)); if on and _xrvVPq>0 then local _puQMTG=_lOhcZT and math.floor((_lOhcZT.Position-_7I24pc.Position).Magnitude) or 0; local _N7pU5Q=_RwWy08.HealthTextESP and (_RwWy08.HealthTextSize*2+4) or (_RwWy08.NameESP and _RwWy08.NameSize+2 or 0); _gopMIC.Text=_Z01y1h("5b").._puQMTG.._Z01y1h("6d5d"); _gopMIC.Position=Vector2.new(_2Es0qW.X,_2Es0qW.Y+_RwWy08.DistanceSize+_N7pU5Q); _gopMIC.Color=Color3.fromRGB(180,220,255); _gopMIC.Size=_RwWy08.DistanceSize; _gopMIC.Visible=true else _gopMIC.Visible=false end else _gopMIC.Visible=false end end end
        for p,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6474")]) do if not _riGHql[p] then _gopMIC.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("6474")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6474")] and _H5F2gJ[_Z01y1h("6474")][p] then pcall(function() _H5F2gJ[_Z01y1h("6474")][p]:Remove() end);_H5F2gJ[_Z01y1h("6474")][p]=nil end end)
end
function _qPyLi8:Disable() SafeDisconnect(_Z01y1h("6474")); if _H5F2gJ[_Z01y1h("6474")] then for _,_gopMIC in pairs(_H5F2gJ[_Z01y1h("6474")]) do pcall(function() _gopMIC:Remove() end) end;_H5F2gJ[_Z01y1h("6474")]=nil end end

-- HEALTH BAR
local _OxLMdM={}
function _OxLMdM:Enable()
    if _FuB9JY[_Z01y1h("6862")] then return end; _H5F2gJ[_Z01y1h("6862")]={};_FuB9JY[_Z01y1h("6862")]={}
    _FuB9JY[_Z01y1h("6862")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.HealthBar then for _,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6862")]) do _xrvVPq.o.Visible=false;_xrvVPq.bg.Visible=false;_xrvVPq.bar.Visible=false end;return end
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _7I24pc=_PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); local _ppaT31=_PVGEO2:FindFirstChildOfClass(_Z01y1h("48756d616e6f6964")); if not _H5F2gJ[_Z01y1h("6862")][p] then local _xrvVPq={}; _xrvVPq.o=Drawing.new(_Z01y1h("537175617265"));_xrvVPq.o.Filled=true;_xrvVPq.o.Color=Color3.new(0,0,0);_xrvVPq.o.Visible=false;_xrvVPq.o.ZIndex=1; _xrvVPq.bg=Drawing.new(_Z01y1h("537175617265"));_xrvVPq.bg.Filled=true;_xrvVPq.bg.Color=Color3.fromRGB(40,40,40);_xrvVPq.bg.Visible=false;_xrvVPq.bg.ZIndex=2; _xrvVPq.bar=Drawing.new(_Z01y1h("537175617265"));_xrvVPq.bar.Filled=true;_xrvVPq.bar.Visible=false;_xrvVPq.bar.ZIndex=3; _H5F2gJ[_Z01y1h("6862")][p]=_xrvVPq end; local _xrvVPq=_H5F2gJ[_Z01y1h("6862")][p]; if _7I24pc and _mrnURO and _ppaT31 then local _hmk8Qn,ton,tz=W2S(_mrnURO.Position+Vector3.new(0,1,0)); local _kNhOwd,bon,bz=W2S(_7I24pc.Position-Vector3.new(0,3,0)); if ton and bon and tz>0 and bz>0 then local _sEBRqI=math.abs(_kNhOwd.Y-_hmk8Qn.Y);local _7A0zxX=_sEBRqI/1.8;local _NzIsBt=4;local _zxpZkP=math.floor(_hmk8Qn.X-_7A0zxX/2-_NzIsBt-4);local _FrhdVr=math.floor(_hmk8Qn.Y); local _oHdw6m=math.clamp(_ppaT31.Health/_ppaT31.MaxHealth,0,1);local _f0nz9y=math._EqBg5P(math.floor(_sEBRqI*_oHdw6m),1);local _b4zvoL=Color3.fromRGB(255*(1-_oHdw6m),255*_oHdw6m,0); _xrvVPq.o.Size=Vector2.new(_NzIsBt+2,math.floor(_sEBRqI)+2);_xrvVPq.o.Position=Vector2.new(_zxpZkP-1,_FrhdVr-1);_xrvVPq.o.Visible=true; _xrvVPq.bg.Size=Vector2.new(_NzIsBt,math.floor(_sEBRqI));_xrvVPq.bg.Position=Vector2.new(_zxpZkP,_FrhdVr);_xrvVPq.bg.Visible=true; _xrvVPq.bar.Size=Vector2.new(_NzIsBt,_f0nz9y);_xrvVPq.bar.Position=Vector2.new(_zxpZkP,_FrhdVr+math.floor(_sEBRqI)-_f0nz9y);_xrvVPq.bar.Color=_b4zvoL;_xrvVPq.bar.Visible=true else _xrvVPq.o.Visible=false;_xrvVPq.bg.Visible=false;_xrvVPq.bar.Visible=false end else _xrvVPq.o.Visible=false;_xrvVPq.bg.Visible=false;_xrvVPq.bar.Visible=false end end end
        for p,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6862")]) do if not _riGHql[p] then _xrvVPq.o.Visible=false;_xrvVPq.bg.Visible=false;_xrvVPq.bar.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("6862")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6862")] and _H5F2gJ[_Z01y1h("6862")][p] then pcall(function() _H5F2gJ[_Z01y1h("6862")][p].o:Remove() end);pcall(function() _H5F2gJ[_Z01y1h("6862")][p].bg:Remove() end);pcall(function() _H5F2gJ[_Z01y1h("6862")][p].bar:Remove() end);_H5F2gJ[_Z01y1h("6862")][p]=nil end end)
end
function _OxLMdM:Disable() SafeDisconnect(_Z01y1h("6862")); if _H5F2gJ[_Z01y1h("6862")] then for _,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6862")]) do pcall(function() _xrvVPq.o:Remove() end);pcall(function() _xrvVPq.bg:Remove() end);pcall(function() _xrvVPq.bar:Remove() end) end;_H5F2gJ[_Z01y1h("6862")]=nil end end

-- LOOK DIRECTION ESP
local _ZiBruz={}
local function GetLookDot(eHRP,mHRP) if not eHRP or not mHRP then return 0 end; local _lNAfIs=(mHRP.Position-eHRP.Position); local _sKywSR=_lNAfIs.Magnitude; if _sKywSR<0.001 then return 0 end; _lNAfIs=_lNAfIs/_sKywSR; local _kmMf9H=eHRP.CFrame.LookVector; return _kmMf9H.X*_lNAfIs.X+_kmMf9H.Z*_lNAfIs.Z end
local function DotToCol(_H9Io5H) if _H9Io5H>0.6 then return Color3.fromRGB(255,50,50) elseif _H9Io5H>0.1 then local _gopMIC=(_H9Io5H-0.1)/0.5; return Color3.fromRGB(255,math.floor(255*(1-_gopMIC)),50) else return Color3.fromRGB(80,220,80) end end
function _ZiBruz:Enable()
    if _FuB9JY[_Z01y1h("6c64")] then return end; _H5F2gJ[_Z01y1h("6c64")]={};_FuB9JY[_Z01y1h("6c64")]={}
    _FuB9JY[_Z01y1h("6c64")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.LookDirectionESP then for _,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6c64")]) do _xrvVPq.line.Visible=false;_xrvVPq.tip1.Visible=false;_xrvVPq.tip2.Visible=false;if _xrvVPq.label then _xrvVPq.label.Visible=false end end;return end
        local _oIGyOc=_mJKyvo.Character; local _WX594u=_oIGyOc and _oIGyOc:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do
            if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then
                _riGHql[p]=true; local _PVGEO2=p.Character; local _mrnURO=_PVGEO2:FindFirstChild(_Z01y1h("48656164")); local _7I24pc=_PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); if not _mrnURO or not _7I24pc then continue end
                if not _H5F2gJ[_Z01y1h("6c64")][p] then local _xrvVPq={}; _xrvVPq.line=Drawing.new(_Z01y1h("4c696e65"));_xrvVPq.line.Visible=false;_xrvVPq.line.Transparency=1;_xrvVPq.line.ZIndex=6; _xrvVPq.tip1=Drawing.new(_Z01y1h("4c696e65"));_xrvVPq.tip1.Visible=false;_xrvVPq.tip1.Transparency=1;_xrvVPq.tip1.ZIndex=6; _xrvVPq.tip2=Drawing.new(_Z01y1h("4c696e65"));_xrvVPq.tip2.Visible=false;_xrvVPq.tip2.Transparency=1;_xrvVPq.tip2.ZIndex=6; _xrvVPq.label=Drawing.new(_Z01y1h("54657874"));_xrvVPq.label.Visible=false;_xrvVPq.label.Center=false;_xrvVPq.label.Outline=true;_xrvVPq.label.OutlineColor=Color3.new(0,0,0);_xrvVPq.label.Size=10;_xrvVPq.label.ZIndex=7; _H5F2gJ[_Z01y1h("6c64")][p]=_xrvVPq end
                local _xrvVPq=_H5F2gJ[_Z01y1h("6c64")][p]; local _fRwerp=_mrnURO.Position+Vector3.new(0,0.8,0); local _1y6P4i,onS,dep=W2S(_fRwerp)
--[[ PROTECTED | OWNER: LippTz | 2026-03-24 ]]
                if not onS or dep<=0 then _xrvVPq.line.Visible=false;_xrvVPq.tip1.Visible=false;_xrvVPq.tip2.Visible=false;_xrvVPq.label.Visible=false;continue end
                local _DEKqjV=_WX594u and (_WX594u.Position-_7I24pc.Position).Magnitude or 10; local _pLsYJe=math._EqBg5P(2,_DEKqjV*0.08); local _kmMf9H=_7I24pc.CFrame.LookVector; local _tr0gdZ=_fRwerp+_kmMf9H*_pLsYJe; local _jYNe5F,tipOn=W2S(_tr0gdZ)
                if not tipOn then local _9hGCyJ=_jYNe5F-_1y6P4i; local _sKywSR=_9hGCyJ.Magnitude; if _sKywSR>0.1 then _jYNe5F=_1y6P4i+(_9hGCyJ/_sKywSR)*_RwWy08.LookDirectionLength end else local _9hGCyJ=_jYNe5F-_1y6P4i; local _sKywSR=_9hGCyJ.Magnitude; local _MTqbpM=_RwWy08.LookDirectionLength; if _sKywSR>_MTqbpM then _jYNe5F=_1y6P4i+(_9hGCyJ/_sKywSR)*_MTqbpM end; if _sKywSR<8 then _jYNe5F=_sKywSR<0.1 and _1y6P4i+Vector2.new(0,-_MTqbpM) or _1y6P4i+(_9hGCyJ/_sKywSR)*8 end end
                local _H9Io5H=GetLookDot(_7I24pc,_WX594u); local _b4zvoL=DotToCol(_H9Io5H)
                _xrvVPq.line.From=_1y6P4i;_xrvVPq.line.To=_jYNe5F;_xrvVPq.line.Color=_b4zvoL;_xrvVPq.line.Thickness=_RwWy08.LookDirectionThickness;_xrvVPq.line.Visible=true
                local _KTSRv6=_jYNe5F-_1y6P4i; local _clDI3s=_KTSRv6.Magnitude
                if _clDI3s>2 then local _C0qVO9=_KTSRv6/_clDI3s; local _eIK4Gb=Vector2.new(-_C0qVO9.Y,_C0qVO9.X); local _haSZmQ=math.clamp(_RwWy08.LookDirectionLength*0.28,5,12); local _zahUVA=_jYNe5F-_C0qVO9*_haSZmQ; _xrvVPq.tip1.From=_jYNe5F;_xrvVPq.tip1.To=_zahUVA+_eIK4Gb*_haSZmQ*0.6;_xrvVPq.tip1.Color=_b4zvoL;_xrvVPq.tip1.Thickness=_RwWy08.LookDirectionThickness;_xrvVPq.tip1.Visible=true; _xrvVPq.tip2.From=_jYNe5F;_xrvVPq.tip2.To=_zahUVA-_eIK4Gb*_haSZmQ*0.6;_xrvVPq.tip2.Color=_b4zvoL;_xrvVPq.tip2.Thickness=_RwWy08.LookDirectionThickness;_xrvVPq.tip2.Visible=true else _xrvVPq.tip1.Visible=false;_xrvVPq.tip2.Visible=false end
                if _RwWy08.LookDirectionShowAngle then local _kwaaol=math.floor(math.acos(math.clamp(_H9Io5H,-1,1))*(180/math.pi)); _xrvVPq.label.Text=_kwaaol.._Z01y1h("b0"); _xrvVPq.label.Position=_jYNe5F+Vector2.new(4,-6); _xrvVPq.label.Color=_b4zvoL; _xrvVPq.label.Visible=true else _xrvVPq.label.Visible=false end
            end
        end
        for p,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6c64")]) do if not _riGHql[p] then _xrvVPq.line.Visible=false;_xrvVPq.tip1.Visible=false;_xrvVPq.tip2.Visible=false;_xrvVPq.label.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("6c64")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) if _H5F2gJ[_Z01y1h("6c64")] and _H5F2gJ[_Z01y1h("6c64")][p] then pcall(function() _H5F2gJ[_Z01y1h("6c64")][p].line:Remove() end);pcall(function() _H5F2gJ[_Z01y1h("6c64")][p].tip1:Remove() end);pcall(function() _H5F2gJ[_Z01y1h("6c64")][p].tip2:Remove() end);pcall(function() _H5F2gJ[_Z01y1h("6c64")][p].label:Remove() end);_H5F2gJ[_Z01y1h("6c64")][p]=nil end end)
end
function _ZiBruz:Disable() SafeDisconnect(_Z01y1h("6c64")); if _H5F2gJ[_Z01y1h("6c64")] then for _,_xrvVPq in pairs(_H5F2gJ[_Z01y1h("6c64")]) do pcall(function() _xrvVPq.line:Remove() end);pcall(function() _xrvVPq.tip1:Remove() end);pcall(function() _xrvVPq.tip2:Remove() end);pcall(function() _xrvVPq.label:Remove() end) end;_H5F2gJ[_Z01y1h("6c64")]=nil end end

-- CHAMS
local _LOfTDJ={}
local _O17fy9={}
function _LOfTDJ:Apply(plr) if _O17fy9[plr] then return end; local _PVGEO2=plr.Character; if not _PVGEO2 then return end; local _aRhHiM=Instance.new(_Z01y1h("486967686c69676874")); _aRhHiM.Name=_Z01y1h("4b7265696e4368616d73"); _aRhHiM.FillColor=_RwWy08.ChamsFillColor; _aRhHiM.OutlineColor=_RwWy08.ChamsOutlineColor; _aRhHiM.FillTransparency=_RwWy08.ChamsFillTransparency; _aRhHiM.OutlineTransparency=_RwWy08.ChamsOutlineTransparency; _aRhHiM.DepthMode=_RwWy08.ChamsWallCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop; _aRhHiM.Adornee=_PVGEO2; _aRhHiM.Parent=_PVGEO2; _O17fy9[plr]=_aRhHiM end
function _LOfTDJ:Remove(plr) if _O17fy9[plr] then pcall(function() _O17fy9[plr]:Destroy() end);_O17fy9[plr]=nil end end
function _LOfTDJ:UpdateAll() for _,_aRhHiM in pairs(_O17fy9) do pcall(function() _aRhHiM.FillColor=_RwWy08.ChamsFillColor;_aRhHiM.OutlineColor=_RwWy08.ChamsOutlineColor;_aRhHiM.FillTransparency=_RwWy08.ChamsFillTransparency;_aRhHiM.OutlineTransparency=_RwWy08.ChamsOutlineTransparency;_aRhHiM.DepthMode=_RwWy08.ChamsWallCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop end) end end
function _LOfTDJ:Enable()
    if _FuB9JY[_Z01y1h("6368")] then return end; _FuB9JY[_Z01y1h("6368")]={}
    for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then self:Apply(p) end end
    _FuB9JY[_Z01y1h("6368")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.ChamsEnabled then for p in pairs(_O17fy9) do self:Remove(p) end;return end
        local _kzqP4d={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _kzqP4d[p]=true; if not _O17fy9[p] then self:Apply(p) end; local _aRhHiM=_O17fy9[p]; if _aRhHiM and _aRhHiM.Adornee~=p.Character then _aRhHiM.Adornee=p.Character;_aRhHiM.Parent=p.Character end end end
        for p in pairs(_O17fy9) do if not _kzqP4d[p] then self:Remove(p) end end
    end)
    _FuB9JY[_Z01y1h("6368")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) self:Remove(p) end)
    _FuB9JY[_Z01y1h("6368")].ca={}
    for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo then _FuB9JY[_Z01y1h("6368")].ca[p]=p.CharacterAdded:Connect(function() task.wait(0.5); if _RwWy08.ChamsEnabled and IsEnemy(p,_RwWy08.TeamCheck) then self:Remove(p);self:Apply(p) end end) end end
    _FuB9JY[_Z01y1h("6368")].pa=_rg1QvR.PlayerAdded:Connect(function(p) if p==_mJKyvo then return end; _FuB9JY[_Z01y1h("6368")].ca[p]=p.CharacterAdded:Connect(function() task.wait(0.5); if _RwWy08.ChamsEnabled and IsEnemy(p,_RwWy08.TeamCheck) then self:Remove(p);self:Apply(p) end end) end)
end
function _LOfTDJ:Disable() for p in pairs(_O17fy9) do self:Remove(p) end; if _FuB9JY[_Z01y1h("6368")] and _FuB9JY[_Z01y1h("6368")].ca then for _,_PVGEO2 in pairs(_FuB9JY[_Z01y1h("6368")].ca) do pcall(function() _PVGEO2:Disconnect() end) end end; SafeDisconnect(_Z01y1h("6368")) end

-- RADAR 2D
local _t8hktD={}
local _7TRzV5,RadarBg,RadarDots,RadarLines=nil,nil,{},{}
local function MkDot(_b4zvoL,sz) local _xrvVPq=Instance.new(_Z01y1h("4672616d65"));_xrvVPq.Size=UDim2.fromOffset(sz,sz);_xrvVPq.AnchorPoint=Vector2.new(0.5,0.5);_xrvVPq.BackgroundColor3=_b4zvoL;_xrvVPq.BorderSizePixel=0;_xrvVPq.ZIndex=12;Instance.new(_Z01y1h("5549436f726e6572"),_xrvVPq).CornerRadius=UDim.new(1,0);local _HqmLIq=Instance.new(_Z01y1h("55495374726f6b65"),_xrvVPq);_HqmLIq.Thickness=1;_HqmLIq.Color=Color3.new(0,0,0);_HqmLIq.Transparency=0.3;return _xrvVPq end
function _t8hktD:Build()
    if _7TRzV5 then return end; local _Vcq0e5=_mJKyvo:WaitForChild(_Z01y1h("506c61796572477569"))
    _7TRzV5=Instance.new(_Z01y1h("53637265656e477569"));_7TRzV5.Name=_Z01y1h("4b7265696e5261646172");_7TRzV5.ResetOnSpawn=false;_7TRzV5.IgnoreGuiInset=true;_7TRzV5.DisplayOrder=998;_7TRzV5.Parent=_Vcq0e5
    local _xRhdxU=_RwWy08.RadarSize; local _OpyQFn=Instance.new(_Z01y1h("4672616d65"));_OpyQFn.Size=UDim2.fromOffset(_xRhdxU+24,_xRhdxU+24);_OpyQFn.Position=UDim2.fromOffset(_RwWy08.RadarX,_RwWy08.RadarY);_OpyQFn.BackgroundTransparency=1;_OpyQFn.BorderSizePixel=0;_OpyQFn.ZIndex=9;_OpyQFn.Parent=_7TRzV5
    RadarBg=Instance.new(_Z01y1h("4672616d65"));RadarBg.Size=UDim2.fromOffset(_xRhdxU,_xRhdxU);RadarBg.Position=UDim2.fromOffset(12,12);RadarBg.BackgroundColor3=Color3.fromRGB(8,8,8);RadarBg.BackgroundTransparency=0.25;RadarBg.BorderSizePixel=0;RadarBg.ZIndex=10;RadarBg.ClipsDescendants=true;Instance.new(_Z01y1h("5549436f726e6572"),RadarBg).CornerRadius=UDim.new(1,0);RadarBg.Parent=_OpyQFn
    local _HDTThd=Instance.new(_Z01y1h("55495374726f6b65"),RadarBg);_HDTThd.Thickness=1.5;_HDTThd.Color=Color3.fromRGB(160,160,160);_HDTThd.Transparency=0.1
    local _j0njaM=Instance.new(_Z01y1h("4672616d65"),RadarBg);_j0njaM.Size=UDim2.new(1,0,0,1);_j0njaM.Position=UDim2.new(0,0,0.5,0);_j0njaM.BackgroundColor3=Color3.fromRGB(255,255,255);_j0njaM.BackgroundTransparency=0.82;_j0njaM.BorderSizePixel=0;_j0njaM.ZIndex=11
    local _0idy1A=Instance.new(_Z01y1h("4672616d65"),RadarBg);_0idy1A.Size=UDim2.new(0,1,1,0);_0idy1A.Position=UDim2.new(0.5,0,0,0);_0idy1A.BackgroundColor3=Color3.fromRGB(255,255,255);_0idy1A.BackgroundTransparency=0.82;_0idy1A.BorderSizePixel=0;_0idy1A.ZIndex=11
    local _raHbRs=Instance.new(_Z01y1h("4672616d65"),RadarBg);_raHbRs.Size=UDim2.new(0.5,0,0.5,0);_raHbRs.AnchorPoint=Vector2.new(0.5,0.5);_raHbRs.Position=UDim2.new(0.5,0,0.5,0);_raHbRs.BackgroundTransparency=1;_raHbRs.BorderSizePixel=0;_raHbRs.ZIndex=11;Instance.new(_Z01y1h("5549436f726e6572"),_raHbRs).CornerRadius=UDim.new(1,0);local _CPG3cZ=Instance.new(_Z01y1h("55495374726f6b65"),_raHbRs);_CPG3cZ.Thickness=0.5;_CPG3cZ.Color=Color3.fromRGB(255,255,255);_CPG3cZ.Transparency=0.75
    local _dwfxfg=MkDot(Color3.fromRGB(255,255,255),8);_dwfxfg.Position=UDim2.new(0.5,0,0.5,0);_dwfxfg.ZIndex=14;_dwfxfg.Parent=RadarBg
    local _Ree8zW=Instance.new(_Z01y1h("546578744c6162656c"),RadarBg);_Ree8zW.Size=UDim2.fromOffset(30,10);_Ree8zW.AnchorPoint=Vector2.new(0.5,0.5);_Ree8zW.Position=UDim2.new(0.75,0,0.5,0);_Ree8zW.BackgroundTransparency=1;_Ree8zW.Text=math.floor(_RwWy08.RadarRange*0.5).._Z01y1h("6d");_Ree8zW.TextColor3=Color3.fromRGB(180,180,180);_Ree8zW.TextTransparency=0.3;_Ree8zW.TextSize=7;_Ree8zW.Font=Enum.Font.Gotham;_Ree8zW.ZIndex=12;RadarLines._w0uL14=_Ree8zW
    local _tGDN9k=Instance.new(_Z01y1h("546578744c6162656c"),RadarBg);_tGDN9k.Size=UDim2.fromOffset(30,10);_tGDN9k.AnchorPoint=Vector2.new(1,0.5);_tGDN9k.Position=UDim2.new(1,-4,0.5,0);_tGDN9k.BackgroundTransparency=1;_tGDN9k.Text=_RwWy08.RadarRange.._Z01y1h("6d");_tGDN9k.TextColor3=Color3.fromRGB(140,140,140);_tGDN9k.TextTransparency=0.4;_tGDN9k.TextSize=7;_tGDN9k.Font=Enum.Font.Gotham;_tGDN9k.ZIndex=12;RadarLines.full=_tGDN9k
end
function _t8hktD:GetDot(plr)
    if not RadarDots[plr] then local _H9Io5H=MkDot(Color3.fromRGB(255,60,60),7);_H9Io5H.Visible=false;_H9Io5H.Parent=RadarBg; local _vRSH54=Instance.new(_Z01y1h("546578744c6162656c"),RadarBg);_vRSH54.Size=UDim2.fromOffset(60,12);_vRSH54.AnchorPoint=Vector2.new(0,0.5);_vRSH54.BackgroundTransparency=1;_vRSH54.Text=plr.Name;_vRSH54.TextColor3=Color3.fromRGB(255,220,220);_vRSH54.TextSize=8;_vRSH54.Font=Enum.Font.Gotham;_vRSH54.TextXAlignment=Enum.TextXAlignment.Left;_vRSH54.ZIndex=15;_vRSH54.Visible=false; RadarDots[plr]={_H9Io5H=_H9Io5H,_vRSH54=_vRSH54} end; return RadarDots[plr]
end
function _t8hktD:RmDot(plr) if RadarDots[plr] then pcall(function() RadarDots[plr]._H9Io5H:Destroy() end);pcall(function() RadarDots[plr]._vRSH54:Destroy() end);RadarDots[plr]=nil end end
function _t8hktD:Enable()
    if _FuB9JY[_Z01y1h("7264")] then return end; self:Build(); _FuB9JY[_Z01y1h("7264")]={}
    _FuB9JY[_Z01y1h("7264")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.RadarEnabled or not _7TRzV5 then if RadarBg then RadarBg.Visible=false end;return end
        RadarBg.Visible=true; local _oIGyOc=_mJKyvo.Character; local _WX594u=_oIGyOc and _oIGyOc:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); if not _WX594u then return end
        local _xRhdxU=_RwWy08.RadarSize; local _wYCgG2=_RwWy08.RadarRange; local _w0uL14=_xRhdxU/2
        if RadarLines._w0uL14 then RadarLines._w0uL14.Text=math.floor(_wYCgG2*0.5).._Z01y1h("6d") end; if RadarLines.full then RadarLines.full.Text=_wYCgG2.._Z01y1h("6d") end
        local _pDe0nE=workspace.CurrentCamera; local _kmMf9H=_pDe0nE.CFrame.LookVector; local _7kK6lK,fZ=_kmMf9H.X,_kmMf9H.Z; local _y3ZLvC=math.sqrt(_7kK6lK*_7kK6lK+fZ*fZ); if _y3ZLvC<0.001 then _y3ZLvC=0.001 end; _7kK6lK=_7kK6lK/_y3ZLvC;fZ=fZ/_y3ZLvC; local _Dq74OV,rZ=fZ,-_7kK6lK
        local _riGHql={}
        for _,p in ipairs(_rg1QvR:GetPlayers()) do if p~=_mJKyvo and IsAlive(p) and IsEnemy(p,_RwWy08.TeamCheck) then _riGHql[p]=true; local _PVGEO2=p.Character; local _7I24pc=_PVGEO2 and _PVGEO2:FindFirstChild(_Z01y1h("48756d616e6f6964526f6f7450617274")); if _7I24pc then local _CQyhNU=self:GetDot(p); local _tYjkx2=_7I24pc.Position-_WX594u.Position; local _PYmW9j,wZ=_tYjkx2.X,_tYjkx2.Z; local _WXrtZG=_PYmW9j*_7kK6lK+wZ*fZ; local _Ws93ZY=_PYmW9j*_Dq74OV+wZ*rZ; local _r1U553=_w0uL14-(_Ws93ZY/_wYCgG2)*_w0uL14; local _qBlvUm=_w0uL14-(_WXrtZG/_wYCgG2)*_w0uL14; local _VJ4DzC=_r1U553-_w0uL14;local _SXcIUY=_qBlvUm-_w0uL14;local _cLQXtV=math.sqrt(_VJ4DzC*_VJ4DzC+_SXcIUY*_SXcIUY); if _cLQXtV>_w0uL14-5 then local _Sq5u2j=(_w0uL14-5)/_cLQXtV;_r1U553=_w0uL14+_VJ4DzC*_Sq5u2j;_qBlvUm=_w0uL14+_SXcIUY*_Sq5u2j end; _CQyhNU._H9Io5H.Position=UDim2.fromOffset(_r1U553,_qBlvUm); local _5geoUp=_PVGEO2:FindFirstChildOfClass(_Z01y1h("48756d616e6f6964")); if _5geoUp then local _oHdw6m=math.clamp(_5geoUp.Health/_5geoUp.MaxHealth,0,1); _CQyhNU._H9Io5H.BackgroundColor3=Color3.fromRGB(255,math.floor(_oHdw6m*180),50) end; _CQyhNU._H9Io5H.Visible=true; local _kCLeob=(_7I24pc.Position-_WX594u.Position).Magnitude; if _kCLeob<_wYCgG2*0.6 then _CQyhNU._vRSH54.Position=UDim2.fromOffset(_r1U553+6,_qBlvUm);_CQyhNU._vRSH54.Visible=true else _CQyhNU._vRSH54.Visible=false end end end end
        for p,_CQyhNU in pairs(RadarDots) do if not _riGHql[p] then _CQyhNU._H9Io5H.Visible=false;_CQyhNU._vRSH54.Visible=false end end
    end)
    _FuB9JY[_Z01y1h("7264")].rm=_rg1QvR.PlayerRemoving:Connect(function(p) self:RmDot(p) end)
end
function _t8hktD:Destroy() SafeDisconnect(_Z01y1h("7264")); for p in pairs(RadarDots) do self:RmDot(p) end; RadarDots={}; if _7TRzV5 then pcall(function() _7TRzV5:Destroy() end);_7TRzV5=nil;RadarBg=nil end end

-- AIMBOT
local _MT06lJ=0
local _yTL2db={Q=Enum.KeyCode.Q,E=Enum.KeyCode.E,R=Enum.KeyCode.R,F=Enum.KeyCode.F,Z=Enum.KeyCode.Z,X=Enum.KeyCode.X,C=Enum.KeyCode.C,V=Enum.KeyCode.V,G=Enum.KeyCode.G,H=Enum.KeyCode.H,LeftShift=Enum.KeyCode.LeftShift,RightShift=Enum.KeyCode.RightShift,LeftControl=Enum.KeyCode.LeftControl,LeftAlt=Enum.KeyCode.LeftAlt}
function _Twp3ov:CancelLock() self.Locked=nil; if self.TweenAnim then pcall(function() self.TweenAnim:Cancel() end);self.TweenAnim=nil end end
function _Twp3ov:GetClosest() local _EqBg5P=_RwWy08.FOVEnabled and _RwWy08.FOVAmount or 9999; local _MUBNDJ,cy=Center(); local _p2U239=Vector2.new(_MUBNDJ,cy); local _zJ0jTY,bd=nil,_EqBg5P; local _hO7d5B=_mJKyvo.Character; for _,p in ipairs(_rg1QvR:GetPlayers()) do if p==_mJKyvo then continue end; if _RwWy08.AimbotAliveCheck and not IsAlive(p) then continue end; if _RwWy08.AimbotTeamCheck and not IsEnemy(p,true) then continue end; local _PVGEO2=p.Character; if not _PVGEO2 then continue end; local _si3q5v=_PVGEO2:FindFirstChild(_RwWy08.AimbotLockPart); if not _si3q5v then continue end; local _2Es0qW,on,_xrvVPq=W2S(_si3q5v.Position); if not on or _xrvVPq<=0 then continue end; if _RwWy08.AimbotWallCheck and WallBetween(workspace.CurrentCamera.CFrame.Position,_si3q5v.Position,{_hO7d5B,_PVGEO2}) then continue end; local _puQMTG=(_p2U239-_2Es0qW).Magnitude; if _puQMTG<bd then bd=_puQMTG;_zJ0jTY=p end end; return _zJ0jTY end
function _Twp3ov:Enable()
    if _FuB9JY[_Z01y1h("6162")] then return end; _FuB9JY[_Z01y1h("6162")]={}
    _FuB9JY[_Z01y1h("6162")]._7KrH1h=_E8bzIL.RenderStepped:Connect(function()
        if not _RwWy08.AimbotEnabled then if self.Locked then self:CancelLock() end;return end
        if _RwWy08.AimbotHoldKey then local _zOb8ve=_yTL2db[_RwWy08.AimbotHoldKeyBind]; if not(_zOb8ve and _wi49pD:IsKeyDown(_zOb8ve)) then if self.Locked then self:CancelLock() end;return end end
        local _pDe0nE=workspace.CurrentCamera; if not _pDe0nE then return end
        if self.Locked then local _OsDWZd=true; if not IsAlive(self.Locked) then _OsDWZd=false end; if _OsDWZd and _RwWy08.AimbotTeamCheck and not IsEnemy(self.Locked,true) then _OsDWZd=false end; if _OsDWZd then local _PVGEO2=self.Locked.Character; local _si3q5v=_PVGEO2 and _PVGEO2:FindFirstChild(_RwWy08.AimbotLockPart); if not _si3q5v then _OsDWZd=false else local _2Es0qW,on,_xrvVPq=W2S(_si3q5v.Position); if not on or _xrvVPq<=0 then _OsDWZd=false end; if _OsDWZd and _RwWy08.AimbotWallCheck then local _pWsBbu=_mJKyvo.Character; if WallBetween(_pDe0nE.CFrame.Position,_si3q5v.Position,{_pWsBbu,_PVGEO2}) then _OsDWZd=false end end; if _OsDWZd then local _MUBNDJ,cy=Center(); if (Vector2.new(_MUBNDJ,cy)-_2Es0qW).Magnitude>(_RwWy08.FOVEnabled and _RwWy08.FOVAmount*1.5 or 9999) then _OsDWZd=false end end end end; if not _OsDWZd then self:CancelLock() end end
        if not self.Locked then self.Locked=self:GetClosest() end
        if self.Locked then local _PVGEO2=self.Locked.Character; local _si3q5v=_PVGEO2 and _PVGEO2:FindFirstChild(_RwWy08.AimbotLockPart); if _si3q5v then local _LrXe51=PredictPos(self.Locked,_si3q5v); if _RwWy08.AimbotSensitivity>0 then if self.TweenAnim then pcall(function() self.TweenAnim:Cancel() end) end; self.TweenAnim=_5r2SJn:Create(_pDe0nE,TweenInfo.new(_RwWy08.AimbotSensitivity,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{CFrame=CFrame.new(_pDe0nE.CFrame.Position,_LrXe51)});self.TweenAnim:Play() else _pDe0nE.CFrame=CFrame.new(_pDe0nE.CFrame.Position,_LrXe51) end; if _RwWy08.AimbotAutoShoot and not _yia2Lk then local _2Es0qW,on=W2S(_si3q5v.Position); if on then local _MUBNDJ,cy=Center(); local _zmtTOE=tick(); if (Vector2.new(_MUBNDJ,cy)-_2Es0qW).Magnitude<15 and (_zmtTOE-_MT06lJ)>=_RwWy08.AimbotAutoShootDelay then _MT06lJ=_zmtTOE;pcall(function() mouse1press();task.wait();mouse1release() end) end end end end else _MT06lJ=tick() end
    end)
end
function _Twp3ov:Disable() self:CancelLock();SafeDisconnect(_Z01y1h("6162")) end

-- MISC
local _7THmYo={}
local function SL() local _6Rjx6r=game:GetService(_Z01y1h("4c69676874696e67")); _7THmYo.Brightness=_6Rjx6r.Brightness;_7THmYo.Ambient=_6Rjx6r.Ambient;_7THmYo.OutdoorAmbient=_6Rjx6r.OutdoorAmbient;_7THmYo.FogEnd=_6Rjx6r.FogEnd;_7THmYo.FogStart=_6Rjx6r.FogStart;_7THmYo.GlobalShadows=_6Rjx6r.GlobalShadows end; SL()
local function Fullbright(_Lv38ov) local _6Rjx6r=game:GetService(_Z01y1h("4c69676874696e67")); if _Lv38ov then _6Rjx6r.Brightness=2;_6Rjx6r.Ambient=Color3.fromRGB(178,178,178);_6Rjx6r.OutdoorAmbient=Color3.fromRGB(178,178,178) else _6Rjx6r.Brightness=_7THmYo.Brightness;_6Rjx6r.Ambient=_7THmYo.Ambient;_6Rjx6r.OutdoorAmbient=_7THmYo.OutdoorAmbient end end
local function NoFog(_Lv38ov) local _6Rjx6r=game:GetService(_Z01y1h("4c69676874696e67")); if _Lv38ov then _6Rjx6r.FogEnd=1e6;_6Rjx6r.FogStart=1e6 else _6Rjx6r.FogEnd=_7THmYo.FogEnd;_6Rjx6r.FogStart=_7THmYo.FogStart end end
local function NoShadow(_Lv38ov) game:GetService(_Z01y1h("4c69676874696e67")).GlobalShadows=not _Lv38ov end

local _qSVnzg={Red=Color3.fromRGB(255,50,50),Blue=Color3.fromRGB(50,120,255),Green=Color3.fromRGB(50,220,80),Yellow=Color3.fromRGB(255,230,50),Orange=Color3.fromRGB(255,140,30),Purple=Color3.fromRGB(180,60,255),White=Color3.fromRGB(255,255,255),Cyan=Color3.fromRGB(50,230,230),Black=Color3.fromRGB(0,0,0)}

-- ============================================================
-- GUI
-- ============================================================
local _gCJp7B = _WShBFb:CreateWindow({
    Title=_Z01y1h("4b7265696e41696d"), SubTitle=_Z01y1h("76362e30")..(_yia2Lk and _Z01y1h("205b4d6f62696c655d") or _Z01y1h("205b50435d")), ConfigName=_Z01y1h("4b7265696e41696d436667"),
})

-- ESP TAB
local _F9wQf8=_gCJp7B:CreateTab(_Z01y1h("455350"))
_F9wQf8:CreateSectionHeader(_Z01y1h("47656e6572616c"))
_F9wQf8:CreateToggle({Title=_Z01y1h("5465616d20436865636b"),Flag=_Z01y1h("5443"),Default=false,Callback=function(_Lv38ov) _RwWy08.TeamCheck=_Lv38ov end})
_F9wQf8:CreateSectionHeader(_Z01y1h("56697375616c"))
_F9wQf8:CreateToggle({Title=_Z01y1h("426f7820455350"),Flag=_Z01y1h("4258"),Default=false,Callback=function(_Lv38ov) _RwWy08.BoxESP=_Lv38ov; if _Lv38ov then _f4THjv:Enable() else _f4THjv:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("436f726e657220426f7820455350"),Flag=_Z01y1h("4342"),Default=false,Callback=function(_Lv38ov) _RwWy08.CornerBoxESP=_Lv38ov; if _Lv38ov then _xsTykg:Enable() else _xsTykg:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("536b656c65746f6e20455350"),Flag=_Z01y1h("534b"),Default=false,Callback=function(_Lv38ov) _RwWy08.SkeletonESP=_Lv38ov; if _Lv38ov then _B3kwKr:Enable() else _B3kwKr:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("54726163657220455350"),Flag=_Z01y1h("5452"),Default=false,Callback=function(_Lv38ov) _RwWy08.TracerESP=_Lv38ov; if _Lv38ov then _UNDjht:Enable() else _UNDjht:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("4865616c746820426172"),Flag=_Z01y1h("4842"),Default=false,Callback=function(_Lv38ov) _RwWy08.HealthBar=_Lv38ov; if _Lv38ov then _OxLMdM:Enable() else _OxLMdM:Disable() end end})
_F9wQf8:CreateSectionHeader(_Z01y1h("4368616d73"))
_F9wQf8:CreateToggle({Title=_Z01y1h("4368616d7320284f75746c696e65202b2046696c6c29"),Flag=_Z01y1h("4348"),Default=false,Callback=function(_Lv38ov) _RwWy08.ChamsEnabled=_Lv38ov; if _Lv38ov then _LOfTDJ:Enable() else _LOfTDJ:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("57616c6c20436865636b20284f63636c7564656429"),Flag=_Z01y1h("43485743"),Default=false,Callback=function(_Lv38ov) _RwWy08.ChamsWallCheck=_Lv38ov;_LOfTDJ:UpdateAll() end})
_F9wQf8:CreateSlider({Title=_Z01y1h("46696c6c205472616e73706172656e6379"),Flag=_Z01y1h("43484654"),Min=0,Max=10,Default=5,Callback=function(_Lv38ov) _RwWy08.ChamsFillTransparency=_Lv38ov/10;_LOfTDJ:UpdateAll() end})
_F9wQf8:CreateSlider({Title=_Z01y1h("4f75746c696e65205472616e73706172656e6379"),Flag=_Z01y1h("43484f54"),Min=0,Max=10,Default=0,Callback=function(_Lv38ov) _RwWy08.ChamsOutlineTransparency=_Lv38ov/10;_LOfTDJ:UpdateAll() end})
_F9wQf8:CreateDropdown({Title=_Z01y1h("46696c6c20436f6c6f72"),Flag=_Z01y1h("43484643"),Options={_Z01y1h("526564"),_Z01y1h("426c7565"),_Z01y1h("477265656e"),_Z01y1h("59656c6c6f77"),_Z01y1h("4f72616e6765"),_Z01y1h("507572706c65"),_Z01y1h("5768697465"),_Z01y1h("4379616e")},Default=_Z01y1h("526564"),Callback=function(_Lv38ov) _RwWy08.ChamsFillColor=_qSVnzg[_Lv38ov] or _qSVnzg.Red;_LOfTDJ:UpdateAll() end})
_F9wQf8:CreateDropdown({Title=_Z01y1h("4f75746c696e6520436f6c6f72"),Flag=_Z01y1h("43484f43"),Options={_Z01y1h("5768697465"),_Z01y1h("426c61636b"),_Z01y1h("526564"),_Z01y1h("426c7565"),_Z01y1h("477265656e"),_Z01y1h("59656c6c6f77"),_Z01y1h("4379616e")},Default=_Z01y1h("5768697465"),Callback=function(_Lv38ov) _RwWy08.ChamsOutlineColor=_qSVnzg[_Lv38ov] or _qSVnzg.White;_LOfTDJ:UpdateAll() end})
_F9wQf8:CreateSectionHeader(_Z01y1h("5261646172203244"))
_F9wQf8:CreateToggle({Title=_Z01y1h("5261646172203244"),Flag=_Z01y1h("5244"),Default=false,Callback=function(_Lv38ov) _RwWy08.RadarEnabled=_Lv38ov; if _Lv38ov then _t8hktD:Enable() end end})
_F9wQf8:CreateSlider({Title=_Z01y1h("52616461722053697a652028707829"),Flag=_Z01y1h("5244535a"),Min=100,Max=300,Default=180,Callback=function(_Lv38ov) _RwWy08.RadarSize=_Lv38ov; if _RwWy08.RadarEnabled then _t8hktD:Destroy();_t8hktD:Enable() end end})
_F9wQf8:CreateSlider({Title=_Z01y1h("52616461722052616e67652028737475647329"),Flag=_Z01y1h("5244524e47"),Min=50,Max=500,Default=150,Callback=function(_Lv38ov) _RwWy08.RadarRange=_Lv38ov end})
_F9wQf8:CreateSectionHeader(_Z01y1h("54657874"))
_F9wQf8:CreateToggle({Title=_Z01y1h("4e616d6520455350"),Flag=_Z01y1h("4e4d"),Default=false,Callback=function(_Lv38ov) _RwWy08.NameESP=_Lv38ov; if _Lv38ov then _tNQ4eD:Enable() else _tNQ4eD:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("4865616c7468205465787420455350"),Flag=_Z01y1h("4854"),Default=false,Callback=function(_Lv38ov) _RwWy08.HealthTextESP=_Lv38ov; if _Lv38ov then _7fw9T4:Enable() else _7fw9T4:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("44697374616e636520455350"),Flag=_Z01y1h("4454"),Default=false,Callback=function(_Lv38ov) _RwWy08.DistanceESP=_Lv38ov; if _Lv38ov then _qPyLi8:Enable() else _qPyLi8:Disable() end end})
_F9wQf8:CreateSectionHeader(_Z01y1h("4c6f6f6b20446972656374696f6e"))
_F9wQf8:CreateToggle({Title=_Z01y1h("4c6f6f6b20446972656374696f6e20455350"),Flag=_Z01y1h("4c44"),Default=false,Callback=function(_Lv38ov) _RwWy08.LookDirectionESP=_Lv38ov; if _Lv38ov then _ZiBruz:Enable() else _ZiBruz:Disable() end end})
_F9wQf8:CreateToggle({Title=_Z01y1h("53686f7720416e676c65"),Flag=_Z01y1h("4c44414e47"),Default=false,Callback=function(_Lv38ov) _RwWy08.LookDirectionShowAngle=_Lv38ov end})
_F9wQf8:CreateSlider({Title=_Z01y1h("4172726f77204c656e6774682028707829"),Flag=_Z01y1h("4c444c454e"),Min=10,Max=100,Default=40,Callback=function(_Lv38ov) _RwWy08.LookDirectionLength=_Lv38ov end})
_F9wQf8:CreateSlider({Title=_Z01y1h("546869636b6e6573732028707829"),Flag=_Z01y1h("4c445448"),Min=1,Max=4,Default=2,Callback=function(_Lv38ov) _RwWy08.LookDirectionThickness=_Lv38ov end})

-- AIMBOT TAB
local _2jIl50=_gCJp7B:CreateTab(_Z01y1h("41696d626f74"))
_2jIl50:CreateSectionHeader(_Z01y1h("41696d626f74"))
_2jIl50:CreateToggle({Title=_Z01y1h("456e61626c652041696d626f74"),Flag=_Z01y1h("414254"),Default=false,Callback=function(_Lv38ov) _RwWy08.AimbotEnabled=_Lv38ov; if _Lv38ov then _Twp3ov:Enable() else _Twp3ov:Disable() end end})
_2jIl50:CreateDropdown({Title=_Z01y1h("4c6f636b2050617274"),Flag=_Z01y1h("41424c50"),Options={_Z01y1h("48656164"),_Z01y1h("48756d616e6f6964526f6f7450617274"),_Z01y1h("5570706572546f72736f"),_Z01y1h("4c6f776572546f72736f"),_Z01y1h("546f72736f")},Default=_Z01y1h("48656164"),Callback=function(_Lv38ov) _RwWy08.AimbotLockPart=_Lv38ov;_Twp3ov:CancelLock() end})
_2jIl50:CreateSlider({Title=_Z01y1h("536d6f6f74686e657373"),Flag=_Z01y1h("4142534d"),Min=0,Max=100,Default=0,Callback=function(_Lv38ov) _RwWy08.AimbotSensitivity=_Lv38ov/200 end})
_2jIl50:CreateSectionHeader(_Z01y1h("50726564696374696f6e"))
_2jIl50:CreateToggle({Title=_Z01y1h("56656c6f636974792050726564696374696f6e"),Flag=_Z01y1h("41425052"),Default=false,Callback=function(_Lv38ov) _RwWy08.AimbotPrediction=_Lv38ov;_Zc9lVf={} end})
_2jIl50:CreateSlider({Title=_Z01y1h("50726564696374696f6e20537472656e677468"),Flag=_Z01y1h("41425053"),Min=1,Max=20,Default=5,Callback=function(_Lv38ov) _RwWy08.AimbotPredictionStrength=_Lv38ov/10 end})
_2jIl50:CreateSectionHeader(_Z01y1h("486f6c64204b6579")..(_yia2Lk and _Z01y1h("205b5043204f6e6c795d") or _Z01y1h("")))
_2jIl50:CreateToggle({Title=_Z01y1h("486f6c64204b6579204d6f6465")..(_yia2Lk and _Z01y1h("205b5043204f6e6c795d") or _Z01y1h("")),Flag=_Z01y1h("4142484b"),Default=false,Callback=function(_Lv38ov) if _Lv38ov and _yia2Lk then _RwWy08.AimbotHoldKey=false;_gCJp7B:Notify(_Z01y1h("486f6c64204b65793a205043204f6e6c7921"),3);return end; _RwWy08.AimbotHoldKey=_Lv38ov;_Twp3ov:CancelLock() end})
_2jIl50:CreateDropdown({Title=_Z01y1h("4b65792042696e64"),Flag=_Z01y1h("4142484b42"),Options={_Z01y1h("51"),_Z01y1h("45"),_Z01y1h("52"),_Z01y1h("46"),_Z01y1h("5a"),_Z01y1h("58"),_Z01y1h("43"),_Z01y1h("56"),_Z01y1h("47"),_Z01y1h("48"),_Z01y1h("4c6566745368696674"),_Z01y1h("52696768745368696674"),_Z01y1h("4c656674436f6e74726f6c"),_Z01y1h("4c656674416c74")},Default=_Z01y1h("51"),Callback=function(_Lv38ov) if _yia2Lk then _gCJp7B:Notify(_Z01y1h("4b65792042696e643a205043204f6e6c7921"),3);return end; _RwWy08.AimbotHoldKeyBind=_Lv38ov end})
_2jIl50:CreateSectionHeader(_Z01y1h("4175746f2053686f6f74")..(_yia2Lk and _Z01y1h("205b5043204f6e6c795d") or _Z01y1h("")))
_2jIl50:CreateToggle({Title=_Z01y1h("4175746f2053686f6f74")..(_yia2Lk and _Z01y1h("205b5043204f6e6c795d") or _Z01y1h("")),Flag=_Z01y1h("41424153"),Default=false,Callback=function(_Lv38ov) if _Lv38ov and _yia2Lk then _RwWy08.AimbotAutoShoot=false;_gCJp7B:Notify(_Z01y1h("4175746f2053686f6f743a205043204f6e6c7921"),3);return end; _RwWy08.AimbotAutoShoot=_Lv38ov end})
_2jIl50:CreateSlider({Title=_Z01y1h("53686f6f742044656c617920287831306d7329"),Flag=_Z01y1h("4142415344"),Min=5,Max=50,Default=10,Callback=function(_Lv38ov) _RwWy08.AimbotAutoShootDelay=_Lv38ov/100 end})
_2jIl50:CreateSectionHeader(_Z01y1h("436865636b73"))
_2jIl50:CreateToggle({Title=_Z01y1h("5465616d20436865636b"),Flag=_Z01y1h("41425443"),Default=false,Callback=function(_Lv38ov) _RwWy08.AimbotTeamCheck=_Lv38ov end})
_2jIl50:CreateToggle({Title=_Z01y1h("416c69766520436865636b"),Flag=_Z01y1h("41424143"),Default=true,Callback=function(_Lv38ov) _RwWy08.AimbotAliveCheck=_Lv38ov end})
_2jIl50:CreateToggle({Title=_Z01y1h("57616c6c20436865636b"),Flag=_Z01y1h("41425743"),Default=false,Callback=function(_Lv38ov) _RwWy08.AimbotWallCheck=_Lv38ov end})
_2jIl50:CreateSectionHeader(_Z01y1h("464f5620436972636c65"))
_2jIl50:CreateToggle({Title=_Z01y1h("464f5620436972636c65"),Flag=_Z01y1h("464f5645"),Default=true,Callback=function(_Lv38ov) _RwWy08.FOVEnabled=_Lv38ov end})
_2jIl50:CreateToggle({Title=_Z01y1h("56697369626c65"),Flag=_Z01y1h("464f5656"),Default=true,Callback=function(_Lv38ov) _RwWy08.FOVVisible=_Lv38ov end})
_2jIl50:CreateSlider({Title=_Z01y1h("5261646975732028707829"),Flag=_Z01y1h("464f5652"),Min=10,Max=500,Default=90,Callback=function(_Lv38ov) _RwWy08.FOVAmount=_Lv38ov end})
_2jIl50:CreateSlider({Title=_Z01y1h("546869636b6e6573732028707829"),Flag=_Z01y1h("464f5654"),Min=1,Max=5,Default=2,Callback=function(_Lv38ov) _RwWy08.FOVThickness=_Lv38ov end})

-- SETTINGS TAB
local _qzLEVV=_gCJp7B:CreateTab(_Z01y1h("53657474696e6773"))
_qzLEVV:CreateSectionHeader(_Z01y1h("426f78202620436f726e657220426f78"))
_qzLEVV:CreateSlider({Title=_Z01y1h("436f726e6572204c656e6774682028707829"),Flag=_Z01y1h("43424c"),Min=2,Max=20,Default=6,Callback=function(_Lv38ov) _RwWy08.CornerBoxLength=_Lv38ov end})
_qzLEVV:CreateSectionHeader(_Z01y1h("536b656c65746f6e"))
_qzLEVV:CreateSlider({Title=_Z01y1h("536b656c65746f6e20546869636b6e657373"),Flag=_Z01y1h("534b5448"),Min=1,Max=5,Default=2,Callback=function(_Lv38ov) _RwWy08.SkeletonThickness=_Lv38ov end})
_qzLEVV:CreateSectionHeader(_Z01y1h("547261636572"))
_qzLEVV:CreateSlider({Title=_Z01y1h("54726163657220546869636b6e657373"),Flag=_Z01y1h("54525448"),Min=1,Max=5,Default=1,Callback=function(_Lv38ov) _RwWy08.TracerThickness=_Lv38ov end})
_qzLEVV:CreateDropdown({Title=_Z01y1h("547261636572204f726967696e"),Flag=_Z01y1h("54524f52"),Options={_Z01y1h("426f74746f6d"),_Z01y1h("43656e746572"),_Z01y1h("546f70")},Default=_Z01y1h("426f74746f6d"),Callback=function(_Lv38ov) _RwWy08.TracerOrigin=_Lv38ov end})
_qzLEVV:CreateSectionHeader(_Z01y1h("54657874204553502053697a6573"))
_qzLEVV:CreateSlider({Title=_Z01y1h("4e616d652053697a652028707829"),Flag=_Z01y1h("4e4d535a"),Min=8,Max=24,Default=10,Callback=function(_Lv38ov) _RwWy08.NameSize=_Lv38ov end})
_qzLEVV:CreateSlider({Title=_Z01y1h("485020546578742053697a652028707829"),Flag=_Z01y1h("4854535a"),Min=8,Max=24,Default=10,Callback=function(_Lv38ov) _RwWy08.HealthTextSize=_Lv38ov end})
_qzLEVV:CreateSlider({Title=_Z01y1h("44697374616e63652053697a652028707829"),Flag=_Z01y1h("4454535a"),Min=8,Max=24,Default=10,Callback=function(_Lv38ov) _RwWy08.DistanceSize=_Lv38ov end})

-- MISC TAB
local _b8OWOG=_gCJp7B:CreateTab(_Z01y1h("4d697363"))
_b8OWOG:CreateSectionHeader(_Z01y1h("56697375616c20547765616b73"))
_b8OWOG:CreateToggle({Title=_Z01y1h("46756c6c627269676874"),Flag=_Z01y1h("4642"),Default=false,Callback=function(_Lv38ov) _RwWy08.Fullbright=_Lv38ov;Fullbright(_Lv38ov) end})
_b8OWOG:CreateToggle({Title=_Z01y1h("4e6f20466f67"),Flag=_Z01y1h("4e46"),Default=false,Callback=function(_Lv38ov) _RwWy08.NoFog=_Lv38ov;NoFog(_Lv38ov) end})
_b8OWOG:CreateToggle({Title=_Z01y1h("4e6f20536861646f77"),Flag=_Z01y1h("4e53"),Default=false,Callback=function(_Lv38ov) _RwWy08.NoShadow=_Lv38ov;NoShadow(_Lv38ov) end})
_b8OWOG:CreateSectionHeader(_Z01y1h("517569636b20416374696f6e73"))
_b8OWOG:CreateButton({Title=_Z01y1h("44697361626c6520416c6c20455350"),Callback=function()
    _RwWy08.SkeletonESP=false;_RwWy08.BoxESP=false;_RwWy08.CornerBoxESP=false;_RwWy08.TracerESP=false;_RwWy08.NameESP=false;_RwWy08.HealthTextESP=false;_RwWy08.DistanceESP=false;_RwWy08.HealthBar=false;_RwWy08.ChamsEnabled=false;_RwWy08.RadarEnabled=false;_RwWy08.LookDirectionESP=false
    _B3kwKr:Disable();_f4THjv:Disable();_xsTykg:Disable();_UNDjht:Disable();_tNQ4eD:Disable();_7fw9T4:Disable();_qPyLi8:Disable();_OxLMdM:Disable();_LOfTDJ:Disable();_t8hktD:Destroy();_ZiBruz:Disable()
    _gCJp7B:Notify(_Z01y1h("416c6c204553502064697361626c6564"),2)
end})
_b8OWOG:CreateButton({Title=_Z01y1h("44697361626c652041696d626f74"),Callback=function() _RwWy08.AimbotEnabled=false;_Twp3ov:Disable();_gCJp7B:Notify(_Z01y1h("41696d626f742064697361626c6564"),2) end})
_b8OWOG:CreateButton({Title=_Z01y1h("526573746f7265204c69676874696e67"),Callback=function() _RwWy08.Fullbright=false;_RwWy08.NoFog=false;_RwWy08.NoShadow=false;Fullbright(false);NoFog(false);NoShadow(false);_gCJp7B:Notify(_Z01y1h("4c69676874696e6720726573746f726564"),2) end})
_b8OWOG:CreateButton({Title=_Z01y1h("44657374726f7920536372697074"),Callback=function()
    Fullbright(false);NoFog(false);NoShadow(false)
    _B3kwKr:Disable();_f4THjv:Disable();_xsTykg:Disable();_UNDjht:Disable();_tNQ4eD:Disable();_7fw9T4:Disable();_qPyLi8:Disable();_OxLMdM:Disable();_LOfTDJ:Disable();_t8hktD:Destroy();_ZiBruz:Disable()
    _Twp3ov:Disable();DestroyFOV();SafeDisconnect(_Z01y1h("726762"))
    for k in pairs(_FuB9JY) do SafeDisconnect(k) end
    local _P0pfNT=_mJKyvo.PlayerGui:FindFirstChild(_Z01y1h("4b7265696e477569")); if _P0pfNT then _P0pfNT:Destroy() end
end})
_b8OWOG:CreateSectionHeader(_Z01y1h("496e666f"))
_b8OWOG:CreateLabel(_Z01y1h("4b7265696e41696d20763620b720")..(_yia2Lk and _Z01y1h("4d6f62696c65") or _Z01y1h("5043")).._Z01y1h("20b72062792040756e69717561646576"))
_b8OWOG:CreateLabel(_Z01y1h("4c6f6f6b20446972207c204368616d73207c205261646172203244207c2052474220455350207c2041696d626f74"))

task.delay(0.5,function()
    if _yia2Lk then _gCJp7B:Notify(_Z01y1h("4d6f62696c6521204175746f2053686f6f74202620486f6c64204b65792064696e6f6e616b7469666b616e2e"),5)
    else _gCJp7B:Notify(_Z01y1h("4b7265696e41696d207636206c6f61646564212053656d756120666974757220616b7469662e"),3) end
end)
