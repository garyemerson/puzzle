module Main exposing (..)

import Html exposing (Html, div, button)
import Svg exposing (Svg, svg, circle, Attribute, rect, defs, pattern, image)
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
import List exposing (map, maximum, sortBy)
import Maybe exposing (withDefault)
import Navigation exposing (Location)
import UrlParser exposing (parsePath, (<?>), s, stringParam)


main : Program Never Model Msg
main =
    Navigation.program
        UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { pieces : Dict Int ( Puzzle.Piece, Position, Int )
    , drag : Maybe Drag
    , winSize : WinSize
    , snap : Maybe Snap
    , numCols : Int
    , numRows : Int
    , location : Location
    , imgUrl : Maybe (Maybe String)
    }


type alias Snap =
    { dist : Float
    , position : Position
    , knob : Puzzle.Knob
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


init : Location -> ( Model, Cmd Msg )
init location =
    ( Model
        piecesInit
        Nothing
        (WinSize 100 100)
        Nothing
        4
        3
        (log "location" location)
        (log "imgUrl" (parsePath (s "" <?> stringParam "img") location))
    , Task.perform WinResize Window.size
    )


piecesInit : Dict Int ( Puzzle.Piece, Position, Int )
piecesInit =
    Dict.empty
        |> Dict.insert 0 ( TopLeft, (Position 100 100), 0 )
        |> Dict.insert 1 ( TopMid, (Position 250 100), 0 )
        |> Dict.insert 2 ( TopMid, (Position 250 100), 0 )
        |> Dict.insert 3 ( TopRight, (Position 400 100), 0 )
        |> Dict.insert 4 ( MidLeft, (Position 100 250), 0 )
        |> Dict.insert 5 ( Center, (Position 250 250), 0 )
        |> Dict.insert 6 ( Center, (Position 250 250), 0 )
        |> Dict.insert 7 ( MidRight, (Position 400 250), 0 )
        |> Dict.insert 8 ( BottomLeft, (Position 100 400), 0 )
        |> Dict.insert 9 ( BottomMid, (Position 250 400), 0 )
        |> Dict.insert 10 ( BottomMid, (Position 250 400), 0 )
        |> Dict.insert 11 ( BottomRight, (Position 400 400), 0 )



--|> Dict.insert 12 ( Left, (Position 600 100), 0 )
--|> Dict.insert 13 ( Right, (Position 750 100), 0 )
--|> Dict.insert 14 ( Top, (Position 600 250), 0 )
--|> Dict.insert 15 ( Bottom, (Position 600 400), 0 )
--|> Dict.insert 140 ( Center, (Position 750 400), 0 )
--|> Dict.insert 150 ( Center, (Position 750 400), 0 )
--|> Dict.insert 16 ( Center, (Position 750 400), 0 )
--|> Dict.insert 17 ( Center, (Position 750 400), 0 )
--|> Dict.insert 18 ( Center, (Position 750 400), 0 )
--|> Dict.insert 19 ( Center, (Position 750 400), 0 )
--|> Dict.insert 20 ( Center, (Position 750 400), 0 )
--|> Dict.insert 21 ( Center, (Position 750 400), 0 )
--|> Dict.insert 22 ( Center, (Position 750 400), 0 )
--|> Dict.insert 23 ( Center, (Position 750 400), 0 )
--|> Dict.insert 24 ( Center, (Position 750 400), 0 )
--|> Dict.insert 25 ( Center, (Position 750 400), 0 )
--|> Dict.insert 26 ( Center, (Position 750 400), 0 )
--|> Dict.insert 27 ( Center, (Position 750 400), 0 )
--|> Dict.insert 28 ( Center, (Position 750 400), 0 )
--|> Dict.insert 29 ( Center, (Position 750 400), 0 )
--|> Dict.insert 30 ( Center, (Position 750 400), 0 )
--|> Dict.insert 31 ( Center, (Position 750 400), 0 )
--|> Dict.insert 32 ( Center, (Position 750 400), 0 )
--|> Dict.insert 33 ( Center, (Position 750 400), 0 )
--|> Dict.insert 34 ( Center, (Position 750 400), 0 )
--|> Dict.insert 35 ( Center, (Position 750 400), 0 )
--|> Dict.insert 36 ( Center, (Position 750 400), 0 )
--|> Dict.insert 37 ( Center, (Position 750 400), 0 )
--|> Dict.insert 38 ( Center, (Position 750 400), 0 )
--|> Dict.insert 39 ( Center, (Position 750 400), 0 )
--|> Dict.insert 40 ( Center, (Position 750 400), 0 )
--|> Dict.insert 41 ( Center, (Position 750 400), 0 )
--|> Dict.insert 42 ( Center, (Position 750 400), 0 )
--|> Dict.insert 43 ( Center, (Position 750 400), 0 )
--|> Dict.insert 44 ( Center, (Position 750 400), 0 )
--|> Dict.insert 45 ( Center, (Position 750 400), 0 )
--|> Dict.insert 46 ( Center, (Position 750 400), 0 )
--|> Dict.insert 47 ( Center, (Position 750 400), 0 )
--|> Dict.insert 48 ( Center, (Position 750 400), 0 )
--|> Dict.insert 49 ( Center, (Position 750 400), 0 )
--|> Dict.insert 50 ( Center, (Position 750 400), 0 )
--|> Dict.insert 51 ( Center, (Position 750 400), 0 )
--|> Dict.insert 52 ( Center, (Position 750 400), 0 )
--|> Dict.insert 53 ( Center, (Position 750 400), 0 )
--|> Dict.insert 54 ( Center, (Position 750 400), 0 )
--|> Dict.insert 55 ( Center, (Position 750 400), 0 )
--|> Dict.insert 56 ( Center, (Position 750 400), 0 )
--|> Dict.insert 57 ( Center, (Position 750 400), 0 )
--|> Dict.insert 58 ( Center, (Position 750 400), 0 )
--|> Dict.insert 59 ( Center, (Position 750 400), 0 )
--|> Dict.insert 60 ( Center, (Position 750 400), 0 )
--|> Dict.insert 61 ( Center, (Position 750 400), 0 )
--|> Dict.insert 62 ( Center, (Position 750 400), 0 )
--|> Dict.insert 63 ( Center, (Position 750 400), 0 )
--|> Dict.insert 64 ( Center, (Position 750 400), 0 )
--|> Dict.insert 65 ( Center, (Position 750 400), 0 )
--|> Dict.insert 66 ( Center, (Position 750 400), 0 )
--|> Dict.insert 67 ( Center, (Position 750 400), 0 )
--|> Dict.insert 68 ( Center, (Position 750 400), 0 )
--|> Dict.insert 69 ( Center, (Position 750 400), 0 )
--|> Dict.insert 70 ( Center, (Position 750 400), 0 )
--|> Dict.insert 71 ( Center, (Position 750 400), 0 )
--|> Dict.insert 72 ( Center, (Position 750 400), 0 )
--|> Dict.insert 73 ( Center, (Position 750 400), 0 )
--|> Dict.insert 74 ( Center, (Position 750 400), 0 )
--|> Dict.insert 75 ( Center, (Position 750 400), 0 )
--|> Dict.insert 76 ( Center, (Position 750 400), 0 )
--|> Dict.insert 77 ( Center, (Position 750 400), 0 )
--|> Dict.insert 78 ( Center, (Position 750 400), 0 )
--|> Dict.insert 79 ( Center, (Position 750 400), 0 )
--|> Dict.insert 80 ( Center, (Position 750 400), 0 )
--|> Dict.insert 81 ( Center, (Position 750 400), 0 )
--|> Dict.insert 82 ( Center, (Position 750 400), 0 )
--|> Dict.insert 83 ( Center, (Position 750 400), 0 )
--|> Dict.insert 84 ( Center, (Position 750 400), 0 )
--|> Dict.insert 85 ( Center, (Position 750 400), 0 )
--|> Dict.insert 86 ( Center, (Position 750 400), 0 )
--|> Dict.insert 87 ( Center, (Position 750 400), 0 )
--|> Dict.insert 88 ( Center, (Position 750 400), 0 )
--|> Dict.insert 89 ( Center, (Position 750 400), 0 )
--|> Dict.insert 90 ( Center, (Position 750 400), 0 )
--|> Dict.insert 91 ( Center, (Position 750 400), 0 )
--|> Dict.insert 92 ( Center, (Position 750 400), 0 )
--|> Dict.insert 93 ( Center, (Position 750 400), 0 )
--|> Dict.insert 94 ( Center, (Position 750 400), 0 )
--|> Dict.insert 95 ( Center, (Position 750 400), 0 )
--|> Dict.insert 96 ( Center, (Position 750 400), 0 )
--|> Dict.insert 97 ( Center, (Position 750 400), 0 )
--|> Dict.insert 98 ( Center, (Position 750 400), 0 )
--|> Dict.insert 99 ( Center, (Position 750 400), 0 )
-- UPDATE


type Msg
    = WinResize WinSize
    | DragStart Int Position
    | DragAt Int Position
    | DragEnd Int Position
    | UrlChange Location


{-| closestSnapPoint
TODO: This should return a Maybe (e.g. if there's only one puzzle piece on the board)
-}
closestSnapPoint :
    Int
    -> Model
    -> Snap -- ( Float, Position, Puzzle.Knob )
closestSnapPoint id model =
    let
        ( piece, position, _ ) =
            dragPosition id model

        currKnobs =
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
                                    closestSnapPointAux
                                        pos
                                        (List.filter (\( _, knob ) -> knob == Puzzle.RightKnob) allOtherKnobs)

                                Puzzle.BottomKnob ->
                                    closestSnapPointAux
                                        pos
                                        (List.filter (\( _, knob ) -> knob == Puzzle.TopKnob) allOtherKnobs)

                                Puzzle.RightKnob ->
                                    closestSnapPointAux
                                        pos
                                        (List.filter (\( _, knob ) -> knob == Puzzle.LeftKnob) allOtherKnobs)

                                Puzzle.TopKnob ->
                                    closestSnapPointAux
                                        pos
                                        (List.filter (\( _, knob ) -> knob == Puzzle.BottomKnob) allOtherKnobs)
                        )
                        currKnobs
                    )
                )
            )
        of
            Nothing ->
                Snap 0 (Position 0 0) Puzzle.LeftKnob

            Just ( pos, knob, dist ) ->
                Snap dist pos knob


otherKnobs : Int -> Model -> List ( Position, Puzzle.Knob )
otherKnobs id model =
    List.foldr
        (List.append)
        []
        (List.map
            (\( key, ( piece, pos, _ ) ) ->
                List.map
                    (\( pt, knob ) -> ( pointToPosition pt, knob ))
                    (Puzzle.knobPoints piece (positionToPoint pos))
            )
            (List.filter (\( id2, _ ) -> id2 /= id) (Dict.toList model.pieces))
        )


closestSnapPointAux : Position -> List ( Position, Puzzle.Knob ) -> ( Position, Puzzle.Knob, Float )
closestSnapPointAux position knobs =
    withDefault
        ( Position 0 0, Puzzle.LeftKnob, 0 )
        (minThird
            (List.map
                (\( pos, knob ) -> ( pos, knob, dist pos position ))
                knobs
            )
        )


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
third ( _, _, c ) =
    c


maxForeground : Model -> Int
maxForeground model =
    withDefault 0 (maximum (map (\( _, ( _, _, foregroundIndex ) ) -> foregroundIndex) (Dict.toList model.pieces)))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WinResize winSize ->
            ( { model | winSize = (log "WinResize" winSize) }, Cmd.none )

        DragStart id position ->
            let
                ( pieceType, pos, _ ) =
                    dragPosition id model
            in
                ( { model
                    | drag = Just (Drag id position position)
                    , pieces = Dict.update id (always (Just ( pieceType, pos, (maxForeground model) + 1 ))) model.pieces
                  }
                , Cmd.none
                )

        DragAt id position ->
            ( { model
                | drag =
                    Maybe.map
                        (\drag -> Drag drag.puzzleId drag.start position)
                        model.drag
                , snap =
                    (let
                        possibleSnap =
                            closestSnapPoint id model
                     in
                        if possibleSnap.dist < toFloat snapRadius then
                            Just possibleSnap
                        else
                            Nothing
                    )
              }
            , Cmd.none
            )

        DragEnd id _ ->
            let
                { dist, position, knob } =
                    closestSnapPoint id model

                ( piece, pos, foregroundIndex ) =
                    if dist < toFloat snapRadius then
                        let
                            ( piece2, _, foregroundIndex ) =
                                dragPosition id model
                        in
                            ( piece2, (pointToPosition (Puzzle.subPts (positionToPoint position) (Puzzle.knobOffset knob))), foregroundIndex )
                    else
                        dragPosition id model
            in
                ( { model
                    | drag = Nothing
                    , pieces = Dict.update id (always (Just ( piece, pos, foregroundIndex ))) model.pieces
                    , snap = Nothing
                  }
                , Cmd.none
                )

        UrlChange location ->
            ( model, Cmd.none )


dist : Position -> Position -> Float
dist p1 p2 =
    sqrt (toFloat ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2))



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just drag ->
            Sub.batch [ Mouse.moves (DragAt drag.puzzleId), Mouse.ups (DragEnd drag.puzzleId), Window.resizes WinResize ]

        Nothing ->
            Window.resizes WinResize



-- VIEW


snapRadius : Int
snapRadius =
    15


view : Model -> Html Msg
view model =
    svg [ width (toString model.winSize.width), height (toString model.winSize.height) ]
        (List.append
            [ defs []
                (backgroundImgs
                    model
                )
            ]
            --[ defs []
            --    [ pattern [ id "backgroundImg", patternUnits "userSpaceOnUse", width "100", height "100" ]
            --        [ image
            --            [ xlinkHref "spongebob.png"
            --            , x "10"
            --            , y "10"
            --            , width "100"
            --            , height "100"
            --            ]
            --            []
            --        ]
            --    ]
            --]
            (let
                snap =
                    (case model.drag of
                        Nothing ->
                            Nothing

                        Just drag ->
                            case model.snap of
                                Nothing ->
                                    Nothing

                                Just { dist, position, knob } ->
                                    Just ( position, drag.puzzleId, knob )
                    )
             in
                List.append
                    (puzzlePieces model snap)
                    (case snap of
                        Nothing ->
                            []

                        Just ( snapPoint, _, _ ) ->
                            [ circle
                                [ cx (toString snapPoint.x)
                                , cy (toString snapPoint.y)
                                , r "3"
                                , fill "yellow"
                                ]
                                []
                            ]
                    )
            )
        )


backgroundImgs : Model -> List (Svg Msg)
backgroundImgs model =
    (map
        (\( puzzleId, ( piece, _, _ ) ) ->
            Svg.pattern [ id ("backgroundImg" ++ (toString puzzleId)), patternUnits "userSpaceOnUse", width (toString model.winSize.width), height (toString model.winSize.height) ]
                [ Svg.image
                    (let
                        pos =
                            (case model.drag of
                                Nothing ->
                                    backgroundImgPosition
                                        (getPosition puzzleId model)
                                        puzzleId
                                        model

                                Just drag ->
                                    if drag.puzzleId == puzzleId then
                                        case model.snap of
                                            Nothing ->
                                                backgroundImgPosition
                                                    (getPosition puzzleId model)
                                                    puzzleId
                                                    model

                                            Just { dist, position, knob } ->
                                                backgroundImgPosition
                                                    (pointToPosition (Puzzle.subPts (positionToPoint position) (Puzzle.knobOffset knob)))
                                                    puzzleId
                                                    model
                                    else
                                        backgroundImgPosition
                                            (getPosition puzzleId model)
                                            puzzleId
                                            model
                            )
                     in
                        [ xlinkHref
                            (case model.imgUrl of
                                Nothing ->
                                    "./spongebob.png"

                                Just maybeUrl ->
                                    case maybeUrl of
                                        Nothing ->
                                            "./spongebob.png"

                                        Just url ->
                                            url
                            )
                        , preserveAspectRatio "none"
                        , patternUnits "userSpaceOnUse"
                        , width (toString (model.numCols * Puzzle.pieceWidth))
                        , height (toString (model.numRows * Puzzle.pieceHeight))
                        , x (toString pos.x)
                        , y (toString pos.y)
                        ]
                    )
                    []
                ]
        )
        (Dict.toList model.pieces)
    )


backgroundImgPosition : Position -> Int -> Model -> Position
backgroundImgPosition pos id model =
    let
        rowIndex =
            id // model.numCols

        colIndex =
            id % model.numCols

        offsetX =
            colIndex * Puzzle.pieceWidth

        offsetY =
            rowIndex * Puzzle.pieceHeight
    in
        Position (pos.x - offsetX) (pos.y - offsetY)


puzzlePieces : Model -> Maybe ( Position, Int, Puzzle.Knob ) -> List (Svg Msg)
puzzlePieces model snap =
    (map
        (\( id, ( piece, position, _ ) ) ->
            Puzzle.pieceSvg piece
                (case snap of
                    Nothing ->
                        (positionToPoint (getPosition id model))

                    Just ( snapPoint, id2, knob ) ->
                        if id == id2 then
                            Puzzle.subPts (positionToPoint snapPoint) (Puzzle.knobOffset knob)
                        else
                            (positionToPoint (getPosition id model))
                )
                [ onMouseDown id
                , SingleTouch.onStart (\coord -> DragStart id (coordsToPosition coord))
                , SingleTouch.onMove (\coord -> DragAt id (coordsToPosition coord))
                , SingleTouch.onEnd (\coord -> DragEnd id (coordsToPosition coord))
                , fill ("url(#backgroundImg" ++ (toString id) ++ ")")
                ]
        )
        (sortBy
            (\( _, ( _, _, foregroundIndex ) ) -> foregroundIndex)
            (Dict.toList model.pieces)
        )
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


getPosition : Int -> Model -> Position
getPosition id model =
    let
        ( _, result, _ ) =
            dragPosition id model
    in
        result


{-| dragPosition
TODO: the dict lookup is unnecessary and should be removed
-}
dragPosition : Int -> Model -> ( Puzzle.Piece, Position, Int )
dragPosition id { pieces, drag, winSize } =
    case drag of
        Nothing ->
            withDefault
                ( Puzzle.Center, Position 0 0, 0 )
                (Dict.get id pieces)

        Just { puzzleId, start, current } ->
            let
                piece =
                    withDefault
                        ( Puzzle.Center, Position 0 0, 0 )
                        (Dict.get id pieces)

                ( pieceType, position, foregroundIndex ) =
                    piece
            in
                if id == puzzleId then
                    ( pieceType
                    , Position
                        (position.x + current.x - start.x)
                        (position.y + current.y - start.y)
                    , foregroundIndex
                    )
                else
                    piece
