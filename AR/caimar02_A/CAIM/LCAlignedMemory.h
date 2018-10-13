//
// LCAlignedMemory.h
// Lily Library
//
// Copyright (c) 2017- Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//

// [include guard]
#ifndef __LILY_GRAPHICS_ALIGNED_MEMORY_C_H__
#define __LILY_GRAPHICS_ALIGNED_MEMORY_C_H__

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
extern "C" {
#endif
    // 4096バイトアラインメントメモリ
    typedef void* LCAlignedMemory4KPtr;
    
    LCAlignedMemory4KPtr LCAlignedMemory4KNew();
    void LCAlignedMemory4KDelete(LCAlignedMemory4KPtr mem);
    
    void* LCAlignedMemory4KPointer(LCAlignedMemory4KPtr mem);
    long  LCAlignedMemory4KCapacity(LCAlignedMemory4KPtr mem);
    long  LCAlignedMemory4KLength(LCAlignedMemory4KPtr mem);
    void  LCAlignedMemory4KResize(LCAlignedMemory4KPtr mem, long length);
    void  LCAlignedMemory4KReserve(LCAlignedMemory4KPtr mem, long length);
    void  LCAlignedMemory4KAppend(LCAlignedMemory4KPtr mem, LCAlignedMemory4KPtr src);
    void  LCAlignedMemory4KAppendC(LCAlignedMemory4KPtr mem, void *bin, long length);
    
    // 16バイトアラインメントメモリ
    typedef void* LCAlignedMemory16Ptr;
    
    LCAlignedMemory16Ptr LCAlignedMemory16New();
    void LCAlignedMemory16Delete(LCAlignedMemory16Ptr mem);
    
    void* LCAlignedMemory16Pointer(LCAlignedMemory16Ptr mem);
    long  LCAlignedMemory16Capacity(LCAlignedMemory16Ptr mem);
    long  LCAlignedMemory16Length(LCAlignedMemory16Ptr mem);
    void  LCAlignedMemory16Resize(LCAlignedMemory16Ptr mem, long length);
    void  LCAlignedMemory16Reserve(LCAlignedMemory16Ptr mem, long length);
    void  LCAlignedMemory16Append(LCAlignedMemory16Ptr mem, LCAlignedMemory16Ptr src);
    void  LCAlignedMemory16AppendC(LCAlignedMemory16Ptr mem, void *bin, long length);
    
#if defined(__cplusplus)
}
#endif


#endif
