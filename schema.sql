-- Run in Supabase SQL editor
create table patients (
  id uuid primary key default gen_random_uuid(),
  patient_id text unique not null,
  name text not null,
  assigned_caregiver text,
  device_id text unique
);
create table devices (
  id uuid primary key default gen_random_uuid(),
  device_id text unique not null,
  patient_id text not null references patients(patient_id),
  status text not null default 'OFFLINE' check (status in ('ONLINE','OFFLINE')),
  battery real, rssi int, snr real,
  last_seen timestamptz,
  firmware_version text default 'v1.0.0'
);
create table sensor_readings (
  id uuid primary key default gen_random_uuid(),
  patient_id text not null references patients(patient_id),
  device_id text not null references devices(device_id),
  timestamp timestamptz not null,
  pm25 real not null, temperature real not null, humidity real not null,
  battery real, mode text, rssi int, snr real,
  sequence_number int not null,
  unique (device_id, sequence_number)
);
create index on sensor_readings (patient_id, timestamp desc);
create table alerts (
  id uuid primary key default gen_random_uuid(),
  patient_id text not null references patients(patient_id),
  timestamp timestamptz not null,
  type text not null,
  severity text not null check (severity in ('CRITICAL','WATCH')),
  metric text, trigger_value real, threshold real, unit text,
  status text not null default 'TRIGGERED' check (status in ('TRIGGERED','ACKNOWLEDGED','RESOLVED')),
  acknowledged_at timestamptz, resolved_at timestamptz
);
create index on alerts (patient_id, status);
create table environmental_events (
  id uuid primary key default gen_random_uuid(),
  patient_id text not null references patients(patient_id),
  timestamp timestamptz not null,
  event_type text not null, description text, severity text
);
create index on environmental_events (patient_id, timestamp desc);
create table thresholds (
  id int primary key default 1 check (id = 1),
  pm25_warn real default 35, pm25_crit real default 75,
  temp_min real default 18, temp_max real default 30,
  hum_min real default 30, hum_max real default 70
);
insert into thresholds (id) values (1);
-- users: use Supabase Auth (auth.users) plus a profile row
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text, role text check (role in ('doctor','nurse','admin'))
);
-- Backend uses the service key (bypasses RLS). Lock tables for everyone else:
alter table patients enable row level security;
alter table devices enable row level security;
alter table sensor_readings enable row level security;
alter table alerts enable row level security;
alter table environmental_events enable row level security;
alter table thresholds enable row level security;
alter table profiles enable row level security;
-- Seed demo patients + devices
insert into patients (patient_id,name,assigned_caregiver,device_id) values
('P001','Rahul Sharma','Nurse A. Iyer','AG-P001'),('P002','Ananya Patel','Nurse K. Rao','AG-P002'),
('P003','Priya Mehta','Dr. Mehta','AG-P003'),('P004','Arjun Nair','Nurse A. Iyer','AG-P004'),
('P005','Meera Joshi','Nurse K. Rao','AG-P005'),('P006','Vikram Singh','Dr. Mehta','AG-P006'),
('P007','Sana Khan','Nurse P. Das','AG-P007'),('P008','Daniel Thomas','Nurse P. Das','AG-P008');
insert into devices (device_id,patient_id) select device_id,patient_id from patients;

-- Emergency contacts (looked up by patient_id; never sent by the device)
create table if not exists patient_contacts (
  id uuid primary key default gen_random_uuid(),
  patient_id text not null references patients(patient_id),
  contact_type text not null check (contact_type in ('NURSE','DOCTOR','SECONDARY')),
  name text not null,
  phone text not null,
  unique (patient_id, contact_type)
);
alter table patient_contacts enable row level security;
-- DEMO DATA ONLY: fake names and non-routable numbers. Replace with real contacts via PUT /api/patients/:pid/contacts/:type
insert into patient_contacts (patient_id, contact_type, name, phone)
select p.patient_id, c.t, 'DEMO ' || initcap(c.t) || ' (' || p.patient_id || ')', '+910000000' || right(p.patient_id, 2) || c.k
from patients p cross join (values ('NURSE', 1), ('DOCTOR', 2), ('SECONDARY', 3)) as c(t, k)
on conflict (patient_id, contact_type) do nothing;
