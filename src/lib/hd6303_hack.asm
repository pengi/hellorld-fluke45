; ==============================================================================
; Hacks for some instructions in HD6303
; ==============================================================================
;
; Macros copied from dasm example code, as workaround for dasm not properly
; supporting those instructions
;

	            .mac hack
	            dc.b	{1}	; opcode
	            dc.b	{2}	; immediate value
	            dc.b	{3}	; zero-page address
	            .endm

	            .mac aimd
	            hack	$71,{1},{2}
	            .endm

	            .mac aimx
	            hack	$61,{1},{2}
	            .endm

	            .mac oimd
	            hack	$72,{1},{2}
	            .endm

	            .mac oimx
	            hack	$62,{1},{2}
	            .endm

	            .mac eimd
	            hack	$75,{1},{2}
	            .endm

	            .mac eimx
	            hack	$65,{1},{2}
	            .endm

	            .mac timd
	            hack	$7b,{1},{2}
	            .endm

	            .mac timx
	            hack	$6b,{1},{2}
	            .endm