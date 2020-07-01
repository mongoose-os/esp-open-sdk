#pragma once

#include <stdint.h>

#define LWIP_NO_STDINT_H 1
typedef uint8_t u8_t;
typedef int8_t s8_t;
typedef uint16_t u16_t;
typedef int16_t s16_t;
typedef uint32_t u32_t;
typedef int32_t s32_t;
typedef uintptr_t mem_ptr_t;
#define LWIP_ERR_T s32_t
