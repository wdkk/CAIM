//
// CAIMMemoryC.h
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

// [include guard]
#ifndef __CAIM_MEMORY_C_H__
#define __CAIM_MEMORY_C_H__

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#if defined(__cplusplus)
extern "C" {
#endif
    // 4096バイトアラインメントメモリ
    typedef void* CAIMMemory4KCPtr;
    
    CAIMMemory4KCPtr CAIMMemory4KCNew();
    void CAIMMemory4KCDelete(CAIMMemory4KCPtr mem);
    
    void* CAIMMemory4KCPointer(CAIMMemory4KCPtr mem);
    long  CAIMMemory4KCCapacity(CAIMMemory4KCPtr mem);
    long  CAIMMemory4KCLength(CAIMMemory4KCPtr mem);
    void  CAIMMemory4KCResize(CAIMMemory4KCPtr mem, long length);
    void  CAIMMemory4KCReserve(CAIMMemory4KCPtr mem, long length);
    void  CAIMMemory4KCAppend(CAIMMemory4KCPtr mem, CAIMMemory4KCPtr src);
    void  CAIMMemory4KCAppendC(CAIMMemory4KCPtr mem, void *bin, long length);
    
    // 16バイトアラインメントメモリ
    typedef void* CAIMMemory16CPtr;
    
    CAIMMemory16CPtr CAIMMemory16CNew();
    void CAIMMemory16CDelete(CAIMMemory16CPtr mem);
    
    void* CAIMMemory16CPointer(CAIMMemory16CPtr mem);
    long  CAIMMemory16CCapacity(CAIMMemory16CPtr mem);
    long  CAIMMemory16CLength(CAIMMemory16CPtr mem);
    void  CAIMMemory16CResize(CAIMMemory16CPtr mem, long length);
    void  CAIMMemory16CReserve(CAIMMemory16CPtr mem, long length);
    void  CAIMMemory16CAppend(CAIMMemory16CPtr mem, CAIMMemory16CPtr src);
    void  CAIMMemory16CAppendC(CAIMMemory16CPtr mem, void *bin, long length);
    
#if defined(__cplusplus)
}
#endif


#endif
