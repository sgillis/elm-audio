var app = Elm.fullscreen(
    Elm.Main,
    { receivedFeed:
      { notes:
        [],
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

app.ports.sendFeed.subscribe(function(feed){
    app.ports.receivedFeed.send(feed);
});
