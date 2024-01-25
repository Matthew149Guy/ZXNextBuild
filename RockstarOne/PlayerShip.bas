#ifndef __PLAYERSHIP__
#define __PLAYERSHIP__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>
#include "./Trig.bas"
#INCLUDE "./Sprites.bas"
#INCLUDE "./Bullets.bas"
#INCLUDE "./EngineWash.bas"

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

' =================
' === Functions ===
' =================

' ==================
' === Initialise ===
' ==================
SUB SHIP_Initialise()
    SHIP_InitialiseShip()
    ENGINE_WASH_Initialise()
    BULLET_InitialiseBullets()
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
        ENGINE_WASH_Start(Ship_X, Ship_Y, Ship_DX, Ship_DY)
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
    ENGINE_WASH_Update()

    ' display bullets
    BULLET_UpdateBullets()

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
END SUB

#endif