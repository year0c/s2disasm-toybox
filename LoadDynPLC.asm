; ---------------------------------------------------------------------------
; Subroutine to load a Dynamic Pattern Load Cues request into the DMA queue.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

LoadDynPLC:
	andi.w	#$FF,d0			; mask out anything except the input frame
	add.w	d0,d0			; double ID (for word-based indexing)
	adda.w	(a2,d0.w),a2		; find current DPLC entry
	move.w	(a2)+,d5		; get number of tasks in this DPLC entry
	subq.w	#1,d5			; subtract 1 from number of tasks (will be the loop count)
	bmi.w	PLC_Return		; if it underflowed, this is an empty entry, nothing to do

PLC_ReadEntry:
	moveq	#0,d1			; clear d1
	move.w	(a2)+,d1		; get first byte of DPLC task
	move.w	d1,d3			; copy to d3
	lsr.w	#8,d3			; shift upper byte to lower byte
	andi.w	#$F0,d3			; only look at upper nybble
	addi.w	#$10,d3			; add 1 to that nybble
	andi.w	#$FFF,d1		; mask out that nybble in the other part
	lsl.l	#5,d1			; multiply by 32
	add.l	d6,d1			; add art location
	move.w	d4,d2			; set target VRAM location
	add.w	d3,d4			; advance VRAM pointer
	add.w	d3,d4			; (twice, for word-based tiles)
	bsr.w	QueueDMATransfer	; load DMA request into queue
	dbf	d5,PLC_ReadEntry	; repeat for number of entries

PLC_Return:
	rts				; return
; End of function LoadDynPLC