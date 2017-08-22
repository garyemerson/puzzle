module Main exposing (..)

import Html exposing (Html, div, button)
import Svg exposing (Svg, svg, circle, Attribute, rect)
import Svg.Attributes exposing (..)
import Svg.Events exposing (on)
import Debug exposing (log)
import Json.Decode as Decode
import Mouse exposing (Position)
import Window
import Task
import Touch exposing (Coordinates)
import SingleTouch
import Puzzle
import Dict exposing (Dict)
import List exposing (map)
import Tuple exposing (first, second)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { positions : Dict Int Position
    , drag : Maybe Drag
    , winSize : WinSize
    , close : Bool
    }


type alias Drag =
    { puzzleId : Int
    , start : Position
    , current : Position
    }


type alias WinSize =
    { width : Int
    , height : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model positionsInit Nothing (WinSize 100 100) False, Task.perform WinResize Window.size )


positionsInit : Dict Int Position
positionsInit =
    Dict.empty
        |> Dict.insert 0 (Position 100 100)
        |> Dict.insert 1 (Position 300 100)
        |> Dict.insert 2 (Position 500 100)
        |> Dict.insert 3 (Position 700 100)



-- UPDATE


type Msg
    = WinResize WinSize
    | DragStart Int Position
    | DragAt Int Position
    | DragEnd Int Position



--| DragPuzzleStart Int Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WinResize winSize ->
            ( { model | winSize = (log "WinResize" winSize) }, Cmd.none )

        DragStart id position ->
            ( { model | drag = Just (Drag id position position) }, Cmd.none )

        DragAt id position ->
            ( { model | drag = Maybe.map (\drag -> Drag drag.puzzleId drag.start position) model.drag, close = log "close" ((dist snapPoint (getPosition id model)) < toFloat snapRadius) }, Cmd.none )

        DragEnd id _ ->
            ( { model
                | drag = Nothing
                , positions = Dict.update id (always (Just (getPosition id model))) model.positions

                --log "DragEnd"
                --    (if model.close then
                --        snapPoint
                --     else
                --        getPosition model
                --    )
              }
            , Cmd.none
            )



--DragPuzzleStart _ _ ->
--    ( model, Cmd.none )


dist : Position -> Position -> Float
dist p1 p2 =
    sqrt (toFloat ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2))



--dist
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just drag ->
            Sub.batch [ Mouse.moves (DragAt drag.puzzleId), Mouse.ups (DragEnd drag.puzzleId), Window.resizes WinResize ]

        Nothing ->
            Window.resizes WinResize



-- VIEW


snapPoint : Position
snapPoint =
    Position 300 300


snapRadius : Int
snapRadius =
    20 + snapGuideRadius


snapGuideRadius : Int
snapGuideRadius =
    2


view : Model -> Html Msg
view model =
    svg [ color "red", display "block", width (toString model.winSize.width), height (toString model.winSize.height) ]
        (puzzlePieces model)



--circle
--    [ onMouseDown
--    , SingleTouch.onStart (\coord -> DragStart (coordsToPosition (log "touch coord" coord)))
--    , SingleTouch.onMove (\coord -> DragAt (coordsToPosition (log "touch coord" coord)))
--    , SingleTouch.onEnd (\coord -> DragEnd (coordsToPosition (log "touch coord" coord)))
--    , Svg.Attributes.cursor "move"
--    , if model.close then
--        cx (toString snapPoint.x)
--      else
--        cx (toString position.x)
--    , if model.close then
--        cy (toString snapPoint.y)
--      else
--        cy (toString position.y)
--    , r "25%"
--    , fill "#0B79CE"
--    ]
--    []
--, circle
--    [ if model.close then
--        cx (toString snapPoint.x)
--      else
--        cx (toString position.x)
--    , if model.close then
--        cy (toString snapPoint.y)
--      else
--        cy (toString position.y)
--    , r (toString snapGuideRadius)
--    , fill "#000"
--    ]
--    []
--, Svg.text_
--    [ fontSize "22px"
--    , if model.close then
--        x (toString snapPoint.x)
--      else
--        x (toString position.x)
--    , if model.close then
--        y (toString (snapPoint.y + 100))
--      else
--        y (toString (position.y + 100))
--    ]
--    [ Svg.text "Drag to gray circle" ]
--, circle
--    [ cx (toString snapPoint.x)
--    , cy (toString snapPoint.y)
--    , r (toString (snapRadius - snapGuideRadius))
--    , fill "rgba(153, 153, 153, 0.75)"
--    ]
--    [] ,
--, Svg.text_
--    [ fontSize "22px"
--    , x "500"
--    , y "250"
--    ]
--    [ Svg.text (toString (Puzzle.mirror ( ( 10, 10 ), ( 16, -3 ), ( 16, -16 ) ))) ]


puzzlePieces : Model -> List (Svg Msg)
puzzlePieces model =
    (map
        (\( key, val ) ->
            Puzzle.center (positionToPoint (getPosition key model))
                [ onMouseDown (first ( key, val ))
                , SingleTouch.onStart (\coord -> DragStart key (coordsToPosition coord))
                , SingleTouch.onMove (\coord -> DragAt key (coordsToPosition coord))
                , SingleTouch.onEnd (\coord -> DragEnd key (coordsToPosition coord))
                ]
        )
        (Dict.toList model.positions)
    )


coordsToPosition : Coordinates -> Position
coordsToPosition coords =
    Position (truncate coords.clientX) (truncate coords.clientY)


positionToPoint : Position -> Puzzle.Point
positionToPoint position =
    Puzzle.Point (toFloat position.x) (toFloat position.y)


onMouseDown : Int -> Attribute Msg
onMouseDown id =
    on "mousedown" (Decode.map (DragStart id) Mouse.position)


getPosition : Int -> Model -> Position
getPosition id { positions, drag, winSize } =
    case drag of
        Nothing ->
            case Dict.get id positions of
                Nothing ->
                    -- TODO: this should never happen, why does it need to be here?
                    Position 0 0

                Just position ->
                    position

        Just { puzzleId, start, current } ->
            let
                position =
                    case Dict.get id positions of
                        Nothing ->
                            -- TODO: this should never happen, why does it need to be here?
                            Position 0 0

                        Just position ->
                            position
            in
                if id == puzzleId then
                    Position
                        (position.x + current.x - start.x)
                        (position.y + current.y - start.y)
                else
                    Position position.x position.y
