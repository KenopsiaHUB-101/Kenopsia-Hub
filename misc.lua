return function(HUB)
    local Tabs = HUB.Tabs
    local Fluent = HUB.Fluent
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    Tabs.Misc:AddParagraph({ Title = "🛠️ Build & Crush Utilities", Content = "Fitur pergerakan, navigasi, dan utilitas anti-lag." })

    -- 1. Smart Noclip
    local smartNoclipActive = false
    RunService.Stepped:Connect(function()
        if not getgenv().KenopsiaRunning then return end
        if smartNoclipActive and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "LowerTorso" then
                    part.CanCollide = false
                end
            end
        end
    end)

    Tabs.Misc:AddToggle("SmartNoclipToggle", {
        Title = "Smart Noclip (Tembus Reruntuhan)",
        Default = false,
        Callback = function(Value)
            smartNoclipActive = Value
            if not Value and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            Fluent:Notify({ Title = "Smart Noclip", Content = Value and "Aktif" or "Nonaktif", Duration = 2 })
        end
    })

    -- 2. Character Fly
    local flyingActive = false
    local flySpeed = 50
    local bodyVel, bodyGyro

    local function toggleFly(val)
        flyingActive = val
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if flyingActive then
            bodyVel = Instance.new("BodyVelocity")
            bodyGyro = Instance.new("BodyGyro")
            bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bodyGyro.CFrame = root.CFrame
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
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

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

    Tabs.Misc:AddToggle("FlyToggle", {
        Title = "Player Fly (Terbang Bebas)",
        Default = false,
        Callback = function(Value) toggleFly(Value) end
    })

    Tabs.Misc:AddSlider("FlySpeedSlider", {
        Title = "Fly Speed",
        Default = 50, Min = 10, Max = 200, SubText = "Kecepatan Terbang",
        Callback = function(Value) flySpeed = Value end
    })

    -- 3. Auto Flip Vehicle
    Tabs.Misc:AddButton({
        Title = "Auto Flip Vehicle / Machine",
        Description = "Membalikkan posisi kendaraan agar tegak kembali.",
        Callback = function()
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)
                    Fluent:Notify({ Title = "Auto Flip", Content = "Kendaraan/Karakter ditegakkan!", Duration = 3 })
                end
            end)
        end
    })

    -- 4. Emergency Unstuck
    Tabs.Misc:AddButton({
        Title = "Emergency Unstuck (Reset Character)",
        Description = "Mereset karakter jika terjebak reruntuhan.",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    })

    -- 5. Clear Local Debris
    Tabs.Misc:AddButton({
        Title = "Clear Local Debris (Anti-Lag)",
        Description = "Menghapus puing-puing bangunan di sekitar Anda.",
        Callback = function()
            local count = 0
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored and not part.Parent:FindFirstChild("Humanoid") then
                    if not part.Parent:IsA("Accessory") then
                        part:Destroy()
                        count = count + 1
                    end
                end
            end
            Fluent:Notify({ Title = "Anti-Lag", Content = "Menghapus " .. count .. " puing!", Duration = 4 })
        end
    })
end
