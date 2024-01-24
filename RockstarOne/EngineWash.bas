' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST ENGINE_WASH_OFFSET AS UBYTE = 50
CONST ENGINE_WASH_SPRITE_START AS UBYTE = 1
CONST ENGINE_WASH_X AS UBYTE = 0
CONST ENGINE_WASH_Y AS UBYTE = 1
CONST ENGINE_WASH_DX AS UBYTE = 2
CONST ENGINE_WASH_DY AS UBYTE = 3
CONST ENGINE_WASH_COUNTER AS UBYTE = 4
CONST ENGINE_WASH_MAX_PARTICLES AS UBYTE = 8

' ========================
' === Global Variables ===
' ========================
DIM EngineWashAnimation(ENGINE_WASH_MAX_PARTICLES, 5) AS INTEGER
DIM EngineWashCount AS BYTE = 0

' =================
' === Functions ===
' =================

' =================================
' === SHIP_InitialiseEngineWash ===
' =================================
SUB ENGINE_WASH_Initialise()
    ' declare variables
    DIM index AS UBYTE    
    
    ' initialise engine wash count
    EngineWashCount = 0

    ' iterate over engine wash particle array
    FOR index = 0 TO (ENGINE_WASH_MAX_PARTICLES - 1)
        ' init the animation counter to -1 (which will mean particle is not live)
        EngineWashAnimation(index, ENGINE_WASH_COUNTER) = -1
    NEXT index
END SUB

' ============================
' === SHIP_StartEngineWash ===
' ============================
SUB ENGINE_WASH_Start(x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER)
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0

    ' have we already got the max number of particles?
    IF EngineWashCount >= ENGINE_WASH_MAX_PARTICLES
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (ENGINE_WASH_MAX_PARTICLES - 1)
        ' is this a "dead" particle we can re-use?
        IF EngineWashAnimation(index, ENGINE_WASH_COUNTER) = -1
            ' yes, grab the index and break out of the for loop
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < ENGINE_WASH_MAX_PARTICLES
        ' set x/y coords
        EngineWashAnimation(firstAvailable, ENGINE_WASH_X) = x + 111 + CAST(INTEGER, RND * 64)
        EngineWashAnimation(firstAvailable, ENGINE_WASH_Y) = y + 111 + CAST(INTEGER, RND * 64)
        
        ' set velocity
        EngineWashAnimation(firstAvailable, ENGINE_WASH_DX) = (0 - dx) + CAST(INTEGER, RND * 8) - 4
        EngineWashAnimation(firstAvailable, ENGINE_WASH_DY) = (0 - dy) + CAST(INTEGER, RND * 8) - 4
        
        ' start animation counter
        EngineWashAnimation(firstAvailable, ENGINE_WASH_COUNTER) = 0

        ' increment engine wash count
        EngineWashCount = EngineWashCount + 1
    END IF
END SUB

' =============================
' === SHIP_UpdateEngineWash ===
' =============================
SUB ENGINE_WASH_Update()
    ' declare variables
    DIM index AS UBYTE = 0
    DIM PlotX AS UINTEGER
    DIM PlotY AS UBYTE

    ' have we got any particles to process?
    IF EngineWashCount = 0
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (ENGINE_WASH_MAX_PARTICLES - 1)
        IF EngineWashAnimation(index, ENGINE_WASH_COUNTER) > -1 AND EngineWashAnimation(index, ENGINE_WASH_COUNTER) < 8
            ' show the sprite
            PlotX = CAST(UINTEGER, (EngineWashAnimation(index, ENGINE_WASH_X) >> 4))
            PlotY = CAST(UBYTE, (EngineWashAnimation(index, ENGINE_WASH_Y) >> 4))
            UpdateSprite(PlotX, PlotY, ENGINE_WASH_SPRITE_START + index, ENGINE_WASH_OFFSET + (EngineWashAnimation(index, ENGINE_WASH_COUNTER) MOD 4), 0, 0)

            ' update engine wash values
            EngineWashAnimation(index, ENGINE_WASH_X) = EngineWashAnimation(index, ENGINE_WASH_X) + EngineWashAnimation(index, ENGINE_WASH_DX)
            EngineWashAnimation(index, ENGINE_WASH_Y) = EngineWashAnimation(index, ENGINE_WASH_Y) + EngineWashAnimation(index, ENGINE_WASH_DY)
            EngineWashAnimation(index, ENGINE_WASH_COUNTER) = EngineWashAnimation(index, ENGINE_WASH_COUNTER) + 1
        ELSE IF EngineWashAnimation(index, ENGINE_WASH_COUNTER) >= 8
            ' remove the sprite
            RemoveSprite(ENGINE_WASH_SPRITE_START + index, 0)
            EngineWashAnimation(index, ENGINE_WASH_COUNTER) = -1
            EngineWashCount = EngineWashCount - 1
        END IF
    NEXT index
END SUB