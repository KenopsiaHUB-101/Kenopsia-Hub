-- ==========================================
-- KENOPSIA HUB - MISC MODULE
-- ==========================================

local Debug = _G.KenopsiaDebug or {
    Info = function() end,
    Success = function() end,
    Error = function() end,
    Warning = function() end,
    Debug = function() end
}

return function(HUB)
    if Debug.Info then Debug:Info("Loading misc module...") end
    
    local Tabs = HUB.Tabs
    local Fluent = HUB.Fluent
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    if not LocalPlayer then
        if Debug.Error then Debug:Error("LocalPlayer not found") end
        return
    end

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
            pcall(function()
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = V
                        if Debug.Debug then Debug:Debug("WalkSpeed set to: " .. V) end
                    end
                end
            end)
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
            pcall(function()
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.UseJumpPower = true
                        hum.JumpPower = V
                        if Debug.Debug then Debug:Debug("JumpPower set to: " .. V) end
                    end
                end
            end)
        end
    })

    -- 2. Player ESP
    if Debug.Debug then Debug:Debug("Setting up Player ESP...") end
    
    local playerEspActive = false
    local espHighlights = {}

    local function updatePlayerEsp()
        pcall(function()
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
        end)
    end

    Tabs.Misc:AddToggle("PlayerEspToggle", {
        Title = "Player ESP (Highlight Pemain)",
        Default = false,
        Callback = function(V)
            playerEspActive = V
            updatePlayerEsp()
            if Debug.Info then Debug:Info("Player ESP " .. (V and "enabled" or "disabled")) end
        end
    })

    -- 3. Smart Noclip
    if Debug.Debug then Debug:Debug("Setting up Smart Noclip...") end
    
    local smartNoclipActive = false
    RunService.Stepped:Connect(function()
        if not getgenv().KenopsiaRunning then return end
        if smartNoclipActive and LocalPlayer.Character then
            pcall(function()
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end)

    Tabs.Misc:AddToggle("SmartNoclipToggle", {
        Title = "Smart Noclip",
        Default = false,
        Callback = function(V) 
            smartNoclipActive = V
            if Debug.Info then Debug:Info("Smart Noclip " .. (V and "enabled" or "disabled")) end
        end
    })

    -- 4. Fly System
    if Debug.Debug then Debug:Debug("Setting up Fly System...") end
    
    local flyingActive = false
    local flySpeed = 50
    local bodyVel, bodyGyro

    Tabs.Misc:AddToggle("FlyToggle", {
        Title = "Player Fly (Terbang)",
        Default = false,
        Callback = function(V)
            flyingActive = V
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                if flyingActive then
                    if bodyVel then bodyVel:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                    
                    bodyVel = Instance.new("BodyVelocity")
                    bodyGyro = Instance.new("BodyGyro")
                    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                    bodyVel.Parent = root
                    bodyGyro.Parent = root
                    
                    if Debug.Debug then Debug:Debug("Fly physics initialized") end
                    
                    task.spawn(function()
                        while flyingActive and getgenv().KenopsiaRunning do
                            pcall(function()
                                local camCF = workspace.CurrentCamera.CFrame
                                local moveDir = Vector3.zero
                                local UIS = game:GetService("UserInputService")
                                
                                if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                                if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                                if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                                if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end

                                if bodyVel then bodyVel.Velocity = moveDir * flySpeed end
                                if bodyGyro then bodyGyro.CFrame = camCF end
                            end)
                            task.wait()
                        end
                    end)
                else
                    if bodyVel then bodyVel:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                    bodyVel = nil
                    bodyGyro = nil
                end
            end)
            
            if Debug.Info then Debug:Info("Fly " .. (V and "enabled" or "disabled")) end
        end
    })

    -- 5. Additional Utilities
    Tabs.Misc:AddButton({
        Title = "Auto Flip Vehicle / Character",
        Callback = function()
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)
                    if Debug.Success then Debug:Success("Character flipped successfully") end
                end
            end)
        end
    })

    Tabs.Misc:AddButton({
        Title = "Clear Local Debris (Anti-Lag)",
        Callback = function()
            pcall(function()
                local count = 0
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored then
                        local parent = part.Parent
                        if parent and not parent:FindFirstChildOfClass("Humanoid") and not parent:IsA("Accessory") then
                            part:Destroy()
                            count = count + 1
                        end
                    end
                end
                
                if Fluent then
                    Fluent:Notify({ Title = "Anti-Lag", Content = "Menghapus " .. count .. " puing!", Duration = 3 })
                end
                
                if Debug.Success then Debug:Success("Cleared " .. count .. " debris parts") end
            end)
        end
    })
    
    if Debug.Success then Debug:Success("Misc module loaded successfully") end
end
