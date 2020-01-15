#ifndef inset
#define inset
#endif //_HEADER_FILE_H_
//FULL ISA DESCRIPTION (D16i Arch)
//Defenitions of the intructions of the D16i Architecture
//RISC Instructions
#define iNOOP            0x00
#define iLI              0x01 //Load immediate
#define iLSINS           0x02 //LOAD STORE INSTRUCTIONS
#define iALUF            0x03
#define iINMI            0x04
#define iJMPR            0x05
#define iMOVF            0x06
#define iJMPD            0x07 //Jump direct
//ALU Instructions (OPs)
#define iADD             0x00
#define iSUB             0x01
#define iADDCO           0x02 //Carry out
#define iSUBCO           0x03 
#define iADDCI           0x04 //Carry In
#define iSUBCI           0x05
#define iADDCOCI         0x06 //Carry out Carry in
#define iSUBCOCI         0x07
#define iAND             0x08
#define iXOR             0x09
#define iOR              0x0a
#define iNOT             0x0b
#define iSHFTL           0x0c
#define iSHFTR           0x0d
//INMI Instruction
#define iSPpp            0x00
#define iSPss            0x01
#define iSTSMR           0x02
#define iHALT            0x07 //This will only call an Exit() Function on kernel provably
#define iSYSC            0x09 //This will actually emit an soft interrupt
#define iRETURN          0x0a //Return from SYSCALL //Could save about 2 instruction cycle, So im keeping it
#define iCR_SWAP         0x0b //For carry in operations, allows to calculate infinite binary values
#define iSTFLAGS         0x0c

//#define iSPOP            0x03
//#define iSPUSH           0x04
//#define iBPR             0x05 //mov sp, bp; does the same
//#define iSPOPNR          0x06
//#define iRBP             0x08 //Return to Base Pointer //Can be replaced with a simple mov sp, bp;
/*Supported only when there is hardware Stack*/
//#define iuBPR            0x06
//#define iuSPpp           0x0c //User Stack Pointer
//#define iuSPss           0x0d
//#define iuPOP            0x0e
//#define iuPUSH           0x0f
//#define iMBS_APR         0x0g //Not really needed. So..
//#define iMBS_BPR         0x0h //Not really needed. So..
//#define iSTRAM           0x05 //ARP BUS TO RAM //Discontinued Architecture Ins
//JMP miicroIns
#define iJMPAB           0x00
#define iJMPEQ           0x01
#define iJMPBA           0x02
#define iJMPNEG          0x03
#define iJMPOVR          0x04
#define iJMPZERO         0x05
#define iJMPNONE         0x06
//Special Purpose Registers
//#define iAPR             0x00
//#define iBPR             0x01
//#define iCPR             0x02
//#define iuSP             0x02
//#define iuBP             0x03
//#define iSSP             0x02
#define iSP              0x00
#define iBP              0x01
#define iDMAP            0x02
#define iKRNLP           0x03
#define iTMRIP           0x04
#define iSYSCR           0x05
#define iLPR             0x06 //Return Register ADDR after SYSC
#define iSTMR            0x07
//MOV micro Instructions
#define iMOVGPRGPR       0x00
#define iMOVGPRSPR       0x01
//#define iMOVSTKGPR       0x02
//#define iMOVGPRSTK       0x04
#define iMOVSPRGPR       0x03
#define iMOVTMRGPR       0x05
#define iMOVDMARGPR      0x06
//Main GPRS
#define iAX              0x00
#define iBX              0x01
#define iCX              0x02
#define iDX              0x03
#define iEX              0x04
#define iFX              0x05
#define iGX              0x06
#define iHX              0x07

#define STACK_ADDR       0xffff //Just because of the standarts
/*
ERRR ERROR_REGISTER: Any illegal execution will create an exeption code on this register
*/

/*
Atomic Instructions
#define LL //Load Link
#define SC //Store Conditional
//Both depend on the LRP registers which is also used for system calls
Also there are not Branch slots, because there will be no multi threading implementation
*/