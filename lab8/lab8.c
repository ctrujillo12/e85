// lab8starter.c
// Josh Brake and David_Harris@hmc.edu
// jbrake@hmc.edu
// 1/20/2020

#include "EasyREDVIO_ThingPlus.h"

#define NUM_ROWS 7
#define NUM_COLS 7

#define MAX_X 6000
#define MAX_Y 7000

#define MIN_X -6000
#define MIN_Y -7000

// physical led matrix pins for rows/cols
const uint8_t row_pins[NUM_ROWS] = {9, 14, 8, 12, 1, 7, 2}; // 1-8
const uint8_t col_pins[NUM_COLS] = {13, 3, 4, 10, 6, 11, 15};  // 9-16

// corresponding microcontroller GPIO pins
const uint8_t mcu_row_pins[NUM_ROWS] = {20, 21, 22, 23, 16, 17, 19}; //1-8
const uint8_t mcu_col_pins[NUM_COLS] = {11, 10, 9, 1, 0, 13, 12}; // 9-16


void setupPins(void) {
    for (int r = 0; r < NUM_ROWS; r++) {
        pinMode(mcu_row_pins[r], OUTPUT);
    }
    for (int c = 0; c < NUM_COLS; c++) {
        pinMode(mcu_col_pins[c], OUTPUT);
    }
}

void turnOffLeds() {

  // To turn all the LEDs off, you can send 0 to all the row pins and 1 to all the column pins.
  // led gpios needsd to be every gpio
  for (int r = 0; r < NUM_ROWS; r++) {
        digitalWrite(mcu_row_pins[r], 0);
    }
    for (int c = 0; c < NUM_COLS; c++) {
        digitalWrite(mcu_col_pins[c], 1);
    }

}

void turnOnLeds() {

  // To turn all the LEDs off, you can send 0 to all the row pins and 1 to all the column pins.
  // led gpios needsd to be every gpio
  for (int r = 0; r < NUM_ROWS; r++) {
        digitalWrite(mcu_row_pins[r], 1);
    }
    for (int c = 0; c < NUM_COLS; c++) {
        digitalWrite(mcu_col_pins[c], 0);
    }

}

void setLed(int active_row, int active_col) {

  for (int r = 0; r < NUM_ROWS; r++){
    if (r == active_row) 
      digitalWrite(mcu_row_pins[r], 1);
    else 
      digitalWrite(mcu_row_pins[r], 0);

    }

  for (int c = 0; c < NUM_COLS; c++){     
    if (c == active_col) 
      digitalWrite(mcu_col_pins[c], 0);
    else
      digitalWrite(mcu_col_pins[c], 1);
     
    }
}

void map(int x, int y) {

  int row_led;
  int col_led;

  // clamp values to min/max
  if (x > MAX_X) x = MAX_X;
  if (x < MIN_X) x = MIN_X;
  if (y > MAX_Y) y = MAX_Y;
  if (y < MIN_Y) y = MIN_Y;

  // when to set center led
  if (x > -80 && x < 80 &&
        y > -80 && y < 80) {
        setLed(4,4);
        return;
  }

  // now map x and y to led number
  col_led = ((x - MIN_X) * (NUM_COLS - 1)) / (MAX_X - MIN_X);
    row_led = ((y - MIN_Y) * (NUM_ROWS - 1)) / (MAX_Y - MIN_Y);
  setLed(row_led, col_led);

  

  
}

int main(void) {
  volatile uint8_t debug;
  volatile int16_t x, y, disx, disy;

  setupPins();
  turnOnLeds();
  delayLoop(500);
  turnOffLeds();
  delayLoop(500);

  spiInit(10, 1, 1); // Initialize SPI pins

  // Setup the LIS3DH
  spiWrite(0x20, 0x77); // highest conversion rate, all axis on
  spiWrite(0x23, 0x88); // block update, and high resolution

  // Check WHO_AM_I register. should return 0x33
  debug = spiRead(0x0F);

  while (1) {
    // Collect the X and Y values from the LIS3DH
    // expressed as two’s complement left-justified
    x = spiRead(0x28) | (spiRead(0x29) << 8);
    y = spiRead(0x2A) | (spiRead(0x2B) << 8);

    turnOffLeds();
    map(x,y);

    delayLoop(100);
  }
}

