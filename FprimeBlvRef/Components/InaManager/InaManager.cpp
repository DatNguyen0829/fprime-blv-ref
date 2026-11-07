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

InaManager ::InaManager(const char* const compName) : 
    InaManagerComponentBase(compName),
    rawCurrent(0),
    rawVoltage(0),
    rawPower(0) 
{}

InaManager ::~InaManager() {}

// ----------------------------------------------------------------------
// Handler implementations for typed input ports
// ----------------------------------------------------------------------

void InaManager ::run_handler(FwIndexType portNum, U32 context) {

    // Set correpsonding values for each read
    if(this->readRegister16(this->INA_ADDR, this->INA260_REG_CURRENT, this->rawCurrent)) // Read current values
    {
        this->systemPowerReadings.set_current(this->convertCurrentRawToAmps(this->rawCurrent));
    }

    if(this->readRegister16(this->INA_ADDR, this->INA260_REG_VOLTAGE, this->rawVoltage))// Read current values
    {
        this->systemPowerReadings.set_voltage(this->convertVoltageRawToVolts(this->rawVoltage));
    }

    if(this->readRegister16(this->INA_ADDR, this->INA260_REG_POWER, this->rawPower)) // Read current values
    {
        this->systemPowerReadings.set_power(this->convertPowerRawToWatts(this->rawPower));
    }

    // Write to telemetry channel
    this->tlmWrite_systemPowerReadings(this->systemPowerReadings);
    
}

// ----------------------------------------------------------------------
// Helper functions
// ----------------------------------------------------------------------
bool InaManager :: readRegister16(U8 sensorAddress, U8 registerAddress, U16& value){

    U8 writeData[1] = {registerAddress};
    U8 readData[2] = {0, 0};

    Fw::Buffer writeBuffer(writeData, sizeof(writeData));
    Fw::Buffer readBuffer(readData, sizeof(readData));

    Drv::I2cStatus status = this->inaWriteRead_out(0, sensorAddress, writeBuffer, readBuffer);

    if (status != Drv::I2cStatus::I2C_OK){
        this->log_WARNING_HI_I2cReadFailed(registerAddress, static_cast<I32>(status.e));
        return false;
    }

    value = (static_cast<U16>(readData[0] << 8))
             | (static_cast<U16>(readData[1])); // Assemble the MSB and LSB into a 16 bit value 
    
    return true;
}

F32 InaManager :: convertCurrentRawToAmps(U16 raw) const{
    return static_cast<I16>(raw) * this->INA260_CURRENT_LSB;
    
}

F32 InaManager :: convertVoltageRawToVolts(U16 raw) const {
    return static_cast<I16>(raw) * this->INA260_VOLTAGE_LSB;
}

F32 InaManager :: convertPowerRawToWatts(U16 raw) const {
    return static_cast<I16>(raw) * this->INA260_POWER_LSB;
}

}  // namespace FprimeBlvRef
