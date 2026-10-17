module ComCcsdsConfig {
    constant BASE_ID = 0x02000000

    module QueueSizes {
        constant comQueue = 16
        constant aggregator = 8
    }

    module StackSizes {
        constant comQueue = 8 * 1024
        constant aggregator = 8 * 1024
    }

    module Priorities {
        constant aggregator = 7
        constant comQueue = 8
    }

    module CpuAffinities {
        constant aggregator = Os.TASK_DEFAULT
        constant comQueue = Os.TASK_DEFAULT
    }

    module QueueDepths {
        constant events = 10
        constant tlm = 1
        constant file = 1
    }

    module QueuePriorities {
        constant events = 0
        constant tlm = 2
        constant file = 1
    }

    module BuffMgr {
        constant frameAccumulatorSize = 1024
        constant commsBuffSize = 1024
        constant commsFileBuffSize = 1024
        constant commsBuffCount = 5
        constant commsFileBuffCount = 5
        constant commsBuffMgrId = 200
    }
}