#ifndef __BULLETS__
#define __BULLETS__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================
CONST BULLET_SPRITE_OFFSET AS UBYTE = 48
CONST BULLET_SPRITE_START AS UBYTE = 9
CONST BULLET_MAX_BULLETS AS UBYTE = 5
CONST BULLET_ANIMATION_COUNTER_MAX AS UBYTE = 12
CONST BULLET_ANIMATION_X AS UBYTE = 0
CONST BULLET_ANIMATION_Y AS UBYTE = 1
CONST BULLET_ANIMATION_DX AS UBYTE = 2
CONST BULLET_ANIMATION_DY AS UBYTE = 3
CONST BULLET_ANIMATION_COUNTER AS BYTE = 4

' ========================
' === Global Variables ===
' ========================
DIM BulletAnimation(BULLET_MAX_BULLETS, 5) AS INTEGER
DIM BulletCount AS BYTE = 0

' =================
' === Functions ===
' =================

' =========================
' === InitialiseBullets ===
' =========================
SUB BULLET_InitialiseBullets()
    ' declare variables
    DIM index AS UBYTE    
    
    ' initialise bullet count
    BulletCount = 0

    ' iterate over engine wash particle array
    FOR index = 0 TO (BULLET_MAX_BULLETS - 1)
        ' init the animation counter to -1 (which will mean particle is not live)
        BulletAnimation(index, BULLET_ANIMATION_COUNTER) = -1
    NEXT index
END SUB

SUB BULLET_StartBullet(x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER)
    ' declare variables
    DIM firstAvailable AS UBYTE = -1
    DIM index AS UBYTE = 0

    ' have we already got the max number of bullets?
    IF BulletCount >= BULLET_MAX_BULLETS
        RETURN
    END IF

    ' iterate over engine wash particle array
    FOR index = 0 TO (BULLET_MAX_BULLETS - 1)
        IF BulletAnimation(index, BULLET_ANIMATION_COUNTER) = -1
            firstAvailable = index
            EXIT FOR
        END IF
    NEXT index

    ' did we find a slot?
    IF firstAvailable > -1 AND firstAvailable < BULLET_MAX_BULLETS
        BulletAnimation(firstAvailable, BULLET_ANIMATION_X) = x + (dx * 12)
        BulletAnimation(firstAvailable, BULLET_ANIMATION_Y) = y + (dy * 12)
        BulletAnimation(firstAvailable, BULLET_ANIMATION_DX) = dx * 12
        BulletAnimation(firstAvailable, BULLET_ANIMATION_DY) = dy * 12
        BulletAnimation(firstAvailable, BULLET_ANIMATION_COUNTER) = 0
        BulletCount = BulletCount + 1
    END IF
END SUB

SUB BULLET_UpdateBullets()
    ' declare variables
    DIM index AS UBYTE = 0
    DIM PlotX AS UINTEGER
    DIM PlotY AS UBYTE

    ' have we got any bullets to process?
    IF BulletCount = 0
        RETURN
    END IF

    ' iterate over bullets array
    FOR index = 0 TO (BULLET_MAX_BULLETS - 1)
        IF BulletAnimation(index, BULLET_ANIMATION_COUNTER) > -1 AND BulletAnimation(index, BULLET_ANIMATION_COUNTER) < BULLET_ANIMATION_COUNTER_MAX
            ' show the sprite
            PlotX = CAST(UINTEGER, (BulletAnimation(index, BULLET_ANIMATION_X) >> 4))
            PlotY = CAST(UBYTE, (BulletAnimation(index, BULLET_ANIMATION_Y) >> 4))
            UpdateSprite(PlotX, PlotY, BULLET_SPRITE_START + index, BULLET_SPRITE_OFFSET + (BulletAnimation(index, BULLET_ANIMATION_COUNTER) MOD 2), 0, 0)

            ' update bullet values
            BulletAnimation(index, BULLET_ANIMATION_X) = BulletAnimation(index, BULLET_ANIMATION_X) + BulletAnimation(index, BULLET_ANIMATION_DX)
            BulletAnimation(index, BULLET_ANIMATION_Y) = BulletAnimation(index, BULLET_ANIMATION_Y) + BulletAnimation(index, BULLET_ANIMATION_DY)

            ' check for going out of bounds - x axis
            IF BulletAnimation(index, BULLET_ANIMATION_X) > 335 * 16
                BulletAnimation(index, BULLET_ANIMATION_X) = -15 * 16
            ELSE IF BulletAnimation(index, BULLET_ANIMATION_X) < -15 * 16
                BulletAnimation(index, BULLET_ANIMATION_X) = 335 * 16
            END IF

            ' check for going out of bounds - y axis
            IF BulletAnimation(index, BULLET_ANIMATION_Y) >= 256 * 16
                BulletAnimation(index, BULLET_ANIMATION_Y) = 0
            ELSE IF BulletAnimation(index, BULLET_ANIMATION_Y) < 0
                BulletAnimation(index, BULLET_ANIMATION_Y) = (256 * 16) -1
            END IF

            BulletAnimation(index, BULLET_ANIMATION_COUNTER) = BulletAnimation(index, BULLET_ANIMATION_COUNTER) + 1
        ELSE IF BulletAnimation(index, BULLET_ANIMATION_COUNTER) >= 8
            ' kill the bullet
            KillBullet(index)
        END IF
    NEXT index
END SUB

SUB KillBullet(index AS UBYTE)
    ' remove the sprite
    RemoveSprite(BULLET_SPRITE_START + index, 0)
    BulletAnimation(index, BULLET_ANIMATION_COUNTER) = -1
    BulletCount = BulletCount - 1
END SUB

#endif