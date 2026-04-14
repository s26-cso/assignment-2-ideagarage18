.section .rodata
fmt: .asciz "%d "
newline: .asciz "\n"

.section .text
.global main
.global next_greater

main:
    addi sp, sp, -16
    sd ra, 0(sp)

    addi a0, a0, -1        # number of inputs and skip program namee
    call next_greater

    ld ra, 0(sp)
    addi sp, sp, 16
    li a0, 0
    ret


# a0 = n, a1 = argv
next_greater:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)

    mv s0, a0              # n
    mv s1, a1              # argv

    # make array for input values
    slli a0, s0, 2
    call malloc
    mv s2, a0

    # result array
    slli a0, s0, 2
    call malloc
    mv t6, a0

    # stack (stores indixes)
    slli a0, s0, 2
    call malloc
    mv t5, a0
    mv t4, t5              # top pointer

    li t0, 1               # argv index (skip program name)
    li t1, 0               # array index

read_loop:
    beq t1, s0, process

    slli t2, t0, 3         # get argv[i]
    add t3, s1, t2
    ld a0, 0(t3)
    call atoi

    slli t2, t1, 2
    add t3, s2, t2
    sw a0, 0(t3)

    addi t0, t0, 1
    addi t1, t1, 1
    j read_loop


process:
    addi t1, s0, -1        # start from right

main_loop:
    blt t1, zero, print

    # current value = arr[i]
    slli t2, t1, 2
    add t3, s2, t2
    lw t0, 0(t3)

pop_loop:
    beq t4, t5, empty_stack   # nothing in stack

    addi t2, t4, -4
    lw t3, 0(t2)              # top index

    slli t2, t3, 2
    add t2, s2, t2
    lw t2, 0(t2)              # arr[top]

    blt t0, t2, found         # found next greater

    addi t4, t4, -4           # pop and try again
    j pop_loop


found:
    # store index of next greater
    slli t2, t1, 2
    add t2, t6, t2
    sw t3, 0(t2)
    j push


empty_stack:
    # no greater element
    slli t2, t1, 2
    add t2, t6, t2
    li t0, -1
    sw t0, 0(t2)


push:
    sw t1, 0(t4)              # push current index
    addi t4, t4, 4

    addi t1, t1, -1
    j main_loop


print:
    li t1, 0

print_loop:
    beq t1, s0, done

    slli t2, t1, 2
    add t3, t6, t2
    lw a1, 0(t3)

    la a0, fmt
    call printf

    addi t1, t1, 1
    j print_loop


done:
    la a0, newline
    call printf

    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    addi sp, sp, 32
    ret