
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define MAX_PIECE	0xff

// from shellcode
extern uint64_t XP_LIST_LENGTH;
extern char* XP_LIST[];

// just some random keys
char xor_keys[] = {0x48, 0x82, 0x10, 0x0a, 0x33, 0x45, 0x72, 0xcc, 0xcc, 0x21, 0x42};

// layout:
//	byte length (xord w last key)
//	byte key (xord w last key)
//	byte[length] data (xord with key)


int main(int argc, char* argv[]) {
	size_t blen;
	char* fmtbuf;
	char* bcurs;
	uint8_t last_key;
	uint8_t piece_key;
	uint8_t piece_len;
	int i, j;

	last_key = 0x42; // initial key

	blen = (size_t)(XP_LIST[XP_LIST_LENGTH-1] - XP_LIST[0]);
	
	fmtbuf = malloc(blen * 2);
	bcurs = fmtbuf;
	
	for (i=0; i<XP_LIST_LENGTH-1; i++) {
		if ((XP_LIST[i+1] - XP_LIST[i]) >= MAX_PIECE) {
			printf("ERROR: Piece too big\n");
			return -1;
		}
		piece_len = (uint8_t)(XP_LIST[i+1] - XP_LIST[i]);
		piece_key = xor_keys[i % sizeof(xor_keys)];
		
		bcurs[0] = piece_len ^ last_key;
		bcurs[1] = piece_key ^ last_key;
		bcurs += 2;

		for (j=0; j<piece_len; j++) {
			bcurs[j] = XP_LIST[i][j] ^ piece_key;
		}
		bcurs += piece_len;
		if (bcurs >= (fmtbuf + (blen * 2))) {
			printf("ERROR: Overflow\n");
			return -1;
		}

		last_key = piece_key;
	}

	write(1, fmtbuf, (bcurs - fmtbuf));

	return 0;
}
