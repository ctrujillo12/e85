// flash.c


#include "EasyREDVIO_ThingPlus.h"


#define DELAY_MS 500


// prototype for assembly language function
void led(int a);


int main(void) {
    pinMode(5, OUTPUT);
    
    while(1) {
        led(0);
        delayLoop(DELAY_MS);
        led(1);
        delayLoop(DELAY_MS);
    }
}
