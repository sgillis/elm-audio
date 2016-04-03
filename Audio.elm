module Audio (..) where

import Effects exposing (Effects)
import Native.Audio
import Set
import Time exposing (Time)


createOscillator : Oscillator -> Float -> Effects ()
createOscillator osc freq =
  Native.Audio.oscillator osc.index osc.waveform osc.detune freq
    |> Effects.task


destroyOscillator : Oscillator -> Float -> Effects ()
destroyOscillator osc freq =
  Native.Audio.destroyOscillator osc.index freq
    |> Effects.task


setOscillatorDetune : Oscillator -> Int -> Effects ()
setOscillatorDetune osc detune =
  Native.Audio.setOscillatorDetune osc.index detune
    |> Effects.task


setOscillatorGain : Oscillator -> Float -> Effects ()
setOscillatorGain osc gain =
  Native.Audio.setOscillatorGain osc.index gain
    |> Effects.task


type alias Audio =
  { oscillators : List Oscillator
  , notes : List Float
  }


init : Audio
init =
  { oscillators = []
  , notes = []
  }


type alias Oscillator =
  { index : Int
  , detune : Int
  , waveform : String
  , attack : Int
  , time : ElapsedTime
  }


initOscillator : Int -> Oscillator
initOscillator index =
  { index = index
  , detune = 0
  , waveform = "sine"
  , attack = 0
  , time = Nothing
  }


type alias ElapsedTime =
  Maybe { elapsedTime : Time, prevTime : Time }



-- MAILBOX


type Action
  = NoOp
  | FeedUpdate Audio
  | Tick Time


mailbox : Signal.Mailbox Action
mailbox =
  Signal.mailbox NoOp


actions : Signal Action
actions =
  mailbox.signal



-- UPDATE


update : Action -> Audio -> ( Audio, Effects Action )
update action audio =
  case action of
    NoOp ->
      ( audio, Effects.none )

    FeedUpdate feed ->
      let
        ( audio', fx ) =
          update' feed audio
      in
        ( audio', Effects.map (\_ -> NoOp) fx )

    Tick time ->
      ( audio, Effects.tick Tick )


update' : Audio -> Audio -> ( Audio, Effects () )
update' input playing =
  let
    ( updatedOscillators, fx ) =
      List.map (updateNotes input.notes playing.notes) input.oscillators
        |> List.unzip

    ( updatedOscillators', fx' ) =
      List.map updateDetune updatedOscillators
        |> List.unzip

    ( updatedOscillators'', fx'' ) =
      List.map updateADSR updatedOscillators'
        |> List.unzip
  in
    ( { input
        | notes = input.notes
        , oscillators = updatedOscillators''
      }
    , Effects.batch
        <| List.concat [ fx, fx', fx'' ]
    )


updateNotes : List Float -> List Float -> Oscillator -> ( Oscillator, Effects () )
updateNotes notes' oldNotes' oscillator =
  let
    notes =
      Set.fromList notes'

    oldNotes =
      Set.fromList oldNotes'

    create =
      Set.toList <| Set.diff notes oldNotes

    destroy =
      Set.toList <| Set.diff oldNotes notes

    created =
      List.map (createOscillator oscillator) create

    destroyed =
      List.map (destroyOscillator oscillator) destroy
  in
    ( oscillator, Effects.batch <| List.concat [ created, destroyed ] )


updateDetune : Oscillator -> ( Oscillator, Effects () )
updateDetune input =
  let
    detune =
      setOscillatorDetune input input.detune
  in
    ( input, detune )


updateADSR : Oscillator -> ( Oscillator, Effects () )
updateADSR input =
  let
    gain =
      setOscillatorGain input 0.5
  in
    ( input, gain )
