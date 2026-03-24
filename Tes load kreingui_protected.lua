local _3aBf34=function(s) local _kIiq14="" for i=1,#s,2 do _kIiq14=_kIiq14..string.char(tonumber(s:sub(i,i+1),16)) end return _kIiq14 end
--[[
    ╔══════════════════════════════════════╗
    ║  Script  : tes                            ║
    ║  Author  : LippTz                         ║
    ║  Date    : 2026-03-24                     ║
    ║  Version : 1.0                       ║
    ╚══════════════════════════════════════╝
--]]

local _qTnfYC = loadstring(game:HttpGet(
        _3aBf34("68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f4c697070547a2f4b7265696e4775694c6962726172792f726566732f68656164732f6d61696e2f4b7265696e4775692e6c7561")
    ))()

    _qTnfYC:SetTheme({ Accent = Color3.fromRGB(99,102,241) })
    -- _qTnfYC:UsePreset(_3aBf34("526f7365")/_3aBf34("456d6572616c64")/_3aBf34("416d626572")/_3aBf34("4d69646e69676874"))

    local _bnnXEM = _qTnfYC:CreateWindow({
        Title      = _3aBf34("4d7920487562"),
        SubTitle   = _3aBf34("76332e30"),
        ConfigName = _3aBf34("4d79487562436f6e666967"),

        -- Key System (hapus 3 baris ini kalau tidak pakai)
        KeySystem  = true,
        KeyUrl     = _3aBf34("68747470733a2f2f706173746562696e2e636f6d2f7261772f47336e7a51754670"),  -- isi key valid (1 per baris)
        KeyLink    = _3aBf34("68747470733a2f2f6c696e6b2d63656e7465722e6e65742f343338363836362f565068634163386870427850"),       -- link untuk dapat key
--[[ PROTECTED | OWNER: LippTz | 2026-03-24 ]]
    })

    local _gYzsub = _bnnXEM:CreateTab(_3aBf34("4d61696e"))
    _gYzsub:CreateSectionHeader(_3aBf34("50656e6761747572616e20556d756d"))
    _gYzsub:CreateButton({ Title=_3aBf34("4b696c6c20416c6c"),   Callback=function() end })
    _gYzsub:CreateToggle({ Title=_3aBf34("476f64204d6f6465"),   Flag=_3aBf34("476f644d6f6465"),  Default=false, Callback=function(v) end })
    _gYzsub:CreateSlider({ Title=_3aBf34("57616c6b5370656564"),  Flag=_3aBf34("5753"), Min=16, Max=100, Default=16, Callback=function(v) end })
    _gYzsub:CreateInputNumber({ Title=_3aBf34("4a756d70506f776572"), Flag=_3aBf34("4a50"), Min=0, Max=200, Default=50, Step=5, Callback=function(v) end })
    _gYzsub:AddSeparator()
    _gYzsub:CreateSectionHeader(_3aBf34("546172676574"))
    _gYzsub:CreateTextBox({ Title=_3aBf34("4e616d61"), Flag=_3aBf34("546172676574"), Placeholder=_3aBf34("5461726765742e2e2e"), Callback=function(v) end })
    _gYzsub:CreateDropdown({ Title=_3aBf34("54696d"), Flag=_3aBf34("5465616d"), Options={_3aBf34("4d65726168"),_3aBf34("42697275"),_3aBf34("48696a6175")}, Default=_3aBf34("4d65726168"), Callback=function(v) end })

    local _2fODvB = _bnnXEM:CreateTab(_3aBf34("56697375616c"))
    _2fODvB:CreateSectionHeader(_3aBf34("455350"))
    _2fODvB:CreateColorPicker({ Title=_3aBf34("45535020436f6c6f72"), Flag=_3aBf34("455350436f6c6f72"), Default=Color3.fromRGB(255,0,0), Callback=function(c) end })
    _2fODvB:CreateToggle({ Title=_3aBf34("53686f7720455350"), Flag=_3aBf34("53686f77455350"), Default=true, Callback=function(v) end })
    _2fODvB:AddSeparator()
    _2fODvB:CreateSectionHeader(_3aBf34("50726f6772657373"))
    local _XpFnzl = _2fODvB:CreateProgressBar({ Title=_3aBf34("4c6f6164696e67"), Flag=_3aBf34("4c6f6164426172"), Default=0 })
    _XpFnzl:Set(75)  -- set ke 75%

    _2fODvB:CreateKeybind({ Title=_3aBf34("546f67676c6520475549"), Flag=_3aBf34("4755494b6579"), Default=Enum.KeyCode.RightShift, Callback=function(k) end })

    _bnnXEM:SaveConfig()
    _bnnXEM:Notify(_3aBf34("4b7265696e4775692076332e30206c6f6164656421"), 3)