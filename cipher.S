.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:	
								# PROLOGUE - start
	pushq %rbp					# 
	movq %rsp, %rbp				# 
								# PROLOGUE - end

	xorq %rax, %rax				# rax = 0
	movq %rdi, %rcx				# rcx = &input
	movq %rsi, %r8				# r8 = &key
km_loop:
	cmpq $16, %rax				# if rax == 16:
	je km_end					#	end()
	movb (%r8), %dl			# r8 = *(key + offset)
	xorb %dl, (%rcx)			# *(input + offset) = *(input + offset) XOR *(key + offset) 
	addq $1, %rcx				# rcx += 1
	addq $1, %r8				# r8 += 1
	incq %rax					# rax += 1
	jmp km_loop					# goto km_loop()
km_end:
					 			# EPILOGUE - start
	movq %rbp, %rsp  			#	
	popq %rbp		 			# leave
	ret				 			#
					 			# EPILOGUE - end





byteSubstitution:
								# PROLOGUE - start
	pushq %rbp					# 
	movq %rsp, %rbp				# 
								# PROLOGUE - end

	movq %rdi, %rcx				# rcx = &input
	xorq %rax, %rax				# rax = 0
bs_loop:	
	cmpq $16, %rax				# if rax == 16:	
	je bs_end					# 	end()
	xorq %rdx, %rdx
	movb (%rcx), %dl			# dl = *(input + offset)
	leaq sbox(%rip), %r8		# r8 = &sbox
	addq %rdx, %r8 				# r8 = &sbox + *(input + offset)
	movb (%r8), %dl				# dl = *(&sbox + *(input + offset))
	movb %dl, (%rcx)			# *(input + offset) = ^
	incq %rax					# rax++
	incq %rcx					# rcx++
	jmp bs_loop					# jump_to(bs_loop)
bs_end:
					 			# EPILOGUE - start
	movq %rbp, %rsp  			#	
	popq %rbp		 			# leave
	ret				 			#
					 			# EPILOGUE - end



shiftRows:
								# PROLOGUE - start
	pushq %rbp					# 
	movq %rsp, %rbp				# 
								# PROLOGUE - end
	
	movl 4(%rdi), %ecx			# line 1
	rorl $8, %ecx				# shift 8 bits (1 byte)
	movl %ecx, 4(%rdi)
	movl 8(%rdi), %ecx 			# line 2
	rorl $16, %ecx				# shift 16 bits (2 byte)
	movl %ecx, 8(%rdi)
	movl 12(%rdi), %ecx			# line 3
	rorl $24, %ecx				# shift 24 bits (3 byte)
	movl %ecx, 12(%rdi)

sr_end:
					 			# EPILOGUE - start
	movq %rbp, %rsp  			#	
	popq %rbp		 			# leave
	ret				 			#
					 			# EPILOGUE - end


cipher:
								# PROLOGUE - start
	pushq %rbp					# 
	movq %rsp, %rbp				# 
								# PROLOGUE - end
	
	xorq %r9, %r9				# r9 = 0
	movq %rdx, %r10 			# r10 = len

chiper_main_loop:				# 1. do len times:
	cmpq %r10, %r9
	je cipher_end
	call keyMixing				# 		a. Key Mixing
	xorq %r11, %r11				
chiper_inner_loop:				# 		b. do 9 times:
	cmpq $9, %r11
	je chiper_inner_end
	call byteSubstitution		# 				i. byte Substitution
	call shiftRows				# 				ii. shift Rows
	pushq %rsi
	pushq %rdi
	call mixColumns				# 				iii. mix Columns
	popq %rdi
	popq %rsi
	call keyMixing				# 				iv. Key Mixing

	incq %r11
	jmp chiper_inner_loop

chiper_inner_end:

	call byteSubstitution		# 		c. byte Substitution
	call shiftRows				# 		d. shift Rows
	call keyMixing				# 		e. Key Mixing

	addq $16, %rdi
	incq %r9
	jmp chiper_main_loop

cipher_end:
					 			# EPILOGUE - start
	movq %rbp, %rsp  			#	
	popq %rbp		 			# leave
	ret				 			#
					 			# EPILOGUE - end
