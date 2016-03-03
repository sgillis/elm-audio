module Knob (Model, Action, init, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import List.Extra


-- Taken from http://codepen.io/blucube/pen/cudAz


type alias Model =
  { angle : Int
  , steps : Int
  , snap : Bool
  , closest : Int
  }


init : Int -> Bool -> Model
init steps snap =
  { angle = 0
  , steps = steps
  , snap = snap
  , closest = round <| toFloat 270 / toFloat steps
  }


type Action
  = NoOp
  | Scroll Int
  | SetClosest


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Scroll x ->
      if x > 0 then
        update SetClosest { model | angle = Basics.min 270 <| model.angle + 2 }
      else
        update SetClosest { model | angle = Basics.max 0 <| model.angle - 2 }

    SetClosest ->
      let
        step =
          toFloat 270 / toFloat model.steps

        min =
          round <| step / 2

        closest =
          (min
            + closestStep
                (min)
                (round step)
                (toFloat (model.angle - (round (toFloat min / 2))))
          )
      in
        { model | closest = closest }


view : Signal.Address Action -> Model -> Html
view address model =
  let
    active =
      round <| (toFloat model.angle) / (toFloat 270 / toFloat model.steps)

    inactive =
      model.steps - active

    tickDegreeStep =
      toFloat 270 / toFloat model.steps

    tickDegreeOffset =
      round <| tickDegreeStep / 2

    tickDegrees =
      (List.repeat model.steps 0)
        |> List.indexedMap
            (\n _ ->
              tickDegreeOffset
                + (round <| toFloat (-135) + toFloat n * tickDegreeStep)
            )

    tickActive =
      if not model.snap then
        List.repeat active True
          ++ List.repeat inactive False
      else
        let
          x' x =
            x - (model.closest - 135 - tickDegreeOffset)
        in
          List.map (\x -> -2 <= x' x && x' x <= 2) tickDegrees

    tickList =
      List.Extra.zip tickDegrees tickActive

    knobAngle =
      if not model.snap then
        model.angle
      else
        Basics.min
          (model.closest - tickDegreeOffset)
          (270 - tickDegreeOffset)
  in
    div
      [ class "knob-surround" ]
      [ div
          [ class "knob"
          , style <| knobStyle knobAngle
          , onWithOptions
              "mousewheel"
              { stopPropagation = True
              , preventDefault = True
              }
              scrollDecoder
              (\x -> Signal.message address (Scroll x))
          ]
          []
      , if not model.snap then
          span [ class "min" ] [ text "Min" ]
        else
          div [] []
      , if not model.snap then
          span [ class "max" ] [ text "Max" ]
        else
          div [] []
      , div
          [ class "ticks" ]
          (List.map tick tickList)
      ]


tick : ( Int, Bool ) -> Html
tick ( degrees, active ) =
  let
    degrees' =
      toString degrees
  in
    div
      [ classList
          [ ( "tick", True )
          , ( "activetick", active )
          ]
      , Html.Attributes.style
          [ ( "-webkit-transform", "rotate(" ++ degrees' ++ "deg)" )
          , ( "-moz-transform", "rotate(" ++ degrees' ++ "deg)" )
          , ( "-o-transform", "rotate(" ++ degrees' ++ "deg)" )
          , ( "-ms-transform", "rotate(" ++ degrees' ++ "deg)" )
          , ( "transform", "rotate(" ++ degrees' ++ "deg)" )
          ]
      ]
      []


knobStyle : Int -> List ( String, String )
knobStyle angle' =
  let
    angle =
      toString angle'
  in
    [ ( "-moz-transform", "rotate(" ++ angle ++ "deg)" )
    , ( "-webkit-transform", "rotate(" ++ angle ++ "deg)" )
    , ( "-o-transform", "rotate(" ++ angle ++ "deg)" )
    , ( "-ms-transform", "rotate(" ++ angle ++ "deg)" )
    , ( "transform", "rotate(" ++ angle ++ "deg)" )
    ]


scrollDecoder : Decode.Decoder Int
scrollDecoder =
  Decode.at [ "wheelDelta" ] Decode.int


closestStep : Int -> Int -> Float -> Int
closestStep start step value =
  let
    start' =
      toFloat start

    step' =
      toFloat step
  in
    if value > start' + step' then
      closestStep (start + step) step value
    else if (value - start') < (start' + step' - value) then
      start
    else
      start + step
