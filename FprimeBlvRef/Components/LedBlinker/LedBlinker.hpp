// ======================================================================
// \title  LedBlinker.hpp
// \author bidat
// \brief  hpp file for LedBlinker component implementation class
// ======================================================================

#ifndef FprimeBlvRef_LedBlinker_HPP
#define FprimeBlvRef_LedBlinker_HPP

#include "FprimeBlvRef/Components/LedBlinker/LedBlinkerComponentAc.hpp"

namespace FprimeBlvRef {

class LedBlinker final : public LedBlinkerComponentBase {
  public:
    // ----------------------------------------------------------------------
    // Component construction and destruction
    // ----------------------------------------------------------------------

    //! Construct LedBlinker object
    LedBlinker(const char* const compName  //!< The component name
    );

    //! Destroy LedBlinker object
    ~LedBlinker();

  private:
    // ----------------------------------------------------------------------
    // Handler implementations for commands
    // ----------------------------------------------------------------------

    //! Handler implementation for command TODO
    //!
    //! TODO
    void TODO_cmdHandler(FwOpcodeType opCode,  //!< The opcode
                         U32 cmdSeq            //!< The command sequence number
                         ) override;
};

}  // namespace FprimeBlvRef

#endif
