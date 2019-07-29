	section text

	jsr initialise
	jsr music_init
	bclr #0,$484
	
piccy	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ff8240

	move.l 	#screen,d0	;get screen address
	clr.b 	d0			;round to 256 byte boundary
	move.l	d0,a0		;copy to a0
	clr.b	$ff820d		;clear vid address low byte (ste)
	lsr.l	#8,d0
	move.b	d0,$ff8203	;set vid address mid byte
	lsr.w	#8,d0
	move.b	d0,$ff8201	;set vid address high byte

	move.l	#picture+34,a1
	move.l	#(32000/4)-1,d0
.loop1	move.l	(a1)+,(a0)+		;copy pic to screen
	dbf	d0,.loop1
	move.l	#((160*10)/4)-1,d0
.loop2	move.l	#0,(a0)+
	dbf	d0,.loop2
	move.l	#picture+34,a1
	move.l	#((160*78)/4)-1,d0

	move.l	#backup,a0
	move.l	$70,(a0)+		;backup vector $70 (VBL)
	move.l	$120,(a0)+		;backup vector $120 (timer b)
	move.b	$fffa07,(a0)+		;backup enable a
	move.b	$fffa13,(a0)+		;backup mask a
	move.b	$fffa15,(a0)+		;backup mask b
	move.b	$fffa1b,(a0)+		;backup timer b control
	move.b	$fffa31,(a0)+		;backup timer b data

	move.l	#vbl,$70

wait	cmp.b	#57,$FFFFFC02
	bne.s	wait
	jsr music_deinit
	bset #0,$484.w

	move.l	#backup,a0
	move.l	(a0)+,$70		;restore vector $70 (vbl)
	move.l	(a0)+,$120		;restore vector $120 (timer b)
	move.b	(a0)+,$fffa07		;restore enable a
	move.b	(a0)+,$fffa13		;restore mask a
	move.b	(a0)+,$fffa15		;restore mask b
	move.b	(a0)+,$fffa1b		;restore timer b control
	move.b	(a0)+,$fffa21		;restore timer b data

	jsr restore

	clr.w -(sp)			;exit
	trap #1

*** VBL Routine ***
vbl
	movem.l	d0-d7/a0-a6,-(sp)	;backup registers
	jsr music_play
	movem.l	(sp)+,d0-d7/a0-a6	;restore registers
	rte



music_init:
	jsr	music_lance_pt50_init
	rts

music_deinit:
	jsr	music_lance_pt50_exit
	rts

music_play:
	jsr	music_lance_pt50_play
	rts
		
	include 'ice_dpck.s'
	include	'initlib.s'
	include	'pt_src50.s'		;Protracker player, Lance 50 kHz (STe)


	section	data

picture	incbin	a8_320.pi1
music	incbin	androids.snd	

blackpal:
		dcb.w	16,$0000			;Black palette
	section	bss
		
	ds.b	256
screen	ds.b	160*288
backup	ds.b	14
depack	ds.b	20000