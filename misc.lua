return function(HUB)
    local Tabs = HUB.Tabs
    local Fluent = HUB.Fluent
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    Tabs.Misc:AddParagraph({ Title = "🛠️ Movement & Player Utilities", Content = "Modifikasi pergerakan dan visual pemain." })

    -- 1. WalkSpeed & JumpPower
    Tabs.Misc:AddSlider("WalkSpeedSlider", {
        Title = "Walk Speed",
        Description = "Kecepatan Jalan Karakter",
        Default = 16,
        Min = 16,
        Max = 150,
        Rounding = 0,
        Callback = function(V)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = V
            end
        end
    })

    Tabs.Misc:AddSlider("JumpPowerSlider", {
        Title = "Jump Power",
        Description = "Tinggi Lompatan Karakter",
        Default = 50,
        Min = 50,
        Max = 200,
        Rounding = 0,
        Callback = function(V)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                hum.UseJumpPower = true
                hum.JumpPower = V
            end
        end
    })

    -- 2. Player ESP
    local playerEspActive = false
    local espHighlights = {}

    local function updatePlayerEsp()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if playerEspActive then
                    if not espHighlights[plr] or not espHighlights[plr].Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "KenopsiaPlayerESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 150)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Adornee = plr.Character
                        hl.Parent = plr.Character
                        espHighlights[plr] = hl
                    end
                else
                    if espHighlights[plr] then
                        espHighlights[plr]:Destroy()
                        espHighlights[plr] = nil
                    end
                end
            end
        end
    end

    Tabs.Misc:AddToggle("PlayerEspToggle", {
        Title = "Player ESP (Highlight Pemain)",
        Default = false,
        Callback = function(V)
            playerEspActive = V
            updatePlayerEsp()
        end
    })

    -- 3. Smart Noclip
    local smartNoclipActive = false
    RunService.Stepped:Connect(function()
        if not getgenv().KenopsiaRunning then return end
        if smartNoclipActive and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)

    Tabs.Misc:AddToggle("SmartNoclipToggle", {
        Title = "Smart Noclip",
        Default = false,
        Callback = function(V) smartNoclipActive = V end
    })

    -- 4. Fly System
    local flyingActive = false
    local flySpeed = 50
    local bodyVel, bodyGyro

    Tabs.Misc:AddToggle("FlyToggle", {
        Title = "Player Fly (Terbang)",
        Default = false,
        Callback = function(V)
            flyingActive = V
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char.HumanoidRootPart

            if flyingActive then
                bodyVel = Instance.new("BodyVelocity")
                bodyGyro = Instance.new("BodyGyro")
                bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bodyVel.Parent = root
                bodyGyro.Parent = root
                
                task.spawn(function()
                    while flyingActive and getgenv().KenopsiaRunning do
                        local camCF = workspace.CurrentCamera.CFrame
                        local moveDir = Vector3.zero
                        local UIS = game:GetService("UserInputService")
                        
                        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end

                        bodyVel.Velocity = moveDir * flySpeed
                        bodyGyro.CFrame = camCF
                        task.wait()
                    end
                    if bodyVel then bodyVel:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                end)
            else
                if bodyVel then bodyVel:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
            end
        end
    })

    -- 5. Utilitas Tambahan
    Tabs.Misc:AddButton({
        Title = "Auto Flip Vehicle / Character",
        Callback = function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0) end
        end
    })

    Tabs.Misc:AddButton({
        Title = "Clear Local Debris (Anti-Lag)",
        Callback = function()
            local count = 0
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored and not part.Parent:FindFirstChildOfClass("Humanoid") then
                    if not part.Parent:IsA("Accessory") then part:Destroy() count = count + 1 end
                end
            end
            Fluent:Notify({ Title = "Anti-Lag", Content = "Menghapus " .. count .. " puing!", Duration = 3 })
        end
    })
end
