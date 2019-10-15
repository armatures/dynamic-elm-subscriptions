module Main exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

import Browser
import Browser.Events exposing (onKeyUp)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Maybe exposing (withDefault)
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , lastPressedKey : Maybe String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url Nothing, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | KeyUp String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newModel =
                    { model
                        | url = url
                    }
            in
            ( newModel
            , Cmd.none
            )

        KeyUp keyName ->
            ( { model | lastPressedKey = Just keyName }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


listenForKeys url =
    String.contains "keyboard" (Url.toString url)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        mapMsg =
            if listenForKeys model.url then
                KeyUp

            else
                always NoOp
    in
    onKeyUp
        (Decode.field "key" Decode.string
            |> Decode.map mapMsg
        )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        lastPressedKey : String
        lastPressedKey =
            model.lastPressedKey
                |> withDefault ""

        listeningForKeys =
            if listenForKeys model.url then
                "listening for keyUp event"

            else
                "Not listening for keyUp"
    in
    { title = "URL Interceptor"
    , body =
        [ text "The current URL is: "
        , b [] [ text (Url.toString model.url) ]
        , ul []
            [ viewLink "/home"
            , viewLink "/profile"
            , viewLink "/reviews/the-century-of-the-self"
            , viewLink "/reviews/public-opinion"
            , viewLink "/reviews/shah-of-shahs"
            , viewLink "keyboard"
            ]
        , text listeningForKeys
        , div [] [ text <| "last pressed key: " ++ lastPressedKey ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
