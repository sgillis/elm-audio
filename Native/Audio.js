Elm.Native.Audio = {};

Elm.Native.Audio.make = function(elm){
    elm.Native = elm.Native || {};
    elm.Native.Audio = elm.Native.Audio || {};
    if (elm.Native.Audio.values) return elm.Native.Audio.values;

    var ctx = new (window.AudioContext || window.webkitAudioContext)();
    var gain = ctx.createGain();
    gain.connect(ctx.destination);

    var oscillators =
        {1: {},
         2: {}
        }

    var oscillator = F3(function(index, detune, frequency){
        var node = ctx.createOscillator();
        node.frequency.value = frequency;
        node.type = "sawtooth";
        node.detune.value = detune / 27;
        node.start();
        node.connect(gain);
        oscillators[index][frequency] = node;
        return frequency
    });

    var destroyOscillator = F2(function(index, frequency){
        var oscillator = oscillators[index][frequency];
        oscillator.stop();
        oscillator.disconnect();
        return frequency;
    });

    var setOscillatorDetune = F2(function(index, detune){
        for(var freq in oscillators[index]){
            oscillators[index][freq].detune.value = detune / 27;
        }
        return detune
    });

    return elm.Native.Audio.values = {
        oscillator: oscillator,
        destroyOscillator: destroyOscillator,
        setOscillatorDetune: setOscillatorDetune
    }
}
