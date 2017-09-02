port module Main exposing (..)

import Array exposing (Array)
import Debug exposing (log)
import Dict exposing (Dict)
import Html exposing (Html, button, div, h2, p, text)
import Html.Attributes exposing (style)
import Json.Decode as Decode
import List exposing (map, maximum, range, sortBy)
import Maybe exposing (withDefault)
import Mouse exposing (Position)
import Navigation exposing (Location)
import Puzzle exposing (Piece(..))
import Random
import Random.List exposing (shuffle)
import SingleTouch
import Svg exposing (Attribute, Svg, circle, defs, image, pattern, rect, svg)
import Svg.Attributes exposing (cx, cy, fill, height, id, patternUnits, preserveAspectRatio, r, width, x, xlinkHref, y, fontSize)
import Svg.Events exposing (on)
import Task
import Touch exposing (Coordinates)
import UrlParser exposing ((<?>), parsePath, s, stringParam)
import Window


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
    -- (piece type, piece postion, zIndex for foreground)
    { pieces : Dict Int ( Puzzle.Piece, Position, Int )
    , drag : Maybe Drag
    , winSize : WinSize
    , snap : Maybe Snap
    , location : Location
    , imgUrl : Maybe String
    , puzzleDimensions : Maybe { width : Int, height : Int }
    }


type alias Snap =
    { id : Int
    , dist : Float
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
        Dict.empty
        Nothing
        (WinSize 100 100)
        Nothing
        (log "location" location)
        (log "imgUrl" (imgUrlFromLocation location))
        (Just { width = 4, height = 3 })
    , Cmd.batch
        [ Task.perform WinResize Window.size
        , case imgUrlFromLocation location of
            Nothing ->
                getImageDimensions "http://garspace.com/puzzle/spongebob.png"

            Just imgUrl ->
                getImageDimensions imgUrl
        ]
    )


imgUrlFromLocation : Location -> Maybe String
imgUrlFromLocation location =
    withDefault Nothing ({- log "imgUrl" -} parsePath (s "puzzle" <?> stringParam "img") location)


piecesInit : Dict Int ( Puzzle.Piece, Position, Int )
piecesInit =
    Dict.empty


getPieceType : { x : Int, y : Int } -> { width : Int, height : Int } -> Puzzle.Piece
getPieceType { x, y } { width, height } =
    let
        foo =
            log "getPieceType" ()
    in
        if x == 0 && x == width - 1 then
            if y == 0 && y == height - 1 then
                Single
            else if y == 0 then
                Top
            else if y == height - 1 then
                Bottom
            else
                CenterVertical
        else if x == 0 then
            if y == 0 && y == height - 1 then
                Left
            else if y == 0 then
                TopLeft
            else if y == height - 1 then
                BottomLeft
            else
                MidLeft
        else if x == width - 1 then
            if y == 0 && y == height - 1 then
                Right
            else if y == 0 then
                TopRight
            else if y == height - 1 then
                BottomRight
            else
                MidRight
        else
            (if y == 0 && y == height - 1 then
                CenterHorizontal
             else if y == 0 then
                TopMid
             else if y == height - 1 then
                BottomMid
             else
                Center
            )


getPiecePositions : List { x : Int, y : Int } -> List Position
getPiecePositions coords =
    let
        foo =
            log "getPiecePositions" coords
    in
        List.map
            (\coord -> Position (coord.x * (Puzzle.pieceWidth + 25) + 50) (coord.y * (Puzzle.pieceHeight + 25) + 50))
            coords



-- UPDATE


type Msg
    = WinResize WinSize
    | DragStart Int Position
    | DragAt Int Position
    | DragEnd Int Position
    | UrlChange Location
    | PositionsGenerated (List Position)
    | ImageDimensions { width : Int, height : Int }


port getImageDimensions : String -> Cmd msg


{-| closestSnapPoint
TODO: This should return a Maybe (e.g. if there's only one puzzle piece on the board)
-}
closestSnapPoint : Int -> Model -> Snap
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
            minThird
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
        of
            Nothing ->
                Snap id 0 (Position 0 0) Puzzle.LeftKnob

            Just ( pos, knob, dist ) ->
                Snap id dist pos knob


otherKnobs : Int -> Model -> List ( Position, Puzzle.Knob )
otherKnobs id model =
    List.foldr
        List.append
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
                    if third curr < third accVal then
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
            ( {- log "WinResize model" -} { model | winSize = log "WinResize" winSize }, Cmd.none )

        DragStart id mousePosition ->
            let
                ( pieceType, pos, _ ) =
                    dragPosition id model
            in
                ( log "DragStart model"
                    { model
                        | drag = Just (Drag id mousePosition mousePosition)
                        , pieces = Dict.update id (always (Just ( pieceType, pos, maxForeground model + 1 ))) model.pieces

                        --, snap = Nothing
                    }
                , Cmd.none
                )

        DragAt _ mousePosition ->
            let
                dragPuzzleId =
                    log "model.drag.puzzleId" (withDefault -1 (Maybe.map (.puzzleId) model.drag))
            in
                ( {- log "DragAt model" -}
                  { model
                    | drag =
                        Maybe.map
                            (\drag -> Drag drag.puzzleId drag.start mousePosition)
                            model.drag
                    , snap =
                        let
                            possibleSnap =
                                closestSnapPoint dragPuzzleId model
                        in
                            if possibleSnap.dist < toFloat snapRadius then
                                Just possibleSnap
                            else
                                Nothing
                  }
                , Cmd.none
                )

        DragEnd id _ ->
            let
                dragPuzzleId =
                    log "model.drag.puzzleId" (withDefault -1 (Maybe.map (.puzzleId) model.drag))

                { dist, position, knob } =
                    closestSnapPoint dragPuzzleId model

                ( piece, pos, foregroundIndex ) =
                    if dist < toFloat snapRadius then
                        let
                            ( piece2, _, foregroundIndex ) =
                                log "DragEnd snap active" dragPosition dragPuzzleId model
                        in
                            ( piece2, pointToPosition (Puzzle.subPts (positionToPoint position) (Puzzle.knobOffset knob)), foregroundIndex )
                    else
                        log "DragEnd dragPosition" (dragPosition dragPuzzleId model)
            in
                ( log "DragEnd model"
                    { model
                        | drag = Nothing
                        , pieces =
                            Dict.update
                                (log "DragEnd dragPuzzleId" dragPuzzleId)
                                (always (Just ( piece, log "DragEnd update pos" pos, foregroundIndex )))
                                model.pieces
                        , snap = Nothing
                    }
                , Cmd.none
                )

        UrlChange location ->
            ( log "UrlChange model" model, Cmd.none )

        PositionsGenerated positions ->
            let
                foo =
                    log "handling PositionsGenerated" ()
            in
                ( { model | pieces = generatePieceDict positions (withDefault { width = 5, height = 5 } model.puzzleDimensions) model }, Cmd.none )

        ImageDimensions { width, height } ->
            -- Kick off PositionsGenerated cmd here
            let
                maxDim =
                    5

                pieceWidth =
                    log "pieceWidth"
                        (if width > height then
                            maxDim
                         else if maxDim * (toFloat width / toFloat height) >= 1 then
                            round (maxDim * (toFloat width / toFloat height))
                         else
                            1
                        )

                pieceHeight =
                    log "pieceHeight"
                        (if height > width then
                            maxDim
                         else if maxDim * (toFloat height / toFloat width) >= 1 then
                            round (maxDim * (toFloat height / toFloat width))
                         else
                            1
                        )
            in
                ( { model
                    | {- pieces =
                             generatePieceDict
                                 (getPiecePositions
                                     (generatePieceCoords
                                         { width = pieceWidth, height = pieceHeight }
                                     )
                                 )
                                 { width = pieceWidth, height = pieceHeight }
                                 model
                         ,
                      -}
                      puzzleDimensions = Just { width = pieceWidth, height = pieceHeight }
                  }
                , {- Cmd.none -}
                  Random.generate
                    PositionsGenerated
                    (shuffle
                        (getPiecePositions
                            (generatePieceCoords
                                { width = pieceWidth, height = pieceHeight }
                            )
                        )
                    )
                )


generatePieceDict : List Position -> { width : Int, height : Int } -> Model -> Dict Int ( Puzzle.Piece, Position, Int )
generatePieceDict positions dim model =
    let
        positionsArr =
            Array.fromList positions

        --dim =
        --    log "dim" (withDefault { width = 0, height = 0 } model.puzzleDimensions)
    in
        List.foldr
            (\{ x, y } dict ->
                let
                    id =
                        x + (y * dim.width)
                in
                    Dict.insert
                        id
                        ( getPieceType { x = x, y = y } { width = dim.width, height = dim.height }
                        , withDefault (Position 0 0) (Array.get id positionsArr)
                        , id
                        )
                        dict
            )
            Dict.empty
            (generatePieceCoords dim)


generatePieceCoords : { width : Int, height : Int } -> List { x : Int, y : Int }
generatePieceCoords { width, height } =
    let
        foo =
            log "generatePieceCoords" { width = width, height = height }
    in
        List.concat
            (List.map
                (\x ->
                    List.map
                        (\y -> { x = x, y = y })
                        (range 0 (height - 1))
                )
                (range 0 (width - 1))
            )


dist : Position -> Position -> Float
dist p1 p2 =
    sqrt (toFloat ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2))



-- SUBSCRIPTIONS


port imageDimensions : ({ width : Int, height : Int } -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        (List.append
            [ Window.resizes WinResize, imageDimensions ImageDimensions ]
            (case model.drag of
                Just drag ->
                    [ Mouse.moves (DragAt drag.puzzleId), Mouse.ups (DragEnd drag.puzzleId), Window.resizes WinResize ]

                Nothing ->
                    []
            )
        )



-- VIEW


snapRadius : Int
snapRadius =
    15


view : Model -> Html Msg
view model =
    div [ style [ ( "background", "#f1f1f1" ) ] ]
        [ h2 [ style [ ( "margin", "0" ), ( "backgroundColor", "#d4d2d2" ), ( "padding", "10px 50px" ) ] ] [ text "Complete the puzzle!" ]
        , svg
            [ width (toString (model.winSize.width - 20))
            , Html.Attributes.draggable "false"
            , Svg.Attributes.style "user-drag: none; -moz-user-select: none; -webkit-user-drag: none;"
            , height (toString (model.winSize.height - 40))
            ]
            (List.append
                [ defs
                    []
                    (backgroundImgs
                        model
                    )
                ]
                (let
                    snap =
                        case model.drag of
                            Nothing ->
                                Nothing

                            Just drag ->
                                case model.snap of
                                    Nothing ->
                                        Nothing

                                    Just { dist, position, knob } ->
                                        Just ( position, drag.puzzleId, knob )
                 in
                    List.append
                        (puzzlePieces model model.snap)
                        (case model.snap of
                            Nothing ->
                                []

                            Just snap ->
                                [ circle
                                    [ cx (toString snap.position.x)
                                    , cy (toString snap.position.y)
                                    , r "3"
                                    , fill "yellow"
                                    ]
                                    []
                                ]
                        )
                )
            )
        ]


backgroundImgs : Model -> List (Svg Msg)
backgroundImgs model =
    map
        (\( puzzleId, _ ) ->
            Svg.pattern
                [ id ("backgroundImg" ++ toString puzzleId)
                , patternUnits "userSpaceOnUse"
                , width (toString model.winSize.width)
                , height (toString model.winSize.height)
                ]
                (let
                    pos =
                        case model.drag of
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

                                        Just snap ->
                                            if puzzleId == snap.id then
                                                backgroundImgPosition
                                                    (pointToPosition (Puzzle.subPts (positionToPoint snap.position) (Puzzle.knobOffset snap.knob)))
                                                    puzzleId
                                                    model
                                            else
                                                backgroundImgPosition
                                                    (getPosition puzzleId model)
                                                    puzzleId
                                                    model
                                else
                                    backgroundImgPosition
                                        (getPosition puzzleId model)
                                        puzzleId
                                        model
                 in
                    [ Svg.rect
                        [ fill "#fff"
                        , width "1000"
                        , height "1000"
                        , x (toString pos.x)
                        , y (toString pos.y)
                        ]
                        []
                    , Svg.image
                        [ xlinkHref (backgroundImgUrl model)
                        , preserveAspectRatio "none"
                        , patternUnits "userSpaceOnUse"
                        , width (toString ((withDefault { width = 5, height = 5 } model.puzzleDimensions).width * Puzzle.pieceWidth))
                        , height (toString ((withDefault { width = 5, height = 5 } model.puzzleDimensions).height * Puzzle.pieceHeight))
                        , x (toString pos.x)
                        , y (toString pos.y)
                        ]
                        []

                    --, Svg.text_
                    --    [ fontSize "22px"
                    --    , x (toString ((getPosition puzzleId model).x + 50))
                    --    , y (toString ((getPosition puzzleId model).y + 50))
                    --    ]
                    --    [ Svg.text (toString puzzleId) ]
                    ]
                )
        )
        (Dict.toList model.pieces)


backgroundImgUrl : Model -> String
backgroundImgUrl model =
    withDefault "http://garspace.com/puzzle/spongebob.png" model.imgUrl


{-| This relies on the fact that piece id can determine its x, y coord (i.e. id of 0 maps to
(0, 0) which is a top left piece)
-}
backgroundImgPosition : Position -> Int -> Model -> Position
backgroundImgPosition pos id model =
    let
        rowIndex =
            id // (withDefault { width = 5, height = 5 } model.puzzleDimensions).width

        colIndex =
            id % (withDefault { width = 5, height = 5 } model.puzzleDimensions).width

        offsetX =
            colIndex * Puzzle.pieceWidth

        offsetY =
            rowIndex * Puzzle.pieceHeight
    in
        Position (pos.x - offsetX) (pos.y - offsetY)



--{ id : Int , dist : Float , position : Position , knob : Puzzle.Knob }


puzzlePieces : Model -> Maybe Snap {- ( Position, Int, Puzzle.Knob ) -} -> List (Svg Msg)
puzzlePieces model maybeSnap =
    map
        (\( id, ( piece, position, _ ) ) ->
            Puzzle.pieceSvg piece
                (case maybeSnap of
                    Nothing ->
                        positionToPoint (getPosition id model)

                    Just snap ->
                        if id == snap.id then
                            Puzzle.subPts (positionToPoint snap.position) (Puzzle.knobOffset snap.knob)
                        else
                            positionToPoint (getPosition id model)
                )
                [ onMouseDown id
                , SingleTouch.onStart (\coord -> DragStart id (coordsToPosition coord))
                , SingleTouch.onMove (\coord -> DragAt id (coordsToPosition coord))
                , SingleTouch.onEnd (\coord -> DragEnd id (coordsToPosition coord))
                , fill ("url(#backgroundImg" ++ toString id ++ ")")
                ]
        )
        (sortBy
            (\( _, ( _, _, foregroundIndex ) ) -> foregroundIndex)
            (Dict.toList model.pieces)
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
