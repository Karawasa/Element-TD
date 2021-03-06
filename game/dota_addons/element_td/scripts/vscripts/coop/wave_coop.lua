-- should be like wave.lua, but for co-op mode

WaveCoop = createClass({
		constructor = function(self, waveNumber)
			self.waveNumber = waveNumber
			self.creepsRemaining = CREEPS_PER_WAVE_COOP
			self.creeps = {}
			self.startTime = 0
			self.endTime = 0
			self.leaks = 0
			self.kills = 0
			self.callback = nil
		end
	},
{}, nil)

function WaveCoop:GetWaveNumber()
	return self.waveNumber
end

function WaveCoop:GetCreeps()
	return self.creeps
end

function WaveCoop:SetOnCompletedCallback(func)
	self.callback = func
end

function WaveCoop:OnCreepKilled(index)
	if self.creeps[index] then
		self.creeps[index] = nil
		self.creepsRemaining = self.creepsRemaining - 1
		local creep = EntIndexToHScript(index)
		if IsValidEntity(creep) and creep:HasAbility("creep_ability_bulky") then
		    self.creepsRemaining = self.creepsRemaining - 1
		end
		self.kills = self.kills + 1

		if self.creepsRemaining <= 0 and self.callback then
			self.endTime = GameRules:GetGameTime()
			self.callback()
		end
	end
end

function WaveCoop:RegisterCreep(index)
	if not self.creeps[index] then
		self.creeps[index] = index
	else
		Log:warn("Attemped to register creep " .. index .. " which is already register!")
	end
end

function WaveCoop:SpawnWave()
	EmitGlobalSound("ui.contract_complete")
	
	local difficulty = GameSettings:GetGlobalDifficulty()
	local entitiesSpawned = 0
	local time_between_spawns = 0.5
	local creepBossSequence = 0
	local creepBossAbilities = CreepBoss:GetAbilityList()
	local numAbilities = #creepBossAbilities
	
	self.startTime = GameRules:GetGameTime() + time_between_spawns
	self.leaks = 0
	self.kills = 0

	-- Reset the lane leak counter
	for i=1, 6 do
		COOP_WAVE_LANE_LEAKS[i] = 0
	end

	self.spawnTimer = Timers:CreateTimer(time_between_spawns, function()
		for sector = 1, 6 do
			if entitiesSpawned >= CREEPS_PER_WAVE_COOP then
				break
			end

			local entity = SpawnEntity(WAVE_CREEPS[self.waveNumber], nil, EntityStartLocations[sector], self.waveNumber)
			if entity then
				self:RegisterCreep(entity:entindex())
				entity:SetForwardVector(Vector(0, -1, 0))
				entity:CreatureLevelUp(self.waveNumber-entity:GetLevel())
				entity.waveObject = self
				entity.waveNumber = self.waveNumber
				entitiesSpawned = entitiesSpawned + 1

				-- Set health
				local health = WAVE_HEALTH[self.waveNumber] * difficulty:GetHealthMultiplier()
				entity:SetMaxHealth(health)
				entity:SetBaseMaxHealth(health)
				entity:SetHealth(entity:GetMaxHealth())

				-- Boss mode
				if self.waveNumber == WAVE_COUNT then
					local bossHealth = WAVE_HEALTH[self.waveNumber] * difficulty:GetHealthMultiplier() * (math.pow(1.2,CURRENT_BOSS_WAVE-1))
					entity:SetMaxHealth(bossHealth)
					entity:SetBaseMaxHealth(bossHealth)
					entity:SetHealth(entity:GetMaxHealth())
					entity.waveNumber = CURRENT_BOSS_WAVE

					-- Choose an ability in sequence
					if CHALLENGE_MODE then
						creepBossAbilities = CreepBoss:GetAbilityList()

						-- Do not let count entities spawned count go over CREEPS_PER_WAVE
						local rand1 = math.random(#creepBossAbilities)
						local rand2 = math.random(#creepBossAbilities - 1)
						if entitiesSpawned == CREEPS_PER_WAVE then
							-- Last creep in wave cannot be bulky
							if rand1 == 1 then
								rand1 = rand1 + 1
							end
							if rand2 == 1 then
								rand2 = rand2 + 1
							end
						end

						local ability1 = table.remove(creepBossAbilities, rand1)
						local ability2 = table.remove(creepBossAbilities, rand2)

						entity.scriptObject.abilities = {}
						entity.scriptObject.abilities[ability1] = AddAbility(entity, ability1) 
						entity.scriptObject.abilities[ability2] = AddAbility(entity, ability2) 
						entity.random_abilities = {[ability1] = true, [ability2] = true}
					else
						creepBossSequence = (creepBossSequence % numAbilities) + 1
				   		local abilityName = creepBossAbilities[creepBossSequence]
						entity.random_abilities = {[abilityName] = true} 
						entity.scriptObject.abilities = {}
						entity.scriptObject.abilities[abilityName] = AddAbility(entity, abilityName)
					end
				end

				-- Set bounty
				local bounty = difficulty:GetBountyForWave(self.waveNumber)

				-- Bulky: double spawn time, double bounty, half creep count
				if entity:HasAbility("creep_ability_bulky") then
					time_between_spawns = 1
					entitiesSpawned = entitiesSpawned + 1
					bounty = bounty * 2
				else
					time_between_spawns = 0.5
				end

				entity:SetMaximumGoldBounty(bounty)
				entity:SetMinimumGoldBounty(bounty)

				entity.scriptObject:OnSpawned() -- called the OnSpawned event

				entity.sector = sector
				CreateMoveTimerForCreepCoop(entity, sector)
			end
		end

		if entitiesSpawned >= CREEPS_PER_WAVE_COOP then
			self.endSpawnTime = GameRules:GetGameTime()
			for i = 1, 6 do
				ClosePortalForSector(nil, i, true)
			end

			if self.waveNumber ~= WAVE_COUNT then
				-- Start clock timer on the UI
				CustomGameEventManager:Send_ServerToAllClients("etd_start_wave_clock", {threshold = FAST_THRESHOLD})
			end

			return nil
		else
			return time_between_spawns
		end
	end)

end