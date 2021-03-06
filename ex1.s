        .syntax unified
	
	      .include "efm32gg.s"

	/////////////////////////////////////////////////////////////////////////////
	//
  // Exception vector table
  // This table contains addresses for all exception handlers
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .section .vectors
	
	      .long   stack_top               /* Top of Stack                 */
	      .long   _reset                  /* Reset Handler                */
	      .long   dummy_handler           /* NMI Handler                  */
	      .long   dummy_handler           /* Hard Fault Handler           */
	      .long   dummy_handler           /* MPU Fault Handler            */
	      .long   dummy_handler           /* Bus Fault Handler            */
	      .long   dummy_handler           /* Usage Fault Handler          */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* SVCall Handler               */
	      .long   dummy_handler           /* Debug Monitor Handler        */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* PendSV Handler               */
	      .long   dummy_handler           /* SysTick Handler              */

	      /* External Interrupts */
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO even handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO odd handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler

	      .section .text

	/////////////////////////////////////////////////////////////////////////////
	//
	// Reset handler
  // The CPU will start executing here after a reset
	//
	/////////////////////////////////////////////////////////////////////////////

	      .globl  _reset
	      .type   _reset, %function
        .thumb_func
_reset:

    ///enable clock 
    ldr r1, cmu_base_addr //load register with word
    ldr r2, [r1, #CMU_HFPERCLKEN0]
    mov r3, #1
    lsl r3, r3, #CMU_HFPERCLKEN0_GPIO  //shift left
    orr r2, r2, r3  //Logical OR
    str r2, [r1, #CMU_HFPERCLKEN0]  //Store register word

    //set up pins for output

    ldr r2, gpio_pa_base

    mov r3, #0x2
    str r3, [r2, #GPIO_CTRL]

    mov r3, #0x55555555
    str r3, [r2, #GPIO_MODEH]



    //make buttons available
    
    ldr r3, gpio_pc_base
    
    mov r4, #0xff
    str r4, [r3, #GPIO_DOUT]

    mov r4, #0x33333333
    str r4, [r3, #GPIO_MODEL]
	
    //set up interrupts
    ldr r0, gpio_base_addr
    mov r4, #0x22222222
    str r4, [r0, #GPIO_EXTIPSELL]

    mov r4, #0xff
    str r4, [r0, #GPIO_EXTIFALL]
    str r4, [r0, #GPIO_EXTIRISE]
    str r4, [r0, #GPIO_IEN]

    ldr r4, =0x802
    ldr r5, =ISER0
    str r4, [r5]

l:
	ldr r4, [r0, #GPIO_IF]
    str r4, [r0, #GPIO_IFC] //clearing the interrupt
    
    ldr r4, [r3, #GPIO_DIN]
    lsl r4, r4, #8
    mov r5, #0
    eor r4, r4, r5
    str r4, [r2, #GPIO_DOUT]
    b l
	
	/////////////////////////////////////////////////////////////////////////////
	//
  // GPIO handler
  // The CPU will jump here when there is a GPIO interrupt
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
gpio_handler:  
    ldr r4, [r0, #GPIO_IF]
    str r4, [r0, #GPIO_IFC] //clearing the interrupt
    
    ldr r4, [r3, #GPIO_DIN]
    lsl r4, r4, #8
    mov r5, #0
    eor r4, r4, r5
    str r4, [r2, #GPIO_DOUT]
	
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
dummy_handler:  
        b .  // do nothing

gpio_pa_base:
    .long GPIO_PA_BASE

cmu_base_addr:
    .long CMU_BASE

gpio_pc_base:
    .long GPIO_PC_BASE

gpio_base_addr:
    .long GPIO_BASE
