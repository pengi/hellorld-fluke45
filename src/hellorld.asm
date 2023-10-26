                .processor       hd6303
                .org             $e000

                .include        "lib/hd6303_hack.asm"
                .include        "lib/hd6303_regs.asm"
                .include        "lib/fluke45_hw.asm"
                .include        "lib/fluke45_display.asm"
                .include        "lib/serial.asm"
                .include        "lib/delay.asm"

; ==============================================================================
; Constants
; ==============================================================================

; Top of internal RAM
init_sp         EQU             $013f

; ==============================================================================
; Variables
; ==============================================================================

v_disp_state    EQU            $00F3

; ==============================================================================
; Main
; ==============================================================================

main
                JSR             init

                JSR             disp_clear_screen
                
                ; Load the pointer to the string
main_reset
                LDX             #str_hellorld_start
main_loop

                PSHX                                        ; Argument for draw_string, current first letter
                JSR             draw_string
                JSR             delay_200ms                 ; Delay while X is already saved
                PULX

                INX                                         ; Step to next letter
                INX

                CPX             #str_hellorld_end           ; Check if we should reset
                BEQ             main_reset
                BRA             main_loop                   ; Otherwise continue

str_hellorld_start
                ; Five blanks, to make it possible to fully scroll in
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_h
                dc.w            disp_e
                dc.w            disp_l
                dc.w            disp_l
                dc.w            disp_o
                dc.w            disp_r
                dc.w            disp_l
                dc.w            disp_d
str_hellorld_end
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_blank
                dc.w            disp_blank

; ==============================================================================
; Draw display
; ==============================================================================

; Draw 5 letters of the string to the main display, starting from the pointer
; from stack

; $02,X - 8 bits - ptr to string

draw_string:
                TSX
                LDX             $02,X
                LDX             $00,X
                LDAB            #10
                PSHB
                JSR             $00,X
                PULB
                
                TSX
                LDX             $02,X
                LDX             $02,X
                LDAB            #9
                PSHB
                JSR             $00,X
                PULB
                
                TSX
                LDX             $02,X
                LDX             $04,X
                LDAB            #8
                PSHB
                JSR             $00,X
                PULB
                
                TSX
                LDX             $02,X
                LDX             $06,X
                LDAB            #7
                PSHB
                JSR             $00,X
                PULB
                
                TSX
                LDX             $02,X
                LDX             $08,X
                LDAB            #6
                PSHB
                JSR             $00,X
                PULB
                

                RTS



; ==============================================================================
; Print letters
; ==============================================================================

; There is no font comlpete well enough to print text on the screen. Therefore,
; each letter has to be improvised either by digits, the simple font available
; or segments. Therefore each letter has its own function to draw

; All functions expects the position to pushed as 8 bits on stack

; Also, keep one letter for blank, for keeping buffer when scrolling
disp_blank:
                JMP     disp_clear_digit    ; Same arguments, so tail recursive

disp_h:
                TSX
                LDAB    $02,X
                LDAA    #2
                PSHB
                PSHA
                JSR     disp_set_letter
                PULX
                RTS

disp_e:
                TSX
                LDAB    $02,X              ; All calls use the same top argument
                PSHB

                JSR     disp_clear_digit

                LDAA    #0
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #3
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #4
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #5
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #6
                PSHA
                JSR     disp_set_segment
                PULA

                PULB
                RTS

disp_l:
                TSX
                LDAB    $02,X
                LDAA    #5
                PSHB
                PSHA
                JSR     disp_set_letter
                PULX
                RTS

disp_o:
                TSX
                LDAB    $02,X
                LDAA    #0
                PSHB
                PSHA
                JSR     disp_set_digit
                PULX
                RTS

disp_r:
                TSX
                LDAB    $02,X              ; All calls use the same top argument
                PSHB

                JSR     disp_clear_digit

                LDAA    #4
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #6
                PSHA
                JSR     disp_set_segment
                PULA

                PULB
                RTS

disp_d:
                TSX
                LDAB    $02,X              ; All calls use the same top argument
                PSHB

                JSR     disp_clear_digit

                LDAA    #1
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #2
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #3
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #4
                PSHA
                JSR     disp_set_segment
                PULA

                LDAA    #6
                PSHA
                JSR     disp_set_segment
                PULA

                PULB
                RTS

; ==============================================================================
; Initialize system
; ==============================================================================
init
                ; Start serial
                ; Also needed to clear up SCLK for use to display communicationm
                JSR             serial_init

                ; Set clock and TX to outputs
                LDAB            #disp_ddrval
                STAB            disp_pddr

                ; Set initial bits
                LDAB            #0
                STAB            disp_port

                ; Start display module
                JSR             disp_init

                RTS

; ==============================================================================
; ISR handlers
; ==============================================================================

; Default ISR handler. If this hits, just halt
hdlr_DEF
                JMP             hdlr_DEF

; Reset handler, setup stack and start application
hdlr_RST
                LDS             #init_sp
                JMP             main

; ==============================================================================
; ISR vector
; ==============================================================================

                ORG             $fff0
svec_DIV0       DC.W            hdlr_DEF
svec_SWI3       DC.W            hdlr_DEF
svec_SWI2       DC.W            hdlr_DEF
svec_FIRQ       DC.W            hdlr_DEF
svec_IRQ        DC.W            hdlr_DEF
svec_SWI        DC.W            hdlr_DEF
svec_NMI        DC.W            hdlr_DEF
svec_RST        DC.W            hdlr_RST
                END