-- Enchantment Tower (Earth + Light + Nature)
-- This is a support tower. It has a splash attack. It has an autocast single target ability that buffs creeps. 
-- Buff increases damage taken by X%. Buff lasts X seconds. Buff does not stack.

EnchantmentTower = createClass({
        tower = nil,
        towerClass = "",

        constructor = function(self, tower, towerClass)
            self.tower = tower;
            self.towerClass = towerClass or self.towerClass;
        end
    },
    {
        className = "EnchantmentTower"
    },
nil);

function EnchantmentTower:FaerieFireThink()
    if self.ability:IsFullyCastable() and self.ability:GetAutoCastState() then
        local creeps = GetCreepsInArea(self.tower:GetOrigin(), self.range);
        local highestHealth = 0;
        local theChosenOne = nil;

        -- find out the tower with the highest damage. Is this a bad choosing algorithm?
        for _, creep in pairs(creeps) do
            if creep:IsAlive() and not creep:HasModifier("modifier_faerie_fire") and creep:GetHealth() > highestHealth then
                highesthealth = creep:GetHealth();
                theChosenOne = creep;
            end
        end

        if theChosenOne then
            self.tower:CastAbilityOnTarget(theChosenOne, self.ability, 1);
        end
    end
end

function EnchantmentTower:OnFaerieFireExpire(keys)
    local target = keys.target;
    if target:IsAlive() then
        RemoveDamageAmpModifierFromCreep(target, self.modifierName);
        self.debuffedCreeps[target:entindex()] = nil;
    end
end

function EnchantmentTower:OnFaerieFireCast(keys)
    local target = keys.target;
    AddDamageAmpModifierToCreep(target, self.modifierName, self.damageAmp);

    self.debuffedCreeps[target:entindex()] = "BibleThump";

    local particle = ParticleManager:CreateParticle("centaur_return_thin", PATTACH_ABSORIGIN, self.tower);
    ParticleManager:SetParticleControl(particle, 0, self.attackLoc);
    ParticleManager:SetParticleControl(particle, 1, target:GetOrigin());
end

function EnchantmentTower:OnAttackLanded(keys)
    local target = keys.target;
    local damage = ApplyAttackDamageFromModifiers(self.tower:GetBaseDamageMax(), self.tower);
    
    DamageEntitiesInArea(target:GetOrigin(), self.halfAOE, self.tower, damage / 2);
    DamageEntitiesInArea(target:GetOrigin(), self.fullAOE, self.tower, damage / 2);
end

function EnchantmentTower:OnCreated()
    self.modifierName = "modifier_faerie_fire";

    self.attackLoc = self.tower:GetAttachmentOrigin(self.tower:ScriptLookupAttachment("attach_attack1"));
    self.damageAmp = GetAbilitySpecialValue("enchantment_tower_faerie_fire", "damage_amp")[self.tower:GetLevel()];
    self.debuffedCreeps = {};
    self.range = tonumber(GetAbilityKeyValue("enchantment_tower_faerie_fire", "AbilityCastRange"));

    self.fullAOE = tonumber(GetUnitKeyValue(self.towerClass, "AOE_Full"));
    self.halfAOE = tonumber(GetUnitKeyValue(self.towerClass, "AOE_Half"));

    self.ability = AddAbility(self.tower, "enchantment_tower_faerie_fire", self.tower:GetLevel());
    self.ability:SetContextThink("FaerieFireThinker", function()
        self:FaerieFireThink();
        return 1;
    end, 1);
    self.ability:ToggleAutoCast();
end

function EnchantmentTower:OnDestroyed()
    for id,_ in pairs(self.debuffedCreeps) do
        local creep = EntIndexToHScript(id);
        if creep and IsValidEntity(creep) and creep:IsAlive() then
            creep:RemoveModifierByName(self.modifierName);
        end
    end
end

RegisterTowerClass(EnchantmentTower, EnchantmentTower.className);