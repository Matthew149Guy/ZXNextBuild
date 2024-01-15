' ================
' === Includes ===
' ================
#DEFINE NEX
#INCLUDE <nextlib.bas>
#include <keys.bas>
#INCLUDE "./Starfield.bas"

' =================
' === Constants ===
' =================

' ========================
' === Global Variables ===
' ========================
DIM sf_dx AS INTEGER = 0
DIM sf_dy AS INTEGER = 0

' =================
' === Functions ===
' =================

' ========================
' === InitialiseSystem ===
' ========================
SUB InitialiseSystem()
    NextRegA($7,3)					' 28mhz 
    NextRegA($14,0)					' black transparency 
    NextRegA($70,%00010000)			' enable 320x256 256col L2 
    NextRegA($69,%10000000)			' enables L2 
    ClipLayer2(0,255,0,255)			' make all of L2 visible 
    'NextReg($15,%00000001) 

END SUB

' ===============
' === Program ===
' ===============

InitialiseSystem()
SF_InitialiseStarfield()

DO
    sf_dx = 0
    sf_dy = 0

    IF MultiKeys(KEYA)
        sf_dx = -800
    END IF

    IF MultiKeys(KEYD)
        sf_dx = 800
    END IF

    IF MultiKeys(KEYW)
        sf_dy = -800
    END IF

    IF MultiKeys(KEYS)
        sf_dy = 800
    END IF

    IF MultiKeys(KEYSPACE)
        EXIT DO
    END IF

    SF_UpdateStarfield(sf_dx, sf_dy)
LOOP