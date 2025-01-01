--------------------------------------
-- Services and Locals
--------------------------------------
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")  -- Needed for 'view' command
local LocalPlayer = Players.LocalPlayer

-- We parent our ScreenGui to PlayerGui (safer than CoreGui in normal games)
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Track the original position of the local player when the script runs
local OriginalPosition
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    OriginalPosition = LocalPlayer.Character.HumanoidRootPart.Position
end

-------------------------------
-- DYNAMIC & DRAGGABLE COMMAND BAR
-------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminCommandBar"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local CommandBar = Instance.new("Frame")
CommandBar.Name = "CommandBar"
CommandBar.Parent = ScreenGui
CommandBar.Position = UDim2.new(0.5, -200, 0.9, 0)
CommandBar.Size = UDim2.new(0, 400, 0, 32)
CommandBar.AnchorPoint = Vector2.new(0.5, 0.5)
CommandBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CommandBar.BorderSizePixel = 0
CommandBar.Visible = false

local CommandBarCorner = Instance.new("UICorner")
CommandBarCorner.CornerRadius = UDim.new(0, 6)
CommandBarCorner.Parent = CommandBar

local CommandBarGradient = Instance.new("UIGradient")
CommandBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 70, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
})
CommandBarGradient.Rotation = 90
CommandBarGradient.Parent = CommandBar

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Parent = CommandBar
Shadow.AnchorPoint = Vector2.new(0,0)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.8
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0, 3, 0, 3)
Shadow.Size = UDim2.new(1, 0, 1, 0)

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0,6)
ShadowCorner.Parent = Shadow

local CommandInput = Instance.new("TextBox")
CommandInput.Name = "CommandInput"
CommandInput.Parent = CommandBar
CommandInput.BackgroundTransparency = 1
CommandInput.Size = UDim2.new(1, -10, 1, 0)
CommandInput.Position = UDim2.new(0, 10, 0, 0)
CommandInput.Font = Enum.Font.SourceSansSemibold
CommandInput.Text = ""
CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandInput.TextSize = 20
CommandInput.ClearTextOnFocus = false
CommandInput.PlaceholderText = "Enter Command..."
CommandInput.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------
-- Command List (Scrollable and Dynamic)
--------------------------------------
local CommandList = Instance.new("Frame")
CommandList.Name = "CommandList"
CommandList.Parent = ScreenGui
CommandList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CommandList.BorderSizePixel = 0
CommandList.Position = UDim2.new(0.5, -200, 0.5, -100)
CommandList.Size = UDim2.new(0, 400, 0, 300)
CommandList.AnchorPoint = Vector2.new(0.5, 0.5)
CommandList.Visible = false
CommandList.Active = true
CommandList.ClipsDescendants = true
CommandList.BackgroundTransparency = 0.2

local CommandListCorner = Instance.new("UICorner")
CommandListCorner.CornerRadius = UDim.new(0, 10)
CommandListCorner.Parent = CommandList

-- ScrollingFrame for Dynamic Content
local CommandListScroll = Instance.new("ScrollingFrame")
CommandListScroll.Name = "CommandListScroll"
CommandListScroll.Parent = CommandList
CommandListScroll.BackgroundTransparency = 1
CommandListScroll.Size = UDim2.new(1, 0, 1, -30)
CommandListScroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Adjusts dynamically
CommandListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CommandListScroll.ScrollBarThickness = 8
CommandListScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
CommandListScroll.Position = UDim2.new(0, 0, 0, 0)

-- UIListLayout for organized commands
local CommandListLayout = Instance.new("UIListLayout")
CommandListLayout.Parent = CommandListScroll
CommandListLayout.SortOrder = Enum.SortOrder.LayoutOrder
CommandListLayout.Padding = UDim.new(0, 5)

-- Commands as individual labels
local commands = {
    "killgui",
    "re",
    "fix",
    "cleanup",
    "noclip",
    "fly/unfly",
    "clip",
    "kill [name]",
    "rocket [name]",
    "view/unview [name]",
    "bring [name]",
    "tp [name1] [name2]",
    "goto [name]",
    "fling [name]",
    "jail [name]",
    "void [name]",
    "banlands [name]",
    "skydive [name]",
    "fireplace [name]",
    "highpoint [name]",
    "annoy/unannoy [name]",
    "revealusers/unrevealusers",
    "lag",
}

for _, cmd in ipairs(commands) do
    local CommandItem = Instance.new("TextLabel")
    CommandItem.Parent = CommandListScroll
    CommandItem.BackgroundTransparency = 1
    CommandItem.Size = UDim2.new(1, -10, 0, 24)
    CommandItem.Font = Enum.Font.SourceSans
    CommandItem.TextColor3 = Color3.fromRGB(255, 255, 255)
    CommandItem.TextSize = 18
    CommandItem.Text = "- " .. cmd
    CommandItem.TextWrapped = false
    CommandItem.TextXAlignment = Enum.TextXAlignment.Left
end

-- Padding for CommandListScroll
local CommandListPadding = Instance.new("UIPadding")
CommandListPadding.Parent = CommandListScroll
CommandListPadding.PaddingLeft = UDim.new(0, 10)
CommandListPadding.PaddingRight = UDim.new(0, 10)
CommandListPadding.PaddingTop = UDim.new(0, 10)

-- Close Button
local CommandListClose = Instance.new("TextButton")
CommandListClose.Name = "CommandListClose"
CommandListClose.Parent = CommandList
CommandListClose.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CommandListClose.Size = UDim2.new(0, 30, 0, 30)
CommandListClose.Position = UDim2.new(1, -35, 0, 5)
CommandListClose.Text = "X"
CommandListClose.Font = Enum.Font.SourceSansBold
CommandListClose.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandListClose.TextSize = 18
CommandListClose.AutoButtonColor = true

local CommandListCloseCorner = Instance.new("UICorner")
CommandListCloseCorner.CornerRadius = UDim.new(0, 5)
CommandListCloseCorner.Parent = CommandListClose

CommandListClose.MouseButton1Click:Connect(function()
    CommandList.Visible = false
end)

--------------------------------------
-- Drag Handling (for Command List)
--------------------------------------
local dragging = false
local dragStart, startPos

CommandList.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = CommandList.Position
    end
end)

CommandList.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        CommandList:TweenPosition(
            UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            ),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.05,
            true
        )
    end
end)

CommandList.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)


--------------------------------------
-- Toggle Command Bar with Semicolon
--------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        CommandBar.Visible = not CommandBar.Visible
        if CommandBar.Visible then
            CommandInput:CaptureFocus()
        else
            CommandInput:ReleaseFocus()
        end
    end
end)

-- Prevent accidental semicolons in input
CommandInput:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = CommandInput.Text
    if #txt > 0 and txt:sub(-1) == ";" then
        CommandInput.Text = txt:sub(1, -2)
    end
end)

--------------------------------------
-- Handle Commands on Enter
--------------------------------------
CommandInput.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end

    local command = CommandInput.Text:lower():gsub("^%s*(.-)%s*$", "%1") -- Trim spaces and lowercase
    CommandInput.Text = "" -- Clear input box after command is processed

    if command == "" then
        CommandBar.Visible = false
        CommandInput:ReleaseFocus()
        return
    end

    print("Command Entered: " .. command)

    --==[ START OF THE SINGLE IF-ELSEIF CHAIN ]==--

    if command == "killgui" then
        ---------------------------------------------------------------------
        -- killgui
        ---------------------------------------------------------------------
        print("Destroying GUI...")
        ScreenGui:Destroy()

    elseif command == "cmds" then
        ---------------------------------------------------------------------
        -- cmds
        ---------------------------------------------------------------------
        CommandList.Visible = not CommandList.Visible
        print("Toggled Command List GUI")

        -- re

    elseif command == "re" then
        ---------------------------------------------------------------------
        -- Reset Character and Return to Original Position (Manual Trigger Only)
        ---------------------------------------------------------------------
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Save original position if not already saved
            if not OriginalPosition then
                OriginalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                print("[INFO] Saved original position:", OriginalPosition)
            end
    
            -- Flag to indicate manual reset
            _G.ManualResetFlag = true
    
            -- Reset your character
            print("[INFO] Resetting character manually...")
            LocalPlayer.Character:BreakJoints()
    
            -- Handle respawn manually
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1) -- Wait briefly for character stabilization
    
            -- Verify and restore position after respawn
            if _G.ManualResetFlag and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Ensure OriginalPosition is a CFrame
                if typeof(OriginalPosition) == "Vector3" then
                    OriginalPosition = CFrame.new(OriginalPosition)
                end
    
                -- Teleport to the saved position
                LocalPlayer.Character.HumanoidRootPart.CFrame = OriginalPosition
                print("[SUCCESS] Respawn complete. Returned to original position:", OriginalPosition)
                
                -- Clear the saved position and manual flag
                OriginalPosition = nil
                _G.ManualResetFlag = false
            else
                warn("[ERROR] Failed to teleport after manual respawn. Missing HumanoidRootPart or OriginalPosition.")
            end
        else
            warn("[ERROR] No current character or HumanoidRootPart found. Cannot execute 're' command.")
        end    
    
    elseif command:sub(1,5) == "bring" then
        ---------------------------------------------------------------------
        -- bring [name]
        ---------------------------------------------------------------------
        local targetPrefix = command:sub(7):lower()
        local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                    or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
        
        if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Equip stroller
            tool.Parent = LocalPlayer.Character
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            task.wait(0.3)
            
            for _, player in ipairs(Players:GetPlayers()) do
                local playerName = player.Name:lower()
                local displayName = player.DisplayName:lower()
                
                if player ~= LocalPlayer
                   and (playerName:sub(1, #targetPrefix) == targetPrefix
                   or displayName:sub(1, #targetPrefix) == targetPrefix) then

                    if player.Character
                       and player.Character:FindFirstChild("HumanoidRootPart")
                       and player.Character:FindFirstChild("Humanoid") then

                        -- Teleport target slightly in front of you
                        player.Character:SetPrimaryPartCFrame(
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        )
                        task.wait(0.3)

                        -- Activate stroller so they can be “grabbed”
                        tool:Activate()
                        task.wait(0.3)

                        -- Final teleport: place target right on you
                        player.Character:SetPrimaryPartCFrame(
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                        )

                        -- Unequip stroller
                        tool.Parent = LocalPlayer.Backpack
                        print("Bring command completed. Target teleported to you.")
                        break
                    else
                        warn("Error: Target player is missing HumanoidRootPart or Humanoid.")
                    end
                end
            end
        else
            warn("Error: No stroller found or your character is missing HumanoidRootPart.")
        end


    elseif command:sub(1,4) == "goto" then
        ---------------------------------------------------------------------
        -- goto [name]
        ---------------------------------------------------------------------
        local targetPrefix = command:sub(6):lower()
        local targetFound = false

        for _, player in ipairs(Players:GetPlayers()) do
            local playerName = player.Name:lower()
            local displayName = player.DisplayName:lower()
            if player ~= LocalPlayer
               and (playerName:sub(1, #targetPrefix) == targetPrefix
               or displayName:sub(1, #targetPrefix) == targetPrefix) then

                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:SetPrimaryPartCFrame(
                        player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    )
                    print("Teleported to player: " .. player.Name)
                    targetFound = true
                    break
                end
            end
        end
        
        if not targetFound then
            print("Error: Unable to find target player.")
        end


    elseif command:sub(1,5) == "fling" then
        ---------------------------------------------------------------------
        -- fling [name]
        ---------------------------------------------------------------------
        local targetPrefix = command:sub(7):lower()
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))

    if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Equip the stroller if not already
        if tool.Parent ~= LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            task.wait(0.2)
        end

        -- Save our own original position
        local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        -- Find and teleport target in front
        for _, player in ipairs(Players:GetPlayers()) do
            local playerName = player.Name:lower()
            local displayName = player.DisplayName:lower()

            if player ~= LocalPlayer
               and (playerName:sub(1, #targetPrefix) == targetPrefix
               or displayName:sub(1, #targetPrefix) == targetPrefix) then

                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Teleport them in front of us
                    player.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    )
                    task.wait(0.1)

                    print("Activating stroller...")
                    tool:Activate()
                    task.wait(0.1)

                    -- SEAT DETECTION: Wait until target is seated (or timeout)
                    local targetHumanoid = player.Character:FindFirstChild("Humanoid")
                    if targetHumanoid then
                        local seatDetected = false
                        local seatTimeout = 5

                        print("Waiting up to " .. seatTimeout .. " seconds for target to sit...")

                        local startTime = tick()
                        while (tick() - startTime) < seatTimeout do
                            -- If the target's Humanoid is seated, we detect it here
                            if targetHumanoid.Sit == true then
                                seatDetected = true
                                break
                            end
                            task.wait(0.2)
                        end

                        if seatDetected then
                            print("Target is now seated. Commencing fling...")

                            -- Fling sequence
                            local flingStart = tick()
                            while (tick() - flingStart) < 1 do
                                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                                    math.random(-5000, 5000),
                                    math.random(-5000, 5000),
                                    math.random(-5000, 5000)
                                )
                                task.wait(0.03)
                            end

                            -- Return to original position
                            if LocalPlayer.Character 
                               and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                                tool.Parent = LocalPlayer.Backpack
                                print("Fling ended. Returned to original position.")
                            else
                                warn("Error: Missing HumanoidRootPart upon fling return.")
                            end

                            -- Optional: Stabilize if velocity is too high
                            task.wait(0.1)
                            local finalVelocity = LocalPlayer.Character.HumanoidRootPart.Velocity.Magnitude
                            print("Final velocity: " .. math.floor(finalVelocity))

                            if finalVelocity > 500 then
                                print("High velocity detected, anchoring character briefly...")
                                LocalPlayer.Character.HumanoidRootPart.Anchored = true
                                task.wait(1)
                                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                            end
                        else
                            -- If we reach here, user never sat
                            print("Target never sat. Fling aborted.")
                        end
                    else
                        -- No humanoid found; can't seat
                        warn("Target player missing Humanoid. Aborting fling.")
                    end
                    break
                else
                    warn("Error: Target player missing HumanoidRootPart.")
                end
            end
        end
    else
        warn("Error: No stroller found or missing HumanoidRootPart.")
    end

    elseif command:sub(1,4) == "view" then
        ---------------------------------------------------------------------
        -- view [name]
        ---------------------------------------------------------------------
		local targetPrefix = command:sub(6):lower()
        local targetPlayer = nil
    
        for _, player in ipairs(Players:GetPlayers()) do
            local playerName = player.Name:lower()
            local displayName = player.DisplayName:lower()
            if player ~= LocalPlayer
               and (playerName:sub(1, #targetPrefix) == targetPrefix
               or displayName:sub(1, #targetPrefix) == targetPrefix) then
                targetPlayer = player
                break
            end
        end
    
        if targetPlayer
           and targetPlayer.Character
           and targetPlayer.Character:FindFirstChild("Humanoid") then
    
            local camera = workspace.CurrentCamera
    
            -- Store old camera settings so we can restore them on `unview`
            oldCamSubject = camera.CameraSubject
            oldCamType = camera.CameraType
    
            -- Make the camera follow the target player's Humanoid
            camera.CameraSubject = targetPlayer.Character.Humanoid
            camera.CameraType = Enum.CameraType.Follow
    
            print("Viewing player: " .. targetPlayer.Name)
        else
            warn("Error: Could not find a valid target player to view.")
        end

    elseif command == "unview" then
        ---------------------------------------------------------------------
        -- unview
        ---------------------------------------------------------------------
        local camera = workspace.CurrentCamera
    
        -- If your own character's Humanoid is alive, we can revert to it.
        if LocalPlayer.Character
           and LocalPlayer.Character:FindFirstChild("Humanoid") then
    
            -- If we stored oldCamSubject/oldCamType, restore them;
            -- otherwise just revert to your character.
            if oldCamSubject and oldCamType then
                camera.CameraSubject = oldCamSubject
                camera.CameraType = oldCamType
            else
                camera.CameraSubject = LocalPlayer.Character.Humanoid
                camera.CameraType = Enum.CameraType.Custom
            end
    
            print("Camera reset to your character.")
        else
            warn("Error: Your character is not available to reset the camera.")
        end
    
        -- Clear out old references
        oldCamSubject = nil
        oldCamType = nil 

    elseif command:sub(1,7) == "skydive" then
        ---------------------------------------------------------------------
        -- skydive [name]
        ---------------------------------------------------------------------
        local targetPrefix = command:sub(9):lower()
        local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                    or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))

        if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if tool.Parent ~= LocalPlayer.Character then
                tool.Parent = LocalPlayer.Character
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                task.wait(0.2)
            end

            local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

            for _, player in ipairs(Players:GetPlayers()) do
                local playerName = player.Name:lower()
                local displayName = player.DisplayName:lower()

                if player ~= LocalPlayer
                   and (playerName:sub(1, #targetPrefix) == targetPrefix
                   or displayName:sub(1, #targetPrefix) == targetPrefix) then

                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character:SetPrimaryPartCFrame(
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        )
                        task.wait(0.2)

                        print("Activating stroller...")
                        tool:Activate()
                        task.wait(0.2)

                        print("Teleporting high above the map...")
                        LocalPlayer.Character:SetPrimaryPartCFrame(
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5000, 0)
                        )
                        task.wait(0.5)

                        print("Returning to original position...")
                        if LocalPlayer.Character
                           and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                            tool.Parent = LocalPlayer.Backpack
                            print("Returned to original position.")
                        else
                            warn("Error: Missing HumanoidRootPart for return.")
                        end
                        
                        break
                    else
                        warn("Error: Target missing HumanoidRootPart.")
                    end
                end
            end
        else
            warn("Error: No stroller found or missing HumanoidRootPart.")
        end

    elseif command == "revealusers" then
        ---------------------------------------------------------------------
        -- revealusers
        ---------------------------------------------------------------------
        print("Revealing all players' real usernames...")
    
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            -- Skip if no character or Humanoid
            local char = targetPlayer.Character
            if not char or not char:FindFirstChild("Humanoid") then
                continue
            end
            
            -- Hide default overhead name/health UI
            char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            
            -- Find character head
            local head = char:FindFirstChild("Head")
            if not head then
                warn("No head found for player:", targetPlayer.Name)
                continue
            end
            
            -- Check if we already made a billboard
            local existingBillboard = char:FindFirstChild("UserBillboard")
            if existingBillboard then
                local textLabel = existingBillboard:FindFirstChild("UsernameLabel")
                if textLabel then
                    textLabel.Text = targetPlayer.Name
                end
            else
                -- Create a BillboardGui for the real username
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "UserBillboard"
                billboard.Adornee = head
                billboard.Parent = char
                billboard.AlwaysOnTop = true
                
                -- A smaller billboard to mimic standard overhead text sizing
                billboard.Size = UDim2.new(0, 100, 0, 20)
                billboard.StudsOffset = Vector3.new(0, 2, 0) 
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "UsernameLabel"
                textLabel.Parent = billboard
                textLabel.BackgroundTransparency = 1
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Font = Enum.Font.SourceSans
                textLabel.TextSize = 14 -- Typical overhead text size
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextScaled = false
                textLabel.Text = targetPlayer.Name
            end
        end    

    elseif command == "unrevealusers" then
        ---------------------------------------------------------------------
        -- unrevealusers
        ---------------------------------------------------------------------
		print("Reverting players to default overhead nametags...")
	
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			local char = targetPlayer.Character
			if not char or not char:FindFirstChild("Humanoid") then
				continue
			end
	
			-- Restore the default overhead name/health UI
			char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	
			-- Remove our custom BillboardGui that shows the real username
			local userBillboard = char:FindFirstChild("UserBillboard")
			if userBillboard and userBillboard:IsA("BillboardGui") then
				userBillboard:Destroy()
			end
		end	

    elseif command:sub(1,4) == "void" then
        ---------------------------------------------------------------------
        -- void [name]
        ---------------------------------------------------------------------
        local targetPrefix = command:sub(6):lower()
        local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
    
        if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Save original position
            local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    
            -- Ensure return to original position after respawn
            local respawnConnection
            respawnConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                local hrp = character:WaitForChild("HumanoidRootPart", 5)
                if hrp then
                    task.wait(1)
                    character:SetPrimaryPartCFrame(originalPosition)
                    print("[INFO] Respawn detected. Returned to original position.")
                    respawnConnection:Disconnect()
                else
                    warn("[ERROR] Respawn failed: Missing HumanoidRootPart.")
                end
            end)
    
            -- Equip the stroller
            tool.Parent = LocalPlayer.Character
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            task.wait(0.3)
    
            -- Handle Unequip event
            local unequipConnection
            unequipConnection = tool.Unequipped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                    print("[INFO] Stroller unequipped. Returned to original position.")
                    unequipConnection:Disconnect()
                end
            end)
    
            -- Search for the target
            local found = false
            for _, player in ipairs(Players:GetPlayers()) do
                local pName = player.Name:lower()
                local pDisplay = player.DisplayName:lower()
    
                if player ~= LocalPlayer
                   and (pName:sub(1, #targetPrefix) == targetPrefix
                   or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
    
                    if player.Character
                       and player.Character:FindFirstChild("HumanoidRootPart")
                       and player.Character:FindFirstChild("Humanoid") then
    
                        found = true
    
                        -- Teleport target player in front of you
                        player.Character:SetPrimaryPartCFrame(
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                        )
                        task.wait(0.2)
    
                        -- Activate stroller
                        tool:Activate()
                        task.wait(0.2)
    
                        -- Teleport YOU beneath the map
                        print("[INFO] Sinking beneath the map...")
                        LocalPlayer.Character:SetPrimaryPartCFrame(
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -300, 0)
                        )
                        task.wait(1)
    
                        -- Unequip stroller manually
                        tool.Parent = LocalPlayer.Backpack
                        if unequipConnection then unequipConnection:Disconnect() end
                        print("[SUCCESS] Void command completed. Returning to original position.")
                        break
                    else
                        warn("[ERROR] Target player missing HumanoidRootPart or Humanoid.")
                    end
                end
            end
    
            if not found then
                print("[ERROR] No matching player found for: " .. targetPrefix)
            end
    
            -- Final fallback to ensure return to original position
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
            end
    
            -- Cleanup: Disconnect connections to avoid memory leaks
            if respawnConnection then respawnConnection:Disconnect() end
            if unequipConnection then unequipConnection:Disconnect() end
        else
            warn("[ERROR] Missing stroller or HumanoidRootPart.")
        end    
    
    elseif command:sub(1,4) == "jail" then
        ---------------------------------------------------------------------
        -- jail [name]
        ---------------------------------------------------------------------
        local targetPrefix = command:sub(6):lower()
    
        -- The "jail" location: 
        local jailCFrame = CFrame.new(
            -679.82431, 38.99998, 165.757706, 
            -0.551903725, -4.11753334e-08, 0.833907843,
            -5.06281062e-08, 1, 3.34608785e-08,
            -0.833907843, -5.06281062e-08, -0.551903725
        )
    
        -- Make sure your character exists
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            warn("[ERROR] Your character is invalid or missing HumanoidRootPart.")
            return
        end
    
        -- Store your original position
        local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    
        -- Find the stroller
        local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                    or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
        if not tool then
            warn("[ERROR] No 'Stroller' gear found in your backpack/character.")
            return
        end
    
        -- Equip stroller if not already
        if tool.Parent ~= LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            task.wait(0.3)
        end
    
        -- Handle Unequip event
        local unequipConnection
        unequipConnection = tool.Unequipped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                print("[INFO] Stroller unequipped. Returned to original position.")
                unequipConnection:Disconnect()
            end
        end)
    
        -- Teleport YOU to jail coords
        LocalPlayer.Character:SetPrimaryPartCFrame(jailCFrame)
        task.wait(0.3)
    
        -- Find target player
        local foundPlayer = nil
        for _, player in pairs(Players:GetPlayers()) do
            local pName = player.Name:lower()
            local pDisplay = player.DisplayName:lower()
            if player ~= LocalPlayer
               and (pName:sub(1, #targetPrefix) == targetPrefix
               or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
                foundPlayer = player
                break
            end
        end
    
        if not foundPlayer then
            warn("[ERROR] No matching player found for: " .. targetPrefix)
            return
        end
    
        -- Make sure target has a valid character
        local targetChar = foundPlayer.Character
        if not targetChar 
           or not targetChar:FindFirstChild("HumanoidRootPart") 
           or not targetChar:FindFirstChild("Humanoid") then
            warn("[ERROR] Target missing Character/HumanoidRootPart/Humanoid.")
            return
        end
    
        -- Teleport the target in front of you (at the jail location)
        targetChar:SetPrimaryPartCFrame(
            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        )
        task.wait(0.2)
    
        -- Activate stroller so they can sit
        print("[INFO] Activating stroller for jail command...")
        tool:Activate()
        task.wait(0.3)
    
        -- Wait up to 5s for them to sit
        local seatTimeout = 5
        local seatDetected = false
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        if targetHumanoid then
            print("[INFO] Waiting up to " .. seatTimeout .. " seconds for target to sit...")
    
            local startTime = tick()
            while (tick() - startTime) < seatTimeout do
                if targetHumanoid.Sit == true then
                    seatDetected = true
                    break
                end
                task.wait(0.2)
            end
        end
    
        if seatDetected then
            print("[SUCCESS] Target is now seated in jail. Teleporting you back home...")
        else
            print("[WARNING] Target never sat. Leaving them in jail. Teleporting you back...")
        end
    
        -- Teleport YOU back to original position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
            -- Unequip the stroller manually
            tool.Parent = LocalPlayer.Backpack
            if unequipConnection then unequipConnection:Disconnect() end
            print("[SUCCESS] You're back at your original location. Target remains in jail.")
        else
            warn("[ERROR] Missing your HumanoidRootPart upon final return.")
        end
    
        -- Final cleanup to ensure event disconnection
        if unequipConnection then unequipConnection:Disconnect() end    

    elseif command:sub(1,6) == "rocket" then
        ---------------------------------------------------------------------
        -- rocket [name]
        ---------------------------------------------------------------------
		local targetPrefix = command:sub(8):lower()

		-- Make sure your character is valid
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			warn("Error: Your character is invalid or missing HumanoidRootPart.")
			return
		end
	
		-- Save your original position
		local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
	
		-- Find the stroller
		local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
			or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
		if not tool then
			warn("Error: No 'Stroller' gear found in your backpack or character.")
			return
		end
	
		-- Equip the stroller if not already
		if tool.Parent ~= LocalPlayer.Character then
			tool.Parent = LocalPlayer.Character
			LocalPlayer.Character.Humanoid:EquipTool(tool)
			task.wait(0.3)
		end
	
		-- Connect an event so if the stroller is unequipped prematurely,
		-- we instantly teleport you back to your original position
		local unequippedConnection
		unequippedConnection = tool.Unequipped:Connect(function()
			if unequippedConnection and unequippedConnection.Connected then
				unequippedConnection:Disconnect()
			end
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
				print("Stroller unequipped early. Teleporting you back immediately.")
			end
		end)
	
		-- Find the target by partial name
		local foundPlayer
		for _, player in ipairs(Players:GetPlayers()) do
			local pName = player.Name:lower()
			local pDisplay = player.DisplayName:lower()
			if player ~= LocalPlayer
				and (pName:sub(1, #targetPrefix) == targetPrefix
				or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
	
				foundPlayer = player
				break
			end
		end
	
		if not foundPlayer then
			warn("No player found matching: " .. targetPrefix)
			return
		end
	
		-- Validate target's character
		local targetChar = foundPlayer.Character
		if not targetChar
		   or not targetChar:FindFirstChild("HumanoidRootPart")
		   or not targetChar:FindFirstChild("Humanoid") then
			warn("Target is missing a valid Character, HumanoidRootPart, or Humanoid.")
			return
		end
	
		-- Teleport target right in front of you
		targetChar:SetPrimaryPartCFrame(
			LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		)
		task.wait(0.3)
	
		-- Activate stroller, so they can sit
		print("Activating stroller for rocket command...")
		tool:Activate()
		task.wait(0.3)
	
		-- Wait for target to actually sit in the stroller seat
		local seatTimeout = 5
		local seatDetected = false
		local targetHumanoid = targetChar:FindFirstChild("Humanoid")
	
		if targetHumanoid then
			print("Waiting up to ".. seatTimeout .." seconds for the target to sit...")
			local startTime = tick()
			while (tick() - startTime) < seatTimeout do
				if targetHumanoid.Sit == true then
					seatDetected = true
					break
				end
				task.wait(0.2)
			end
		end
	
		if not seatDetected then
			-- If we reach here, the target never sat in the stroller
			print("Target never sat in stroller. Aborting rocket.")
			return
		end
	
		print("Target is seated. Commencing rocket...")
	
		-- "Rocket" time: Launch you upward by applying a BodyVelocity
		local hrp = LocalPlayer.Character.HumanoidRootPart
		local launchSpeed = 500
	
		local bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(0, 1e8, 0) -- Only vertical movement
		bodyVel.Velocity = Vector3.new(0, launchSpeed, 0)
		bodyVel.Parent = hrp
	
		print("Launching you upward for 2 seconds...")
		task.wait(2)
	
		-- After 2 seconds, remove the BodyVelocity
		bodyVel:Destroy()
	
		-- Unequip the stroller -> the target stays in midair (or falls) 
		tool.Parent = LocalPlayer.Backpack
		print("Stroller unequipped. Target remains while you return.")
	
		-- Teleport YOU back to your original position
		if unequippedConnection and unequippedConnection.Connected then
			unequippedConnection:Disconnect()
		end
		LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
		print("Rocket command complete. You are safely back at your original spot.")

    elseif command == "noclip" then
        ---------------------------------------------------------------------
        -- noclip
        ---------------------------------------------------------------------
        print("Noclip enabled! You can walk through walls now.")

    local RunService = game:GetService("RunService")
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    -- We'll create a connection to keep setting CanCollide = false
    -- each frame for all parts in your character.
    local noclipConnection

    local function disableCollisions()
        if not character or not character.Parent then
            return
        end
        -- For every BasePart in your character, set CanCollide = false
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.CanCollide then
                descendant.CanCollide = false
            end
        end
    end

    -- Start disabling collisions each Heartbeat
    noclipConnection = RunService.Heartbeat:Connect(function()
        disableCollisions()
    end)

    -- (Optional) A small message or instructions
    -- If you want to re-enable collisions, you'd do a separate command (e.g. "clip")
    -- that calls noclipConnection:Disconnect() and resets collisions.

    elseif command == "clip" then
        ---------------------------------------------------------------------
        -- clip
        ---------------------------------------------------------------------
		-- If you stored the 'noclipConnection' in a variable accessible here:
		if noclipConnection and noclipConnection.Connected then
			noclipConnection:Disconnect()
		end
	
		local character = LocalPlayer.Character
		if character then
			-- Reset collisions to true (optional)
			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = true
				end
			end
		end
	
		print("Collisions re-enabled. You can no longer walk through walls.")
        
-- banlands [name] (teleports player to the banlands altitude)

elseif command:sub(1,8) == "banlands" then
    local targetPrefix = command:sub(10):lower()
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))

    if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Save original position
        local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

        -- Ensure return to original position after respawn
        local respawnConnection
        respawnConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                task.wait(1)
                character:SetPrimaryPartCFrame(originalPosition)
                print("[INFO] Respawn detected. Returned to original position.")
                respawnConnection:Disconnect()
            else
                warn("[ERROR] Failed to teleport back after respawn due to missing HumanoidRootPart.")
            end
        end)

        -- Equip the stroller
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)

        -- Handle Unequip event
        local unequipConnection
        unequipConnection = tool.Unequipped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                print("[INFO] Stroller unequipped. Returned to original position.")
                unequipConnection:Disconnect()
            end
        end)

        -- Search for the target
        local found = false
        for _, player in ipairs(Players:GetPlayers()) do
            local pName = player.Name:lower()
            local pDisplay = player.DisplayName:lower()

            if player ~= LocalPlayer
               and (pName:sub(1, #targetPrefix) == targetPrefix
               or pDisplay:sub(1, #targetPrefix) == targetPrefix) then

                if player.Character
                   and player.Character:FindFirstChild("HumanoidRootPart")
                   and player.Character:FindFirstChild("Humanoid") then

                    found = true

                    -- Teleport target player in front of you
                    player.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    )
                    task.wait(0.2)

                    -- Activate stroller (to ensure they are grabbed)
                    tool:Activate()
                    task.wait(0.2)

                    -- Teleport YOU to banlands altitude
                    print("[INFO] Teleporting to banlands altitude...")
                    LocalPlayer.Character:SetPrimaryPartCFrame(
                        CFrame.new(0, 100000000, 0)
                    )
                    task.wait(1)

                    -- Unequip stroller to trigger return
                    tool.Parent = LocalPlayer.Backpack
                    unequipConnection:Disconnect()
                    print("[SUCCESS] Banlands command completed. Returning to original position.")
                    break
                else
                    warn("[ERROR] Target player missing HumanoidRootPart or Humanoid.")
                end
            end
        end

        if not found then
            print("[ERROR] No matching player found for: " .. targetPrefix)
        end

        -- Final fallback to ensure return to original position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
        end
    else
        warn("[ERROR] Missing stroller or HumanoidRootPart.")
    end

    -- Variables for the annoy command
local isAnnoying = false
local annoyTarget = nil
local annoyTool = nil

-- Variables for the annoy command
local isAnnoying = false
local annoyTarget = nil
local annoyTool = nil

-- Variables for the annoy command
local isAnnoying = false
local annoyTarget = nil
local annoyTool = nil

--------------------------------------
-- annoy [name] (rapidly teleports behind the target and equips/unequips the stroller)
-- Stop the annoy loop when the player respawns
LocalPlayer.CharacterAdded:Connect(function()
    if isAnnoying then
        isAnnoying = false
        print("Player respawned. Stopped annoying process.")
        annoyTarget = nil
        annoyTool = nil
    end
end)

elseif command:sub(1,5) == "annoy" then
    local targetPrefix = command:sub(7):lower()

    -- Find the target player
    for _, player in ipairs(Players:GetPlayers()) do
        local playerName = player.Name:lower()
        local displayName = player.DisplayName:lower()
        if player ~= LocalPlayer
           and (playerName:sub(1, #targetPrefix) == targetPrefix
           or displayName:sub(1, #targetPrefix) == targetPrefix) then
            annoyTarget = player
            break
        end
    end

    -- Check if the target player is valid
    if annoyTarget and annoyTarget.Character and annoyTarget.Character:FindFirstChild("HumanoidRootPart") then
        -- Find the stroller tool
        annoyTool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                    or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))

        if annoyTool then
            isAnnoying = true
            print("Annoying " .. annoyTarget.Name .. "...")

            -- Start the annoy loop
            while isAnnoying do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    -- Calculate the position behind the target
                    local targetCFrame = annoyTarget.Character.HumanoidRootPart.CFrame
                    local teleportCFrame = targetCFrame * CFrame.new(0, 0, 5) -- Teleport 5 studs behind

                    -- Teleport to the position behind the target
                    LocalPlayer.Character:SetPrimaryPartCFrame(teleportCFrame)

                    -- Face the target
                    local lookAtCFrame = CFrame.lookAt(
                        LocalPlayer.Character.HumanoidRootPart.Position,
                        targetCFrame.Position
                    )
                    LocalPlayer.Character:SetPrimaryPartCFrame(lookAtCFrame)

                    -- Equip the stroller
                    annoyTool.Parent = LocalPlayer.Character
                    LocalPlayer.Character.Humanoid:EquipTool(annoyTool)
                    task.wait(0.05)

                    -- Unequip the stroller
                    annoyTool.Parent = LocalPlayer.Backpack
                    task.wait(0.05)
                else
                    warn("Error: Your character is missing HumanoidRootPart.")
                    break
                end
            end
        else
            warn("Error: No stroller found in your backpack or character.")
        end
    else
        warn("Error: Target player not found or missing HumanoidRootPart.")
    end

--------------------------------------
-- unannoy (stops the annoying process)
elseif command == "unannoy" then
    if isAnnoying then
        isAnnoying = false
        print("Stopped annoying " .. (annoyTarget and annoyTarget.Name or "the target") .. ".")
        annoyTarget = nil
        annoyTool = nil
    else
        print("No annoying process is currently running.")
    end

elseif command:sub(1,4) == "kill" then
    ---------------------------------------------------------------------
    -- kill [name]
    ---------------------------------------------------------------------
    local targetPrefix = command:sub(6):lower()
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
        or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))

    if tool 
       and LocalPlayer.Character 
       and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

        -- Store your original position
        local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

        -- Equip the stroller
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)

        -- Handle Unequip event for safety
        local unequipConnection
        unequipConnection = tool.Unequipped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                print("[INFO] Stroller unequipped. Returned to original position.")
                unequipConnection:Disconnect()
            end
        end)

        -- Search for the target
        local found = false
        for _, player in ipairs(Players:GetPlayers()) do
            local pName = player.Name:lower()
            local pDisplay = player.DisplayName:lower()

            if player ~= LocalPlayer
               and (pName:sub(1, #targetPrefix) == targetPrefix
               or pDisplay:sub(1, #targetPrefix) == targetPrefix) then

                if player.Character
                   and player.Character:FindFirstChild("HumanoidRootPart")
                   and player.Character:FindFirstChild("Humanoid") then

                    found = true

                    -- Save the target's current position BEFORE "killing" them (optional)
                    local targetHRP = player.Character.HumanoidRootPart
                    local positionBeforeKill = targetHRP.CFrame
                    _G.LastPreKillPosition = positionBeforeKill

                    -- Teleport target a bit in front of you
                    player.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    )
                    task.wait(0.2)

                    -- Activate stroller (so they can be 'grabbed')
                    tool:Activate()
                    task.wait(0.2)

                    -- Teleport YOU beneath the map
                    print("[INFO] Proceeding to kill...")
                    LocalPlayer.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -480, 0)
                    )
                    task.wait(0.25)

                    -- Unequip stroller
                    tool.Parent = LocalPlayer.Backpack
                    unequipConnection:Disconnect()

                    -- Ensure proper return to original position
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                        print("[SUCCESS] Kill command completed. Returned to original position.")
                    else
                        warn("[ERROR] Failed to return to original position after kill command.")
                    end
                    break
                else
                    warn("[ERROR] Target player is missing HumanoidRootPart or Humanoid.")
                end
            end
        end

        if not found then
            print("[ERROR] No matching player found for: " .. targetPrefix)
        end

    else
        warn("[ERROR] Missing stroller or HumanoidRootPart.")
    end

elseif command == "fix" then
    ---------------------------------------------------------------------
    -- fix
    --   Clears or resets all your known positions to a default state.
    ---------------------------------------------------------------------
    
    -- Set them back to defaults (e.g., (0,0,0) or nil)
    OriginalPosition = Vector3.new(0,0,0)
    SomeOtherPosition = Vector3.new(0,0,0)
    -- ... repeat for any other positional variables
    
    print("fix: All known positions have been reset to defaults.")

elseif command:sub(1,2) == "tp" then
    ---------------------------------------------------------------------
    -- tp <user1> <user2>
    -- 1) Save your original pos
    -- 2) Equip stroller
    -- 3) Teleport user1 in front, 'grab' them
    -- 4) Teleport you (and them) to user2
    -- 5) Drop user1
    -- 6) Teleport you back
    ---------------------------------------------------------------------

    -- Split the command by spaces
    local parts = command:split(" ")
    if #parts < 3 then
        warn("Usage: tp <user1> <user2>")
        return
    end

    local user1Prefix = parts[2]:lower()
    local user2Prefix = parts[3]:lower()

    -- Find user1 & user2 by partial name
    local user1, user2 = nil, nil
    for _, p in ipairs(Players:GetPlayers()) do
        local pName = p.Name:lower()
        local dName = p.DisplayName:lower()

        if not user1 
           and (pName:sub(1, #user1Prefix) == user1Prefix
             or dName:sub(1, #user1Prefix) == user1Prefix) then
            user1 = p
        end
        if not user2
           and (pName:sub(1, #user2Prefix) == user2Prefix
             or dName:sub(1, #user2Prefix) == user2Prefix) then
            user2 = p
        end
        if user1 and user2 then
            break
        end
    end

    if not user1 then
        warn("tp: Could not find user1: " .. user1Prefix)
        return
    end
    if not user2 then
        warn("tp: Could not find user2: " .. user2Prefix)
        return
    end
    if user1 == LocalPlayer then
        warn("tp: You cannot pick up yourself as user1!")
        return
    end
    if user1 == user2 then
        warn("tp: user1 and user2 are the same person!")
        return
    end

    -- We proceed with the stroller logic if we have:
    -- 1) A stroller
    -- 2) Our own character/HRP
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
    local myChar = LocalPlayer.Character
    if not (tool and myChar and myChar:FindFirstChild("HumanoidRootPart")) then
        warn("tp: Missing stroller or your character is invalid.")
        return
    end

    -- user1 must have a char + HRP + Humanoid
    local c1 = user1.Character
    if not (c1 and c1:FindFirstChild("HumanoidRootPart") and c1:FindFirstChild("Humanoid")) then
        warn("tp: user1 missing HRP/Humanoid.")
        return
    end

    -- user2 must have a char + HRP
    local c2 = user2.Character
    if not (c2 and c2:FindFirstChild("HumanoidRootPart")) then
        warn("tp: user2 missing HRP.")
        return
    end

    -- 1) Save your original position
    local originalPos = myChar.HumanoidRootPart.CFrame

    -- 2) Equip stroller
    tool.Parent = myChar
    myChar.Humanoid:EquipTool(tool)
    task.wait(0.3)

    -- 3) Teleport user1 in front of you, "grab" them with stroller
    c1:SetPrimaryPartCFrame(
        myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    )
    task.wait(0.2)
    tool:Activate()  -- "grab" them
    task.wait(0.2)

    -- 4) Teleport YOU (and thus them in your stroller) to user2's position
    local user2Pos = c2.HumanoidRootPart.CFrame
    print("Teleporting you + user1 to user2’s location...")
    myChar:SetPrimaryPartCFrame(user2Pos * CFrame.new(0,0,5))
    task.wait(0.5)

    -- 5) Drop user1 (unequip stroller => user1 is left behind)
    tool.Parent = LocalPlayer.Backpack
    print("Dropped user1 at user2's location.")

    -- 6) Teleport you back to original position
    myChar:SetPrimaryPartCFrame(originalPos)
    print("Returned you to your original spot.")

elseif command:sub(1,9) == "highpoint" then
   
    local targetPrefix = command:sub(11):lower()

    local highpointCFrame = CFrame.new(
    -970.27734, 209.968979, -193.61305,
    -0.967470527, 5.93599054e-08,  0.252983719,
     5.12842e-08,  1,             -3.85161272e-08,
    -0.252983719, -2.42891485e-08, -0.967470527
)


    -- Make sure your character exists
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Error: Your character is invalid or missing HumanoidRootPart.")
        return
    end

    -- Store your original position
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    -- Find the stroller
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
    if not tool then
        warn("Error: No 'Stroller' gear found in your backpack/character.")
        return
    end

    -- Equip stroller if not already
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)
    end

    -- Teleport YOU to highpoint coords
    LocalPlayer.Character:SetPrimaryPartCFrame(highpointCFrame)
    task.wait(0.3)

    -- Find target player
    local foundPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        local pName = player.Name:lower()
        local pDisplay = player.DisplayName:lower()
        if player ~= LocalPlayer
           and (pName:sub(1, #targetPrefix) == targetPrefix
           or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
            foundPlayer = player
            break
        end
    end

    if not foundPlayer then
        print("No matching player found for: " .. targetPrefix)
        return
    end

    -- Make sure target has a valid character
    local targetChar = foundPlayer.Character
    if not targetChar 
       or not targetChar:FindFirstChild("HumanoidRootPart") 
       or not targetChar:FindFirstChild("Humanoid") then
        warn("Target missing Character/HumanoidRootPart/Humanoid.")
        return
    end

    -- Teleport the target in front of you (at the highpoint location)
    targetChar:SetPrimaryPartCFrame(
        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    )
    task.wait(0.3)

    -- Activate stroller so they can sit
    print("Activating stroller for highpoint command...")
    tool:Activate()
    task.wait(0.3)

    -- Wait up to 5s for them to sit
    local seatTimeout = 5
    local seatDetected = false
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        print("Waiting up to "..seatTimeout.." seconds for target to sit...")

        local startTime = tick()
        while (tick() - startTime) < seatTimeout do
            if targetHumanoid.Sit == true then
                seatDetected = true
                break
            end
            task.wait(0.2)
        end
    end

    if seatDetected then
        print("Target is now seated at highpoint. Teleporting you back home...")
    else
        print("Target never sat. We'll still leave them here at highpoint. Teleporting you back...")
    end

    -- Teleport YOU back to original position
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
        -- Optionally un-equip the stroller
        tool.Parent = LocalPlayer.Backpack
        print("You're back at your original location. Target remains at highpoint.")
    else
        warn("Error: Missing your HumanoidRootPart upon final return.")
    end

elseif command:sub(1,9) == "fireplace" then
   
    local targetPrefix = command:sub(11):lower()

    local highpointCFrame = CFrame.new(
    -138.025406, 40.4750977, -206.529129,
    -0.000784904696, -0.144901007, -0.989445865,
    -0.00690736901, 0.989423335, -0.144892231,
    0.99997586, 0.00672074081, -0.00177748781
)

    -- Make sure your character exists
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Error: Your character is invalid or missing HumanoidRootPart.")
        return
    end

    -- Store your original position
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    -- Find the stroller
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
    if not tool then
        warn("Error: No 'Stroller' gear found in your backpack/character.")
        return
    end

    -- Equip stroller if not already
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)
    end

    -- Teleport YOU to highpoint coords
    LocalPlayer.Character:SetPrimaryPartCFrame(highpointCFrame)
    task.wait(0.3)

    -- Find target player
    local foundPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        local pName = player.Name:lower()
        local pDisplay = player.DisplayName:lower()
        if player ~= LocalPlayer
           and (pName:sub(1, #targetPrefix) == targetPrefix
           or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
            foundPlayer = player
            break
        end
    end

    if not foundPlayer then
        print("No matching player found for: " .. targetPrefix)
        return
    end

    -- Make sure target has a valid character
    local targetChar = foundPlayer.Character
    if not targetChar 
       or not targetChar:FindFirstChild("HumanoidRootPart") 
       or not targetChar:FindFirstChild("Humanoid") then
        warn("Target missing Character/HumanoidRootPart/Humanoid.")
        return
    end

    -- Teleport the target in front of you (at the highpoint location)
    targetChar:SetPrimaryPartCFrame(
        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    )
    task.wait(0.3)

    -- Activate stroller so they can sit
    print("Activating stroller for highpoint command...")
    tool:Activate()
    task.wait(0.3)

    -- Wait up to 5s for them to sit
    local seatTimeout = 5
    local seatDetected = false
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        print("Waiting up to "..seatTimeout.." seconds for target to sit...")

        local startTime = tick()
        while (tick() - startTime) < seatTimeout do
            if targetHumanoid.Sit == true then
                seatDetected = true
                break
            end
            task.wait(0.2)
        end
    end

    if seatDetected then
        print("Target is now seated at highpoint. Teleporting you back home...")
    else
        print("Target never sat. We'll still leave them here at highpoint. Teleporting you back...")
    end

    -- Teleport YOU back to original position
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
        -- Optionally un-equip the stroller
        tool.Parent = LocalPlayer.Backpack
        print("You're back at your original location. Target remains at highpoint.")
    else
        warn("Error: Missing your HumanoidRootPart upon final return.")
    end

    ---------------------------------------------------------------------
-- Example: "cleanup" command to undo script changes
---------------------------------------------------------------------
elseif command:sub(1,7) == "cleanup" then
    -- 1) Disconnect any relevant connections you made
    --    (If your script stored them in a table called 'Connections')
    if Connections then
        for _, conn in ipairs(Connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        Connections = {}
    end

    -- 2) Reset your Humanoid, if desired
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            -- Re-enable "Dead" state in case you disabled it
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            -- Let joints break on death again
            hum.BreakJointsOnDeath = true
            -- Return health to normal
            hum.MaxHealth = 100
            hum.Health = hum.MaxHealth
        end
    end

    -- 3) Destroy or remove any leftover Strollers, if you want
    --    (In Character or Backpack)
    local function destroyIfExists(obj)
        if obj and obj.Parent then
            obj:Destroy()
        end
    end

    if char then
        destroyIfExists(char:FindFirstChild("Stroller"))
    end
    destroyIfExists(LocalPlayer.Backpack:FindFirstChild("Stroller"))

    -- 4) Clear any stored global positions or variables
    _G.LastPreKillPosition = nil
    _G.SomeOtherGlobal = nil
    -- etc.

    print("Cleanup complete: reverted script effects without rejoining.")

elseif command:sub(1,3) == "sit" then
    -- Usage Example: "sit bob"
    local targetPrefix = command:match("^sit%s+(%S+)")
    if not targetPrefix then
        warn("Error: No username provided after 'sit'")
        return
    end

    -- Find the target player
    local targetPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        local pName = player.Name:lower()
        local pDisplay = player.DisplayName:lower()
        if player ~= LocalPlayer
           and (pName:sub(1, #targetPrefix) == targetPrefix
           or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
            targetPlayer = player
            break
        end
    end

    if not targetPlayer then
        warn("Error: Could not find player matching '" .. targetPrefix .. "'")
        return
    end

    -- Check if the target has a torso (R6)
    local targetChar = targetPlayer.Character
    if not targetChar then
        warn("Error: Target player has no character.")
        return
    end

    local torso = targetChar:FindFirstChild("Torso")
    if not torso then
        warn("Error: Target is missing 'Torso'.")
        return
    end

    -- Ensure your character is valid
    local yourChar = LocalPlayer.Character
    if not yourChar then
        warn("Error: Your character does not exist.")
        return
    end

    local yourHum = yourChar:FindFirstChild("Humanoid")
    local yourHRP = yourChar:FindFirstChild("HumanoidRootPart")
    if not (yourHum and yourHRP) then
        warn("Error: Your character is missing Humanoid or HumanoidRootPart.")
        return
    end

    ------------------------------------------------
    -- 1) Calculate the position at foot level in front of the target
    ------------------------------------------------
    local targetPosition = torso.CFrame * CFrame.new(0, -2.5, -2) -- Adjust Y and Z offsets for foot level
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {workspace.Terrain, targetChar}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    -- Raycast to find the floor in front of the target
    local raycastResult = workspace:Raycast(targetPosition.Position, Vector3.new(0, -10, 0), raycastParams)
    if raycastResult then
        targetPosition = CFrame.new(raycastResult.Position) * CFrame.new(0, 0.5, 0) -- Adjust Y offset for seating
    else
        warn("Error: Could not find the floor in front of the target.")
        return
    end

    ------------------------------------------------
    -- 2) Create a Seat at foot level in front of the target
    ------------------------------------------------
    local seat = Instance.new("Seat")
    seat.Name = "FootSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.Anchored = false -- Allow the seat to move with the target
    seat.CanCollide = true
    seat.Transparency = 1 -- Make the seat invisible
    seat.TopSurface = Enum.SurfaceType.Smooth
    seat.BottomSurface = Enum.SurfaceType.Smooth
    seat.CFrame = targetPosition
    seat.Parent = workspace

    ------------------------------------------------
    -- 3) Attach the seat to the target's torso
    ------------------------------------------------
    local weld = Instance.new("WeldConstraint")
    weld.Name = "SeatWeld"
    weld.Part0 = seat
    weld.Part1 = torso
    weld.Parent = seat

    ------------------------------------------------
    -- 4) Force your character to sit on the seat
    ------------------------------------------------
    -- Teleport your character to the seat
    yourHRP.CFrame = seat.CFrame * CFrame.new(0, 0.5, 0) -- Adjust Y offset to sit properly
    task.wait(0.1) -- Wait briefly to ensure teleportation

    -- Sit on the seat
    seat:Sit(yourHum)
    task.wait(0.5) -- Give Roblox time to register seating

    -- Ensure you're seated; fallback teleport to seat if needed
    if yourHum.Sit ~= true then
        yourHRP.CFrame = seat.CFrame * CFrame.new(0, 1.5, 0)
        seat:Sit(yourHum)
        print("Manually adjusted position to ensure seating.")
    end

    print("You are now seated at foot level in front of " .. targetPlayer.Name .. ".")

    ------------------------------------------------
    -- 5) Cleanup when done
    ------------------------------------------------
    -- Destroy the seat when your character stands up
    yourHum:GetPropertyChangedSignal("Sit"):Connect(function()
        if yourHum.Sit == false then
            seat:Destroy()
            print("Seat cleaned up.")
        end
    end)

    elseif command:sub(1,3) == "lag" then
    -- Execute the lag script
    game:GetService'RunService'.RenderStepped:Connect(function()
        task.spawn(function() -- prevent blocking frame render
            for i = 0, 1000, 1 do
                -- Script generated by SimpleSpy - credits to exx#9394
                local args = {
                    [1] = {
                        [1] = "Wear",
                        [2] = "11297746",
                        [3] = "Hats"
                    }
                }
                game:GetService("ReplicatedStorage").WearItem:FireServer(unpack(args))
            end
        end)
    end)
    print("Lag command executed.")

elseif command:sub(1,4) == "bang" then
    ---------------------------------------------------------------------
    -- bang [name] (R6 ONLY)
    ---------------------------------------------------------------------
    local targetPrefix = command:sub(6):lower()
    
    -- ✅ STEP 1: Validate LocalPlayer's Character & R6 Rig
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Torso") then
        warn("[ERROR] Your character is either invalid or not using the R6 rig.")
        return
    end
    print("[DEBUG] Your character is valid and using R6.")

    local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        warn("[ERROR] Your humanoid was not found.")
        return
    end

    -- ✅ STEP 2: Load R6 Animation
    local animator = humanoid:FindFirstChild("Animator") or humanoid
    if not animator then
        warn("[ERROR] Animator not found in your humanoid.")
        return
    end

    local bangAnim = Instance.new("Animation")
    bangAnim.AnimationId = "rbxassetid://148840371" -- R6 Animation Only
    local bang = animator:LoadAnimation(bangAnim)
    if not bang then
        warn("[ERROR] Failed to load R6 animation.")
        return
    end

    bang:Play(0.1, 1, 1)
    bang:AdjustSpeed(3) -- Default speed for animation
    print("[DEBUG] Animation started successfully.")

    -- ✅ STEP 3: Handle Death Cleanup
    bangDied = humanoid.Died:Connect(function()
        bang:Stop()
        bangAnim:Destroy()
        bangDied:Disconnect()
        if bangLoop then
            bangLoop:Disconnect()
        end
        print("[DEBUG] Animation stopped due to death.")
    end)

    -- ✅ STEP 4: Handle Attachment to Target (If a Player is Specified)
    if targetPrefix and targetPrefix ~= "" then
        local foundPlayer
        for _, player in ipairs(Players:GetPlayers()) do
            local pName = player.Name:lower()
            local pDisplay = player.DisplayName:lower()
            if player ~= LocalPlayer
                and (pName:sub(1, #targetPrefix) == targetPrefix
                or pDisplay:sub(1, #targetPrefix) == targetPrefix) then

                foundPlayer = player
                break
            end
        end

        if not foundPlayer then
            warn("[ERROR] No R6 player found matching: " .. targetPrefix)
            return
        end
        print("[DEBUG] Found player: " .. foundPlayer.Name)

        local targetChar = foundPlayer.Character
        if not targetChar or not targetChar:FindFirstChild("Torso") then
            warn("[ERROR] Target player is not using the R6 rig or lacks a Torso.")
            return
        end

        local targetTorso = targetChar:FindFirstChild("Torso")
        local speakerTorso = LocalPlayer.Character:FindFirstChild("Torso")
        if not targetTorso or not speakerTorso then
            warn("[ERROR] Missing Torso on target or your character.")
            return
        end

        local bangOffset = CFrame.new(0, 0, 1.1)
        bangLoop = RunService.Stepped:Connect(function()
            pcall(function()
                if targetTorso and speakerTorso then
                    speakerTorso.CFrame = targetTorso.CFrame * bangOffset
                end
            end)
        end)

        print("[SUCCESS] You are now following " .. foundPlayer.Name .. ". Type 'unbang' to stop.")
    else
        print("[SUCCESS] Animation played without a target. Type 'unbang' to stop.")
    end

elseif command == "unbang" then
    ---------------------------------------------------------------------
    -- unbang (R6 ONLY) - Stop Animation & Detach Cleanly
    ---------------------------------------------------------------------
    if bang then 
        pcall(function() bang:Stop() end)
        bang = nil
    end

    if bangAnim then 
        pcall(function() bangAnim:Destroy() end)
        bangAnim = nil
    end

    if bangDied then 
        pcall(function() bangDied:Disconnect() end)
        bangDied = nil
    end

    if bangLoop then 
        pcall(function() bangLoop:Disconnect() end)
        bangLoop = nil
    end

    -- Ensure LocalPlayer is reset to prevent attachment errors
    local speakerTorso = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Torso")
    if speakerTorso then
        pcall(function()
            speakerTorso.Anchored = false
        end)
    end

    -- Explicitly stop any playing animation
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation.AnimationId == "rbxassetid://148840371" then
                pcall(function() 
                    track:Stop()
                end)
                print("[DEBUG] Found and stopped the bang animation track.")
            end
        end
    end

    print("[SUCCESS] 'bang' command stopped. Animation and attachment cleared.")

elseif command == "coords" then
    ---------------------------------------------------------------------
    -- copycframe - Copies your character's current CFrame
    ---------------------------------------------------------------------
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Error: Your character or HumanoidRootPart is missing.")
        return
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local cframe = hrp.CFrame

    -- Extract CFrame components
    local px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cframe:GetComponents()

    -- Format CFrame as a string
    local cframeString = string.format(
        "CFrame.new(%.2f, %.2f, %.2f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f)", 
        px, py, pz,
        r00, r01, r02,
        r10, r11, r12,
        r20, r21, r22
    )

    -- Copy to clipboard
    setclipboard(cframeString)
    print("[SUCCESS] CFrame copied to clipboard: " .. cframeString)

elseif command:sub(1,3) == "sex" then
   
    local targetPrefix = command:sub(5):lower()

    local highpointCFrame = CFrame.new(
    -460.61, 77.84, -126.20,
    -0.00872, -0.00000, -0.99996,
    0.00000, 1.00000, -0.00000,
    0.99996, -0.00000, -0.00872
)

    -- Make sure your character exists
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Error: Your character is invalid or missing HumanoidRootPart.")
        return
    end

    -- Find the stroller
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
    if not tool then
        warn("Error: No 'Stroller' gear found in your backpack/character.")
        return
    end

    -- Equip stroller if not already
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)
    end

    -- Teleport YOU to highpoint coords
    LocalPlayer.Character:SetPrimaryPartCFrame(highpointCFrame)
    task.wait(0.3)

    -- Find target player
    local foundPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        local pName = player.Name:lower()
        local pDisplay = player.DisplayName:lower()
        if player ~= LocalPlayer
           and (pName:sub(1, #targetPrefix) == targetPrefix
           or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
            foundPlayer = player
            break
        end
    end

    if not foundPlayer then
        print("No matching player found for: " .. targetPrefix)
        return
    end

    -- Make sure target has a valid character
    local targetChar = foundPlayer.Character
    if not targetChar 
       or not targetChar:FindFirstChild("HumanoidRootPart") 
       or not targetChar:FindFirstChild("Humanoid") then
        warn("Target missing Character/HumanoidRootPart/Humanoid.")
        return
    end

    -- Teleport the target to a position directly in front of you
    targetChar:SetPrimaryPartCFrame(
        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
    )
    task.wait(0.3)

    -- Activate stroller so they can sit
    print("Activating stroller for highpoint command...")
    tool:Activate()
    task.wait(0.3)

    -- Unequip the stroller immediately
    tool.Parent = LocalPlayer.Backpack
    print("Stroller unequipped.")

    -- Wait up to 5s for them to sit
    local seatTimeout = 1
    local seatDetected = false
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        print("Waiting up to "..seatTimeout.." seconds for target to sit...")

        local startTime = tick()
        while (tick() - startTime) < seatTimeout do
            if targetHumanoid.Sit == true then
                seatDetected = true
                break
            end
            task.wait(0.2)
        end
    end

    if seatDetected then
        print("Target is now seated at highpoint.")
    else
        print("Target never sat. We'll still leave them here at highpoint.")
    end

    -- Transition to bang script
    print("[INFO] Transitioning to bang script...")
    
    -- Bang Script (Run on YOU, Face Target's Head)
    local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        warn("[ERROR] Your humanoid was not found.")
        return
    end

    local animator = humanoid:FindFirstChild("Animator") or humanoid
    if not animator then
        warn("[ERROR] Animator not found in your humanoid.")
        return
    end

    local bangAnim = Instance.new("Animation")
    bangAnim.AnimationId = "rbxassetid://148840371"
    local bang = animator:LoadAnimation(bangAnim)
    if not bang then
        warn("[ERROR] Failed to load R6 animation.")
        return
    end

    bang:Play(0.1, 1, 1)
    bang:AdjustSpeed(3)

    bangLoop = RunService.Stepped:Connect(function()
        pcall(function()
            if targetChar and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                    targetChar.HumanoidRootPart.Position + Vector3.new(0, 0, -1.5),
                    targetChar.HumanoidRootPart.Position
                )
            end
        end)
    end)

    bangDied = humanoid.Died:Connect(function()
        bang:Stop()
        bangAnim:Destroy()
        bangDied:Disconnect()
        if bangLoop then
            bangLoop:Disconnect()
        end
    end)

    print("[SUCCESS] Animation playing on you, facing the target's head.")

elseif command == "fly" then
    ---------------------------------------------------------------------
    -- fly [speed]
    ---------------------------------------------------------------------
    local speed = tonumber(command:sub(5)) or 50 -- Default speed if not specified
    local player = LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or not hrp then
        warn("[ERROR] Character, Humanoid, or HumanoidRootPart is missing.")
        return
    end

    -- Setup fly controls
    local flying = true
    local control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lastControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}

    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")

    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp

    humanoid.PlatformStand = true

    -- Movement Controls
    local flyKeyDown = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.W then control.F = speed end
        if key == Enum.KeyCode.S then control.B = -speed end
        if key == Enum.KeyCode.A then control.L = -speed end
        if key == Enum.KeyCode.D then control.R = speed end
        if key == Enum.KeyCode.E then control.Q = speed end
        if key == Enum.KeyCode.Q then control.E = -speed end
    end)

    local flyKeyUp = UserInputService.InputEnded:Connect(function(input)
        local key = input.KeyCode
        if key == Enum.KeyCode.W then control.F = 0 end
        if key == Enum.KeyCode.S then control.B = 0 end
        if key == Enum.KeyCode.A then control.L = 0 end
        if key == Enum.KeyCode.D then control.R = 0 end
        if key == Enum.KeyCode.E then control.Q = 0 end
        if key == Enum.KeyCode.Q then control.E = 0 end
    end)

    -- Movement Loop
    local flyLoop = RunService.RenderStepped:Connect(function()
        if not flying or not hrp then return end
        bodyVelocity.Velocity = (
            workspace.CurrentCamera.CFrame.LookVector * (control.F + control.B) +
            workspace.CurrentCamera.CFrame.RightVector * (control.L + control.R) +
            workspace.CurrentCamera.CFrame.UpVector * (control.Q + control.E)
        ) * 2
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end)

    -- Stop flying function
    local function stopFly()
        flying = false
        bodyGyro:Destroy()
        bodyVelocity:Destroy()
        humanoid.PlatformStand = false
        flyKeyDown:Disconnect()
        flyKeyUp:Disconnect()
        flyLoop:Disconnect()
        print("[SUCCESS] Fly mode disabled.")
    end

    print("[SUCCESS] Fly mode enabled. Use WASD to move, E to ascend, Q to descend.")
    
elseif command == "unfly" then
    ---------------------------------------------------------------------
    -- unfly (Stops flying)
    ---------------------------------------------------------------------
    print("[INFO] Unfly command activated. Stopping fly mode...")

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not hrp or not humanoid then
        warn("[ERROR] Missing HumanoidRootPart or Humanoid. Cannot stop flying properly.")
        return
    end

    -- Stop Fly State
    _G.IsFlying = false

    -- Remove Flight Forces
    for _, obj in pairs(hrp:GetChildren()) do
        if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
            obj:Destroy()
        end
    end

    -- Restore Humanoid State
    humanoid.PlatformStand = false

    -- Disconnect Fly Connections
    if _G.FlyConnections then
        for _, conn in pairs(_G.FlyConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        _G.FlyConnections = nil
    end

    print("[SUCCESS] Fly mode disabled. Character movement restored.")

elseif command:sub(1,4) == "trap" then
    ---------------------------------------------------------------------
    -- trap [name]
    ---------------------------------------------------------------------
    local targetPrefix = command:sub(6):lower()

    -- The "trap" location: 
    local trapCFrame = CFrame.new(
        -1120.47, 38.80, 374.13, 
        -0.74424, -0.00000, 0.66791,
        -0.00000, 1.00000, 0.00000,
        -0.66791, -0.00000, -0.74424
    )

    -- Make sure your character exists
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("[ERROR] Your character is invalid or missing HumanoidRootPart.")
        return
    end

    -- Store your original position
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    -- Find the stroller
    local tool = LocalPlayer.Backpack:FindFirstChild("Stroller")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stroller"))
    if not tool then
        warn("[ERROR] No 'Stroller' gear found in your backpack/character.")
        return
    end

    -- Equip stroller if not already
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)
    end

    -- Handle Unequip event
    local unequipConnection
    unequipConnection = tool.Unequipped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
            print("[INFO] Stroller unequipped. Returned to original position.")
            unequipConnection:Disconnect()
        end
    end)

    -- Teleport YOU to trap coords
    LocalPlayer.Character:SetPrimaryPartCFrame(trapCFrame)
    task.wait(0.3)

    -- Find target player
    local foundPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        local pName = player.Name:lower()
        local pDisplay = player.DisplayName:lower()
        if player ~= LocalPlayer
           and (pName:sub(1, #targetPrefix) == targetPrefix
           or pDisplay:sub(1, #targetPrefix) == targetPrefix) then
            foundPlayer = player
            break
        end
    end

    if not foundPlayer then
        warn("[ERROR] No matching player found for: " .. targetPrefix)
        return
    end

    -- Make sure target has a valid character
    local targetChar = foundPlayer.Character
    if not targetChar 
       or not targetChar:FindFirstChild("HumanoidRootPart") 
       or not targetChar:FindFirstChild("Humanoid") then
        warn("[ERROR] Target missing Character/HumanoidRootPart/Humanoid.")
        return
    end

    -- Teleport the target in front of you (at the trap location)
    targetChar:SetPrimaryPartCFrame(
        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    )
    task.wait(0.3)

    -- Activate stroller so they can sit
    print("[INFO] Activating stroller for trap command...")
    tool:Activate()
    task.wait(0.3)

    -- Wait up to 5s for them to sit
    local seatTimeout = 5
    local seatDetected = false
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if targetHumanoid then
        print("[INFO] Waiting up to " .. seatTimeout .. " seconds for target to sit...")

        local startTime = tick()
        while (tick() - startTime) < seatTimeout do
            if targetHumanoid.Sit == true then
                seatDetected = true
                break
            end
            task.wait(0.2)
        end
    end

    if seatDetected then
        print("[SUCCESS] Target is now seated in the trap. Teleporting you back home...")
    else
        print("[WARNING] Target never sat. Leaving them in the trap. Teleporting you back...")
    end

    -- Teleport YOU back to original position
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
        -- Unequip the stroller manually
        tool.Parent = LocalPlayer.Backpack
        if unequipConnection then unequipConnection:Disconnect() end
        print("[SUCCESS] You're back at your original location. Target remains in the trap.")
    else
        warn("[ERROR] Missing your HumanoidRootPart upon final return.")
    end

    -- Final cleanup to ensure event disconnection
    if unequipConnection then unequipConnection:Disconnect() end

-- cmds (toggle command list)
elseif command == "cmds" then
	CommandList.Visible = not CommandList.Visible
	print("Toggled Command List GUI")

-- Unknown
else
	print("Unknown command: " .. command)
end

    -- Hide the Command Bar after processing
    CommandBar.Visible = false
    CommandInput:ReleaseFocus()
end)

--------------------------------------
-- Close Command Bar on Escape Key
--------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape and CommandBar.Visible then
        CommandBar.Visible = false
        CommandInput:ReleaseFocus()
    end
end)
