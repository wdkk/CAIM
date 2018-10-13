//
// LCAlignedMemory.cxx
// Lily Library
//
// Copyright (c) 2017- Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//

#include "LCAlignedMemory.h"
#include <cstdlib>
#include <iostream>
#include <type_traits>
#include <vector>

template<typename T = void*, typename std::enable_if<std::is_pointer<T>::value, std::nullptr_t>::type = nullptr>
static inline T alignedMalloc(std::size_t size, std::size_t alignment) noexcept {
    void* p;
    return reinterpret_cast<T>(posix_memalign(&p, alignment, size) == 0 ? p : nullptr);
}

static inline void alignedFree(void* ptr) noexcept { std::free(ptr); }

template<typename T, std::size_t N>
class AlignedAllocator : public std::allocator<T>
{
public:
    
    using ConstPtr = typename std::allocator<T>::const_pointer;
    using Ptr = typename std::allocator<T>::pointer;
    using SizeType = typename std::allocator<T>::size_type;
    
    Ptr allocate(SizeType n, ConstPtr = nullptr) const {
        if (n > this->max_size()) { throw std::bad_alloc(); }
        return alignedMalloc<Ptr>(n * sizeof(T), N);
    }
    
    void deallocate(Ptr p, SizeType) const noexcept { alignedFree(p); }
};

static const int ALIGNMENT16   = 16;
static const int ALIGNMENT4096 = 4096;

typedef std::vector<char, AlignedAllocator<char, ALIGNMENT4096>> LCAlignedMemory4K;

static LCAlignedMemory4K* _M4K(LCAlignedMemory4KPtr mem_) { return (LCAlignedMemory4K*)mem_; }

LCAlignedMemory4KPtr LCAlignedMemory4KNew() {
    LCAlignedMemory4K* mem = (LCAlignedMemory4K*)(new LCAlignedMemory4K());
    mem->reserve(ALIGNMENT4096);
    return mem;
}

void LCAlignedMemory4KDelete(LCAlignedMemory4KPtr mem_) {
    delete _M4K(mem_);
}

void* LCAlignedMemory4KPointer(LCAlignedMemory4KPtr mem_) {
    return _M4K(mem_)->data();
}

long LCAlignedMemory4KCapacity(LCAlignedMemory4KPtr mem_) {
    return (long)_M4K(mem_)->capacity();
}

long LCAlignedMemory4KLength(LCAlignedMemory4KPtr mem_) {
    return (long)_M4K(mem_)->size();
}

void LCAlignedMemory4KResize(LCAlignedMemory4KPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    LCAlignedMemory4K *mem = _M4K(mem_);
    if(length == mem->size()) { return; }
    mem->resize(length);
}

void LCAlignedMemory4KReserve(LCAlignedMemory4KPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    _M4K(mem_)->reserve(length);
}

void LCAlignedMemory4KAppend(LCAlignedMemory4KPtr mem_, LCAlignedMemory4KPtr src_) {
    LCAlignedMemory4K* d = _M4K(mem_);
    LCAlignedMemory4K* s = _M4K(src_);
    std::copy(s->begin(), s->end(), std::back_inserter(*d));
}

void LCAlignedMemory4KAppendC(LCAlignedMemory4KPtr mem_, void* bin_, long length_) {
    LCAlignedMemory4K* m = _M4K(mem_);
    long sz = m->size();
    m->resize((size_t)(sz + length_));
    char* p = (char*)LCAlignedMemory4KPointer(mem_);
    
    memcpy(&p[sz], bin_, (size_t)length_);
}


typedef std::vector<char, AlignedAllocator<char, ALIGNMENT16>> LCAlignedMemory16;

static LCAlignedMemory16* _M16(LCAlignedMemory16Ptr mem_) { return (LCAlignedMemory16*)mem_; }

LCAlignedMemory16Ptr LCAlignedMemory16New() {
    LCAlignedMemory16* mem = (LCAlignedMemory16*)(new LCAlignedMemory16());
    mem->reserve(ALIGNMENT16);
    return mem;
}

void LCAlignedMemory16Delete(LCAlignedMemory16Ptr mem_) {
    delete _M16(mem_);
}

void* LCAlignedMemory16Pointer(LCAlignedMemory16Ptr mem_) {
    return _M16(mem_)->data();
}

long LCAlignedMemory16Capacity(LCAlignedMemory16Ptr mem_) {
    return (long)_M16(mem_)->capacity();
}

long LCAlignedMemory16Length(LCAlignedMemory16Ptr mem_) {
    return (long)_M16(mem_)->size();
}

void LCAlignedMemory16Resize(LCAlignedMemory16Ptr mem_, long length_) {
    long mod = length_ % ALIGNMENT16;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT16 - mod);
    LCAlignedMemory16 *mem = _M16(mem_);
    if(length == mem->size()) { return; }
    mem->resize(length);
}

void LCAlignedMemory16Reserve(LCAlignedMemory16Ptr mem_, long length_) {
    long mod = length_ % ALIGNMENT16;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT16 - mod);
    _M16(mem_)->reserve(length);
}

void LCAlignedMemory16Append(LCAlignedMemory16Ptr mem_, LCAlignedMemory4KPtr src_) {
    LCAlignedMemory16* d = _M16(mem_);
    LCAlignedMemory16* s = _M16(src_);
    std::copy(s->begin(), s->end(), std::back_inserter(*d));
}

void LCAlignedMemory16AppendC(LCAlignedMemory16Ptr mem_, void* bin_, long length_) {
    LCAlignedMemory16* m = _M16(mem_);
    long sz = m->size();
    m->resize((size_t)(sz + length_));
    char* p = (char*)LCAlignedMemory16Pointer(mem_);
    
    memcpy(&p[sz], bin_, (size_t)length_);
}
