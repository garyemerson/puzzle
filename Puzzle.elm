module Puzzle exposing (..)

import Svg exposing (Svg, svg, circle, Attribute, rect)
import Svg.Attributes exposing (..)
import List exposing (append)


{-
   The 13 different types of puzzle pieces are:
   ┌───┐  ┌───┐  ┌───┐
   │    > >    > >   │
   └─^─┘  └─^─┘  └─^─┘                ┌───┐
   ┌─^─┐  ┌─^─┐  ┌─^─┐  ┌───┐  ┌───┐  │   │
   │    > >    > >   │  │    > >   │  └─^─┘
   └─^─┘  └─^─┘  └─^─┘  └───┘  └───┘  ┌─^─┐
   ┌─^─┐  ┌─^─┐  ┌─^─┐                │   │
   │    > >   >  >   │                └───┘
   └───┘  └───┘  └───┘
-}


type alias Point =
    { x : Float, y : Float }


{-| The origin/move point of a puzzle piece is the top left corner
-}
center : Point -> List (Attribute msg) -> Svg msg
center topLeft attrs =
    svg
        (append
            attrs
            [ width "361", height "361", overflow "visible", cursor "move" ]
        )
        [ Svg.path
            [ fill "#f1f1f1"
            , stroke "#000000"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            , d
                (String.join
                    " "
                    [ String.join " "
                        [ "M"
                        , toString topLeft.x
                        , toString topLeft.y
                        ]
                    , leftKnob
                    , bottomKnob
                    , rightKnob
                    , topKnob
                    ]
                )
            ]
            []
        ]


{-| Auxliary fn to mirror 'c' path elements (bezier curves) about the x axis
-}
mirror : ( ( Float, Float ), ( Float, Float ), ( Float, Float ) ) -> ( ( Float, Float ), ( Float, Float ), ( Float, Float ) )
mirror ( ( x1, y1 ), ( x2, y2 ), ( x3, y3 ) ) =
    let
        ( dx, dy ) =
            ( -x3, y3 )
    in
        ( ( x2 - x3, -(y2 - y3) ), ( dx + x1, dy - y1 ), ( dx, dy ) )


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
