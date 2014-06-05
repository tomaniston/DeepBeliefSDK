include(`helpers.asm')

define(`A_VECTORS_PER_PASS', 4)
define(`VECTORS_PER_PASS', 8)
define(`ELEMENTS_PER_PASS', `eval(VECTORS_PER_PASS * 16)')
define(`ELEMENTS_PER_PASS_MINUS_ONE', `eval(ELEMENTS_PER_PASS - 1)')
define(`A_BYTES_PER_PASS', `eval(ELEMENTS_PER_PASS * 2)')
define(`B_BYTES_PER_PASS', `eval(ELEMENTS_PER_PASS * 4)')
define(`ELEMENTS_PER_FINISH_PASS', 16)
define(`ELEMENTS_PER_FINISH_PASS_MINUS_ONE', `eval(ELEMENTS_PER_FINISH_PASS - 1)')
define(`A_BYTES_PER_FINISH_PASS', `eval(ELEMENTS_PER_FINISH_PASS * 2)')
define(`B_BYTES_PER_FINISH_PASS', `eval(ELEMENTS_PER_FINISH_PASS * 4)')
define(`NUM_QPUS', 8)
define(`ALL_DONE_SEMA', 0)

# Register allocations
define(`rM', ra0)
define(`rN', ra1)
define(`rK', ra2)
define(`rAlpha', ra3)
define(`rAAddress', ra4)
define(`rAMin', ra5)
define(`rARange', ra6)
define(`rLDA', ra7)
define(`rBAddress', ra8)
define(`rLDB', ra9)
define(`rBeta', ra10)
define(`rCAddress', ra11)
define(`rLDC', ra12)
define(`rDebugAddress', ra24)
define(`rWhichQPU', ra26)

define(`rI', ra13)
define(`rJ', ra14)
define(`rL', ra15)
define(`rCurrentA', ra16)
define(`rCurrentB', ra17)
define(`rCurrentC', ra20)
define(`rElementsToRead', ra23)
define(`rDebugOutput', ra25)
define(`rDMALoadAddrY', ra27)
define(`rVPMReadAddr', ra28)
define(`rVPMWriteAddr', ra29)
define(`rDMAStoreAddrY', ra30)
define(`rAVPMReadAddr', ra31)
# Warning - overloading raMisc register, beware of clashes if the scope expands
define(`raMisc', `rCurrentC')
define(`rA0to15', rb0)
define(`rA16to31', rb1)
define(`rA32to47', rb2)
define(`rA48to63', rb3)
define(`rA64to79', rb4)
define(`rA80to95', rb5)
define(`rA96to111', rb6)
define(`rA112to127', rb7)
define(`rBaseMask', rb8)
define(`rElementCountMask', rb9)
define(`rRowsToLoad', rb10)
define(`rElementsRemaining', rb11)
define(`rMaskShift', rb12)
define(`rElementsPerVector', rb13)
define(`r2A0to15', rb14)
define(`r2A16to31', rb15)
define(`r2A32to47', rb16)
define(`r2A48to63', rb17)
define(`r2A64to79', rb18)
define(`r2A80to95', rb19)
define(`r2A96to111', rb20)
define(`r2A112to127', rb21)

define(`rAccum0', r0)
define(`rAccum1', r1)
define(`rAccum2', r2)
define(`rTotal', r3)

# Load arguments
or rM, raReadUniform, 0; nop
or rN, raReadUniform, 0; nop
or rK, raReadUniform, 0; nop
or rAlpha, raReadUniform, 0; nop
or rAAddress, raReadUniform, 0; nop
or rAMin, raReadUniform, 0; nop
or rARange, raReadUniform, 0; nop
or rLDA, raReadUniform, 0; nop
or rBAddress, raReadUniform, 0; nop
or rLDB, raReadUniform, 0; nop
or rBeta, raReadUniform, 0; nop
or rCAddress, raReadUniform, 0; nop
or rLDC, raReadUniform, 0; nop
or rDebugAddress, raReadUniform, 0; nop
or rWhichQPU, raReadUniform, 0; nop

ldi rDebugOutput, 0x3f000000

nop rb39, r0, r0; mul24 rTotal, rWhichQPU, VECTORS_PER_PASS
ldi rAccum0, VPM_DMA_LOAD_SETUP_ADDRY_SHIFT
shl rDMALoadAddrY, rTotal, rAccum0; nop
ldi rAccum0, VPM_BLOCK_READ_SETUP_ADDR_SHIFT
shl rVPMReadAddr, rTotal, rAccum0; nop
add rAccum0, rAccum0, 1; nop
shl rAVPMReadAddr, rTotal, rAccum0; nop
ldi rAccum0, VPM_BLOCK_WRITE_SETUP_ADDR_SHIFT
shl rVPMWriteAddr, rTotal, rAccum0; nop
ldi rAccum0, VPM_DMA_STORE_SETUP_ADDRY_SHIFT
shl rDMAStoreAddrY, rTotal, rAccum0; nop

ldi rAccum0, [0, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
ldi rAccum1, [0, 0, 0, 0, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
add rAccum0, rAccum0, rAccum1; nop
ldi rAccum1, [0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 3, 3, 3, 3, 3]
add rAccum0, rAccum0, rAccum1; nop
ldi rAccum1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 3, 3]
add rAccum0, rAccum0, rAccum1; nop
ldi rAccum1, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3]
add rBaseMask, rAccum0, rAccum1; nop

or rI, rWhichQPU, 0; nop
loop_i:
or rAccum0, rM, 0; nop
sub ra39, rI, rAccum0; nop
brr.ne ra39, loop_i_break
NOP
NOP
NOP

ldi rJ, 0
loop_j:
or rAccum0, rN, 0; nop
sub ra39, rJ, rAccum0; nop
brr.ne ra39, loop_j_break
NOP
NOP
NOP

shl rAccum0, rLDA, 1; nop
nop rb39, r0, r0; mul24 rAccum0, rI, rAccum0
add rCurrentA, rAAddress, rAccum0; nop

shl rAccum0, rLDB, 2; nop
nop rb39, r0, r0; mul24 rAccum0, rJ, rAccum0
add rCurrentB, rBAddress, rAccum0; nop

ldi rTotal, 0

ldi rL, 0
main_loop_l:
ldi rAccum0, ELEMENTS_PER_PASS_MINUS_ONE
sub rAccum0, rK, rAccum0; nop
sub ra39, rL, rAccum0; nop
brr.ne ra39, main_loop_l_break
NOP
NOP
NOP

ldi rAccum0, ELEMENTS_PER_PASS
and rAccum0, rL, rAccum0; nop
brr.zc rAccum0, skip_a_load
NOP
NOP
NOP

define(`MPITCH', 2)
define(`ROWLEN', 16)
define(`NROWS', VECTORS_PER_PASS)
define(`VPITCH', 1)
define(`ADDRY', 0)
define(`ADDRX', 0)
ldi rAccum0, VPM_DMA_LOAD_SETUP_VALUE(MODEW_32_BIT, MPITCH, ROWLEN, NROWS, VPITCH, NOT_VERT, ADDRY, ADDRX)
or ra49, rAccum0, rDMALoadAddrY; nop

MUTEX_ACQUIRE()
VPM_DMA_LOAD_START(rCurrentA)
MUTEX_RELEASE()
VPM_DMA_LOAD_WAIT_FOR_COMPLETION()

define(`NUM', 0)
define(`STRIDE', 1)
define(`ADDR', 0)
ldi rAccum0, VPM_BLOCK_READ_SETUP_VALUE(NUM, STRIDE, IS_HORIZ, NOT_LANED, SIZE_16_BIT, ADDR)
or ra49, rAccum0, rAVPMReadAddr; nop

# Read 128 A values from VPM
ldi rAccum0, 0x0000ffff
and.unpack16a rA0to15, rVpmReadFifo, rAccum0; nop
and.unpack16a rA16to31, rVpmReadFifo, rAccum0; nop
and.unpack16a rA32to47, rVpmReadFifo, rAccum0; nop
and.unpack16a rA48to63, rVpmReadFifo, rAccum0; nop
and.unpack16a rA64to79, rVpmReadFifo, rAccum0; nop
and.unpack16a rA80to95, rVpmReadFifo, rAccum0; nop
and.unpack16a rA96to111, rVpmReadFifo, rAccum0; nop
and.unpack16a rA112to127, rVpmReadFifo, rAccum0; nop

and.unpack16a r2A0to15, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A16to31, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A32to47, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A48to63, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A64to79, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A80to95, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A96to111, rVpmReadFifo, rAccum0; nop
and.unpack16a r2A112to127, rVpmReadFifo, rAccum0; nop

itof rA0to15, rA0to15, rA0to15; nop
itof rA16to31, rA16to31, rA16to31; nop
itof rA32to47, rA32to47, rA32to47; nop
itof rA48to63, rA48to63, rA48to63; nop
itof rA64to79, rA64to79, rA64to79; nop
itof rA80to95, rA80to95, rA80to95; nop
itof rA96to111, rA96to111, rA96to111; nop
itof rA112to127, rA112to127, rA112to127; nop

brr ra39, after_a_load
NOP
NOP
NOP

skip_a_load:

itof rA0to15, r2A0to15, r2A0to15; nop
itof rA16to31, r2A16to31, r2A16to31; nop
itof rA32to47, r2A32to47, r2A32to47; nop
itof rA48to63, r2A48to63, r2A48to63; nop
itof rA64to79, r2A64to79, r2A64to79; nop
itof rA80to95, r2A80to95, r2A80to95; nop
itof rA96to111, r2A96to111, r2A96to111; nop
itof rA112to127, r2A112to127, r2A112to127; nop

after_a_load:

define(`MPITCH', 2)
define(`ROWLEN', 16)
define(`NROWS', VECTORS_PER_PASS)
define(`VPITCH', 1)
define(`ADDRY', 0)
define(`ADDRX', 0)
ldi rAccum0, VPM_DMA_LOAD_SETUP_VALUE(MODEW_32_BIT, MPITCH, ROWLEN, NROWS, VPITCH, NOT_VERT, ADDRY, ADDRX)
or ra49, rAccum0, rDMALoadAddrY; nop

MUTEX_ACQUIRE()
VPM_DMA_LOAD_START(rCurrentB)
MUTEX_RELEASE()

or rAccum0, rARange, 0; nop
or rAccum1, rAMin, 0; nop
nop ra39, r0, r0; fmul rAccum2, rA0to15, rAccum0
fadd rA0to15, rAccum2, rAccum1; fmul rAccum2, rA16to31, rAccum0
fadd rA16to31, rAccum2, rAccum1; fmul rAccum2, rA32to47, rAccum0
fadd rA32to47, rAccum2, rAccum1; fmul rAccum2, rA48to63, rAccum0
fadd rA48to63, rAccum2, rAccum1; fmul rAccum2, rA64to79, rAccum0
fadd rA64to79, rAccum2, rAccum1; fmul rAccum2, rA80to95, rAccum0
fadd rA80to95, rAccum2, rAccum1; fmul rAccum2, rA96to111, rAccum0
fadd rA96to111, rAccum2, rAccum1; fmul rAccum2, rA112to127, rAccum0
fadd rA112to127, rAccum2, rAccum1; nop

VPM_DMA_LOAD_WAIT_FOR_COMPLETION()

define(`NUM', VECTORS_PER_PASS)
define(`STRIDE', 1)
define(`ADDR', 0)
ldi rAccum0, VPM_BLOCK_READ_SETUP_VALUE(NUM, STRIDE, IS_HORIZ, NOT_LANED, SIZE_32_BIT, ADDR)
or ra49, rAccum0, rVPMReadAddr; nop

# Read 128 B values from VPM
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA0to15, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA16to31, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA32to47, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA48to63, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA64to79, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA80to95, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA96to111, rAccum0
fadd rTotal, rTotal, rAccum0; nop

or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA112to127, rAccum0
fadd rTotal, rTotal, rAccum0; nop

ldi rAccum0, A_BYTES_PER_PASS
add rCurrentA, rCurrentA, rAccum0; nop
ldi rAccum0, B_BYTES_PER_PASS
add rCurrentB, rCurrentB, rAccum0; nop

ldi rAccum0, ELEMENTS_PER_PASS
add rL, rL, rAccum0; nop
brr ra39, main_loop_l
NOP
NOP
NOP

main_loop_l_break:

finish_loop_l:

or rAccum0, rK, 0; nop
sub ra39, rL, rAccum0; nop
brr.ne ra39, finish_loop_l_break
NOP
NOP
NOP

or rAccum0, rK, 0; nop
sub rAccum0, rAccum0, rL; nop
or rElementsRemaining, rAccum0, rAccum0; nop

ldi rAccum1, ELEMENTS_PER_PASS
and rAccum1, rL, rAccum1; nop
brr.zc rAccum1, finish_skip_a_load
NOP
NOP
NOP

ldi rAccum1, 31
add rAccum0, rAccum0, rAccum1; nop
shr rAccum0, rAccum0, 5; nop
ldi rAccum1, VPM_DMA_LOAD_SETUP_NROWS_SHIFT
shl rAccum1, rAccum0, rAccum1; nop
define(`MPITCH', 2)
define(`ROWLEN', 16)
define(`NROWS', 0)
define(`VPITCH', 1)
define(`ADDRY', 0)
define(`ADDRX', 0)
ldi rAccum0, VPM_DMA_LOAD_SETUP_VALUE(MODEW_32_BIT, MPITCH, ROWLEN, NROWS, VPITCH, NOT_VERT, ADDRY, ADDRX)
or rAccum0, rAccum0, rDMALoadAddrY; nop
or ra49, rAccum0, rAccum1; nop

MUTEX_ACQUIRE()
VPM_DMA_LOAD_START(rCurrentA)
MUTEX_RELEASE()
VPM_DMA_LOAD_WAIT_FOR_COMPLETION()

define(`NUM', VECTORS_PER_PASS)
define(`STRIDE', 1)
define(`ADDR', 0)
ldi rAccum0, VPM_BLOCK_READ_SETUP_VALUE(NUM, STRIDE, IS_HORIZ, NOT_LANED, SIZE_16_BIT, ADDR)
or ra49, rAccum0, rAVPMReadAddr; nop

# Read 128 A values from VPM
ldi rAccum0, 0x0000ffff
and.unpack16a rA0to15, rVpmReadFifo, rAccum0; nop
and.unpack16a rA16to31, rVpmReadFifo, rAccum0; nop
and.unpack16a rA32to47, rVpmReadFifo, rAccum0; nop
and.unpack16a rA48to63, rVpmReadFifo, rAccum0; nop
and.unpack16a rA64to79, rVpmReadFifo, rAccum0; nop
and.unpack16a rA80to95, rVpmReadFifo, rAccum0; nop
and.unpack16a rA96to111, rVpmReadFifo, rAccum0; nop
and.unpack16a rA112to127, rVpmReadFifo, rAccum0; nop

itof rA0to15, rA0to15, rA0to15; nop
itof rA16to31, rA16to31, rA16to31; nop
itof rA32to47, rA32to47, rA32to47; nop
itof rA48to63, rA48to63, rA48to63; nop
itof rA64to79, rA64to79, rA64to79; nop
itof rA80to95, rA80to95, rA80to95; nop
itof rA96to111, rA96to111, rA96to111; nop
itof rA112to127, rA112to127, rA112to127; nop

brr ra39, finish_after_a_load
NOP
NOP
NOP

finish_skip_a_load:

itof rA0to15, r2A0to15, r2A0to15; nop
itof rA16to31, r2A16to31, r2A16to31; nop
itof rA32to47, r2A32to47, r2A32to47; nop
itof rA48to63, r2A48to63, r2A48to63; nop
itof rA64to79, r2A64to79, r2A64to79; nop
itof rA80to95, r2A80to95, r2A80to95; nop
itof rA96to111, r2A96to111, r2A96to111; nop
itof rA112to127, r2A112to127, r2A112to127; nop

finish_after_a_load:

or rAccum0, rARange, 0; nop
nop ra39, r0, r0; fmul rA0to15, rA0to15, rAccum0
nop ra39, r0, r0; fmul rA16to31, rA16to31, rAccum0
nop ra39, r0, r0; fmul rA32to47, rA32to47, rAccum0
nop ra39, r0, r0; fmul rA48to63, rA48to63, rAccum0
nop ra39, r0, r0; fmul rA64to79, rA64to79, rAccum0
nop ra39, r0, r0; fmul rA80to95, rA80to95, rAccum0
nop ra39, r0, r0; fmul rA96to111, rA96to111, rAccum0
nop ra39, r0, r0; fmul rA112to127, rA112to127, rAccum0

or rAccum0, rAMin, 0; nop
fadd rA0to15, rA0to15, rAccum0;  nop
fadd rA16to31, rA16to31, rAccum0;  nop
fadd rA32to47, rA32to47, rAccum0;  nop
fadd rA48to63, rA48to63, rAccum0;  nop
fadd rA64to79, rA64to79, rAccum0;  nop
fadd rA80to95, rA80to95, rAccum0;  nop
fadd rA96to111, rA96to111, rAccum0;  nop
fadd rA112to127, rA112to127, rAccum0;  nop

ldi rAccum1, 15
add rAccum0, rElementsRemaining, rAccum1; nop
shr rAccum0, rAccum0, 4; nop
ldi rAccum1, VPM_DMA_LOAD_SETUP_NROWS_SHIFT
shl rAccum1, rAccum0, rAccum1; nop
define(`MPITCH', 2)
define(`ROWLEN', 16)
define(`NROWS', 0)
define(`VPITCH', 1)
define(`ADDRY', 0)
define(`ADDRX', 0)
ldi rAccum0, VPM_DMA_LOAD_SETUP_VALUE(MODEW_32_BIT, MPITCH, ROWLEN, NROWS, VPITCH, NOT_VERT, ADDRY, ADDRX)
or rAccum0, rAccum0, rDMALoadAddrY; nop
or ra49, rAccum0, rAccum1; nop

MUTEX_ACQUIRE()
VPM_DMA_LOAD_START(rCurrentB)
MUTEX_RELEASE()
VPM_DMA_LOAD_WAIT_FOR_COMPLETION()

define(`NUM', VECTORS_PER_PASS)
define(`STRIDE', 1)
define(`ADDR', 0)
ldi rAccum0, VPM_BLOCK_READ_SETUP_VALUE(NUM, STRIDE, IS_HORIZ, NOT_LANED, SIZE_32_BIT, ADDR)
or ra49, rAccum0, rVPMReadAddr; nop

ldi rMaskShift, 31
ldi rElementsPerVector, 16

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA0to15, rAccum0
and rAccum0, rAccum0, rAccum1; nop

fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA16to31, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA32to47, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA48to63, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA64to79, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA80to95, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA96to111, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

or rAccum1, rElementsRemaining, rElementsRemaining; nop
sub rElementsRemaining, rAccum1, rElementsPerVector; nop
sub rAccum0, rBaseMask, rAccum1; nop
asr rAccum1, rAccum0, rMaskShift; nop
or rAccum0, rVpmReadFifo, 0;  nop
nop rb39, r0, r0; fmul rAccum0, rA112to127, rAccum0
and rAccum0, rAccum0, rAccum1; nop
fadd rTotal, rTotal, rAccum0; nop

finish_loop_l_break:

or r0, rTotal, 0; nop
or r3, rTotal, 0; nop
nop rb39, r0, <<1; v8max r0, r0, r0
fadd rTotal, rTotal, r0; nop
or r0, rTotal, 0; nop
or r3, rTotal, 0; nop
nop rb39, r0, <<2; v8max r0, r0, r0
fadd rTotal, rTotal, r0; nop
or r0, rTotal, 0; nop
or r3, rTotal, 0; nop
nop rb39, r0, <<4; v8max r0, r0, r0
fadd rTotal, rTotal, r0; nop
or r0, rTotal, 0; nop
or r3, rTotal, 0; nop
nop rb39, r0, <<8; v8max r0, r0, r0
fadd rTotal, rTotal, r0; nop

nop rb39, r0, r0; fmul rTotal, rTotal, rAlpha;

define(`STRIDE', 1)
define(`ADDR', 0)
ldi rAccum0, VPM_BLOCK_WRITE_SETUP_VALUE(STRIDE, IS_HORIZ, NOT_LANED, SIZE_32_BIT, ADDR)
or rb49, rAccum0, rVPMWriteAddr; nop

or rVpmWriteFifo, rTotal, 0; nop

shl rAccum0, rLDC, 2; nop
nop rb39, r0, r0; mul24 rAccum0, rJ, rAccum0
add rCurrentC, rCAddress, rAccum0; nop
shl rAccum0, rI, 2; nop
add rCurrentC, rCurrentC, rAccum0; nop

define(`UNITS', 1)
define(`DEPTH', 1)
define(`ADDRY', 0)
define(`ADDRX', 0)
ldi rAccum0, VPM_DMA_STORE_SETUP_VALUE(UNITS, DEPTH, IS_HORIZ, ADDRY, ADDRX, MODEW_32_BIT)
or rb49, rAccum0, rDMAStoreAddrY; nop

MUTEX_ACQUIRE()
VPM_DMA_STORE_START(rCurrentC)
MUTEX_RELEASE()
VPM_DMA_STORE_WAIT_FOR_COMPLETION()

add rJ, rJ, 1; nop
brr ra39, loop_j
NOP
NOP
NOP

loop_j_break:

add rI, rI, NUM_QPUS; nop
brr ra39, loop_i
NOP
NOP
NOP

loop_i_break:

define(`STRIDE', 1)
define(`ADDR', 0)
ldi rAccum0, VPM_BLOCK_WRITE_SETUP_VALUE(STRIDE, IS_HORIZ, NOT_LANED, SIZE_32_BIT, ADDR)
or rb49, rAccum0, rVPMWriteAddr; nop

or rVpmWriteFifo, rDebugOutput, 0; nop

define(`UNITS', 1)
define(`DEPTH', 16)
define(`ADDRY', 0)
define(`ADDRX', 0)
ldi rAccum0, VPM_DMA_STORE_SETUP_VALUE(UNITS, DEPTH, IS_HORIZ, ADDRY, ADDRX, MODEW_32_BIT)
or rb49, rAccum0, rDMAStoreAddrY; nop

MUTEX_ACQUIRE()
VPM_DMA_STORE_START(rDebugAddress)
MUTEX_RELEASE()
VPM_DMA_STORE_WAIT_FOR_COMPLETION()

sema up, ALL_DONE_SEMA

or rb39, rWhichQPU, 0; nop
brr.zc rb39, non_master_finish
NOP
NOP
NOP

# The number of 'down's must match the number of QPUs being run
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA
sema down, ALL_DONE_SEMA

END_PROGRAM_HARD()

non_master_finish:

END_PROGRAM_SOFT()