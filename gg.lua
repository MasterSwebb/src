-- D1NO HUB w/ Bring All + Infinite Jump + Admin Management
-- Single-file GUI script
-- Paste into your executor and run. Client-only; no server-side exploits.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Config: set admin IDs here (numbers)
local adminIDs = {9479860406
    -- example: 12345678
}

-- GUI Cleanup if already exists
if game:GetService("CoreGui"):FindFirstChild("D1noHub_GUI") then
    game:GetService("CoreGui"):FindFirstChild("D1noHub_GUI"):Destroy()
end

-- Helper functions
local function isAdmin(plr)
    for _, id in ipairs(adminIDs) do
        if plr.UserId == id then return true end
    end
    return false
end

local function create(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then
                obj.Parent = v
            else
                obj[k] = v
            end
        end
    end
    return obj
end

-- Main ScreenGui
local screenGui = create("ScreenGui", {
    Name = "D1noHub_GUI",
    ResetOnSpawn = false,
    Parent = game:GetService("CoreGui"),
})

-- Main Frame
local main = create("Frame", {
    Name = "Main",
    Parent = screenGui,
    Size = UDim2.new(0, 525, 0, 420),
    Position = UDim2.new(0.5, -262, 0.5, -210),
    BackgroundColor3 = Color3.fromRGB(20, 20, 22),
    BorderSizePixel = 0,
})
main.Active = true
main.Draggable = true

-- Title bar
local title = create("Frame", {
    Name = "TitleBar",
    Parent = main,
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = Color3.fromRGB(15, 15, 17),
    BorderSizePixel = 0,
})
create("TextLabel", {
    Parent = title,
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "D1NO HUB",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- Tab buttons container
local tabsFrame = create("Frame", {
    Parent = main,
    Size = UDim2.new(0, 120, 1, -36),
    Position = UDim2.new(0, 0, 0, 36),
    BackgroundTransparency = 1,
})
local function makeTabButton(name, y)
    local btn = create("TextButton", {
        Parent = tabsFrame,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, y),
        BackgroundColor3 = Color3.fromRGB(26, 26, 28),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.Gotham,
        TextSize = 14,
    })
    return btn
end

local pages = {}
local function makePage(name)
    local page = create("Frame", {
        Parent = main,
        Size = UDim2.new(1, -120, 1, -36),
        Position = UDim2.new(0, 120, 0, 36),
        BackgroundTransparency = 1,
        Visible = false,
        Name = name .. "_Page",
    })
    pages[name] = page
    return page
end

local homeBtn = makeTabButton("Home", 8)
local playersBtn = makeTabButton("Players", 8 + 36)
local settingsBtn = makeTabButton("Settings", 8 + 72)
local adminBtn = makeTabButton("Admin", 8 + 108)

local homePage = makePage("Home")
local playersPage = makePage("Players")
local settingsPage = makePage("Settings")
local adminPage = makePage("Admin")

-- Tab switching
local function showPage(name)
    for k,v in pairs(pages) do v.Visible = false end
    if pages[name] then pages[name].Visible = true end
end
showPage("Home")

homeBtn.MouseButton1Click:Connect(function() showPage("Home") end)
playersBtn.MouseButton1Click:Connect(function() showPage("Players") end)
settingsBtn.MouseButton1Click:Connect(function() showPage("Settings") end)
adminBtn.MouseButton1Click:Connect(function() 
    if isAdmin(LocalPlayer) then
        showPage("Admin") 
    else
        local old = adminBtn.Text
        adminBtn.Text = "LOCKED"
        delay(1, function() adminBtn.Text = old end)
    end
end)

-- HOME page content
create("TextLabel", {
    Parent = homePage,
    Size = UDim2.new(1, -24, 0, 24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "Welcome to D1NO HUB — client GUI",
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local infoLabel = create("TextLabel", {
    Parent = homePage,
    Size = UDim2.new(1, -24, 0, 80),
    Position = UDim2.new(0, 12, 0, 44),
    BackgroundTransparency = 1,
    Text = "Use the Players tab to interact with other players.\nSettings has ESP, Bring All & visual options.\nAdmin tab visible only to configured admins.\n'Bring All' is client-side positioning only.",
    TextColor3 = Color3.fromRGB(180,180,180),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
})

-- PLAYERS page content
local playerSearch = create("TextBox", {
    Parent = playersPage,
    Size = UDim2.new(1, -24, 0, 28),
    Position = UDim2.new(0, 12, 0, 12),
    PlaceholderText = "Search player name...",
    Text = "",
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    TextSize = 14,
})
local refreshBtn = create("TextButton", {
    Parent = playersPage,
    Size = UDim2.new(0, 100, 0, 28),
    Position = UDim2.new(1, -112, 0, 12),
    Text = "Refresh",
    Font = Enum.Font.Gotham,
    TextSize = 14,
})

local playersList = create("ScrollingFrame", {
    Parent = playersPage,
    Size = UDim2.new(1, -24, 1, -56),
    Position = UDim2.new(0, 12, 0, 48),
    BackgroundColor3 = Color3.fromRGB(18,18,20),
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
})
playersList.ScrollBarThickness = 6

local uiListLayout = create("UIListLayout", {Parent = playersList})
uiListLayout.Padding = UDim.new(0, 6)

-- function to populate players list
local function makePlayerRow(plr)
    local row = create("Frame", {
        Parent = playersList,
        Size = UDim2.new(1, -12, 0, 46),
        BackgroundColor3 = Color3.fromRGB(28,28,30),
        BorderSizePixel = 0,
    })
    local nameLabel = create("TextLabel", {
        Parent = row,
        Size = UDim2.new(0.6, -8, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = plr.Name .. " [" .. tostring(plr.UserId) .. "]",
        TextColor3 = Color3.fromRGB(240,240,240),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local btnContainer = create("Frame", {
        Parent = row,
        Size = UDim2.new(0.4, -8, 1, -8),
        Position = UDim2.new(0.6, 2, 0, 4),
        BackgroundTransparency = 1,
    })
    local teleportBtn = create("TextButton", {
        Parent = btnContainer,
        Size = UDim2.new(0.33, -4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "TP",
        Font = Enum.Font.Gotham,
        TextSize = 12,
    })
    local spectateBtn = create("TextButton", {
        Parent = btnContainer,
        Size = UDim2.new(0.33, -4, 1, 0),
        Position = UDim2.new(0.33, 3, 0, 0),
        Text = "Spec",
        Font = Enum.Font.Gotham,
        TextSize = 12,
    })
    local copyBtn = create("TextButton", {
        Parent = btnContainer,
        Size = UDim2.new(0.34, -4, 1, 0),
        Position = UDim2.new(0.66, 6, 0, 0),
        Text = "ID",
        Font = Enum.Font.Gotham,
        TextSize = 12,
    })

    teleportBtn.MouseButton1Click:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end)

    spectateBtn.MouseButton1Click:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = plr.Character:FindFirstChildWhichIsA("Humanoid")
        end
    end)

    copyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard(tostring(plr.UserId))
        end)
    end)
end

local function refreshPlayers()
    for i,v in pairs(playersList:GetChildren()) do
        if not v:IsA("UIListLayout") then
            v:Destroy()
        end
    end
    local search = playerSearch.Text:lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if search == "" or plr.Name:lower():find(search) then
                makePlayerRow(plr)
            end
        end
    end
    local contentSize = uiListLayout.AbsoluteContentSize.Y
    playersList.CanvasSize = UDim2.new(0, 0, 0, contentSize + 8)
end

refreshBtn.MouseButton1Click:Connect(refreshPlayers)
playerSearch:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
Players.PlayerAdded:Connect(function() wait(0.2) refreshPlayers() end)
Players.PlayerRemoving:Connect(function() wait(0.2) refreshPlayers() end)
refreshPlayers()

-- SETTINGS page content (ESP & Bring All)
create("TextLabel", {
    Parent = settingsPage,
    Size = UDim2.new(1, -24, 0, 24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "Visuals, ESP & Bring All",
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- ESP toggles and options
local espEnabled = false
local espDistance = 200
local espToggle = create("TextButton", {
    Parent = settingsPage,
    Size = UDim2.new(0, 120, 0, 30),
    Position = UDim2.new(0, 12, 0, 48),
    Text = "ESP: OFF",
    Font = Enum.Font.Gotham,
    TextSize = 14,
})
local espDistBox = create("TextBox", {
    Parent = settingsPage,
    Size = UDim2.new(0, 120, 0, 30),
    Position = UDim2.new(0, 146, 0, 48),
    Text = tostring(espDistance),
    PlaceholderText = "Max Dist",
    Font = Enum.Font.Gotham,
    TextSize = 14,
})

local espMap = {}
local function createESPForPlayer(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    if espMap[plr] then return end
    local bill = create("BillboardGui", {
        Name = "SnipeESP",
        Parent = plr.Character,
        Adornee = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart"),
        Size = UDim2.new(0, 140, 0, 40),
        AlwaysOnTop = true,
        ResetOnSpawn = false,
    })
    local frame = create("Frame", {
        Parent = bill,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.25,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BorderSizePixel = 0,
    })
    local nameLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = plr.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255,255,255),
    })
    local distLabel = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(200,200,200),
    })
    espMap[plr] = {Bill = bill, DistLabel = distLabel}
end

local function removeESPForPlayer(plr)
    local entry = espMap[plr]
    if entry then
        if entry.Bill and entry.Bill.Parent then entry.Bill:Destroy() end
        espMap[plr] = nil
    end
end

local function updateESP()
    local maxDist = tonumber(espDistBox.Text) or 200
    for plr, data in pairs(espMap) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and data.DistLabel then
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                          and (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude 
                          or 0
            data.DistLabel.Text = string.format("Dist: %d", math.floor(dist))
            data.Bill.Enabled = dist <= maxDist
        else
            removeESPForPlayer(plr)
        end
    end
end

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createESPForPlayer(plr)
            end
        end
    else
        for plr, _ in pairs(espMap) do
            removeESPForPlayer(plr)
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if espEnabled and plr ~= LocalPlayer then
        createESPForPlayer(plr)
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    removeESPForPlayer(plr)
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then updateESP() end
end)

-- Bring All button
local bringAllBtn = create("TextButton", {
    Parent = settingsPage,
    Size = UDim2.new(0, 120, 0, 30),
    Position = UDim2.new(0, 12, 0, 88),
    Text = "Bring All",
    Font = Enum.Font.Gotham,
    TextSize = 14,
})

local bringAllEnabled = false
bringAllBtn.MouseButton1Click:Connect(function()
    bringAllEnabled = not bringAllEnabled
    bringAllBtn.Text = bringAllEnabled and "Bring All: ON" or "Bring All"
end)

RunService.RenderStepped:Connect(function()
    if bringAllEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-5,5),0,math.random(-5,5))
            end
        end
    end
end)

-- SETTINGS: Infinite Jump
local infJumpEnabled = false
local infJumpBtn = create("TextButton", {
    Parent = settingsPage,
    Size = UDim2.new(0, 120, 0, 30),
    Position = UDim2.new(0, 146, 0, 88),
    Text = "Infinite Jump: OFF",
    Font = Enum.Font.Gotham,
    TextSize = 14,
})

infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    infJumpBtn.Text = "Infinite Jump: " .. (infJumpEnabled and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ADMIN PAGE CONTENT
create("TextLabel", {
    Parent = adminPage,
    Size = UDim2.new(1, -24, 0, 24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundTransparency = 1,
    Text = "Admin Management",
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local adminInput = create("TextBox", {
    Parent = adminPage,
    Size = UDim2.new(0, 200, 0, 28),
    Position = UDim2.new(0, 12, 0, 48),
    PlaceholderText = "Enter UserId...",
    Text = "",
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    TextSize = 14,
})
local addAdminBtn = create("TextButton", {
    Parent = adminPage,
    Size = UDim2.new(0, 100, 0, 28),
    Position = UDim2.new(0, 220, 0, 48),
    Text = "Add Admin",
    Font = Enum.Font.Gotham,
    TextSize = 14,
})

local adminListFrame = create("ScrollingFrame", {
    Parent = adminPage,
    Size = UDim2.new(1, -24, 1, -88),
    Position = UDim2.new(0, 12, 0, 88),
    BackgroundColor3 = Color3.fromRGB(18,18,20),
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0,0,0,0),
})
adminListFrame.ScrollBarThickness = 6
local adminListLayout = create("UIListLayout", {Parent = adminListFrame})
adminListLayout.Padding = UDim.new(0,4)

local function refreshAdminList()
    for _, child in pairs(adminListFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, id in ipairs(adminIDs) do
        local row = create("Frame", {
            Parent = adminListFrame,
            Size = UDim2.new(1, -8, 0, 28),
            BackgroundColor3 = Color3.fromRGB(28,28,30),
            BorderSizePixel = 0,
        })
        create("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(id),
            TextColor3 = Color3.fromRGB(230,230,230),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 4, 0, 0),
        })
        local removeBtn = create("TextButton", {
            Parent = row,
            Size = UDim2.new(0.3, -4, 1, 0),
            Position = UDim2.new(0.7, 4, 0, 0),
            Text = "Remove",
            Font = Enum.Font.Gotham,
            TextSize = 12,
        })
        removeBtn.MouseButton1Click:Connect(function()
            table.remove(adminIDs, i)
            refreshAdminList()
        end)
    end
    adminListFrame.CanvasSize = UDim2.new(0,0,0,adminListLayout.AbsoluteContentSize.Y + 4)
end

addAdminBtn.MouseButton1Click:Connect(function()
    local id = tonumber(adminInput.Text)
    if id and not table.find(adminIDs, id) then
        table.insert(adminIDs, id)
        adminInput.Text = ""
        refreshAdminList()
    end
end)

refreshAdminList()
