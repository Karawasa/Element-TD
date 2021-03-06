-- Nova (Fire + Light + Nature)
-- This is a support tower. Every time this tower attacks it does X damage in an area of effect around it. 
-- It also debuffs all creeps hit. Buff slows down movement speed by X%. Debuff does not stack. Debuff lasts X seconds.

NovaTower = createClass({
        tower = nil,
        towerClass = "",

        constructor = function(self, tower, towerClass)
            self.tower = tower
            self.towerClass = towerClass or self.towerClass
        end
    },
    {
        className = "NovaTower"
    },
nil)

function NovaTower:Explode()
    local particle = ParticleManager:CreateParticle("particles/custom/towers/nova/attack.vpcf", PATTACH_ABSORIGIN, self.tower)
    ParticleManager:SetParticleControl(particle, 0, self.tower:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    
    local damage = ApplyAbilityDamageFromModifiers(self.explodeDamage, self.tower)
    DamageEntitiesInArea(self.tower:GetAbsOrigin(), self.aoe, self.tower, damage)
    self.lastExplodeTime = GameRules:GetGameTime()
    self.tower:EmitSound("Nova.Cast")
end

function NovaTower:OnCreated()
    self.ability = AddAbility(self.tower, "nova_tower_explode", self.tower:GetLevel())
    self.explodeDamage = self.ability:GetLevelSpecialValueFor("damage", self.tower:GetLevel()-1)
    self.aoe = self.ability:GetLevelSpecialValueFor("aoe", self.tower:GetLevel()-1) +self.tower:GetHullRadius()
    self.lastExplodeTime = 0
end

function NovaTower:OnAttackLanded(keys) end
RegisterTowerClass(NovaTower, NovaTower.className)