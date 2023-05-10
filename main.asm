list p=16f877A
#include <p16f877a.inc>
    
__CONFIG _FOSC_EXTRC & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_ON & _CPD_OFF & _WRT_OFF & _CP_OFF
    
RES_VECT  CODE    0x0000
    goto    INICJUJ

    
MAIN_PROG CODE

INICJUJ
 bcf STATUS, RP1
 bsf STATUS, RP0
 
 movlw 0x00
 movwf TRISB
 movlw 0xFF
 movwf TRISC

 bcf STATUS, RP1
 bcf STATUS, RP0
  
 
 movlw 0x00
 
 movwf 0x20 ;zmienna: bit 0: czekanie niezalezne flaga,
	    ;	      bit 1: mryganie flaga,
 
 movwf 0x21 ;zmienna: czekanie niezalezne licznik 1 (jezeli rozne od 0 to czekanie dziala, przypisana wartosc to czas czekania)
 movwf 0x22 ;zmienna: czekanie niezalezne licznik 2
 movwf 0x23 ;zmienna: czekanie niezalezne licznik 3
 
 movwf 0x24 ;zmienna: czekanie normalne licznik 1
 movwf 0x25 ;zmienna: czekanie normalne licznik 2
 movwf 0x26 ;zmienna: czekanie normalne licznik 3
 
 movwf 0x28 ;zmienna: odpowiedz gracza
 movwf 0x29 ;zmienna: kolorowa lampka do zapalenia
 movwf 0x2A ;zmienna: zycia
 movwf 0x2B ;zmienna: lampki do wyswietlenia
 
 movlw 0x30 ;STALA: pierwszy/poczatkowy adres sekwencji
 movwf 0x27 ;zmienna: ostatni adres sekwencji (ustawiany ostatni jako pierwszy)
 
 goto CZEKAJ_NA_START
 
 
CZEKAJ_NA_START
 
 movf 0x21, 1 ;sprawdzenie czy czas mrygniecia minal (czas petli niezaleznej)
 btfsc STATUS, Z
 call MRYGANIE_I_USTAWIENIE_LICZNIKA
 
 call CZEKANIE_NIEZALEZNE
 
 movf PORTC, 1 ;sprawdzenie czy ktorys przycisk jest wcisniety
 btfss STATUS, Z
 goto START
 goto CZEKAJ_NA_START
 

START
 
 movlw b'00000011'
 movwf 0x2A ;ustawienie zyc na 3
 
 goto LOSUJ_KROK_SEKWENCJI
 
 
LOSUJ_KROK_SEKWENCJI
 
 movf 0x27, 0
 movwf FSR ;zapisanie adresu rejestru do adresacji posredniej kolejnej czesci sekwencji
 
 movf 0x23, 0 ;wybieranie "losowej" liczby (aktualna wartosc licznika 3, trudna do przewidzenia, zalezy od tego kiedy gracz zakonczy dana sekcje)
 andlw b'00000011'
 movwf INDF ;przypisanie do rejestru wskazanego przez FSR
 
 incf 0x27, 1 ;przesuniecie ostatniego adresu sekwencji o 1 rejestr do przodu
 
 goto WYSWIETL_SEKWENCJE
 
 
WYSWIETL_SEKWENCJE
 
 movlw b'00000000' ;przygotowanie lampek do wyswietlania sekwencji
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 
 movlw 0x03 ;STALA oznaczajaca czas czekania
 call CZEKANIE_DLUGIE
 
 movlw 0x30
 movwf FSR ;ustawienie obecnego adresu na poczatkowy 
 
 WYSWIETL_KOLEJNY_KROK
 movf INDF, 0
 call WYSWIETL_JEDEN_KROK
 
 movlw 0x02 ;STALA oznaczajaca czas czekania
 call CZEKANIE_DLUGIE
 
 movlw b'00000000' ;zgaszenie lampki przed zaswieceniem kolejnej
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 
 movlw 0xBF ;STALA oznaczajaca czas czekania
 call CZEKANIE_KROTKIE
 
 incf FSR, 1 ;przesuniecie obecnego adresu sekwencji o 1 do przodu
 
 movf FSR, 0 ;sprawdzenie czy obecny adres to adres ostatni (czy zakonczyc proces wyswietlania)
 subwf 0x27, 0
 btfsc STATUS, Z
 goto WPROWADZANIE_ODP
 goto WYSWIETL_KOLEJNY_KROK
 
 
WPROWADZANIE_ODP
 
 movlw 0x30
 movwf FSR ;ustawienie obecnego adresu na poczatkowy 
 
 CZEKAJ_NA_ODP
 movf 0x21, 1 ;czekanie niezalezne w celu losowania licznika 3 do kolejnych krokow sekwencji
 btfsc STATUS, Z
 incf 0x21, 1
 call CZEKANIE_NIEZALEZNE
 
 movf PORTC, 0 ;sprawdzenie czy ktorys z czterech przyciskow kolorowych jest wcisniety
 andlw b'00011110'
 btfss STATUS, Z
 goto SPRAWDZ_ODP
 goto CZEKAJ_NA_ODP
 
 
SPRAWDZ_ODP
 
 movwf 0x28 ;zapisanie odpowiedzi gracza
 
 movlw 0x0A ;STALA oznaczajaca czas czekania
 call CZEKANIE_KROTKIE
 
 call WYSWIETL_ODP ;mrygniecie lampki w celu zasygnalizowania graczowi o pomyslnym wcisnieciu przycisku
 
 movlw 0x8F ;STALA oznaczajaca czas czekania
 call CZEKANIE_KROTKIE
 
 movlw b'00000001' ;zgasniecie mrygniecia lampki
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 
 CZEKAJ_NA_ZWOLNIENIE_PRZYCISKOW
 
 movlw 0x0F ;STALA oznaczajaca czas czekania
 call CZEKANIE_KROTKIE
 
 movf PORTC, 0 ;sprawdzenie czy ktorys z czterech przyciskow kolorowych jest wcisniety nadal
 andlw b'00011110'
 btfss STATUS, Z
 goto CZEKAJ_NA_ZWOLNIENIE_PRZYCISKOW
 
 btfss INDF, 0 ;sprawdzenie bitu 0 rejestru (czy jest to lampka nr 0 lub 2 czy 1 lub 3)
 goto NR_0_LUB_2_ODP
 goto NR_1_LUB_3_ODP
 NR_0_LUB_2_ODP
 btfss INDF, 1 ;sprawdzenie bitu 1 rejestru (czy jest to lampka nr 0 czy 2)
 goto NR_0_GREEN_ODP
 goto NR_2_YELLOW_ODP
 NR_1_LUB_3_ODP
 btfss INDF, 1 ;sprawdzenie bitu 1 rejestru (czy jest to lampka nr 1 czy 3)
 goto NR_1_RED_ODP
 goto NR_3_BLUE_ODP
 
NR_0_GREEN_ODP
 movf 0x28, 0
 andlw b'00000010'
 btfss STATUS, Z
 goto ODP_OK
 goto ODP_ZLE
 
NR_1_RED_ODP
 movf 0x28, 0
 andlw b'00000100'
 btfss STATUS, Z
 goto ODP_OK
 goto ODP_ZLE
 
NR_2_YELLOW_ODP
 movf 0x28, 0
 andlw b'00001000'
 btfss STATUS, Z
 goto ODP_OK
 goto ODP_ZLE
 
NR_3_BLUE_ODP
 movf 0x28, 0
 andlw b'00010000'
 btfss STATUS, Z
 goto ODP_OK
 goto ODP_ZLE
 
 
ODP_OK ;Przejscie do nastepnego kroku sekwencji 
 incf FSR, 1 ;przesuniecie obecnego adresu sekwencji o 1 do przodu
 movf FSR, 0 ;sprawdzenie czy obecny adres to adres ostatni (czy zakonczyc proces odpowiadania)
 subwf 0x27, 0
 btfss STATUS, Z
 goto CZEKAJ_NA_ODP
 goto LOSUJ_KROK_SEKWENCJI
 
ODP_ZLE ;Zmniejszenie liczby zyc, jezeli zycia = 0 to koniec gry, jezeli nie to wyswietl sekwencje jeszcze raz
 movlw 0xFF ;STALA oznaczajaca czas czekania
 call CZEKANIE_KROTKIE
 decfsz 0x2A, 1
 goto WYSWIETL_SEKWENCJE
 goto KONIEC_GRY
 
KONIEC_GRY
 
 movlw b'00000000' ;zgasniecie mrygniecia lampki
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 
 movlw 0x03 ;STALA oznaczajaca czas czekania
 call CZEKANIE_DLUGIE
 
 movlw 0x30 ;STALA pierwszy/poczatkowy adres sekwencji
 movwf 0x27 ;zresetowanie pierwszego adresu sekwencji
 
 goto CZEKAJ_NA_START ;powrot do stanu poczatkowego
 
 
 
CZEKANIE_NIEZALEZNE ;Niezalena petla czasowa (wykonuje jedno zmniejszenie i konczy dzialanie)
 bsf 0x20, 0 ;sprawdzanie czy zmniejszyc licznik 1 (jezeli l1 != 0, l2 == 0, l3 == 0)
 movf 0x21, 1
 btfsc STATUS, Z
 bcf 0x20, 0
 movf 0x22, 1
 btfss STATUS, Z
 bcf 0x20, 0
 movf 0x23, 1
 btfss STATUS, Z
 bcf 0x20, 0
 btfsc 0x20, 0
 call CZEK_N_1
 ;
 bsf 0x20, 0 ;sprawdzanie czy zmniejszyc licznik 2 (jezeli l2 != 0, l1 == 0)
 movf 0x22, 1
 btfsc STATUS, Z
 bcf 0x20, 0
 movf 0x23, 1
 btfss STATUS, Z
 bcf 0x20, 0
 btfsc 0x20, 0
 call CZEK_N_2
 ;
 movf 0x23, 1 ;sprawdzanie czy zmniejszyc licznik 3 (jezeli l3 != 0)
 btfss STATUS, Z
 call CZEK_N_3
 ;
 return
CZEK_N_1 ;zmniejszenie licznika 1 i wymaksowanie licznika 2
 decf 0x21, 1
 movlw 0x1F ;STALA bedaca mnoznikiem czasu czekania
 movwf 0x22
 return
CZEK_N_2 ;zmniejszenie licznika 2 i wymaksowanie licznika 3
 decf 0x22, 1
 movlw 0xFF
 movwf 0x23
 return
CZEK_N_3 ;zmniejszenie licznika 3
 decf 0x23, 1
 return
 
 
CZEKANIE_DLUGIE ;Zwykla petla czasowa, 3 liczniki (wykonuje sie dopuki nie wyzeruje pierwszego licznika po czym konczy dzialanie) 
 movwf 0x24 ;przypisanie liczby oznaczajacej dlugosc czekania do pierwszego licznika
 CZEK_D_1
 movlw 0xFF
 movwf 0x25
 decfsz 0x24, 1
 goto CZEK_D_2
 return
 CZEK_D_2
 movlw 0xFF
 movwf 0x26
 decfsz 0x25, 1
 goto CZEK_D_3
 goto CZEK_D_1
 CZEK_D_3
 decfsz 0x26, 1
 goto CZEK_D_3
 goto CZEK_D_2
 
 
CZEKANIE_KROTKIE ;Zwykla petla czasowa, 2 liczniki (wykonuje sie dopuki nie wyzeruje pierwszego licznika po czym konczy dzialanie) 
 movwf 0x24 ;przypisanie liczby oznaczajacej dlugosc czekania do pierwszego licznika
 CZEK_K_1
 movlw 0xFF
 movwf 0x25
 decfsz 0x24, 1
 goto CZEK_K_2
 return
 CZEK_K_2
 decfsz 0x25, 1
 goto CZEK_K_2
 goto CZEK_K_1
 
 
MRYGANIE_I_USTAWIENIE_LICZNIKA
 movlw 0x01 ;STALA oznaczajaca dlugosc swiecenia podczas mrygania
 movwf 0x21 
 btfss 0x20, 1 ;Mrygniecie lampek (jezeli zapalone zgas, jezeli zgasone zapal)
 goto MRYGANIE_ON
 goto MRYGANIE_OFF
 MRYGANIE_ON
 movlw b'00010100' ;fajny patern mrygania
 movwf PORTB
 bsf 0x20, 1 ;ustawienie flagi na 1 = wlaczone
 return
 MRYGANIE_OFF 
 movlw b'00001010' ;fajny patern mrygania
 movwf PORTB
 bcf 0x20, 1 ;ustawienie flagi na 0 = wylaczone
 return
 
 
WYSWIETL_JEDEN_KROK ;Przejscie do wartosci w rejestrze W w celu sprawdzenia, ktora lampke zapalic
 movwf 0x29
 btfss 0x29, 0 ;sprawdzenie bitu 0 rejestru (czy jest to lampka nr 0 lub 2 czy 1 lub 3)
 goto NR_0_LUB_2
 goto NR_1_LUB_3
 NR_0_LUB_2
 btfss 0x29, 1 ;sprawdzenie bitu 1 rejestru (czy jest to lampka nr 0 czy 2)
 goto NR_0_GREEN
 goto NR_2_YELLOW
 NR_1_LUB_3
 btfss 0x29, 1 ;sprawdzenie bitu 1 rejestru (czy jest to lampka nr 1 czy 3)
 goto NR_1_RED
 goto NR_3_BLUE
 
NR_0_GREEN
 movlw b'00000010'
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 return
 
NR_1_RED
 movlw b'00000100'
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 return
 
NR_2_YELLOW
 movlw b'00001000'
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 return
 
NR_3_BLUE
 movlw b'00010000'
 movwf 0x2B
 call WYSWIETL_LAMPKI_I_ZYCIA
 return
 

WYSWIETL_ODP ;Zamiana odpowiedzi gracza na lampke do zapalenia
 btfsc 0x28, 1
 movlw b'00000000'
 
 btfsc 0x28, 2
 movlw b'00000001'
 
 btfsc 0x28, 3
 movlw b'00000010'
 
 btfsc 0x28, 4
 movlw b'00000011'
 
 goto WYSWIETL_JEDEN_KROK
 
 
WYSWIETL_LAMPKI_I_ZYCIA ;Poloczenie wyswietlenia kolorowych lampek i aktualnej liczby zyc
 movf 0x2A, 0
 sublw 0x03
 btfsc STATUS, Z
 goto ZYCIA_3
 
 movf 0x2A, 0
 sublw 0x02
 btfsc STATUS, Z
 goto ZYCIA_2
 
 movf 0x2A, 0
 sublw 0x01
 btfsc STATUS, Z
 goto ZYCIA_1
 
 movf 0x2A, 0
 btfsc STATUS, Z
 goto ZYCIA_0
 
ZYCIA_3
 movf 0x2B, 0
 iorlw b'11100001'
 movwf PORTB
 return
 
ZYCIA_2
 movf 0x2B, 0
 iorlw b'01100001'
 movwf PORTB
 return
 
ZYCIA_1
 movf 0x2B, 0
 iorlw b'00100001'
 movwf PORTB
 return
 
ZYCIA_0
 movf 0x2B, 0
 iorlw b'00000001'
 movwf PORTB
 return
 
 
 
ELO
 movlw 0x00
 movwf PORTB
 goto $
 end