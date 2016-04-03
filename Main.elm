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
import SynthKeyboard
import Task


type alias Model =
  { audio : Audio
  , notes : List Keys.Note
  , detuneKnob : MinMaxKnob.Model
  , waveformSelector : WaveformKnob.Model
  , keyboard : SynthKeyboard.Model
  }


type alias Feed =
  { detuneKnob : MinMaxKnob.Model
  , waveformSelector : WaveformKnob.Model
  , notes : List Float
  }


modelToFeed : Model -> Feed
modelToFeed model =
  { detuneKnob = model.detuneKnob
  , waveformSelector = model.waveformSelector
  , notes = List.map Keys.noteToFreq model.notes
  }


type Action
  = NoOp
  | AudioUpdate Audio.Action
  | SetNotes (List Keys.Note)
  | DetuneKnobAction MinMaxKnob.Action
  | WaveformSelectorAction WaveformKnob.Action
  | KeyboardAction SynthKeyboard.Action


init : ( Model, Effects Action )
init =
  ( { audio = Audio.init
    , notes = []
    , detuneKnob = MinMaxKnob.init
    , waveformSelector = WaveformKnob.init
    , keyboard = SynthKeyboard.init
    }
  , Effects.map AudioUpdate <| Effects.tick Audio.Tick
  )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    NoOp ->
      ( model, Effects.none )

    AudioUpdate action' ->
      let
        ( audio', fx ) =
          Audio.update action' model.audio
      in
        ( { model | audio = audio' }
        , Effects.map AudioUpdate fx
        )

    SetNotes notes ->
      ( { model | notes = notes }
      , Effects.none
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

    KeyboardAction act ->
      let
        keyboard' =
          SynthKeyboard.update act model.keyboard
      in
        ( { model | keyboard = keyboard' }
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
    , SynthKeyboard.view
        (Signal.forwardTo address KeyboardAction)
        model.keyboard
        model.notes
    ]


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =
        [ Signal.map AudioUpdate audioInput
        , Signal.map SetNotes
            <| Signal.map Keys.keysToNote Keyboard.keysDown
        ]
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


port receivedFeed : Signal Feed


port sendFeed : Signal Feed
port sendFeed =
  Signal.map modelToFeed model



-- AUDIO SIGNALS


audioInput : Signal Audio.Action
audioInput =
  Signal.map audioInput' (Signal.dropRepeats receivedFeed)
    |> Signal.map Audio.FeedUpdate


audioInput' : Feed -> Audio
audioInput' feed =
  Audio.init
    |> (\freq osc -> { osc | notes = freq })
        feed.notes
    |> (\osc audio -> { audio | oscillators = osc :: audio.oscillators })
        (oscillator1 feed)
    |> (\osc audio -> { audio | oscillators = osc :: audio.oscillators })
        (oscillator2 feed)


oscillator1 : Feed -> Oscillator
oscillator1 feed =
  Audio.initOscillator 1
    |> (\detune waveform osc ->
          { osc
            | detune = detune
            , waveform = waveform
          }
       )
        0
        (WaveformKnob.toWaveform feed.waveformSelector)


oscillator2 : Feed -> Oscillator
oscillator2 feed =
  Audio.initOscillator 2
    |> (\detune waveform osc ->
          { osc
            | detune = detune
            , waveform = waveform
          }
       )
        feed.detuneKnob.angle
        (WaveformKnob.toWaveform feed.waveformSelector)


notes : Signal (List Keys.Note)
notes =
  Signal.map Keys.keysToNote Keyboard.keysDown
