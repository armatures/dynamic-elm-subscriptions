module Main exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

import Browser
import Browser.Events exposing (onKeyUp)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
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
    , listenToKeys : Bool
    , lastPressedKey : Maybe String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key url False Nothing, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | KeyUp String


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
                        , listenToKeys = String.contains "keyboard" (Url.toString url)
                    }
            in
            ( newModel
            , Cmd.none
            )

        KeyUp keyName ->
            ( { model | lastPressedKey = Just keyName }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    --replace this with the next line, and it works
    if model.listenToKeys then
        --    if True then
        onKeyUp
            (Decode.field "key" Decode.string
                |> Decode.map KeyUp
            )

    else
        Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        lastPressedKey =
            case model.lastPressedKey of
                Nothing ->
                    []

                Just key ->
                    [ text key ]

        listeningForKeys =
            if model.listenToKeys then
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
        ]
            ++ lastPressedKey
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
