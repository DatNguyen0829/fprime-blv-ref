#ifndef COMCCSDSLORA_DEFS_HPP
#define COMCCSDSLORA_DEFS_HPP

namespace ComCcsdsLora {
    struct ComCcsdsLoraState {
        // No external runtime state is currently needed.
    };
    struct TopologyState {
        ComCcsdsLoraState comCcsdsLora;
    };
}

#endif