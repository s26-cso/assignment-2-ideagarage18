.section .bss
ch_left:  .space 1          
ch_right: .space 1          # 1-byte buffer for left adn right char

.section .rodata
print_str: .asciz "%s\n"   # for printf fornat string

.section .data
filename: .asciz "input.txt"   # input file name
yes: .asciz "Yes"               
no:  .asciz "No"               

.section .text
.globl main

main:
    addi sp, sp, -40
    sd ra,0(sp)    # return address
    sd s0,8(sp)    # fd
    sd s1, 16(sp)    # file size /
    sd s2, 24(sp)    # left pointer
    sd s3, 32(sp)    # right pointer

    li a0, -100        # current dir
    la a1, filename    # pointer to filename  
    li a2, 0           # O_RDONLY
    li a3, 0           # mode unused
    li a7, 56          # syscall: openat
    ecall
    mv  s0, a0          # save fd

    mv  a0, s0
    li  a1, 0           # offset = 0
    li  a2, 2           # SEEK_END
    li  a7, 62          # syscall: lseek
    ecall
    mv  s1, a0          # a0 had store the file size, transferred to s1

    # yahape it check if last byte is '\n' 
    mv  a0, s0
    addi a1, s1, -1     
    li  a2, 0           # SEEK_SET
    li  a7, 62          # syscall: lseek
    ecall

    mv  a0, s0
    la  a1, ch_left     # reuse ch_left buffer temporarily
    li  a2, 1           # read 1 byte
    li  a7, 63          # syscall: read
    ecall

    la  t0, ch_left
    lb  t1, 0(t0)       # t1 = last byte of file
    li  t2, 10          # 10 askii for newline symbol
    bne t1, t2, no_newline  # if not newline, skip decrement
    addi s1, s1, -1     # strip newline from the end
no_newline:

    # to make empty strigs palindrome
    beqz s1, is_pal

    # lseek(fd, 0, SEEK_SET) — reset pointer back to start
    mv  a0, s0
    li  a1, 0           # offset = 0
    li  a2, 0           # SEEK_SET, basically puts pointer back to start
    li  a7, 62          # syscall: lseek
    ecall

    li   s2, 0          # left  = 0
    addi s3, s1, -1     # right = size - 1

check_loop:
    bge s2, s3, is_pal  # if left >= right, that ye ek palimdrome hai

    # lseek to left position
    mv  a0, s0
    mv  a1, s2          # offset = left index
    li  a2, 0           # SEEK_SET
    li  a7, 62          # syscall: lseek
    ecall

    # read 1 char at left position
    mv  a0, s0
    la  a1, ch_left     # <-- was "chL" (undefined label)
    li  a2, 1           # read 1 byte
    li  a7, 63          # syscall: read
    ecall

    # right
    mv  a0, s0
    mv  a1, s3          
    li  a2, 0         
    li  a7, 62          
    ecall

    mv  a0, s0
    la  a1, ch_right   
    li  a2, 1           
    li  a7, 63          
    ecall

    # compare
    la  t0, ch_left
    lb  t1, 0(t0)       # t1 = left char
    la  t0, ch_right
    lb  t2, 0(t0)       # t2 = right char
    bne t1, t2, not_pal # main comparison 

    addi s2, s2, 1      
    addi s3, s3, -1     # eft++,right--
    j check_loop

is_pal:
    la a1, yes        
    j print

not_pal:
    la a1, no          

print:
    la  a0, print_str   
    call printf         # printf(print_str, a1)

    ld ra,  0(sp)
    ld s0,  8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)       # restore saved registers
    addi sp, sp, 40     # free stack memory
    ret