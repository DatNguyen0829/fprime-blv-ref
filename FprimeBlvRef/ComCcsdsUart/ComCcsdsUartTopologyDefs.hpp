#ifndef COMCCSDSUART_TOPOLOGY_DEFS_HPP
#define COMCCSDSUART_TOPOLOGY_DEFS_HPP

#include <Fw/Types/MallocAllocator.hpp>
#include <Svc/BufferManager/BufferManager.hpp>
#include <Svc/FrameAccumulator/FrameDetector/CcsdsTcFrameDetector.hpp>

// Shared standard ComCcsds configuration and allocator
#include <Svc/Subtopologies/ComCcsds/ComCcsdsConfig/ComCcsdsSubtopologyConfig.hpp>
#include <Svc/Subtopologies/ComCcsds/ComCcsdsConfig/FppConstantsAc.hpp>

// Enums generated from the new ComCcsdsUart module
#include <FprimeBlvRef/ComCcsdsUart/Ports_ComBufferQueueEnumAc.hpp>
#include <FprimeBlvRef/ComCcsdsUart/Ports_ComPacketQueueEnumAc.hpp>

namespace ComCcsdsUart {

struct SubtopologyState {
    // No external runtime state is currently needed.
};

struct TopologyState {
    SubtopologyState comCcsdsUart;
};

}  // namespace ComCcsdsUart

#endif