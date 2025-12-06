// lab9baseline.c


#include "EasyREDVIO_ThingPlus.h"


void triggerCheck(void) {
    volatile int seat, decel, trigger; 
    
    while (1) {
        seat = digitalRead(0);
        decel = digitalRead(1);
        trigger = seat && decel;
        digitalWrite(2, trigger);
    }
}


int main(void) {
    pinMode(0, INPUT);
    pinMode(1, INPUT);
    pinMode(2, OUTPUT);
    
    triggerCheck();
}
