#ifndef __COLLISION__
#define __COLLISION__

' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>
#INCLUDE "./Bullets.bas"
#INCLUDE "./Explosion.bas"
#INCLUDE "./PlayerShip.bas"
#INCLUDE "./Rocks.bas"

' =================
' === Constants ===
' =================
CONST COLLISION_ROCK_SIZE_LARGE AS INTEGER = 512
CONST COLLISION_ROCK_SIZE_MEDIUM AS INTEGER = 256
CONST COLLISION_ROCK_SIZE_SMALL AS INTEGER = 256
CONST COLLISION_ROCK_BOX_LARGE AS INTEGER = -16
CONST COLLISION_ROCK_BOX_MEDIUM AS INTEGER = -16
CONST COLLISION_ROCK_BOX_SMALL AS INTEGER = 0

' ========================
' === Global Variables ===
' ========================

' =================
' === Functions ===
' =================

' =================================
' === COLLISION_BulletsAndRocks ===
' =================================
SUB COLLISION_BulletsAndRocks()
    DIM rockIndex AS UBYTE = 0
    DIM bulletIndex AS UBYTE = 0
    DIM box AS INTEGER
    DIM size AS INTEGER

    ' iterate over rocks array
    FOR rockIndex = 0 TO (ROCK_MAX_TOTAL_ROCKS - 1)
        
        ' is the rock live?'
        IF RockAnimation(rockIndex, ROCK_ANIMATION_COUNTER) > -1
            
            ' determine size of rock
            IF RockAnimation(rockIndex, ROCK_ANIMATION_SIZE) = 2
                box = COLLISION_ROCK_BOX_LARGE
                size = COLLISION_ROCK_SIZE_LARGE
            ELSE IF RockAnimation(rockIndex, ROCK_ANIMATION_SIZE) = 1
                box = COLLISION_ROCK_BOX_MEDIUM
                size = COLLISION_ROCK_SIZE_MEDIUM
            ELSE
                box = COLLISION_ROCK_BOX_SMALL
                size = COLLISION_ROCK_SIZE_SMALL
            END IF

            ' iterate over bullets array
            FOR bulletIndex = 0 TO BULLET_MAX_BULLETS - 1
                ' is the bullet live?
                IF BulletAnimation(bulletIndex, BULLET_ANIMATION_COUNTER) > -1
                    ' is there a coliision?
                    IF BulletAnimation(bulletIndex, BULLET_ANIMATION_X) + 1 >= RockAnimation(rockIndex, ROCK_ANIMATION_X) + box _
                        AND BulletAnimation(bulletIndex, BULLET_ANIMATION_X) + 1 <= RockAnimation(rockIndex, ROCK_ANIMATION_X) + (size - box) _
                        AND BulletAnimation(bulletIndex, BULLET_ANIMATION_Y) + 1 >= RockAnimation(rockIndex, ROCK_ANIMATION_Y) + box _
                        AND BulletAnimation(bulletIndex, BULLET_ANIMATION_Y) + 1 <= RockAnimation(rockIndex, ROCK_ANIMATION_Y) + (size - box)
                    
                        ' boom
                        ' start an explosion
                        EXPLOSION_Start( _
                            RockAnimation(rockIndex, ROCK_ANIMATION_X), _
                            RockAnimation(rockIndex, ROCK_ANIMATION_Y), _
                            RockAnimation(rockIndex, ROCK_ANIMATION_DX), _
                            RockAnimation(rockIndex, ROCK_ANIMATION_DY), _
                            RockAnimation(rockIndex, ROCK_ANIMATION_SIZE))

                        ' if we are a big rock or medium rock, we create 2 new smaller rocks
                        IF RockAnimation(rockIndex, ROCK_ANIMATION_SIZE) > 0
                            ROCK_StartRock( _
                                RockAnimation(rockIndex, ROCK_ANIMATION_X), _
                                RockAnimation(rockIndex, ROCK_ANIMATION_Y), _
                                RockAnimation(rockIndex, ROCK_ANIMATION_SIZE) - 1)

                            ROCK_StartRock( _
                                RockAnimation(rockIndex, ROCK_ANIMATION_X), _
                                RockAnimation(rockIndex, ROCK_ANIMATION_Y), _
                                RockAnimation(rockIndex, ROCK_ANIMATION_SIZE) - 1)
                        END IF

                        ' and finally kill the rock & bullet
                        ROCK_KillRock(rockIndex)
                        BULLET_KillBullet(bulletIndex)
                    END IF      
                END IF
            NEXT bulletIndex
        END IF
    NEXT rockIndex
END SUB

#endif