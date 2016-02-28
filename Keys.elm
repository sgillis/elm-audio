module Keys (keysToFreq) where

import Char exposing (KeyCode)
import Set


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
