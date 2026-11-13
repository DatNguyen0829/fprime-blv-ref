module FprimeBlvRef {

  # ----------------------------------------------------------------------
  # Symbolic constants for port numbers
  # ----------------------------------------------------------------------

  enum Ports_RateGroups {
    rateGroup_1Hz
    rateGroup_0_5Hz
    rateGroup_0_25Hz
  }

  deployment topology ReferenceDeployment {

  # ----------------------------------------------------------------------
  # Subtopology imports
  # ----------------------------------------------------------------------
    import CdhCore.Subtopology
    import ComCcsdsUart.Subtopology
    import DataProducts.Subtopology
    import FileHandling.Subtopology
    
  # ----------------------------------------------------------------------
  # Instances used in the topology
  # ----------------------------------------------------------------------
    instance chronoTime
    instance rateGroup_1Hz
    instance rateGroup_0_5Hz
    instance rateGroup_0_25Hz
    instance rateGroupDriver
    instance systemResources
    instance timer
    instance comDriver
    instance cmdSeq
    instance statusLedManager
    instance inaManager
    instance statusLedDriver
    instance inaDriver

  # ----------------------------------------------------------------------
  # Pattern graph specifiers
  # ----------------------------------------------------------------------

    command connections instance CdhCore.cmdDisp
    event connections instance CdhCore.events
    telemetry connections instance CdhCore.tlmSend
    text event connections instance CdhCore.textLogger
    health connections instance CdhCore.$health
    param connections instance FileHandling.prmDb
    time connections instance chronoTime

  # ----------------------------------------------------------------------
  # Telemetry packets (only used when TlmPacketizer is used)
  # ----------------------------------------------------------------------

    # include "ReferenceDeploymentPackets.fppi"

  # ----------------------------------------------------------------------
  # Direct graph specifiers
  # ----------------------------------------------------------------------

    connections ComCcsds_CdhCore {
      # Core events and telemetry to communication queue
      CdhCore.events.PktSend -> ComCcsdsUart.comQueue.comPacketQueueIn[ComCcsdsUart.Ports_ComPacketQueue.EVENTS]
      CdhCore.tlmSend.PktSend -> ComCcsdsUart.comQueue.comPacketQueueIn[ComCcsdsUart.Ports_ComPacketQueue.TELEMETRY]

      # Router to Command Dispatcher
      ComCcsdsUart.fprimeRouter.commandOut -> CdhCore.cmdDisp.seqCmdBuff
      CdhCore.cmdDisp.seqCmdStatus -> ComCcsdsUart.fprimeRouter.cmdResponseIn
      
    }

    connections ComCcsds_FileHandling {
      # File Downlink to Communication Queue
      FileHandling.fileDownlink.bufferSendOut -> ComCcsdsUart.comQueue.bufferQueueIn[ComCcsdsUart.Ports_ComBufferQueue.FILE]
      ComCcsdsUart.comQueue.bufferReturnOut[ComCcsdsUart.Ports_ComBufferQueue.FILE] -> FileHandling.fileDownlink.bufferReturn

      # Router to File Uplink
      ComCcsdsUart.Subtopology.fileUplinkOut -> FileHandling.fileUplink.bufferSendIn
      FileHandling.fileUplink.bufferSendOut -> ComCcsdsUart.Subtopology.fileUplinkReturnIn
    }

    connections Communications {
      # ComDriver buffer allocations
      comDriver.allocate      -> ComCcsdsUart.commsBufferManager.bufferGetCallee
      comDriver.deallocate    -> ComCcsdsUart.commsBufferManager.bufferSendIn
      
      # ComDriver <-> ComStub (Uplink)
      comDriver.$recv                     -> ComCcsdsUart.comStub.drvReceiveIn
      ComCcsdsUart.comStub.drvReceiveReturnOut -> comDriver.recvReturnIn
      
      # ComStub <-> ComDriver (Downlink)
      ComCcsdsUart.comStub.drvSendOut      -> comDriver.$send
      comDriver.ready         -> ComCcsdsUart.comStub.drvConnected
    }

    connections FileHandling_DataProducts {
      # Data Products to File Downlink
      DataProducts.dpCat.fileOut -> FileHandling.fileDownlink.SendFile
      FileHandling.fileDownlink.FileComplete -> DataProducts.dpCat.fileDone
    }

    connections RateGroups {
      # timer to drive rate group
      timer.CycleOut -> rateGroupDriver.CycleIn

      # Divider output drives this active rate group
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup_1Hz] -> rateGroup_1Hz.CycleIn
      
      # Receive bytes first
      rateGroup_1Hz.RateGroupMemberOut[0] -> comDriver.schedIn

      # Process newly received commands
      rateGroup_1Hz.RateGroupMemberOut[1] -> CdhCore.cmdDisp.run

      # Process outgoing packets
      rateGroup_1Hz.RateGroupMemberOut[2] -> ComCcsdsUart.comQueue.run
      rateGroup_1Hz.RateGroupMemberOut[3] -> ComCcsdsUart.aggregator.timeout

      # Remaining periodic work
      rateGroup_1Hz.RateGroupMemberOut[4] -> CdhCore.tlmSend.Run
      rateGroup_1Hz.RateGroupMemberOut[5] -> FileHandling.fileDownlink.Run
      rateGroup_1Hz.RateGroupMemberOut[6] -> systemResources.run

      # Running Ina Sensor to poll power data
      rateGroup_1Hz.RateGroupMemberOut[7] -> inaManager.run

      # 0.5Hz rate group
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup_0_5Hz] -> rateGroup_0_5Hz.CycleIn
      rateGroup_0_5Hz.RateGroupMemberOut[0] -> cmdSeq.schedIn

      # 0.25Hz rate group
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup_0_25Hz] -> rateGroup_0_25Hz.CycleIn
      rateGroup_0_25Hz.RateGroupMemberOut[0] -> CdhCore.$health.Run
      rateGroup_0_25Hz.RateGroupMemberOut[1] -> ComCcsdsUart.commsBufferManager.schedIn
      rateGroup_0_25Hz.RateGroupMemberOut[2] -> DataProducts.dpBufferManager.schedIn
      rateGroup_0_25Hz.RateGroupMemberOut[3] -> DataProducts.dpWriter.schedIn
      rateGroup_0_25Hz.RateGroupMemberOut[4] -> DataProducts.dpMgr.schedIn
    }

    connections CdhCore_cmdSeq {
      # Command Sequencer
      cmdSeq.comCmdOut -> CdhCore.cmdDisp.seqCmdBuff
      CdhCore.cmdDisp.seqCmdStatus -> cmdSeq.cmdResponseIn
    }

    connections ReferenceDeployment {
      # GPIO write connections
      statusLedManager.statusLedSet -> statusLedDriver.gpioWrite

      # I2C write and read connection
      inaManager.inaWriteRead -> inaDriver.writeRead
    }

  }

}
