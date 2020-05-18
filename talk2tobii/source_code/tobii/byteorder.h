/*  
 *	byteorder.h TCP/IP communication
 *
 *  Copyright (C) Tobii Technology 2004, all rights reserved.
 */

#ifndef BYTEORDER_H_
#define BYTEORDER_H_
 
#if defined(_WIN32)
#include <winsock2.h>
#else
#define __stdcall
#endif

#if defined(__cplusplus)
extern "C" {
#endif

void IpByteOrder(unsigned long (*Fnc)(unsigned long), char *pData, unsigned long len);
void IpByteOrderDouble(void (*Fnc)(double *), char *pData, unsigned long len);
void ntohd(double *pX);
void htond(double *pX);

#if defined(__cplusplus)
}
#endif

#endif /* BYTEORDER_H_ */
