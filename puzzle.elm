module Puzzle exposing (..)

import Html exposing (Html)
import Svg exposing (svg, circle, Attribute, rect)
import Svg.Attributes exposing (..)
import Svg.Events exposing (on)


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
center : Point -> Html msg
center center =
    svg [ width "361", height "361", overflow "visible" ]
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
                        , toString center.x
                        , toString center.y
                        ]
                    , leftKnob
                    , bottomKnob
                    , rightKnob
                    , topKnob
                    ]
                )
            ]
            []

        --, Svg.text_
        --    [ fontSize "22px", x "50", y "50" ]
        --    [ Svg.text (toString (mirror ( ( 0, -13.328 ), ( 7.945, -18.182 ), ( 18.236, -7.873 ) ))) ]
        --, Svg.text_
        --    [ fontSize "22px", x "50", y "75" ]
        --    [ Svg.text (toString (mirror ( ( 10.311, 10.309 ), ( 16.365, -3.035 ), ( 16.365, -15.763 ) ))) ]
        ]


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
        [ "l 0 -35.709"
        , "c 0 -13.328, 7.945 -18.182, 18.236 -7.873"
        , "c 10.311 10.309, 16.365 -3.035, 16.365 -15.763"
        , "c  0 -12.728, -6.054 -26.072, -16.365 -15.763"
        , "c -10.291 10.309, -18.236 5.455, -18.236 -7.873"
        , "l 0 -35.709"
        ]


topKnob : String
topKnob =
    String.join " "
        [ "l -35.709 0"
        , "c -13.328 0, -18.182 -7.945, -7.873 -18.236"
        , "c 10.309 -10.311, -3.035 -16.365, -15.763 -16.365"
        , "c  -12.728 0, -26.072 6.054, -15.763 16.365"
        , "c 10.309 10.291, 5.455 18.236, -7.873 18.236"
        , "l -35.709 0"
        ]


leftKnob : String
leftKnob =
    String.join " "
        [ "l 0 35.709"
        , "c 0 13.328, 7.945 18.182, 18.236 7.873"
        , "c 10.311 -10.309, 16.365 3.035, 16.365 15.763"
        , "c  0 12.728, -6.054 26.072, -16.365 15.763"
        , "c -10.291 -10.309, -18.236 -5.455, -18.236 7.873"
        , "l 0 35.709"
        ]


bottomKnob : String
bottomKnob =
    String.join " "
        [ "l 35.709 0"
        , "c 13.328 0, 18.182 -7.945, 7.873 -18.236"
        , "c -10.309 -10.311, 3.035 -16.365, 15.763 -16.365"
        , "c  12.728 0, 26.072 6.054, 15.763 16.365"
        , "c -10.309 10.291, -5.455 18.236, 7.873 18.236"
        , "l 35.709 0"
        ]
