#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Thu Mar 29 18:30:03 EDT 2018
# SW Build 2086221 on Fri Dec 15 20:54:30 MST 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xsim ForwardingUnitTest_behav -key {Behavioral:sim_1:Functional:ForwardingUnitTest} -tclbatch ForwardingUnitTest.tcl -view /archive/scripts/ECE3570Lab2/CPU10Bits_Test_behav.wcfg -view /archive/scripts/ECE3570Lab2/CPU10Bits_Test_behav1.wcfg -log simulate.log
