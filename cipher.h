
#include <stdint.h>


#ifndef CIPHER_H_
#define HW2_WET_STUDENTS_CODE_H

void keyMixing(uint8_t input[4][4], uint8_t key[4][4]);
void byteSubstitution(uint8_t input[4][4]);
void shiftRows(uint8_t input[4][4]);
void cipher(uint8_t input[][4][4], uint8_t key[4][4], uint8_t len);

#endif /* CIPHER_H_ */
