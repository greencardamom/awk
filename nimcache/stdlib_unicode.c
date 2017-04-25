/* Generated by Nim Compiler v0.13.1 */
/*   (c) 2015 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Linux, amd64, gcc */
/* Command for C compiler:
   gcc -c  -w  -I/home/adminuser/Nim/lib -o /home/adminuser/awknim/nimcache/stdlib_unicode.o /home/adminuser/awknim/nimcache/stdlib_unicode.c */
#define NIM_INTBITS 64

#include "nimbase.h"
typedef struct TY131842 TY131842;
typedef struct TGenericSeq TGenericSeq;
typedef struct TNimType TNimType;
typedef struct TNimNode TNimNode;
typedef struct NimStringDesc NimStringDesc;
struct  TGenericSeq  {
NI len;
NI reserved;
};
typedef N_NIMCALL_PTR(void, TY3289) (void* p, NI op);
typedef N_NIMCALL_PTR(void*, TY3294) (void* p);
struct  TNimType  {
NI size;
NU8 kind;
NU8 flags;
TNimType* base;
TNimNode* node;
void* finalizer;
TY3289 marker;
TY3294 deepcopy;
};
struct  NimStringDesc  {
  TGenericSeq Sup;
NIM_CHAR data[SEQ_DECL_SIZE];
};
struct  TNimNode  {
NU8 kind;
NI offset;
TNimType* typ;
NCSTRING name;
NI len;
TNimNode** sons;
};
struct TY131842 {
  TGenericSeq Sup;
  NI data[SEQ_DECL_SIZE];
};
N_NIMCALL(TY131842*, newseq_131837)(NI len);
N_NOINLINE(void, raiseIndexError)(void);
static N_INLINE(void, nimFrame)(TFrame* s);
N_NOINLINE(void, stackoverflow_22201)(void);
static N_INLINE(void, popFrame)(void);
TNimType NTI126203; /* RuneImpl */
extern TFrame* frameptr_19436;

static N_INLINE(void, nimFrame)(TFrame* s) {
	NI LOC1;
	LOC1 = 0;
	{
		if (!(frameptr_19436 == NIM_NIL)) goto LA4;
		LOC1 = ((NI) 0);
	}
	goto LA2;
	LA4: ;
	{
		LOC1 = ((NI) ((NI16)((*frameptr_19436).calldepth + ((NI16) 1))));
	}
	LA2: ;
	(*s).calldepth = ((NI16) (LOC1));
	(*s).prev = frameptr_19436;
	frameptr_19436 = s;
	{
		if (!((*s).calldepth == ((NI16) 2000))) goto LA9;
		stackoverflow_22201();
	}
	LA9: ;
}

static N_INLINE(void, popFrame)(void) {
	frameptr_19436 = (*frameptr_19436).prev;
}

N_NIMCALL(NI, runelenat_126392)(NimStringDesc* s, NI i) {
	NI result;
	nimfr("runeLenAt", "unicode.nim")
	result = 0;
	nimln(44, "unicode.nim");
	{
		if ((NU)(i) > (NU)(s->Sup.len)) raiseIndexError();
		if (!((NU64)(((NI) (((NU8)(s->data[i]))))) <= (NU64)(((NI) 127)))) goto LA3;
		result = ((NI) 1);
	}
	goto LA1;
	LA3: ;
	{
		nimln(45, "unicode.nim");
		if ((NU)(i) > (NU)(s->Sup.len)) raiseIndexError();
		if (!((NI)((NU64)(((NI) (((NU8)(s->data[i]))))) >> (NU64)(((NI) 5))) == ((NI) 6))) goto LA6;
		result = ((NI) 2);
	}
	goto LA1;
	LA6: ;
	{
		nimln(46, "unicode.nim");
		if ((NU)(i) > (NU)(s->Sup.len)) raiseIndexError();
		if (!((NI)((NU64)(((NI) (((NU8)(s->data[i]))))) >> (NU64)(((NI) 4))) == ((NI) 14))) goto LA9;
		result = ((NI) 3);
	}
	goto LA1;
	LA9: ;
	{
		nimln(47, "unicode.nim");
		if ((NU)(i) > (NU)(s->Sup.len)) raiseIndexError();
		if (!((NI)((NU64)(((NI) (((NU8)(s->data[i]))))) >> (NU64)(((NI) 3))) == ((NI) 30))) goto LA12;
		result = ((NI) 4);
	}
	goto LA1;
	LA12: ;
	{
		nimln(48, "unicode.nim");
		if ((NU)(i) > (NU)(s->Sup.len)) raiseIndexError();
		if (!((NI)((NU64)(((NI) (((NU8)(s->data[i]))))) >> (NU64)(((NI) 2))) == ((NI) 62))) goto LA15;
		result = ((NI) 5);
	}
	goto LA1;
	LA15: ;
	{
		nimln(49, "unicode.nim");
		if ((NU)(i) > (NU)(s->Sup.len)) raiseIndexError();
		if (!((NI)((NU64)(((NI) (((NU8)(s->data[i]))))) >> (NU64)(((NI) 1))) == ((NI) 126))) goto LA18;
		result = ((NI) 6);
	}
	goto LA1;
	LA18: ;
	{
		nimln(50, "unicode.nim");
		result = ((NI) 1);
	}
	LA1: ;
	popFrame();
	return result;
}
NIM_EXTERNC N_NOINLINE(void, stdlib_unicodeInit000)(void) {
	nimfr("unicode", "unicode.nim")
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, stdlib_unicodeDatInit000)(void) {
NTI126203.size = sizeof(NI);
NTI126203.kind = 31;
NTI126203.base = 0;
NTI126203.flags = 3;
}
