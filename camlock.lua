local camlock = getgenv()['returnal']['camlock'] -- Getting the camlock table
local Camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Target = nil
local LockEnabled = false
local Keybind = Enum.KeyCode[camlock['Key']] -- Keybind to toggle lock
local Smoothing = camlock['Adjusting']['Smoothing'] -- Smoothing for camera movement
local CustomPartsEnabled = camlock['CustomParts']['Enabled'] -- Check if CustomParts is enabled
local CustomParts = camlock['CustomParts']['Parts'] -- The part to focus on (e.g., 'Head')
local ClosestPart = camlock['ClosestPart'] -- Lock to closest part flag
local AirPart = camlock['Air']['AirPart'] -- Air lock part (e.g., 'Head')

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

-- Function to lock the camera on the target's head or the closest part
local function lockOnTarget()
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local character = Target.Character
        local partToLock = nil
        
        -- If closest part is enabled, lock to the closest part
        if ClosestPart then
            if CustomPartsEnabled and character:FindFirstChild(CustomParts) then
                partToLock = character[CustomParts] -- Custom parts focus
            else
                partToLock = character.HumanoidRootPart -- Default to HumanoidRootPart
            end
        elseif character:FindFirstChild("Humanoid") and character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then
            -- Lock to the head when the player jumps
            if character:FindFirstChild("Head") then
                partToLock = character.Head
            end
        end

        -- If we have a valid part to lock to
        if partToLock then
            local predictedPosition = partToLock.Position

            -- Smoothing the camera movement to the predicted position
            local cameraPosition = Camera.CFrame.Position
            local newPosition = cameraPosition:Lerp(predictedPosition, Smoothing)
            Camera.CFrame = CFrame.new(newPosition, predictedPosition)
        end
    end
end

-- Toggle the lock state when the keybind is pressed
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
