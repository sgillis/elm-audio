var app = Elm.fullscreen(
    Elm.Main,
    { receivedModel:
      { audio:
        { oscillators:
          [ { index: 1,
              playingNotes: [],
              waveform: "sine",
              detune: 0 },
            { index: 2,
              playingNotes: [],
              waveform: "sine",
              detune: 0 }
          ],
          notes:
          []
        },
        detuneKnob:
        { angle: 0,
          steps: 28,
          snap: false,
          closest: 0,
        },
        waveformSelector:
        { angle: 0,
          steps: 5,
          snap: false,
          closest: 0,
        }
      }
    }
);

app.ports.sendModel.subscribe(function(model){
    app.ports.receivedModel.send(model);
});
