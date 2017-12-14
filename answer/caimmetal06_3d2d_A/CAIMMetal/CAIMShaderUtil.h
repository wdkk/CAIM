//
// CAIMShaderUtil.h
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
#ifndef __CAIM_SHADER_UTIL_H__
#define __CAIM_SHADER_UTIL_H__

#include <metal_stdlib>

using namespace metal;

float slightZ(uint idx) { return 0.00000025 * float(idx); }

#endif

