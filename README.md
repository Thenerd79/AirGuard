# 🌿 Air-Guard — Patient-Adaptive Indoor Air Quality Monitoring & Purification System

Air-Guard is an ESP32-based **patient-adaptive indoor air quality monitoring and purification system** designed for home environments.

The system continuously monitors:

- 🌫️ PM2.5 / particulate concentration
- 🌡️ Temperature
- 💧 Relative humidity

The sensor node performs **edge processing** to classify the indoor environment according to configurable caregiver-defined thresholds.

Environmental data is transmitted wirelessly using **LoRa (SX1278)** to a remote receiver node, allowing environmental conditions to be monitored without a direct connection between the sensor node and the caregiver system.

The planned purification subsystem uses a **5V DC blower controlled through a MOSFET**, allowing Air-Guard to automatically respond to elevated particulate levels.

---

# 🎯 Project Objective

Air-Guard aims to provide a low-cost, portable and patient-adaptive solution for monitoring indoor environmental conditions.

Unlike a conventional environmental monitor, Air-Guard separates:

1. **Environmental sensing**
2. **Patient-specific threshold evaluation**
3. **Local environmental display**
4. **Long-range wireless communication**
5. **Automatic purification control**

This allows caregivers to configure environmental thresholds according to the requirements of the monitored patient.

---

# 🔗 Quick Links

| Resource | Link |
|----------|------|
| 🔌 Complete Circuit | [Circuit Designer](https://app.cirkitdesigner.com/project/72f4accd-b4bb-4687-a699-8c45e1bc3c0c) |
| 📦 Bill of Materials | [Notion BOM](https://viridian-path-34d.notion.site/Aakashvani-3adc78e01c3d80f9a7f2f4c04ff93067?source=copy_link) |
| 🔄 Firmware Flowchart | [Eraser.io Flowchart](https://app.eraser.io/workspace/saOYZ587aT2T2XnHdCFs?origin=share) |
| 🔋 Power Analysis | [Power Analysis](https://viridian-path-34d.notion.site/Battery-Life-Estimation-ESP32-LoRa-Sensor-Node-3aec78e01c3d80c3be53f0dbc6ac5a15?source=copy_link) |

> Some documentation links may be updated as the prototype hardware and firmware evolve.

---

# 🧠 System Architecture

Air-Guard consists of two primary nodes:

### 🟢 Sensor Node

The sensor node contains:

- ESP32 DevKit
- DHT22
- GP2Y1014V1919 PM2.5 sensor
- I2C OLED display
- SX1278 LoRa module

The sensor node:

1. Reads environmental parameters.
2. Processes sensor data locally.
3. Calculates an estimated AQI.
4. Compares readings against configured thresholds.
5. Determines the current environmental state.
6. Displays the result on the OLED.
7. Transmits environmental data through LoRa.

The sensor node is designed to operate independently from a laptop during deployment.

---

### 🔵 Receiver Node

The receiver node contains:

- ESP32
- SX1278 LoRa module

Its primary purpose is to receive environmental packets from the sensor node and provide the environmental result to the caregiver-side monitoring system.

The receiver currently outputs:

- PM2.5
- Estimated AQI
- Temperature
- Humidity
- Environmental state
- Threshold condition

---

# ⚙️ How the System Works

```text
                    ┌─────────────────────┐
                    │      DHT22          │
                    │ Temp + Humidity     │
                    └──────────┬──────────┘
                               │
                               │
┌─────────────────┐            ▼
│   GP2Y1014      │──────► ┌───────────────┐
│    PM2.5        │        │     ESP32     │
└─────────────────┘        │ Sensor Node   │
                           └───────┬───────┘
                                   │
                         ┌─────────┴─────────┐
                         │                   │
                         ▼                   ▼
                  ┌────────────┐      ┌────────────┐
                  │ I2C OLED   │      │  SX1278    │
                  │ Local Data │      │   LoRa     │
                  └────────────┘      └──────┬─────┘
                                             │
                                             │ LoRa
                                             │
                                             ▼
                                      ┌────────────┐
                                      │  SX1278    │
                                      │ Receiver   │
                                      └──────┬─────┘
                                             │
                                             ▼
                                      ┌────────────┐
                                      │   ESP32    │
                                      │ Receiver   │
                                      └──────┬─────┘
                                             │
                                             ▼
                                    Caregiver Monitor
