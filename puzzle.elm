module Main exposing (..)

import Html exposing (Html, div, button)
import Svg exposing (svg, circle, Attribute)
import Svg.Attributes exposing (..)
import Svg.Events exposing (on)
import Debug exposing (log)
import Json.Decode as Decode
import Mouse exposing (Position)
import Window
import Task


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
    ( Model (Position 55 55) Nothing (WinSize 100 100), Task.perform WinResize Window.size )



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
            ( { model | drag = Maybe.map (\drag -> Drag drag.start position) model.drag }, Cmd.none )

        DragEnd position ->
            ( { model | drag = Nothing, position = getPosition model }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just drag ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd, Window.resizes WinResize ]

        Nothing ->
            Window.resizes WinResize



-- VIEW


view : Model -> Html Msg
view model =
    let
        position =
            getPosition model
    in
        svg [ color "red", display "block", width (toString model.winSize.width), height (toString model.winSize.height) ]
            [ circle
                [ onMouseDown
                , Svg.Attributes.cursor "move"
                , cx (toString position.x)
                , cy (toString position.y)
                , r "50"
                , fill "#0B79CE"
                ]
                []
            , circle
                [ cx "50%"
                , cy "50%"
                , r "10"
                , fill "#999"
                ]
                []

            --polygon [ stroke "#29e"
            --, strokeWidth "20"
            --, strokeLinejoin "round"
            --, fill "none"
            --, points "260.8676170428898331,219.7770876399966369 297.8074659814675442,334.6204278639912673 200.0000000000000000,264.0000000000000000 102.1925340185324700,334.6204278639912673 139.1323829571101669,219.7770876399966369 41.7441956884864567,148.5795721360087214 162.3817438532817334,148.2229123600033631 200.0000000000000284,33.5999999999999943 237.6182561467182950,148.2229123600033631 358.2558043115135433,148.5795721360087498"
            --] []
            ]


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
