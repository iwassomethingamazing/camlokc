-- Camera Lock functions based on the table
local camlock = getgenv()['returnal']['camlock']
local Camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Target = nil
local Prediction = camlock['Advance']['PredictionY']
local Keybind = Enum.KeyCode[camlock['Key']]
local LockEnabled = false
local OffsetMode = camlock['Offset']['Mode']
local Smoothing = camlock['Adjusting']['Smoothing']
local Adjust = camlock['Adjusting']['Adjust']
local CheckIfJumped = camlock['Adjusting']['CheckIfJumped']
local CustomPartsEnabled = camlock['CustomParts']['Enabled']
local CustomParts = camlock['CustomParts']['Parts']

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

-- Locking logic with Offset mode and prediction
local function lockOnTarget()
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Target.Character.HumanoidRootPart
        local predictedPosition = hrp.Position + (hrp.Velocity * Prediction)

        -- Adjust camera position based on smoothing and offset
        local cameraPosition = Camera.CFrame.Position
        local newPosition = cameraPosition:Lerp(predictedPosition + Vector3.new(Adjust, Adjust, Adjust), Smoothing)
        Camera.CFrame = CFrame.new(newPosition, predictedPosition)
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

-- Update the camera while locked
game:GetService("RunService").RenderStepped:Connect(function()
    if LockEnabled then
        lockOnTarget()
    end
end)
