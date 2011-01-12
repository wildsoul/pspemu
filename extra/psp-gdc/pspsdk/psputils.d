/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psputils.h - Prototypes for the sceUtils library.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psputils.h 1884 2006-04-30 08:55:54Z chip $
 */

/* Note: Some of the structures, types, and definitions in this file were
   extrapolated from symbolic debugging information found in the Japanese
   version of Puzzle Bobble. */
module pspsdk.psputils;

import pspsdk.psptypes;
import std.c.time;

extern (C):

/* Some of the structures and definitions in this file were extracted from the japanese 
   puzzle bobble main executable */

/** @defgroup Utils Utils Library */

/** @addtogroup Utils */

/*@{*/

/**
  * Get the time in seconds since the epoc (1st Jan 1970)
  *
  */
time_t sceKernelLibcTime(time_t *t);

/** 
  * Get the processor clock used since the start of the process
  */
clock_t sceKernelLibcClock();

/** 
  * Get the current time of time and time zone information
  */
//int sceKernelLibcGettimeofday(timeval *tp, timezone *tzp);
int sceKernelLibcGettimeofday(void *tp, void *tzp);

/** 
  * Write back the data cache to memory
  */
void sceKernelDcacheWritebackAll();

/**
  * Write back and invalidate the data cache
  */
void sceKernelDcacheWritebackInvalidateAll();

/**
  * Write back a range of addresses from data cache to memory
  */
void sceKernelDcacheWritebackRange(/*const*/ void *p, uint size);

/**
  * Write back and invalidate a range of addresses in data cache
  */
void sceKernelDcacheWritebackInvalidateRange(/*const*/ void *p, uint size);

/**
  * Invalidate a range of addresses in data cache
  */
void sceKernelDcacheInvalidateRange(/*const*/ void *p, uint size);

/** Structure for holding a mersenne twister context */
struct SceKernelUtilsMt19937Context {
	uint 	count;
	uint 	state[624];
}

/** 
  * Function to initialise a mersenne twister context.
  *
  * @param ctx - Pointer to a context
  * @param seed - A seed for the random function.
  *
  * @par Example:
  * @code
  * SceKernelUtilsMt19937Context ctx;
  * sceKernelUtilsMt19937Init(&ctx, time(NULL));
  * u23 rand_val = sceKernelUtilsMt19937UInt(&ctx);
  * @endcode
  *
  * @return < 0 on error.
  */
int sceKernelUtilsMt19937Init(SceKernelUtilsMt19937Context *ctx, u32 seed);

/**
  * Function to return a new psuedo random number.
  *
  * @param ctx - Pointer to a pre-initialised context.
  * @return A pseudo random number (between 0 and MAX_INT).
  */
u32 sceKernelUtilsMt19937UInt(SceKernelUtilsMt19937Context *ctx);

/** Structure to hold the MD5 context */
struct SceKernelUtilsMd5Context {
	uint 	h[4];
	uint 	pad;
	SceUShort16 	usRemains;
	SceUShort16 	usComputed;
	SceULong64 	ullTotalLen;
	ubyte 	buf[64];
}

/**
  * Function to perform an MD5 digest of a data block.
  *
  * @param data - Pointer to a data block to make a digest of.
  * @param size - Size of the data block.
  * @param digest - Pointer to a 16byte buffer to store the resulting digest
  *
  * @return < 0 on error.
  */
int sceKernelUtilsMd5Digest(u8 *data, u32 size, u8 *digest);

/**
  * Function to initialise a MD5 digest context
  *
  * @param ctx - A context block to initialise
  *
  * @return < 0 on error.
  * @par Example:
  * @code
  * SceKernelUtilsMd5Context ctx;
  * u8 digest[16];
  * sceKernelUtilsMd5BlockInit(&ctx);
  * sceKernelUtilsMd5BlockUpdate(&ctx, (u8*) "Hello", 5);
  * sceKernelUtilsMd5BlockResult(&ctx, digest);
  * @endcode
  */
int sceKernelUtilsMd5BlockInit(SceKernelUtilsMd5Context *ctx);

/**
  * Function to update the MD5 digest with a block of data.
  *
  * @param ctx - A filled in context block.
  * @param data - The data block to hash.
  * @param size - The size of the data to hash
  *
  * @return < 0 on error.
  */
int sceKernelUtilsMd5BlockUpdate(SceKernelUtilsMd5Context *ctx, u8 *data, u32 size);

/**
  * Function to get the digest result of the MD5 hash.
  *
  * @param ctx - A filled in context block.
  * @param digest - A 16 byte array to hold the digest.
  *
  * @return < 0 on error.
  */
int sceKernelUtilsMd5BlockResult(SceKernelUtilsMd5Context *ctx, u8 *digest);

/** Type to hold a sha1 context */
struct SceKernelUtilsSha1Context {
	uint 	h[5];
	SceUShort16 	usRemains;
	SceUShort16 	usComputed;
	SceULong64 	ullTotalLen;
	ubyte 	buf[64];
}

/**
  * Function to SHA1 hash a data block.
  * 
  * @param data - The data to hash.
  * @param size - The size of the data.
  * @param digest - Pointer to a 20 byte array for storing the digest
  *
  * @return < 0 on error.
  */
int sceKernelUtilsSha1Digest(u8 *data, u32 size, u8 *digest);

/**
  * Function to initialise a context for SHA1 hashing.
  *
  * @param ctx - Pointer to a context.
  *
  * @return < 0 on error.
  *
  * @par Example:
  * @code
  * SceKernelUtilsSha1Context ctx;
  * u8 digest[20];
  * sceKernelUtilsSha1BlockInit(&ctx);
  * sceKernelUtilsSha1BlockUpdate(&ctx, (u8*) "Hello", 5);
  * sceKernelUtilsSha1BlockResult(&ctx, digest);
  * @endcode
  */
int sceKernelUtilsSha1BlockInit(SceKernelUtilsSha1Context *ctx);

/**
  * Function to update the current hash.
  *
  * @param ctx - Pointer to a prefilled context.
  * @param data - The data block to hash.
  * @param size - The size of the data block
  *
  * @return < 0 on error.
  */
int sceKernelUtilsSha1BlockUpdate(SceKernelUtilsSha1Context *ctx, u8 *data, u32 size);

/**
  * Function to get the result of the SHA1 hash.
  * 
  * @param ctx - Pointer to a prefilled context.
  * @param digest - A pointer to a 20 byte array to contain the digest.
  *
  * @return < 0 on error.
  */
int sceKernelUtilsSha1BlockResult(SceKernelUtilsSha1Context *ctx, u8 *digest);

/*@}*/

