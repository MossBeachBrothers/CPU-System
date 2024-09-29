module cpu_core (
    input wire clk,
    input wire resetn,
); 

    

    iccm_wrapper iccm_inst ();

    dccm_wrapper dccm_inst();

    instruction_fetch_unit ifu_inst ();

    instruction_decode_unit idu_isnt();

    control_unit cu_inst ();

    alu alu_inst();

    register_file reg_file_inst ();

    mau mau_inst ();




endmodule 