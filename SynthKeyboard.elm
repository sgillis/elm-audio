module SynthKeyboard (Model, Action, init, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Keys exposing (Note(..))


type alias Model =
  {}


init : Model
init =
  {}


type Action
  = NoOp


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model


view : Signal.Address Action -> Model -> List Note -> Html
view address model notes =
  div
    [ class "keyboard" ]
    <| List.concat
        [ octave address model notes
        ]


octave : Signal.Address Action -> Model -> List Note -> List Html
octave address model notes =
  [ key address model notes C
  , key address model notes Cs
  , key address model notes D
  , key address model notes Ds
  , key address model notes E
  , key address model notes F
  , key address model notes Fs
  , key address model notes G
  , key address model notes Gs
  , key address model notes A
  , key address model notes As
  , key address model notes B
  ]


key : Signal.Address Action -> Model -> List Note -> Note -> Html
key address model notes note =
  let
    class' =
      if List.member note [ Cs, Ds, Fs, Gs, As ] then
        "key sharp"
      else
        "key"

    active =
      if List.member note notes then
        " active"
      else
        ""
  in
    div [ class <| class' ++ active ] []
