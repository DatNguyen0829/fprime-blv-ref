// ======================================================================
// \title  LedBlinker.cpp
// \author bidat
// \brief  cpp file for LedBlinker component implementation class
// ======================================================================

#include "FprimeBlvRef/Components/LedBlinker/LedBlinker.hpp"

namespace FprimeBlvRef {

// ----------------------------------------------------------------------
// Component construction and destruction
// ----------------------------------------------------------------------

LedBlinker ::LedBlinker(const char* const compName) : LedBlinkerComponentBase(compName) {}

LedBlinker ::~LedBlinker() {}

// ----------------------------------------------------------------------
// Handler implementations for commands
// ----------------------------------------------------------------------

void LedBlinker ::SET_LED_cmdHandler(FwOpcodeType opCode, U32 cmdSeq, const Fw::On& led_state) {
    switch (static_cast<Fw::On::T>(led_state.e))
    {
    case Fw::On::ON:
        this->statusLedSet_out(0, Fw::Logic::HIGH);
        break;
    
    case Fw::On::OFF:
        this->statusLedSet_out(0, Fw::Logic::LOW);
        break;
    default:
        this->cmdResponse_out(opCode, cmdSeq, Fw::CmdResponse::FORMAT_ERROR);
        break;
    }

    this->log_ACTIVITY_HI_LED_STATE(led_state);
    this->cmdResponse_out(opCode, cmdSeq, Fw::CmdResponse::OK);
}

}  // namespace FprimeBlvRef
