module Main exposing (..)

import Html exposing (Html, div, button)
import Svg exposing (svg, circle, Attribute, rect)
import Svg.Attributes exposing (..)
import Svg.Events exposing (on)
import Debug exposing (log)
import Json.Decode as Decode
import Mouse exposing (Position)
import Window
import Task
import Touch exposing (Coordinates)
import SingleTouch


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
    { position : Position
    , drag : Maybe Drag
    , winSize : WinSize
    , close : Bool
    }


type alias Drag =
    { start : Position
    , current : Position
    }


type alias WinSize =
    { width : Int
    , height : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Position 105 105) Nothing (WinSize 100 100) False, Task.perform WinResize Window.size )



-- UPDATE


type Msg
    = WinResize WinSize
    | DragStart Position
    | DragAt Position
    | DragEnd Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WinResize winSize ->
            ( { model | winSize = (log "WinResize" winSize) }, Cmd.none )

        DragStart position ->
            ( { model | drag = Just (Drag position position) }, Cmd.none )

        DragAt position ->
            ( { model | drag = Maybe.map (\drag -> Drag drag.start position) model.drag, close = log "close" ((dist snapPoint (getPosition model)) < toFloat snapRadius) }, Cmd.none )

        DragEnd _ ->
            ( { model
                | drag = Nothing
                , position =
                    log "DragEnd"
                        (if model.close then
                            snapPoint
                         else
                            getPosition model
                        )
              }
            , Cmd.none
            )


dist : Position -> Position -> Float
dist p1 p2 =
    sqrt (toFloat ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2))



--dist
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just drag ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd, Window.resizes WinResize ]

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
    let
        position =
            getPosition model
    in
        svg [ color "red", display "block", width (toString model.winSize.width), height (toString model.winSize.height) ]
            [ circle
                [ onMouseDown
                , SingleTouch.onStart (\coord -> DragStart (coordsToPosition (log "touch coord" coord)))
                , SingleTouch.onMove (\coord -> DragAt (coordsToPosition (log "touch coord" coord)))
                , SingleTouch.onEnd (\coord -> DragEnd (coordsToPosition (log "touch coord" coord)))
                , Svg.Attributes.cursor "move"
                , if model.close then
                    cx (toString snapPoint.x)
                  else
                    cx (toString position.x)
                , if model.close then
                    cy (toString snapPoint.y)
                  else
                    cy (toString position.y)
                , r "25%"
                , fill "#0B79CE"
                ]
                []
            , circle
                [ if model.close then
                    cx (toString snapPoint.x)
                  else
                    cx (toString position.x)
                , if model.close then
                    cy (toString snapPoint.y)
                  else
                    cy (toString position.y)
                , r (toString snapGuideRadius)
                , fill "#000"
                ]
                []
            , Svg.text_
                [ fontSize "22px"
                , if model.close then
                    x (toString snapPoint.x)
                  else
                    x (toString position.x)
                , if model.close then
                    y (toString (snapPoint.y + 100))
                  else
                    y (toString (position.y + 100))
                ]
                [ Svg.text "Drag to gray circle" ]
            , circle
                [ cx (toString snapPoint.x)
                , cy (toString snapPoint.y)
                , r (toString (snapRadius - snapGuideRadius))
                , fill "rgba(153, 153, 153, 0.75)"
                ]
                []

            --polygon [ stroke "#29e"
            --, strokeWidth "20"
            --, strokeLinejoin "round"
            --, fill "none"
            --, points "260.8676170428898331,219.7770876399966369 297.8074659814675442,334.6204278639912673 200.0000000000000000,264.0000000000000000 102.1925340185324700,334.6204278639912673 139.1323829571101669,219.7770876399966369 41.7441956884864567,148.5795721360087214 162.3817438532817334,148.2229123600033631 200.0000000000000284,33.5999999999999943 237.6182561467182950,148.2229123600033631 358.2558043115135433,148.5795721360087498"
            --] []
            ]


coordsToPosition : Coordinates -> Position
coordsToPosition coords =
    Position (truncate coords.clientX) (truncate coords.clientY)


onMouseDown : Attribute Msg
onMouseDown =
    on "mousedown" (Decode.map DragStart Mouse.position)


getPosition : Model -> Position
getPosition { position, drag, winSize } =
    case drag of
        Nothing ->
            position

        Just { start, current } ->
            Position
                (position.x + current.x - start.x)
                (position.y + current.y - start.y)
