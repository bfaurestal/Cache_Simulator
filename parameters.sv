//this file contains parameters and data structs
package mypkg;
`define WAYS  8
`define LINE 16*1024 //16k sets
`define LINE_SIZE 64
`define MESI_BITS 2

parameter WAY   = `WAYS; // I_Cache
parameter I_WAY   = `WAYS/2; //D_Cache set assiocivity
parameter LINE = `LINE;
parameter LINE_SIZE = `LINE_SIZE;
parameter CAPACITY = LINE * WAY * LINE_SIZE;
parameter MESI_BITS = `MESI_BITS;
parameter ADDRESS_BITS = 32;
parameter OFFSET_BITS  = $clog2(LINE_SIZE); //offset bits
parameter INDEX_BITS = $clog2(LINE); //index bits 
parameter I_INDEX_BITS = $clog2(LINE); // D_Cache index bits 
parameter TAG_BITS = ADDRESS_BITS - (INDEX_BITS + OFFSET_BITS);
parameter I_TAG_BITS = ADDRESS_BITS - (I_INDEX_BITS + OFFSET_BITS); //D_Cache tag

int tag_hit = 0;
int tag_miss =0;
int FALSE=0;
int TRUE=1;
int empty_way=0;
int way_filled=0;
int return_way=0; 
int d_globalLRU=0;
int flag;
int curr_used;
int way;
int miss_flag;

/* -------------------->File Handler settings<-------------------- */
integer silent = 0;
integer normal = 0;

/* -------------------->Data cache settings<-------------------- */
reg [ADDRESS_BITS - 1 : 0]address;
reg [OFFSET_BITS - 1 : 0]byte_select;
reg [INDEX_BITS - 1 : 0]index;
reg [TAG_BITS - 1: 0]tag;
integer debug = 0;

/* -------------------->Instruction cache settings<-------------------- */
reg [OFFSET_BITS - 1 : 0]i_byte_select;
reg [I_INDEX_BITS - 1 : 0]i_index;
reg [I_TAG_BITS - 1: 0]i_tag;

//Instruction cache structure 
typedef struct {
 bit [TAG_BITS : 0] tag[LINE][WAY];
 reg [2 - 1: 0]protocol_bits[WAY];
 reg [WAY-2 : 0]PLRU; //subtract 2 because - 1 for array to 0 and -1 for the equation for PLRU bits
} D_Cache;

//Data cache structure
typedef struct {
 //reg [I_TAG_BITS : 0] tag[I_WAY];
 logic [14:0] iCache[16][2];
 reg [2 - 1: 0]protocol_bits[I_WAY];
 reg [I_WAY - 2 : 0]PLRU; //subtract 2 because - 1 for array to 0 and -1 for the equation for PLRU bits
} I_Cache;

bit [14:0] iCache[LINE][I_WAY];
bit [14:0] dCache[LINE][WAY];
bit [1:0]  LRU_tracker_4[][I_WAY - 1:0];
bit [2:0]  LRU_tracker_8[][WAY - 1:0];
bit [2:0]  MESI_tracker[LINE][WAY];

int read = 0;
int write = 0;
int cacheMiss=0;
int CacheHIT=0;
real hit_ratio= 0;
int BusOp;
string snoop_text_rslt;
//int address;
//int SnoopResult;
enum{READ=0,WRITE,I_FETCH,L2_INVAL,L2_DATA_RQ,CLR=8,PRINT=9}command; //commands
enum{M=3,E=1,S=2,I=0}MESI_states;
endpackage
