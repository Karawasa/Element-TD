-- Roots (Darkness + Earth + Nature)
-- This is a support tower. It shoots out a line with X width that buffs creeps hit. 
-- Buff slows down movement speed by X%. Buff also does X damage per second. Buff stacks for damage but NOT slow. Buff lasts X seconds. Think of this like a shockwave.

RootsTower = createClass({
        tower = nil,
        towerClass = "",

        constructor = function(self, tower, towerClass)
            self.tower = tower;
            self.towerClass = towerClass or self.towerClass;
        end
    },
    {
        className = "RootsTower";
    },
nil);

function RootsTower:OnDOTTick(keys)

end

function RootsTower:OnAttackStart(keys) 

    local launchParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_ambient_beam_sparkly.vpcf", PATTACH_ABSORIGIN, self.tower);
    ParticleManager:SetParticleControl(launchParticle, 0, self.tower:GetOrigin());
    ParticleManager:ReleaseParticleIndex(launchParticle);

    local targetPos = keys.target:GetAbsOrigin();
    local dir = (targetPos - self.tower:GetOrigin()):Normalized();
    dir.z = 0;

    local affectedCreeps = {};
    local velocity = dir * 185;

    local pos = self.tower:GetAbsOrigin();
    pos.x = pos.x + velocity.x;
    pos.y = pos.y + velocity.y;

    local affected = 0;

    for i = 1, 6, 1 do
        pos.x = pos.x + velocity.x;
        pos.y = pos.y + velocity.y;

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_vine_glows_coreSpray.vpcf", PATTACH_ABSORIGIN, self.tower);
        ParticleManager:SetParticleControl(particle, 0, pos);
        ParticleManager:ReleaseParticleIndex(particle);

        local creeps = GetCreepsInArea(pos, self.width / 2);
        for _, creep in pairs(creeps) do
            if creep:IsAlive() and not affectedCreeps[creep:entindex()] then
                affected = affected + 1;
                affectedCreeps[creep:entindex()] = true;

                self.ability:ApplyDataDrivenModifier(self.tower, creep, "modifier_gaias_wrath_slow", {});
                self.ability:ApplyDataDrivenModifier(self.tower, creep, "modifier_gaias_wrath_damage", {});
            end
        end
    end
end

function RootsTower:OnDamageTick(keys)
    DamageEntity(keys.target, self.tower, self.damagePerSecond);
end

function RootsTower:OnCreated()
    self.ability = AddAbility(self.tower, "roots_tower_gaias_wrath", self.tower:GetLevel());
    
    self.width = GetAbilitySpecialValue("roots_tower_gaias_wrath", "width");
    self.length = self.tower:GetAttackRange();
    self.damagePerSecond = GetAbilitySpecialValue("roots_tower_gaias_wrath", "dps")[self.tower:GetLevel()];
end

function RootsTower:OnAttackLanded(keys) end
RegisterTowerClass(RootsTower, RootsTower.className);