module Puzzle exposing (..)

import Svg exposing (Svg, svg, circle, Attribute, rect)
import Svg.Attributes exposing (..)
import List exposing (append)


--Point -> List (Attribute msg) -> Svg msg


type Piece
    = Single
    | CenterHorizontal
    | CenterVertical
    | Bottom
    | Top
    | Right
    | Left
    | MidLeft
    | BottomLeft
    | BottomMid
    | BottomRight
    | MidRight
    | TopRight
    | TopMid
    | TopLeft
    | Center


type Knob
    = LeftKnob
    | BottomKnob
    | RightKnob
    | TopKnob



--{ svg : List (Attribute msg) -> Svg msg
--, leftKnobOffset : Maybe Point
--, bottomKnobOffset : Maybe Point
--, rightKnobOffset : Maybe Point
--, topKnobOffset : Maybe Point
--}


type alias Point =
    { x : Float, y : Float }


subPts : Point -> Point -> Point
subPts pt1 pt2 =
    Point (pt1.x - pt2.x) (pt1.y - pt2.y)


addPts : Point -> Point -> Point
addPts pt1 pt2 =
    Point (pt1.x + pt2.x) (pt1.y + pt2.y)


knobPoints : Piece -> Point -> List ( Point, Knob )
knobPoints piece point =
    case piece of
        Single ->
            []

        CenterHorizontal ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point rightKnobOffset, RightKnob ) ]

        CenterVertical ->
            [ ( addPts point bottomKnobOffset, BottomKnob ), ( addPts point topKnobOffset, TopKnob ) ]

        Bottom ->
            [ ( addPts point topKnobOffset, TopKnob ) ]

        Top ->
            [ ( addPts point bottomKnobOffset, BottomKnob ) ]

        Right ->
            [ ( addPts point leftKnobOffset, LeftKnob ) ]

        Left ->
            [ ( addPts point rightKnobOffset, RightKnob ) ]

        MidLeft ->
            [ ( addPts point bottomKnobOffset, BottomKnob ), ( addPts point rightKnobOffset, RightKnob ), ( addPts point topKnobOffset, TopKnob ) ]

        BottomLeft ->
            [ ( addPts point rightKnobOffset, RightKnob ), ( addPts point topKnobOffset, TopKnob ) ]

        BottomMid ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point rightKnobOffset, RightKnob ), ( addPts point topKnobOffset, TopKnob ) ]

        BottomRight ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point topKnobOffset, TopKnob ) ]

        MidRight ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point bottomKnobOffset, BottomKnob ), ( addPts point topKnobOffset, TopKnob ) ]

        TopRight ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point bottomKnobOffset, BottomKnob ) ]

        TopMid ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point bottomKnobOffset, BottomKnob ), ( addPts point rightKnobOffset, RightKnob ) ]

        TopLeft ->
            [ ( addPts point bottomKnobOffset, BottomKnob ), ( addPts point rightKnobOffset, RightKnob ) ]

        Center ->
            [ ( addPts point leftKnobOffset, LeftKnob ), ( addPts point bottomKnobOffset, BottomKnob ), ( addPts point rightKnobOffset, RightKnob ), ( addPts point topKnobOffset, TopKnob ) ]


pieceWidth : Int
pieceWidth =
    118


pieceHeight : Int
pieceHeight =
    118


{-| Auxilary fn to create svg for a puzzle piece given the specified sides.
-}
pieceSvgAux : String -> String -> String -> String -> Point -> List (Attribute msg) -> Svg msg
pieceSvgAux left bottom right top point attrs =
    svg
        (append
            attrs
            [ {- width "361", height "361", -} overflow "visible", cursor "move" ]
        )
        [ Svg.path
            [ stroke "#555"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , d
                (String.join
                    " "
                    [ String.join " "
                        [ "M"
                        , toString point.x
                        , toString point.y
                        ]
                    , left
                    , bottom
                    , right
                    , top
                    ]
                )
            ]
            []
        ]



{-
   The 16 different types of puzzle pieces are:

    ┌───┐  ┌───┐  ┌───┐                       ┌───┐
    │    > >    > >   │                       │   │
    └─^─┘  └─^─┘  └─^─┘                       └─^─┘
    ┌─^─┐  ┌─^─┐  ┌─^─┐  ┌───┐  ┌───┐  ┌───┐  ┌─^─┐  ┌───┐
    │    > >    > >   │  │    > >    > >   │  │   │  │   │
    └─^─┘  └─^─┘  └─^─┘  └───┘  └───┘  └───┘  └─^─┘  └───┘
    ┌─^─┐  ┌─^─┐  ┌─^─┐                       ┌─^─┐
    │    > >   >  >   │                       │   │
    └───┘  └───┘  └───┘                       └───┘

   The origin/point/move point of a puzzle piece is the top left corner. The svg path runs counterclockwise.
-}
{- offsets from top left origin
   left     (34, 59)
   bottom   (59, 84)
   right    (152, 59)
   top      (59, -34)
-}


knobOffset : Knob -> Point
knobOffset knob =
    case knob of
        LeftKnob ->
            rightKnobOffset

        BottomKnob ->
            topKnobOffset

        RightKnob ->
            leftKnobOffset

        TopKnob ->
            bottomKnobOffset


leftKnobOffset : Point
leftKnobOffset =
    Point 34 59


bottomKnobOffset : Point
bottomKnobOffset =
    Point 59 84


rightKnobOffset : Point
rightKnobOffset =
    Point 152 59


topKnobOffset : Point
topKnobOffset =
    Point 59 -34


pieceSvg : Piece -> Point -> List (Attribute msg) -> Svg msg
pieceSvg piece point attrs =
    case piece of
        Single ->
            pieceSvgAux leftLine bottomLine rightLine topLine point attrs

        CenterHorizontal ->
            pieceSvgAux leftKnob bottomLine rightKnob topLine point attrs

        CenterVertical ->
            pieceSvgAux leftLine bottomKnob rightLine topKnob point attrs

        Bottom ->
            --bottomSvg : Point -> List (Attribute msg) -> Svg msg
            --bottomSvg point attrs =
            pieceSvgAux leftLine bottomLine rightLine topKnob point attrs

        --}
        Top ->
            --topSvg : Point -> List (Attribute msg) -> Svg msg
            --topSvg point attrs =
            pieceSvgAux leftLine bottomKnob rightLine topLine point attrs

        --}
        Right ->
            --rightSvg : Point -> List (Attribute msg) -> Svg msg
            --rightSvg point attrs =
            pieceSvgAux leftKnob bottomLine rightLine topLine point attrs

        --}
        Left ->
            --leftSvg : Point -> List (Attribute msg) -> Svg msg
            --leftSvg point attrs =
            pieceSvgAux leftLine bottomLine rightKnob topLine point attrs

        --}
        MidLeft ->
            --midLeftSvg : Point -> List (Attribute msg) -> Svg msg
            --midLeftSvg point attrs =
            pieceSvgAux leftLine bottomKnob rightKnob topKnob point attrs

        --}
        BottomLeft ->
            --bottomLeftSvg : Point -> List (Attribute msg) -> Svg msg
            --bottomLeftSvg point attrs =
            pieceSvgAux leftLine bottomLine rightKnob topKnob point attrs

        --}
        BottomMid ->
            --bottomMidSvg : Point -> List (Attribute msg) -> Svg msg
            --bottomMidSvg point attrs =
            pieceSvgAux leftKnob bottomLine rightKnob topKnob point attrs

        --}
        BottomRight ->
            --bottomRightSvg : Point -> List (Attribute msg) -> Svg msg
            --bottomRightSvg point attrs =
            pieceSvgAux leftKnob bottomLine rightLine topKnob point attrs

        --}
        MidRight ->
            --midRightSvg : Point -> List (Attribute msg) -> Svg msg
            --midRightSvg point attrs =
            pieceSvgAux leftKnob bottomKnob rightLine topKnob point attrs

        --}
        TopRight ->
            --topRightSvg : Point -> List (Attribute msg) -> Svg msg
            --topRightSvg point attrs =
            pieceSvgAux leftKnob bottomKnob rightLine topLine point attrs

        --}
        TopMid ->
            --topMidSvg : Point -> List (Attribute msg) -> Svg msg
            --topMidSvg point attrs =
            pieceSvgAux leftKnob bottomKnob rightKnob topLine point attrs

        --}
        TopLeft ->
            --topLeftSvg : Point -> List (Attribute msg) -> Svg msg
            --topLeftSvg point attrs =
            pieceSvgAux leftLine bottomKnob rightKnob topLine point attrs

        --}
        Center ->
            --centerSvg : Point -> List (Attribute msg) -> Svg msg
            --centerSvg point attrs =
            pieceSvgAux leftKnob bottomKnob rightKnob topKnob point attrs
--}


{-| Auxiliary fn to mirror 'c' path elements (bezier curves) about the x axis
-}
mirror : ( ( Float, Float ), ( Float, Float ), ( Float, Float ) ) -> ( ( Float, Float ), ( Float, Float ), ( Float, Float ) )
mirror ( ( x1, y1 ), ( x2, y2 ), ( x3, y3 ) ) =
    let
        ( dx, dy ) =
            ( -x3, y3 )
    in
        ( ( x2 - x3, -(y2 - y3) ), ( dx + x1, dy - y1 ), ( dx, dy ) )



{-
      (18 + 16, 35 + 8 + 16)
      (34, 59)

      * For rightKnob and leftKnob the center of the knob is (34, 59) away from its uppermost point
      * For topKnob and bottomKnob the center of the know is (59, -34) away from its leftmost point

      118 long

   offsets from top left origin
      left     (34, 59)
      bottom   (59, 84)
      right    (152, 59)
      top      (59, -34)
-}


rightKnob : String
rightKnob =
    String.join " "
        [ "l 0 -35"
        , "c 0 -13, 8 -18, 18 -8"
        , "c 10 10, 16 -3, 16 -16"
        , "c 0 -13,-6 -26, -16 -16"
        , "c -10 10, -18 5, -18 -8"
        , "l 0 -35"
        ]


topKnob : String
topKnob =
    String.join " "
        [ "l -35 0"
        , "c -13 0, -18 -8, -8 -18"
        , "c 10 -10, -3 -16, -16 -16"
        , "c -13 -0, -26 6, -16 16"
        , "c 10 10, 5 18, -8 18"
        , "l -35 0"
        ]


leftKnob : String
leftKnob =
    String.join " "
        [ "l 0 35"
        , "c 0 13, 8 18, 18 8"
        , "c 10 -10, 16 3, 16 16"
        , "c 0 13,-6 26, -16 16"
        , "c -10 -10, -18 -5, -18 8"
        , "l 0 35"
        ]


bottomKnob : String
bottomKnob =
    String.join " "
        [ "l 35 0"
        , "c 13 0, 18 -8, 8 -18"
        , "c -10 -10, 3 -16, 16 -16"
        , "c 13 -0, 26 6, 16 16"
        , "c -10 10, -5 18, 8 18"
        , "l 35 0"
        ]


rightLine : String
rightLine =
    "l 0 -118"


topLine : String
topLine =
    "l -118 0"


leftLine : String
leftLine =
    "l 0 118"


bottomLine : String
bottomLine =
    "l 118 0"
