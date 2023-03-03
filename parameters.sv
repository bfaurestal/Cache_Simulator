//this file contains parameters and data structs
package mypkg;
`define WAYS  8
`define HIT   0
`define HITM  1
`define NOHIT 2
`define LINE 16*1024
`define LINE_SIZE 64

parameter WAY   = `WAYS;
parameter HIT   = `HIT;
parameter HITM  = `HITM;
parameter NOHIT = `NOHIT;
parameter LINE = `LINE;
parameter LINE_SIZE = `LINE_SIZE;
parameter CAPACITY = LINE * WAY * LINE_SIZE;
bit [1:0]final_Snoop;
bit[1:0]final_final_snoop;

parameter ADDRESS_BITS = 32;
parameter OFFSET_BITS  = $clog2(LINE_SIZE); //offset bits
parameter INDEX_BITS = $clog2(LINE/WAY); //index bits 
parameter TAG_BITS = ADDRESS_BITS - (INDEX_BITS + OFFSET_BITS);
//using bits
/* parameter integer i_size = 32; //instruction size
parameter integer c_size = 24; // capacity size
parameter integer d_size = 6; // data_line size
parameter integer protocol = 2; // how many bits for protocol (MESI)
parameter integer a_size = 8; //ways
parameter integer tag_bits = i_size - (c_size - d_size - $clog2(a_size)) - d_size;
parameter integer index_bits = c_size - d_size -$clog2(a_size);  */



reg [ADDRESS_BITS - 1 : 0]address;
reg [OFFSET_BITS - 1 : 0]byte_select;
reg [INDEX_BITS - 1 : 0]index;
reg [TAG_BITS - 1: 0]tag;
string translator;

 typedef struct {
	 reg [TAG_BITS : 0] tag[WAY];
	 reg [2 - 1: 0]protocol_bits[WAY];
	 reg [WAY-2 : 0]PLRU; //subtract 2 because - 1 for array to 0 and -1 for the equation for PLRU bits
    
  } cache_data;
/* int read = 0;
int write = 0; */
int cacheMiss=0;
int CacheHIT=0;

int BusOp;
string snoop_text_rslt;
//int address;
//int SnoopResult;

enum{READ=0,WRITE,L1_READ,SNOOP_INVAL,SNOOPED_RD,SNOOP_WR,
		SNOOP_RDWITM,CLR=8,PRINT=9}command; //commands
enum{M=3,E=1,S=2,I=0}MESI_states;

enum{BREAD=1,BWRITE=2,BINVAL=3,BRWIM=4} bus_operations;

enum{GETLINE=1,SENDLINE=2,INVALLINE=3,EVICTLINE=4} L2_L1_messages;

endpackage
