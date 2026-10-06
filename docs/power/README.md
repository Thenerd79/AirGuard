# AirGuard Power System

This section documents the power architecture of the AirGuard prototype and the planned future solar-powered version.

The current prototype is powered using a **5V USB power bank / 5V adapter** for simplicity, portability, and reliable testing.

A future version of AirGuard can replace the external power bank with a **solar-powered battery system**, enabling longer-term autonomous operation.

---

## 1. Prototype Power System

The current AirGuard prototype uses a **5V power bank** as the primary power source.

The power bank supplies the ESP32-based sensor node and the connected peripherals.

### Prototype Power Flow

```text
5V POWER BANK
      →
    ESP32
      →
 ┌────┼───────────┬───────────┬───────────┐
 ↓    ↓           ↓           ↓           ↓
DHT22 PM2.5     OLED        LoRa       Control
      Sensor                SX1278      System
                                      ↓
                                  MOSFET
                                      ↓
                                  5V Blower
```
## 2. Why We Use a Power Bank in the Prototype
The power-bank approach was selected for the prototype because it provides:
- Simple wiring
- Portable operation
- Easy testing and debugging
- Sufficient power for the ESP32 and peripherals
- No requirement for a solar charging circuit during initial development
- Easy replacement and recharging during demonstrations
This allows the prototype to focus on the main AirGuard functionality:
Sense → Decide → Act → Alert

## 3. Future Solar-Powered Version

The long-term goal is to make AirGuard capable of **solar-powered operation**.

Instead of relying on a power bank, the future system can use:

```text
Solar Panel
     |
     v
Solar Charge Controller
     |
     v
Rechargeable Battery
     |
     v
Power Regulation
     |
     v
AirGuard Electronics
     |
     v
Sensors + LoRa + Display + Purifier
```
## 4. Future Solar Architecture

A future AirGuard power system can contain:

| Component | Purpose |
|---|---|
| Solar Panel | Converts sunlight into electrical energy |
| Solar Charge Controller | Manages solar charging |
| Rechargeable Battery | Stores energy |
| Battery Protection / BMS | Provides battery protection |
| Voltage Regulation | Provides suitable voltages to electronics |
| ESP32 | Main controller |
| Sensors | Environmental monitoring |
| LoRa | Long-range communication |
| Blower | Air purification |

### Future Power Flow

```text
              SOLAR PANEL
                   |
                   v
          CHARGE CONTROLLER
                   |
                   v
          RECHARGEABLE BATTERY
                   |
                   v
           POWER REGULATION
                   |
                   v
              AIRGUARD
                   |
        +----------+----------+
        |          |          |
        v          v          v
     SENSORS      ESP32    PURIFIER
                    |
                    v
                  LoRa
                    |
                    v
             CAREGIVER SYSTEM
```
## 5. Prototype vs Future Version

| Feature | Current Prototype | Future Version |
|---|---|---|
| Primary Power | 5V Power Bank | Solar Panel |
| Energy Storage | Power Bank Battery | Rechargeable Battery |
| Charging | USB | Solar Charge Controller |
| Operation | Portable | Potentially autonomous |
| Solar Integration | Not implemented | Planned |
| Battery Management | Integrated in power bank | Dedicated BMS |
| Power Regulation | Prototype supply | Dedicated regulated power system |
## 6. Current Prototype Power Circuit

The prototype currently uses an external **5V power source**.

The power distribution is designed around the requirements of the ESP32, sensors, communication module, display, and 5V blower.

![Prototype Power System](./01_Prototype_Power_System.png)

## 7. Future Solar Power Circuit

The solar-powered version is a **future development** and is not part of the current prototype.

A suitable solar charging and battery-management stage will be added between the solar panel and the AirGuard electronics.

![Future Solar Power System](./02_Future_Solar_Power_System.png)

> **Future Concept — Not Implemented in Current Prototype**

## 8. Power Design Philosophy

The AirGuard power architecture follows three stages:

```text
POWER SOURCE → POWER MANAGEMENT → AIRGUARD LOADS

Current Prototype
POWER BANK → USB / 5V SUPPLY → AIRGUARD

Future Version
SOLAR PANEL → CHARGE CONTROLLER + BATTERY → REGULATED AIRGUARD SUPPLY
```
## 9. Future Improvements

The future power system can be improved by adding:

- Solar charging
- Rechargeable battery storage
- Battery state-of-charge monitoring
- Low-battery warning
- Automatic power-saving modes
- ESP32 deep-sleep where appropriate
- Energy-efficient LoRa communication
- Intelligent blower power control
- Solar-aware operating modes

These improvements can help AirGuard operate for longer periods without depending on a conventional external power source.
## 10. Important Prototype Note

The current AirGuard prototype **is not solar powered**.

The solar-powered architecture described in this document represents the planned future version of the system.

The current prototype uses a **5V power bank / USB power source** to validate:

- Environmental sensing
- Patient-adaptive decision logic
- Purification control
- Caregiver interface
- LoRa communication
- Online dashboard functionality

The solar subsystem will be developed as a future enhancement once the core AirGuard functionality has been validated.

---

## AirGuard Power Vision

> **Prototype today with reliable USB power.**  
> **Build toward autonomous solar-powered operation tomorrow.**

**AirGuard — Not just cleaner air. Smarter decisions for every patient.**
