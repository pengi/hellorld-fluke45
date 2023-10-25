

serial_init
                ; TIMER2 provied clock for SCI
                ; Setup as divide by E/1
                LDAB            #%00010000 
                STAB            reg_TCSR3
                
                ; Time constant register of 2 gives 9600 baud
                LDAB            #2 
                STAB            reg_TCONR

                ; Set SCI to 8 bit asynchronous, 9600 baud
                LDAB            #%00100100
                STAB            reg_RMCR

                LDAB            #%00101010
                STAB            reg_TRCSR1

                LDAB            #%00101000
                STAB            reg_TRCSR2

                RTS


serial_send
                ; Wait until TX register is empty
                ; Waiting before sending means next byte can become ready while
                ; current one is clocked out
                LDAA            reg_TRCSR2
                ANDA            #%00100000
                BEQ             serial_send

                ; Send byte
                STAB            reg_TDR

                RTS

; Prints string pointed to from X register
serial_send_str
                ; Put X at top of stack
                PSHX
serial_send_str_loop
                ; Load current byte
                TSX
                LDX     $00,X
                LDAB    $00,X

                ; Exit if NULL byte
                BEQ     serial_send_str_exit

                ; Print byte
                JSR     serial_send

                ; Increment pointer
                TSX
                LDD     $00,X
                ADDD    #1
                STD     $00,X

                ; Repeat
                BRA     serial_send_str_loop

                ; Exit
serial_send_str_exit
                PULX
                RTS