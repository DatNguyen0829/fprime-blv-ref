#ifndef COMCCSDSLORA_DEFS_HPP
#define COMCCSDSLORA_DEFS_HPP

#include <Fw/Types/MallocAllocator.hpp>
#include <Svc/BufferManager/BufferManager.hpp>
#include <Svc/FrameAccumulator/FrameDetector/CcsdsTcFrameDetector.hpp>

// Shared standard ComCcsds configuration and allocator
#include <Svc/Subtopologies/ComCcsds/ComCcsdsConfig/ComCcsdsSubtopologyConfig.hpp>
#include <Svc/Subtopologies/ComCcsds/ComCcsdsConfig/FppConstantsAc.hpp>

// Enums generated from the new ComCcsdsUart module
#include <FprimeBlvRef/ComCcsdsLora/Ports_ComBufferQueueEnumAc.hpp>
#include <FprimeBlvRef/ComCcsdsLora/Ports_ComPacketQueueEnumAc.hpp>


namespace ComCcsdsLora {
    struct ComCcsdsLoraState {
        // No external runtime state is currently needed.
    };
    struct TopologyState {
        ComCcsdsLoraState comCcsdsLora;
    };
}

#endif