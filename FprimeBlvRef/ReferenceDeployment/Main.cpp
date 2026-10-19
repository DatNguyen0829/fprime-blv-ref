#include <FprimeBlvRef/ReferenceDeployment/Top/ReferenceDeploymentTopology.hpp>
#include <Os/Os.hpp>

#include <zephyr/device.h>
#include <zephyr/drivers/uart.h>
#include <zephyr/kernel.h>

namespace {

void sendMarker(const struct device* uart, const char* text) {
    while (*text != '\0') {
        uart_poll_out(uart, *text++);
    }
}

}

int main() {
    // ** DO NOT REMOVE **//
    //
    // This sleep is necessary to allow the USB CDC ACM interface to initialize before
    // the application starts writing to it.
    k_sleep(K_MSEC(3000));

    Os::init();

    const struct device* uartDevice =
        DEVICE_DT_GET(DT_NODELABEL(cdc_acm_uart0));

    if (!device_is_ready(uartDevice)) {
        return -1;
    }

    // Wait until Python/GDS opens the virtual COM port.
    // uint32_t dtr = 0;
    // while (dtr == 0) {
    //     uart_line_ctrl_get(uartDevice, UART_LINE_CTRL_DTR, &dtr);
    //     k_sleep(K_MSEC(100));
    // }

    // sendMarker(uartDevice, "BEFORE SETUP\r\n");

    FprimeBlvRef::TopologyState state{};
    state.uartDevice = uartDevice;
    state.baudRate = 115200;

    FprimeBlvRef::setupTopology(state);

    // This happens after ZephyrUartDriver::configure().
    // sendMarker(uartDevice, "AFTER SETUP\r\n");

    FprimeBlvRef::startRateGroups();
    FprimeBlvRef::teardownTopology(state);
    return 0;
}