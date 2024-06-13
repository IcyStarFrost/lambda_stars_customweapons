local util = util

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    
    babylauncher = {
        model = "models/weapons/w_rocket_launcher.mdl",
        origin = "Star's Weapons",
        prettyname = "Baby Launcher",
        holdtype = "rpg",
        killicon = "lambdaplayers/killicons/baby",
        bonemerge = true,
        keepdistance = 800,
        attackrange = 5000,

        callback = function( self, wepent, target )            
            local baby = ents.Create( "prop_physics" )
            if !IsValid( baby ) then return end

            self.l_WeaponUseCooldown = CurTime() + 1.5

            wepent:EmitSound( "weapons/rpg/rocketfire1.wav", 80, 100, 1, CHAN_WEAPON )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG )

            baby:SetModel( "models/props_c17/doll01.mdl" )
            baby:SetPos( wepent:GetPos() )
            baby:SetAngles( self:EyeAngles2() )
            baby:SetOwner( self )
            baby:SetPhysicsAttacker( self, 5 )
            baby:Spawn()


            baby:EmitSound( "lambdaplayers/babylauncher/babyshot.wav", 80 )

            local phys = baby:GetPhysicsObject()
            if IsValid( phys ) then
                phys:ApplyForceCenter( ( target:WorldSpaceCenter() - self:EyePos2() ):GetNormalized() * 100000 )
            end
            local id
            id = baby:AddCallback( "PhysicsCollide", function()
                local dmg = DamageInfo()
                dmg:SetAttacker( self )
                dmg:SetInflictor( wepent )
                dmg:SetDamage( 45 )
                dmg:SetDamageType( DMG_BULLET + DMG_CRUSH )

                util.BlastDamageInfo( dmg, baby:GetPos(), 100 )
                baby:RemoveCallback( "PhysicsCollide", id)
            end )

            timer.Simple( 15, function() 
                if IsValid( baby ) then baby:Remove() end
            end )

            return true
        end,

        islethal = true,
    }

})

local IsValid = IsValid
local random = math.random
local CurTime = CurTime
local DamageInfo = DamageInfo

local idlesounds = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
	"ambient/creatures/town_child_scream1.wav",
	"ambient/creatures/town_child_scream1.wav",
	"ambient/creatures/town_child_scream1.wav",
	"ambient/creatures/town_muffled_cry1.wav",
	"ambient/creatures/town_muffled_cry1.wav",
	"ambient/creatures/town_muffled_cry1.wav",
	"ambient/creatures/town_zombie_call1.wav",
	"npc/zombie_poison/pz_pain3.wav",
	"npc/fast_zombie/fz_alert_far1.wav",
}

local swingsounds = {

	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie_poison/pz_warn2.wav",
	"npc/fast_zombie/fz_frenzy1.wav",
}

local deathsounds = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
}

local Models = {
	"models/zombie/classic.mdl",
	"models/zombie/classic_legs.mdl",
	"models/zombie/fast.mdl",
	"models/humans/corpse1.mdl",
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {

	thezombie = {
		model = "models/zombie/classic.mdl",
		origin = "Misc",
		prettyname = "The Zombie",
		holdtype = "melee2",
		--killicon = "lambdaplayers/killicons/tpose_kl",
		ismelee = true,
		bonemerge = false,
		offPos = Vector(0,0,0),   
		offAng = Angle( 0, 0, 0 ),
		keepdistance = 10,
		attackrange = 70,

		OnDeploy = function( lambda, wepent )
			wepent.NextBabbleTime = 0
			wepent:SetModel( Models[ random( #Models ) ] )
            wepent:SetLocalAngles( Angle( -90, 0, -90 ))
            wepent:SetLocalPos( Vector( 0, -20, 0 ) )
		end,

		OnHolster = function( lambda, wepent )
			wepent.NextBabbleTime = nil
		end,

		OnDeath = function( lambda, wepent, dmginfo )
			wepent:EmitSound( deathsounds[ random( #deathsounds ) ], 70 )
			for _, sound in ipairs( idlesounds ) do
				wepent:StopSound( sound )
			end
		end,

		OnThink = function( lambda, wepent, dead )
			if !dead and CurTime() > wepent.NextBabbleTime then
				wepent:EmitSound( idlesounds[ random( #idlesounds ) ], 70 )
			end

			return random( 4.0, 7.0 )
		end,
				
		OnAttack = function( self, wepent, target )
			self.l_WeaponUseCooldown = CurTime() + random( 0.64, 0.72 )
			wepent:EmitSound( swingsounds[ random( #swingsounds ) ], 70 )
			wepent:EmitSound( "npc/zombie/claw_miss" .. random( 1,2 )..".wav", 65 )

			for _, sound in ipairs( idlesounds ) do
				wepent:StopSound( sound )
			end

			self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
			self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
			
			self:SimpleWeaponTimer( 0.3, function()
				if !IsValid( target ) or !self:IsInRange( target, 60 ) then return end

				local dmg = random( 8, 16 )
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( dmg )
				dmginfo:SetAttacker( self )
				dmginfo:SetInflictor( wepent )
				dmginfo:SetDamageType( DMG_CLUB )
				dmginfo:SetDamageForce( ( target:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized() * dmg )
				target:TakeDamageInfo( dmginfo )

				target:EmitSound( "physics/flesh/flesh_impact_hard" .. random( 1,5 )..".wav", 80 )
				target:EmitSound( "physics/flesh/flesh_squishy_impact_hard" .. random( 1,4 )..".wav", 80 )
			end )

			return true
		end,

		islethal = true
	}
} )

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    technology = {
        model = "models/props_lab/workspace003.mdl",
        origin = "Star's Weapons",
        prettyname = "Advanced Computer Technology",
        holdtype = "duel",
        ismelee = true,
        killicon = "lambdaplayers/killicons/workspace",
        keepdistance = 100,
        attackrange = 150,
        weaponscale = 0.3,
        offang = Angle( -80, 0, -90 ),

        callback = function( self, wepent, target )

            self.l_WeaponUseCooldown = CurTime() + 2

            wepent:EmitSound( "lambdaplayers/technology/tech.mp3", 100, math.random( 98, 102 ), 1, CHAN_WEAPON ) 
            target:EmitSound( "vo/k_lab/kl_ahhhh.wav", 70 )

            
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE )
        
            local dmg = DamageInfo() 
            dmg:SetDamage( 500 )
            dmg:SetAttacker( self )
            dmg:SetInflictor( wepent )
            dmg:SetDamageType( DMG_CLUB )
            dmg:SetDamageForce( ( target:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized() * 500 )
        
            target:TakeDamageInfo( dmg )

            return true
        end,

        islethal = true,
    }

})

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    weaponizedtoolgun = {
        model = "models/weapons/w_toolgun.mdl",
        origin = "Star's Weapons",
        prettyname = "Weaponized Toolgun",
        holdtype = "revolver",
        killicon = "lambdaplayers/killicons/toolgun",
        ismelee = false,
        bonemerge = true,
        
        keepdistance = 300, -- Stay away from our enemy 300 units away
        attackrange = 2000, -- Attack when we are within 2000 units near our enemy
        spread = 0.1, -- Spread
        damage = 10, -- Do 10 damage
        rateoffire = 0.3, -- 0.3 seconds 
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER, -- The recoil gesture
        bulletcount = 1, -- Shoot only one bullet at a time
        tracername = "ToolTracer", -- Toolgun tracer
        attacksnd = "weapons/airboat/airboat_gun_lastshot*2*.wav", -- Forgot the fire sound. The * on each side of the 2 means it will randomly pick a number from 1 to 2
        clip = 20, -- 20 shots per clip

        -- I won't add muzzleflash or shelleject since we don't really need it

        reloadtime = 2, -- 2 second reload
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER, -- Revolver reload
        reloadsounds = { { 0.1, "ambient/energy/zap1.wav" }, { 1, "ambient/machines/combine_terminal_idle2.wav" }, { 1.8, "ambient/energy/whiteflash.wav" }  }, -- The reload sounds

        islethal = true,
    }

})

local bazingatbl = {
    "lambdaplayers/vin.mp3",
    "lambdaplayers/Bazinga!.mp3",
    "lambdaplayers/spotpills01.wav"
}

local function bazinga( lambda, wepent )
    local tbl = table.Add( GetLambdaPlayers(), player.GetAll() )
    for k, v in RandomPairs( tbl ) do
        if !IsValid( v ) or v == lambda or v.IsLambdaPlayer and v:GetIsDead() then continue end
        local nav = navmesh.GetNavArea( v:GetPos(), 100 )
        if !nav then continue end

        lambda:SetPos( nav:GetClosestPointOnArea( v:GetPos() + v:GetForward() * 80 ) )
        lambda:WaitWhileMoving( 1 )

        timer.Simple( 0.01, function()
            if !IsValid( lambda ) then return end
            local snd = bazingatbl[ math.random( #bazingatbl ) ]
            lambda:EmitSound( snd, 100 )
            lambda:EmitSound( snd, 100 )
            lambda:EmitSound( snd, 100 )
        end )

        timer.Simple( 0.6, function()
            if !IsValid( lambda ) then return end
            util.BlastDamage( wepent, lambda, lambda:WorldSpaceCenter(), 600, 300 )
            local effect = EffectData()
            effect:SetOrigin( lambda:WorldSpaceCenter() )
            util.Effect( "Explosion", effect, true, true )
        end )
        break
    end
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    bazinga = {
        model = "models/hunter/plates/plate.mdl",
        origin = "Star's Weapons",
        prettyname = "Bazinga!",
        holdtype = "normal",
        rateoffire = 5,
        damage = 0,

        OnThink = function( lambda, wepent, target )
            if math.random( 1, 300 ) == 1 then
                bazinga( lambda, wepent )
            end
        end,

        OnAttack = function( lambda, wepent )
            bazinga( lambda, wepent )
        end,

        nodraw = true,
        dropondeath = false,
        ismelee = true,
        islethal = true,
    }
} )

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    handheld_combineturret = {
        model = "models/Combine_turrets/Floor_turret.mdl",
        origin = "Star's Weapons",
        prettyname = "Handheld Turret",
        --killicon = "weapon_smg1",
        holdtype = "pistol",
        keepdistance = 300,
        attackrange = 1500,
        weaponscale = 0.3,
        offang = Angle( -90, 0, -90 ),
        offpos = Vector( 0, -5, 0 ),

        clip = 100,
        tracername = "AR2Tracer",
        damage = 3,
        spread = 0.35,
        rateoffire = 0.1,
        muzzleflash = 5,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1,
        attacksnd = "^npc/turret_floor/shoot*3*.wav",

        reloadtime = 2,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SMG1,
        reloadanimspeed = 0.7,
        reloadsounds = { { 0, "npc/turret_floor/retract.wav" }, { 0.2, "npc/turret_floor/click1.wav" }, { 0.5, "npc/turret_floor/click1.wav" }, { 1, "weapons/pistol/pistol_reload1.wav" } },

        islethal = true,
    }

})

local up = Vector( 0, 0, 200 )
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    powerlinepole = {
        model = "models/props_c17/utilitypole01a.mdl",
        origin = "Star's Weapons",
        prettyname = "Power Line Pole",
        killicon = "lambdaplayers/killicons/utilitypole",
        holdtype = "melee2",
        ismelee = true,
        keepdistance = 100,
        offang = Angle( 0, 0, -90 ),
        attackrange = 400,

        callback = function( self, wepent, target )

            self.l_WeaponUseCooldown = CurTime() + 2

            wepent:EmitSound( "physics/nearmiss/whoosh_large4.wav", 80, math.random( 98, 102 ), 1, CHAN_WEAPON ) 
            

            
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
            local id = self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
            self:SetLayerPlaybackRate( id, 0.4 )
        
            self:SimpleTimer( 1, function()
                if !IsValid( target ) or !self:IsInRange( target, 400 ) then return end

                wepent:EmitSound( "ambient/explosions/explode_3.wav", 80, math.random( 98, 102 ), 1, CHAN_WEAPON ) 
                target:EmitSound( "ambient/machines/slicer2.wav", 70 )

                for k, v in ipairs( self:FindInSphere( nil, 1000 ) ) do
                    if !IsValid( v ) then continue end

                    if v:IsPlayer() then
                        v:SetPos( v:GetPos() + Vector( 0, 0, 5 ) )
                        v:SetVelocity( up )
                    elseif v.IsLambdaPlayer then
                        v.loco:Jump()
                        v.loco:SetVelocity( v.loco:GetVelocity() + up )
                    elseif IsValid( v:GetPhysicsObject() ) then
                        local phys = v:GetPhysicsObject()
                        phys:ApplyForceCenter( up * phys:GetMass() )
                    end
                end
                self.loco:Jump()
                self.loco:SetVelocity( self.loco:GetVelocity() + up )

                local willkill = ( target:Health() - 60 ) <= 0
                local force =( target:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized() * 500
                if target.IsLambdaPlayer and willkill then 
                    target.loco:Jump()
                    target.loco:SetVelocity( target.loco:GetVelocity() + ( self:GetNormalTo( target ) * 2000 ) + up * 2 )
                elseif willkill then 
                    force = ( self:GetNormalTo( target ) * ( 60 * 20 ) ) + up * ( 10 * 20 )
                end

                self:SimpleTimer( 0.1, function()
                    if !IsValid( target ) then return end
                    local dmg = DamageInfo() 
                    dmg:SetDamage( 60 )
                    dmg:SetAttacker( self )
                    dmg:SetInflictor( wepent )
                    dmg:SetDamageType( DMG_CLUB )
                    dmg:SetDamageForce( force )

                    util.ScreenShake( target:GetPos(), 10, 200, 1.5, 3000 )
                
                    target:TakeDamageInfo( dmg )
                end )
            end )

            return true
        end,

        islethal = true,
    }

})

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    thecrate = {
        model = "models/props_junk/wood_crate002a.mdl",
        origin = "Star's Weapons",
        prettyname = "The Crate",
        holdtype = "melee",
        killicon = "lambdaplayers/killicons/woodcrate",
        ismelee = true,
        keepdistance = 10,
        attackrange = 85,
        offang = Angle( 0, 0, -90 ),
        offpos = Vector( 0, 0, 30 ),

        damage = 25,
        rateoffire = 0.7,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
        attacksnd = "Weapon_Crowbar.Single",
        hitsnd = "Weapon_Crowbar.Melee_Hit",

        callback = function( self, wepent, target )
            self:SimpleTimer( 0.1, function()
                local box = ents.Create( "prop_physics" )
                box:SetModel( "models/props_junk/wood_crate002a.mdl" )
                box:SetCollisionGroup( COLLISION_GROUP_WORLD )
                box:SetPos( wepent:GetPos() ) 
                box:SetAngles( wepent:GetAngles() )
                box:Spawn()
                timer.Simple( 0.05, function()
                    if !IsValid( box ) then return end
                    box:TakeDamage( 100, self or box, wepent or box )
                end )
            end )
        end,

        islethal = true,
    }

})



table.Merge( _LAMBDAPLAYERSWEAPONS, {

    leadpipe = {
        model = "models/props_canal/mattpipe.mdl",
        origin = "Star's Weapons",
        prettyname = "Lead Pipe",
        holdtype = "melee",
        killicon = "lambdaplayers/killicons/leadpipe",
        ismelee = true,
        keepdistance = 10,
        attackrange = 55,
        offang = Angle( 180, 0, 90 ),
        offpos = Vector( 0, 0, 0 ),

        damage = 10000000,
        rateoffire = 1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
        attacksnd = "Weapon_Crowbar.Single",
        hitsnd = "lambdaplayers/leadpipe.wav",

        islethal = true,
    }

})

local swingsounds = {
    "vo/k_lab/kl_getoutrun02.wav",
    "vo/k_lab/kl_getoutrun01.wav",
    "vo/k_lab/kl_ahhhh.wav",
    "vo/k_lab/kl_getoutrun03.wav",
    "vo/k_lab/kl_hedyno01.wav",
    "vo/k_lab/kl_hedyno02.wav",
    "vo/k_lab/kl_hedyno03.wav",
    "vo/k_lab/kl_heremypet02.wav",
    "vo/k_lab/kl_heremypet02.wav",
    "vo/k_lab/kl_nocareful.wav"
}

local theklienersnds = {
    "vo/k_lab/kl_comeout.wav",
    "vo/k_lab/kl_dearme.wav",
    "vo/k_lab/kl_cantwade.wav",
    "vo/k_lab/kl_almostforgot.wav",
    "vo/k_lab/kl_bonvoyage.wav",
    "vo/k_lab/kl_blast.wav",
    "vo/k_lab/kl_excellent.wav",
    "vo/k_lab/kl_fiddlesticks.wav",
    "vo/k_lab/kl_waitmyword.wav",
    "vo/k_lab/kl_besokind.wav",
    "vo/k_lab/kl_coaxherout.wav",
    "vo/k_lab/kl_comeout.wav",
    "vo/k_lab/kl_credit.wav",
    "vo/k_lab/kl_debeaked.wav",
    "vo/k_lab/kl_delaydanger.wav",
    "vo/k_lab/kl_diditwork.wav",
    "vo/k_lab/kl_ensconced.wav",
    "vo/k_lab/kl_fewmoments01.wav",
    "vo/k_lab/kl_fewmoments02.wav",
    "vo/k_lab/kl_gordongo.wav",
    "vo/k_lab/kl_gordonthrow.wav",
    "vo/k_lab/kl_mygoodness01.wav",
    "vo/k_lab/kl_opportunetime01.wav",
    "vo/k_lab/kl_wishiknew.wav",
    "vo/k_lab/kl_whatisit.wav",
    "vo/k_lab/kl_thenwhere.wav",
    "vo/k_lab/kl_relieved.wav",
    "vo/k_lab/kl_interference.wav",
    "vo/k_lab2/kl_howandwhen02.wav",

}

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    thekleiner = {
        model = "models/Kleiner.mdl",
        origin = "Star's Weapons",
        prettyname = "Kleiner",
        holdtype = "melee2",
        killicon = "lambdaplayers/killicons/kleiner",
        ismelee = true,
        keepdistance = 10,
        attackrange = 75,
        offang = Angle( -90, 0, -90 ),
        offpos = Vector( 0, -20, 0 ),

        OnThink = function( lambda, wepent )
            if math.random( 1, 100 ) == 1 and ( !lambda.l_thekleinernextspeak or lambda.l_thekleinernextspeak and CurTime() > lambda.l_thekleinernextspeak ) then
                local snd = theklienersnds[ math.random( #theklienersnds ) ]
                wepent:EmitSound( snd, 70 )
                lambda.l_thekleinernextspeak = CurTime() + SoundDuration( snd )
            end
        end,

        OnDrop = function( lambda, wepent, dropent )
            dropent:EmitSound( "vo/k_lab2/kl_greatscott.wav", 80 )
        end,

        
        OnAttack = function( lambda, wepent, target )
            wepent:EmitSound( swingsounds[ math.random( #swingsounds ) ], 70 )
            target:EmitSound( "physics/flesh/flesh_impact_hard" .. math.random( 1, 5 ) .. ".wav", 80 )
        end,

        damage = 15,
        rateoffire = 1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
        attacksnd = "",
        hitsnd = "",

        islethal = true,
    }

})


table.Merge( _LAMBDAPLAYERSWEAPONS, {

    C4 = {
        model = "models/weapons/w_c4.mdl",
        origin = "Star's Weapons",
        islethal = true,
        clip = 1,
        holdtype = "slam",
        prettyname = "C4 Plastic Explosive",
        keepdistance = 500,
        attackrange = 600,
    
        callback = function( self, wepent, targ )

            local c4 = ents.Create( "lambda_c4" )
            c4:SetPos( wepent:GetPos() )
            c4:SetAngles( wepent:GetAngles() )
            c4:SetPlayer( self )
            c4:Spawn()

            if MW2CC then
                MW2CC:DispatchCallCard( self, "Planted C4!" )
            end

            self:SwitchToLethalWeapon()

            return true
        end
    }, 



} )




if CLIENT then 

    net.Receive( "lambdaplayers_c4_createdecal", function()
        local hitpos = net.ReadVector()
        local normal = net.ReadNormal()

        local mat = util.DecalMaterial( "Scorch" )
        local imat = Material( mat )
        util.DecalEx( imat, Entity( 0 ), hitpos, normal, color_white, 10, 10 )
    end )
end






