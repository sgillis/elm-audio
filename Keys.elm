module Keys (Note(..), keysToNote, noteToFreq) where

import Char exposing (KeyCode)
import Set


type Note
  = C
  | Cs
  | D
  | Ds
  | E
  | F
  | Fs
  | G
  | Gs
  | A
  | As
  | B


keysToNote : Set.Set KeyCode -> List Note
keysToNote keys =
  let
    maybeFloats =
      List.map Char.fromCode (Set.toList keys)
        |> List.map charToNote

    maybeToList mx xs =
      case mx of
        Just x ->
          x :: xs

        Nothing ->
          xs
  in
    List.foldl maybeToList [] maybeFloats


noteToFreq : Note -> Float
noteToFreq note =
  case note of
    C ->
      261.626

    Cs ->
      277.183

    D ->
      293.665

    Ds ->
      311.127

    E ->
      329.628

    F ->
      349.228

    Fs ->
      369.994

    G ->
      391.995

    Gs ->
      415.305

    A ->
      440

    As ->
      466.164

    B ->
      493.883


charToNote : Char -> Maybe Note
charToNote char =
  case char of
    'A' ->
      Just C

    'W' ->
      Just Cs

    'S' ->
      Just D

    'E' ->
      Just Ds

    'D' ->
      Just E

    'F' ->
      Just F

    'T' ->
      Just Fs

    'G' ->
      Just G

    'Y' ->
      Just Gs

    'H' ->
      Just A

    'U' ->
      Just As

    'J' ->
      Just B

    _ ->
      Nothing
