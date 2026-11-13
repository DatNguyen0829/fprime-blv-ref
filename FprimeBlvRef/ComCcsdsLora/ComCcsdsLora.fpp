module ComCcsdsLora {
    # include any instance definitions here. For example:
    # instance framer: Svc.Framer base id ComCcsdsLoraConfig.ComCcsdsLora_BASE_ID + << OFFSET >>

    # note that subtopologies are written with phases, which means inline c++ within this fpp file.
    # here is an example:
    # instance myCoolComponent: Components.CoolComponent base id ComCcsdsLoraConfig.ComCcsdsLora_BASE_ID + << OFFSET >> \
    #   queue size ComCcsdsLoraConfig.QueueSizes.myCoolComponent \
    #   stack size ComCcsdsLoraConfig.StackSizes.myCoolComponent \
    #   priority ComCcsdsLoraConfig.Priorities.CoolComponent \
    #   {
    #       phase Fpp.ToCpp.Phases.configComponents """
    #       {
    #           # some configuration function calls as necessary
    #       }
    #       """
    #   }

    # ---------------------------------------------------------------------
    # Active Components
    # ----------------------------------------------------------------------
    
    # Add your active components here. For example:
    # instance myComponent: Svc.MyComponent base id ComCcsdsLoraConfig.BASE_ID + 0x0100 \
    #     queue size ComCcsdsLoraConfig.QueueSizes.myComponent \
    #     stack size ComCcsdsLoraConfig.StackSizes.myComponent \
    #     priority ComCcsdsLoraConfig.Priorities.myComponent

    # ----------------------------------------------------------------------
    # Queued Components
    # ----------------------------------------------------------------------
    
    # Add your queued components here. For example:
    # instance myQueuedComponent: Svc.MyQueuedComponent base id ComCcsdsLoraConfig.BASE_ID + 0x0200 \
    #     queue size ComCcsdsLoraConfig.QueueSizes.myQueuedComponent

    # ----------------------------------------------------------------------
    # Passive Components
    # ----------------------------------------------------------------------
    
    # Add your passive components here. For example:
    # instance myPassiveComponent: Svc.MyPassiveComponent base id ComCcsdsLoraConfig.BASE_ID + 0x0300        

    @ Subtopology for Lora communication stack
    topology ComCcsdsLora {

        # include any instance declarations here
        # and wiring connections as well. For example:

        # instance framer
        # connections Framer {
        #     ...    
        # }

    } # end topology
} # end ComCcsdsLora