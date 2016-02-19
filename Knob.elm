module Knob (Model, Action, init, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode


-- Taken from http://codepen.io/blucube/pen/cudAz


type alias Model =
  { angle : Int }


init : Model
init =
  { angle = 0 }


type Action
  = NoOp
  | Scroll Int


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Scroll x ->
      if x > 0 then
        { model | angle = Basics.min 270 <| model.angle + 2 }
      else
        { model | angle = Basics.max 0 <| model.angle - 2 }


view : Signal.Address Action -> Model -> Html
view address model =
  let
    active =
      round <| (toFloat model.angle) / 10 + 1

    inactive =
      28 - active
  in
    div
      [ class "knob-surround" ]
      [ div
          [ class "knob"
          , style <| knobStyle model.angle
          , onWithOptions
              "mousewheel"
              { stopPropagation = True
              , preventDefault = True
              }
              scrollDecoder
              (\x -> Signal.message address (Scroll x))
          ]
          []
      , span [ class "min" ] [ text "Min" ]
      , span [ class "max" ] [ text "Max" ]
      , div
          [ class "ticks" ]
          (List.map tick
            <| List.repeat active True
            ++ List.repeat inactive False
          )
      ]


tick : Bool -> Html
tick active =
  div
    [ classList
        [ ( "tick", True )
        , ( "activetick", active )
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
