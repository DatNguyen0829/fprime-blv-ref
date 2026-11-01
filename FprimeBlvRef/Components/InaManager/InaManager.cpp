// ======================================================================
// \title  InaManager.cpp
// \author bidat
// \brief  cpp file for InaManager component implementation class
// ======================================================================

#include "FprimeBlvRef/Components/InaManager/InaManager.hpp"

namespace FprimeBlvRef {

// ----------------------------------------------------------------------
// Component construction and destruction
// ----------------------------------------------------------------------

InaManager ::InaManager(const char* const compName) : InaManagerComponentBase(compName) {}

InaManager ::~InaManager() {}

// ----------------------------------------------------------------------
// Handler implementations for typed input ports
// ----------------------------------------------------------------------

void InaManager ::run_handler(FwIndexType portNum, U32 context) {
    // TODO
}

}  // namespace FprimeBlvRef
