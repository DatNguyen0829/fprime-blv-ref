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

  private:
    // ----------------------------------------------------------------------
    // Handler implementations for typed input ports
    // ----------------------------------------------------------------------

    //! Handler implementation for run
    //!
    //! Input port for running tick scheduler
    void run_handler(FwIndexType portNum,  //!< The port number
                     U32 context           //!< The call order
                     ) override;
    
    // ----------------------------------------------------------------------
    // Helper functions
    // ----------------------------------------------------------------------

    // Function to read the 16-bit value stored in a register at a specified address
    bool readRegister16(U8 sensorAddress, U8 registerAddress, U16& value);

    // Functions to convert raw data from registers to usable values
    F32 convertCurrentRawToAmps(U16 raw) const;
    F32 convertVoltageRawToVolts(U16 raw) const;
    F32 convertPowerRawToWatts(U16 raw) const;

  private:
    // ----------------------------------------------------------------------
    // Private member variables
    // ----------------------------------------------------------------------   
    static constexpr U8 INA_ADDR = 0x40;  // Address of on board INA260 sensor
      
    static constexpr U8 INA260_REG_CURRENT = 0x01; // current register address
    static constexpr U8 INA260_REG_VOLTAGE = 0x02; // voltage register address
    static constexpr U8 INA260_REG_POWER = 0x03; // power register address
    
    static constexpr F32 INA260_CURRENT_LSB = 0.00125F; // INA260 current LSB is 1.25mA
    static constexpr F32 INA260_VOLTAGE_LSB = 0.00125F; // INA260 voltage LSB is 1.25mV
    static constexpr F32 INA260_POWER_LSB = 0.010F; // INA260 power LSB is 10mW
    
    U16 rawCurrent;
    U16 rawVoltage;
    U16 rawPower;

    PowerReading systemPowerReadings;

};

}  // namespace FprimeBlvRef

#endif
