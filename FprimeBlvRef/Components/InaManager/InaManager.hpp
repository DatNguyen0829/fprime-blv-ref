// ======================================================================
// \title  InaManager.hpp
// \author bidat
// \brief  hpp file for InaManager component implementation class
// ======================================================================

#ifndef FprimeBlvRef_InaManager_HPP
#define FprimeBlvRef_InaManager_HPP

#include "FprimeBlvRef/Components/InaManager/InaManagerComponentAc.hpp"

namespace FprimeBlvRef {

class InaManager final : public InaManagerComponentBase {
  public:
    // ----------------------------------------------------------------------
    // Component construction and destruction
    // ----------------------------------------------------------------------

    //! Construct InaManager object
    InaManager(const char* const compName  //!< The component name
    );

    //! Destroy InaManager object
    ~InaManager();
};

}  // namespace FprimeBlvRef

#endif
