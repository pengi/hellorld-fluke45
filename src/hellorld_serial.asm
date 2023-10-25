                .processor      hd6303
                .org            $e000

                .include        "lib/hd6303_hack.asm"
                .include        "lib/hd6303_regs.asm"
                .include        "lib/serial.asm"

; ==============================================================================
; Constants
; ==============================================================================

; Top of internal RAM
init_sp         EQU             $013f

; ==============================================================================
; Start of available ROM area when using an 64kbit or 8kbyte EEPROM
; ==============================================================================

main
                JSR             serial_init
main_loop
                LDX             #str_hellorld
                JSR             serial_send_str
                JMP             main_loop
                
str_hellorld    DC.B            "Hellorld!",$0A,$0D,$00

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

                .org             $fff0
svec_DIV0       dc.w            hdlr_DEF
svec_SWI3       dc.w            hdlr_DEF
svec_SWI2       dc.w            hdlr_DEF
svec_FIRQ       dc.w            hdlr_DEF
svec_IRQ        dc.w            hdlr_DEF
svec_SWI        dc.w            hdlr_DEF
svec_NMI        dc.w            hdlr_DEF
svec_RST        dc.w            hdlr_RST
                end