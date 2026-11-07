module FprimeBlvRef {
    @ Manager that interfaces with on board INA260 voltage, current, and power sensor
    passive component InaManager {

        ###############################################################################
        #                               PORTS                                         #
        ###############################################################################

        @ Input port for running tick scheduler
        sync input port run: Svc.Sched

        @ Out port to call ZephyrI2cDriver for write AND read operations
        output port inaWriteRead: Drv.I2cWriteRead

        ###############################################################################
        #                               TELEMETRY                                     #
        ###############################################################################

        @ Telemetry channel for system voltage, current, power readings
        telemetry  systemPowerReadings: PowerReading

        ###############################################################################
        #                                EVENT                                        #
        ###############################################################################

        @ Event for failed INA260 read
        event I2cReadFailed(register_address: U8, status: I32) severity warning high \
            format "INA260 I2C read failed for register 0x{} with status {}"

        ###############################################################################
        # Standard AC Ports: Required for Channels, Events, Commands, and Parameters  #
        ###############################################################################
        @ Port for requesting the current time
        time get port timeCaller

        @ Enables command handling
        import Fw.Command

        @ Enables event handling
        import Fw.Event

        @ Enables telemetry channels handling
        import Fw.Channel

        @ Port to return the value of a parameter
        param get port prmGetOut

        @Port to set the value of a parameter
        param set port prmSetOut

    }
}