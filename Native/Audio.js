Elm.Native.Audio = {};

Elm.Native.Audio.make = function(elm){
    elm.Native = elm.Native || {};
    elm.Native.Audio = elm.Native.Audio || {};
    if (elm.Native.Audio.values) return elm.Native.Audio.values;

    var Task = Elm.Native.Task.make(elm);
    var Utils = Elm.Native.Utils.make(elm);

    var ctx = new (window.AudioContext || window.webkitAudioContext)();
    var gain = ctx.createGain();
    gain.connect(ctx.destination);

    var oscillators =
        {1: {},
         2: {}
        }

    var oscillator = F4(function(index, waveform, detune, frequency){
        return Task.asyncFunction(function(callback){
            var node = ctx.createOscillator();
            node.frequency.value = frequency;
            node.type = waveform;
            node.detune.value = detune / 27;
            node.start();
            node.connect(gain);
            oscillators[index][frequency] = node;
            callback(Task.succeed(Utils.Tuple0));
        })
    });

    var destroyOscillator = F2(function(index, frequency){
        return Task.asyncFunction(function(callback){
            var oscillator = oscillators[index][frequency];
            oscillator.stop();
            oscillator.disconnect();
            callback(Task.succeed(Utils.Tuple0));
        });
    });

    var setOscillatorDetune = F2(function(index, detune){
        return Task.asyncFunction(function(callback){
            for(var freq in oscillators[index]){
                oscillators[index][freq].detune.value = detune / 27;
            }
            callback(Task.succeed(Utils.Tuple0));
        });
    });

    return elm.Native.Audio.values = {
        oscillator: oscillator,
        destroyOscillator: destroyOscillator,
        setOscillatorDetune: setOscillatorDetune
    }
}
