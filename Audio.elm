module Audio (..) where

import Char exposing (..)
import Native.Audio
import Set


createOscillator : Oscillator -> Int -> Int
createOscillator osc freq =
  Native.Audio.oscillator osc.index osc.detune freq


destroyOscillator : Oscillator -> Int -> Int
destroyOscillator osc freq =
  Native.Audio.destroyOscillator osc.index freq


setOscillatorDetune : Oscillator -> Int -> Int
setOscillatorDetune osc detune =
  Native.Audio.setOscillatorDetune osc.index detune


type alias Audio =
  { oscillators : List Oscillator
  , notes : List Int
  }


init : Audio
init =
  { oscillators = []
  , notes = []
  }


type alias Oscillator =
  { index : Int
  , detune : Int
  }


initOscillator : Int -> Oscillator
initOscillator index =
  { index = index
  , detune = 0
  }


view : Audio -> String
view audio =
  ""


update : Audio -> Audio -> Audio
update input playing =
  let
    updatedOscillators =
      List.map (updateNotes input.notes playing.notes) input.oscillators

    updatedOscillators' =
      List.map updateDetune updatedOscillators
  in
    { input
      | notes = input.notes
      , oscillators = updatedOscillators'
    }


updateNotes : List Int -> List Int -> Oscillator -> Oscillator
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
    oscillator


updateDetune : Oscillator -> Oscillator
updateDetune input =
  let
    _ =
      setOscillatorDetune input input.detune
  in
    input



-- Helper functions


keysToFreq : Set.Set KeyCode -> List Int
keysToFreq keys =
  let
    maybeInts =
      List.map Char.fromCode (Set.toList keys)
        |> List.map charToFreq

    maybeToList mx xs =
      case mx of
        Just x ->
          x :: xs

        Nothing ->
          xs
  in
    List.foldl maybeToList [] maybeInts


charToFreq : Char -> Maybe Int
charToFreq char =
  case char of
    'A' ->
      Just 440

    'W' ->
      Just 466

    'S' ->
      Just 494

    'D' ->
      Just 523

    'R' ->
      Just 554

    'F' ->
      Just 587

    'T' ->
      Just 622

    'G' ->
      Just 659

    'H' ->
      Just 698

    'U' ->
      Just 740

    'J' ->
      Just 784

    'I' ->
      Just 831

    _ ->
      Nothing
