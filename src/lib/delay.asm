
; ===================================================================
; Delay 200ms
; ===================================================================

delay_200ms
                PSHX
                ; for i=0; i<10; i++
                CLRB
                TSX
                STAB             $00,X
delay_200ms_loop
                TSX
                LDAB             $00,X
                CMPB             #10
                BCC              delay_200ms_loop_end

                ; sleep for a millisecond
                LDX             #20
                PSHX
                JSR             delay_ms
                PULX

                ; end for
                TSX
                INC             $00,X
                BRA             delay_200ms_loop
delay_200ms_loop_end

                PULX
                RTS

; ===================================================================
; Delay 1ms
; ===================================================================

delay_1ms
                LDX             #1
                PSHX
                JSR             delay_ms
                PULX
                RTS

; ===================================================================
; Delay ms
; ===================================================================

; Code from fluke 45 firmware

; Arguments:
; $07,X - time

; Local variables
; $00,X - 2 bytes - guard
; $02,X - 2 bytes - cycles

; With XTAL = 3.6864MHz, divided by 4 to a system clock at 0.9216MHz
; one tick is therefore 922 cycles / 0.9216 us = 1ms (approximately)

delay_ms        PSHX
                PSHX
                TSX                         ; - if(time <= 71) {
                LDAB            $07,X
                CMPB            #71
                BHI             delay_ms_1
                LDAB            $07,X               ; -     cycles = mul_word(time, 922)
                CLRA
                PSHB
                PSHA
                LDX             #922
                PSHX
                JSR             mul_word
                PULX
                PULX
                TSX
                STD             $02,X
                BRA             delay_ms_2          ; - } else {
delay_ms_1
                LDD             #$FFB6              ; -     cycles = $FFB6
                TSX
                STD             $02,X
delay_ms_2                                          ; - }
                LDD             reg_FRCH            ; - guard = R_FRC
                TSX
                STD             $00,X
                SUBD            #100                ; - cycles += guard - 100
                ADDD            $02,X
                STD             $02,X
                SUBD            #$FFB6              ; - if(cycles > $ffb6) {
                BLS             delay_ms_3
                CLRA                                ; -     cycles = 0
                CLRB
                STD             $02,X
delay_ms_3                                          ; - }
                                                    ; - if(ticks == 0) {
                TSX
                TST             $07,X
                                                    ; -     return
                BEQ             delay_ms_exit       ; - }
                LDD             $02,X               ; - if(cycles < guard) {
                SUBD            $00,X
                BCC             delay_ms_5
delay_ms_4      LDD             reg_FRCH            ; -     while( guard > R_FRC ) {}
                TSX
                SUBD            $00,X
                BHI             delay_ms_4
delay_ms_5                                          ; - }
                LDD             reg_FRCH            ; - while( cycles < R_FRC ) {}
                TSX
                SUBD            $02,X
                BCS             delay_ms_5
delay_ms_exit   PULX
                PULX
                RTS

; ===================================================================
; Multiply word
; ===================================================================

; Code from fluke 45 firmware

; Seems to multiply an 8 bit and 16 bit word, as two arguments
; TODO: reverse engineer

mul_word        PSHX
                PSHX
                TSX
                LDAB            $07,X
                STAB            $00,X
                LDAA            $09,X
                MUL
                STAB            $00,X
                STAA            $01,X
                LDAB            $01,X
                CLRA
                TBA
                CLRB
                STD             $02,X
                LDAB            $00,X
                CLRA
                ADDD            $02,X
                STD             $02,X
                LDAB            $07,X
                STAB            $00,X
                LDD             $08,X
                TAB
                CLRA
                LDAA            $00,X
                MUL
                STAB            $00,X
                CLRA
                TBA
                CLRB
                ADDD            $02,X
                STD             $02,X
                LDD             $06,X
                TAB
                CLRA
                STAB            $00,X
                LDAA            $09,X
                MUL
                STAB            $00,X
                CLRA
                TBA
                CLRB
                ADDD            $02,X
                STD             $02,X
                PULX
                PULX
                RTS
