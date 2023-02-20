module Counter exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--


import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Dict exposing (..)
import Maybe exposing (map)


-- MAIN
main = Browser.sandbox { init = init, update = update, view = view }



-- MODEL
type alias Model = { counters : Dict Int Int }

init : Model
init = { counters = Dict.empty }


-- UPDATE
type Msg
  = Increment Int
  | Decrement Int
  | NewCounter

update : Msg -> Model -> Model
update msg { counters } =
  case msg of
    NewCounter -> { counters = Dict.insert (Dict.size counters + 1) 0 counters }
    Decrement s -> { counters = Dict.update s (Maybe.map (\x -> x - 1)) counters }
    Increment s -> { counters = Dict.update s (Maybe.map (\x -> x + 1)) counters }

-- VIEW
view : Model -> Html Msg
view model =
  div [] [
    div [] [button [ onClick NewCounter ] [ text "add counter" ]]
    , div [] (Dict.values (Dict.map counterView model.counters))
    ]

counterView : Int -> Int -> Html Msg
counterView serial counter =
  div []
    [
      div [] [text ("serial: " ++ (String.fromInt serial))]
    , button [ onClick (Decrement serial)  ] [ text "-" ]
    , div [] [ text (String.fromInt counter) ]
    , button [ onClick (Increment serial) ] [ text "+" ]
    ]