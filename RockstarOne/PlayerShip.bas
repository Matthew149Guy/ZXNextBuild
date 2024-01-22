' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST sprX2 AS UBYTE  =%01000                 ' constants for attrib 4 of base sprite 
CONST sprX4 AS UBYTE         =%10000  
CONST sprX8 AS UBYTE         =%11000
CONST sprY2 AS UBYTE         =%00010
CONST sprY4 AS UBYTE         =%00100
CONST sprY8 AS UBYTE         =%00110
CONST sprXmirror AS UBYTE    = %1000					' thare constants required for sprite mirror + flipping 
CONST sprYmirror AS UBYTE    = %0100
CONST sprRotate AS UBYTE     = %0010

CONST SHIP_BOX AS UBYTE      = 6
CONST SHIP_SPRITE_OFFSET AS UBYTE = 9
CONST SHIP_LIT_OFFSET AS UBYTE = 16
CONST SHIP_MAX_SPEED_MULTIPLIER AS UBYTE = 3

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
SUB SHIP_InitialiseShip()
    DIM counter AS UBYTE
    DIM index AS UBYTE
    DIM frame AS UBYTE
    DIM spFlags AS UBYTE
    DIM dx as INTEGER
    DIM dy AS INTEGER
    DIM angle AS FIXED
    DIM dxSign AS BYTE = 1
    DIM dySign AS BYTE = -1
    Ship_X = 152 * 16
    Ship_Y = 116 * 16
    Ship_CurrentFrame = 0

    FOR index = 0 TO 23
        IF index > 5 AND index < 12
            IF index = 6
                frame = 6
            ELSE
                frame = index - 6
            END IF
            spFlags = sprRotate
            counter = index - 6
            dxSign = 1
            dySign = 1
        ELSE IF index > 11 AND index < 18
            IF index = 12
                frame = 6
                spFlags = sprYmirror
                counter = index - 12
            ELSE IF index > 12
                spFlags = sprRotate BOR sprXmirror
                counter = (18 - index)
                frame = counter MOD 6
            END IF
            dxSign = -1
            dySign = 1
        ELSE IF index > 17
            IF index = 18
                frame = 0
                spFlags = sprRotate BOR sprXmirror
                counter = index - 18
            ELSE IF index > 18
                spFlags = sprXmirror 
                counter =  (24 - index)
                frame = counter MOD 6
            END IF
            dxSign = -1
            dySign = -1
        ELSE
            counter = index
            frame = index
            spFlags = 0
            dxSign = 1
            dySign = -1
        END IF

        angle = ((CAST(FIXED, index) * 15)) * PI / 180

        dx = CAST(INTEGER, SIN(angle)*15) * 1
        dy = CAST(INTEGER, COS(angle)*15) * -1

        ShipAnimation(index, 0) = counter
        ShipAnimation(index, 1) = spFlags
        ShipAnimation(index, 2) = dx
        ShipAnimation(index, 3) = dy  
    NEXT index
END SUB

SUB SHIP_RotateShip(direction AS UBYTE)
    IF direction = 0
        Ship_CurrentFrame = Ship_CurrentFrame + 1
        IF Ship_CurrentFrame > 23
            Ship_CurrentFrame = 0
        END IF
    ELSE
        Ship_CurrentFrame = Ship_CurrentFrame - 1
        IF Ship_CurrentFrame < 0
            Ship_CurrentFrame = 23
        END IF
    END IF
END SUB

SUB SHIP_ThrustShip(thrust AS UBYTE)

    IF thrust = 1
        Ship_Lit = 1

        Ship_DX = Ship_DX + ShipAnimation(Ship_CurrentFrame, 2)
        Ship_DY = Ship_DY + ShipAnimation(Ship_CurrentFrame, 3)

        'IF Ship_DX >= 0
        ''    IF Ship_DX > ShipAnimation(Ship_CurrentFrame, 2) * 4
        ''        Ship_DX = ShipAnimation(Ship_CurrentFrame, 2) * 4
        ''    END IF
        'ELSE
        ''    IF Ship_DX < ShipAnimation(Ship_CurrentFrame, 2) * 4
        ''        Ship_DX = ShipAnimation(Ship_CurrentFrame, 2) * 4
        ''    END IF
       '' END IF
        
       '' IF Ship_DY >= 0
        ''    IF Ship_DY > ShipAnimation(Ship_CurrentFrame, 3) * 4
        ''        Ship_DY = ShipAnimation(Ship_CurrentFrame, 3) * 4
        ''    END IF
        'ELSE
        ''    IF Ship_DY < ShipAnimation(Ship_CurrentFrame, 3) * 4
        ''        Ship_DY = ShipAnimation(Ship_CurrentFrame, 3) * 4
        ''    END IF
        'END IF

        IF Ship_DX > 127
            Ship_DX = 127
        ELSE IF Ship_DX < -127
            Ship_DX = -127
        END IF

        IF Ship_DY > 127
            Ship_DY = 127
        ELSE IF Ship_DY < -127
            Ship_DY = -127
        END IF
    ELSE
        Ship_Lit = 0
    END IF

    message = "SHIP_DX: " + STR(Ship_DX) + "   "
    FL2Text(1,5,message,40)
    message = "SHIP_DY: " + STR(Ship_DY) + "   "
    FL2Text(1,6,message,40)
END SUB

SUB SHIP_ApplyFriction()

    'IF ShipAnimation(Ship_CurrentFrame, 2) / 4 >= 0
    ''    IF ShipAnimation(Ship_CurrentFrame, 2) / 4 > Ship_DX
    ''        Ship_DX = 0
    ''    ELSE 
    ''        Ship_DX = Ship_DX - ShipAnimation(Ship_CurrentFrame, 2) / 4 
    ''    END IF
    'ELSE
    ''   IF ShipAnimation(Ship_CurrentFrame, 2) / 4  < Ship_DX
    ''        Ship_DX = 0
    ''    ELSE
    ''        Ship_DX = Ship_DX - ShipAnimation(Ship_CurrentFrame, 2) / 4 
    ''    END IF
    'END IF

    'IF ShipAnimation(Ship_CurrentFrame, 3) / 4  >= 0
    ''    IF ShipAnimation(Ship_CurrentFrame, 3) / 4  > Ship_DY
    ''        Ship_DY = 0
    ''    ELSE 
    ''        Ship_DY = Ship_DY - ShipAnimation(Ship_CurrentFrame, 3) / 4 
    ''    END IF
    'ELSE
    ''    IF ShipAnimation(Ship_CurrentFrame, 3) < Ship_DY
    ''        Ship_DY = 0
    ''    ELSE
    ''        Ship_DY = Ship_DY - ShipAnimation(Ship_CurrentFrame, 3) / 4 
    ''    END IF
    'END IF

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

SUB SHIP_UpdateShip()

    message = "SHIP_DX_MAX: " + STR(ShipAnimation(Ship_CurrentFrame, 2)) + "   "
    FL2Text(1,1,message,40)
    message = "SHIP_DY_MAX: " + STR(ShipAnimation(Ship_CurrentFrame, 3)) + "   "
    FL2Text(1,2,message,40)
    
    
    
    SHIP_ApplyFriction()

    Ship_X = Ship_X + Ship_DX
    Ship_Y = Ship_Y + Ship_DY

    IF Ship_X > 335 * 16
        Ship_X = -15 * 16
    ELSE IF Ship_X < -15 * 16
        Ship_X = 335 * 16
    END IF

    IF Ship_Y > 273 * 16
        Ship_Y = -15 * 16
    ELSE IF Ship_Y < -15 * 16
        Ship_Y = 273 * 16
    END IF

    ShipPlot_X = Ship_X >> 4
    ShipPlot_Y = Ship_Y >> 4

    message = "SHIP_X: " + STR(Ship_X) + "   "
    FL2Text(1,3,message,40)
    message = "SHIP_Y: " + STR(Ship_Y) + "   "
    FL2Text(1,4,message,40)

    IF Ship_Lit = 0
        UpdateSprite(ShipPlot_X, ShipPlot_Y, 0, ShipAnimation(Ship_CurrentFrame, 0) + SHIP_SPRITE_OFFSET, ShipAnimation(Ship_CurrentFrame, 1), 0)
    ELSE
        UpdateSprite(ShipPlot_X, ShipPlot_Y, 0, ShipAnimation(Ship_CurrentFrame, 0) + SHIP_SPRITE_OFFSET + SHIP_LIT_OFFSET, ShipAnimation(Ship_CurrentFrame, 1), 0)
    END IF
END SUB 