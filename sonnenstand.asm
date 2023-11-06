.386
.model	flat, stdcall
option	casemap :none

include	\masm32\include\windows.inc
include	\masm32\include\kernel32.inc
include	\masm32\include\user32.inc
include	\masm32\include\advapi32.inc
include	\masm32\include\shell32.inc
include	\masm32\include\wsock32.inc
include	\masm32\include\masm32.inc
include \masm32\include\Winmm.inc
include \masm32\include\msvcrt.inc
include	\masm32\include\comctl32.inc
include \masm32\macros\macros.asm


includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\wsock32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\Winmm.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\comctl32.lib	

DlgProc		proto :dword,:dword,:dword,:dword
GetTodaysJulianDay proto
Radians2Degrees proto
degress_sin proto
degress_cos proto
degress_tan proto
SetDlgItemBuffer proto :REAL8,:dword

.const
IDD_MAIN	equ	1000
IDC_EDIT1002 equ 1002
IDC_EDIT1003 equ 1003
IDB_GOGOGO	equ	1101

IDC_EDIT1203 equ 1203
IDC_EDIT1204 equ 1204
IDC_EDIT1205 equ 1205
IDC_EDIT1206 equ 1206
IDC_EDIT1207 equ 1207
IDC_EDIT1208 equ 1208
IDC_EDIT1209 equ 1209
IDC_EDIT1210 equ 1210
IDC_EDIT1211 equ 1211
IDC_EDIT1212 equ 1212
IDC_EDIT1213 equ 1213
IDC_EDIT1214 equ 1214
IDC_EDIT1215 equ 1215
IDC_EDIT1216 equ 1216
IDC_EDIT1217 equ 1217
IDC_EDIT1218 equ 1218
IDC_EDIT1219 equ 1219
IDC_CALENDAR1240 equ 1240
.data
testoutput db "%.18LG",0

dd15					dd		15d
dd24					dd		24d
dd36525					dd		36525d
dd86400					dd		86400d
dd4716					dd 		4716d
dd2451545				dd		2451545d
dd360					dd		360d
dd180					dd		180d
Real8__365_25			REAL8	365.25d
Real8__30_6001			REAL8	30.6001d
Real8__1524_5			REAL8	-1524.5d
Real8__0_9856474		REAL8	0.9856474d
Real8__0_9856003		REAL8	0.9856003d
Real8__280_460			REAL8	280.460d
Real8__357_528			REAL8	357.528d
Real8__1_915			REAL8	1.915d
Real8__0_020			REAL8	0.020d	
Real8__23_439			REAL8	23.439d	
Real8__0_0000004		REAL8	0.0000004d
Real8__6_697376			REAL8	6.697376d
Real8__2400_05134		REAL8	2400.05134d
Real8__1_002738			REAL8	1.002738d

;your exact location exact
;49.999999,10.199999
Real8_GeoBreite REAL8	49.999999
Real8_lambda	REAL8	10.199999	;geographischen Laenge
;;Muechen 48,1N 11,6 O 

.data?
TestTime				SYSTEMTIME <?>
hInstance				dd		?
hWin2					dd		?

H_dd					dd		?
H_Real8					REAL8	?
B_dd					dd		?
B_Real8					REAL8	?
D_dd					dd		?
D_Real8					REAL8	?
M_dd					dd		?
M_Real8					REAL8	?
Y_dd					dd		?
Y_Real8					REAL8	?

JD_Real8_Part1			REAL8	?
JD_Real8_Part2			REAL8	?
JD_real8				REAL8	?
JD0_real8				REAL8	?
Zeitvariable_n_real8	REAL8	?
L_real8					REAL8	?
g_real8					REAL8	?
ekl_laenge_real8		REAL8	?
e_Real8					REAL8	?
alpha_Real8				REAL8	?
alpha_nenner__Real8		REAL8	?
Deklination_Real8		REAL8	?
T_Real8					REAL8	?
TO_Real8				REAL8	?
ohg_Real8				REAL8	?
og_Real8				REAL8	?
o_Real8					REAL8	?
r_Real8					REAL8	?
a_Real8					REAL8	?
Azimut_nenner__Real8	REAL8	?
h_Real8					REAL8	?

oldcw   				dw		?
newcw					dw		?
;---------------------------------------testzeug
buffer 					db		?
;---------------------------------------testzeug
; лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	invoke	InitCommonControls
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset DlgProc, 0
	invoke	ExitProcess, 0

DlgProc proc hWin:dword,uMsg:dword,wParam:dword,lParam:dword
	mov eax,hWin
	mov hWin2,eax
	
	mov	eax,uMsg
	.if	eax == WM_INITDIALOG
		invoke	LoadIcon,hInstance,200				;drecks icon macht das file so gross, vielleicht sollt ichs weglassen
		invoke	SendMessage, hWin, WM_SETICON, 1, eax
	.elseif eax == WM_COMMAND
		mov	eax,wParam
		.if	eax == IDB_GOGOGO
		invoke GetTodaysJulianDay   ;hier brauchen wir keinen thread die berechnung blockt das fenster nicht , viel zu wenig gerechne
		.endif
	.elseif	eax == WM_CLOSE
		invoke	EndDialog, hWin, 0
	.endif
	xor	eax,eax
	ret
DlgProc endp
; лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
GetTodaysJulianDay proc
Finit										;wir wollen floats verwenden
invoke GetSystemTime,addr TestTime			;The time is in coordinated universal time (UTC) 
xor edx,edx
xor eax,eax
xor ecx,ecx
;------------------------------------------------------------------------------------------------------------
;http://de.wikipedia.org/wiki/Julianisches_Datum#Berechnung_in_Programmiersprachen

;   wenn Monat > 2 dann  Y = Jahr,   M = Monat
;                  sonst Y = Jahr-1, M = Monat+12
;    
;   D = Tag 
;    
;   H = Stunde/24 + Minute/1440 + Sekunde/86400
;    
;   wenn TT.MM.YYYY >= 15.10.1582  
;        dann Gregorianischer Kalender: A = Int(Y/100), B = 2 - A + Int(A/4)
;         
;   wenn TT.MM.YYYY <= 04.10.1582  
;        dann Julianischer Kalender:                    B = 0
;    
;   sonst Fehler: Das Datum zwischen dem 04.10.1582 und dem 15.10.1582 existiert nicht.
;                 Auf den         04.10.1582 (Julianischer Kalender) folgte 
;                 unmittelbar der 15.10.1582 (Gregorianischer Kalender).
;    
;   JD = Int(365,25*(Y+4716)) + Int(30,6001*(M+1)) + D + H + B - 1524,5
;------------------------------------------------------------------------------------------------------------
;setup year and month
cmp word ptr[TestTime.wMonth],2
ja @F
add word ptr[TestTime.wMonth],12
dec word ptr[TestTime.wYear]	
@@:
;------------------------------------------------------------------------------------------------------------
;kleiner debugging test
;Es ist der Sonnenstand f№r den 6. August 2006 um 8 Uhr MESZ (T = 6 Uhr UT) in M№nchen (\varphi = 48,1░ N, ? = 11,6░ O) zu bestimmen. Es ergeben sich
;mov word ptr[TestTime.wYear],2006d
;mov word ptr[TestTime.wMonth],8d
;mov word ptr[TestTime.wDay],6d
;mov word ptr[TestTime.wHour],6d
;mov word ptr[TestTime.wMinute],0d
;mov word ptr[TestTime.wSecond],0d
;
;mov word ptr[TestTime.wYear],2012d
;mov word ptr[TestTime.wMonth],8d
;mov word ptr[TestTime.wDay],6d
;mov word ptr[TestTime.wHour],3d
;mov word ptr[TestTime.wMinute],50d
;mov word ptr[TestTime.wSecond],0d
;------------------------------------------------------------------------------------------------------------
;H berechnen		H_dd und H_Real8  ;H = Stunde/24 + Minute/1440 + Sekunde/86400
xor eax,eax
xor ecx,ecx
movzx eax,TestTime.wHour	
imul EAX,eax,60d	
cdq
movzx ecx,TestTime.wMinute
add eax,ecx
imul EAX,eax,60d
cdq
movzx ecx,TestTime.wSecond
add eax,ecx
mov H_dd,eax
fild H_dd
fidiv dd86400
fstp H_Real8
;------------------------------------------------------------------------------------------------------------
;B berechnen	vereinfacht auf einen Zeitraum bis 2299	B_dd und B_Real8 
cmp word ptr[TestTime.wYear],1582d
jb B_equ_0		;falls  vor 1582 
ja B_not_0		;falls  nach 1582
;falls wir im jahr 1582 uns befinden
cmp word ptr[TestTime.wMonth],10d
jb B_equ_0		;falls  vor 10.1582 
ja B_not_0		;falls nach 10.1582 
;falls wir oktober 1582 haben
cmp word ptr[TestTime.wDay],4d
jbe B_equ_0		;falls  vor/oder 4.10.1582  ;also 1-4. okt 1582 
cmp word ptr[TestTime.wDay],15d
jae @F
;falls wir hier ankommen ist ein invalides datum 5-14oktober 1582  und setzen das datum auf 15.ok
mov word ptr[TestTime.wDay],15d
@@:
B_not_0:
;hier eine kleine vereinfachung von A = Int(Y/100), B = 2 - A + Int(A/4) precompiled?? sucks!! :D
mov B_dd,-10
cmp word ptr[TestTime.wYear],1699d
jbe B_Out				;vor 1699 B == -10
dec B_dd	;B = -11
cmp word ptr[TestTime.wYear],1799d
jbe B_Out				;zwischen 1700 und 1799 --> B == -11
dec B_dd	;B = -12
cmp word ptr[TestTime.wYear],1899d
jbe B_Out				;zwischen 1800 und 1899 --> B == -12
dec B_dd	;B = -13
cmp word ptr[TestTime.wYear],2099d
jbe B_Out				;zwischen 1900 und 2099 --> B == -13
dec B_dd	;B = -14
cmp word ptr[TestTime.wYear],2199d
jbe B_Out				;zwischen 2100 und 2199 --> B == -14
dec B_dd	;B = -15
cmp word ptr[TestTime.wYear],2299d
jbe B_Out				;zwischen 2200 und 2299 --> B == -15

B_equ_0:
mov B_dd,0

B_Out:
fild B_dd
fstp B_Real8
;------------------------------------------------------------------------------------------------------------
;Day in float speichern		D_dd und D_Real8
xor eax,eax 
movzx eax,TestTime.wDay
mov D_dd,eax
fild D_dd
fstp D_Real8
;------------------------------------------------------------------------------------------------------------
;Month in float speichern		M_dd und M_Real8
xor eax,eax 
movzx eax,TestTime.wMonth
mov M_dd,eax
fild M_dd
fstp M_Real8
;------------------------------------------------------------------------------------------------------------
;Year in float speichern		Y_dd und Y_Real8
xor eax,eax 
movzx eax,TestTime.wYear
mov Y_dd,eax
fild Y_dd
fstp Y_Real8
;------------------------------------------------------------------------------------------------------------
;JD berechnen Part1		;Int(365,25*(Y+4716))    i use parts so i can easy debug this parts  
fld Y_Real8				;Year
fiadd dd4716			;+4716
fmul Real8__365_25		;*365.25
;--------setup the control word to round down!!!---and round down aka trunicate--standard == nearest
fstcw oldcw
fwait
mov   ax,oldcw
or    ax,0C00h
mov   newcw,ax
fldcw newcw 			;trunicate mode
frndint
fldcw oldcw				;restore old control word aka nearest mode

fstp JD_Real8_Part1
;------------------------------------------------------------------------------------------------------------
;JD berechnen Part2		;Int(30,6001*(M+1))
fld M_Real8				;Month
fld1					;1
fadd					;Month+1
fmul Real8__30_6001		;* 30,6001
fldcw newcw 			;trunicate mode
frndint
fldcw oldcw				;restore old control word nearest mode

fstp JD_Real8_Part2
;------------------------------------------------------------------------------------------------------------
;JD berechnen 		JD = JD_Real8_Part1 + JD_Real8_Part2 + D + H + B - 1524,5
fld JD_Real8_Part1	
fld JD_Real8_Part2	
fadd
fld D_Real8
fadd
fld B_Real8
fadd
fld Real8__1524_5
fadd

fstp JD0_real8		;sichern von JD0  
fld JD0_real8		;

fld H_Real8			;H variable  dazu == JD
fadd

fstp JD_real8
invoke SetDlgItemBuffer,JD_real8,IDC_EDIT1203
;------------------------------------------------------------------------------------------------------------
;Zeitvariable_n berechnen  n = JD - 2451545
fld JD_real8
fisub dd2451545

fstp Zeitvariable_n_real8
invoke SetDlgItemBuffer,Zeitvariable_n_real8,IDC_EDIT1204
;------------------------------------------------------------------------------------------------------------
;mittlere ekliptikale_Laenge L der Sonne berechnen  L = 280,460 + 0,9856474 * n
fld Zeitvariable_n_real8
fmul Real8__0_9856474
fadd Real8__280_460
@@:
 push 360d         ;push the immediate value as a DWORD
 ficom dword ptr[esp] ;compare ST(0) to the integer value on the stack
 fstsw [esp]       ;overwrite the pushed value with the Status Word
 fwait             ;insure the previous instruction is completed
 pop  eax          ;retrieve the Status Word in AX and clean the stack
 sahf              ;transfer the condition codes to the CPU's flag register
jb   	@F	; st0 is lower than 360   
fisub dd360
jmp @B 

@@:

fstp L_real8
invoke SetDlgItemBuffer,L_real8,IDC_EDIT1205
;------------------------------------------------------------------------------------------------------------
;mittlere Anomalie g berechnen  g = 357,528 + 0,9856003 * n
fld Zeitvariable_n_real8
fmul Real8__0_9856003
fadd Real8__357_528
@@:
 push 360d         ;push the immediate value as a DWORD
 ficom dword ptr[esp] ;compare ST(0) to the integer value on the stack
 fstsw [esp]       ;overwrite the pushed value with the Status Word
 fwait             ;insure the previous instruction is completed
 pop  eax          ;retrieve the Status Word in AX and clean the stack
 sahf              ;transfer the condition codes to the CPU's flag register
jb   	@F	; st0 is lower than 360   
fisub dd360
jmp @B 

@@:

fstp g_real8
invoke SetDlgItemBuffer,g_real8,IDC_EDIT1206
;------------------------------------------------------------------------------------------------------------
;ekliptikale Laenge mit e ~ 0.0167  	ekliptikale Laenge aka "EklLae" = L + 1,915 * sin(g) + 0.020 * sin(2g)
fld g_real8
fld st 				;duplicate
fadd				;(2g)	
invoke degress_sin
fmul Real8__0_020

fld g_real8
invoke degress_sin
fmul Real8__1_915	;1,915 * sin(g)

fadd				;1,915 * sin(g) + 0.020 * sin(2g)

fld L_real8
fadd

fstp ekl_laenge_real8
invoke SetDlgItemBuffer,ekl_laenge_real8,IDC_EDIT1207
;------------------------------------------------------------------------------------------------------------
;Schiefe der Ekliptik e berechnen  			e = 23.439 - 0.0000004 *n
;e_Real8
fld	Real8__23_439
fld Zeitvariable_n_real8
fmul Real8__0_0000004
fsub

fstp e_Real8
invoke SetDlgItemBuffer,e_Real8,IDC_EDIT1208
;------------------------------------------------------------------------------------------------------------
;Rektaszension alpha  berechnen  			alpha =arctan(cos(e)*sin(ekl_laenge)/cos(ekl_laenge))
fld	e_Real8
invoke degress_cos	

fld	ekl_laenge_real8
invoke degress_sin

fmul							;zaehler

fld	ekl_laenge_real8
invoke degress_cos 				;nenner
nop
nop
nop
nop
fstp alpha_nenner__Real8		;hier duplizieren  und spaeter auf negativ testen  ??
fld	alpha_nenner__Real8
;Hinweis: Falls der Nenner im Argument des Arcustangens einen Wert kleiner Null hat, sind 180░ zum Ergebnis zu addieren, um den Winkel in den richtigen Quadranten zu bringen (? muss im gleichen Quadranten liegen wie ?

FPATAN

invoke Radians2Degrees
fstp alpha_Real8
;
;
;fld	alpha_nenner__Real8  ;auf negative vergleichen
;
;ftst               ;compare the value of ST(0) to +0.0
; fstsw ax          ;copy the Status Word containing the result to AX
; fwait             ;insure the previous instruction is completed
; sahf              ;transfer the condition codes to the CPU's flag register
; jb @F      ;(CF=0)
;
;fld alpha_Real8
;fiadd dd180
;fstp alpha_Real8
;
;@@:
;fstp st			;pop alpha_nenner__Real8 
invoke SetDlgItemBuffer,alpha_Real8,IDC_EDIT1209
;------------------------------------------------------------------------------------------------------------
;Deklination DEKL  berechnen  			Deklination =arcsin(sin(e)*sin(ekl_laenge))
fld	e_Real8
invoke degress_sin
 
fld	ekl_laenge_real8
invoke degress_sin
             
fmul

; ArcSin not supported fpu command   fpu lib kanns aber unnoetig einzubinden da das auch funktioniert
    fld st(0)         ;{ X   X }
    fmul st,st(0)     ;{ X^2 X }
    fld1              ;{ 1 X^2 X }
    fsubrp st(1),st   ;{ (1-X^2) X }
    fsqrt             ;{ sqrt(1-X^2) X }
    fpatan            ;{ Uses both arguments }

invoke Radians2Degrees

fstp Deklination_Real8
invoke SetDlgItemBuffer,Deklination_Real8,IDC_EDIT1210
;------------------------------------------------------------------------------------------------------------
;TO  berechnen  			T0 = ( JDO - 2451545 ) / 36525
fld	JD0_real8
fisub dd2451545
fidiv dd36525

fstp TO_Real8
invoke SetDlgItemBuffer,TO_Real8,IDC_EDIT1211
;------------------------------------------------------------------------------------------------------------
;T  berechnen  			T = h*24d
fld	H_Real8
fimul dd24

fstp T_Real8
invoke SetDlgItemBuffer,T_Real8,IDC_EDIT1212
;------------------------------------------------------------------------------------------------------------
;ohg  berechnen  			ohg =6.697376 + 2400.05134*T0 + 1.002738 * T

fld T_Real8
fmul Real8__1_002738	

fld TO_Real8
fmul Real8__2400_05134

fadd

fadd Real8__6_697376

@@:
 push 24d         ;push the immediate value as a DWORD
 ficom dword ptr[esp] ;compare ST(0) to the integer value on the stack
 fstsw [esp]       ;overwrite the pushed value with the Status Word
 fwait             ;insure the previous instruction is completed
 pop  eax          ;retrieve the Status Word in AX and clean the stack
 sahf              ;transfer the condition codes to the CPU's flag register
jb   	@F	; st0 is lower than 24   
fisub dd24
jmp @B 

@@:

fstp ohg_Real8
invoke SetDlgItemBuffer,ohg_Real8,IDC_EDIT1213
;------------------------------------------------------------------------------------------------------------
;og  berechnen  			og =ohg*15
fld ohg_Real8
fimul dd15	

fstp og_Real8
invoke SetDlgItemBuffer,og_Real8,IDC_EDIT1214
;------------------------------------------------------------------------------------------------------------
;theta  berechnen  			o =ohg+lambda   
fld og_Real8
fadd Real8_lambda

fstp o_Real8
invoke SetDlgItemBuffer,o_Real8,IDC_EDIT1215
;------------------------------------------------------------------------------------------------------------

;Stundenwinkel r  berechnen  			r = 0 - Rektaszension ?  		\tau \, = \, \theta - \alpha.
fld o_Real8
fsub alpha_Real8
	
fstp r_Real8
invoke SetDlgItemBuffer,r_Real8,IDC_EDIT1216
;------------------------------------------------------------------------------------------------------------
;Azimut a  berechnen  			
fld r_Real8
invoke degress_sin


fld	r_Real8
invoke degress_cos

fld Real8_GeoBreite
invoke degress_sin

fmul

fld Deklination_Real8
invoke degress_tan

fld	Real8_GeoBreite
invoke degress_cos
  
fmul

fsub

fstp Azimut_nenner__Real8		;hier duplizieren  und spaeter auf negativ testen  ??
fld	Azimut_nenner__Real8
;Hinweis: Falls der Nenner im Argument des Arcustangens einen Wert kleiner Null hat, sind 180░ zum Ergebnis zu addieren, um den Winkel in den richtigen Quadranten zu bringen (? muss im gleichen Quadranten liegen wie ?).


FPATAN
invoke Radians2Degrees
fstp a_Real8


;fld	Azimut_nenner__Real8  ;auf negative vergleichen
;ftst               ;compare the value of ST(0) to +0.0
; fstsw ax          ;copy the Status Word containing the result to AX
; fwait             ;insure the previous instruction is completed
; sahf              ;transfer the condition codes to the CPU's flag register
; jb @F            ;(CF=0)
; 
;fld a_Real8
;fiadd dd180
;fstp a_Real8
;
;@@:
;fstp st			;pop alpha_nenner__Real8 
invoke SetDlgItemBuffer,a_Real8,IDC_EDIT1217
;------------------------------------------------------------------------------------------------------------
;Hoehenwinkel h berechnen  			
fld Deklination_Real8
invoke degress_cos

 fld	r_Real8
 invoke degress_cos

 fld	Real8_GeoBreite
 invoke degress_cos

fmul
fmul

fld Deklination_Real8
invoke degress_sin

               
fld Real8_GeoBreite
invoke degress_sin

fmul
fadd
	
	fld st(0)         ;{ X   X }
    fmul st,st(0)     ;{ X^2 X }
    fld1              ;{ 1 X^2 X }
    fsubrp st(1),st   ;{ (1-X^2) X }
    fsqrt             ;{ sqrt(1-X^2) X }
    fpatan            ;{ Uses both arguments }

invoke Radians2Degrees
fstp h_Real8
invoke SetDlgItemBuffer,h_Real8,IDC_EDIT1218

ret
GetTodaysJulianDay endp

SetDlgItemBuffer proc RealToConvert:REAL8,IdentifierControl:dword
invoke crt_sprintf,addr buffer,addr testoutput,RealToConvert			;;fuuuck no %F support on asm ;(
;invoke MessageBoxA,0,addr buffer,addr buffer,0
invoke SetDlgItemText,hWin2,IdentifierControl,addr buffer
ret
SetDlgItemBuffer endp

Radians2Degrees proc
push 180d       ;for converting to degrees
fimul dword ptr[esp] ;ST(0)=180*angle in radians, ST(1)=xxx
fldpi           ;ST(0)=?, ST(1)=180*angle in radians, ST(2)=xxx
fdiv            ;ST(0)=180/?*angle in radians=angle in degrees, ST(1)=xxx
add   esp,4
ret
Radians2Degrees endp

degress_sin proc
push 180d    ;store the integer value of 180 on the stack   ;no result check
fidiv dword ptr[esp]   ;divide the angle in degrees by 180
             ;-> ST(0)=angle in degrees/180
fldpi        ;load the hard-coded value of ?
             ;-> ST(0)=?, ST(1)=angle in degrees/180
fmul         ;-> ST(0)=angle in degrees*?/180, => angle in radians
add   esp,4  ;adjust the stack pointer to clean-up the pushed 180
fsin         ;compute the sine of the angle
             ;-> ST(0)=sin(angle) if no error
ret
;-----------Failsave proccs sollten so aussehen:
;   pushd 180    ;store the integer value of 180 on the stack
;   fidiv dword ptr[esp]   ;divide the angle in degrees by 180
;                ;-> ST(0)=angle in degrees/180
;   fldpi        ;load the hard-coded value of ?
;                ;-> ST(0)=?, ST(1)=angle in degrees/180
;   fmul         ;-> ST(0)=angle in degrees*?/180, => angle in radians
;   fsin         ;compute the sine of the angle
;               ;-> ST(0)=sin(angle) if no error
;   fstsw [esp]  ;store the Status Word on the stack overwriting the 180
;   fwait        ;to insure the last instruction is completed
;   pop   eax    ;get the Status Word in AX (which also cleans the stack)
;   shr   al,1   ;transfer the Invalid op flag (bit0 of AL) to the CF flag
;   jnc   @F     ;jump if no invalid operation detected
; 	   ;insert code to handle an invalid operation
;                ;-> ST(0)=INDEFINITE (angle has been trashed)
;@@:
;   sahf         ;transfer AH to the CPU flag register
;   jpo   @F     ;jump if PF=C2=0 meaning angle value is in acceptable range
;        ;insert code to handle angle ouside acceptable range
;                ;-> ST(0)=angle in radians unchanged
;@@:             ;-> ST(0)=sin(angle) -- no error
;	Ret
degress_sin endp

degress_cos proc
push 180d    ;store the integer value of 180 on the stack
fidiv dword ptr[esp]   ;divide the angle in degrees by 180
             ;-> ST(0)=angle in degrees/180
fldpi        ;load the hard-coded value of ?
             ;-> ST(0)=?, ST(1)=angle in degrees/180
fmul         ;-> ST(0)=angle in degrees*?/180, => angle in radians
add   esp,4  ;adjust the stack pointer to clean-up the pushed 180
             ;pop reg32 would also clean the stack but trash a register
fcos         ;compute the cosine of the angle
             ;-> ST(0)=cos(angle)
ret
degress_cos endp

degress_tan proc
push 180d 
fidiv dword ptr[esp]   ;divide the angle in degrees by 180
             ;-> ST(0)=angle in degrees/180
fldpi        ;load the hard-coded value of ?
             ;-> ST(0)=?, ST(1)=angle in degrees/180
fmul         ;-> ST(0)=angle in degrees*?/180, => angle in radians
add   esp,4  
fptan         
fstp st
ret
degress_tan endp


end start
;more than 2k opcodes i would say fail ! ???
