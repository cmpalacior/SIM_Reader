#include "soc-hw.h"

int main (void)
{
  uint32_t *addr;
  uint32_t data;
  int dato_salida;
  data = 0x24;
  for (addr = (uint32_t *) RAM_START; addr < (uint32_t *) (RAM_START+20); addr++){
	*addr = data++;
  }
  addr = 0x40000008;
  uart0->rxtx = (*addr);
  addr = 0x4000000C;
  uart0->rxtx = (*addr);
  dato_salida = uart0->rxtx;
  return 0;

}
