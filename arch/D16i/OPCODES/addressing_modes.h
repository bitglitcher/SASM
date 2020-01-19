
#define reg_lo          0x00
#define reg_hi          0x01
//#define reg_ft			0x02 //Non real opcode
//Now its real but not implemented

//Braching signals
#define branch_ab		0x00
#define branch_eq		0x01
#define branch_ba		0x02
#define branch_zero		0x03
#define branch_ovr		0x04
#define branch_neg		0x05
#define branch_noop		0x06

//Addresing modes
#define ALUF_ADDR_MODE(ins, op, rt, s1, s2) ((ins) | (op << 3) | (rt << 7) | (s1 << 10) | (s2 << 13))
#define LI_ADDR_MODE(ins, hl, gs, rt, immv) ((ins) | (hl << 3) | (gs << 4) | (rt << 5) | (immv << 8))
#define JMPD_ADDR_MODE(ins, immv) ((ins) | (immv << 3))
#define MOVF_ADDR_MODE(ins, hl_t, hl_s, ft_b, op, rt, s1) ((ins) | (hl_t << 3) | (hl_s << 4) | (ft_b << 5) | (op << 6) | (rt << 10) | (s1 << 13))
#define JMPFR_ADDR_MODE(ins, ivr, op, ap1, t1, t2) ((ins) | (ivr << 3) | (op << 4) | (ap1 << 7) | (t1 << 10) | (t2 << 13))
#define LSINS_ADDR_MODE(ins, ls, gs, hl, t1, p1, immv) ((ins) | (ls << 3) | (gs << 4) | (hl << 5) | (t1 << 6) | (p1 << 9) | (immv << 12))
#define INMI_ADDR_MODE(ins, op, gs, hl, s1, t1) ((ins) | (op << 3) | (gs << 8) | (hl << 9) | (s1 << 10) | (t1 << 13))

//Special INMI addressing modes
#define INMI_ADDR_MODE_IMM(ins, op, immv) ((ins) | (op << 3) | (immv << 8))
//Data addresing modes (Actual Instruction Execution Arrangament)
//Final encoded instruction (temporal holder)
//unsigned short int INS_COMPLETE; //(16bits)
union ALUF_ENCODING //(ADDRESSING MODE)
{
	struct ALUF_DATA_STRUCT
	{
		unsigned char ins : 3;
		unsigned char op : 4;
		unsigned char target_register : 3;
		unsigned char source_register_0 : 3;
		unsigned char source_register_1 : 3;
	} ALUF_DATA_TYPE;
	long int FULL_DATA_TYPE;
};
union LI_ENCODING //(ADDRESSING MODE)
{
	struct LI_DATA_STRUCT
	{
		unsigned char ins : 3;
		unsigned char hl_bit : 1;
		unsigned char gs_bit : 1;
		unsigned char target_register : 3;
		unsigned char inmmediate_value : 8; 
		
	} LI_DATA_TYPE;
	unsigned short int FULL_DATA_TYPE;
};
union MOVF_ENCODING //(ADDRESSING MODE)
{
	struct MOVF_DATA_STRUCT
	{
		unsigned char ins : 3;
		unsigned char hl_t : 1;
		unsigned char hl_s : 1;
		unsigned char ft_bit : 1;
		unsigned char op : 4;
		unsigned char target_register : 3;
		unsigned char source_register : 3;	
	} MOVF_DATA_TYPE;
	unsigned short int FULL_DATA_TYPE;
};
union JMPI_ENCODING
{
	struct JMPI_DATA_STRUCT
	{
		unsigned char ins : 3;
		unsigned char invert_ops : 1;
		unsigned char op : 3;
		unsigned short int immediate_value : 9;
	} JMPI_DATA_TYPE;
	unsigned short int FULL_DATA_TYPE;
};
union JMPFR_ENCODING
{
	struct JMPFR_DATA_STRUCT
	{
		unsigned char ins : 3;
		unsigned char invert_ops : 1;
		unsigned char op : 3;
		unsigned char target_register : 3;
		unsigned char immediate_value : 6;
	} JMPFR_DATA_TYPE;
	unsigned short int FULL_DATA_TYPE;
};

