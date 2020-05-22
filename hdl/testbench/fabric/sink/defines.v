/*******************************
 * General definitions
 *******************************/

// 100 MHz clock
`define CLK_SYS_PERIOD 10.00 //ns
//`define CLK_SYS_PERIOD 10000.00 //ps

// Reset Delay, in Clock Cycles
`define RST_SYS_DELAY  		5000

/*******************************
 * Wishbone definitions
 *******************************/

// Wishbone Reference Clock
`define WB_CLOCK_PERIOD (`CLK_SYS_PERIOD)
`define WB_RESET_DELAY (10*`WB_CLOCK_PERIOD)
// Wishbone Data Width
`define WB_DATA_BUS_WIDTH 128
// Wishbone Address Width
`define WB_ADDRESS_BUS_WIDTH 4
