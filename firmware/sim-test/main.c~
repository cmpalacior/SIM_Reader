#include "soc-hw.h"

void irq_handler(uint32_t irq)
{
      lcd_wait();
      sim0->sim_reg = 0x10;
      lcd_write(sim0->data0, sim0->data1, sim0->data2, sim0->data3, sim0->data4);
      lcd_wait();
      lcd0->lcd_ins = LCD_CHR;
      lcd_wait();
      sim0->sim_reg = 0x11;
      lcd_write(sim0->data0, sim0->data1, sim0->data2, sim0->data3, sim0->data4);
      lcd_wait();
      lcd0->lcd_ins = LCD_CHR;
      lcd_wait();
      sim0->sim_reg = 0x12;
      lcd_write(sim0->data0, sim0->data1, sim0->data2, sim0->data3, sim0->data4);
        lcd_wait();
      lcd0->lcd_ins = LCD_CHR;
      lcd_wait();
      sim0->sim_reg = 0x13;
      lcd_write(sim0->data0, sim0->data1, sim0->data2, sim0->data3, sim0->data4);
}

int main ()
{
  irq_enable();
  irq_set_mask(0x00000004);
  lcd_wait();
  lcd_write(0x20202020, 0x4C656374, 0x6F722064, 0x65205349, 0x4D202020);
  lcd_wait();
  lcd0->lcd_ins = LCD_CHR;
  lcd_wait();
  lcd_write(0x20202020, 0x20202020, 0x20202020, 0x20202020, 0x20202020);
  lcd_wait();
  lcd0->lcd_ins = LCD_CHR;
  lcd_wait();
  lcd_write(0x20436872, 0x69737469, 0x616E2050, 0x616C6163, 0x696F2020);
  lcd_wait();
  lcd0->lcd_ins = LCD_CHR;
  lcd_wait();
  lcd_write(0x204D6967, 0x75656C20, 0x4C696D61, 0x73202020, 0x20202020);
  lcd_wait();
  lcd0->lcd_ins = LCD_CHR;
  sim0->sim_reg = SIM_EN;
  while (! (sim0->sim_cr & SIM_DONE));
  return 0;
}
