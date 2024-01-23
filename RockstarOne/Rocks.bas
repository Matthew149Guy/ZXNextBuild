' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST ROCK_SPRITE_OFFSET AS UBYTE = 16
CONST ROCK_SPRITE_START AS UBYTE = 32
CONST ROCK_MIN_ROCKS AS UBYTE = 3
CONST ROCK_MAX_ROCKS AS UBYTE = 5
CONST ROCK_MAX_TOTAL_ROCKS AS UBYTE = 48
CONST ROCK_ANIMATION_COUNTER_MAX AS UBYTE = 18
CONST ROCK_ANIMATION_X AS UBYTE = 0
CONST ROCK_ANIMATION_Y AS UBYTE = 1
CONST ROCK_ANIMATION_DX AS UBYTE = 2
CONST ROCK_ANIMATION_DY AS UBYTE = 3
CONST ROCK_ANIMATION_COUNTER AS BYTE = 4
CONST ROCK_ANIMATION_SIZE AS UBYTE = 5
CONST ROCK_ANIMATION_SPRITE_FLAGS AS UBYTE = 6
CONST ROCK_ANIMATION_SPRITE_SET AS UBYTE = 7

' ========================
' === Global Variables ===
' ========================
DIM RockAnimation(ROCK_MAX_TOTAL_ROCKS, 8) AS INTEGER
DIM RockCount AS BYTE = 0

' =================
' === Functions ===
' =================

' =========================
' === InitialiseRocks ===
' =========================
SUB ROCK_InitialiseRocks(noOfRocks AS BYTE)
    ' declare variables
    DIM index AS UBYTE
    DIM rocksAdded AS UBYTE = 0
    DIM rockX AS INTEGER
    DIM rockY AS INTEGER
    
    ' initialise rock count
    RockCount = 0

    IF noOfRocks < ROCK_MIN_ROCKS
        noOfRocks = ROCK_MIN_ROCKS
    END IF

    IF noOfRocks > ROCK_MAX_ROCKS
        noOfRocks = ROCK_MAX_ROCKS
    END IF

    ' iterate over rocks array
    FOR index = 0 TO (ROCK_MAX_TOTAL_ROCKS - 1)
        ' init the animation counter to -1 (which will mean particle is not live)
        RockAnimation(index, ROCK_ANIMATION_COUNTER) = -1 
    NEXT index

    WHILE rocksAdded < noOfRocks
        rockX = CAST(INTEGER, RND * 300 * 16) + 160
        rockY = CAST(INTEGER, RND * 236 * 16) + 160

        ROCK_StartRock(rockX, rockY, 2)
        ROCK_StartRock(rockX, rockY, 1)
        ROCK_StartRock(rockX, rockY, 0)

        rocksAdded = rocksAdded + 1
    END WHILE
END SUB

SUB ROCK_StartRock(x AS INTEGER, y AS INTEGER, size AS INTEGER)
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0
    DIM spriteFlags AS UBYTE = 0
    DIM spriteSet AS UBYTE = 0

    ' do we need to set sprite flags?
    IF size = 2
        spriteFlags = sprX2 BOR sprY2
        spriteSet = 0
    ELSE IF size = 1
        spriteFlags = 0
        spriteSet = 0
    ELSE
        spriteFlags = 0
        spriteSet = ROCK_SPRITE_OFFSET     
    END IF

    ' have we already got the max number of rocks?
    IF RockCount >= ROCK_MAX_TOTAL_ROCKS
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (ROCK_MAX_TOTAL_ROCKS - 1)
        IF RockAnimation(index, ROCK_ANIMATION_COUNTER) = -1
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < ROCK_MAX_TOTAL_ROCKS
        RockAnimation(firstAvailable, ROCK_ANIMATION_X) = x
        RockAnimation(firstAvailable, ROCK_ANIMATION_Y) = y
        RockAnimation(firstAvailable, ROCK_ANIMATION_DX) = (CAST(INTEGER, RND * 176) - 88) >> size
        RockAnimation(firstAvailable, ROCK_ANIMATION_DY) = (CAST(INTEGER, RND * 176) - 88) >> size
        RockAnimation(firstAvailable, ROCK_ANIMATION_COUNTER) = CAST(INTEGER, RND * 18)
        RockAnimation(firstAvailable, ROCK_ANIMATION_SIZE) = size
        RockAnimation(firstAvailable, ROCK_ANIMATION_SPRITE_FLAGS) = spriteFlags
        RockAnimation(firstAvailable, ROCK_ANIMATION_SPRITE_SET) = spriteSet
        RockCount = RockCount + 1
    END IF
END SUB

SUB ROCK_UpdateRocks()
    ' declare variables
    DIM index AS UBYTE = 0
    DIM PlotX AS UINTEGER
    DIM PlotY AS UBYTE
    DIM spriteOffset AS UBYTE = 0

    ' have we got any rocks to process?
    IF RockCount = 0
        RETURN
    END IF

    ' iterate over rocks array
    FOR index = 0 TO (ROCK_MAX_TOTAL_ROCKS - 1)
        IF RockAnimation(index, ROCK_ANIMATION_COUNTER) > -1
            ' show the sprite
            PlotX = CAST(INTEGER, (RockAnimation(index, ROCK_ANIMATION_X) >> 4))
            PlotY = CAST(INTEGER, (RockAnimation(index, ROCK_ANIMATION_Y) >> 4))

            UpdateSprite(PlotX, PlotY, ROCK_SPRITE_START + index, RockAnimation(index, ROCK_ANIMATION_SPRITE_SET) + (RockAnimation(index, ROCK_ANIMATION_COUNTER) >> 1), 0, RockAnimation(index, ROCK_ANIMATION_SPRITE_FLAGS))

            ' update rock values
            RockAnimation(index, ROCK_ANIMATION_X) = RockAnimation(index, ROCK_ANIMATION_X) + RockAnimation(index, ROCK_ANIMATION_DX)
            RockAnimation(index, ROCK_ANIMATION_Y) = RockAnimation(index, ROCK_ANIMATION_Y) + RockAnimation(index, ROCK_ANIMATION_DY)

            ' check for going out of bounds - x axis
            IF RockAnimation(index, ROCK_ANIMATION_X) > 335 * 16
                RockAnimation(index, ROCK_ANIMATION_X) = -31 * 16
            ELSE IF RockAnimation(index, ROCK_ANIMATION_X) < -31 * 16
                RockAnimation(index, ROCK_ANIMATION_X) = 335 * 16
            END IF

            ' check for going out of bounds - y axis
            IF RockAnimation(index, ROCK_ANIMATION_Y) >= 256 * 16
                RockAnimation(index, ROCK_ANIMATION_Y) = 0
            ELSE IF RockAnimation(index, ROCK_ANIMATION_Y) < 0
                RockAnimation(index, ROCK_ANIMATION_Y) = (256 * 16) - 1
            END IF

            ' incrememnt rock animation counter
            RockAnimation(index, ROCK_ANIMATION_COUNTER) = RockAnimation(index, ROCK_ANIMATION_COUNTER) + 1

            ' check rock animation counter has not gone beyond max value
            IF RockAnimation(index, ROCK_ANIMATION_COUNTER) >= ROCK_ANIMATION_COUNTER_MAX
                RockAnimation(index, ROCK_ANIMATION_COUNTER) = 0
            END IF
        END IF
    NEXT index
END SUB

SUB KillRock(index AS UBYTE)
    ' remove the sprite
    RemoveSprite(ROCK_SPRITE_START + index, 0)
    RockAnimation(index, ROCK_ANIMATION_COUNTER) = -1
    RockCount = RockCount - 1
END SUB