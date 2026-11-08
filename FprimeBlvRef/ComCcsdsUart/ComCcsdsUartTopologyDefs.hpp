#ifndef COMCCSDSUART_DEFS_HPP
#define COMCCSDSUART_DEFS_HPP

namespace ComCcsdsUart {
    struct ComCcsdsUartState {
        /* include any variables that are needed for 
        configuring/starting/tearing down the topology */
    };
    struct TopologyState {
        ComCcsdsUartState ComCcsdsUart_state;
    };
}

#endif