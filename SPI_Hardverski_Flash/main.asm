;
; SPI_Hardverski_Flash_memorija.asm
;
; Created: 16.11.2022. 08:27:12
; Author : Aleksandar Bogdanovic
;

.include "m328pdef.inc"

.dseg

// PIN layout

.equ SS		= 2						// PB2, D10, SS
.equ MOSI	= 3						// PB3, D11, MOSI
.equ MISO	= 4						// PB4, D12, MISO
.equ SCK	= 5						// PB5, D13, SCK

.cseg
.org 0x00

	rjmp init

init:
	rcall spi_init
	rjmp main

main:
	;-------------------------------
	;rcall enable_reset
	;-------------------------------
	;rcall reset_device
	;-------------------------------
	;rcall read_jedec_id
	;-------------------------------
	;rcall read_flash_id
	;-------------------------------
	;rcall read_manufacturer_id
	;-------------------------------
	;rcall write_enable
	;rcall write_disable
	;-------------------------------
	;rcall block_erase
	;-------------------------------
	;rcall page_program
	;-------------------------------
	;rcall chip_erase
	;-------------------------------
	;rcall write_enable_status_reg
	;-------------------------------
	;rcall w_status_register1
	;rcall w_status_register2
	;rcall w_status_register3
	;-------------------------------
	;rcall status_register1
	;rcall status_register2
	;rcall status_register3
	;-------------------------------
	rcall read_data
	;-------------------------------

end: 
	rjmp end

spi_init:
	ldi r17, 0b00101100				// Ukljucujemo PB 2, 3 i 5 kao output
	out DDRB, r17
	ldi r17, 0b01010011				// Ukljucujemo bitove SPE, MSTR, SPR1 i SPR0 u SPI Control Registru
	out SPCR, r17					// fsck = fosc/128, |SPIE|SPE|DORD|MSTR|CPOL|CPHA|SPR1|SPR0|
	rcall disable_spi
	ret

enable_spi:		
	cbi PORTB, SS					// Zato sto na low (0V) detektuje emitovanje 
	ret
disable_spi:
	sbi PORTB, SS
	ret

write_byte:
	mov r17, r19
again:								//					 |MSB| - | - | - | - | - | - |LSB|
	out SPDR, r17					// SPI Data Register |R/w|R/w|R/w|R/w|R/w|R/w|R/w|R/w|					 
loop:
	in r18, SPSR					// SPI Status Registar |SPIF|WCOL| - | - | - | - | - |SPI2X|
	sbrs r18, SPIF					// SPIF: SPI Interrupt Flag
	rjmp loop
	ret

enable_reset:
	rcall enable_spi
	ldi r19, 0x66					// Enable Reset (66h)
	rcall write_byte
	rcall disable_spi
	ret

reset_device:
	rcall enable_spi
	ldi r19, 0x99					// Reset Device (99h)
	rcall write_byte
	rcall disable_spi
	ret

write_enable_status_reg:
	rcall enable_spi
	ldi r19, 0x50					// Write Enable for Volatile Status Register (50h)
	rcall write_byte
	rcall disable_spi
	ret

write_enable:
	rcall enable_spi
	ldi r19, 0x06					// Write Enable (06h)
	rcall write_byte
	rcall disable_spi
	ret

write_disable:
	rcall enable_spi
	ldi r19, 0x04					// Write Disable (04h)
	rcall write_byte
	rcall disable_spi
	ret

block_erase:
	rcall enable_spi
	ldi r19, 0xD8					// Block Erase (64KB) (D8h)
	rcall write_byte
	ldi r19, 0x20					// Security Register 1: A23-16 = 00h; A15-8 = 10h; A7-0 = byte address
	rcall write_byte
	ldi r19, 0x00					// Address data
	rcall write_byte
	ldi r19, 0x00					// Address data
	rcall write_byte
	rcall disable_spi
	ret

chip_erase:
	rcall enable_spi
	ldi r19, 0xC7					// Chip Erase (C7h or 60h) 
	rcall write_byte
	rcall disable_spi
	ret

status_register1:
	rcall enable_spi
	ldi r19, 0x05					// Read Status Register-1 (05h) 
	rcall write_byte
// Receive status 1	
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

status_register2:
	rcall enable_spi
	ldi r19, 0x35					// Read Status Register-2 (35h) 
	rcall write_byte
// Receive status 1	
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

status_register3:
	rcall enable_spi
	ldi r19, 0x15					// Read Status Register-3 (15h) 
	rcall write_byte
// Receive status 1	
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

w_status_register1:
	rcall enable_spi
	ldi r19, 0x01					// Write Status Register-1 (01h)
	rcall write_byte
// Receive status 1	
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

w_status_register2:
	rcall enable_spi
	ldi r19, 0x31					// Write Status Register-2 (31h)
	rcall write_byte
// Receive status 1	
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

w_status_register3:
	rcall enable_spi
	ldi r19, 0x11					// Write Status Register-3 (11h)
	rcall write_byte
// Receive status 1		
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

page_program:
	ser r24
	rcall write_enable
	rcall enable_spi
	ldi r19, 0x02					// Page Program (02h)
	rcall write_byte
// Address data
	ldi r19, 0x1F					// Address data
	rcall write_byte
	ldi r19, 0xFF					// Address data
	rcall write_byte
	ldi r19, 0x00					// Address data
	rcall write_byte
// Write bytes
wr_data:
	ldi r19, 0x41					// Data
	rcall write_byte
	ldi r19, 0x63
	rcall write_byte
	ldi r19, 0x61
	rcall write_byte
	//dec r24
	breq izlaz
	//rjmp wr_data
izlaz:	
	rcall disable_spi
	ret

read_data:
	rcall enable_spi
	ldi r19, 0x03					// Read Data (03h)
	rcall write_byte
// Address data
	ldi r19, 0x1F					// Address data
	rcall write_byte
	ldi r19, 0xFF					// Address data
	rcall write_byte
	ldi r19, 0x00					// Address data
	rcall write_byte
// Receive bytes
	ldi r19, 0x00					// Misc data
	rcall write_byte
	ldi r19, 0x00					// Misc data
	rcall write_byte
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall disable_spi
	ret

read_flash_id:
	rcall enable_spi
	ldi r19, 0x4B					// Read Unique ID Number (4Bh)
	rcall write_byte
	ldi r19, 0xFF					// Misc data
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall write_byte
// Get unique id
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall disable_spi
	ret

read_jedec_id:
	rcall enable_spi
	ldi r19, 0x9F					// Read JEDEC ID (9Fh)
	rcall write_byte
// Get jedec id
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall disable_spi
	ret

	read_manufacturer_id:
	rcall enable_spi
	ldi r19, 0x90					//Read Manufacturer / Device ID (90h) 
	rcall write_byte
	// Get Device ID
	ldi r19, 0x00					// Misc data
	rcall write_byte
	rcall write_byte
	rcall write_byte
	rcall disable_spi
	ret