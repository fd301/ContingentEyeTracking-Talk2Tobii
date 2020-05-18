typedef unsigned int WORD;
typedef unsigned long DWORD;
typedef long LONG;
typedef long long LONGLONG;
typedef unsigned long long ULONGLONG;

typedef union _LARGE_INTEGER {
  struct {
    DWORD LowPart;
    LONG HighPart;
  };
  LONGLONG QuadPart;
} LARGE_INTEGER, *PLARGE_INTEGER;

typedef union _ULARGE_INTEGER {
  struct {
    DWORD LowPart;
    DWORD HighPart;
  };
  struct {
    DWORD LowPart;
    DWORD HighPart;
  } u;
  ULONGLONG QuadPart;
} ULARGE_INTEGER, *PULARGE_INTEGER;

typedef long long __int64;

typedef struct _FILETIME {
  DWORD dwLowDateTime;
  DWORD dwHighDateTime;
} FILETIME, *PFILETIME;

typedef struct _SYSTEMTIME {
  WORD wYear;
  WORD wMonth;
  WORD wDayOfWeek;
  WORD wDay;
  WORD wHour;
  WORD wMinute;
  WORD wSecond;
  WORD wMilliseconds;
} SYSTEMTIME, *PSYSTEMTIME;

void GetLocalTime(SYSTEMTIME *localsystemtime);

void GetLocalTime(SYSTEMTIME *localsystemtime)
{
	time_t		t;
	struct tm	*ltp;

	struct timeval	tv;

/* do this ...  (seems to work better than gettimeofday) */
  t = time(NULL);	/* time since the Epoch in seconds */
/* or this, if you want microseconds */
/*
  gettimeofday(&tv,NULL); 
  t = tv.tv_sec + tv.tv_usec / 1000000;
*/

/*ltp = localtime(&t);*//* time relative to time zone */
  ltp = gmtime(&t);   	/* time expressed in Coordinated Universal Time (UTC) */

  localsystemtime->wYear = (WORD)ltp->tm_year;
  localsystemtime->wMonth = (WORD)ltp->tm_mon;
  localsystemtime->wDayOfWeek = (WORD)ltp->tm_wday;
  localsystemtime->wDay = (WORD)ltp->tm_yday;
/* should we account for daylight savings time? (ltp->tm_isdst is 1 if DST) */
  localsystemtime->wHour = (WORD)ltp->tm_hour;
  localsystemtime->wMinute = (WORD)ltp->tm_min;
  localsystemtime->wSecond = (WORD)ltp->tm_sec;
  localsystemtime->wMilliseconds = tv.tv_usec / 1000;
}
