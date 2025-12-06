/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdio.h>
#include <stdint.h>


/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/



#define GPIO_BASE       0x10012000
#define LED0 22      
#define LED1 23  
#define BUTTON0 19
#define BUTTON1 20

volatile uint32_t *GPIO_input_val  = (uint32_t *)(GPIO_BASE + 0x00);
volatile uint32_t *GPIO_input_en   = (uint32_t *)(GPIO_BASE + 0x04);
volatile uint32_t *GPIO_output_en  = (uint32_t *)(GPIO_BASE + 0x08);
volatile uint32_t *GPIO_output_val = (uint32_t *)(GPIO_BASE + 0x0C);
volatile uint32_t *GPIO_pue        = (uint32_t *)(GPIO_BASE + 0x10);

void init_gpio(void) {
    // Enable button inputs
    *GPIO_input_en |= (1 << BUTTON0) | (1 << BUTTON1);

    // Enable internal pull-ups for buttons
    // *GPIO_pue |= (1 << BUTTON0) | (1 << BUTTON1);

    // Enable LED outputs
    *GPIO_output_en |= (1 << LED0) | (1 << LED1);

    // Start with LEDs off
    *GPIO_output_val &= ~((1 << LED0) | (1 << LED1));
}


void delay(int ms) {
    // mtime points to a counter that increments 32768 times per second
    volatile uint64_t *mtime = (uint64_t*)0x0200bff8;

    // Given the current count (i.e., *mtime), how high will the 
    // counter be in another ms milliseconds?
    uint64_t doneTime = *mtime + (ms*32768)/1000;

    // Sit here (looping, doing nothing but checking the counter)
    // until they counter is big enough that we must have waited
    // the appropriate amount of time.
    while (*mtime < doneTime);

    return;
}

// set 1 led and then turn it off based on the sequence
void set_led(int sequence_led) {

  *GPIO_output_val &= ~((1 << LED0) | (1 << LED1)); // start with both off

  if (sequence_led == 0) {  // turn on led 0
    *GPIO_output_val |= (1 << LED0);
  } else if (sequence_led == 1) {  // turn on led 1
    *GPIO_output_val |= (1 << LED1);
  }

  delay(300);
  *GPIO_output_val &= ~((1 << LED0) | (1 << LED1));  // turn leds off
}

void set_leds(void) {
    delay(50);
    *GPIO_output_val |= ((1 << LED0) | (1 << LED1)); // set both on
    delay(800);
    *GPIO_output_val &= ~((1 << LED0) | (1 << LED1));

}


// detect which button is being pressed
int wait_for_input(void) {
  int button_pressed = -1;

  while(button_pressed == -1) {
    uint32_t input = *GPIO_input_val;
    int button_0_pressed = (input & (1 << BUTTON0)) != 0;
    int button_1_pressed = (input & (1 << BUTTON1)) != 0;
    if (button_0_pressed) {
       button_pressed = 0;
    }
    else if (button_1_pressed) {
       button_pressed = 1;
    }
  delay(100);
  }

  if (button_pressed == 0) {
    set_led(0);
  }
  else if (button_pressed == 1) {
    set_led(1);
  }
  return button_pressed;
}

// turns both leds on to show loss
void wrong_reset(void) {
  set_leds();
}


int current_length = 2;  
int sequence[12] = {0,1,1,0,1,0,1,1,0,0,0,1};

//int main(void) {
//    init_gpio();

//    while (1) {

//      uint32_t var = *GPIO_input_val;
//        if ((*GPIO_input_val & (1 << BUTTON1)) != 0) // button pressed (active low)
//            *GPIO_output_val |= (1 << LED1);        // turn LED on
//        else
//            *GPIO_output_val &= ~(1 << LED1);       // turn LED off
    

//      if ((*GPIO_input_val & (1 << BUTTON0)) != 0) // button pressed (active low)
//            *GPIO_output_val |= (1 << LED0);        // turn LED on
//        else
//            *GPIO_output_val &= ~(1 << LED0);
//            }
//}


int main(void) {
  init_gpio();
  while (1) {
  
      
      //display sequence[0:1]
      for(int i=0; i<current_length ; i++){
        set_led(sequence[i]);
        delay(100);
    
      }


      int correct = 1;

      // gather inputs up to current length and compare to display sequence
      for(int j=0; j<current_length; j++) {
          // get input
        int input = wait_for_input();

        // comparing the input to the sequence 
        if (input != sequence[j]) {
            wrong_reset(); // indicated loss
            delay(500);
            correct = 0;     
            break;         
        }
        else {
            continue;
        }
      }

      // either reset to display first 2 or keep going with pattern
      if (correct == 1) {
        
        current_length++;

        if (current_length > 5) {
          current_length = 5;
        }

      }
      else if (correct == 0) {
        
        current_length = 2;

      }  
        

      // display win !
      if (current_length == 5) {
        delay(100);
        set_leds();
        set_leds();
        set_leds();
        set_leds();
        set_leds();
        set_leds();
        break;
      }


      
  }}
