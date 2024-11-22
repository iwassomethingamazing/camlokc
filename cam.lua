local Camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Target = nil
local Prediction = 0.18 -- Adjusted for consistent accuracy
local Keybind = Enum.KeyCode.Q
local LockEnabled = false

-- Function to find the closest target
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local hrp = character.HumanoidRootPart
            local screenPoint, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - UIS:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

-- Lock instantly to target's predicted position
local function lockOnTarget()
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Target.Character.HumanoidRootPart
        local predictedPosition = hrp.Position + (hrp.Velocity * Prediction)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
    end
end

-- Toggle lock
UIS.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.KeyCode == Keybind then
        LockEnabled = not LockEnabled
        if LockEnabled then
            Target = getClosestTarget()
        else
            Target = nil
        end
    end
end)

-- Force instant locking
RunService.RenderStepped:Connect(function()
    if LockEnabled then
        lockOnTarget()
    end
end)
