# Station G2 Base Station

High-power LoRa base station for relay/router duty.

## Specifications

| Property | Value |
|----------|-------|
| Manufacturer | B&Q Consulting / Unit Engineering |
| MCU | ESP32-S3 |
| LoRa | SX1262 + dedicated PA |
| Max TX Power | 36.5 dBm (4.46W) at 915 MHz |
| LNA | 18.5 dB gain, 1.8 dB NF |
| Power Input | 12V DC (9-19V), USB-C |
| Price | ~$109 |
| Firmware | Meshtastic (ROUTER mode) or MeshCore (simple_repeater) |

## Role in LA-Mesh

Primary relay/router nodes for rooftop and tower deployment. The integrated PA and LNA make this the best device for fixed infrastructure.

## FCC Power Budget

At default 30 dBm output + 6 dBi antenna = 36 dBm EIRP (at legal ceiling).
Higher gain antennas require reducing TX power.

## Setup Guide

See [firmware flashing guide](../guides/firmware-flashing.md) and [node deployment guide](../guides/node-deployment.md).

## Deployment Notes

- Use 12V DC input for solar deployments (avoid USB PD)
- Weatherproof enclosure required for outdoor installation
- Stock is frequently limited - order early
