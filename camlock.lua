local camlockTable = getgenv()['returnal']['camlock']
local NotificationService = game:GetService("StarterGui")

-- Function to send a notification
local function sendNotification(title, text)
    NotificationService:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 3; -- Duration of the notification
    })
end

-- Function to detect changes in the table
local function checkForTableUpdate()
    while true do
        -- Check if the table has been modified
        local newTable = getgenv()['returnal']['camlock']
        if newTable ~= camlockTable then
            -- Notify the user that the table was updated
            sendNotification("Table Updated", "The camlock table has been updated. Reinjecting...")

            -- Update the camlock table reference
            camlockTable = newTable

            -- Reinject the script with the new table
            loadstring([[
                local camlock = getgenv()['returnal']['camlock']
                -- Your updated script here with new camlock values
                -- (This will execute the updated camlock values after reinjecting)
            ]])()

            -- Break out of the loop after reinjecting
            break
        end
        wait(1) -- Check every second for changes
    end
end

-- Start the table update check in a separate thread
coroutine.wrap(checkForTableUpdate)()

-- Your original script logic here...
local Camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Target = nil
local Prediction = camlockTable['Advance']['PredictionY']
local Keybind = Enum.KeyCode[camlockTable['Key']]
local LockEnabled = false
local OffsetMode = camlockTable['Offset']['Mode']
local Smoothing = camlockTable['Adjusting']['Smoothing']
local Adjust = camlockTable['Adjusting']['Adjust']
local CheckIfJumped = camlockTable['Adjusting']['CheckIfJumped']
local CustomPartsEnabled = camlockTable['CustomParts']['Enabled']
local CustomParts = camlockTable['CustomParts']['Parts']

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
