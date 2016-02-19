module Audio (..) where

import Char exposing (..)
import Native.Audio
import Set
import String


createOscillator : Oscillator -> Int -> Int
createOscillator osc freq =
  Native.Audio.oscillator osc.detune freq


destroyOscillator : Int -> Int
destroyOscillator freq =
  Native.Audio.destroyOscillator freq


type alias Audio =
  { oscillators : List Oscillator }


init : List Int -> Audio
init oscs =
  { oscillators = List.map initOscillator oscs }


type alias Oscillator =
  { index : Int
  , notes : List Int
  , detune : Int
  }


initOscillator : Int -> Oscillator
initOscillator index =
  { index = index
  , notes = []
  , detune = 0
  }


view : Audio -> String
view audio =
  ""


update : Audio -> Audio -> Audio
update input playing =
  let
    updateOsc'' osc playing =
      if osc.index == playing.index then
        updateOscillator osc playing
      else
        osc

    updateOsc' playingOscs osc =
      List.map (updateOsc'' osc) playingOscs

    updateOsc oscs playingOscs =
      List.map (updateOsc' playingOscs) oscs

    updatedOscillators =
      updateOsc input.oscillators playing.oscillators
  in
    input


updateOscillator : Oscillator -> Oscillator -> Oscillator
updateOscillator input playing =
  let
    notes =
      Set.fromList input.notes

    oldNotes =
      Set.fromList playing.notes

    create =
      Set.toList <| Set.diff notes oldNotes

    destroy =
      Set.toList <| Set.diff oldNotes notes

    created =
      List.map (createOscillator input) create

    destroyed =
      List.map destroyOscillator destroy
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
