//
//  CAIMMemory.cpp
//  ios_caimmetal01
//
//  Created by kengo on 2017/03/08.
//  Copyright © 2017年 TUT Creative Application. All rights reserved.
//

#include "CAIMMemoryC.h"
#include <cstdlib>
#include <iostream>
#include <type_traits>
#include <vector>

/*!
 * @brief アラインメントされたメモリを動的確保する関数
 * @param [in] size       確保するメモリサイズ (単位はbyte)
 * @param [in] alignment  アラインメント (2のべき乗を指定すること)
 * @return  アラインメントし，動的確保されたメモリ領域へのポインタ
 */
template<typename T = void*, typename std::enable_if<std::is_pointer<T>::value, std::nullptr_t>::type = nullptr>
static inline T alignedMalloc(std::size_t size, std::size_t alignment) noexcept
{
#if defined(_MSC_VER) || defined(__MINGW32__)
    return reinterpret_cast<T>(_aligned_malloc(size, alignment));
#else
    void* p;
    return reinterpret_cast<T>(posix_memalign(&p, alignment, size) == 0 ? p : nullptr);
#endif 
}

/*!
 * @brief アラインメントされたメモリを解放する関数
 * @param [in] ptr  解放対象のメモリの先頭番地を指すポインタ
 */
static inline void alignedFree(void* ptr) noexcept
{
#if defined(_MSC_VER) || defined(__MINGW32__)
    _aligned_free(ptr);
#else
    std::free(ptr);
#endif
}

// アラインメントされたメモリを確保するSTLのカスタムアロケータ
template<typename T, std::size_t N>
class AligndSTLAllocator : public std::allocator<T>
{
    public:
    using size_type = typename std::allocator<T>::size_type;
    using pointer = typename std::allocator<T>::pointer;
    using const_pointer = typename std::allocator<T>::const_pointer;
    
    /*!
     * @brief STLのメモリ領域を動的確保する
     *
     * @param [in] n              確保する要素数
     * @param [in] const_pointer  使用しない引数
     * @return  アラインされたメモリ領域へのポインタ
     */
    pointer allocate(size_type n, const_pointer = nullptr) const {
        if (n > this->max_size()) { throw std::bad_alloc(); }
        return alignedMalloc<pointer>(n * sizeof(T), N);
    }
    
    /*!
     * @brief STLのメモリ領域を解放する
     * @param [in,out] p  動的確保したメモリ領域
     * @param [in]     n  要素数 (使用しない引数)
     */
    void deallocate(pointer p, size_type) const noexcept {
        alignedFree(p);
    }
};

///////////////////////////////////////////////

static const int ALIGNMENT4096 = 4096;

typedef std::vector<char, AligndSTLAllocator<char, ALIGNMENT4096>> CAIMMemoryC;

static CAIMMemoryC* _M(CAIMMemoryCPtr mem_) { return (CAIMMemoryC*)mem_; }

CAIMMemoryCPtr CAIMMemoryCNew() {
    CAIMMemoryC* mem = (CAIMMemoryC*)(new CAIMMemoryC());
    mem->reserve(ALIGNMENT4096);
    return mem;
}

void CAIMMemoryCDelete(CAIMMemoryCPtr mem_) {
    delete _M(mem_);
}

void* CAIMMemoryCPointer(CAIMMemoryCPtr mem_) {
    return _M(mem_)->data();
}

long CAIMMemoryCCapacity(CAIMMemoryCPtr mem_) {
    return (long)_M(mem_)->capacity();
}

long CAIMMemoryCLength(CAIMMemoryCPtr mem_) {
    return (long)_M(mem_)->size();
}

void CAIMMemoryCResize(CAIMMemoryCPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    CAIMMemoryC *mem = _M(mem_);
    if(length == mem->size()) { return; }
    mem->resize(length);
}

void CAIMMemoryCReserve(CAIMMemoryCPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    _M(mem_)->reserve(length);
}

void CAIMMemoryCAppend(CAIMMemoryCPtr mem_, CAIMMemoryCPtr src_) {
    CAIMMemoryC* d = _M(mem_);
    CAIMMemoryC* s = _M(src_);
    std::copy(s->begin(), s->end(), std::back_inserter(*d));
}

void CAIMMemoryCAppendC(CAIMMemoryCPtr mem_, void* bin_, long length_) {
    CAIMMemoryC* m = _M(mem_);
    long sz = m->size();
    m->resize((size_t)(sz + length_));
    char* p = (char*)CAIMMemoryCPointer(mem_);
    
    memcpy(&p[sz], bin_, (size_t)length_);
}
