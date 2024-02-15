'!org=24576
'!heap=4096

' ================
' === Includes ===
' ================
#DEFINE NEX
#DEFINE IM2

#INCLUDE <nextlib.bas>
#include <keys.bas>

#INCLUDE "./PlayerShip.bas"
#INCLUDE "./Rocks.bas"
#INCLUDE "./Explosion.bas"
#INCLUDE "./Alien.bas"
#INCLUDE "./Collision.bas"
#INCLUDE "./BonusScore.bas"
#INCLUDE "./SoundFX.bas"

' =================
' === Constants ===
' =================

' ========================
' === Global Variables ===
' ========================

' =================
' === Functions ===
' =================

' ========================
' === InitialiseSystem ===
' ========================
SUB InitialiseSystem()
    NextRegA($7,3)					' 28mhz 
    NextRegA($14,227)					' black transparency 
    NextRegA($70,%00010000)			' enable 320x256 256col L2 
    NextRegA($69,%10000000)			' enables L2 
    
    
    'NextReg($15,%00000001) 
    asm 
        nextreg $56,34
        nextreg $57,35
        nextreg $43,%00100000
        nextreg $15,%01100011
    end asm
    ClipLayer2(0,255,0,255)			' make all of L2 visible 
    ClipSprite(0, 255, 32, 255)

    ' load image
    LoadBMP("sprial.bmp")

    ShowLayer2(1)

    ' load sprites
    LoadSDBank("RockstarOne.spr",0,0,0,34)
    ' initialise sprites
    InitSprites(64,$c000)

    ' load font
    LoadSDBank("font4.spr",0,0,0,40)

    ' initialise sound
    ' load sfx data
    LoadSDBank("RockstarOneSFX.afb", 0, 0, 0, 43)
    LoadSDBank("vt24000.bin", 0, 0, 0, 41)
    LoadSDBank("level1.pt3", 0, 0, 0, 42)
    InitSFX(43)
    InitMusic(41, 42, 0000)
    SetUpIM()

    PlaySFX(0)

    EnableSFX

    ' initialise player ship
    SHIP_Initialise()

    ' initilaise rocks
    ROCK_InitialiseRocks(3)

    ' initialise explosions
    EXPLOSION_Initialise()

    ' initialise alien
    ALIEN_Initialise()

    ' initialise bonus scores
    BONUS_SCORE_Initialise()
END SUB

' ===============
' === Program ===
' ===============
RANDOMIZE
InitialiseSystem()

DIM counter AS BYTE = 0
DIM mainindex AS BYTE = 0
DIM offset AS BYTE = 9
DIM spFlags AS BYTE = 0
DIM delaycount AS BYTE = 0
DIM message AS STRING
DIM fireKeyDown AS UBYTE = 0

'EnableMusic

FL2Text(0, 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 40)
FL2Text(1, 1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 40)
FL2Text(2, 2, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 40)
FL2Text(3, 3, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 40)

DO
    IF MultiKeys(KEYSPACE)
        EXIT DO
    END IF

    IF delaycount > 3
        IF MultiKeys(KEYW)
            SHIP_ThrustShip(1)
            PlaySFX(1)
        ELSE
            SHIP_ThrustShip(0)
        END IF

        IF MultiKeys(KEYD)
            SHIP_RotateShip(0)
        END IF

        IF MultiKeys(KEYA)
            SHIP_RotateShip(1)
        END IF

        IF MultiKeys(KEYL)
            IF fireKeyDown = 0
                BULLET_StartBullet(Ship_X, Ship_Y, ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DX), ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DY))
                PlaySFX(13)
                fireKeyDown = 1
            END IF
        ELSE
            fireKeyDown = 0
        END IF

        delaycount = 0

        ' check for collisions
        COLLISION_BulletsAndRocks()
        COLLISION_BulletsAndAlien()

        ' display ship, engne wash & bullets
        SHIP_UpdateShip()
        
        ' display rocks
        ROCK_UpdateRocks()

        ' update alien
        ALIEN_UpdateAlien()

        ' display explosions
        EXPLOSION_Update()

        ' display bonus scores
        BONUS_SCORE_Update()
    END IF

    
    

    mainindex = mainindex + 1
    IF mainindex > 23
        mainindex = 0
    END IF


    delaycount = delaycount + 1

    WaitRetrace2(1)
    
LOOP

CallbackSFX()