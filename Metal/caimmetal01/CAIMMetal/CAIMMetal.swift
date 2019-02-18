//
// CAIMMetal.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Foundation
import Metal

open class CAIMMetal
{
    public static var device:MTLDevice? = MTLCreateSystemDefaultDevice()
    private static var _command_queue:MTLCommandQueue?
    public static var commandQueue:MTLCommandQueue? {
        if( CAIMMetal._command_queue == nil ) { CAIMMetal._command_queue = device?.makeCommandQueue() }
        return CAIMMetal._command_queue
    }
    
    // コマンド実行
    public static func execute( prev:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                                main:( _ commandBuffer:MTLCommandBuffer )->(),
                                post:( _ commandBuffer:MTLCommandBuffer )->() = { _ in } ) {
        // 描画コマンドエンコーダ
        guard let command_buffer:MTLCommandBuffer = CAIMMetal.commandQueue?.makeCommandBuffer() else {
            print("cannot get Metal command buffer.")
            return
        }
        
        // 事前処理の実行(コンピュートシェーダなどで使える)
        prev( command_buffer )
            
        main( command_buffer )
        
        // コマンドバッファの確定
        command_buffer.commit()
        
        // 事後処理の関数の実行(command_buffer.waitUntilCompletedの呼び出しなど)
        post( command_buffer )
    }
}
