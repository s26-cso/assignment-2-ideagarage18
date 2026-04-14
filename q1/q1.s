    .section .text
    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost

make_node:
    addi sp, sp, -16
    sd   ra, 8(sp)
    sd   a0, 0(sp)          # save val – malloc will clobber a0

    li   a0, 24             # sizeof(Node) = 4 + 4 pad + 8 + 8
    call malloc

    ld   t1, 0(sp)          # restore val
    sw   t1,  0(a0)         # node->val   = val
    sd   x0,  8(a0)         # node->left  = NULL
    sd   x0, 16(a0)         # node->right = NULL

    ld   ra, 8(sp)
    addi sp, sp, 16
    ret

insert:
    addi sp, sp, -32
    sd   ra,  24(sp)
    sd   s0,  16(sp)        # s0 = root
    sd   s1,   8(sp)        # s1 = val

    mv   s0, a0
    mv   s1, a1

    beqz s0, insert_null    # root == NULL → create a node here

    lw   t0, 0(s0)          # t0 = root->val
    blt  s1, t0, insert_left
    bgt  s1, t0, insert_right
    mv   a0, s0
    j    insert_done

insert_left:
    ld   a0,  8(s0)         # a0 = root->left
    mv   a1, s1
    call insert
    sd   a0,  8(s0)         # root->left = returned node
    mv   a0, s0
    j    insert_done

insert_right:
    ld   a0, 16(s0)         # a0 = root->right
    mv   a1, s1
    call insert
    sd   a0, 16(s0)         # root->right = returned node
    mv   a0, s0
    j    insert_done

insert_null:
    mv   a0, s1
    call make_node           # returns new node in a0

insert_done:
    ld   ra,  24(sp)
    ld   s0,  16(sp)
    ld   s1,   8(sp)
    addi sp, sp, 32
    ret

get:
    
get_loop:
    beqz a0, get_done       # NULL → not found, a0 already 0

    lw   t0, 0(a0)          # t0 = current->val
    beq  t0, a1, get_done   # found – return a0

    blt  a1, t0, get_go_left

    # go right
    ld   a0, 16(a0)
    j    get_loop

get_go_left:
    ld   a0, 8(a0)
    j    get_loop

get_done:
    ret


getAtMost:
    li   t2, -1             # best = -1  

atmost_loop:
    beqz a1, atmost_return  # root == NULL → done

    lw   t0, 0(a1)          # t0 = current->val

    blt  a0, t0, atmost_left    # val < current then//go left

    mv   t2, t0
    beq  t0, a0, atmost_return  # exact match , can't do better

    ld   a1, 16(a1)
    j    atmost_loop

atmost_left:
    ld   a1, 8(a1)
    j    atmost_loop

atmost_return:
    mv   a0, t2
    ret