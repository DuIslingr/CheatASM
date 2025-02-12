﻿grammar CheatASM;

program: gameInfo? titleID? buildID? variableDecl* cheatEntry+
       | variableDecl* statement+;

statement: opCode1
         | opCode2
         | opCode3
         | opCode4
         | opCode5
         | opCode7
         | opCode8
         | opCode9
         | movInstr
		 | opCodeC0
		 | opCodeC1
		 | opCodeC2;

cheatEntry: (header=cheatHeader) statement+;

titleID: DOT 'title'  (title=ID);
buildID: DOT 'build'  (build=ID);
gameInfo: DOT 'gameinfo' (info=CHEAT_NAME);

cheatHeader: DOT 'cheat'  (master=MASTER)? (name=CHEAT_NAME);

/* cond.d [HEAP + num], num */
opCode1: (cond=CONDITIONAL) DOT (bitWidth=BIT_WIDTH) LSQUARE(memType=MEM_TYPE)PLUS_SIGN(offset=numRef)RSQUARE COMMA (value=numRef);
opCode2: END_COND;
opCode3: LOOP (register=regRef) COMMA(value=numRef)
       | (endloop=END_LOOP) (register=regRef);
/* mov.d reg, num */
opCode4: MOVE (DOT BIT_WIDTH)? (register=regRef) COMMA (value=numRef);

/* mov.d reg, [HEAP + num] */
/* mov.d reg, [reg + num] */
opCode5: MOVE DOT (bitWidth=BIT_WIDTH) (register=regRef) COMMA LSQUARE (memType=MEM_TYPE) PLUS_SIGN (offset=numRef) RSQUARE
       |  MOVE DOT (bitWidth=BIT_WIDTH) (register=regRef) COMMA LSQUARE (baseRegister=regRef) PLUS_SIGN (offset=numRef) RSQUARE;

/* mov.d [reg], number */
/* mov.d [reg + reg], number */
//opCode6: MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (register=regRef)(PLUS_SIGN(offsetReg=regRef))? RSQUARE COMMA (value=numRef) (increment=INCREMENT)?;

opCode7: (func=LEGACY_ARITHMETIC) DOT (bitWidth=BIT_WIDTH) (register=regRef) COMMA (value=numRef);
opCode8: KEYCHECK (key=KEY);

opCode9: (func=ARITHMETIC) DOT (bitWidth=BIT_WIDTH) (dest=regRef) COMMA (leftReg=regRef) COMMA (right=anyRef);

/* rule for Opcode 0/6/A */
movInstr: MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (memType=MEM_TYPE|base=regRef) (PLUS_SIGN (offset=anyRef))? RSQUARE COMMA (source=anyRef) (increment=INCREMENT)?
        | MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (memType=MEM_TYPE|base=regRef) (PLUS_SIGN (offset=anyRef) PLUS_SIGN (immediate=anyRef))? RSQUARE COMMA (source=anyRef) (increment=INCREMENT)?;

/* can be
mov.d [reg], reg
mov.d [reg + reg], reg
mov.d [reg + num], reg
mov.d [HEAP + reg], reg
mov.d [HEAP + num], reg
mov.d [HEAP + reg + num], reg

*/
/*opCodeA:           MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (baseReg=regRef) RSQUARE COMMA (sourceReg=regRef) (increment=INCREMENT)?
       | MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (baseReg=regRef) PLUS_SIGN (offset=anyRef) RSQUARE COMMA (sourceReg=regRef) (increment=INCREMENT)?
	   | MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (memType=MEM_TYPE) PLUS_SIGN (offset=anyRef) RSQUARE COMMA (sourceReg=regRef) (increment=INCREMENT)?
	   | MOVE DOT (bitWidth=BIT_WIDTH) LSQUARE (memType=MEM_TYPE) PLUS_SIGN (baseReg=regRef) PLUS_SIGN (value=numRef) RSQUARE COMMA (sourceReg=regRef) (increment=INCREMENT)?;*/


opCodeC0: (cond=CONDITIONAL) DOT (bitWidth=BIT_WIDTH) (source=regRef) COMMA LSQUARE (memType=MEM_TYPE) PLUS_SIGN (offset=anyRef) RSQUARE

		| (cond=CONDITIONAL) DOT (bitWidth=BIT_WIDTH) (source=regRef) COMMA LSQUARE (addrReg=regRef) PLUS_SIGN (offset=anyRef) RSQUARE

		| (cond=CONDITIONAL) DOT (bitWidth=BIT_WIDTH) (source=regRef) COMMA (value=anyRef);

opCodeC1: (func=SAVEREG) (reg=regRef) COMMA (index=numRef)
        | (func=LOADREG) (index=numRef) COMMA (reg=regRef);


opCodeC2: (func=SAVE|func=LOAD) regRef (COMMA regRef)+
        | (func=SAVEALL|func=LOADALL);

numberLiteral : IntegerLiteral | DecimalLiteral | HEX_NUMBER;
regRef: (reg=REGISTER) | (var=VARIABLE_NAME);

numRef: (num=HEX_NUMBER) | (var=VARIABLE_NAME);

anyRef: (reg=REGISTER) | (num=HEX_NUMBER) | (var=VARIABLE_NAME);

variableDecl:  (name=VARIABLE_NAME) COLON (type=VARIABLE_TYPE) (const=CONST)? (val=numberLiteral);

// Lexer Rules
MOVE: M O V;
CONDITIONAL: GT | GE | LT | LE | EQ | NE;
LOOP: L O O P;
END_LOOP: E N D L O O P;
KEYCHECK: K E Y C H E C K;
END_COND: E N D C O N D;
INCREMENT: I N C;
SAVE: S A V E ;
SAVEREG: S A V E R E G;
SAVEALL: S A V E A L L;
LOAD: L O A D;
LOADREG: L O A D R E G;
LOADALL: L O A D A L L;
LSQUARE: '[';
RSQUARE: ']';
LCURL: '{';
RCURL: '}';
PLUS_SIGN: '+';
COMMA: ',';
// memory types

MEM_TYPE: MEMORY_HEAP | MEMORY_MAIN;
MEMORY_MAIN: M A I N;
MEMORY_HEAP: H E A P;

BIT_WIDTH: BIT_BYTE | BIT_WORD | BIT_DOUBLE | BIT_QUAD;
BIT_BYTE: B;
BIT_WORD: W;
BIT_DOUBLE: D;
BIT_QUAD: Q;


// comparisons
GT: G T;
GE: G E;
LT: L T;
LE: L E;
EQ: E Q;
NE: N E;

// arithmetic
LEGACY_ARITHMETIC: ADD | SUB | MUL | LSH | RSH ;
ARITHMETIC: AND | OR | NOT | XOR | NONE;

ADD: A D D;
SUB: S U B;
MUL: M U L;
LSH: L S H;
RSH: R S H;
AND: A N D;
OR: O R;
NOT: N O T;
XOR: X O R;
NONE: N O N E;

// keys
KEY: A_KEY | B_KEY | X_KEY | Y_KEY | LSP_KEY | RSP_KEY | L_KEY
   | R_KEY | ZL_KEY | ZR_KEY | PLUS_KEY | MINUS_KEY | LEFT_KEY
   | UP_KEY | RIGHT_KEY | DOWN_KEY | LSL_KEY | LSU_KEY | LSR_KEY
   | LSD_KEY | RSL_KEY | RSU_KEY | RSR_KEY | RSD_KEY | SL_KEY | SR_KEY;
A_KEY: A;
B_KEY: B;
X_KEY: X;
Y_KEY: Y;
LSP_KEY: L S P;
RSP_KEY: R S P;
L_KEY: L;
R_KEY: R;
ZL_KEY: Z L;
ZR_KEY: Z R;
PLUS_KEY: P L U S;
MINUS_KEY: M I N U S;
LEFT_KEY: L E F T;
UP_KEY: U P;
RIGHT_KEY: R I G H T;
DOWN_KEY: D O W N;
LSL_KEY: L S L;
LSU_KEY: L S U;
LSR_KEY: L S R;
LSD_KEY: L S D;
RSL_KEY: R S L;
RSU_KEY: R S U;
RSR_KEY: R S R;
RSD_KEY: R S D;
SL_KEY: S L;
SR_KEY: S R;

CONST: C O N S T;

MASTER: M A S T E R;

REGISTER: [Rr][0-9a-fA-F];
HEX_NUMBER: '0' X [0-9a-fA-F]+;
WS: [ \t\r\n]+ -> skip;
COMMENT: '#'.* -> skip;
DOT: '.';
COLON: ':';
VARIABLE_NAME: [A-Za-z][A-Za-z0-9]*;
DecimalLiteral  : IntegerLiteral '.' [0-9]+ ;
IntegerLiteral  : '0' | '1'..'9' '0'..'9'* ;

VARIABLE_TYPE: DOT ((U | S) ('8' | '16' | '32' | '64') | F ('32' | '64'));

ID:  '{'[0-9A-Fa-f]+ '}' ;

CHEAT_NAME: '"' [0-9A-Za-z \\.()_]+ '"';

fragment A : [aA]; // match either an 'a' or 'A'
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];