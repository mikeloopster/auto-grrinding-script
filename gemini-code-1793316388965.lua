-- Services
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

-- Parameters
local NPC_FOLDER = Workspace:WaitForChild("Enemies") -- Folder containing your enemy models

local function getClosestEnemy(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end
	
	local closestEnemy = nil
	local shortestDistance = math.huge
	
	for _, enemy in pairs(NPC_FOLDER:GetChildren()) do
		local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
		local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
		
		if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
			local distance = (rootPart.Position - enemyRoot.Position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				closestEnemy = enemy
			end
		end
	end
	
	return closestEnemy
end

-- Main Auto-Grind Function
local function startAutoGrind(player, toolToEquip)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	
	-- Equip weapons if held in Backpack
	local tool = player.Backpack:FindFirstChild(toolToEquip)
	if tool then
		humanoid:EquipTool(tool)
	end

	-- Simple Loop: Runs while player has auto-grind active
	task.spawn(function()
		while player:GetAttribute("AutoGrindActive") == true do
			local target = getClosestEnemy(character)
			
			if target then
				local targetRoot = target:FindFirstChild("HumanoidRootPart")
				local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
				
				-- Loop until enemy dies or disappears
				while targetHumanoid and targetHumanoid.Health > 0 and player:GetAttribute("AutoGrindActive") do
					local distance = (rootPart.Position - targetRoot.Position).Magnitude
					
					if distance > 5 then
						-- Move closer to enemy
						humanoid:MoveTo(targetRoot.Position)
					else
						-- Stop and attack
						humanoid:MoveTo(rootPart.Position)
						
						-- Trigger the equipped weapon's attack function (RemoteEvent or Tool:Activate)
						local currentTool = character:FindFirstChildOfClass("Tool")
						if currentTool then
							currentTool:Activate() -- Activates the tool's built-in swing/attack logic
						end
					end
					
					task.wait(0.3) -- Attack interval / tick rate
				end
			else
				-- No enemies nearby, wait before checking again
				task.wait(1)
			end
		end
	end)
end

-- Example trigger: Toggle auto-farm state
-- player:SetAttribute("AutoGrindActive", true)
-- startAutoGrind(player, "Sword")