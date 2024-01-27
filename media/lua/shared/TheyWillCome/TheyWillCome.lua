-- init sandbox variables and mod data
local function init()
	
	local modData = ModData.getOrCreate("TheyWillCome")
	
	if not modData.lastDayOfKills then
		modData.lastDayOfKills = 0
	end
	
	if not modData.lastAmountKills then
		modData.lastAmountKills = 0
	end

	if not modData.defaultHearing then
		modData.defaultHearing = getSandboxOptions():getOptionByName("ZombieLore.Hearing"):getValue()
	end

	if not modData.defaultMemory then
		modData.defaultMemory = getSandboxOptions():getOptionByName("ZombieLore.Memory"):getValue()
	end

	if not modData.defaultFollowSoundDistance then
		modData.defaultFollowSoundDistance = getSandboxOptions():getOptionByName("ZombieConfig.FollowSoundDistance"):getValue()
	end

	if not modData.defaultRallyGroupSize then
		modData.defaultRallyGroupSize = getSandboxOptions():getOptionByName("ZombieConfig.RallyGroupSize"):getValue()
	end

	if not modData.defaultRedistributeHours then
		modData.defaultRedistributeHours = getSandboxOptions():getOptionByName("ZombieConfig.RedistributeHours"):getValue()
	end
end


-- Verify every hour if the player is being so passive
local function checkIfStartHuntingPlayer()

	local modData = ModData.getOrCreate("TheyWillCome") -- Call mod data

	for playerIndex = 0, getNumActivePlayers()-1 do -- Check for main player
	
		local player = getSpecificPlayer(playerIndex)
		local dayKills = player:getZombieKills()
		local daysPass = math.floor(getGameTime():getWorldAgeHours() / 24)
		
		local x = player:getCurrentSquare():getX()
		local y = player:getCurrentSquare():getY()
		local z = player:getCurrentSquare():getZ()
		
		-- How much zombies the player has killed today?
		
		if dayKills <= modData.lastAmountKills then -- Any: 
			 
			-- And it has passed the total of days stablished in condition?
			if daysPass - modData.lastDayOfKills >= SandboxVars.TheyWillCome.DaysCondition then 

				-- Increment zombie smartness
				getSandboxOptions():set("ZombieLore.Hearing", 1)
				getSandboxOptions():set("ZombieLore.Memory", 1)
				getSandboxOptions():set("ZombieConfig.FollowSoundDistance", 1000)
				getSandboxOptions():set("ZombieConfig.RallyGroupSize", 0)
				getSandboxOptions():set("ZombieConfig.RedistributeHours", 2)

				getWorldSoundManager():addSound(nil, x, y, z, 1000, 1000) -- Attract zombies to the actual/last player possition
			end
		else  -- It has killed:

			-- Leave it alone. Store this in the mod data
			modData.lastAmountKills = dayKills
			modData.lastDayOfKills = daysPass

			-- Return zombies behavior to default
			getSandboxOptions():set("ZombieLore.Hearing", modData.defaultHearing)
			getSandboxOptions():set("ZombieLore.Memory", modData.defaultMemory)
			getSandboxOptions():set("ZombieConfig.FollowSoundDistance", modData.defaultFollowSoundDistance)
			getSandboxOptions():set("ZombieConfig.RallyGroupSize", modData.defaultRallyGroupSize)
			getSandboxOptions():set("ZombieConfig.RedistributeHours", modData.defaultRedistributeHours)
		end
	end
end


Events.OnGameStart.Add(init)
Events.EveryHours.Add(checkIfStartHuntingPlayer)