#ifndef __ALIENBULLET__
#define __ALIENBULLET__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST ALIEN_BULLET_OFFSET AS UBYTE = 50
CONST ALIEN_BULLET_SPRITE_START AS BYTE = 104
CONST ALIEN_BULLET_X AS UBYTE = 0
CONST ALIEN_BULLET_Y AS UBYTE = 1
CONST ALIEN_BULLET_DX AS UBYTE = 2
CONST ALIEN_BULLET_DY AS UBYTE = 3
CONST ALIEN_BULLET_COUNTER AS UBYTE = 4
CONST ALIEN_BULLET_MAX_PARTICLES AS UBYTE = 2
CONST ALIEN_BULLET_LIFETIME AS UBYTE = 12

' ========================
' === Global Variables ===
' ========================
DIM AlienBulletAnimation(ALIEN_BULLET_MAX_PARTICLES, 5) AS INTEGER
DIM AlienBulletCount AS BYTE = 0

' =================
' === Functions ===
' =================

' ==============================
' === ALIEN_BULLET_Initialise ===
' ==============================
SUB ALIEN_BULLET_Initialise()
    ' declare variables
    DIM index AS UBYTE 
    
    ' initialise alien bullet count
    AlienBulletCount = 0

    ' iterate over alien bullet array
    FOR index = 0 TO (ALIEN_BULLET_MAX_PARTICLES - 1)
        ' init the animation counter to -1 (which will mean particle is not live)
        AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) = -1
    NEXT index
END SUB

' ==========================
' === ALIEN_BULLET_Start ===
' ==========================
SUB ALIEN_BULLET_Start(x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER)
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0

    ' have we already got the max number of particles?
    IF AlienBulletCount >= ALIEN_BULLET_MAX_PARTICLES
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (ALIEN_BULLET_MAX_PARTICLES - 1)
        ' is this a "dead" particle we can re-use?
        IF AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) = -1
            ' yes, grab the index and break out of the for loop
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < ALIEN_BULLET_MAX_PARTICLES
        ' set x/y coords
        AlienBulletAnimation(firstAvailable, ALIEN_BULLET_X) = x
        AlienBulletAnimation(firstAvailable, ALIEN_BULLET_Y) = y
        
        ' set velocity
        AlienBulletAnimation(firstAvailable, ALIEN_BULLET_DX) = dx
        AlienBulletAnimation(firstAvailable, ALIEN_BULLET_DY) = dy

        ' start animation counter
        AlienBulletAnimation(firstAvailable, ALIEN_BULLET_COUNTER) = 0

        ' increment alien bullet count
        AlienBulletCount = AlienBulletCount + 1

        ' play alien bulet sound
        PlaySFX(39)
    END IF
END SUB

' ===========================
' === ALIEN_BULLET_Update ===
' ===========================
SUB ALIEN_BULLET_Update()
    ' declare variables
    DIM index AS UBYTE = 0
    DIM PlotX AS UINTEGER
    DIM PlotY AS UBYTE

    ' have we got any bullets to process?
    IF AlienBulletCount = 0
        RETURN
    END IF

    'message = "COUNT: " + STR(AlienBulletCount) + "         "
    'FL2Text(0,2,message,40)

    ' iterate over bullets array
    FOR index = 0 TO (ALIEN_BULLET_MAX_PARTICLES - 1)
        IF AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) > -1 AND AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) < ALIEN_BULLET_LIFETIME
            ' show the sprite
            PlotX = CAST(UINTEGER, (AlienBulletAnimation(index, ALIEN_BULLET_X) >> 4))
            PlotY = CAST(UBYTE, (AlienBulletAnimation(index, ALIEN_BULLET_Y) >> 4))

            'message = "PLOTX: " + STR(PlotX) + "         "
            'FL2Text(0,3,message,40)

            'message = "PLOTY: " + STR(PlotY) + "         "
            'FL2Text(0,4,message,40)

            UpdateSprite(PlotX, PlotY, ALIEN_BULLET_SPRITE_START + index, ALIEN_BULLET_OFFSET + (BulletAnimation(index, ALIEN_BULLET_COUNTER) MOD 3), 0, 0)

            ' update bullet values
            AlienBulletAnimation(index, ALIEN_BULLET_X) = AlienBulletAnimation(index, ALIEN_BULLET_X) + AlienBulletAnimation(index, ALIEN_BULLET_DX)
            AlienBulletAnimation(index, ALIEN_BULLET_Y) = AlienBulletAnimation(index, ALIEN_BULLET_Y) + AlienBulletAnimation(index, ALIEN_BULLET_DY)

            ' check for going out of bounds - x axis
            IF AlienBulletAnimation(index, ALIEN_BULLET_X) > 335 * 16
                ' kill the bullet
                ALIEN_BULLET_KillBullet(index)
            ELSE IF AlienBulletAnimation(index, ALIEN_BULLET_X) < -15 * 16
                ' kill the bullet
                ALIEN_BULLET_KillBullet(index)
            END IF

            ' check for going out of bounds - y axis
            IF AlienBulletAnimation(index, ALIEN_BULLET_Y) >= 256 * 16
                ' kill the bullet
                ALIEN_BULLET_KillBullet(index)
            ELSE IF AlienBulletAnimation(index, ALIEN_BULLET_Y) < 0
                ' kill the bullet
                ALIEN_BULLET_KillBullet(index)
            END IF

            AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) = AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) + 1

        ELSE IF AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) >= ALIEN_BULLET_LIFETIME
            ' kill the bullet
            ALIEN_BULLET_KillBullet(index)
        END IF
    NEXT index
END SUB

' ===============================
' === ALIEN_BULLET_KillBullet ===
' ===============================
SUB ALIEN_BULLET_KillBullet(index AS UBYTE)
    ' remove the sprite
    RemoveSprite(ALIEN_BULLET_SPRITE_START + index, 0)
    AlienBulletAnimation(index, ALIEN_BULLET_COUNTER) = -1
    AlienBulletCount = AlienBulletCount - 1
END SUB

#endif