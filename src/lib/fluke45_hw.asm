; ==============================================================================
; Pinmap
; ==============================================================================

; P22 - DSCLK - PORT2 $04 / $fb
; P25 - DISRX - PORT2 $20 / $df
; P26 - DISTX - PORT2 $40 / $bf

disp_port       EQU             reg_PORT2
disp_pddr       EQU             reg_P2DDR
disp_ddrval     EQU             $44
disp_clk_b      EQU             $04
disp_rx_b       EQU             $20
disp_tx_b       EQU             $40
