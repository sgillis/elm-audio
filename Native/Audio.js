Elm.Native.Audio = {};

Elm.Native.Audio.make = function(elm){
    elm.Native = elm.Native || {};
    elm.Native.Audio = elm.Native.Audio || {};
    if (elm.Native.Audio.values) return elm.Native.Audio.values;

    var ctx = new (window.AudioContext || window.webkitAudioContext)();
    var gain = ctx.createGain();
    gain.connect(ctx.destination);

    var oscillators = {}

    var oscillator = F2(function(detune, frequency){
        var node1 = ctx.createOscillator();
        node1.frequency.value = frequency;
        node1.type = "sawtooth";
        node1.detune.value = detune / 27;
        node1.start();
        node1.connect(gain);
        if(oscillators[frequency] == undefined){
            oscillators[frequency] = [ node1 ];
        } else {
            oscillators[frequency].push(node1);
        }
        return frequency
    });

    var destroyOscillator = function(frequency){
        oscillators[frequency].forEach(function (oscillator) {
            oscillator.stop();
            oscillator.disconnect();
        });
        return frequency;
    };

    var connect = F2(function(sender, receiver){
        if (receiver.ctor === "DestinationNode"){
            sender._node.connect(ctx.destination);
        } else {
            sender._node.connect(receiver._node);
        }
        return true;
    });

    return elm.Native.Audio.values = {
        oscillator: oscillator,
        connect: connect,
        destroyOscillator: destroyOscillator
    }
}
