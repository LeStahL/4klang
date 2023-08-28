%define SU_TARGET_ELF
%include "physics_girl_st.inc"

%define SND_PCM_STREAM_PLAYBACK 0x0
%define SND_PCM_FORMAT_FLOAT_LE 0xE
%define SND_PCM_ACCESS_RW_INTERLEAVED 0x3

section .bss
soundbuffer:
    resd SU_LENGTH_IN_SAMPLES * SU_SAMPLE_SIZE * SU_CHANNEL_COUNT

pcm_handle:
    resq 1

play_sound_thread:
    resq 1

section .data
pcm_device:
    db "default", 0

pcm_handle_reference:
    dd pcm_handle

; Those we link.
section .text
_play_symbols:
    extern pthread_create
    extern snd_pcm_open@@ALSA_0.9
    extern snd_pcm_set_params@@ALSA_0.9
    extern snd_pcm_writei@@ALSA_0.9
    extern _XInitThreads
    extern _XOpenDisplay@4
    extern _XPending@4
    extern _XNextEvent@4
    
    global _play_sound
_play_sound:
    push SU_SAMPLE_SIZE * SU_LENGTH_IN_SAMPLES
    push soundbuffer
    push pcm_handle
    call snd_pcm_writei@@ALSA_0.9

    global _start
_start:
%ifdef SU_LOAD_GMDLS
    call _su_load_gmdls
%endif ; SU_LOAD_GMDLS
    push 0
    push SND_PCM_STREAM_PLAYBACK
    push pcm_device
    push pcm_handle_reference
    call snd_pcm_open@@ALSA_0.9

    push SU_LENGTH_IN_SAMPLES * SU_SAMPLE_SIZE
    push 0
    push SU_SAMPLE_RATE
    push SU_CHANNEL_COUNT
    push SND_PCM_ACCESS_RW_INTERLEAVED
    push SND_PCM_FORMAT_FLOAT_LE
    push pcm_handle
    call snd_pcm_set_params@@ALSA_0.9

    push 0
    push _play_sound
    push 0
    push play_sound_thread
    call pthread_create


;     ; CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
;     times 2 push 0
;     push soundbuffer
;     push _su_render_song@4
;     times 2 push 0
;     call _CreateThread@24

;     ; waveOutOpen(&hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
;     times 3 push 0
;     push wavefmt
;     push WAVE_MAPPER
;     push hwaveout
;     call _waveOutOpen@24

;     ; waveOutWrite(hWaveOut, &WaveHDR, sizeof(WaveHDR));
;     push wavehdr_end - wavehdr
;     push wavehdr
;     push dword [hwaveout]
;     call _waveOutWrite@12

mainloop:
;         ; Dispatch all available win32 messages 
;         dispatchloop:
;             push PM_REMOVE
;             times 3 push 0
;             push msg
;             call _PeekMessageA@20
;             cmp eax, 0
;             je dispatchloop_end
            
;             push msg
;             call _DispatchMessageA@4

;             jmp dispatchloop
;         dispatchloop_end:

;         ; Update time from wave position.
;         ; waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
;         push 12
;         push mmtime
;         push dword [hwaveout]
;         call _waveOutGetPosition@12
        
;         ; Exit when we finished playing the song.
;         cmp dword [time], SU_LENGTH_IN_SAMPLES
;         jge exit

;         ; Stall until escape.
;         push VK_ESCAPE
;         call _GetAsyncKeyState@4

;         cmp eax, 0
;         je mainloop
    jmp mainloop

exit:
    hlt
