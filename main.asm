INCLUDE "hardware.inc"
; written by 52525rr.
SECTION "entry", ROM0[$100]
  jp start

SECTION "main", ROM0[$150]
tmp: MACRO
ADD HL,HL 
ADD A,A
jr nc,@+2+1
ADD HL,BC
ENDM
tmp2: MACRO
ADD HL,HL
ADD A,A
jr nc,@+2+1
ADD HL,DE
ENDM
INVHL: MACRO ;28 cycles
  xor a,a
  sub a,l
  ld l,a 
  ld a,0
  sbc a,h
  ld h,a 
ENDM
mulBC: MACRO
 LD A,B
 LD B,0
 ld hl,0
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
ENDM
mulBCs: MACRO
 ld a,c
 xor a,b
 ld [$ff00+$a0],a
 bit 7,b
 jr z,@+2+3
 xor a,a
 sub a,b
 ld b,A 
 bit 7,c
 jr z,@+2+3
 xor a,a
 sub a,c
 ld c,A 
 LD A,b
 LD b,0
 ld h,b
 ld l,b
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
 : tmp
  ld a,[$ff00+$a0]
  bit 7,A 
  jr z, @+2+7
  : INVHL
ENDM
mulDE: MACRO
 LD A,D
 LD D,0
 ld h,d
 ld l,d
 : tmp2
 : tmp2
 : tmp2
 : tmp2
 : tmp2
 : tmp2
 : tmp2
 : tmp2
ENDM
start:
  ld sp,$DFFF
  ld a,$e4
  ld [rBGP],a
  ld a,$91
  ld [rLCDC],a
wait:
  ld a,[rLY]
  cp a,$90
  jr nz,wait
  xor a,a 
  ld [rLCDC],a
setup:
  ld hl,$9fff
  xor a,a
loop:
  ld [hl-],a
  bit 7,h
  jr nz,loop
filltilemap:
  ld hl,$9800+$20+2
  ld b,16
  ld c,16
  ld de,16
loop2:
  ld [hl+],a
  inc a
  dec b
  jr nz,loop2
  add hl,de
  ld b,16
  dec c
  jr nz,loop2
  jp main
comppixelDE:
  xor a,a
  ld [$ff00+$90],a
  ld bc,0
  ld hl,0; H,L = e,f
pixel:
  push de; screen coordinates
  ld a,d;
  add a,h; 
  ld c,a; PY = int(y)+f; B,C = PX,PY
  ld a,e;
  add a,l; 
  ld b,a; PX = int(x)+e
  push bc; save PX, PY
  push bc; again
  ld c,b; C = PX
  : mulBCs ; PX*PX
  pop bc; retrive PX,PY
  push hl; save PX*PX
  ld b,c; B = PY
  : mulBCs ;PY*PY
  ld d,h ; DE = PY*PY
  ld e,l
  pop hl; HL = retrived PX*PX
  ld a,h    ; 1 byte  ; 4 cycles
  or a,d    ; 1 byte  ; 4 cycles
  and a,$F0 ; 2 bytes ; 8 cycles
  jr nz,end ; 2 bytes ; 8-12 cycles
next0:
  add hl,hl
  add hl,hl
  add hl,hl 
  
  push hl; save PX*PX
  ld h,d
  ld l,e
  
  add hl,hl
  add hl,hl
  add hl,hl; normalize PY*PY
  ld d,h 
  pop hl; normalize PX*PX and PY*PY 
  ld e,h ;D,E = PX*PX,PY*PY
  ld a,d
  add a,e
  add a,a
  jr c,end ; PX*PX + PY*PY > 4
  
  ld a,[$ff00+$90]
  inc a
  ld [$ff00+$90],a
  cp a,$0f
  jr z,end
  
  ld a,d
  sub a,e; 
  
  ld h,a; e=PX*PX-PY*PY;
  pop bc; get PX,PY
  sla b; PX*2
  push hl
  : mulBCs; (PX*2)*PY
  add hl,hl
  add hl,hl
  add hl,hl; normalize
  ld d,h; save result to E
  pop hl; retrieve e,f
  ld l,d; save result to f
  pop de; get back screen coordinates
  jp pixel
end:
  ld a,[$ff00+$90]

  pop bc
  pop de
  
  ret
next:
  ld a,$91
  ld [rLCDC],a
tile:
  ld bc,$0808
tloop:
  push bc
  push hl
  call comppixelDE
  pop hl
  pop bc
  inc d
  ld [hl+],a
  
  dec c
  jr nz,tloop
  ld a,d
  sub a,8
  ld d,A 
  inc e
  ld c,8
  dec b
  jr nz,tloop
  ret
ditherloop:
  ret
transfer: MACRO
  xor a,a
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  srl [hl]
  rla
  inc hl
  ;ld a,$FF
  ld [bc],A 
  inc bc
  inc bc
  endm

ZZ:
  push bc
  push de
  ld hl,$c000; memory address
  call tile
  ld b,d; save current pixel
  ld c,e
  call ditherloop
  ld hl,$c000
  pop de
  pop bc
wait0: 
  ld a,[rLY]
  cp a,$90
  jr nz,wait0
  : transfer; 2 bitplanes
  : transfer
  
  : transfer; 2 bitplanes
  : transfer
  
  : transfer; 2 bitplanes
  : transfer
  
  : transfer; 2 bitplanes
  : transfer
  ld hl,$c000
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc
  dec bc 
  dec bc
  dec bc 
  dec bc
  : transfer; 2 bitplanes
  : transfer
  
  : transfer; 2 bitplanes
  : transfer
  
  : transfer; 2 bitplanes
  : transfer
  
  : transfer; 2 bitplanes
  : transfer
  dec bc
  ret
tmp3: MACRO
  call ZZ
  ld a,d
  add a,8
  ld d,a
ENDM
main:
  ld a,$91
  ld [rLCDC],a
  ld l,16
  ld de,$c0c0
  ld bc,$8000; VRAM destination
lineoftiles:
  push hl
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  : tmp3
  ld a,e
  add a,8
  ld e,a 
  ld d,$c0
  pop hl
  ld c,0
  dec l
  jp nz,lineoftiles
  halt
