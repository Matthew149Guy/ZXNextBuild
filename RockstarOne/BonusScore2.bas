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
'CONST BONUS_SCORE_X AS UBYTE = 0
'CONST BONUS_SCORE_Y AS UBYTE = 1
'CONST BONUS_SCORE_DX AS UBYTE = 2
'CONST BONUS_SCORE_DY AS UBYTE = 3
'CONST BONUS_SCORE_SPRITE_OFFSET AS UBYTE = 4
'CONST BONUS_SCORE_COUNTER AS UBYTE = 5
CONST BONUS_SCORE_MAX_PARTICLES AS UBYTE = 4

' ========================
' === Global Variables ===
' ========================
'DIM BonusScoreAnimation(BONUS_SCORE_MAX_PARTICLES, 6) AS INTEGER
'DIM BonusScoreCount AS BYTE = 0
DIM BonusScore_X AS INTEGER = 0
DIM BonusScore_Y AS INTEGER = 0
DIM BonusScore_DX AS INTEGER = 0
DIM BonusScore_DY AS INTEGER = 0
DIM BonusScore_SPRITE_OFFSET AS UBYTE = BONUS_SCORE_OFFSET
DIM BonusScore_COUNTER AS UBYTE = -1

' =================
' === Functions ===
' =================

' ==============================
' === BONUS_SCORE_Initialise ===
' ==============================
SUB BONUS_SCORE_Initialise()
    BonusScore_COUNTER = -1
END SUB

' =========================
' === BONUS_SCORE_Start ===
' =========================
SUB BONUS_SCORE_Start(x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER, type AS UBYTE)
    ' set x/y coords
    BonusScore_X = x + 111 + CAST(INTEGER, RND * 64)
    BonusScore_Y = y + 111 + CAST(INTEGER, RND * 64)
    
    ' set velocity
    'BonusScoreAnimation(firstAvailable, BONUS_SCORE_DX) = (0 - dx) + CAST(INTEGER, RND * 8) - 4
    'BonusScoreAnimation(firstAvailable, BONUS_SCORE_DY) = (0 - dy) + CAST(INTEGER, RND * 8) - 4
    BonusScore_DX = dx / 4
    BonusScore_DY = dy / 4
    
    ' set correct sprite
    BonusScore_SPRITE_OFFSET = BONUS_SCORE_OFFSET + 4 - (4 * type)

    ' start animation counter
    BonusScore_COUNTER = 0
END SUB

' ==========================
' === BONUS_SCORE_Update ===
' ==========================
SUB BONUS_SCORE_Update()
    ' declare variables
    DIM PlotX AS UINTEGER = 0
    DIM PlotY AS UBYTE = 0
    DIM frame AS UBYTE = 0
    DIM offset AS UBYTE = 0

    ' have we got any particles to process?
    IF BonusScore_COUNTER < 0
        RETURN
    END IF

    IF BonusScore_COUNTER < 32
        ' show the sprite
        PlotX = CAST(UINTEGER, (BonusScore_X / 16))
        PlotY = CAST(UBYTE, (BonusScore_Y / 16))
        
        frame = CAST(UBYTE, BonusScore_SPRITE_OFFSET)
        offset = (BonusScore_COUNTER >> 1) MOD 4

        frame = frame + offset

        UpdateSprite(PlotX, PlotY, BONUS_SCORE_SPRITE_START + index, frame, 0, 0)

        ' update engine wash values
        BonusScore_X = BonusScore_X + BonusScore_DX
        BonusScore_Y = BonusScore_Y + BonusScore_DY
        BonusScore_COUNTER = BonusScore_COUNTER + 1
    ELSE IF BonusScore_COUNTER >= 32
        ' remove the sprite
        RemoveSprite(BONUS_SCORE_SPRITE_START + index, 0)
        BonusScore_COUNTER = -1
    END IF
END SUB

#endif