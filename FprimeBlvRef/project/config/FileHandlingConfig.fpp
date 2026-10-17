module FileHandlingConfig {
    #Base ID for the FileHandling Subtopology, all components are offsets from this base ID
    constant BASE_ID = 0x05000000
    
    module QueueSizes {
        constant fileUplink = 5
        constant fileDownlink = 5
        constant fileManager = 5
        constant prmDb = 5
    }
    
    module StackSizes {
        constant fileUplink    = 8 * 1024
        constant fileDownlink  = 8 * 1024
        constant fileManager   = 8 * 1024
        constant prmDb         = 8 * 1024
    }

    module Priorities {
        constant fileUplink = 9
        constant fileDownlink = 10
        constant fileManager = 11
        constant prmDb = 12
    }

    module CpuAffinities {
        constant fileUplink    = Os.TASK_DEFAULT
        constant fileDownlink  = Os.TASK_DEFAULT
        constant fileManager   = Os.TASK_DEFAULT
        constant prmDb         = Os.TASK_DEFAULT
    }

    # File downlink configuration constants
    module DownlinkConfig {
        constant cooldown = 1000
        constant cycleTime = 1000
        constant fileQueueDepth = 2
    }
}
