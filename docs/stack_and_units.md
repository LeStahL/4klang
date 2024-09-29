[[_TOC_]]

# Designing Sound with the Stack and Units in Sointu

Being confronted with a stack-based sizecoding synthesizer for the first time can be quite overwhelming, especially as non-coder, so the purpose of this document is to cover some basic design patterns for instruments in a stack-based synthesizer.

## Introduction to Stacks

A [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) is a data type that consists of a set of elements (units in Sointu's case) and two operations: you can either `push` an element onto the stack (add it to the top) or `pop` an element from the stack (remove the top element from the stack), leaving the stack in the state before the element was pushed.

## Introduction to Sointu units

Sointu lets you model the signals in instruments by editing a list of units. Those units have different effects on the signal stack. There are signal sources like `oscillator` and `envelope`, mathematical units like `mulp`, signal processing units like `distort` or `reverb`, the automation unit `send` and output units like `out` and `outaux`.

Those units all have different effects on the signal stack; for example `oscillator` will push an oscillator signal onto the stack; the specific effect of the units in the instrument view will be covered in detail later in this document however.

The synthesizer allows you to copy and paste any number of units in the following, YAML-based format:
```yaml
units:
- type: envelope
  id: 182
  parameters: {attack: 0, decay: 0, gain: 128, release: 64, stereo: 0, sustain: 128}
```
Selecting units in Sointu and pressing CTRL+C will copy the units to the clipboard in this format; units in this document will be listed as YAML and as stack screenshot, so you can copy-paste the yaml into Sointu.

Next to the units in the instrument, the signal stack size after the execution of the unit is displayed as number. For an instrument in Sointu to work, it needs to leave the signal stack empty (size must be 0) after the last unit, and the stack size can never decrease below zero.

The units respect stereo signals and treat them as two signals on the stack.

Sointu has an one stereo output channel, two auxiliary stereo output channels and an auxiliary mono output channel. All of them can be used to output sound.

## Explanation of the Default Instrument

When creating a new instrument in Sointu, it will by default contain the following stack:

![Screenshot of the default instrument stack in Sointu](images/default_instrument.png?raw=true)

```yaml
units:
- type: envelope
  id: 10
  parameters: {attack: 64, decay: 64, gain: 64, release: 64, stereo: 0, sustain: 64}
- type: oscillator
  id: 11
  parameters: {color: 64, detune: 64, gain: 64, phase: 0, shape: 64, stereo: 0, transpose: 64, type: 0}
- type: mulp
  id: 12
  parameters: {stereo: 0}
- type: delay
  id: 13
  parameters: {damp: 0, dry: 128, feedback: 96, notetracking: 2, pregain: 40, stereo: 0}
  varargs: [48]
- type: pan
  id: 14
  parameters: {panning: 64, stereo: 0}
- type: outaux
  id: 15
  parameters: {auxgain: 64, outgain: 64, stereo: 1}
```

The instrument first pushes an `envelope` and an `oscillator` unit onto the stack. The `mulp` operation multiplies the top two signals on the stack and removes them ('multiply and pop'), then pushes the result. Delay adds a delay effect to the signal on top of the stack. `pan` makes a stereo signal from the signal on top of the stack, increasing the stack size by one for the second channel signal. `outaux` outputs the signal as sound and pops two signals (the channels) from the stack.

## List of available Units

This section lists all available units and their effect on the signal stack as reference.

### `add`

This adds the top two signals, pops the last operand from the signal stack and pushes the result of the addition. It is useful if you want to keep the first operand of the addition for later use.

|before  |after            |
|--------|-----------------|
|operand2|operand1+operand2|
|operand1|operand1         |
|...     |...              |

### `addp`

This adds the top two signals, pops both of the operands and pushes the result, reducing the signal stack size.

|before  |after            |
|--------|-----------------|
|operand2|                 |
|operand1|operand1+operand2|
|...     |...              |

### `aux`

Send the top signal to an auxiliary output.
Parameters:
|Name       |Effect                         |
|-----------|-------------------------------|
|gain       |Scales the signal before output|
|channel    |Selects the output to send to  |

### `clip`

Clips the top signal to the inclusive range [0,1].

### `compressor`

Determines a compression factor signal for the top signal on the stack and pushes it.

|before |after            |
|-------|-----------------|
|       |factor           |
|operand|operand          |
|...    |...              |

This means, that the compressed signal can be obtained by using the block

![Screenshot of the block acting as a compressor effect](images/compressor_effect.png?raw=true)

```yaml
units:
- type: compressor
  id: 16
  parameters: {attack: 64, invgain: 64, ratio: 64, release: 64, stereo: 0, threshold: 64}
- type: mulp
  id: 19
  parameters: {stereo: 0}
```

## Common Patterns

### Oscillator with envelope

### Pitch Envelope

### Filter Envelope

### FM

### Reverb

### Supersaw

### Sampler

### Compressor

### Side chain

### Global effects

### Parameter modulation

### Debugging signals

### Synchronization with Visuals
