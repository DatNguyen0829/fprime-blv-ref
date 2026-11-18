#ifndef LORA_CFG_HPP
#define LORA_CFG_HPP

#include <Fw/FPrimeBasicTypes.hpp>
#include <zephyr/drivers/lora.h>

namespace LoRaConfig {

// Radio frequency used at startup.
// Must match the other LoRa endpoint.
const U32 FREQUENCY = 435750000;

// Lock runtime retuning to 435.75 MHz initially.
// SET_FREQ can only accept values in this range.
const U32 MIN_FREQUENCY = FREQUENCY;
const U32 MAX_FREQUENCY = FREQUENCY;

// Retained for configuration compatibility.
// The current LoRa component obtains operational TX/RX bandwidth
// from its F´ BANDWIDTH_TX and BANDWIDTH_RX parameters.
lora_signal_bandwidth BANDWIDTH = BW_125_KHZ;

// Requested SX1278 transmit power.
// Begin conservatively, then increase after basic link testing.
const I8 TX_POWER = 14;

// LoRa preamble length in symbols.
const U16 PREAMBLE_LENGTH = 8;

// Prepended to every transmitted packet and removed upon reception.
U8 HEADER[] = {0, 0, 0, 0};

}  // namespace LoRaConfig

#endif  // LORA_CFG_HPP