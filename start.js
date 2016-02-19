var app = Elm.fullscreen(
    Elm.Main, 
    { receivedModel:
      { audio:
        { oscillators:
          [ { index: 1, notes: [], detune: 0 },
            { index: 2, notes: [], detune: 0 }
          ]
        },
        detuneKnob:
        { angle: 0 }
      }
    }
);

app.ports.sendModel.subscribe(function(model){
    app.ports.receivedModel.send(model);
});
