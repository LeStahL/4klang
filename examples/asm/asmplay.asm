%include "physics_girl_st.inc"

%define PM_REMOVE 0x1
%define VK_ESCAPE 0x1B
%define WAVE_FORMAT_IEEE_FLOAT 0x3
%define WHDR_PREPARED 0x2
%define WAVE_MAPPER 0xFFFFFFFF
%define TIME_SAMPLES 0x2

; Those we link.
section _play_symbols text
_play_symbols:
    extern _GetAsyncKeyState@4
    extern _PeekMessageA@20
    extern _DispatchMessageA@4
    extern _CreateThread@24
    extern _waveOutOpen@24
    extern _waveOutWrite@12
    extern _waveOutGetPosition@12

; For win32 messages.
section msg bss
msg:
    resd 1
message:
    resd 7

section wavefmt data
wavefmt:
    dw WAVE_FORMAT_IEEE_FLOAT
    dw SU_CHANNEL_COUNT
    dd SU_SAMPLE_RATE 
    dd SU_SAMPLE_SIZE * SU_SAMPLE_RATE * SU_CHANNEL_COUNT
    dw SU_SAMPLE_SIZE * SU_CHANNEL_COUNT
    dw SU_SAMPLE_SIZE * 8
    dw 0

section wavehdr data
wavehdr:
    dd soundbuffer
    dd SU_LENGTH_IN_SAMPLES * SU_SAMPLE_SIZE * SU_CHANNEL_COUNT
    times 2 dd 0
    dd WHDR_PREPARED
    times 4 dd 0
wavehdr_end:

section soundbuffer bss
soundbuffer:
    resd SU_LENGTH_IN_SAMPLES * SU_SAMPLE_SIZE * SU_CHANNEL_COUNT

section hwaveout bss
hwaveout:
    resd 1

; For the time.
section mmtime data
mmtime:
    dd TIME_SAMPLES
time:
    times 2 dd 0

section entry text
    global _WinMain@16
_WinMain@16:
%ifdef SU_LOAD_GMDLS
    call _su_load_gmdls
%endif ; SU_LOAD_GMDLS

    ; CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
    times 2 push 0
    push soundbuffer
    push _su_render_song@4
    times 2 push 0
    call _CreateThread@24

    ; waveOutOpen(&hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
    times 3 push 0
    push wavefmt
    push WAVE_MAPPER
    push hwaveout
    call _waveOutOpen@24

    ; waveOutWrite(hWaveOut, &WaveHDR, sizeof(WaveHDR));
    push wavehdr_end - wavehdr
    push wavehdr
    push dword [hwaveout]
    call _waveOutWrite@12

    mainloop:
        ; Dispatch all available win32 messages 
        dispatchloop:
            push PM_REMOVE
            times 3 push 0
            push msg
            call _PeekMessageA@20
            cmp eax, 0
            je dispatchloop_end
            
            push msg
            call _DispatchMessageA@4

            jmp dispatchloop
        dispatchloop_end:

        ; Update time from wave position.
        ; waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
        push 12
        push mmtime
        push dword [hwaveout]
        call _waveOutGetPosition@12
        
        ; Exit when we finished playing the song.
        cmp dword [time], SU_LENGTH_IN_SAMPLES
        jge exit

        ; Stall until escape.
        push VK_ESCAPE
        call _GetAsyncKeyState@4

        cmp eax, 0
        je mainloop

exit:
    hlt
