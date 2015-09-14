/*
 *  linux/arch/arm/lib/copypage.S
 *
 *  Copyright (C) 1995-1999 Russell King
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 *  ASM optimised string functions
 */
#include <linux/linkage.h>
#include <asm/assembler.h>
#include <asm/asm-offsets.h>
#include <asm/cache.h>

#define COPY_COUNT (PAGE_SZ / (2 * L1_CACHE_BYTES) PLD( -1 ))

		.text
		.align	5
/*
 * StrongARM optimised copy_page routine
 * now 1.78bytes/cycle, was 1.60 bytes/cycle (50MHz bus -> 89MB/s)
 * Note that we probably achieve closer to the 100MB/s target with
 * the core clock switching.
 */

#define COPY_COUNT (PAGE_SZ / (L1_CACHE_BYTES))

		.text
	ARM(	.p2align 5	)
	THUMB(	.p2align 2	)
 ENTRY(copy_page)
		stmfd	sp!, {r4-r8, lr}
 	PLD(	pld	[r1, #0]		)		 	PLD(	pld	[r1, #0]		)
 	PLD(	pld	[r1, #L1_CACHE_BYTES]		)		 	PLD(	pld	[r1, #L1_CACHE_BYTES]		)
#if PREFETCH_DISTANCE > 2
	PLD(	pld	[r1, #2 * L1_CACHE_BYTES]	)
#if PREFETCH_DISTANCE > 3
	PLD(	pld	[r1, #3 * L1_CACHE_BYTES]	)
#if PREFETCH_DISTANCE > 4
	PLD(	pld	[r1, #4 * L1_CACHE_BYTES]	)
#endif
#endif
#endif
	PLD(	movs	r2, #(COPY_COUNT - PREFETCH_DISTANCE)	)
	NO_PLD(	mov	r2, #COPY_COUNT				)
1:	PLD(	pld	[r1, #PREFETCH_DISTANCE * L1_CACHE_BYTES])
2:
	.rept	(2 * L1_CACHE_BYTES / 16 - 1)
		stmia	r0!, {r3, r4, ip, lr}		@	4
		ldmia	r1!, {r3, r4, ip, lr}		@	4
	.endr
		subs	r2, r2, #1			@	1
		stmia	r0!, {r3, r4, ip, lr}		@	4
		ldmgtia	r1!, {r3, r4, ip, lr}		@	4
		bgt	1b				@	1
	PLD(	ldmeqia r1!, {r3, r4, ip, lr}	)
	PLD(	beq	2b			)
		ldmfd	sp!, {r4, pc}			@	3
ENDPROC(copy_page)
