module HttpLoader exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Process exposing (sleep)
import Task exposing (perform)
import Http
import Platform.Cmd exposing (batch)
import Time

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type URLState = Idle | InProgress

type alias URL = { url : String, state : URLState, content : Maybe String, reqTracker : Maybe String }

init : () -> (URL, Cmd Msg)
init _ =
  ( {url = "", state = Idle, content = Nothing, reqTracker = Nothing}
  , Cmd.none
  )

type Msg =
     FillUrl String
   | Start
   | Cancel
   | UrlContent (Result Http.Error String)
   | ReqTracker Time.Posix

subscriptions : URL -> Sub Msg
subscriptions model = Sub.none

update : Msg -> URL -> (URL, Cmd Msg)
update msg model =
  case msg of
    FillUrl url -> ({ model | url = url }, Cmd.none)
    Start ->
     if not (String.isEmpty (.url model))
     then
      ( {model | state = InProgress}
      , perform ReqTracker Time.now
      )
      else (model, Cmd.none)
    Cancel ->
    -- request 1676974750184 has been cancelled
     ( {model | state = Idle, url = "", content = Maybe.map (\tr -> "request " ++ tr ++ " has been cancelled") (.reqTracker model) }
     , case .reqTracker model of
        Just tr -> Http.cancel tr
        _ -> Cmd.none
     )
    UrlContent result ->
      case result of
        Ok text ->
          ({model | content = Just text, state = Idle, url = ""}, Cmd.none)
        Err _ ->
          ({model | content = Nothing, state = Idle, url = ""}, Cmd.none)
    ReqTracker tm ->
      ( {model | reqTracker = Just (String.fromInt (Time.posixToMillis tm))}
      , Http.request
        { method = "GET"
        , headers = []
        , url = .url model
        , body = Http.emptyBody
        , expect = Http.expectString UrlContent
        , timeout = Nothing
        , tracker = Just (String.fromInt (Time.posixToMillis tm))
        }
      )

view : URL -> Html Msg
view { url, state, content, reqTracker } =
  div []
   [
      input [ type_ "text", placeholder "input URL here", onInput FillUrl ] []
    , if state == Idle then div [] [] else div [ style "color" "black" ] [ text ("id:" ++ Maybe.withDefault "" reqTracker ++  "download is in progress...") ]
    , button [ onClick Start, disabled (state == InProgress) ] [ text "download" ]
    , button [ onClick Cancel, disabled (state == Idle) ] [ text "cancel" ]
    , pre [] [ text
       (case content of
         Just s -> s
         _ -> "") ]
   ]
