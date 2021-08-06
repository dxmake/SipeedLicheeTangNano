//Copyright (C)2014-2021 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8 Beta
//Created Time: 2021-08-06 14:17:09
create_clock -name clk_24M -period 41.667 -waveform {0 20.834} [get_ports {clk_24M}]
create_clock -name clk_100M -period 10 -waveform {0 5} [get_nets {clk_100M}]
create_clock -name clk_100K -period 10000 -waveform {0 5000} [get_nets {clk_o_4}]
