/*
 * fat12.c - NXT FAT12 initialisation and access functions
 *
 * Copyright (C) 2010  Carl G. Ritson
 *
 * Redistribution of this file is permitted under
 * the terms of the GNU Public License (GPL) version 2.
 */

#include "tvm-nxt.h"

static uint8_t data_0_to_26[] = {
	0xeb, 0x3c, 0x90, 0x6d, 0x6b, 0x64, 0x6f, 0x73, 0x66,
	0x73, 0x00, 0x00, 0x02, 0x04, 0x01, 0x00, 0x02, 0x10,
	0x00, 0x50, 0x00, 0xf8, 0x01, 0x00, 0x20, 0x00, 0x40
};
static uint8_t data_38_to_190[] = {
	0x29, 0x4a, 0xb5, 0x2d, 0x2e, 0x4e, 0x58, 0x54, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x46, 0x41,
	0x54, 0x31, 0x32, 0x20, 0x20, 0x20, 0x0e, 0x1f, 0xbe,
	0x5b, 0x7c, 0xac, 0x22, 0xc0, 0x74, 0x0b, 0x56, 0xb4,
	0x0e, 0xbb, 0x07, 0x00, 0xcd, 0x10, 0x5e, 0xeb, 0xf0,
	0x32, 0xe4, 0xcd, 0x16, 0xcd, 0x19, 0xeb, 0xfe, 0x54,
	0x68, 0x69, 0x73, 0x20, 0x69, 0x73, 0x20, 0x6e, 0x6f,
	0x74, 0x20, 0x61, 0x20, 0x62, 0x6f, 0x6f, 0x74, 0x61,
	0x62, 0x6c, 0x65, 0x20, 0x64, 0x69, 0x73, 0x6b, 0x2e,
	0x20, 0x20, 0x50, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x20,
	0x69, 0x6e, 0x73, 0x65, 0x72, 0x74, 0x20, 0x61, 0x20,
	0x62, 0x6f, 0x6f, 0x74, 0x61, 0x62, 0x6c, 0x65, 0x20,
	0x66, 0x6c, 0x6f, 0x70, 0x70, 0x79, 0x20, 0x61, 0x6e,
	0x64, 0x0d, 0x0a, 0x70, 0x72, 0x65, 0x73, 0x73, 0x20,
	0x61, 0x6e, 0x79, 0x20, 0x6b, 0x65, 0x79, 0x20, 0x74,
	0x6f, 0x20, 0x74, 0x72, 0x79, 0x20, 0x61, 0x67, 0x61,
	0x69, 0x6e, 0x20, 0x2e, 0x2e, 0x2e, 0x20, 0x0d, 0x0a
};
static uint8_t data_510_to_514[] = {
	0x55, 0xaa, 0xf8, 0xff, 0xff
};
static uint8_t data_1024_to_1026[] = {
	0xf8, 0xff, 0xff
};
static uint8_t data_1536_to_1561[] = {
	0x4e, 0x58, 0x54, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
	0x20, 0x20, 0x08, 0x00, 0x00, 0xbb, 0x66, 0x68, 0x3d,
	0x68, 0x3d, 0x00, 0x00, 0xbb, 0x66, 0x68, 0x3d
};

void fat12_init (uint8_t *data, uint32_t len)
{
	memset (data, 0, len);
	/* FIXME: this is a fixed 40k FAT12 file system with 16 root dir entries */
	memcpy (data +    0,      data_0_to_26, sizeof (data_0_to_26)); 
	memcpy (data +   38,    data_38_to_190, sizeof (data_38_to_190)); 
	memcpy (data +  510,   data_510_to_514, sizeof (data_510_to_514)); 
	memcpy (data + 1024, data_1024_to_1026, sizeof (data_1024_to_1026)); 
	memcpy (data + 1536, data_1536_to_1561, sizeof (data_1536_to_1561)); 
}
