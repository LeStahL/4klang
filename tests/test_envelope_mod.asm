%define BPM 100

%include "sointu/header.inc"

BEGIN_PATTERNS
    PATTERN 64, HLD, HLD, HLD, HLD, HLD, HLD, HLD,HLD, HLD, HLD, 0, 0, 0, 0, 0
END_PATTERNS

BEGIN_TRACKS
    TRACK VOICES(1),0
END_TRACKS

BEGIN_PATCH
    BEGIN_INSTRUMENT VOICES(1) ; Instrument0
        SU_ENVELOPE MONO,ATTAC(80),DECAY(80),SUSTAIN(64),RELEASE(80),GAIN(128)
        SU_ENVELOPE MONO,ATTAC(80),DECAY(80),SUSTAIN(64),RELEASE(80),GAIN(128)
        SU_OSCILLAT MONO,TRANSPOSE(120),DETUNE(64),PHASE(0),COLOR(128),SHAPE(96),GAIN(128),FLAGS(SINE+LFO)
        SU_SEND MONO,AMOUNT(68),LOCALPORT(0,0)
        SU_SEND MONO,AMOUNT(68),LOCALPORT(0,1)
        ; Sustain modulation seems not to be implemented
        SU_SEND MONO,AMOUNT(68),LOCALPORT(0,3)
        SU_SEND MONO,AMOUNT(68),LOCALPORT(1,4) + SEND_POP
        SU_OUT  STEREO,GAIN(110)
    END_INSTRUMENT
END_PATCH

%include "sointu/footer.inc"
