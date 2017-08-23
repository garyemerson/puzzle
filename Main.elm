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
import Puzzle exposing (Piece(..))
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


getOr : comparable -> v -> Dict comparable v -> v
getOr key fallback dict =
    case Dict.get key dict of
        Nothing ->
            fallback

        Just val ->
            val



-- MODEL


type alias Model =
    { positions : Dict Int ( Puzzle.Piece, Position )
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


positionsInit : Dict Int ( Puzzle.Piece, Position )
positionsInit =
    Dict.empty
        |> Dict.insert 0 ( Center, (Position 100 100) )
        |> Dict.insert 1 ( Center, (Position 100 250) )
        |> Dict.insert 2 ( Center, (Position 100 400) )
        |> Dict.insert 3 ( Center, (Position 250 400) )
        |> Dict.insert 4 ( Center, (Position 400 400) )
        |> Dict.insert 5 ( Center, (Position 400 250) )
        |> Dict.insert 6 ( Center, (Position 400 100) )
        |> Dict.insert 7 ( Center, (Position 250 100) )
        |> Dict.insert 8 ( Center, (Position 250 250) )
        |> Dict.insert 9 ( Center, (Position 600 100) )
        |> Dict.insert 10 ( Center, (Position 750 100) )
        |> Dict.insert 11 ( Center, (Position 600 250) )
        |> Dict.insert 13 ( Center, (Position 600 400) )
        |> Dict.insert 14 ( Center, (Position 600 400) )
        |> Dict.insert 15 ( Center, (Position 600 400) )
        |> Dict.insert 16 ( Center, (Position 600 400) )
        |> Dict.insert 17 ( Center, (Position 600 400) )
        |> Dict.insert 18 ( Center, (Position 600 400) )
        |> Dict.insert 19 ( Center, (Position 600 400) )
        |> Dict.insert 20 ( Center, (Position 600 400) )
        |> Dict.insert 21 ( Center, (Position 600 400) )
        |> Dict.insert 22 ( Center, (Position 600 400) )
        |> Dict.insert 23 ( Center, (Position 600 400) )
        |> Dict.insert 24 ( Center, (Position 600 400) )
        |> Dict.insert 25 ( Center, (Position 600 400) )
        |> Dict.insert 26 ( Center, (Position 600 400) )
        |> Dict.insert 27 ( Center, (Position 600 400) )
        |> Dict.insert 28 ( Center, (Position 600 400) )
        |> Dict.insert 29 ( Center, (Position 600 400) )
        |> Dict.insert 30 ( Center, (Position 600 400) )
        |> Dict.insert 31 ( Center, (Position 600 400) )
        |> Dict.insert 32 ( Center, (Position 600 400) )
        |> Dict.insert 33 ( Center, (Position 600 400) )
        |> Dict.insert 34 ( Center, (Position 600 400) )
        |> Dict.insert 35 ( Center, (Position 600 400) )
        |> Dict.insert 36 ( Center, (Position 600 400) )
        |> Dict.insert 37 ( Center, (Position 600 400) )
        |> Dict.insert 38 ( Center, (Position 600 400) )
        |> Dict.insert 39 ( Center, (Position 600 400) )
        |> Dict.insert 40 ( Center, (Position 600 400) )
        |> Dict.insert 41 ( Center, (Position 600 400) )
        |> Dict.insert 42 ( Center, (Position 600 400) )
        |> Dict.insert 43 ( Center, (Position 600 400) )
        |> Dict.insert 44 ( Center, (Position 600 400) )
        |> Dict.insert 45 ( Center, (Position 600 400) )
        |> Dict.insert 46 ( Center, (Position 600 400) )
        |> Dict.insert 47 ( Center, (Position 600 400) )
        |> Dict.insert 48 ( Center, (Position 600 400) )
        |> Dict.insert 49 ( Center, (Position 600 400) )
        |> Dict.insert 50 ( Center, (Position 600 400) )
        |> Dict.insert 51 ( Center, (Position 600 400) )
        |> Dict.insert 52 ( Center, (Position 600 400) )
        |> Dict.insert 53 ( Center, (Position 600 400) )
        |> Dict.insert 54 ( Center, (Position 600 400) )
        |> Dict.insert 55 ( Center, (Position 600 400) )
        |> Dict.insert 56 ( Center, (Position 600 400) )
        |> Dict.insert 57 ( Center, (Position 600 400) )
        |> Dict.insert 58 ( Center, (Position 600 400) )
        |> Dict.insert 59 ( Center, (Position 600 400) )
        |> Dict.insert 60 ( Center, (Position 600 400) )
        |> Dict.insert 61 ( Center, (Position 600 400) )
        |> Dict.insert 62 ( Center, (Position 600 400) )
        |> Dict.insert 63 ( Center, (Position 600 400) )
        |> Dict.insert 64 ( Center, (Position 600 400) )
        |> Dict.insert 65 ( Center, (Position 600 400) )
        |> Dict.insert 66 ( Center, (Position 600 400) )
        |> Dict.insert 67 ( Center, (Position 600 400) )
        |> Dict.insert 68 ( Center, (Position 600 400) )
        |> Dict.insert 69 ( Center, (Position 600 400) )
        |> Dict.insert 70 ( Center, (Position 600 400) )
        |> Dict.insert 71 ( Center, (Position 600 400) )
        |> Dict.insert 72 ( Center, (Position 600 400) )
        |> Dict.insert 73 ( Center, (Position 600 400) )
        |> Dict.insert 74 ( Center, (Position 600 400) )
        |> Dict.insert 75 ( Center, (Position 600 400) )
        |> Dict.insert 76 ( Center, (Position 600 400) )
        |> Dict.insert 77 ( Center, (Position 600 400) )
        |> Dict.insert 78 ( Center, (Position 600 400) )
        |> Dict.insert 79 ( Center, (Position 600 400) )
        |> Dict.insert 80 ( Center, (Position 600 400) )
        |> Dict.insert 81 ( Center, (Position 600 400) )
        |> Dict.insert 82 ( Center, (Position 600 400) )
        |> Dict.insert 83 ( Center, (Position 600 400) )
        |> Dict.insert 84 ( Center, (Position 600 400) )
        |> Dict.insert 85 ( Center, (Position 600 400) )
        |> Dict.insert 86 ( Center, (Position 600 400) )
        |> Dict.insert 87 ( Center, (Position 600 400) )
        |> Dict.insert 88 ( Center, (Position 600 400) )
        |> Dict.insert 89 ( Center, (Position 600 400) )
        |> Dict.insert 90 ( Center, (Position 600 400) )
        |> Dict.insert 91 ( Center, (Position 600 400) )
        |> Dict.insert 92 ( Center, (Position 600 400) )
        |> Dict.insert 93 ( Center, (Position 600 400) )
        |> Dict.insert 94 ( Center, (Position 600 400) )
        |> Dict.insert 95 ( Center, (Position 600 400) )
        |> Dict.insert 96 ( Center, (Position 600 400) )
        |> Dict.insert 97 ( Center, (Position 600 400) )
        |> Dict.insert 98 ( Center, (Position 600 400) )
        |> Dict.insert 99 ( Center, (Position 600 400) )



-- UPDATE


type Msg
    = WinResize WinSize
    | DragStart Int Position
    | DragAt Int Position
    | DragEnd Int Position


closestSnapPoint : Int -> Model -> ( Float, Position, Puzzle.Knob )
closestSnapPoint id model =
    let
        currKnobs =
            let
                ( piece, position ) =
                    getPiecePosition id model
            in
                List.map (\( pt, knob ) -> ( pointToPosition pt, knob )) (Puzzle.knobPoints piece (positionToPoint position))

        allOtherKnobs =
            otherKnobs id model
    in
        case
            (minThird
                (List.foldr
                    (::)
                    []
                    (List.map
                        (\( pos, knob ) ->
                            case knob of
                                Puzzle.LeftKnob ->
                                    closestSnapPointAux pos (List.filter (\( _, knob ) -> knob == Puzzle.RightKnob) allOtherKnobs)

                                Puzzle.BottomKnob ->
                                    closestSnapPointAux pos (List.filter (\( _, knob ) -> knob == Puzzle.TopKnob) allOtherKnobs)

                                Puzzle.RightKnob ->
                                    closestSnapPointAux pos (List.filter (\( _, knob ) -> knob == Puzzle.LeftKnob) allOtherKnobs)

                                Puzzle.TopKnob ->
                                    closestSnapPointAux pos (List.filter (\( _, knob ) -> knob == Puzzle.BottomKnob) allOtherKnobs)
                        )
                        currKnobs
                    )
                 --( 0, Position 0 0, Puzzle.LeftKnob )
                )
            )
        of
            Nothing ->
                ( 0, Position 0 0, Puzzle.LeftKnob )

            Just ( pos, knob, dist ) ->
                ( dist, pos, knob )


otherKnobs : Int -> Model -> List ( Position, Puzzle.Knob )
otherKnobs id model =
    List.foldr
        (List.append)
        []
        (List.map (\( key, ( piece, pos ) ) -> List.map (\( pt, knob ) -> ( pointToPosition pt, knob )) (Puzzle.knobPoints piece (positionToPoint pos))) (List.filter (\( id2, _ ) -> id2 /= id) (Dict.toList model.positions)))


closestSnapPointAux : Position -> List ( Position, Puzzle.Knob ) -> ( Position, Puzzle.Knob, Float )
closestSnapPointAux position knobs =
    case minThird (List.map (\( pos, knob ) -> ( pos, knob, dist pos position )) knobs) of
        Nothing ->
            ( Position 0 0, Puzzle.LeftKnob, 0 )

        Just x ->
            x


{-| This returns the mininum tuple by comparing the third element. For example, the min
in [(0, 1), (4, 0), (3, 2)] would be (4, 0).
-}
minThird : List ( a, b, comparable ) -> Maybe ( a, b, comparable )
minThird list =
    List.foldr
        (\curr acc ->
            case acc of
                Nothing ->
                    Just curr

                Just accVal ->
                    if (third curr) < (third accVal) then
                        Just curr
                    else
                        Just accVal
        )
        Nothing
        list


third : ( a, b, c ) -> c
third ( a, b, c ) =
    c



--(1, 2), (0, 4), (3, 7)
--List.map (\()) (Dict.toList model.positions)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WinResize winSize ->
            ( { model | winSize = (log "WinResize" winSize) }, Cmd.none )

        DragStart id position ->
            ( { model | drag = Just (Drag id position position) }, Cmd.none )

        DragAt id position ->
            ( { model
                | drag =
                    Maybe.map
                        (\drag -> Drag drag.puzzleId drag.start position)
                        model.drag
                , close = (dist snapPoint (getPosition id model)) < toFloat snapRadius
              }
            , Cmd.none
            )

        DragEnd id _ ->
            ( { model
                | drag = Nothing
                , positions = Dict.update id (always (Just ( Center, (getPosition id model) ))) model.positions

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
    20


snapGuideRadius : Int
snapGuideRadius =
    2


view : Model -> Html Msg
view model =
    svg [ width (toString model.winSize.width), height (toString model.winSize.height) ]
        (List.append
            (puzzlePieces model)
            (case model.drag of
                Nothing ->
                    []

                Just x ->
                    let
                        ( _, pos, _ ) =
                            closestSnapPoint x.puzzleId model
                    in
                        [ circle
                            [ cx (toString pos.x)
                            , cy (toString pos.y)
                            , r "3"
                            , fill "yellow"
                            ]
                            []
                        ]
            )
        )


puzzlePieces : Model -> List (Svg Msg)
puzzlePieces model =
    (map
        (\( key, val ) ->
            Puzzle.pieceSvg (first val)
                (positionToPoint (getPosition key model))
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


pointToPosition : Puzzle.Point -> Position
pointToPosition pt =
    Position (truncate pt.x) (truncate pt.y)


positionToPoint : Position -> Puzzle.Point
positionToPoint position =
    Puzzle.Point (toFloat position.x) (toFloat position.y)


onMouseDown : Int -> Attribute Msg
onMouseDown id =
    on "mousedown" (Decode.map (DragStart id) Mouse.position)


{-| getPosition
TODO: the dict lookup is unnecessary and should be removed
-}
getPosition : Int -> Model -> Position
getPosition id model =
    second (getPiecePosition id model)


getPiecePosition : Int -> Model -> ( Puzzle.Piece, Position )
getPiecePosition id { positions, drag, winSize } =
    case drag of
        Nothing ->
            case Dict.get id positions of
                Nothing ->
                    -- TODO: this should never happen, why does it need to be here?
                    ( Puzzle.Center, Position 0 0 )

                Just position ->
                    position

        Just { puzzleId, start, current } ->
            let
                position =
                    (case Dict.get id positions of
                        Nothing ->
                            -- TODO: this should never happen, why does it need to be here?
                            ( Puzzle.Center, Position 0 0 )

                        Just position ->
                            position
                    )
            in
                if id == puzzleId then
                    ( first position
                    , Position
                        ((second position).x + current.x - start.x)
                        ((second position).y + current.y - start.y)
                    )
                else
                    position
