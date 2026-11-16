module ComCcsdsLora {

    # ComPacket Queue enum for queue types
    enum Ports_ComPacketQueue : U8 {
        EVENTS,
        TELEMETRY 
    }

    enum Ports_ComBufferQueue : U8 {
        FILE
    }

    # ----------------------------------------------------------------------
    # Active Components
    # ----------------------------------------------------------------------
    instance comQueue: Svc.ComQueue base id ComCcsdsConfig.BASE_ID_LORA + 0x00000 \
        queue size ComCcsdsConfig.QueueSizes.comQueue \
        stack size ComCcsdsConfig.StackSizes.comQueue \
        priority ComCcsdsConfig.Priorities.comQueue \
        cpu ComCcsdsConfig.CpuAffinities.comQueue \
    {
        phase Fpp.ToCpp.Phases.configComponents """
        using namespace ComCcsdsLora;
        Svc::ComQueue::QueueConfigurationTable configurationTableLora;

        // Events (highest-priority)
        configurationTableLora.entries[Ports_ComPacketQueue::EVENTS].depth = ComCcsdsConfig::QueueDepths::events;
        configurationTableLora.entries[Ports_ComPacketQueue::EVENTS].priority = ComCcsdsConfig::QueuePriorities::events;

        // Telemetry
        configurationTableLora.entries[Ports_ComPacketQueue::TELEMETRY].depth = ComCcsdsConfig::QueueDepths::tlm;
        configurationTableLora.entries[Ports_ComPacketQueue::TELEMETRY].priority = ComCcsdsConfig::QueuePriorities::tlm;

        // File Downlink Queue (buffer queue using NUM_CONSTANTS offset)
        configurationTableLora.entries[Ports_ComPacketQueue::NUM_CONSTANTS + Ports_ComBufferQueue::FILE].depth = ComCcsdsConfig::QueueDepths::file;
        configurationTableLora.entries[Ports_ComPacketQueue::NUM_CONSTANTS + Ports_ComBufferQueue::FILE].priority = ComCcsdsConfig::QueuePriorities::file;

        // Allocation identifier is 0 as the MallocAllocator discards it
        ComCcsdsLora::comQueue.configure(configurationTableLora, 0, ComCcsds::Allocation::memAllocator);
        """
        phase Fpp.ToCpp.Phases.tearDownComponents """
        ComCcsdsLora::comQueue.cleanup();
        """
    }

    # ----------------------------------------------------------------------
    # Passive Components
    # ----------------------------------------------------------------------
    instance frameAccumulator: Svc.FrameAccumulator base id ComCcsdsConfig.BASE_ID_LORA + 0x01000 \
    {

        phase Fpp.ToCpp.Phases.configObjects """
        Svc::FrameDetectors::CcsdsTcFrameDetector frameDetector;
        """
        phase Fpp.ToCpp.Phases.configComponents """
        ComCcsdsLora::frameAccumulator.configure(
            ConfigObjects::ComCcsdsLora_frameAccumulator::frameDetector,
            1,
            ComCcsds::Allocation::memAllocator,
            ComCcsdsConfig::BuffMgr::frameAccumulatorSize
        );
        """

        phase Fpp.ToCpp.Phases.tearDownComponents """
        ComCcsdsLora::frameAccumulator.cleanup();
        """
    }

    instance commsBufferManager: Svc.BufferManager base id ComCcsdsConfig.BASE_ID_LORA + 0x02000 \
    {
        phase Fpp.ToCpp.Phases.configObjects """
        Svc::BufferManager::BufferBins bins;
        """

        phase Fpp.ToCpp.Phases.configComponents """
        memset(&ConfigObjects::ComCcsdsLora_commsBufferManager::bins, 0, sizeof(ConfigObjects::ComCcsdsLora_commsBufferManager::bins));
        ConfigObjects::ComCcsdsLora_commsBufferManager::bins.bins[0].bufferSize = ComCcsdsConfig::BuffMgr::commsBuffSize;
        ConfigObjects::ComCcsdsLora_commsBufferManager::bins.bins[0].numBuffers = ComCcsdsConfig::BuffMgr::commsBuffCount;
        ConfigObjects::ComCcsdsLora_commsBufferManager::bins.bins[1].bufferSize = ComCcsdsConfig::BuffMgr::commsFileBuffSize;
        ConfigObjects::ComCcsdsLora_commsBufferManager::bins.bins[1].numBuffers = ComCcsdsConfig::BuffMgr::commsFileBuffCount;
        ComCcsdsLora::commsBufferManager.setup(
            ComCcsdsConfig::BuffMgr::commsBuffMgrId,
            0,
            ComCcsds::Allocation::memAllocator,
            ConfigObjects::ComCcsdsLora_commsBufferManager::bins
        );
        """

        phase Fpp.ToCpp.Phases.tearDownComponents """
        ComCcsdsLora::commsBufferManager.cleanup();
        """
    }

    # The standard ComCcsdsConfig dependency defines ComCcsds.fprimeRouter.
    # This LoRa-specific stack needs a router instance in its own module.
    instance fprimeRouter: Svc.FprimeRouter base id ComCcsdsConfig.BASE_ID_LORA + 0x03000

    instance tcDeframer: Svc.Ccsds.TcDeframer base id ComCcsdsConfig.BASE_ID_LORA + 0x04000

    instance spacePacketDeframer: Svc.Ccsds.SpacePacketDeframer base id ComCcsdsConfig.BASE_ID_LORA + 0x05000

    instance aggregator: Svc.ComAggregator base id ComCcsdsConfig.BASE_ID_LORA + 0x06000 \
        queue size ComCcsdsConfig.QueueSizes.aggregator \
        stack size ComCcsdsConfig.StackSizes.aggregator \
        priority ComCcsdsConfig.Priorities.aggregator \
        cpu ComCcsdsConfig.CpuAffinities.aggregator

    # NOTE: name 'framer' is used for the framer that connects to the Com Adapter Interface for better subtopology interoperability
    instance framer: Svc.Ccsds.TmFramer base id ComCcsdsConfig.BASE_ID_LORA + 0x07000

    instance spacePacketFramer: Svc.Ccsds.SpacePacketFramer base id ComCcsdsConfig.BASE_ID_LORA + 0x08000

    instance apidManager: Svc.Ccsds.ApidManager base id ComCcsdsConfig.BASE_ID_LORA + 0x09000

    # This subtopology boxes the Space Packet packet layer: router, ComQueue, space packet
    # framer/deframer, APID manager, aggregator, and comms buffer manager.
    topology SpacePacketFraming {
        # Usage Note:
        #
        # When importing this subtopology, users shall establish 5 port connections with a downstream
        # framing layer or a component implementing the Svc.Com (Svc/Interfaces/Com.fpp) interface:
        #
        # 1) Outputs:
        #     - ComCcsdsLora.SpacePacketFraming.dataOut       -> [downstream].dataIn
        #     - ComCcsdsLora.SpacePacketFraming.dataReturnOut -> [downstream].dataReturnIn
        # 2) Inputs:
        #     - [downstream].dataReturnOut -> ComCcsdsLora.SpacePacketFraming.dataReturnIn
        #     - [downstream].comStatusOut  -> ComCcsdsLora.SpacePacketFraming.comStatusIn
        #     - [downstream].dataOut       -> ComCcsdsLora.SpacePacketFraming.dataIn

        # Active Components
        instance comQueue

        # Passive Components
        instance commsBufferManager
        instance fprimeRouter
        instance spacePacketDeframer
        instance spacePacketFramer
        instance apidManager
        instance aggregator

        connections Downlink {
            # ComQueue <-> SpacePacketFramer
            comQueue.dataOut                -> spacePacketFramer.dataIn
            spacePacketFramer.dataReturnOut -> comQueue.dataReturnIn
            # SpacePacketFramer buffer and APID management
            spacePacketFramer.bufferAllocate   -> commsBufferManager.bufferGetCallee
            spacePacketFramer.bufferDeallocate -> commsBufferManager.bufferSendIn
            spacePacketFramer.getApidSeqCount  -> apidManager.getApidSeqCountIn
            # SpacePacketFramer <-> ComAggregator
            spacePacketFramer.dataOut -> aggregator.dataIn
            aggregator.dataReturnOut  -> spacePacketFramer.dataReturnIn

            # ComStatus
            aggregator.comStatusOut        -> spacePacketFramer.comStatusIn
            spacePacketFramer.comStatusOut -> comQueue.comStatusIn
            # (Outgoing) Aggregator <-> downstream connections shall be established by the user
        }

        connections Uplink {
            # (Incoming) downstream <-> SpacePacketDeframer connections shall be established by the user
            # SpacePacketDeframer APID validation
            spacePacketDeframer.validateApidSeqCount -> apidManager.validateApidSeqCountIn
            # SpacePacketDeframer <-> Router
            spacePacketDeframer.dataOut -> fprimeRouter.dataIn
            fprimeRouter.dataReturnOut  -> spacePacketDeframer.dataReturnIn
        }

        # ----------------------------------------------------------------------
        # Topology ports (open framing boundary)
        # ----------------------------------------------------------------------

        @ Output port sending aggregated space packets to the downstream framing layer
        port dataOut       = aggregator.dataOut

        @ Input port receiving back ownership of downlinked buffers from the downstream framing layer
        port dataReturnIn  = aggregator.dataReturnIn

        @ Input port receiving com status from the downstream framing layer
        port comStatusIn   = aggregator.comStatusIn

        @ Input port receiving space packets from the downstream framing layer for deframing
        port dataIn        = spacePacketDeframer.dataIn

        @ Output port returning ownership of uplinked buffers to the downstream framing layer
        port dataReturnOut = spacePacketDeframer.dataReturnOut

        # Buffer management boundary
        @ Input port for requesting (allocating) a new Fw::Buffer from the comms buffer pool
        port bufferGetCallee = commsBufferManager.bufferGetCallee

        @ Input port for deallocating Fw::Buffers back into the comms buffer pool
        port bufferSendIn    = commsBufferManager.bufferSendIn
    } # end SpacePacketFraming

    # This subtopology boxes the CCSDS TM/TC transfer frame layer: the TM framer (downlink),
    # and the frame accumulator + TC deframer (uplink).
    topology TmTcFraming {
        # Usage Note:
        #
        # When importing this subtopology, users shall establish the following external connections:
        #
        # 1) Upstream (packet layer, e.g. SpacePacketFraming):
        #     - [upstream].dataOut                          -> ComCcsdsLora.TmTcFraming.dataIn
        #     - ComCcsdsLora.TmTcFraming.dataReturnOut          -> [upstream].dataReturnIn
        #     - ComCcsdsLora.TmTcFraming.comStatusOut           -> [upstream].comStatusIn
        #     - ComCcsdsLora.TmTcFraming.dataOut                -> [upstream].dataIn (deframed data)
        #     - [upstream].dataReturnOut                    -> ComCcsdsLora.TmTcFraming.dataReturnIn
        # 2) Downstream (a component implementing the Svc.Com interface):
        #     - ComCcsdsLora.TmTcFraming.framedDataOut          -> [Svc.Com].dataIn
        #     - ComCcsdsLora.TmTcFraming.framedDataReturnOut    -> [Svc.Com].dataReturnIn
        #     - [Svc.Com].dataReturnOut -> ComCcsdsLora.TmTcFraming.framedDataReturnIn
        #     - [Svc.Com].comStatusOut  -> ComCcsdsLora.TmTcFraming.framedComStatusIn
        #     - [Svc.Com].dataOut       -> ComCcsdsLora.TmTcFraming.framedDataIn
        # 3) Buffer management (e.g. a Svc.BufferManager):
        #     - ComCcsdsLora.TmTcFraming.bufferAllocate   -> [BufferManager].bufferGetCallee
        #     - ComCcsdsLora.TmTcFraming.bufferDeallocate -> [BufferManager].bufferSendIn

        instance framer
        instance tcDeframer
        instance frameAccumulator

        connections Uplink {
            # FrameAccumulator <-> TcDeframer
            frameAccumulator.dataOut -> tcDeframer.dataIn
            tcDeframer.dataReturnOut -> frameAccumulator.dataReturnIn
        }

        # ----------------------------------------------------------------------
        # Topology ports
        # ----------------------------------------------------------------------

        # Upstream boundary (packet layer)
        @ Input port receiving space packets from the packet layer for TM framing
        port dataIn        = framer.dataIn

        @ Output port returning ownership of downlinked buffers to the packet layer
        port dataReturnOut = framer.dataReturnOut

        @ Output port forwarding com status to the packet layer
        port comStatusOut  = framer.comStatusOut

        @ Output port sending TC-deframed data to the packet layer
        port dataOut       = tcDeframer.dataOut

        @ Input port receiving back ownership of uplinked buffers from the packet layer
        port dataReturnIn  = tcDeframer.dataReturnIn

        # Downstream boundary (Svc.Com interface)
        @ Output port sending TM transfer frames to the com interface
        port framedDataOut       = framer.dataOut

        @ Input port receiving back ownership of transmitted frame buffers from the com interface
        port framedDataReturnIn  = framer.dataReturnIn

        @ Input port receiving com status from the com interface
        port framedComStatusIn   = framer.comStatusIn

        @ Input port receiving raw uplink data from the com interface
        port framedDataIn        = frameAccumulator.dataIn

        @ Output port returning ownership of received uplink buffers to the com interface
        port framedDataReturnOut = frameAccumulator.dataReturnOut

        # Buffer management boundary
        @ Output port for allocating accumulation buffers
        port bufferAllocate   = frameAccumulator.bufferAllocate

        @ Output port for deallocating accumulation buffers
        port bufferDeallocate = frameAccumulator.bufferDeallocate
    } # end TmTcFraming

    # This subtopology composes the SpacePacketFraming packet layer with the TmTcFraming
    # TM/TC transfer frame layer to form the full CCSDS communications stack.
    topology FramingSubtopology {
        # Usage Note:
        #
        # When importing this subtopology, users shall establish 5 port connections with a component implementing
        # the Svc.Com (Svc/Interfaces/Com.fpp) interface. They are as follows:
        #
        # 1) Outputs:
        #     - ComCcsdsLora.FramingSubtopology.dataOut       -> [Svc.Com].dataIn
        #     - ComCcsdsLora.FramingSubtopology.dataReturnOut -> [Svc.Com].dataReturnIn
        # 2) Inputs:
        #     - [Svc.Com].dataReturnOut -> ComCcsdsLora.FramingSubtopology.dataReturnIn
        #     - [Svc.Com].comStatusOut  -> ComCcsdsLora.FramingSubtopology.comStatusIn
        #     - [Svc.Com].dataOut       -> ComCcsdsLora.FramingSubtopology.dataIn

        # Packet layer (router, ComQueue, space packet framer/deframer, buffer manager)
        import SpacePacketFraming

        # TM/TC transfer frame layer (TM framer, frame accumulator, TC deframer)
        import TmTcFraming

        connections Downlink {
            # SpacePacketFraming <-> TmTcFraming
            SpacePacketFraming.dataOut -> TmTcFraming.dataIn
            TmTcFraming.dataReturnOut  -> SpacePacketFraming.dataReturnIn

            # ComStatus
            TmTcFraming.comStatusOut -> SpacePacketFraming.comStatusIn
            # (Outgoing) TmTcFraming <-> ComInterface connections shall be established by the user
        }

        connections Uplink {
            # (Incoming) ComInterface <-> TmTcFraming connections shall be established by the user
            # TmTcFraming buffer allocations
            TmTcFraming.bufferDeallocate -> SpacePacketFraming.bufferSendIn
            TmTcFraming.bufferAllocate   -> SpacePacketFraming.bufferGetCallee
            # TmTcFraming <-> SpacePacketFraming
            TmTcFraming.dataOut               -> SpacePacketFraming.dataIn
            SpacePacketFraming.dataReturnOut  -> TmTcFraming.dataReturnIn
        }

        # ----------------------------------------------------------------------
        # Topology ports (Svc.Com boundary)
        # ----------------------------------------------------------------------

        @ Output port sending TM transfer frames to the com interface
        port dataOut       = framer.dataOut

        @ Input port receiving back ownership of transmitted frame buffers from the com interface
        port dataReturnIn  = framer.dataReturnIn

        @ Input port receiving com status from the com interface
        port comStatusIn   = framer.comStatusIn

        @ Input port receiving raw uplink data from the com interface
        port dataIn        = frameAccumulator.dataIn

        @ Output port returning ownership of received uplink buffers to the com interface
        port dataReturnOut = frameAccumulator.dataReturnOut
    } # end FramingSubtopology

    # Full CCSDS stack with an open Svc.Com boundary. The deployment connects
    # these communication ports directly to the Zephyr.LoRa component.
    topology Subtopology {
        import FramingSubtopology

        # ----------------------------------------------------------------------
        # Topology ports
        # ----------------------------------------------------------------------

        # Command routing
        @ Output port sending routed command packets to the command dispatcher
        port commandOut         = fprimeRouter.commandOut

        @ Input port receiving command response messages back into the router
        port cmdResponseIn      = fprimeRouter.cmdResponseIn

        @ Output port sending uplinked file packets to the file handling stack
        port fileUplinkOut          = fprimeRouter.fileOut

        @ Input port receiving back buffer ownership from the file handling stack
        port fileUplinkReturnIn = fprimeRouter.fileBufferReturnIn

        # Telemetry/events/file queuing (array ports - index at connection site)
        @ Input port array for queueing Fw::ComBuffers
        port comPacketQueueIn = comQueue.comPacketQueueIn

        @ Input port array for queueing Fw::Buffers
        port bufferQueueIn    = comQueue.bufferQueueIn

        @ Output port array returning ownership of Fw::Buffers to their original sender after dequeuing
        port bufferReturnOut  = comQueue.bufferReturnOut

        # Open Svc.Com boundary for Zephyr.LoRa
        @ Output port sending framed downlink data to the LoRa component
        port dataOut = framer.dataOut

        @ Input port receiving returned downlink buffers from the LoRa component
        port dataReturnIn = framer.dataReturnIn

        @ Input port receiving communication status from the LoRa component
        port comStatusIn = framer.comStatusIn

        @ Input port receiving uplink data from the LoRa component
        port dataIn = frameAccumulator.dataIn

        @ Output port returning uplink buffers to the LoRa component
        port dataReturnOut = frameAccumulator.dataReturnOut

        # Buffer management for the LoRa communication interface
        @ Input port for requesting (allocating) a new Fw::Buffer from the comms buffer pool
        port commsBufferGetCallee = commsBufferManager.bufferGetCallee

        @ Input port for deallocating Fw::Buffers back into the comms buffer pool
        port commsBufferSendIn    = commsBufferManager.bufferSendIn

        # Scheduling
        @ Input port for scheduling ComQueue telemetry output
        port comQueueRun          = comQueue.run

        @ Rate-group driven timeout to flush the ComAggregator buffer
        port aggregatorTimeout    = aggregator.timeout

        @ Input port triggering commsBufferManager telemetry output
        port bufferManagerSchedIn = commsBufferManager.schedIn

    } # end Subtopology

} # end ComCcsdsLora