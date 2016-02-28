module Main (main) where

import Audio exposing (Audio, Oscillator)
import Effects exposing (Effects)
import Html exposing (..)
import Keyboard
import Keys
import MinMaxKnob
import WaveformKnob
import Signal exposing (Signal)
import StartApp
import Task


type alias Model =
  { audio : Audio
  , detuneKnob : MinMaxKnob.Model
  , waveformSelector : WaveformKnob.Model
  }


type Action
  = NoOp
  | AudioUpdate Audio
  | DetuneKnobAction MinMaxKnob.Action
  | WaveformSelectorAction WaveformKnob.Action


init : ( Model, Effects Action )
init =
  ( { audio = Audio.init
    , detuneKnob = MinMaxKnob.init
    , waveformSelector = WaveformKnob.init
    }
  , Effects.none
  )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    NoOp ->
      ( model, Effects.none )

    AudioUpdate audio ->
      let
        ( audio', fx ) =
          Audio.update audio model.audio
      in
        ( { model | audio = audio' }
        , Effects.map (\_ -> NoOp) fx
        )

    DetuneKnobAction act ->
      let
        knob' =
          MinMaxKnob.update act model.detuneKnob
      in
        ( { model | detuneKnob = knob' }
        , Effects.none
        )

    WaveformSelectorAction act ->
      let
        knob' =
          WaveformKnob.update act model.waveformSelector
      in
        ( { model | waveformSelector = knob' }
        , Effects.none
        )


view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ MinMaxKnob.view
        (Signal.forwardTo address DetuneKnobAction)
        model.detuneKnob
    , WaveformKnob.view
        (Signal.forwardTo address WaveformSelectorAction)
        model.waveformSelector
    ]


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =
        [ Signal.map AudioUpdate audioInput ]
    }


main : Signal Html
main =
  app.html


model : Signal Model
model =
  app.model


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks


port receivedModel : Signal Model
port sendModel : Signal Model
port sendModel =
  model



-- AUDIO SIGNALS


audioInput : Signal Audio
audioInput =
  (Signal.constant <| Audio.init)
    |> Signal.map2
        (\freq osc -> { osc | notes = freq })
        frequencies
    |> Signal.map2
        (\osc audio -> { audio | oscillators = osc :: audio.oscillators })
        oscillator1
    |> Signal.map2
        (\osc audio -> { audio | oscillators = osc :: audio.oscillators })
        oscillator2


oscillator1 : Signal Oscillator
oscillator1 =
  (Signal.constant <| Audio.initOscillator 1)
    |> Signal.map2
        (\detune osc -> { osc | detune = detune })
        (Signal.constant 0)


oscillator2 : Signal Oscillator
oscillator2 =
  (Signal.constant <| Audio.initOscillator 2)
    |> Signal.map2
        (\detune osc -> { osc | detune = detune })
        (Signal.dropRepeats
          (Signal.map (.angle << .detuneKnob) receivedModel)
        )


frequencies : Signal (List Int)
frequencies =
  Signal.map Keys.keysToFreq Keyboard.keysDown
