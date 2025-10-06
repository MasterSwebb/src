-- ModuleScript: SwebUI
-- Usage: local SwebUI = require(path.to.SwebUI)
--        local win = SwebUI:CreateWindow("Sweb UI")
--        local tab = win:AddTab("Main")
--        local section = tab:AddSection("Combat")
--        section:AddToggle("Auto Attack", false, function(state) print("toggle", state) end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local SwebUI = {}
SwebUI.__index = SwebUI

-- Utilities
local function new(instType, props)
    local inst = Instance.new(instType)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    return inst
end

local function createRounded(frame, cornerRadius)
    local uic = new("UICorner", {CornerRadius = cornerRadius or UDim.new(0, 6)})
    uic.Parent = frame
    return uic
end

local function simpleTween(inst, props, time)
    time = time or 0.18
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(inst, info, props)
    tween:Play()
    return tween
end

-- root ScreenGui
local function getParentGui()
    local player = Players.LocalPlayer
    if not player then
        -- fallback to CoreGui if running in exploit-like environment
        local sg = Instance.new("ScreenGui")
        sg.Name = "SwebUI_Fallback"
        sg.ResetOnSpawn = false
        sg.Parent = game:GetService("CoreGui")
        return sg
    end
    local playerGui = player:WaitForChild("PlayerGui")
    local sg = playerGui:FindFirstChild("SwebUI")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "SwebUI"
        sg.ResetOnSpawn = false
        sg.Parent = playerGui
    end
    return sg
end

-- Component constructors
local function createLabel(text, size)
    local lb = new("TextLabel", {
        Text = text or "",
        Size = size or UDim2.new(1,0,0,20),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return lb
end

-- Window factory
function SwebUI:CreateWindow(title)
    local self = setmetatable({}, SwebUI)
    self.window = {}
    local parentGui = getParentGui()

    local frame = new("Frame", {
        Name = "SwebWindow_" .. title:gsub("%s+",""),
        Parent = parentGui,
        Size = UDim2.new(0, 680, 0, 420),
        Position = UDim2.new(0.5, -340, 0.5, -210),
        BackgroundColor3 = Color3.fromRGB(30,30,34),
        Active = true,
        Draggable = true
    })
    createRounded(frame, UDim.new(0,8))

    local header = new("Frame", {
        Parent = frame,
        Size = UDim2.new(1,0,0,38),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(22,22,26)
    })
    createRounded(header, UDim.new(0,8))

    local titleLabel = new("TextLabel", {
        Parent = header,
        Text = title,
        Size = UDim2.new(0.6,0,1,0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(240,240,240),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Position = UDim2.new(0,12,0,0)
    })

    local closeBtn = new("TextButton", {
        Parent = header,
        Text = "X",
        Size = UDim2.new(0,36,0,26),
        Position = UDim2.new(1,-44,0,6),
        BackgroundColor3 = Color3.fromRGB(200,60,60),
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    createRounded(closeBtn, UDim.new(0,6))
    closeBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    -- Left: tabs list
    local tabsFrame = new("Frame", {
        Parent = frame,
        Size = UDim2.new(0,160,1,-38),
        Position = UDim2.new(0,0,0,38),
        BackgroundColor3 = Color3.fromRGB(24,24,28)
    })
    createRounded(tabsFrame, UDim.new(0,6))

    local tabsLayout = new("UIListLayout", {Parent = tabsFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})
    tabsLayout.Padding = UDim.new(0,6)
    local tabsContainer = new("ScrollingFrame", {
        Parent = tabsFrame,
        Size = UDim2.new(1,-12,1,-12),
        Position = UDim2.new(0,6,0,6),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6
    })
    local tabsList = new("UIListLayout", {Parent = tabsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})

    -- Right: content area
    local contentFrame = new("Frame", {
        Parent = frame,
        Size = UDim2.new(1,-160,1,-38),
        Position = UDim2.new(0,160,0,38),
        BackgroundColor3 = Color3.fromRGB(18,18,22)
    })
    createRounded(contentFrame, UDim.new(0,6))

    local contentTabs = {} -- name -> content frame

    -- Methods
    function self:AddTab(name)
        -- tab button
        local btn = new("TextButton", {
            Parent = tabsContainer,
            Size = UDim2.new(1,0,0,36),
            BackgroundColor3 = Color3.fromRGB(26,26,30),
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(220,220,220)
        })
        createRounded(btn, UDim.new(0,6))

        -- content page
        local page = new("Frame", {
            Parent = contentFrame,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false
        })
        local pageLayout = new("UIListLayout", {Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
        pageLayout.Padding = UDim.new(0,8)
        contentTabs[name] = page

        btn.MouseButton1Click:Connect(function()
            -- hide others
            for _, p in pairs(contentTabs) do p.Visible = false end
            page.Visible = true
            -- highlight (simple tween)
            for _, child in pairs(tabsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(26,26,30)
                end
            end
            simpleTween(btn, {BackgroundColor3 = Color3.fromRGB(44,44,48)}, 0.12)
            btn.BackgroundColor3 = Color3.fromRGB(44,44,48)
        end)

        -- return tab object
        local tabObj = {}
        function tabObj:AddSection(sectionName)
            local secFrame = new("Frame", {
                Parent = page,
                Size = UDim2.new(1, -12, 0, 0),
                BackgroundColor3 = Color3.fromRGB(28,28,32)
            })
            createRounded(secFrame, UDim.new(0,6))
            -- put a vertical size constraint using UIListLayout and AutomaticSize
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            local inner = new("Frame", {
                Parent = secFrame,
                Size = UDim2.new(1, -12, 1, -12),
                Position = UDim2.new(0,6,0,6),
                BackgroundTransparency = 1
            })
            local headerLabel = createLabel(sectionName, UDim2.new(1,0,0,20))
            headerLabel.Parent = inner
            headerLabel.Font = Enum.Font.GothamSemibold
            headerLabel.TextSize = 15

            local contentHolder = new("Frame", {
                Parent = inner,
                Size = UDim2.new(1,0,0,0),
                BackgroundTransparency = 1
            })
            contentHolder.AutomaticSize = Enum.AutomaticSize.Y
            contentHolder.LayoutOrder = 2
            local holderLayout = new("UIListLayout", {Parent = contentHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})
            holderLayout.Padding = UDim.new(0,6)

            -- control functions
            local section = {}

            function section:AddButton(text, callback)
                local b = new("TextButton", {
                    Parent = contentHolder,
                    Size = UDim2.new(1,0,0,36),
                    BackgroundColor3 = Color3.fromRGB(48,48,56),
                    Text = text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(245,245,245)
                })
                createRounded(b, UDim.new(0,6))
                b.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
                return b
            end

            function section:AddToggle(label, default, callback)
                local row = new("Frame", {Parent = contentHolder, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1})
                local lbl = createLabel(label, UDim2.new(0.7,0,1,0))
                lbl.Parent = row
                local toggleBtn = new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(0,44,0,22),
                    Position = UDim2.new(1,-52,0,3),
                    Text = "",
                    BackgroundColor3 = default and Color3.fromRGB(90,200,130) or Color3.fromRGB(60,60,66)
                })
                createRounded(toggleBtn, UDim.new(0,6))
                local state = default or false
                toggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(90,200,130) or Color3.fromRGB(60,60,66)
                    pcall(callback, state)
                end)
                pcall(callback, state)
                return {element = row, get = function() return state end, set = function(v) state = v; toggleBtn.BackgroundColor3 = state and Color3.fromRGB(90,200,130) or Color3.fromRGB(60,60,66); pcall(callback, state) end}
            end

            function section:AddSlider(label, min, max, default, callback)
                min = min or 0; max = max or 100; default = default or min
                local row = new("Frame", {Parent = contentHolder, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
                local lbl = createLabel(label, UDim2.new(1,0,0,18))
                lbl.Parent = row
                lbl.Position = UDim2.new(0,0,0,0)

                local sliderBg = new("Frame", {
                    Parent = row,
                    Size = UDim2.new(1,0,0,12),
                    Position = UDim2.new(0,0,0,20),
                    BackgroundColor3 = Color3.fromRGB(50,50,56)
                })
                createRounded(sliderBg, UDim.new(0,6))
                sliderBg.ClipsDescendants = true

                local fill = new("Frame", {
                    Parent = sliderBg,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(120,170,240),
                })
                createRounded(fill, UDim.new(0,6))

                local dragging = false
                local value = default

                local function setValueFromX(x)
                    local abs = sliderBg.AbsolutePosition.X
                    local w = sliderBg.AbsoluteSize.X
                    local rel = math.clamp((x - abs) / w, 0, 1)
                    value = min + rel * (max - min)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    pcall(callback, value)
                end

                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        setValueFromX(input.Position.X)
                    end
                end)
                sliderBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        setValueFromX(input.Position.X)
                    end
                end)
                pcall(callback, value)
                return {element = row, get = function() return value end, set = function(v) value = v; local rel = (value - min) / (max - min); fill.Size = UDim2.new(rel,0,1,0); pcall(callback, value); end}
            end

            function section:AddDropdown(label, options, defaultIndex, callback)
                defaultIndex = defaultIndex or 1
                options = options or {}
                local row = new("Frame", {Parent = contentHolder, Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1})
                local lbl = createLabel(label, UDim2.new(0.6,0,1,0))
                lbl.Parent = row

                local dd = new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(0.4, -8, 1, 0),
                    Position = UDim2.new(0.6, 8, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(48,48,56),
                    Text = tostring(options[defaultIndex] or ""),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(240,240,240)
                })
                createRounded(dd, UDim.new(0,6))

                local list = new("Frame", {
                    Parent = row,
                    Size = UDim2.new(0.4, -8, 0, math.min(#options,6) * 30),
                    Position = UDim2.new(0.6, 8, 1, 6),
                    BackgroundColor3 = Color3.fromRGB(36,36,40),
                    Visible = false
                })
                createRounded(list, UDim.new(0,6))

                local layout = new("UIListLayout", {Parent = list, SortOrder = Enum.SortOrder.LayoutOrder})
                for i, opt in ipairs(options) do
                    local it = new("TextButton", {
                        Parent = list,
                        Size = UDim2.new(1,0,0,30),
                        BackgroundTransparency = 1,
                        Text = opt,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230)
                    })
                    it.MouseButton1Click:Connect(function()
                        dd.Text = opt
                        list.Visible = false
                        pcall(callback, opt, i)
                    end)
                end

                dd.MouseButton1Click:Connect(function()
                    list.Visible = not list.Visible
                end)

                pcall(callback, options[defaultIndex], defaultIndex)
                return {element = row, set = function(i) dd.Text = options[i]; pcall(callback, options[i], i) end}
            end

            function section:AddKeybind(label, defaultKey, callback)
                defaultKey = defaultKey or Enum.KeyCode.F
                local row = new("Frame", {Parent = contentHolder, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1})
                local lbl = createLabel(label, UDim2.new(0.6,0,1,0))
                lbl.Parent = row

                local keyBtn = new("TextButton", {
                    Parent = row,
                    Size = UDim2.new(0.35, -8, 1, 0),
                    Position = UDim2.new(0.65, 8, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(48,48,56),
                    Text = tostring(defaultKey.Name or tostring(defaultKey)),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(230,230,230)
                })
                createRounded(keyBtn, UDim.new(0,6))

                local binding = defaultKey
                local waitingFor = false

                keyBtn.MouseButton1Click:Connect(function()
                    waitingFor = true
                    keyBtn.Text = "Press a key..."
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if waitingFor and input.UserInputType == Enum.UserInputType.Keyboard then
                        binding = input.KeyCode
                        keyBtn.Text = binding.Name
                        waitingFor = false
                        pcall(callback, binding)
                    else
                        -- activation
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == binding then
                            pcall(callback, binding)
                        end
                    end
                end)

                return {element = row, get = function() return binding end, set = function(k) binding = k; keyBtn.Text = tostring(k.Name or k) end}
            end

            function section:AddColorPicker(label, defaultColor, callback)
                defaultColor = defaultColor or Color3.fromRGB(255,255,255)
                local row = new("Frame", {Parent = contentHolder, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
                local lbl = createLabel(label, UDim2.new(0.6,0,1,0))
                lbl.Parent = row

                local colorPreview = new("Frame", {
                    Parent = row,
                    Size = UDim2.new(0,34,0,26),
                    Position = UDim2.new(1,-44,0,5),
                    BackgroundColor3 = defaultColor
                })
                createRounded(colorPreview, UDim.new(0,6))

                local cpOpen = false
                local picker = new("Frame", {
                    Parent = row,
                    Size = UDim2.new(0,180,0,140),
                    Position = UDim2.new(1,-188,1,6),
                    BackgroundColor3 = Color3.fromRGB(28,28,32),
                    Visible = false
                })
                createRounded(picker, UDim.new(0,6))
                local hue = new("Frame", {Parent = picker, Size = UDim2.new(1,-12,0,20), Position = UDim2.new(0,6,0,8), BackgroundColor3 = Color3.fromRGB(200,50,120)})
                createRounded(hue, UDim.new(0,6))
                local sample = new("Frame", {Parent = picker, Size = UDim2.new(1,-12,0,80), Position = UDim2.new(0,6,0,36), BackgroundColor3 = defaultColor})
                createRounded(sample, UDim.new(0,6))

                -- simple clickable hue toggles (not a full HSB picker)
                local hues = {Color3.fromRGB(255,0,0), Color3.fromRGB(255,120,0), Color3.fromRGB(255,220,0), Color3.fromRGB(0,190,60), Color3.fromRGB(0,170,255), Color3.fromRGB(120,80,255), Color3.fromRGB(255,0,200)}
                local hx = new("Frame", {Parent = hue, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
                local hxLayout = new("UIListLayout", {Parent = hx, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})
                hxLayout.Padding = UDim.new(0,4)
                for i, c in ipairs(hues) do
                    local sw = new("TextButton", {Parent = hx, Size = UDim2.new(0, (180-12)/#hues, 1, 0), BackgroundColor3 = c, Text = "", AutoButtonColor = false})
                    createRounded(sw, UDim.new(0,4))
                    sw.MouseButton1Click:Connect(function()
                        sample.BackgroundColor3 = c
                        colorPreview.BackgroundColor3 = c
                        pcall(callback, c)
                    end)
                end

                colorPreview.MouseButton1Click:Connect(function()
                    cpOpen = not cpOpen
                    picker.Visible = cpOpen
                end)

                return {element = row, set = function(c) colorPreview.BackgroundColor3 = c; sample.BackgroundColor3 = c; pcall(callback, c) end, get = function() return colorPreview.BackgroundColor3 end}
            end

            return section
        end

            -- end AddSection

        return tabObj
    end

    -- initialize: create a default tab selected
    local defaultTab = self:AddTab("Main")
    -- select it automatically (simulate click)
    for _, child in pairs(tabsContainer:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "Main" then
            child.MouseButton1Click:Fire()
        end
    end

    self._root = frame
    self._tabsContainer = tabsContainer
    return self
end

return SwebUI
