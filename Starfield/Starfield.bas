' ================
' === Includes ===
' ================
#INCLUDE <nextlib.bas>

' =================
' === Constants ===
' =================

' data bank to use for starfield data
CONST SF_DATA_BANK AS UBYTE = 66

' start address of starfield data
CONST SF_DATA_ADDR AS UINTEGER = $8000

' number of stars to show
CONST SF_NUM_STARS AS UBYTE = 60

' planes (not needed but make source easier to read)
CONST SF_PLANE_1 AS UBYTE = 1
CONST SF_PLANE_2 AS UBYTE = 2
CONST SF_PLANE_3 AS UBYTE = 3

' velocity multipliers (not needed but make source easier to read)
CONST SF_VELOCITY_1 AS UBYTE = 2
CONST SF_VELOCITY_2 AS UBYTE = 1
CONST SF_VELOCITY_3 AS UBYTE = 0

' ========================
' === Global Variables ===
' ========================

' bounding rectangle
'DIM SF_MIN_X AS UINTEGER = 3200
'DIM SF_MIN_Y AS UINTEGER = 3200
'DIM SF_MAX_X AS UINTEGER = 28799
'DIM SF_MAX_Y AS UINTEGER = 22399

DIM SF_MIN_X AS UINTEGER = 0
DIM SF_MIN_Y AS UINTEGER = 0
DIM SF_MAX_X AS UINTEGER = 31999
DIM SF_MAX_Y AS UINTEGER = 25599

' initialisation flag
DIM SF_INIT AS UBYTE = 0

' the stars themselves
DIM SF_STARS(SF_NUM_STARS-1, 4) AS UINTEGER

' =================
' === Functions ===
' =================

' ===========================
' === InitialiseStarfield ===
' ===========================
SUB SF_InitialiseStarfield()
    ' declare index
    DIM index AS UBYTE = 0
    DIM count AS UBYTE = 0

    ' seed random numbers
    RANDOMIZE
    
    ' iterate over all the stars and generate
    WHILE index < SF_NUM_STARS
        ' set initial x position'
        SF_STARS(index, 0) = INT(RND() * (SF_MAX_X - SF_MIN_X)) + SF_MIN_X + 1

        ' set initial y position
        SF_STARS(index, 1) = INT(RND() * (SF_MAX_Y - SF_MIN_Y)) + SF_MIN_Y + 1

        IF count > 2
            count = 0
        END IF

        ' set the plane
        SF_STARS(index, 2) = count + 1

        count = count + 1

        ' depending on the plane, set the color
        IF SF_STARS(index, 2) = 1
            ' far plane
            SF_STARS(index, 3) = 7
        ELSE IF SF_STARS(index, 2) = 2
            ' mid plane
            SF_STARS(index, 3) = 6
        ELSE
            ' near plane
            SF_STARS(index, 3) = 200
        END IF

        ' increment index
        index = index + 1
    END WHILE

    ' set initialised flag
    SF_INIT = 1
END SUB

' =======================
' === UpdateStarfield ===
' =======================
SUB SF_UpdateStarfield(dx AS INTEGER, dy AS INTEGER)
    ' declare variables
    DIM index AS UBYTE = 0
    DIM planeDx AS INTEGER
    DIM planeDy AS INTEGER
    DIM plane1Dx AS INTEGER
    DIM plane1Dy AS INTEGER
    DIM plane2Dx AS INTEGER
    DIM plane2Dy AS INTEGER
    DIM plane3Dx AS INTEGER
    DIM plane3Dy AS INTEGER
    DIM plotX AS UINTEGER
    DIM ployY AS UBYTE

    ' pre-calculate component velocities for each plane
    ' far plane - shift by 2 = divide by 4
    plane1Dx = dx / 4
    plane1Dy = dy / 4

    ' mid plane - shift by 1 = divide by 2
    plane2Dx = dx / 2
    plane2Dy = dy / 2
    
    ' near plane - shift by 0 = divide by 1
    plane3Dx = dx
    plane3Dy = dy

    index = 0

    ' iterate over all the stars and update
    WHILE index < SF_NUM_STARS
        ' erase the star
        plotX = SF_STARS(index, 0)/100
        plotY = CAST(UBYTE, SF_STARS(index, 1)/100)
        'IF SF_STARS(index, 0) > 0 AND SF_STARS(index, 0) < 32000 AND SF_STARS(index, 1) > 0 AND SF_STARS(index, 1) < 25600
            FPlotL2(plotY, plotX, 0)
        'END IF
        
        ' move the star
        
        ' modify the velocity based on the plane
        IF SF_STARS(index, 2) = 1
            planeDx = plane1Dx
            planeDy = plane1Dy
        ELSE IF SF_STARS(index, 2) = 2
            planeDx = plane2Dx
            planeDy = plane2Dy
        ELSE
            planeDx = plane3Dx
            planeDy = plane3Dy
        END IF

        ' update star coords and check for bounding
        ' x
        IF planeDx < 0
            IF (SF_STARS(index, 0) + planeDx) < SF_MIN_X
                SF_STARS(index, 0) = SF_MIN_X
            ELSE
                SF_STARS(index, 0) = SF_STARS(index, 0) + planeDx
            END IF
        ELSE
        SF_STARS(index, 0) = SF_STARS(index, 0) + planeDx
        END IF
        

        IF SF_STARS(index, 0) < (SF_MIN_X + 5)
            SF_STARS(index, 0) = SF_MAX_X
        ELSE IF SF_STARS(index, 0) > SF_MAX_X
            SF_STARS(index, 0) = SF_MIN_X
        END IF

        ' y
        
        IF planeDy < 0
            IF (SF_STARS(index, 1) + planeDy) < SF_MIN_Y
                SF_STARS(index, 1) = SF_MIN_Y
            ELSE
                SF_STARS(index, 1) = SF_STARS(index, 1) + planeDy
            END IF
        ELSE
            SF_STARS(index, 1) = SF_STARS(index, 1) + planeDy
        END IF

        IF SF_STARS(index, 1) < (SF_MIN_Y + 5)
            SF_STARS(index, 1) = SF_MAX_Y
        ELSE IF SF_STARS(index, 1) > SF_MAX_Y
            SF_STARS(index, 1) = SF_MIN_Y
        END IF

        ' draw the star
        plotX = SF_STARS(index, 0)/100
        plotY = CAST(UBYTE, SF_STARS(index, 1)/100)
        'IF SF_STARS(index, 0) > 0 AND SF_STARS(index, 0) < 32000 AND SF_STARS(index, 1) > 0 AND SF_STARS(index, 1) < 25600
            FPlotL2(plotY, plotX, SF_STARS(index, 3))
        'END IF

        ' increment index
        index = index + 1
    END WHILE

    'FPlotL2(127,160,209)
    'FPlotL2(128,161,209)
    'FPlotL2(127,160,209)
    'FPlotL2(128,161,209)

END SUB