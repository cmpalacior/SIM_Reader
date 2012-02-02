#include "soc-hw.h"

uart_t   *uart0  = (uart_t *)   0xF0000000;
lcd_t    *lcd0 	 = (lcd_t *)  	0xF0010000;
key_t    *key0 	 = (key_t *)  	0xF0020000;
sim_t    *sim0 	 = (sim_t *)  	0xF0030000;
uint32_t *sram0  = (uint32_t *) 0x40000000;

isr_ptr_t isr_table[32];


void tic_isr();
/***************************************************************************
 * IRQ handling
 */
void isr_null()
{
}

/*
void irq_handler(uint32_t pending)
{
	int i;

	for(i=0; i<32; i++) {
		if (pending & 0x01) (*isr_table[i])();
		pending >>= 1;
	}
}*/

void isr_init()
{
	int i;
	for(i=0; i<32; i++)
		isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
	isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
	isr_table[irq] = &isr_null;
}

/***************************************************************************
 * LCD Functions
 */
void lcd_wait()
{   
	while (! (lcd0->lcd_cr & LCD_RDY));
}

void lcd_write(uint32_t dat0, uint32_t dat1, uint32_t dat2, uint32_t dat3, uint32_t dat4)
{
	if(lcd0->lcd_cr & LCD_RDY){
	lcd0->data0 = dat0;
	lcd0->data1 = dat1;
	lcd0->data2 = dat2;
	lcd0->data3 = dat3;
	lcd0->data4 = dat4;
	lcd0->lcd_ins = LCD_WR;	
	}
}

void lcd_clear()
{
	if(lcd0->lcd_cr & LCD_RDY){
	lcd0->lcd_ins = LCD_CLR;
	}
}
/***************************************************************************
 * UART Functions
 */
void uart_init()
{
	//uart0->ier = 0x00;  // Interrupt Enable Register
	//uart0->lcr = 0x03;  // Line Control Register:    8N1
	//uart0->mcr = 0x00;  // Modem Control Register

	// Setup Divisor register (Fclk / Baud)
	//uart0->div = (FCPU/(57600*16));
}

char uart_getchar()
{   
	while (! (uart0->ucr & UART_DR)) ;
	return uart0->rxtx;
}

void uart_putchar(char c)
{
	while (uart0->ucr & UART_BUSY) ;
	uart0->rxtx = c;
}

void uart_putstr(char *str)
{
	char *c = str;
	while(*c) {
		uart_putchar(*c);
		c++;
	}
}

