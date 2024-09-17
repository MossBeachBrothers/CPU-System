module cpu_wrapper(

); 

//Core

cpu_core core_i (

);


//Power on Sequence
start_sequence start_sequence_i (

);

//PLL
pll_wrapper pll_wrapper_i (

);


peripheral peripheral_i (
    //SPI controller
);



endmodule 
