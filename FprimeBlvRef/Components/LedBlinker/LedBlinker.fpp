module FprimeBlvRef {
    @ Blinking test for zephyr implementation
    active component LedBlinker {

        ###############################################################################
        #                               COMMANDS                                      #
        ###############################################################################

        async command SET_LED (
            led_state: Fw.On @< Indicates whether the led should be on or off
        )

        ###############################################################################
        #                                EVENTS                                       #
        ###############################################################################
        event LED_STATE(ledState: Fw.On) \
            severity activity high \
            format "LED IS {}!"

        ###############################################################################
        #                                 PORTS                                       #
        ###############################################################################

        @ output port to call ZephyrGpioDriver
        output port statusLedSet: Drv.GpioWrite

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