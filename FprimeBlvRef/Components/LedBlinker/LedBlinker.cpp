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

void LedBlinker ::TODO_cmdHandler(FwOpcodeType opCode, U32 cmdSeq) {
    // TODO
    this->cmdResponse_out(opCode, cmdSeq, Fw::CmdResponse::OK);
}

}  // namespace FprimeBlvRef
