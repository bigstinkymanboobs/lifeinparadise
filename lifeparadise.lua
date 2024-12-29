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
-- Command List Window (Draggable)
--------------------------------------
local CommandList = Instance.new("Frame")
CommandList.Name = "CommandList"
CommandList.Parent = ScreenGui
CommandList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CommandList.BorderSizePixel = 0
CommandList.Position = UDim2.new(0.5, -200, 0.5, -100)
CommandList.Size = UDim2.new(0, 400, 0, 200)
CommandList.AnchorPoint = Vector2.new(0.5, 0.5)
CommandList.Visible = false
CommandList.Active = true
CommandList.ClipsDescendants = true
CommandList.BackgroundTransparency = 0.2

local CommandListCorner = Instance.new("UICorner")
CommandListCorner.CornerRadius = UDim.new(0, 10)
CommandListCorner.Parent = CommandList

local CommandListScroll = Instance.new("ScrollingFrame")
CommandListScroll.Name = "CommandListScroll"
CommandListScroll.Parent = CommandList
CommandListScroll.BackgroundTransparency = 1
CommandListScroll.Size = UDim2.new(1, 0, 1, -30)
CommandListScroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
CommandListScroll.ScrollBarThickness = 8
CommandListScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
CommandListScroll.Position = UDim2.new(0, 0, 0, 0)

local CommandListText = Instance.new("TextLabel")
CommandListText.Name = "CommandListText"
CommandListText.Parent = CommandListScroll
CommandListText.BackgroundTransparency = 1
CommandListText.Size = UDim2.new(1, -10, 1, 0)
CommandListText.Font = Enum.Font.SourceSans
CommandListText.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandListText.TextSize = 18
CommandListText.Text = [[
Available Commands:
- killgui
- re
- noclip
- clip
- kill [name]
- rocket [name]
- view/unview [name]
- bring [name]
- goto [name]
- fling [name]
- jail [name]
- void [name]
- skydive [name]
- annoy/unannoy [name]
- revealusers/unrevealusers
- cmds
]]
CommandListText.TextWrapped = true
CommandListText.TextYAlignment = Enum.TextYAlignment.Top
CommandListText.TextXAlignment = Enum.TextXAlignment.Left

local CommandListTextPadding = Instance.new("UIPadding")
CommandListTextPadding.Parent = CommandListText
CommandListTextPadding.PaddingLeft = UDim.new(0, 10)
CommandListTextPadding.PaddingRight = UDim.new(0, 10)
CommandListTextPadding.PaddingTop = UDim.new(0, 10)

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

-- Strip semicolons if they sneak in
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

    local command = CommandInput.Text
    CommandInput.Text = ""
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


    elseif command == "re" then
        if LocalPlayer.Character
           and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
           and OriginalPosition then
    
            print("Resetting character and returning to latest position...")
    
            -- Kill yourself
            LocalPlayer.Character:BreakJoints()
    
            -- Wait for the new character
            local newChar = LocalPlayer.CharacterAdded:Wait()
            local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
    
            if hrp then
                task.wait(1)  -- short wait so the character is fully initialized
                hrp.CFrame = CFrame.new(OriginalPosition)
                print("Teleported back to your last known position after reset.")
            else
                print("Error: Failed to locate HumanoidRootPart after respawn.")
            end
        else
            print("Error: Your character is invalid or we have no OriginalPosition yet.")
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
                            while (tick() - flingStart) < 5 do
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
                            LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1000, 0)
                        )
                        task.wait(1)

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
        -- Save original position in case you respawn or un-equip the stroller
        local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

        -- Ensure you return to original position after respawn
        local function onRespawn(character)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                task.wait(1)
                character:SetPrimaryPartCFrame(originalPosition)
                print("Respawn detected. Teleported back to original position.")
            else
                warn("Failed to teleport back after respawn due to missing HumanoidRootPart.")
            end
        end
        LocalPlayer.CharacterAdded:Connect(onRespawn)

        -- Equip the stroller
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)

        -- NEW: If the stroller unequips for any reason, instantly snap back
        tool.Unequipped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                print("Stroller unequipped, teleporting you back immediately.")
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

                    -- Teleport player a bit in front of you
                    player.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    )
                    task.wait(0.2)

                    -- Activate stroller (so they can be ‘grabbed’)
                    tool:Activate()
                    task.wait(0.2)

                    -- Teleport you beneath the map
                    print("Proceeding to sink beneath the map...")
                    LocalPlayer.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -300, 0)
                    )
                    task.wait(1)

                    -- Unequip stroller -> triggers the Unequipped event 
                    tool.Parent = LocalPlayer.Backpack
                    print("Void command complete; you should be snapped back instantly.")
                    break
                else
                    warn("Error: Target player is missing HumanoidRootPart or Humanoid.")
                end
            end
        end

        if not found then
            print("No matching player found for: " .. targetPrefix)
        end

    else
        warn("Error: No stroller found or missing HumanoidRootPart.")
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

    -- Teleport the target in front of you (at the jail location)
    targetChar:SetPrimaryPartCFrame(
        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    )
    task.wait(0.3)

    -- Activate stroller so they can sit
    print("Activating stroller for jail command...")
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
        print("Target is now seated in jail. Teleporting you back home...")
    else
        print("Target never sat. We'll still leave them here at jail. Teleporting you back...")
    end

    -- Teleport YOU back to original position
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
        -- Optionally un-equip the stroller
        tool.Parent = LocalPlayer.Backpack
        print("You're back at your original location. Target remains in jail.")
    else
        warn("Error: Missing your HumanoidRootPart upon final return.")
    end

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
		local launchSpeed = 150
	
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
        -- Save original position in case you respawn or un-equip the stroller
        local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

        -- Ensure you return to original position after respawn
        local function onRespawn(character)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                task.wait(1)
                character:SetPrimaryPartCFrame(originalPosition)
                print("Respawn detected. Teleported back to original position.")
            else
                warn("Failed to teleport back after respawn due to missing HumanoidRootPart.")
            end
        end
        LocalPlayer.CharacterAdded:Connect(onRespawn)

        -- Equip the stroller
        tool.Parent = LocalPlayer.Character
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.3)

        -- NEW: If the stroller unequips for any reason, instantly snap back
        tool.Unequipped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
                print("Stroller unequipped, teleporting you back immediately.")
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

                    -- Teleport player a bit in front of you
                    player.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    )
                    task.wait(0.2)

                    -- Activate stroller (so they can be ‘grabbed’)
                    tool:Activate()
                    task.wait(0.2)

                    -- Teleport you to the banlands altitude (e.g., Y = 3000)
                    print("Proceeding to teleport to the banlands altitude...")
                    LocalPlayer.Character:SetPrimaryPartCFrame(
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 100000000, 0)
                    )
                    task.wait(1)

                    -- Unequip stroller -> triggers the Unequipped event 
                    tool.Parent = LocalPlayer.Backpack
                    print("Banlands command complete; you should be snapped back instantly.")
                    break
                else
                    warn("Error: Target player is missing HumanoidRootPart or Humanoid.")
                end
            end
        end

        if not found then
            print("No matching player found for: " .. targetPrefix)
        end

    else
        warn("Error: No stroller found or missing HumanoidRootPart.")
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

if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    -- Save original position in case you respawn or un-equip the stroller
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    -- Ensure you return to original position after respawn
    local function onRespawn(character)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            task.wait(1)
            character:SetPrimaryPartCFrame(originalPosition)
            print("Respawn detected. Teleported back to original position.")
        else
            warn("Failed to teleport back after respawn due to missing HumanoidRootPart.")
        end
    end
    LocalPlayer.CharacterAdded:Connect(onRespawn)

    -- Equip the stroller
    tool.Parent = LocalPlayer.Character
    LocalPlayer.Character.Humanoid:EquipTool(tool)
    task.wait(0.3)

    -- NEW: If the stroller unequips for any reason, instantly snap back
    tool.Unequipped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:SetPrimaryPartCFrame(originalPosition)
            print("Stroller unequipped, teleporting you back immediately.")
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

                -- Teleport player a bit in front of you
                player.Character:SetPrimaryPartCFrame(
                    LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                )
                task.wait(0.2)

                -- Activate stroller (so they can be ‘grabbed’)
                tool:Activate()
                task.wait(0.2)

                -- Teleport you beneath the map
                print("Proceeding to kill...")
                LocalPlayer.Character:SetPrimaryPartCFrame(
                    LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -480, 0)
                )
                task.wait(0.3)

                -- Unequip stroller -> triggers the Unequipped event 
                tool.Parent = LocalPlayer.Backpack
                print("Void command complete; you should be snapped back instantly.")
                break
            else
                warn("Error: Target player is missing HumanoidRootPart or Humanoid.")
            end
        end
    end

    if not found then
        print("No matching player found for: " .. targetPrefix)
    end

else
    warn("Error: No stroller found or missing HumanoidRootPart.")
end

-- cmds (toggle command list)
elseif command == "cmds" then
	CommandList.Visible = not CommandList.Visible
	print("Toggled Command List GUI")

-- Unknown
else
	print("Unknown command: " .. command)
end
end)
