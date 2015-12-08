-- Swarm Creep class
CreepSwarm = createClass({
        creep = nil,
        creepClass = "",

        constructor = function(self, creep, creepClass)
            self.creep = creep;
            self.creepClass = creepClass or self.creepClass
        end
    },
    {
        className = "CreepSwarm"
    },
CreepBasic);

function CreepSwarm:OnTakeDamage(keys)
    print("CreepSwarm:OnHit")
    if self.creep:GetHealth() > 0 and self.creep:GetHealthPercent() <= 50 and not self.creep.isSwarm then
        print("Creating Swarm")
        self.creep.isSwarm = true;

        local swarm = SpawnEntity(self.creep:GetUnitName(), self.creep.playerID, self.creep:GetOrigin());
        swarm.class = creepClass;
        swarm.playerID = self.creep.playerID;
        swarm.waveObject = self.creep.waveObject;
        self.creep.waveObject:RegisterCreep(swarm:entindex());
        self.creep.waveObject.creepsRemaining = self.creep.waveObject.creepsRemaining + 1 -- Increment creep count
        swarm.isSwarm = true;
        local newMaxHealth = self.creep:GetMaxHealth()/2;
        swarm:SetMaxHealth(newMaxHealth);
        swarm:SetBaseMaxHealth(newMaxHealth);
        swarm:SetHealth(newMaxHealth);
        swarm:SetDeathXP(0);
        swarm:SetForwardVector(self.creep:GetForwardVector());

        self.creep:SetMaxHealth(newMaxHealth);
        self.creep:SetBaseMaxHealth(newMaxHealth);
        self.creep:SetHealth(newMaxHealth);

        local newScale = self.creep:GetModelScale()*0.8;

        self.creep:SetModelScale(newScale);
        swarm:SetModelScale(newScale);

        local playerID = self.creep.playerID;
        local wave = self.creep.waveObject:GetWaveNumber();
        local bounty = math.ceil(GetPlayerDifficulty(playerID):GetBountyForWave(wave)/2);

        self.creep:SetMaximumGoldBounty(bounty);
        self.creep:SetMinimumGoldBounty(bounty);

        swarm:SetMaximumGoldBounty(bounty);
        swarm:SetMinimumGoldBounty(bounty);

        local playerData = GetPlayerData(playerID);
        CreateMoveTimerForCreep(swarm, playerData.sector + 1);
    end
end

RegisterCreepClass(CreepSwarm, CreepSwarm.className);