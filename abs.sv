//Absolute value function
function [31:0] abs;
    input [31:0] data;
    begin
        if (data[31])  // Assuming a 32-bit signed integer, check the sign bit
            abs = -data;
        else
            abs = data;
    end
endfunction
