;-------------------------------------;
; Too Many Flies (Shit In Da Corner)  ;
; 256-byte intro by ERN0, 1998.08.15  ;
; (Reformatted for FASM, 2018.05.17)  ;
;-------------------------------------;
; ******* ***     *** *******  *****  ;
; ***     ***     *** ***     ***     ;
; ******  ***     *** ******   *****  ;
; ***     ***     *** ***         *** ;
; ***     ******* *** ******* ******  ;
;-------------------------------------;
;      mailto:ern0@linkbroker.hu      ;
;        http://linkbroker.hu/        ;
; ------------------------------------;
;
; I have no time to code a whole demo, suck with music player, protected
; mode and so on, so if I wanna release something, this is the only way.


; .286            ; Lamer 80286 code

FLIES     equ     222     ; No of flies
SEEDPLUZ  equ     19      ; Random generator
BAZE      equ     1000H   ; BX base
SLEN      equ     20H     ; Structure length
COLPLUZ   equ     21      ; Next Fly's brightest color offset
DECR      equ     3       ; Darker color offset
SPEEDQ    equ     24447   ; Speed divisor


; The structure
;
;       0       Color
;       2       X position
;       4       X actual speed
;       6       X counter
;       8       X counter start value
;       10      reserved :-)
;       12      Y position
;       14      Y actual speed
;       16      Y counter
;       18      Y counter start value

;macska  segment para public 'code'
;        assume  cs:macska
;        assume  ds:macska
;        assume  es:nothing

        org     100H
;----------------------------------------------
s:

        mov     al,13H
        int     10H
        mov     ax,0a000H
        mov     es,ax

        lea     dx,[text]       ; also itz da color of da 1st fly
        mov     ah,9
        int     21H

seed:

        mov     ch,3    ; max no of flies
        mov     bx,BAZE
        mov     bp,188
xinit:
        mov     ax,dx
        and     al,03FH
        mov     [bx],ax ; color
        ;
        mov     word [bx+2],bp     ; X position
        mov     word [bx+12],bp    ; Y position
        ;
        xor     ax,ax
        mov     [bx+4],ax
        mov     [bx+14],ax

        add     bx,SLEN
        add     dl,COLPLUZ
        loop    xinit
;----------------------------------------------
Cycle:
        mov     cx,FLIES
        mov     bx,BAZE

cyc:    xor     ax,ax   ; Clear
        call    PutFly

        xor     si,si   ; X-manipulation
        mov     bp,320-3
        call    Think
        mov     si,10   ; Y-manipulation
        mov     bp,200-3
        call    Think

        mov     ax,[bx] ; Draw
        mov     ah,DECR
        call    PutFly

        add     bx,SLEN
        loop    cyc
;----------------------------------------------
; Wait.VB, keypress.check, quit

        mov     dx,3daH ; Ripped code
kafff:  lahf
        in      al,dx
        and     ax,0408H
        jnz     kafff

        mov     ah,1
        int     16H
        jz      Cycle

q:      mov     ax,3    ; Cleanup
        int     10H
        int     16H
;----------------------------------------------
PutFly:                 ; Put BX Fly with
                        ; AL color, AH color decrement
        push    ax

        mov     dx,320
        mov     ax,[bx+12]      ; Y position
        mul     dx
        add     ax,[bx+2]       ; X position
        mov     di,ax

        push    es
        pop     ds

        pop     ax

        mov     [di+640+2],al   ; Shape of the fly
        sub     al,ah
        mov     [di+320+2],al
        mov     [di+960+2],al
        mov     [di+640+1],al
        mov     [di+640+3],al

        push    cs
        pop     ds

        ret
;----------------------------------------------
Think:                   ; [bx+si] coordinate operation

        test    byte [bx+si+4],-1  ; check zero speed
        jnz     doit

        call    Random
        cwd
        mov     di,SPEEDQ       ; 65536/maxspeed
        idiv    di
        mov     word [bx+si+4],ax  ; inital speed
        call    Random
        and     ax,1fH
        or      al,1
nonz:   mov     word [bx+si+6],ax  ; counter value
        mov     word [bx+si+8],ax  ; counter value

doit:   dec     byte [bx+si+6]     ; countdown
        jnz     keepspeed
        mov     al,1
        test    byte [bx+si+5],80H ; check sign
        jnz     slowdown
        neg     ax
slowdown:       
        add     word [bx+si+4],ax  ; slowdown
        mov     ax,[bx+si+8]       ; copy counter inital value...
        mov     [bx+si+6],ax       ; ...to counter actual value

keepspeed:      
				call		thinkmove

        test    byte [bx+si+3],80H ; check low bound
        jz      chkhi

        call    thinkmoveneg
chkhi:  
				cmp     [bx+si+2],bp       ; check high bound
        jc      rr

thinkmoveneg:   
        neg     word [bx+si+4]     ; turn

thinkmove:      
        mov     ax,[bx+si+4]       ; actual speed
        add     [bx+si+2],ax       ; move

rr:
;----------------------------------------------
Random:
        mov     ax,[seed]
        add     ax,SEEDPLUZ
        mov     [seed],ax

        ret
;----------------------------------------------
text    db      10                 ; The text
        db      244,215,139,226
        db      '$'

;macska  ends
;        end     s
