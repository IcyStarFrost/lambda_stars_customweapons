AddCSLuaFile()

ENT.Base = "base_anim"

if CLIENT then language.Add( "lambda_c4", "C4 Plastic Explosive" ) end

local debris = {
    "models/props_debris/concrete_chunk01a.mdl",
    "models/props_debris/concrete_chunk01b.mdl",
    "models/props_debris/concrete_chunk01c.mdl",
    "models/props_debris/concrete_chunk02a.mdl",
    "models/props_debris/concrete_chunk02b.mdl",
    "models/props_debris/concrete_chunk06c.mdl",
    "models/props_debris/concrete_chunk06d.mdl",
    "models/props_debris/concrete_chunk08a.mdl",
    "models/props_debris/walldestroyed08a.mdl",
    "models/props_debris/concrete_floorpile01a.mdl",
    "models/props_debris/concrete_section128wall001c.mdl",
    "models/props_debris/concrete_wall01a.mdl",
    "models/props_debris/plaster_ceilingpile001b.mdl",
    "models/props_debris/plaster_ceilingpile001a.mdl",
    "models/props_debris/plaster_ceilingpile001c.mdl"
}

if SERVER then util.AddNetworkString( "lambda_c4_decal" ) end

function ENT:Initialize()

    if SERVER then

        self:SetModel( "models/weapons/w_c4.mdl" )
        self:SetColor( self:GetPlayer():GetPlyColor():ToColor() )

        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:PhysWake()

        self.l_delay = 2
        self.l_timer = CurTime() + 2
        self.l_countingdown = true

        self:EmitSound( "lambdaplayers/c4_plant_quiet.wav", 70 )

    end

end

function ENT:Draw()
    self.l_ownerpfp = self.l_ownerpfp or self:GetPlayer():GetPFPMat()
    self.l_ownername = self.l_ownername or self:GetPlayer():Name()
    self.l_ownercolor = self.l_ownercolor or self:GetPlayer():GetPlyColor()

    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr( self:GetPos() ) <= 300 ^ 2 then

        local ang = ( self:GetPos() - LocalPlayer():EyePos() ):Angle()
        ang:RotateAroundAxis( ang:Up(), -90 )
        ang:RotateAroundAxis( ang:Forward(), 90 )

        cam.Start3D2D( self:GetPos() + Vector( 0, 0, 35 ), ang, 1 )
            draw.DrawText( self.l_ownername, "Trebuchet24", 0, 0, self.l_ownercolor:ToColor(), TEXT_ALIGN_LEFT )
        cam.End3D2D()

        render.SetMaterial( self.l_ownerpfp )
        render.DrawSprite( ( self:GetPos() + Vector( 0, 0, 30 ) ) - EyeAngles():Right() * 25, 32, 32, color_white )

    end
end

function ENT:OnTakeDamage( info )
    self:TakePhysicsDamage( info )
end

local trace = {}

function ENT:Think()
    if CLIENT then return end

    if self.l_countingdown and self.l_delay > 0 and CurTime() > self.l_timer then 

        self:EmitSound( "lambdaplayers/c4_click.wav", 80, 100, 1, CHAN_WEAPON )
        
        self.l_delay = self.l_delay - 0.1
        self.l_timer = CurTime() + self.l_delay
    elseif self.l_countingdown and self.l_delay <= 0 then 

        self:EmitSound( "lambdaplayers/nvg_on.wav", 80 )

        for k, lambda in ipairs( ents.FindByClass( "npc_lambdaplayer" ) ) do
            timer.Simple( math.Rand( 0, 1 ), function()
                if !IsValid( self ) or !IsValid( lambda ) then return end
                if lambda:CanSee( self ) then
                    lambda:RetreatFrom( self )
                end
            end )
        end
        
        timer.Simple( 1, function() if !IsValid( self ) then return end self:EmitSound( "lambdaplayers/arm_bomb.wav", 80 ) end )

        timer.Simple( 2, function()
            if !IsValid( self ) then return end

            ParticleEffect( "explosion_huge", self:GetPos(),Angle(0,0,0) )
            util.BlastDamage( self, IsValid( self:GetPlayer() ) and self:GetPlayer() or self, self:GetPos() + Vector( 0, 0, 10 ), 2500, 1000 )
            util.ScreenShake( self:GetPos(), 50, 100, 4, 5400 )
            sound.Play("lambdaplayers/explode_6.wav", self:GetPos(), 100, 100, 1 )
            sound.Play( "ambient/explosions/explode_2.wav", self:GetPos(), 100, 100, 1 )

            trace.start = self:GetPos()
            trace.endpos = self:GetPos() - Vector( 0, 0, 10000 )
            trace.mask = MASK_SOLID_BRUSHONLY
            trace.collisiongroup = COLLISION_GROUP_WORLD
            local result = util.TraceLine( trace )

            net.Start( "lambda_c4_decal", true )
            net.WriteVector( result.HitPos )
            net.WriteNormal( result.HitNormal )
            net.Broadcast() 

            for i = 1, math.random( 3, 16 ) do
                local concrete = ents.Create( "prop_physics" )
                concrete:SetModel( debris[ math.random( #debris ) ] )
                concrete:SetPos( self:GetPos() + Vector( math.random( -100, 100 ), math.random( -100, 100 ), 100 ) )
                concrete:SetAngles( AngleRand( -180, 180) )
                concrete:Spawn()

                concrete:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
                concrete:Ignite( math.random( 5, 30 ) )
                concrete:SetLocalAngularVelocity( AngleRand( -500, 500 ) )
                local phys = concrete:GetPhysicsObject()

                if IsValid( phys ) then
                    phys:SetMass( 60 )
                    phys:ApplyForceCenter( VectorRand( -800000, 800000 ) )
                end

                timer.Simple( 45, function() if IsValid( concrete ) then concrete:Remove() end end)

            end


            self:Remove()
        end )

        self.l_countingdown = false
    end

end

function ENT:SetupDataTables()
    self:NetworkVar( "Entity", 0, "Player" )
end

if CLIENT then
    net.Receive( "lambda_c4_decal", function()
        local pos = net.ReadVector()
        local normal = net.ReadNormal()

        local mat = Material( util.DecalMaterial( "Scorch" ) )
        util.DecalEx( mat, Entity( 0 ), pos, normal, color_white, 10, 10 )
    end )
end