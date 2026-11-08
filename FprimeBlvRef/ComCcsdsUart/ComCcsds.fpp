module ComCcsdsUart {
    # include any instance definitions here. For example:
    # instance framer: Svc.Framer base id ComCcsdsUartConfig.ComCcsdsUart_BASE_ID + << OFFSET >>

    # note that subtopologies are written with phases, which means inline c++ within this fpp file.
    # here is an example:
    # instance myCoolComponent: Components.CoolComponent base id ComCcsdsUartConfig.ComCcsdsUart_BASE_ID + << OFFSET >> \
    #   queue size ComCcsdsUartConfig.QueueSizes.myCoolComponent \
    #   stack size ComCcsdsUartConfig.StackSizes.myCoolComponent \
    #   priority ComCcsdsUartConfig.Priorities.CoolComponent \
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
    # instance myComponent: Svc.MyComponent base id ComCcsdsUartConfig.BASE_ID + 0x0100 \
    #     queue size ComCcsdsUartConfig.QueueSizes.myComponent \
    #     stack size ComCcsdsUartConfig.StackSizes.myComponent \
    #     priority ComCcsdsUartConfig.Priorities.myComponent

    # ----------------------------------------------------------------------
    # Queued Components
    # ----------------------------------------------------------------------
    
    # Add your queued components here. For example:
    # instance myQueuedComponent: Svc.MyQueuedComponent base id ComCcsdsUartConfig.BASE_ID + 0x0200 \
    #     queue size ComCcsdsUartConfig.QueueSizes.myQueuedComponent

    # ----------------------------------------------------------------------
    # Passive Components
    # ----------------------------------------------------------------------
    
    # Add your passive components here. For example:
    # instance myPassiveComponent: Svc.MyPassiveComponent base id ComCcsdsUartConfig.BASE_ID + 0x0300        

    @ A subtology to provide a communication line specific for UART
    topology ComCcsdsUart {

        # include any instance declarations here
        # and wiring connections as well. For example:

        # instance framer
        # connections Framer {
        #     ...    
        # }

    } # end topology
} # end ComCcsdsUart