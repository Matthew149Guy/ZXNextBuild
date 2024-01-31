#ifndef __BONUSSCORE__
#define __BONUSSCORE__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST BONUS_SCORE_OFFSET AS UBYTE = 54
CONST BONUS_SCORE_SPRITE_START AS BYTE = 100
CONST BONUS_SCORE_X AS UBYTE = 0
CONST BONUS_SCORE_Y AS UBYTE = 1
CONST BONUS_SCORE_DX AS UBYTE = 2
CONST BONUS_SCORE_DY AS UBYTE = 3
CONST BONUS_SCORE_SPRITE_OFFSET AS UBYTE = 4
CONST BONUS_SCORE_COUNTER AS UBYTE = 5
CONST BONUS_SCORE_MAX_PARTICLES AS UBYTE = 4

' ========================
' === Global Variables ===
' ========================
DIM BonusScoreAnimation(BONUS_SCORE_MAX_PARTICLES, 6) AS INTEGER
DIM BonusScoreCount AS BYTE = 0

' =================
' === Functions ===
' =================

' ==============================
' === BONUS_SCORE_Initialise ===
' ==============================
SUB BONUS_SCORE_Initialise()
    ' declare variables
    DIM index AS UBYTE 
    DIM box AS INTEGER
    
    ' initialise engine wash count
    BonusScoreCount = 0

    ' iterate over engine wash particle array
    FOR index = 0 TO (BONUS_SCORE_MAX_PARTICLES - 1)
        ' init the animation counter to -1 (which will mean particle is not live)
        BonusScoreAnimation(index, BONUS_SCORE_COUNTER) = -1
    NEXT index
END SUB

' =========================
' === BONUS_SCORE_Start ===
' =========================
SUB BONUS_SCORE_Start(x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER, type AS UBYTE)
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0

    ' have we already got the max number of particles?
    IF BonusScoreCount >= BONUS_SCORE_MAX_PARTICLES
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (BONUS_SCORE_MAX_PARTICLES - 1)
        ' is this a "dead" particle we can re-use?
        IF BonusScoreAnimation(index, BONUS_SCORE_COUNTER) = -1
            ' yes, grab the index and break out of the for loop
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < BONUS_SCORE_MAX_PARTICLES
        ' set x/y coords
        BonusScoreAnimation(firstAvailable, BONUS_SCORE_X) = x + 111 + CAST(INTEGER, RND * 64)
        BonusScoreAnimation(firstAvailable, BONUS_SCORE_Y) = y + 111 + CAST(INTEGER, RND * 64)
        
        ' set velocity
        'BonusScoreAnimation(firstAvailable, BONUS_SCORE_DX) = (0 - dx) + CAST(INTEGER, RND * 8) - 4
        'BonusScoreAnimation(firstAvailable, BONUS_SCORE_DY) = (0 - dy) + CAST(INTEGER, RND * 8) - 4
        BonusScoreAnimation(firstAvailable, BONUS_SCORE_DX) = dx / 4
        BonusScoreAnimation(firstAvailable, BONUS_SCORE_DY) = dy / 4
        
        ' set correct sprite
        BonusScoreAnimation(firstAvailable, BONUS_SCORE_SPRITE_OFFSET) = BONUS_SCORE_OFFSET + 4 - (4 * type)

        ' start animation counter
        BonusScoreAnimation(firstAvailable, BONUS_SCORE_COUNTER) = 0

        ' increment engine wash count
        BonusScoreCount = BonusScoreCount + 1
    END IF
END SUB

' ==========================
' === BONUS_SCORE_Update ===
' ==========================
SUB BONUS_SCORE_Update()
    ' declare variables
    DIM index AS BYTE = 0
    DIM PlotX AS UINTEGER = 0
    DIM PlotY AS UBYTE = 0
    DIM spriteId AS BYTE = 0
    DIM frame AS UBYTE = 0
    DIM offset AS UBYTE = 0

    ' have we got any particles to process?
    IF BonusScoreCount = 0
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (BONUS_SCORE_MAX_PARTICLES - 1)
        IF BonusScoreAnimation(index, BONUS_SCORE_COUNTER) > -1 AND BonusScoreAnimation(index, BONUS_SCORE_COUNTER) < 16
            ' show the sprite
            PlotX = CAST(UINTEGER, (BonusScoreAnimation(index, BONUS_SCORE_X) / 16))
            PlotY = CAST(UBYTE, (BonusScoreAnimation(index, BONUS_SCORE_Y) / 16))
            
            frame = CAST(UBYTE, BonusScoreAnimation(index, BONUS_SCORE_SPRITE_OFFSET))
            offset = BonusScoreAnimation(index, BONUS_SCORE_COUNTER) MOD 4

            frame = frame + offset

            spriteId = 100 + index
            FL2Text(0, 0, "HELLO", 40)
            UpdateSprite(PlotX, PlotY, BONUS_SCORE_SPRITE_START + index, frame, 0, 0)

            ' update engine wash values
            BonusScoreAnimation(index, BONUS_SCORE_X) = BonusScoreAnimation(index, BONUS_SCORE_X) + BonusScoreAnimation(index, BONUS_SCORE_DX)
            BonusScoreAnimation(index, BONUS_SCORE_Y) = BonusScoreAnimation(index, BONUS_SCORE_Y) + BonusScoreAnimation(index, BONUS_SCORE_DY)
            BonusScoreAnimation(index, BONUS_SCORE_COUNTER) = BonusScoreAnimation(index, BONUS_SCORE_COUNTER) + 1
        ELSE IF BonusScoreAnimation(index, BONUS_SCORE_COUNTER) >= 16
            ' remove the sprite
            RemoveSprite(BONUS_SCORE_SPRITE_START + index, 0)
            BonusScoreAnimation(index, BONUS_SCORE_COUNTER) = -1
            BonusScoreCount = BonusScoreCount - 1
        END IF
    NEXT index
END SUB

#endif