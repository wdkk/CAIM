//
// CAIMMemory4KC.mm
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

#include "CAIMMemoryC.h"
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

typedef std::vector<char, AlignedAllocator<char, ALIGNMENT4096>> CAIMMemory4KC;

static CAIMMemory4KC* _M4K(CAIMMemory4KCPtr mem_) { return (CAIMMemory4KC*)mem_; }

CAIMMemory4KCPtr CAIMMemory4KCNew() {
    CAIMMemory4KC* mem = (CAIMMemory4KC*)(new CAIMMemory4KC());
    mem->reserve(ALIGNMENT4096);
    return mem;
}

void CAIMMemory4KCDelete(CAIMMemory4KCPtr mem_) {
    delete _M4K(mem_);
}

void* CAIMMemory4KCPointer(CAIMMemory4KCPtr mem_) {
    return _M4K(mem_)->data();
}

long CAIMMemory4KCCapacity(CAIMMemory4KCPtr mem_) {
    return (long)_M4K(mem_)->capacity();
}

long CAIMMemory4KCLength(CAIMMemory4KCPtr mem_) {
    return (long)_M4K(mem_)->size();
}

void CAIMMemory4KCResize(CAIMMemory4KCPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    CAIMMemory4KC *mem = _M4K(mem_);
    if(length == mem->size()) { return; }
    mem->resize(length);
}

void CAIMMemory4KCReserve(CAIMMemory4KCPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT4096;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT4096 - mod);
    _M4K(mem_)->reserve(length);
}

void CAIMMemory4KCAppend(CAIMMemory4KCPtr mem_, CAIMMemory4KCPtr src_) {
    CAIMMemory4KC* d = _M4K(mem_);
    CAIMMemory4KC* s = _M4K(src_);
    std::copy(s->begin(), s->end(), std::back_inserter(*d));
}

void CAIMMemory4KCAppendC(CAIMMemory4KCPtr mem_, void* bin_, long length_) {
    CAIMMemory4KC* m = _M4K(mem_);
    long sz = m->size();
    m->resize((size_t)(sz + length_));
    char* p = (char*)CAIMMemory4KCPointer(mem_);
    
    memcpy(&p[sz], bin_, (size_t)length_);
}


typedef std::vector<char, AlignedAllocator<char, ALIGNMENT16>> CAIMMemory16C;

static CAIMMemory16C* _M16(CAIMMemory16CPtr mem_) { return (CAIMMemory16C*)mem_; }

CAIMMemory16CPtr CAIMMemory16CNew() {
    CAIMMemory16C* mem = (CAIMMemory16C*)(new CAIMMemory16C());
    mem->reserve(ALIGNMENT16);
    return mem;
}

void CAIMMemory16CDelete(CAIMMemory16CPtr mem_) {
    delete _M16(mem_);
}

void* CAIMMemory16CPointer(CAIMMemory16CPtr mem_) {
    return _M16(mem_)->data();
}

long CAIMMemory16CCapacity(CAIMMemory16CPtr mem_) {
    return (long)_M16(mem_)->capacity();
}

long CAIMMemory16CLength(CAIMMemory16CPtr mem_) {
    return (long)_M16(mem_)->size();
}

void CAIMMemory16CResize(CAIMMemory16CPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT16;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT16 - mod);
    CAIMMemory16C *mem = _M16(mem_);
    if(length == mem->size()) { return; }
    mem->resize(length);
}

void CAIMMemory16CReserve(CAIMMemory16CPtr mem_, long length_) {
    long mod = length_ % ALIGNMENT16;
    long length = mod == 0 ? length_ : length_ + (ALIGNMENT16 - mod);
    _M16(mem_)->reserve(length);
}

void CAIMMemory16CAppend(CAIMMemory16CPtr mem_, CAIMMemory4KCPtr src_) {
    CAIMMemory16C* d = _M16(mem_);
    CAIMMemory16C* s = _M16(src_);
    std::copy(s->begin(), s->end(), std::back_inserter(*d));
}

void CAIMMemory16CAppendC(CAIMMemory16CPtr mem_, void* bin_, long length_) {
    CAIMMemory16C* m = _M16(mem_);
    long sz = m->size();
    m->resize((size_t)(sz + length_));
    char* p = (char*)CAIMMemory16CPointer(mem_);
    
    memcpy(&p[sz], bin_, (size_t)length_);
}
