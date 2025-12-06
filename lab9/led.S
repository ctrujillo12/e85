// led.S
// turn LED on GPIO 5 on or off


.section .text                  // What follows is code, not data
.align 2                        // Make sure code aligns on word boundaries
.globl led                      // The "led" function can be called from C


.equ GPIO_OUTPUT_VAL, 0x1001200C     // Define a constant


// When the C code makes a call to this led function, 
// the argument value will be provided in a0


led:
    addi sp, sp, -16            // Setup our stack frame
    sw ra, 12(sp)               // Save return address


    li t1, GPIO_OUTPUT_VAL      // Put address of GPIO0 output_val register in t1
    lw t2, 0(t1)                // Store current state of output_val register in  t2
    li t3, 0x20                 // Put a 1 in the 6th bit corresponding to GPIO 5
    beqz a0, ledoff             // Go to ledoff if a0 is 0; otherwise, continue on
ledon:
    or t2, t2, t3               // Ensure t2 has a one in the GPIO 5 bit
    j finish                    // Go to finish
ledoff:
    not t3, t3
    and t2, t2, t3              // Ensure t2 has a zero in the GPIO 5 bit
finish:
    sw t2, 0(t1)                // Write updated t2 to the output_val register


    lw ra, 12(sp)               // Restore the return address
    addi sp, sp, 16             // Deallocate stack frame
    ret                         // Return to the calling function
