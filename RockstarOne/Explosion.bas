#ifndef __EXPLOSIONS__
#define __EXPLOSIONS__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST EXPLOSION_OFFSET AS UBYTE = 32
CONST EXPLOSION_SPRITE_START AS UBYTE = 64
CONST EXPLOSION_SPRITE_FRAMES AS UBYTE = 14
CONST EXPLOSION_ANIMATION_SPEED AS UBYTE = 2
CONST EXPLOSION_MAX_PARTICLES AS UBYTE = 16

CONST EXPLOSION_X AS UBYTE = 0
CONST EXPLOSION_Y AS UBYTE = 1
CONST EXPLOSION_DX AS UBYTE = 2
CONST EXPLOSION_DY AS UBYTE = 3
CONST EXPLOSION_COUNTER AS UBYTE = 4
CONST EXPLOSION_SPRITE_FLAGS AS UBYTE = 5

' ========================
' === Global Variables ===
' ========================
DIM ExplosionAnimation(EXPLOSION_MAX_PARTICLES, 6) AS INTEGER
DIM ExplosionCount AS BYTE = 0

' =================
' === Functions ===
' =================

' ============================
' === EXPLOSION_Initialise ===
' ============================
SUB EXPLOSION_Initialise()
    ' declare variables
    DIM index AS UBYTE    
    
    ' initialise explosion count
    ExplosionCount = 0

    ' iterate over explosion particle array
    FOR index = 0 TO (EXPLOSION_MAX_PARTICLES - 1)
        ' init the animation counter to -1 (which will mean explosion is not live)
        ExplosionAnimation(index, EXPLOSION_COUNTER) = -1
    NEXT index
END SUB

' =======================
' === EXPLOSION_Start ===
' =======================
SUB EXPLOSION_Start(x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER, size AS INTEGER)
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0
    DIM spriteFlags AS UBYTE = 0

    ' have we already got the max number of particles?
    IF ExplosionCount >= EXPLOSION_MAX_PARTICLES
        RETURN
    END IF

    ' iterate over explosion array
    FOR index = 0 TO (EXPLOSION_MAX_PARTICLES - 1)
        ' is this a "dead" explosion we can re-use?
        IF ExplosionAnimation(index, EXPLOSION_COUNTER) = -1
            ' yes, grab the index and break out of the for loop
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < EXPLOSION_MAX_PARTICLES
        
        ' big rock?
        IF size > 1
            ' big explosion
            spriteFlags = sprX2 BOR sprY2
        END IF

        ' set x/y coords
        ExplosionAnimation(firstAvailable, EXPLOSION_X) = x + 111 + CAST(INTEGER, RND * 64)
        ExplosionAnimation(firstAvailable, EXPLOSION_Y) = y + 111 + CAST(INTEGER, RND * 64)
        
        ' set velocity

        ' we are setting velocity of the explosion based on the velocity of the thing that has been blown up
        ' we want the explosion to move at 3/4 speed of the rock/ship/alien, but not too slow
        IF dx > 15
            dx = dx - (dx / 4)
        END IF

        IF dy > 15
            dy = dy - (dy / 4)
        END IF

        ExplosionAnimation(firstAvailable, EXPLOSION_DX) = (0 - dx) + CAST(INTEGER, RND * 8) - 4
        ExplosionAnimation(firstAvailable, EXPLOSION_DY) = (0 - dy) + CAST(INTEGER, RND * 8) - 4
        
        ' start animation counter
        ExplosionAnimation(firstAvailable, EXPLOSION_COUNTER) = 0

        ' set sprite flags
        ExplosionAnimation(firstAvailable, EXPLOSION_SPRITE_FLAGS) = spriteFlags

        ' increment explosion count
        ExplosionCount = ExplosionCount + 1
    END IF
END SUB

' ========================
' === EXPLOSION_Update ===
' ========================
SUB EXPLOSION_Update()
    ' declare variables
    DIM index AS UBYTE = 0
    DIM PlotX AS UINTEGER
    DIM PlotY AS UBYTE

    ' have we got any explosions to process?
    IF ExplosionCount = 0
        RETURN
    END IF

    ' iterate over explosion array
    FOR index = 0 TO (EXPLOSION_MAX_PARTICLES - 1)
        IF ExplosionAnimation(index, EXPLOSION_COUNTER) > -1 AND ExplosionAnimation(index, EXPLOSION_COUNTER) < (EXPLOSION_SPRITE_FRAMES * EXPLOSION_ANIMATION_SPEED)
            ' show the sprite
            PlotX = CAST(UINTEGER, (ExplosionAnimation(index, EXPLOSION_X) >> 4))
            PlotY = CAST(UBYTE, (ExplosionAnimation(index, EXPLOSION_Y) >> 4))
            UpdateSprite(PlotX, PlotY, EXPLOSION_SPRITE_START + index, EXPLOSION_OFFSET + (ExplosionAnimation(index, EXPLOSION_COUNTER) MOD EXPLOSION_ANIMATION_SPEED), 0, 0)

            ' update explosion values
            ExplosionAnimation(index, EXPLOSION_X) = ExplosionAnimation(index, EXPLOSION_X) + ExplosionAnimation(index, EXPLOSION_DX)
            ExplosionAnimation(index, EXPLOSION_Y) = ExplosionAnimation(index, EXPLOSION_Y) + ExplosionAnimation(index, EXPLOSION_DY)
            ExplosionAnimation(index, EXPLOSION_COUNTER) = ExplosionAnimation(index, EXPLOSION_COUNTER) + 1
        ELSE IF ExplosionAnimation(index, EXPLOSION_COUNTER) >= (EXPLOSION_SPRITE_FRAMES * EXPLOSION_ANIMATION_SPEED)
            ' remove the sprite
            RemoveSprite(EXPLOSION_SPRITE_START + index, 0)
            ExplosionAnimation(index, EXPLOSION_COUNTER) = -1
            ExplosionCount = ExplosionCount - 1
        END IF
    NEXT index
END SUB

#endif