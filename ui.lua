local HUB = getgenv().KenopsiaHUB
if not HUB then HUB = { State = { } } end

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB",
    SubTitle = "Build & Crush",
    TabWidth = 150,
    Size = UDim2.fromOffset(550, 480),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Store = Window:AddTab({ Title = "Store", Icon = "shopping-cart" }),
    Misc = Window:AddTab({ Title = "MISC", Icon = "wrench" }),
    Monitoring = Window:AddTab({ Title = "Monitoring", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Debug = Window:AddTab({ Title = "Debug", Icon = "bug" }),
}

HUB.Fluent = Fluent
HUB.Window = Window
HUB.Tabs = Tabs
HUB.SaveManager = SaveManager
HUB.InterfaceManager = InterfaceManager

-- State Management
HUB.State = {
    isLocked = true,
    password = "kenopsia_hub123",
    bypassEnabled = true,
    autoBuy = false,
    smartStock = true,
    antiAFK = true,
    fastWalk = false,
    esp = false,
    audioAlert = true,
    streamproof = false
}

-- ==================== LOCK SCREEN ====================
local lockScreen = Instance.new("ScreenGui")
lockScreen.Name = "KenopsiaLock"
lockScreen.ResetOnSpawn = false
lockScreen.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Name = "LockFrame"
frame.Size = UDim2.fromOffset(320, 180)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = lockScreen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.3)
title.Position = UDim2.fromOffset(0, 15)
title.BackgroundTransparency = 1
title.Text = "Kenopsia HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = frame

local passLabel = Instance.new("TextLabel")
passLabel.Size = UDim2.fromScale(1, 0.15)
passLabel.Position = UDim2.fromOffset(0, 60)
passLabel.BackgroundTransparency = 1
passLabel.Text = "Password:"
passLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
passLabel.Font = Enum.Font.Gotham
passLabel.TextSize = 14
passLabel.Parent = frame

local passInput = Instance.new("TextBox")
passInput.Size = UDim2.fromScale(0.8, 0.25)
passInput.Position = UDim2.fromScale(0.1, 0.5)
passInput.PlaceholderText = "Enter Password"
passInput.Text = ""
passInput.TextColor3 = Color3.fromRGB(255, 255, 255)
passInput.Font = Enum.Font.Gotham
passInput.TextSize = 16
passInput.Parent = frame

local btnUnlock = Instance.new("TextButton")
btnUnlock.Size = UDim2.fromScale(0.8, 0.2)
btnUnlock.Position = UDim2.fromScale(0.1, 0.85)
btnUnlock.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
btnUnlock.Text = "Unlock"
btnUnlock.TextColor3 = Color3.fromRGB(255, 255, 255)
btnUnlock.Font = Enum.Font.GothamBold
btnUnlock.TextSize = 16
btnUnlock.Parent = frame

btnUnlock.MouseButton1Click:Connect(function()
    local entered = passInput.Text
    if entered == HUB.State.password then
        HUB.State.isLocked = false
        lockScreen:Destroy()
        Window:Show()
        Fluent:Notify({ Title = "Unlocked", Content = "Welcome back.", Duration = 3 })
    else
        passInput.Text = "Wrong Password"
        passInput.TextColor3 = Color3.fromRGB(255, 80, 80)
        task.wait(1)
        passInput.Text = ""
        passInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

passInput:GetPropertyChangedSignal("Text"):Connect(function()
    if passInput.Text == "" then
        passInput.PlaceholderText = "Enter Password"
    end
end)

-- ==================== FLOATING BUTTON ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KenopsiaFloatingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleBtn.Active = true
toggleBtn.Draggable = true

local cornerBtn = Instance.new("UICorner", toggleBtn)
cornerBtn.CornerRadius = UDim.new(0, 12)

-- Load Logo
local logoUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/logo.png"
local logoPath = "kenopsia_logo.png"

pcall(function()
    if getcustomasset and writefile then
        if not (isfile and isfile(logoPath)) then
            writefile(logoPath, game:HttpGet(logoUrl))
        end
        toggleBtn.Image = getcustomasset(logoPath)
    end
end)

local VirtualInputManager = game:GetService("VirtualInputManager")

local function safeToggleUI()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    task.wait(0.05) 
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end

toggleBtn.TouchEnded:Connect(function()
    safeToggleUI()
end)

-- ==================== ANTI-DEVTOOLS / STREAMPROOF ====================
Window.Container.AutomaticSize = Enum.AutomaticSize.None
Window.Container.BorderSizePixel = 0

-- Hide from Roblox's "Inspect" (DevTools)
pcall(function()
    Window.Container:GetPropertyChangedSignal("Name"):Connect(function()
        -- This doesn't fully hide it, but helps
    end)
end)

HUB.Window = Window
HUB.Tabs = Tabs

Fluent:Notify({ Title = "Kenopsia HUB", Content = "Lock Screen Active!", Duration = 4 })

return HUB
