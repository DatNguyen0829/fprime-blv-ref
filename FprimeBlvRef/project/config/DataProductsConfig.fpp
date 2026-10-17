module DataProductsConfig {
    constant BASE_ID = 0x04000000

    module QueueSizes {
        constant dpCat = 3
        constant dpMgr = 3
        constant dpWriter = 3
        constant dpBufferAccumulator = 3
        constant dpBufferManager = 3
    }

    module StackSizes {
        constant dpCat = 8 * 1024
        constant dpMgr = 8 * 1024
        constant dpWriter = 8 * 1024
        constant dpBufferAccumulator = 8 * 1024
        constant dpBufferManager = 8 * 1024
    }

    module Priorities {
        constant dpCat = 9
        constant dpMgr = 10
        constant dpWriter = 11
        constant dpBufferAccumulator = 12
        constant dpBufferManager = 12
    }

    module CpuAffinities {
        constant dpCat = Os.TASK_DEFAULT
        constant dpMgr = Os.TASK_DEFAULT
        constant dpWriter = Os.TASK_DEFAULT
        constant dpBufferAccumulator = Os.TASK_DEFAULT
    }

    module BufferAccumulator {
        constant allocatorId   = 301
        constant maxNumBuffers = 2
    }

    module BuffMgr {
        constant dpBufferStoreSize  = 512
        constant dpBufferStoreCount = 2
        constant dpBufferManagerId  = 300
    }

    module Paths {
        constant dpDir = "./DpCat"
        constant dpState = "./DpCat/DpState.dat"
    }
}