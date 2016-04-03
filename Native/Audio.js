Elm.Native.Audio = {};

Elm.Native.Audio.make = function(elm){
    elm.Native = elm.Native || {};
    elm.Native.Audio = elm.Native.Audio || {};
    if (elm.Native.Audio.values) return elm.Native.Audio.values;

    var Task = Elm.Native.Task.make(elm);
    var Utils = Elm.Native.Utils.make(elm);

    var ctx = new (window.AudioContext || window.webkitAudioContext)();
    var masterGain = ctx.createGain();
    masterGain.connect(ctx.destination);

    var oscillators =
        {1: {},
         2: {}
        };

    var oscillator = F4(function(index, waveform, detune, frequency){
        return Task.asyncFunction(function(callback){
            var node = ctx.createOscillator();
            node.frequency.value = frequency;
            node.type = waveform;
            node.detune.value = detune / 27;
            node.start();
            var gain = ctx.createGain();
            node.connect(gain);
            gain.connect(masterGain);
            oscillators[index][frequency] = oscillators[index][frequency] || {};
            oscillators[index][frequency]['node'] = node;
            oscillators[index][frequency]['gain'] = gain;
            callback(Task.succeed(Utils.Tuple0));
        });
    });

    var destroyOscillator = F2(function(index, frequency){
        return Task.asyncFunction(function(callback){
            var oscillator = oscillators[index][frequency]['node'];
            var gain = oscillators[index][frequency]['gain'];
            oscillator.stop();
            gain.disconnect();
            oscillator.disconnect();
            callback(Task.succeed(Utils.Tuple0));
        });
    });

    var setOscillatorDetune = F2(function(index, detune){
        return Task.asyncFunction(function(callback){
            for(var freq in oscillators[index]){
                oscillators[index][freq]['node'].detune.value = detune / 27;
            }
            callback(Task.succeed(Utils.Tuple0));
        });
    });

    var setOscillatorGain = F2(function(index, gain){
        for(var freq in oscillators[index]){
          console.log(oscillators[index][freq]['gain']);
        }
        return Task.asyncFunction(function(callback){
          for(var freq in oscillators[index]){
            oscillators[index][freq]['gain'].gain.value = gain;
          }
          callback(Task.succeed(Utils.Tuple0));
        });
    });

    return elm.Native.Audio.values = {
        oscillator: oscillator,
        destroyOscillator: destroyOscillator,
        setOscillatorDetune: setOscillatorDetune,
        setOscillatorGain: setOscillatorGain
    };
}
