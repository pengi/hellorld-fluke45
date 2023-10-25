; ===================================================================
; Init display
; ===================================================================

; Code copied from disassembled fluke 45 firmware

; Seems to initialize the display and synchronize the communication

; Arguments:

; Local variables
; $00,X - status
; $01,X - i

disp_init
                PSHX
                CLRB                                    ; - v_disp_state = 0;
                STAB            v_disp_state
                PSHB                                    ; - status = disp_send_raw(0, $c8);
                PSHB
                LDX             #$00C8
                PSHX
                JSR             disp_send_raw
                PULX
                PULX
                TSX
                STAB            $00,X
                CMPB            #$01                    ; - if(status == $01) {
                BNE             disp_init_1
                JMP             disp_init_exit          ; -     return;
disp_init_1                                             ; - }
                LDAB            $00,X                   ; - if(status == $55) { // self test fail
                CMPB            #$55
                BNE             disp_init_2
                LDAB            #$01                    ; -     v_disp_state = 1;
                STAB            v_disp_state
                JMP             disp_init_exit          ; -     return;
disp_init_2                                             ; - }
                LDAB            #$02                    ; - v_disp_state = 2;
                STAB            v_disp_state
                CLRB                                    ; - for(i=0; i<20; i++) {
                TSX
                STAB            $01,X
disp_init_3     TSX
                LDAB            $01,X
                CMPB            #$14
                BCC             disp_init_6
                LDAB            $00,X                   ; -     if(status == $01)
                CMPB            #$01
                BEQ             disp_init_6             ; -         break
                LDX             #1                      ; -     status = disp_send_raw(1, $ff)
                PSHX
                LDX             #$00FF
                PSHX
                JSR             disp_send_raw
                PULX
                PULX
                TSX
                STAB            $00,X
                LDAB            disp_port               ; -     if(get_rx() != 0) {
                ANDB            #$20
                BEQ             disp_init_4
                LDX             #1                      ; -         delay_ms(1)
                PSHX
                JSR             delay_ms
                PULX
disp_init_4                                             ; -     }
                LDAB            disp_port               ; -     if(get_rx() != 0) {
                ANDB            #$20
                BEQ             disp_init_5

                CLRB                                    ; -         status = $00
                TSX
                STAB            $00,X
disp_init_5     TSX                                     ; -     }
                INC             $01,X
                BRA             disp_init_3
disp_init_6                                             ; - }
                LDX             #1                      ; - if(0 != disp_send_raw(1, $e0)) {
                PSHX
                LDX             #$00E0
                PSHX
                JSR             disp_send_raw
                PULX
                PULX
                SUBD            #1
                BNE             disp_init_exit          ; -     return;
disp_init_7                                             ; - }
                LDAB            disp_port                 ; - while(get_rx() == 1) {}
                ANDB            #$20
                BNE             disp_init_7
                CLRB                                    ; - disp_send_raw(0, $c8)
                PSHB
                PSHB
                LDX             #$00C8
                PSHX
                JSR             disp_send_raw
                PULX
                PULX
                TSX                                     ; - if(status == $01) {
                STAB            $00,X
                CMPB            #$01
                BNE             disp_init_8
                CLRB                                    ; -     v_disp_state = 0
                STAB            v_disp_state
                BRA             disp_init_exit          ; -     return;
disp_init_8                                             ; - }
                TSX                                     ; - if(status == $55) { // self test fail
                LDAB            $00,X
                CMPB            #$55
                BNE             disp_init_exit
                LDAB            #$01                    ; -     v_disp_state = 1
                STAB            v_disp_state
disp_init_exit                                          ; - }
                PULX
                RTS


; ===================================================================
; Display - update and store state
; ===================================================================

; Code copied from disassembled fluke 45 firmware

; Arguments:
; $03,X - 8 bits - data

disp_send8
                TSX
                LDAB            $03,X                   ; v_disp_state = disp_send8_int(arg1)
                CLRA
                PSHB
                PSHA
                BSR             disp_send8_int
                PULX
                STAB            v_disp_state
                RTS

; ===================================================================
; Display - update
; ===================================================================

; Code copied from disassembled fluke 45 firmware

; Arguments:
; $08,X - 8 bits - data

; Local variables
; $00,X - 8 bits - var2
; $02,X - 8 bits - status

; Return:
; D = status

disp_send8_int        PSHX
                DES

disp_send8_int_1                                              ; - do {
                LDAB            reg_PORT2               ; -     if(port_rx == 0) {
                ANDB            #$20
                BEQ             disp_send8_int_2              ; -         break;
                                                        ; -     }
                LDAB            v_disp_state            ; - } while(v_disp_state != 2);
                CMPB            #$02
                BNE             disp_send8_int_1
disp_send8_int_2
                LDX             #1                      ; - status = disp_send_raw(1, data)
                PSHX
                TSX
                LDAB            $08,X
                CLRA
                PSHB
                PSHA
                JSR             disp_send_raw
                PULX
                PULX
                TSX
                STAB            $02,X

                CMPB            #$01                    ; - if(status != 1 && v_disp_state != 2) {
                BEQ             disp_send8_int_6
                LDAB            v_disp_state
                CMPB            #$02
                BEQ             disp_send8_int_6

                ; Some code existed here that just read and wrote back data to
                ; the EEPROM. No reason to keep that when only interfacing the
                ; display, so removed

                LDAB            reg_PORT2               ; -     if(port_rx != 0) {
                ANDB            #$20
                BEQ             disp_send8_int_3

                JSR             delay_1ms


disp_send8_int_3                                              ; -     }
                LDX             #1                      ; -     status = disp_send_raw(1, $ff)
                PSHX
                LDX             #$FF
                PSHX
                BSR             disp_send_raw
                PULX
                PULX
                TSX
                STAB            $02,X

                LDAB            reg_PORT2               ; -     if(port_rx != 0) {
                ANDB            #$20
                BEQ             disp_send8_int_4

                JSR             delay_1ms

disp_send8_int_4                                              ; -     }
                LDAB            reg_PORT2               ; -     if(port_rx != 0) {
                ANDB            #$20
                BEQ             disp_send8_int_5

                CLRB                                    ; -         status = 0
                TSX
                STAB            $02,X


disp_send8_int_5                                              ; -     }
                TSX                                     ; -     if(status != 1) {
                LDAB            $02,X
                CMPB            #$01
                BNE             disp_send8_int_3              ; -         ...repeat...
                                                        ; -     }
                LDD             #1                      ; -     return 1
                BRA             disp_send8_int_exit
                                                        ; - }


disp_send8_int_6
                LDAB            v_disp_state            ; - if(v_disp_state == 2) {
                CMPB            #$02
                BNE             disp_send8_int_ret0

                LDD             #2                      ; -     return 2
                BRA             disp_send8_int_exit


disp_send8_int_ret0                                           ; - }
                CLRA                                    ; - return 0
                CLRB

disp_send8_int_exit   PULX
                INS
                RTS


; ===================================================================
; Display - send byte
; ===================================================================

; Code copied from disassembled fluke 45 firmware

; Arguments:
; $09,X - full_byte
; $07,X - data_tx

; Local variables
; $02,X - data_rx
; $03,X - i

; Return:
; B = data_rx

disp_send_raw
                PSHX
                PSHX
                CLRB                                    ; - data_rx = 0
                TSX
                STAB            $02,X
                STAB            $03,X                   ; - for(i = 0; i < 8; i++) {
disp_send_raw_loop
                TSX
                LDAB            $03,X
                CMPB            #$08
                BCC             disp_send_raw_endl
                LDAB            $02,X                   ; -     if(data_rx == 1) {
                CMPB            #$01
                BNE             disp_send_raw_2
                TST             $09,X                   ; -         if(full_byte != 0) {
                BNE             disp_send_raw_endl      ; -             break;
disp_send_raw_2                                         ; -         }
                                                        ; -     }
                aimd            #$FB,disp_port          ; -     port_clock = low
                TSX                                     ; -     if(data_tx & $80 != 0) {
                LDAB            $07,X
                ROLB
                BCC             disp_send_raw_3
                oimd            #$40,disp_port          ; -         port_tx = high
                BRA             disp_send_raw_4         ; -     }
disp_send_raw_3                                         ; -     else {
                LDAB            disp_port
                ANDB            #$BF
                STAB            disp_port


disp_send_raw_4                                         ; -     }
                TSX                                     ; -     data_rx <<= 1
                ASL             $02,X
                LDAB            disp_port               ; -     data_rx |= port_rx ? 1 : 0
                ANDB            #$20
                CLRA
                LSRD
                LSRD
                LSRD
                LSRD
                LSRD
                ORAB            $02,X
                STAB            $02,X
                oimd            #$04,disp_port          ; -     port_clock = high
                TSX
                ASL             $07,X                   ; -     data_tx <<= 1
                INC             $03,x                   ; -     // i++ from for()
                BRA             disp_send_raw_loop
disp_send_raw_endl                                      ; - }
                TSX                                     ; - if(i < 8) {
                LDAB            $03,X
                CMPB            #$08
                BCC             disp_send_raw_5
                CLRB                                    ; -     data_rx = 0
                STAB            $02,X
disp_send_raw_5                                             ; - }
                TSX                                     ; - return data_rx
                LDAB            $02,X
                CLRA
                PULX
                PULX
                RTS
