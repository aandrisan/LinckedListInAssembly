.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern malloc: proc
extern scanf: proc
extern strcmp: proc
extern fprintf: proc
extern fscanf: proc
extern fopen: proc
extern fclose: proc


public start

.data

first dd 0
last dd 0
new dd 0
nr_elemente dd 0
nr dd 0
index dd 0
elem_sters dd 0
mesaj_gol db "lista este goala   ",0
format_afis db "%d ",0
format db "%d",0
mes_imp db "Depaseste numarul de elemente  ",0
mode_write db "w",0
format_fisier db "%s",0
fisier db 50 dup(0)
nr_fisier dd 0
mode_read db "r",0
msg1 db "creare",0
msg2 db "introducere_final",0
msg3 db "stergere",0
msg4 db "introducere_in_fisier",0
msg5 db "introducere_din_fisier",0
msg6 db "exit",0
msg7 db "afisare",0
msg8 db "cautare",0
msg9 db "introducere_inceput",0
msg10 db "introducere_dupa",0
mesg db "Opreratiile care se pot efectua sunt: creare, introducere_final, introducere_inceput, intoducere_dupa, stergere,        introducere_in_fisier,  introducere_din_fisier, afisare, cautare, exit  ",0
mesaj_citit db 50 dup(0)
mesaj_gresit db "Instructiunea nu exista  ",0
nr_cautat dd 0
mesaj_gasit db "Elementul a fost gasit pe pozitia %d  ",0
mesaj_negasit db "Elementul nu a fost gasit  ",0
mes_invalid db "Operatia nu se poate efectua  ",0
mesaj_index db "Introdu index  ",0
mesaj_numar db "Introdu numar  ",0
mesaj_fisier db "Introdu fisier  ",0

.code


comparare macro mesaj, format
push mesaj
push format
call strcmp
add esp,8
endm

;aici fac first si last null(0) ca initializare
init macro first, last
mov first,0
mov last,0
endm 


; adaug elemnete in lista 
adauga proc
	push ebp 
	mov ebp, esp
	
	push 8
	call malloc  ;aloc spatiu pentru elementul din lista
	add esp,4
	mov new, eax
	
	push offset mesaj_numar 
	push offset format_fisier
	call printf
	add esp,8
	
	push offset nr  ;citesc elementul
	push offset format
	call scanf
	add esp, 8
	
	mov eax, nr_elemente
	add eax, 1
	mov nr_elemente, eax
	
	cmp last, 0   ;verific daca lista este goala
	jne adauga_element

	mov ebx, nr
	mov edi, new
	mov dword ptr[edi], ebx  ;adaug pe primii 4 octeti elementul
	mov dword ptr[edi+4], 0  ;adaug pointerul spre urmatorul element aici este 0 ca fiind null
	mov first, edi
	mov last, edi
	jmp final
	
	adauga_element:
	mov ebx, nr
	mov edi, new
	mov dword ptr[edi],ebx
	mov dword ptr[edi+4], 0
	mov ecx, last
	mov dword ptr[ecx+4],edi
	mov last, edi
	final:
	
	mov esp, ebp
	pop ebp
	ret 4 
adauga endp

sterge proc
	push ebp
	mov ebp, esp
	
	push offset mesaj_index  ;citeste indexul elementului  elementele incep cu indexul 1
	push offset format_fisier
	call printf
	add esp,8
	
	push offset index
	push offset format
	call scanf
	add esp, 8
	
	mov ecx, index
	mov ebx, nr_elemente
	cmp ecx, ebx
	je ultimul  
	jg imposibil  ;verifica daca indexul nu este prea mare fata de cate elemente exista in lista
	
	cmp ecx,1
	jne urmator
	mov edi, first
	mov eax, dword ptr[edi+4]
	mov first, eax
	jmp final

	urmator:
	mov ebx, first
	mov elem_sters, ebx
	dec ecx
	stergere:
	
	mov ebx, elem_sters
	mov eax, dword ptr[ebx+4];
	mov elem_sters, eax
	
	cmp ecx,0
	dec ecx
	jne stergere ;bucla pentru a ajunge la elemnetul sters

	mov edx, dword ptr[eax+4]  ;mut adresa urmatorului elemente in partea adresata acestui lucru
	mov dword ptr[ebx+4], edx
	
	jmp final
	
	ultimul:  ;stergerea ultimimului elemente este diferita deoarece trebuie pus 0 la final
	mov ebx, first
	mov elem_sters, ebx
	dec ecx
	stergere2:
	mov ebx, elem_sters
	mov eax, dword ptr[ebx+4]
	mov elem_sters, eax	
	cmp ecx,0
	dec ecx
	jne stergere2
	
	mov last, ebx
	mov dword ptr[ebx+4],0

	jmp final
	
	imposibil:
	push offset mes_imp
	call printf
	add esp,4 
	jmp iesire
	
	final:
	mov eax, nr_elemente
	dec eax
	mov nr_elemente, eax
	
	iesire:
	mov esp, ebp
	pop ebp
	ret

sterge endp

afisare_lista proc
	push ebp
	mov ebp, esp
	
	mov ecx, nr_elemente
	cmp ecx, 0
	je gol

	mov edi, first
	afisare1:
	mov ecx, dword ptr[edi +4]
	cmp ecx, 0
	je final
	
	mov eax, dword ptr[edi]
	
	push eax
	push offset format_afis
	call printf
	add esp ,8
	
	mov ebx, dword ptr[edi+4]
	mov edi, ebx
	jmp afisare1 ;bucla pentru afisare
	
	gol:
	push offset mesaj_gol  ;afiseaza mesaj daca lista este goala
	call printf
	jmp finall
	
	final:
	mov eax, dword ptr[edi]
	
	push eax
	push offset format_afis
	call printf
	add esp ,8

	finall:
	mov esp, ebp
	pop ebp
	ret
afisare_lista endp

adauga_fisier proc
    push ebp
	mov ebp, esp
	
	push offset mesaj_fisier
	push offset format_fisier
	call printf
	add esp,8
	
	push offset fisier
	push offset format_fisier  ;citesc numele fisierului si il creez deoarece este deschis in modul scriere
	call scanf
	add esp,8
	
	push offset mode_write
	push offset fisier
	call fopen
	add esp,8
	mov nr_fisier, eax
	
	mov ecx, nr_elemente
	cmp ecx, 0
	je golh

	mov edi, first
	afisare12:
	mov ecx, dword ptr[edi+4]
	cmp ecx, 0
	je finaln

	mov eax, dword ptr[edi]
	
	push eax
	push offset format_afis  ;afisarea in fisier
	push nr_fisier
	call fprintf
	add esp ,12
	
	mov ebx, dword ptr[edi+4]
	mov edi, ebx
	jmp afisare12  ;bucla pentru afisare in fisier
	
	golh:
	push offset mesaj_gol ;daca lista este goala se afiseaza un mesaj de eroare
	push nr_fisier
	call fprintf
	add esp,8
	jmp finalnn
	
	finaln:
	mov eax, dword ptr[edi]
	
	push eax
	push offset format_afis
	push nr_fisier
	call fprintf
	add esp ,12
	
	finalnn:
	push nr_fisier
	call fclose
	add esp,4
	
	mov eax, 0
	mov first, eax
	mov last, eax
	mov nr_elemente, eax
	
	mov esp, ebp
	pop ebp
	ret
adauga_fisier endp

insert_fisier proc

	push ebp
	mov ebp, esp
	
	push offset mesaj_fisier
	push offset format_fisier
	call printf
	add esp,8
	
	push offset fisier
	push offset format_fisier  ;citeste numele fisierului
	call scanf
	add esp,8
	
	push offset mode_read  ;deschide fisierul in mod citire
	push offset fisier
	call fopen
	add esp,8
	mov nr_fisier, eax
	
	push offset nr
	push offset format
	push nr_fisier
	citi:
	call fscanf

	test eax,eax  ;testeaza daca a ajus la finalul fisierului
	js inchide
	
	push 8   ;face adaugarea normala ca de la tastatura
	call malloc
	add esp,4
	mov new, eax
	
	mov eax, nr_elemente
	add eax, 1
	mov nr_elemente, eax
	
	cmp last, 0
	jne adauga_element

	mov ebx, nr
	mov edi, new
	mov dword ptr[edi], ebx
	mov dword ptr[edi+4], 0
	mov first, edi
	mov last, edi
	jmp final
	
	adauga_element:
	mov ebx, nr
	mov edi, new
	mov dword ptr[edi],ebx
	mov dword ptr[edi+4], 0
	mov ecx, last
	mov dword ptr[ecx+4],edi
	mov last, edi
	final:
	jmp citi
	
	inchide:
	push nr_fisier
	call fclose
	add esp,4
	
	mov esp, ebp
	pop ebp
	ret
insert_fisier endp

cauta proc
	push ebp
	mov ebp,esp

	push offset mesaj_numar
	push offset format_fisier
	call printf
	add esp,8
	
	push offset nr_cautat
	push offset format
	call scanf
	add esp,8
	
	mov ecx, nr_elemente
	mov esi,first
	dec ecx
	cautal:
	mov ebx,esi
	mov eax, dword ptr[ebx]
	cmp eax, nr_cautat
	je gasit  ;sare la final daca elementul a fost gasit
	mov esi, dword ptr[ebx+4]
	cmp ecx,0
	je negasit  ;verifica daca a ajuns la finalul liste 
	dec ecx
	jmp cautal
	
	gasit:
	mov eax, nr_elemente
	sub eax,ecx
	
	push eax
	push offset mesaj_gasit
	call printf
	add esp,8
	jmp final
	
	negasit:
	push offset mesaj_negasit
	call printf
	add esp,4
	
	final:
	mov esp,ebp
	pop ebp
	ret
cauta endp

insert_first proc
	push ebp
	mov ebp, esp
	
	push 8
	call malloc
	add esp,4
	mov new, eax
	
	push offset mesaj_numar
	push offset format_fisier
	call printf
	add esp,8
	
	push offset nr
	push offset format
	call scanf
	add esp, 8
	
	mov eax, nr_elemente
	add eax, 1
	mov nr_elemente, eax
	
	cmp first, 0
	jne adauga_element

	mov ebx, nr
	mov edi, new
	mov dword ptr[edi], ebx
	mov dword ptr[edi+4], 0
	mov first, edi
	mov last, edi
	jmp final
	
	adauga_element:
	mov ebx, nr
	mov edi, new
	mov esi, first
	mov dword ptr[edi],ebx
	mov dword ptr[edi+4],esi 
	mov first,edi
	final:
	
	mov esp, ebp
	pop ebp
	ret 
insert_first endp

insert_after proc
	push ebp
	mov ebp, esp
	
	mov ecx, nr_elemente
	cmp ecx,0
	je invalid
	
	push offset mesaj_index
	push offset format_fisier
	call printf
	add esp,8
	
	push offset index
	push offset format
	call scanf
	add esp,8
	
	mov ecx,index
	cmp ecx, nr_elemente
	jg mare
	
	push 8
	call malloc
	add esp,4
	mov new, eax
	
	push offset mesaj_numar
	push offset format_fisier
	call printf
	add esp,8
	
	push offset nr
	push offset format
	call scanf
	add esp, 8
	
	mov eax, nr_elemente
	add eax, 1
	mov nr_elemente, eax
	
	mov ecx,index
	;dec ecx
	mov ebx,first
	bucla:
	mov edi, ebx
	mov ebx, dword ptr [edi+4]
	cmp ecx,0
	dec ecx
	jne bucla
	mov eax,new
	mov dword ptr[edi+4],eax
	mov dword ptr[eax+4],ebx
	mov edi,nr
	mov dword ptr[eax], edi
	jmp final
	
	invalid:
	push offset mes_invalid
	push offset format_fisier
	call printf
	add esp,8
	jmp final
	
	mare:
	push offset mes_imp
	push offset format_fisier
	call printf
	add esp,8
	
	final:
	
	mov esp, ebp
	pop ebp
	ret 
insert_after endp
	
	
	
  
start:

	push offset mesg
	call printf
	add esp,4
meniu:
	push offset mesaj_citit
	push offset format_fisier
	call scanf
	add esp,8
	
	comparare offset mesaj_citit, offset msg6
	cmp eax,0
	je sfarsit
	
	comparare offset mesaj_citit, offset msg1
	cmp eax,0
	jne intro
	
	init first, last
	jmp meniu
	
	
intro:
	comparare offset mesaj_citit, offset msg2
	cmp eax,0
	jne stergereaa
	call adauga
	jmp meniu
	
stergereaa:
	comparare offset mesaj_citit, offset msg3
	cmp eax,0
	jne introdu_fisier
	call sterge
	jmp meniu
	
introdu_fisier:
	comparare offset mesaj_citit, offset msg4
	cmp eax,0
	jne citeste_fisierr
	call adauga_fisier
	jmp meniu
	
citeste_fisierr:
	comparare offset mesaj_citit, offset msg5
	cmp eax,0
	jne afisareee
	call insert_fisier
	jmp meniu

afisareee:
	comparare offset mesaj_citit, offset msg7
	cmp eax,0
	jne cautare
	call afisare_lista
	jmp meniu

cautare:
	comparare offset mesaj_citit, offset msg8
	cmp eax,0
	jne insert_inceput
	call cauta
	jmp meniu
	
insert_inceput:
	comparare offset mesaj_citit, offset msg9
	cmp eax,0
	jne insert_dupa
	call insert_first
	jmp meniu
	
insert_dupa:
	comparare offset mesaj_citit, offset msg10
	cmp eax,0
	jne gresit
	call insert_after
	jmp meniu
	
gresit:
	push offset mesaj_gresit
	call printf 
	add esp,4
	jmp meniu
	
sfarsit:
	push 0	
	call exit

end start		