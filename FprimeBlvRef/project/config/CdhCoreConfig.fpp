module CdhCoreConfig {
    #Base ID for the CdhCore Subtopology, all components are offsets from this base ID
    constant BASE_ID = 0x01000000
    
    module QueueSizes {
        constant cmdDisp     = 8
        constant events      = 16
        constant tlmSend     = 16
        constant $health     = 16
    }
    

    module StackSizes {
        constant cmdDisp     = 8 * 1024
        constant events      = 8 * 1024
        constant tlmSend     = 8 * 1024
    }

    module Priorities {
        constant cmdDisp = 7
        constant $health = 8
        constant events = 9
        constant tlmSend = 10
    }

    module CpuAffinities {
        constant cmdDisp     = Os.TASK_DEFAULT
        constant events      = Os.TASK_DEFAULT
        constant tlmSend     = Os.TASK_DEFAULT
    }
}
