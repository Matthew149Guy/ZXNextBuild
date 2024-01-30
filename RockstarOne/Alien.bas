#ifndef __ALIEN__
#define __ALIEN__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>
#INCLUDE "./Sprites.bas"

' =================
' === Constants ===
' =================
CONST ALIEN_SPRITE_INDEX AS UBYTE = 96
CONST ALIEN_SPRITE_OFFSET AS UBYTE = 15
CONST ALIEN_ANIMATION_FRAME AS UBYTE = 0
CONST ALIEN_ANIMATION_SPRITE_FLAGS AS UBYTE = 1
CONST ALIEN_ANIMATION_SIZE_SMALL AS UBYTE = 0
CONST ALIEN_ANIMATION_SIZE_LARGE AS UBYTE = sprX2 BOR sprY2
CONST ALIEN_SIZE_SMALL AS UBYTE = 0
CONST ALIEN_SIZE_LARGE AS UBYTE = 1
CONST ALIEN_STATUS_SLEEP AS UBYTE = 0
CONST ALIEN_STATUS_LIVE AS UBYTE = 1
CONST ALIEN_STATUS_OFFSCREEN AS UBYTE = 2
CONST ALIEN_STATUS_KILLED AS UBYTE = 3
CONST ALIEN_MIN_Y AS INTEGER = 32 * 16
CONST ALIEN_MAX_Y AS INTEGER = 224 * 16
CONST ALIEN_OPTIONS_X AS UBYTE = 0
CONST ALIEN_OPTIONS_DX AS UBYTE = 1
CONST ALIEN_OPTIONS_DY AS UBYTE = 2

' ========================
' === Global Variables ===
' ========================
DIM Alien_X AS INTEGER = 164 * 16
DIM Alien_Y AS INTEGER = 116 * 16
DIM AlienPlot_X AS UINTEGER
DIM AlienPlot_Y AS UBYTE
DIM Alien_DX AS INTEGER = 0
DIM Alien_DY AS INTEGER = 0
DIM Alien_CurrentFrame AS BYTE = 0
DIM Alien_Size AS UBYTE = ALIEN_SIZE_SMALL
DIM Alien_Status AS UBYTE = ALIEN_STATUS_SLEEP
DIM AlienAnimation(4, 2) AS INTEGER
DIM AlienStartOptions(12, 3) AS INTEGER
DIM AlienSleepCounter AS INTEGER = 0
DIM AlienSleepTime AS UINTEGER = 600

' =================
' === Functions ===
' =================

' =======================
' === ALIEN_Initialise ===
' =======================
SUB ALIEN_Initialise()
    ALIEN_InitialiseAlien()
END SUB

SUB ALIEN_InitialiseAlien()
    ' set up alien animation data
    AlienAnimation(0, ALIEN_ANIMATION_FRAME) = ALIEN_SPRITE_OFFSET + 0
    AlienAnimation(0, ALIEN_ANIMATION_SPRITE_FLAGS) = 0

    AlienAnimation(1, ALIEN_ANIMATION_FRAME) = ALIEN_SPRITE_OFFSET + 16
    AlienAnimation(1, ALIEN_ANIMATION_SPRITE_FLAGS) = 0

    AlienAnimation(2, ALIEN_ANIMATION_FRAME) = ALIEN_SPRITE_OFFSET + 32
    AlienAnimation(2, ALIEN_ANIMATION_SPRITE_FLAGS) = 0

    AlienAnimation(3, ALIEN_ANIMATION_FRAME) = ALIEN_SPRITE_OFFSET + 16
    AlienAnimation(3, ALIEN_ANIMATION_SPRITE_FLAGS) = sprXmirror

    ' set up alien start up options - left/right, dx, dy
    ALIEN_InitialiseStartUpOption(0, 0, 30)
    ALIEN_InitialiseStartUpOption(1, 0, 45)
    ALIEN_InitialiseStartUpOption(2, 0, 60)

    ALIEN_InitialiseStartUpOption(3, 0, 120)
    ALIEN_InitialiseStartUpOption(4, 0, 135)
    ALIEN_InitialiseStartUpOption(5, 0, 150)

    ALIEN_InitialiseStartUpOption(6, 320*16, 210)
    ALIEN_InitialiseStartUpOption(7, 320*16, 225)
    ALIEN_InitialiseStartUpOption(8, 320*16, 240)

    ALIEN_InitialiseStartUpOption(9, 320*16, 300)
    ALIEN_InitialiseStartUpOption(10, 320*16, 315)
    ALIEN_InitialiseStartUpOption(11, 320*16, 330)

    AlienSleepCounter = 0
    AlienSleepTime = CAST(INTEGER, (RND * 300) + 300)
END SUB

SUB ALIEN_Sleep()
    Alien_Status = ALIEN_STATUS_SLEEP
    AlienSleepCounter = 0
    AlienSleepTime = CAST(INTEGER, (RND * 300) + 300)
END SUB

FUNCTION ALIEN_CanStart() AS UBYTE
    IF AlienSleepCounter > AlienSleepTime
        IF ((RND * 2) + 0.5) >= 1
            RETURN 1
        ELSE
            RETURN 1
            ' AlienSleepCounter = 0
        END IF
    ELSE
        RETURN 0
    END IF
END FUNCTION

SUB ALIEN_InitialiseStartUpOption(index AS UBYTE, x AS INTEGER, angle AS FIXED)
    DIM dx as INTEGER
    DIM dy AS INTEGER
    DIM radians AS FIXED

    ' get the angle in radians
    radians = angle * PI / 180

    ' compute the dx & dy components for the thruster velocity to apply for this direction
    dx = CAST(INTEGER, (SIN(radians)*16) + 0.5) * 1
    dy = CAST(INTEGER, (COS(radians)*16) + 0.5) * -1

    ' store the values
    AlienStartOptions(index, ALIEN_OPTIONS_X) = x
    AlienStartOptions(index, ALIEN_OPTIONS_DX) = dx
    AlienStartOptions(index, ALIEN_OPTIONS_DY) = dy

END SUB

SUB ALIEN_StartAlien()
    DIM startIndex AS UBYTE

    ' is the alien sleeping?
    IF Alien_Status <> ALIEN_STATUS_SLEEP
        ' no sleeping - exit
        RETURN
    END IF

    ' get y value at random
    Alien_Y = CAST(INTEGER, ((RND * (ALIEN_MAX_Y - ALIEN_MIN_Y)) + 0.5)) + ALIEN_MIN_Y

    ' get alien size at random
    Alien_Size = CAST(UBYTE, (RND * 1) + 0.5)

    ' pick a start index
    startIndex = CAST(UBYTE, (RND * 12) + 0.5)

    ' get the values
    Alien_X = AlienStartOptions(startIndex, ALIEN_OPTIONS_X)
    Alien_DX = AlienStartOptions(startIndex, ALIEN_OPTIONS_DX) * (3 - Alien_Size)
    Alien_DY = AlienStartOptions(startIndex, ALIEN_OPTIONS_DY) * (3 - Alien_Size)

    ' are we staring on the left?
    IF Alien_X = 0
        ' we need to move the alien back off screen according to it's size
        IF Alien_Size = ALIEN_SIZE_LARGE
            Alien_X = Alien_X - (32 * 16)
        ELSE IF Alien_Size = ALIEN_SIZE_SMALL
            Alien_X = Alien_X - (16 * 16)
        END IF
    END IF

    ' iniitialise frame counter
    Alien_CurrentFrame = -1

    ' set status
    Alien_Status = ALIEN_STATUS_LIVE

END SUB

SUB ALIEN_UpdateAlien()
    DIM sizeFlags AS UBYTE = ALIEN_ANIMATION_SIZE_SMALL

    ALIEN_ShowDebuggingInfo()
    ' is the alien asleep?
    IF Alien_Status = ALIEN_STATUS_SLEEP
        ' check if we can start the alien yet
        IF ALIEN_CanStart() = 1
            ' start the alien sequence
            ALIEN_StartAlien()
        ELSE
            ' incerement the sleep counter
            AlienSleepCounter = AlienSleepCounter + 1
        END IF

        ' exit
        RETURN
    END IF
    
    ' is the alien live?
    IF Alien_Status <> ALIEN_STATUS_LIVE
        ' nope, nothing else to do, exit
        RETURN
    END IF

    ' update x,y & frame
    Alien_X = Alien_X + Alien_DX
    Alien_Y = Alien_Y + Alien_DY
    Alien_CurrentFrame = Alien_CurrentFrame + 1

    ' check frame has not gone bigger than 8
    IF Alien_CurrentFrame >= 8
        Alien_CurrentFrame = 0
    END IF

    ' check y bounds and reverse y direction if exceeded
    IF Alien_Y < ALIEN_MIN_Y
        Alien_Y = ALIEN_MIN_Y
        Alien_DY = (0 - Alien_DY)
    ELSE IF Alien_Y > ALIEN_MAX_Y
        Alien_Y = ALIEN_MAX_Y
        Alien_DY = (0 - Alien_DY)
    END IF

    ' check x bounds and kill the alien if exceeded
    IF Alien_X >= 320 * 16 OR Alien_X <= -512
        RemoveSprite(ALIEN_SPRITE_INDEX,0)
        ALIEN_Sleep()
    END IF

    ' get screen coords
    AlienPlot_X = CAST(UINTEGER, (Alien_X / 16))
    AlienPlot_Y = CAST(UBYTE, (Alien_Y / 16))

    ' get size flags
    IF Alien_Size = ALIEN_SIZE_LARGE
        sizeFlags = ALIEN_ANIMATION_SIZE_LARGE
    END IF

    ' show the alien
    UpdateSprite(_
         AlienPlot_X, _
         AlienPlot_Y, _
         ALIEN_SPRITE_INDEX, _
         AlienAnimation(Alien_CurrentFrame/2, ALIEN_ANIMATION_FRAME), _
         AlienAnimation(Alien_CurrentFrame/2, ALIEN_ANIMATION_SPRITE_FLAGS), _
         sizeFlags)

    
END SUB

SUB ALIEN_ShowDebuggingInfo()
    ' ship debugging info
    DIM message AS STRING
    message = "ALIEN X: " + STR(Alien_X) + "   "
    FL2Text(1,1,message,40)
    message = "ALIEN Y: " + STR(Alien_Y) + "   "
    FL2Text(1,2,message,40)
    message = "STATUS: " + STR(Alien_Status) + "   "
    FL2Text(1,3,message,40)
    message = "COUNTDOWN: " + STR(AlienSleepTime - AlienSleepCounter) + "   "
    FL2Text(1,4,message,40)
    'message = "SHIP_DX: " + STR(Ship_DX) + "   "
    'FL2Text(1,5,message,40)
    'message = "SHIP_DY: " + STR(Ship_DY) + "   "
    'FL2Text(1,6,message,40)
END SUB

#endif