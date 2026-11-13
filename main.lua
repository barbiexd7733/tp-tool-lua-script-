-- Delta Executor Persistent Circular Buttons & 3D Tool Script
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = CoreGui:FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- Clean up any existing GUI if re-executed
if playerGui:FindFirstChild("TPToolGUI_Circular") then
    playerGui.TPToolGUI_Circular:Destroy()
end

-- Create Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TPToolGUI_Circular"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Helper function to make any UI element draggable on mobile/PC
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- 1. Create the yellow circular "TP TOOL" button
local tpToolButton = Instance.new("TextButton")
tpToolButton.Name = "TPToolButton"
tpToolButton.Size = UDim2.new(0, 50, 0, 50)
tpToolButton.Position = UDim2.new(0, 20, 0, 50)
tpToolButton.BackgroundColor3 = Color3.fromRGB(255, 225, 53) -- Yellow
tpToolButton.Text = "TOOL"
tpToolButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
tpToolButton.TextSize = 10
tpToolButton.Font = Enum.Font.SourceSansBold
tpToolButton.Parent = screenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(1, 0)
corner1.Parent = tpToolButton
makeDraggable(tpToolButton)

-- 2. Create the red circular action "TP" button (Permanent/Always Visible now)
local tpActionButton = Instance.new("TextButton")
tpActionButton.Name = "TPActionButton"
tpActionButton.Size = UDim2.new(0, 50, 0, 50)
tpActionButton.Position = UDim2.new(0, 20, 0, 110)
tpActionButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Red
tpActionButton.Text = "TP"
tpActionButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
tpActionButton.TextSize = 13
tpActionButton.Font = Enum.Font.SourceSansBold
tpActionButton.Visible = true -- Stays visible permanently!
tpActionButton.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(1, 0)
corner2.Parent = tpActionButton
makeDraggable(tpActionButton)

-- State Variable
local placedMarkerPart = nil

-- Function to give the 3D Text "TP" Tool
tpToolButton.MouseButton1Click:Connect(function()
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    if not backpack or not character then return end
    
    if backpack:FindFirstChild("TP_Tool") or (character and character:FindFirstChild("TP_Tool")) then
        return
    end

    local tool = Instance.new("Tool")
    tool.Name = "TP_Tool"
    tool.RequiresHandle = true

    -- Create 3D Handle Part
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.BrickColor = BrickColor.new("Bright yellow")
    handle.Material = Enum.Material.Neon
    handle.Shape = Enum.PartType.Ball
    handle.CanCollide = false
    handle.Parent = tool

    -- Add 3D Text Display on the tool itself
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = handle

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "TP TOOL"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.Parent = billboard

    tool.Parent = backpack
end)

-- Red "TP" Circular Button Functionality
tpActionButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart

    if not placedMarkerPart then
        -- Drop marker anchor point where you are standing
        local marker = Instance.new("Part")
        marker.Name = "TP_Marker"
        marker.Size = Vector3.new(2, 0.4, 2)
        marker.Position = rootPart.Position - Vector3.new(0, 3, 0)
        marker.Anchored = true
        marker.CanCollide = false
        marker.BrickColor = BrickColor.new("Bright red")
        marker.Material = Enum.Material.Neon
        marker.Parent = workspace

        -- Visual marker label
        local bg = Instance.new("BillboardGui")
        bg.Size = UDim2.new(0, 120, 0, 50)
        bg.StudsOffset = Vector3.new(0, 1, 0)
        bg.AlwaysOnTop = true
        bg.Parent = marker
        
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.BackgroundTransparency = 1
        tl.Text = "TELEPORT SPOT"
        tl.TextColor3 = Color3.fromRGB(255, 0, 0)
        tl.TextScaled = true
        tl.Font = Enum.Font.SourceSansBold
        tl.Parent = bg

        placedMarkerPart = marker
        tpActionButton.Text = "GO"
    else
        -- Teleport back to marker
        if placedMarkerPart and placedMarkerPart.Parent then
            rootPart.CFrame = CFrame.new(placedMarkerPart.Position + Vector3.new(0, 3, 0))
            
            placedMarkerPart:Destroy()
            placedMarkerPart = nil
            tpActionButton.Text = "TP"
        end
    end
end)
