# Designing Sound with the Stack and Units in Sointu

Being confronted with a stack-based sizecoding synthesizer for the first time can be quite overwhelming, especially as non-coder, so the purpose of this document is to cover some basic design patterns for instruments in a stack-based synthesizer.

## Introduction to Stacks

A [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) is a data type that consists of a set of elements (units in Sointu's case) and two operations: you can either `push` an element onto the stack (add it to the top) or `pop` an element from the stack (remove the top element from the stack), leaving the stack in the state before the element was pushed.

## Introduction to Sointu units

Sointu lets you model signals in instruments as units on a stack. Each unit pushes or pops one or multiple units. There are signal sources like `oscillator` and `envelope`, mathematical units like `mulp`, signal processing units like `distort` or `reverb`, the automation unit `send` and output units like `out` and `outaux`.

The synthesizer allows you to copy and paste any number of units in the following, YAML-based format:
```yaml
units:
- type: envelope
  id: 182
  parameters: {attack: 0, decay: 0, gain: 128, release: 64, stereo: 0, sustain: 128}
```
Selecting units in Sointu and pressing CTRL+C will copy the units to the clipboard in this format; units in this document will be listed as YAML and as stack screenshot, so you can copy-paste the yaml into Sointu.

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

## List of available Units

## Common Patterns

### VCO
### VCF
### FM
### Reverb
### Sampler
### Compressor
### Side chain
### Parameter modulation
### Debugging signals
### Synchronization with Visuals
