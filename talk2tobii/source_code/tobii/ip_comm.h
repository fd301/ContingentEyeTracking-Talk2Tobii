/*  
 *	ip_comm.h :  TCP/IP communication
 *
 *  Copyright (C) Tobii Technology 2002-2003, all rights reserved.
 */

#ifndef IP_COMM_H_
#define IP_COMM_H_

#include "toberror.h"
#include "tet.h" /* callback functions */

#if defined(__cplusplus)
extern "C" {
#endif

typedef struct _SCallback {
	Tet_CallbackFunction Fnc;
	void *pApplicationData;
	unsigned long interval;
	unsigned long *pState;
} SCallback;

 
long IpInit(void **ppMem, char *pIPaddress, unsigned short portnumber);
long IpClose(void **ppMem);
long IpSend(void *pMem, char *pData, unsigned long len);
long IpIsConnectedToLocalHost(void *pMem);
long IpRecv(void *pMem, unsigned long timeout, char *pBuf, unsigned long expected_len);
long IpRecvTmr(void *pMem, unsigned long timeout, char *pBuf, unsigned long expected_len, SCallback *pCb);


#if defined(__cplusplus)
}
#endif


#endif /* IP_COMM_H_ */
