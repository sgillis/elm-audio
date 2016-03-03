module WaveformKnob (Model, Action, init, toWaveform, update, view) where

import Html exposing (Html)
import Knob


type alias Model =
  Knob.Model


type Action
  = KnobAction Knob.Action


init : Model
init =
  Knob.init 4 True


update : Action -> Model -> Model
update act model =
  case act of
    KnobAction act' ->
      Knob.update act' model


view : Signal.Address Action -> Model -> Html
view address model =
  Knob.view (Signal.forwardTo address KnobAction) model


toWaveform : Model -> String
toWaveform model =
  case model.closest of
    68 ->
      "sine"

    136 ->
      "square"

    204 ->
      "sawtooth"

    272 ->
      "triangle"

    _ ->
      Debug.log "default waveform" "sine"
