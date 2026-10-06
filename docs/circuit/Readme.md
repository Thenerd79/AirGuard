# 🔌 AirGuard — Circuit & Hardware Documentation

AirGuard is a **patient-adaptive indoor air-quality monitoring and protection system** designed to continuously monitor the indoor environment and respond according to configurable patient-specific thresholds.

The system monitors:

- PM2.5
- Temperature
- Humidity

The ESP32 processes these measurements and determines the current environmental state:

- 🟢 ECO
- 🟡 WATCH
- 🔴 PROTECTION

Based on the detected state, AirGuard can control the purification blower, activate a local alert, and transmit environmental information to a caregiver through LoRa and an online MQTT dashboard.

---

## 🎯 Core Concept

**Sense → Decide → Act → Alert**

The AirGuard system follows this overall architecture:

```text
PM2.5 + Temperature + Humidity
              ↓
        ESP32 Controller
              ↓
   Patient-Specific Decision
              ↓
     ECO / WATCH / PROTECTION
              ↓
     Purification + Alert
              ↓
          LoRa Link
              ↓
       MQTT / Dashboard
              ↓
          Caregiver
```

---

# 📋 Circuit Overview

| Circuit | Purpose |
|---|---|
| **Circuit 1 – AirGuard Sensor Node** | Environmental sensing and local processing |
| **Circuit 2 – LoRa Receiver Node** | Receives environmental data wirelessly |
| **Circuit 3 – Purification & Alert Control** | Controls blower and buzzer |
| **Circuit 4 – Caregiver Control Interface** | Five-button caregiver interaction |
| **Circuit 5 – Complete AirGuard Circuit** | Complete integrated prototype |
| **Circuit 6 – Power System** | Prototype power and future solar integration |

---

# 📂 Circuit Files

```text
docs/
└── circuit/
    ├── 01_AirGuard_Sensor_Node.png
    ├── 02_LoRa_Receiver.png
    ├── 03_Purification_Alert_Control.png
    ├── 04_Caregiver_Control_Interface.png
    ├── 05_Complete_AirGuard_Circuit.png
    ├── 06_Power_System.png
    ├── wiring_diagram.png
    └── Readme.md
```

---

# 1️⃣ AirGuard Sensor Node

## Purpose

The AirGuard Sensor Node is the main sensing and processing unit.

It continuously measures:

- PM2.5 concentration
- Temperature
- Relative humidity

The ESP32 processes the sensor readings and determines the current environmental safety state.

## Components

- ESP32 DevKit V1
- DHT22 temperature/humidity sensor
- GP2Y1014AU0F PM2.5 sensor
- 0.96" SSD1306 I2C OLED
- SX1278 LoRa 433 MHz module
- Resistors
- Capacitor
- Prototype wiring

---

## DHT22 Connections

| DHT22 Pin | ESP32 |
|---|---|
| VCC | 3.3V |
| DATA | GPIO4 |
| GND | GND |

The DHT22 provides the temperature and humidity measurements used by the AirGuard decision layer.

---

## GP2Y1014AU0F Connections

| GP2Y1014AU0F | ESP32 / Supply |
|---|---|
| VCC | 5V |
| GND | GND |
| LED Control | GPIO25 |
| Analog Output | GPIO34 |

The PM2.5 sensor provides the particulate measurement used by the AirGuard decision layer.

> **Important:** GPIO34 is an input-only ADC pin. Verify the voltage-divider arrangement and the voltage reaching GPIO34 before connecting the PM2.5 analog output.

---

## SSD1306 OLED Connections

| OLED Pin | ESP32 |
|---|---|
| VCC | 3.3V |
| GND | GND |
| SDA | GPIO21 |
| SCL | GPIO22 |

The OLED displays:

- PM2.5
- Temperature
- Humidity
- AirGuard state
- Alert status
- LoRa status

---

# 2️⃣ LoRa Receiver Node

## Purpose

The LoRa Receiver provides the wireless communication link between the patient's environment and the caregiver monitoring system.

The receiver listens for AirGuard packets transmitted by the sensor node.

## Components

- ESP32 DevKit V1
- SX1278 LoRa 433 MHz module
- Optional OLED display
- USB power supply

---

## SX1278 Connections

| SX1278 Pin | ESP32 |
|---|---|
| VCC | 3.3V |
| GND | GND |
| SCK | GPIO18 |
| MISO | GPIO19 |
| MOSI | GPIO23 |
| NSS / CS | GPIO5 |
| RESET | GPIO14 |
| DIO0 | GPIO26 |

---

## Communication

```text
AirGuard Sensor
      ↓
   SX1278
      ↓
  LoRa 433 MHz
      ↓
   SX1278
      ↓
Receiver ESP32
      ↓
 MQTT / Dashboard
```

The receiver can process information such as:

```text
PM2.5: 145 µg/m³
TEMP: 31.4 °C
HUMIDITY: 68 %
STATE: WATCH
ALERT: ACTIVE
```

---

# 3️⃣ Purification & Alert Control

## Purpose

This circuit converts the AirGuard decision into a physical response.

Instead of only displaying poor air quality, AirGuard can automatically control a 5V blower according to the detected environmental state.

## Components

- 5V DC blower/fan
- Logic-level N-channel MOSFET
- Flyback diode
- 100–220 Ω gate resistor
- 10 kΩ gate pulldown resistor
- Active buzzer

---

## AirGuard Purification Logic

| AirGuard State | PM2.5 | Blower |
|---|---:|---:|
| 🟢 **ECO** | `<110 µg/m³` | 0% |
| 🟡 **WATCH** | `110–170 µg/m³` | ~60% |
| 🔴 **PROTECTION** | `>170 µg/m³` | 100% |

> **Note:** These PM2.5 values are configurable prototype thresholds and are not presented as official clinical or medical limits.

---

## Blower Control

The ESP32 must **not drive the 5V blower directly**.

The blower is controlled using a logic-level N-channel MOSFET.

```text
ESP32 PWM
    │
    ↓
100–220 Ω Gate Resistor
    │
    ↓
MOSFET Gate

+5V
 │
 ↓
5V Blower
 │
 ↓
MOSFET Drain
 │
 ↓
MOSFET Source
 │
 ↓
GND
```

A **10 kΩ pulldown resistor** should be connected between the MOSFET gate and GND.

A **flyback diode** should be connected across the DC blower to protect the switching circuit from motor back-EMF.

---

## Buzzer

The active buzzer provides a local warning when an alert condition occurs.

```text
Unsafe Environment
        ↓
    Buzzer ON
        ↓
Caregiver presses ACK
        ↓
    Buzzer OFF
        ↓
Alert remains visible
```

The ACKNOWLEDGE action only silences the audible alarm.

It does **not** mean that the environmental condition has become safe.

---

# 4️⃣ Caregiver Control Interface

## Purpose

AirGuard includes a physical interface that allows a nurse or caregiver to interact with the system without requiring a computer.

The interface contains five push buttons.

---

## Five Buttons

| Button | Function |
|---|---|
| **ACKNOWLEDGE** | Accept and silence the active alarm |
| **MENU** | Open threshold/settings menu |
| **UP** | Increase selected threshold by 5 units |
| **DOWN** | Decrease selected threshold by 5 units |
| **RESET** | Restore/reset the selected setting |

---

## ACKNOWLEDGE

The ACKNOWLEDGE button confirms that the caregiver has received the alert.

It does not clear the environmental warning.

```text
Unsafe Environment
        ↓
     Buzzer ON
        ↓
 Caregiver presses ACK
        ↓
     Buzzer OFF
        ↓
 Alert remains visible
```

This prevents the system from falsely reporting that the environmental problem has been solved.

---

# 5️⃣ Patient Threshold Configuration

The **MENU** button opens the patient configuration interface.

Example:

```text
AIRGUARD MENU

> Temperature
  Humidity
  PM2.5
  Exit
```

The caregiver can configure the environmental thresholds according to the selected patient profile.

---

## Temperature

The selected temperature threshold can be changed in steps of 5°C.

Example:

```text
UP

25°C → 30°C → 35°C
```

```text
DOWN

35°C → 30°C → 25°C
```

---

## Humidity

Humidity values can be adjusted in steps of 5%.

Example:

```text
UP

60% → 65% → 70%
```

```text
DOWN

70% → 65% → 60%
```

---

## Prototype Default Environmental Range

| Parameter | Prototype Range |
|---|---|
| Temperature | 18–34 °C |
| Humidity | 30–80 % |

Values outside the configured acceptable range can contribute to a **WATCH** environmental condition.

> These are prototype configuration values and should not be interpreted as medical limits.

---

# 6️⃣ Complete AirGuard Circuit

## Purpose

The complete circuit combines:

- Environmental sensing
- Patient-specific decision making
- OLED display
- Automatic purification
- Local alerting
- Caregiver controls
- LoRa communication

## Main Components

| Component | Function |
|---|---|
| ESP32 DevKit V1 | Main controller |
| DHT22 | Temperature and humidity sensing |
| GP2Y1014AU0F | PM2.5 sensing |
| SSD1306 OLED | Local display |
| SX1278 LoRa | Long-range communication |
| 5V blower/fan | Air purification |
| N-channel MOSFET | Blower switching |
| Flyback diode | Motor protection |
| Active buzzer | Local alert |
| 5 push buttons | Caregiver interface |
| Resistors / capacitor | Signal conditioning and protection |
| 5V power supply | Prototype power |

---

## Complete System Architecture

```text
┌─────────────────────┐
│     ENVIRONMENT     │
│ PM2.5 / Temp / RH   │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│        ESP32        │
│  Decision Layer     │
└──────────┬──────────┘
           ↓
 ┌─────────┼─────────┐
 ↓         ↓         ↓
ECO      WATCH   PROTECTION
 ↓         ↓         ↓
0%       ~60%      100%
Fan       Fan       Fan
           │
     ┌─────┼─────┐
     ↓     ↓     ↓
   OLED  Buzzer LoRa
                 ↓
          LoRa Receiver
                 ↓
           MQTT / Wi-Fi
                 ↓
        Online Dashboard
                 ↓
            Caregiver
```

---

# 🧠 AirGuard Decision Layer

The main innovation of AirGuard is not simply collecting sensor data.

The ESP32 converts environmental measurements into a **patient-specific decision**.

## Decision Process

| Input | Decision | System Response |
|---|---|---|
| Environment within configured range | ECO | Purifier OFF |
| Environment requires attention | WATCH | Purifier ~60% + Alert |
| PM2.5 exceeds protection threshold | PROTECTION | Purifier 100% + Alert |

The system continuously repeats this process:

> **SENSE → DECIDE → ACT → ALERT → MEASURE AGAIN**

This creates a closed-loop environmental protection system.

---

# 📡 Communication Architecture

AirGuard uses LoRa for communication between the sensor node and receiver.

The receiver can forward the received information through Wi-Fi and MQTT to the online dashboard.

```text
AirGuard Sensor
      ↓
   LoRa 433 MHz
      ↓
LoRa Receiver ESP32
      ↓
      Wi-Fi
      ↓
MQTT / Mosquitto
      ↓
Online Dashboard
      ↓
   Caregiver
```

---

# 📊 Data Transmitted by AirGuard

The sensor node can transmit information such as:

```text
AIRGUARD
Sensor ID
Sequence Number
PM2.5
AQI
Temperature
Humidity
System State
Alert State
Fan Level
Event
```

Example:

```text
AIRGUARD|ID=SENSOR01|SEQ=25|PM=145|AQI=120|T=31.4|H=68|STATE=WATCH|ALERT=ACTIVE|FAN=60
```

---

# 🔋 Power System

## Current Prototype

The current prototype can be powered using:

- 5V USB power bank
- 5V USB adapter

The 5V supply powers the main 5V loads.

The ESP32 provides 3.3V to suitable low-voltage modules.

```text
5V Power Source
      │
      ├────────► ESP32
      │
      ├────────► PM2.5 Sensor
      │
      └────────► 5V Blower
```

The following modules operate from the 3.3V rail:

- DHT22
- SSD1306 OLED
- SX1278 LoRa

---

# ☀️ Future Solar Power Version

A future version of AirGuard can integrate the available 6V solar panel with a suitable solar charging and battery-management system.

```text
6V Solar Panel
      ↓
Solar Charging Controller
      ↓
Li-ion Battery + BMS
      ↓
Voltage Regulation
      ↓
AirGuard System
```

> The solar subsystem is considered a future power-optimization stage unless physically integrated and tested in the prototype.

---

# 📌 ESP32 Pin Summary

| Function | GPIO |
|---|---:|
| DHT22 Data | GPIO4 |
| PM2.5 LED Control | GPIO25 |
| PM2.5 Analog Output | GPIO34 |
| OLED SDA | GPIO21 |
| OLED SCL | GPIO22 |
| LoRa SCK | GPIO18 |
| LoRa MISO | GPIO19 |
| LoRa MOSI | GPIO23 |
| LoRa NSS / CS | GPIO5 |
| LoRa RESET | GPIO14 |
| LoRa DIO0 | GPIO26 |

> Final GPIO assignments for the blower, buzzer and five caregiver buttons should match the final firmware and physical prototype wiring.

---

# ⚠️ Important Hardware Notes

- All modules must share a common GND.
- The SX1278 must be powered from a suitable 3.3V supply.
- Do not drive the 5V blower directly from an ESP32 GPIO.
- Use a suitable logic-level N-channel MOSFET for blower switching.
- Use a flyback diode across the DC blower.
- The PM2.5 sensor requires the appropriate LED drive and filtering components for the specific sensor/module implementation.
- Verify the voltage reaching ESP32 ADC GPIO34 before connecting the PM2.5 analog output.
- Keep the LoRa antenna properly connected before transmission.
- Do not operate a high-power LoRa module without an appropriate antenna connection.
- Ensure the 5V supply can provide sufficient current for the blower.
- Test each subsystem individually before connecting the complete prototype.
- Keep high-current blower wiring separated from sensitive sensor wiring where practical.
- The thresholds shown in this documentation are **prototype-configurable values and are not medical or clinical limits**.

---

# 🔧 Hardware Design Philosophy

AirGuard is designed around five functional layers:

| Layer | Function |
|---|---|
| **Sense** | Measure PM2.5, temperature and humidity |
| **Decide** | Compare measurements with patient-specific thresholds |
| **Act** | Control purification according to the environmental state |
| **Alert** | Notify the caregiver locally and remotely |
| **Monitor** | Display and transmit the environmental condition |

This allows the prototype to move beyond passive air-quality measurement toward a **patient-adaptive environmental response system**.


🎯 Problem-to-Hardware Mapping
| Problem | AirGuard Hardware / Feature |
|---|---|
| Indoor PM2.5 is difficult to monitor continuously | GP2Y1014 PM2.5 sensor |
| Environmental conditions vary between patients | Patient-specific thresholds |
| Monitoring alone does not cause action | ESP32 decision layer |
| Air pollution can require immediate response | Blower + MOSFET |
| Caregiver may not notice an unsafe condition | Buzzer + LoRa + dashboard alert |
| Manual checking is inconvenient | Continuous monitoring |
| Patient may not be able to operate complex systems | Simple 5-button interface |
| Different patients have different acceptable conditions | Configurable temperature/humidity/PM thresholds |
| Wi-Fi may not be available near the patient | LoRa communication |
| Caregiver needs remote visibility | MQTT + online dashboard |

# 🎯 AirGuard

> **Not just cleaner air. Smarter decisions for every patient.**
