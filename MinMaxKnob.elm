module MinMaxKnob (Model, Action, init, update, view) where

import Html exposing (Html)
import Knob


type alias Model =
  Knob.Model


type Action
  = KnobAction Knob.Action


init : Model
init =
  Knob.init


update : Action -> Model -> Model
update act model =
  case act of
    KnobAction act' ->
      Knob.update act' model


view : Signal.Address Action -> Model -> Html
view address model =
  Knob.view (Signal.forwardTo address KnobAction) model
