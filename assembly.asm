load ax, lo, 0x1;
load bx, lo, 0x1;
noop;
add cx, ax, bx;
mov ax, cx;
jmp 0x2;