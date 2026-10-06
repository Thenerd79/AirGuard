# AirGuard backend

Node 18+ / Express. Runs in-memory with zero setup, or on Supabase.

    npm install
    cp .env.example .env     # set GATEWAY_API_KEY; add Supabase keys to use a database
    npm start                # http://localhost:4000

## Supabase
1. Create a project, run `schema.sql` in the SQL editor (also seeds P001-P008 + devices).
2. Put `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` (service_role key, server only) in `.env`.

## Endpoints
| Method | Path | Notes |
|---|---|---|
| POST | /api/readings | Gateway JSON contract, header `x-api-key` |
| GET | /api/patients, /api/patients/:pid | patient + device + latest reading + status |
| GET | /api/patients/:pid/readings?range=24h\|7d\|30d | chart data |
| GET | /api/patients/:pid/events | timeline |
| GET | /api/patients/:pid/contacts | NURSE / DOCTOR / SECONDARY contacts (name, phone) |
| PUT | /api/patients/:pid/contacts/:type | body `{"name","phone"}`; creates or updates that contact |
| GET | /api/devices, /api/alerts?status=, /api/summary | |
| POST | /api/alerts/:id/acknowledge, /resolve | resolve only if acknowledged and value is back below threshold (409 otherwise) |
| GET/PUT | /api/thresholds | |
| GET | /api/health | |

## Test it
    curl -X POST localhost:4000/api/readings -H "content-type: application/json" -H "x-api-key: change-me" \
     -d '{"patient_id":"P001","device_id":"AG-P001","sequence_number":1,"timestamp":"'$(date -u +%FT%TZ)'","pm25":86,"temperature":27.2,"humidity":72,"battery":78,"mode":"PROTECTION","rssi":-71,"snr":8.4}'
    curl localhost:4000/api/alerts

Sending the same `sequence_number` twice is ignored (LoRa retries). A device silent for `OFFLINE_AFTER_MS` is marked OFFLINE with an event.

## Critical notifications
Doctor and nurse recipients use the existing `patient_contacts` configuration (`DOCTOR` and `NURSE`); configure them through `PUT /api/patients/:pid/contacts/:type`. After User login, the frontend updates `SECONDARY` through that same endpoint using the emergency number entered by the patient. Indian 10-digit mobile numbers and `+91` formats are normalized to E.164. Seeded contacts are demo-only and are skipped until replaced with valid numbers.

Each new critical episode creates the existing alert record and the backend notification service attempts both SMS and WhatsApp for the configured doctor, nurse, and patient emergency contact. Repeated critical readings do not resend while the alert is open. When the reading returns to `STABLE`, the critical alert is resolved and a later critical episode can notify again. The message includes patient ID, PM2.5, temperature, humidity and the required action. Each recipient/channel is attempted independently; failures are logged and do not stop the other deliveries.

With Twilio variables blank, the service runs in explicit mock mode and logs each attempted notification without sending it. Real delivery requires all four server-only environment variables: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_SMS_FROM`, and `TWILIO_WHATSAPP_FROM`. For WhatsApp, `TWILIO_WHATSAPP_FROM` can be the configured sandbox sender (for example `whatsapp:+14155238886`); each recipient must first join the sandbox. Never place these credentials in the frontend.

For the in-memory demo store, configure the hospital Doctor and Nurse contacts after each backend restart using the existing endpoint, for example:

    curl -X PUT http://localhost:4000/api/patients/P001/contacts/DOCTOR -H "content-type: application/json" -d "{\"name\":\"Doctor\",\"phone\":\"9876543210\"}"
    curl -X PUT http://localhost:4000/api/patients/P001/contacts/NURSE -H "content-type: application/json" -d "{\"name\":\"Nurse\",\"phone\":\"9876543211\"}"

Replace these example numbers with consented recipient numbers. Do not use placeholder numbers with live Twilio credentials.

## MQTT sensor input
The backend connects to `mqtt://localhost:1883` and subscribes to `airguard/P001/readings`. It accepts JSON containing `patient_id`, `pm25`, `temperature`, and `humidity`, then sends the reading through the same validation and storage path as `POST /api/readings`. For MQTT messages it supplies `device_id` (`AG-P001`), the receive timestamp, and a unique sequence number. The backend derives the stored mode from the sensor values; the incoming `state` field is not part of the reading model.

## Tests and simulator
    npm test                                              # starts the real server on a random port, in-memory store
    npm run simulate -- --scenario demo --patient P001    # normal -> watch -> critical -> recovery
    npm run simulate -- --scenario critical --count 5 --interval 1 --dup

`tools/simulate.js` is a separate dev tool: it only POSTs the standard payload to `/api/readings`. Options: `--url` (default http://localhost:4000), `--api-key` (default env GATEWAY_API_KEY or change-me), `--start-seq`, `--dup`.

## Frontend roles and acknowledgement
The React demo offers User, Hospital, Doctor and Nurse roles. User name, phone and emergency contact are held in the current frontend session; there is no account/authentication service or patient-profile persistence. Hospital, Doctor and Nurse can see the existing multi-patient view and acknowledge active alerts. This is demo UI role gating, not server-side authentication; do not expose this local prototype as a secured production system.
