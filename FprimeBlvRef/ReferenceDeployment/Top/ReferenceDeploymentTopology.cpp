// ======================================================================
// \title  ReferenceDeploymentTopology.cpp
// \brief cpp file containing the topology instantiation code
//
// ======================================================================
// Provides access to autocoded functions
#include <FprimeBlvRef/ReferenceDeployment/Top/ReferenceDeploymentTopologyAc.hpp>
// Note: Uncomment when using Svc:TlmPacketizer
//#include <FprimeBlvRef/ReferenceDeployment/Top/ReferenceDeploymentPacketsAc.hpp>

// Necessary project-specified types
#include <Fw/Types/MallocAllocator.hpp>
#include <Fw/Types/Assert.hpp>
#include <zephyr/drivers/uart.h>
#include <zephyr/drivers/gpio.h>

// Public functions for use in main program are namespaced with deployment module FprimeBlvRef
// This is also the namespace where the topology components are instantiated by FPP.
namespace FprimeBlvRef {

// Instantiate a malloc allocator for cmdSeq buffer allocation
Fw::MallocAllocator mallocator;

// Rate group timing: base clock interval and divisors are coupled to rate group names
static constexpr U32 BASE_RATE_PERIOD_MS = 100; // 100ms period
Svc::RateGroupDriver::DividerSet rateGroupDivisorsSet{{{1, 0}, {2, 0}, {4, 0}}};
// Divisors: 10Hz, 5Hz, 2.5Hz

// Context tokens for rate group members (unused, set to zero)
Svc::ActiveRateGroup::ContextArray rateGroup_1HzContext(0);
Svc::ActiveRateGroup::ContextArray rateGroup_0_5HzContext(0);
Svc::ActiveRateGroup::ContextArray rateGroup_0_25HzContext(0);

// Getting gpio pins map to proper device tree labels
static const gpio_dt_spec statusLedPin = GPIO_DT_SPEC_GET(DT_NODELABEL(status_led), gpios);

/**
 * \brief: to debug
 */
void debugMarker(const struct device* uart, const char* text) {
    if (uart == nullptr) {
        return;
    }

    while (*text != '\0') {
        uart_poll_out(uart, *text++);
    }

    uart_poll_out(uart, '\r');
    uart_poll_out(uart, '\n');
}

/**
 * \brief configure and open a single subsystem power-enable output
 *
 * Configures the pin as an output initialized inactive/high, then hands it to the
 * ZephyrGpioDriver instance. A failed GPIO does not abort deployment startup; it is
 * only reported so the remaining outputs can still be brought up.
 */
static bool configureGpioOutput(Zephyr::ZephyrGpioDriver& driver, const gpio_dt_spec& pin) {
    if (!gpio_is_ready_dt(&pin)) {
        return false;
    }

    if (gpio_pin_configure_dt(&pin, GPIO_OUTPUT_INACTIVE) != 0) {
        return false;
    }

    if (driver.open(pin, Zephyr::ZephyrGpioDriver::OUT) != Os::File::Status::OP_OK) {
        return false;
    }

    return gpio_pin_set_dt(&pin, 0) == 0;
}

/**
 * \brief configure/setup components in project-specific way
 *
 * This is a *helper* function which configures/sets up each component requiring project specific input. This includes
 * allocating resources, passing-in arguments, etc. This function may be inlined into the topology setup function if
 * desired, but is extracted here for clarity.
 */
void configureTopology() {
    // Rate group driver needs a divisor list
    rateGroupDriver.configure(rateGroupDivisorsSet);

    // Rate groups require context arrays.
    rateGroup_1Hz.configure(rateGroup_1HzContext);
    rateGroup_0_5Hz.configure(rateGroup_0_5HzContext);
    rateGroup_0_25Hz.configure(rateGroup_0_25HzContext);

    // Command sequencer needs to allocate memory to hold contents of command sequences
    cmdSeq.allocateBuffer(0, mallocator, 5 * 1024);

    // PrmDb file name must be supplied by the using topology
    FileHandling::prmDb.configure("PrmDb.dat");

    // Configure gpio output pins
    configureGpioOutput(statusLedDriver, statusLedPin);
}

void setupTopology(const TopologyState& state) {
    // debugMarker(state.uartDevice, "S0 ENTER");

    initComponents(state);
    // debugMarker(state.uartDevice, "S1 INIT");

    setBaseIds();
    // debugMarker(state.uartDevice, "S2 IDS");

    connectComponents();
    // debugMarker(state.uartDevice, "S3 CONNECT");

    regCommands();
    // debugMarker(state.uartDevice, "S4 COMMANDS");

    configComponents(state);
    // debugMarker(state.uartDevice, "S5 AUTO CONFIG");

    configureTopology();
    // debugMarker(state.uartDevice, "S6 MANUAL CONFIG");

    readParameters();
    // debugMarker(state.uartDevice, "S7 READ PARAMS");

    loadParameters();
    // debugMarker(state.uartDevice, "S8 LOAD PARAMS");

    startTasks(state);
    // debugMarker(state.uartDevice, "S9 START TASKS");

    FW_ASSERT(state.uartDevice != nullptr);

    comDriver.configure(state.uartDevice, state.baudRate);
    // debugMarker(state.uartDevice, "S10 UART CONFIG");
}

void startRateGroups() {
    timer.configure(BASE_RATE_PERIOD_MS);
    timer.start();

    while(true){
        timer.cycle();
    }
}

void stopRateGroups() {
    timer.stop();
}

void teardownTopology(const TopologyState& state) {
    timer.stop(); 

    // Autocoded (active component) task clean-up. Functions provided by topology autocoder.
    stopTasks(state);
    freeThreads(state);

    // Resource deallocation
    cmdSeq.deallocateBuffer(mallocator);

    tearDownComponents(state);
    deinitComponents(state);
}
};  // namespace FprimeBlvRef
