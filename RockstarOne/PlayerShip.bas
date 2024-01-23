' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>
#INCLUDE "./Sprites.bas"
#INCLUDE "./Bullets.bas"
#INCLUDE "./Rocks.bas"

' =================
' === Constants ===
' =================
CONST SHIP_BOX AS UBYTE      = 6
CONST SHIP_SPRITE_OFFSET AS UBYTE = 9
CONST SHIP_LIT_OFFSET AS UBYTE = 16
CONST SHIP_MAX_SPEED_MULTIPLIER AS UBYTE = 3
CONST SHIP_MAX_SPEED_LIMIT AS BYTE = 127
CONST SHIP_ANIMATION_FRAME AS UBYTE = 0
CONST SHIP_ANIMATION_SPRITE_FLAGS AS UBYTE = 1
CONST SHIP_ANIMATION_DX AS UBYTE = 2
CONST SHIP_ANIMATION_DY AS UBYTE = 3

CONST SHIP_ENGINE_WASH_OFFSET AS UBYTE = 50
CONST SHIP_ENGINE_WASH_SPRITE_START AS UBYTE = 1
CONST SHIP_ENGINE_WASH_X AS UBYTE = 0
CONST SHIP_ENGINE_WASH_Y AS UBYTE = 1
CONST SHIP_ENGINE_WASH_DX AS UBYTE = 2
CONST SHIP_ENGINE_WASH_DY AS UBYTE = 3
CONST SHIP_ENGINE_WASH_COUNTER AS UBYTE = 4
CONST SHIP_ENGINE_WASH_MAX_PARTICLES AS UBYTE = 8

' ========================
' === Global Variables ===
' ========================
DIM Ship_X AS INTEGER = 164 * 16
DIM Ship_Y AS INTEGER = 116 * 16
DIM ShipPlot_X AS UINTEGER
DIM ShipPlot_Y AS UBYTE
DIM Ship_DX AS INTEGER = 0
DIM Ship_DY AS INTEGER = 0
DIM Ship_Lit AS UBYTE = 0
DIM Ship_CurrentFrame AS BYTE = 0
DIM ShipAnimation(24, 4) AS INTEGER
DIM EngineWashAnimation(SHIP_ENGINE_WASH_MAX_PARTICLES, 5) AS INTEGER
DIM EngineWashCount AS BYTE = 0

' =================
' === Functions ===
' =================

' ==================
' === Initialise ===
' ==================
SUB SHIP_Initialise()
    SHIP_InitialiseShip()
    SHIP_InitialiseEngineWash()
    BULLET_InitialiseBullets()
    ROCK_InitialiseRocks(3)
END SUB

' ===========================
' === SHIP_InitialiseShip ===
' ===========================
SUB SHIP_InitialiseShip()
    ' declare variables
    DIM counter AS UBYTE
    DIM index AS UBYTE
    DIM spFlags AS UBYTE
    DIM dx as INTEGER
    DIM dy AS INTEGER
    DIM angle AS FIXED

    ' initialise ship position and animation frame
    Ship_X = 152 * 16
    Ship_Y = 116 * 16
    Ship_CurrentFrame = 0

    ' iterate over each of the 24 animation frames for the ship, create data for each frame, and store in the ShipAnimation array
    '  0: Index of frame in the sprite data
    '  1: Rotate/XMirror/YMirror flags for displaying the sprite frame
    '  2: Pre-calculated thruster velocity x component based on the the direction the ship is pointing
    '  3: Pre-calculated thruster velocity y component based on the the direction the ship is pointing
    FOR index = 0 TO 23
        ' set sprite frame and rotate/mirror flags
        ' are we in the second quadrant?
        IF index > 5 AND index < 12
            spFlags = sprRotate
            counter = index - 6
        ' are we in the third quadrant?
        ELSE IF index > 11 AND index < 18
            IF index = 12
                spFlags = sprYmirror
                counter = index - 12
            ELSE IF index > 12
                spFlags = sprRotate BOR sprXmirror
                counter = (18 - index)
            END IF
        ' are we in the fourth quadrant?
        ELSE IF index > 17
            IF index = 18
                spFlags = sprRotate BOR sprXmirror
                counter = index - 18
            ELSE IF index > 18
                spFlags = sprXmirror 
                counter =  (24 - index)
            END IF
        ' we must be in the first quadrant
        ELSE
            counter = index
            spFlags = 0
        END IF

        ' get the angle in radians
        angle = ((CAST(FIXED, index) * 15)) * PI / 180

        ' compute the dx & dy components for the thruster velocity to apply for this direction
        dx = CAST(INTEGER, SIN(angle)*15) * 1
        dy = CAST(INTEGER, COS(angle)*15) * -1

        ' set ship animation values in the ShipAnimation array
        ShipAnimation(index, SHIP_ANIMATION_FRAME) = counter
        ShipAnimation(index, SHIP_ANIMATION_SPRITE_FLAGS) = spFlags
        ShipAnimation(index, SHIP_ANIMATION_DX) = dx
        ShipAnimation(index, SHIP_ANIMATION_DY) = dy  
    NEXT index
END SUB

' =================================
' === SHIP_InitialiseEngineWash ===
' =================================
SUB SHIP_InitialiseEngineWash()
    ' declare variables
    DIM index AS UBYTE    
    
    ' initialise engine wash count
    EngineWashCount = 0

    ' iterate over engine wash particle array
    FOR index = 0 TO (SHIP_ENGINE_WASH_MAX_PARTICLES - 1)
        ' init the animation counter to -1 (which will mean particle is not live)
        EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) = -1
    NEXT index
END SUB

' ============================
' === SHIP_StartEngineWash ===
' ============================
SUB SHIP_StartEngineWash()
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0

    ' have we already got the max number of particles?
    IF EngineWashCount >= SHIP_ENGINE_WASH_MAX_PARTICLES
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (SHIP_ENGINE_WASH_MAX_PARTICLES - 1)
        IF EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) = -1
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < SHIP_ENGINE_WASH_MAX_PARTICLES
        EngineWashAnimation(firstAvailable, SHIP_ENGINE_WASH_X) = Ship_X + 111 + CAST(INTEGER, RND * 64)
        EngineWashAnimation(firstAvailable, SHIP_ENGINE_WASH_Y) = Ship_Y + 111 + CAST(INTEGER, RND * 64)
        EngineWashAnimation(firstAvailable, SHIP_ENGINE_WASH_DX) = (0 - ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DX)) + CAST(INTEGER, RND * 8) - 4
        EngineWashAnimation(firstAvailable, SHIP_ENGINE_WASH_DY) = (0 - ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DY)) + CAST(INTEGER, RND * 8) - 4
        EngineWashAnimation(firstAvailable, SHIP_ENGINE_WASH_COUNTER) = 0
        EngineWashCount = EngineWashCount + 1
    END IF
END SUB

' =============================
' === SHIP_UpdateEngineWash ===
' =============================
SUB SHIP_UpdateEngineWash()
    ' declare variables
    DIM index AS UBYTE = 0
    DIM PlotX AS UINTEGER
    DIM PlotY AS UBYTE
    DIM frame AS UBYTE

    ' have we got any particles to process?
    IF EngineWashCount = 0
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (SHIP_ENGINE_WASH_MAX_PARTICLES - 1)
        IF EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) > -1 AND EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) < 8
            ' show the sprite
            PlotX = CAST(UINTEGER, (EngineWashAnimation(index, SHIP_ENGINE_WASH_X) >> 4))
            PlotY = CAST(UBYTE, (EngineWashAnimation(index, SHIP_ENGINE_WASH_Y) >> 4))
            UpdateSprite(PlotX, PlotY, SHIP_ENGINE_WASH_SPRITE_START + index, SHIP_ENGINE_WASH_OFFSET + (EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) MOD 4), 0, 0)

            ' update engine wash values
            EngineWashAnimation(index, SHIP_ENGINE_WASH_X) = EngineWashAnimation(index, SHIP_ENGINE_WASH_X) + EngineWashAnimation(index, SHIP_ENGINE_WASH_DX)
            EngineWashAnimation(index, SHIP_ENGINE_WASH_Y) = EngineWashAnimation(index, SHIP_ENGINE_WASH_Y) + EngineWashAnimation(index, SHIP_ENGINE_WASH_DY)
            EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) = EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) + 1
        ELSE IF EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) >= 8
            ' remove the sprite
            RemoveSprite(SHIP_ENGINE_WASH_SPRITE_START + index, 0)
            EngineWashAnimation(index, SHIP_ENGINE_WASH_COUNTER) = -1
            EngineWashCount = EngineWashCount - 1
        END IF
    NEXT index
END SUB

' =======================
' === SHIP_RotateShip ===
' =======================
SUB SHIP_RotateShip(direction AS UBYTE)
    ' which way are we turning?
    IF direction = 0
        ' clockwise - increment ship animation frame
        Ship_CurrentFrame = Ship_CurrentFrame + 1
        
        ' check for overflow
        IF Ship_CurrentFrame > 23
            Ship_CurrentFrame = 0
        END IF
    ELSE
        ' anti-clockwise - decrement ship animation frame
        Ship_CurrentFrame = Ship_CurrentFrame - 1
        
        ' check for underflow
        IF Ship_CurrentFrame < 0
            Ship_CurrentFrame = 23
        END IF
    END IF
END SUB

' =======================
' === SHIP_ThrustShip ===
' =======================
SUB SHIP_ThrustShip(thrust AS UBYTE)  
    ' are we thrusting?'
    IF thrust = 1
        ' we are thrusting - set ship lit flag to on
        Ship_Lit = 1

        ' update ship velocity based on direction ship is pointing
        Ship_DX = Ship_DX + ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DX)
        Ship_DY = Ship_DY + ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DY)

        ' enforce maximum speed limit - dx component
        IF Ship_DX > SHIP_MAX_SPEED_LIMIT
            Ship_DX = SHIP_MAX_SPEED_LIMIT
        ELSE IF Ship_DX < 0-SHIP_MAX_SPEED_LIMIT
            Ship_DX = 0-SHIP_MAX_SPEED_LIMIT
        END IF

        ' enforce maximum speed limit - dy component
        IF Ship_DY > SHIP_MAX_SPEED_LIMIT
            Ship_DY = SHIP_MAX_SPEED_LIMIT
        ELSE IF Ship_DY < 0-SHIP_MAX_SPEED_LIMIT
            Ship_DY = 0-SHIP_MAX_SPEED_LIMIT
        END IF

        ' start engine wash
        SHIP_StartEngineWash()
    ELSE
        ' we are not thrusting - set ship lit flag to off
        Ship_Lit = 0
    END IF
END SUB

' ==========================
' === SHIP_ApplyFriction ===
' ==========================
SUB SHIP_ApplyFriction()
    ' reduce ship velocity based on current speed - dx component
    IF Ship_DX < -10
        Ship_DX = Ship_DX + 4
    ELSE IF Ship_DX >= -10 AND Ship_DX < 0
        Ship_DX = Ship_DX + 1
    ELSE IF Ship_DX <= 10 AND Ship_DX > 0
        Ship_DX = Ship_DX - 1
    ELSE IF Ship_DX > 10 
        Ship_DX = Ship_DX - 4
    ELSE IF Ship_Lit = 0
        Ship_DX = 0
    END IF

    ' reduce ship velocity based on current speed - dy component
    IF Ship_DY < -10
        Ship_DY = Ship_DY + 4
    ELSE IF Ship_DY >= -10 AND Ship_DY < 0
        Ship_DY = Ship_DY + 1
    ELSE IF Ship_DY <= 10 AND Ship_DY > 0
        Ship_DY = Ship_DY - 1
    ELSE IF Ship_DY > 10 
        Ship_DY = Ship_DY - 4
    ELSE IF Ship_Lit = 0
        Ship_DY = 0
    END IF
END SUB

' =======================
' === SHIP_UpdateShip ===
' =======================
SUB SHIP_UpdateShip()
    ' debugging info - uncomme
    'SHIP_ShowShipDebuggingInfo()
    
    ' apply friction'
    SHIP_ApplyFriction()

    ' update ship position
    Ship_X = Ship_X + Ship_DX
    Ship_Y = Ship_Y + Ship_DY

    ' check for going out of bounds - x axis
    IF Ship_X > 335 * 16
        Ship_X = -15 * 16
    ELSE IF Ship_X < -15 * 16
        Ship_X = 335 * 16
    END IF

    ' check for going out of bounds - y axis
    IF Ship_Y >= 256 * 16
        Ship_Y = 0
    ELSE IF Ship_Y < 0
        Ship_Y = (256 * 16) - 1
    END IF

    ' get screen coords for ship
    ShipPlot_X = Ship_X >> 4
    ShipPlot_Y = Ship_Y >> 4
    
    ' display engine wash
    SHIP_UpdateEngineWash()

    ' display bullets
    BULLET_UpdateBullets()

    ' display rocks
    ROCK_UpdateRocks()

    ' display the ship
    ' are the thrusters on?
    IF Ship_Lit = 0
        ' thruster off - show appropriate sprite frame
        UpdateSprite(ShipPlot_X, ShipPlot_Y, 0, ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_FRAME) + SHIP_SPRITE_OFFSET, ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_SPRITE_FLAGS), 0)
    ELSE
        ' thruster on - show appropriate sprite frame
        UpdateSprite(ShipPlot_X, ShipPlot_Y, 0, ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_FRAME) + SHIP_SPRITE_OFFSET + SHIP_LIT_OFFSET, ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_SPRITE_FLAGS), 0)
    END IF
END SUB 

' ==================================
' === SHIP_ShowShipDebuggingInfo ===
' ==================================
SUB SHIP_ShowShipDebuggingInfo()
    ' ship debugging info
    DIM message AS STRING
    'message = "SHIP_DX_MAX: " + STR(ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DX)) + "   "
    'FL2Text(1,1,message,40)
    'message = "SHIP_DY_MAX: " + STR(ShipAnimation(Ship_CurrentFrame, SHIP_ANIMATION_DY)) + "   "
    'FL2Text(1,2,message,40)
    'message = "SHIP_X: " + STR(Ship_X) + "   "
    'FL2Text(1,3,message,40)
    'message = "SHIP_Y: " + STR(Ship_Y) + "   "
    'FL2Text(1,4,message,40)
    'message = "SHIP_DX: " + STR(Ship_DX) + "   "
    'FL2Text(1,5,message,40)
    'message = "SHIP_DY: " + STR(Ship_DY) + "   "
    'FL2Text(1,6,message,40)

    message = "ROCK COUNT: " + STR(RockCount) + "   "
    FL2Text(1,1,message,40)
END SUB