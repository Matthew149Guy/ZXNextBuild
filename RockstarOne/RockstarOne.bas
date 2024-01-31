' ================
' === Includes ===
' ================
#DEFINE NEX
#INCLUDE <nextlib.bas>
#include <keys.bas>
#include "./PlayerShip.bas"
#INCLUDE "./Rocks.bas"
#INCLUDE "./Explosion.bas"
#INCLUDE "./Alien.bas"
#INCLUDE "./Collision.bas"
#INCLUDE "./BonusScore2.bas"

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
    NextRegA($14,2270)					' black transparency 
    NextRegA($70,%00010000)			' enable 320x256 256col L2 
    NextRegA($69,%10000000)			' enables L2 
    ClipLayer2(0,255,0,255)			' make all of L2 visible 
    'NextReg($15,%00000001) 
    asm 
        nextreg $56,34
        nextreg $57,35
        nextreg $43,%00100000
        nextreg $15,%00000011
    end asm

    ' load sprites
    LoadSDBank("RockstarOne.spr",0,0,0,34)
    ' initialise sprites
    InitSprites(64,$c000)

    ' load font
    LoadSDBank("font4.spr",0,0,0,40)

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

DO
    IF MultiKeys(KEYSPACE)
        EXIT DO
    END IF

    IF delaycount > 3
        IF MultiKeys(KEYW)
            SHIP_ThrustShip(1)
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