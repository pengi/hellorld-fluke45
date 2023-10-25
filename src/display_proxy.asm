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


main_loop
                ; Print display status
                LDAB            v_disp_state
                ADDB            #'0
                JSR             serial_send

                ; Wait for byte on serial
                JSR             serial_read

                ; send to display
                PSHB
                PSHA
                JSR             disp_send8
                PULX

                ; Repeat
                JMP             main_loop

; ==============================================================================
; Initialize system
; ==============================================================================
init
                ; Start serial
                ; Also needed to clear up SCLK for use to display communication

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