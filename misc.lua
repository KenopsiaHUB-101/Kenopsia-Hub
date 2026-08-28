return function(HUB)
    local State = HUB.State
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")

    -- 1. Anti-AFK
    HUB.AntiAFK = task.spawn(function()
        while State.antiAFK and getgenv().KenopsiaRunning do
            task.wait(30)
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- Jump to simulate activity
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    task.wait(0.1)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    end)

    -- 2. Fast Walk
    HUB.FastWalk = task.spawn(function()
        local originalSpeed = 16
        while State.fastWalk and getgenv().KenopsiaRunning do
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 32 -- Double speed
                end
            end
            task.wait(0.1)
        end
        -- Restore speed when disabled
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = originalSpeed
            end
        end
    end)

    -- 3. ESP (Basic Implementation)
    HUB.ESP = task.spawn(function()
        while State.esp and getgenv().KenopsiaRunning do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        -- Simple ESP: Highlight or Box (using Highlight object is less detectable)
                        local highlight = Instance.new("Highlight")
                        highlight.FillTransparency = 0.5
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = head
                        task.wait(0.1) -- Cleanup every frame to avoid clutter
                        highlight:Destroy()
                    end
                end
            end
            task.wait(0.05)
        end
    end)

    -- 4. Auto Reconnect
    HUB.AutoReconnect = task.spawn(function()
        while getgenv().KenopsiaRunning do
            if not LocalPlayer then
                task.wait(1)
                -- Roblox handles reconnection automatically, but we can trigger UI refresh
            end
            task.wait(5)
        end
    end)
end
