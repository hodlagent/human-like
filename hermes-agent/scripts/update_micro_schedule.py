#!/usr/bin/env python3
"""Reusable script to update micro-trigger cron schedule.
Usage: python3 update_micro_schedule.py <interval>
Example: python3 update_micro_schedule.py "every 12m"

Uses cron.jobs API (list_jobs, update_job, parse_schedule) — NOT direct JSON editing.
"""

import sys, os, json
from datetime import datetime, timezone

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from cron.jobs import list_jobs, update_job, parse_schedule

if len(sys.argv) < 2:
    print("Usage: update_micro_schedule.py <interval>  (e.g. 'every 12m')")
    sys.exit(1)

new_schedule_str = sys.argv[1]
micro_cron_id = "31b39f8f3c88"
state_path = os.path.expanduser("~/.hermes/human-like/thinking-state.json")

# --- Step 1: Update cron via cron.jobs API ---
new_schedule = parse_schedule(new_schedule_str)
job_found = False
for j in list_jobs():
    if j.get('id', '').startswith(micro_cron_id):
        update_job(j['id'], updates={"schedule": new_schedule})
        print(f"[CRON] Updated {j['id']} schedule -> {new_schedule_str}")
        job_found = True
        break
if not job_found:
    print(f"[CRON] WARNING: job {micro_cron_id} not found")

# --- Step 2: Update thinking-state.json ---
try:
    with open(state_path, 'r') as f:
        state = json.load(f)
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M")
    state["lastMicroRun"] = now_iso
    state["lastMicroCronUpdated"] = now_iso
    state["suggestedInterval"] = new_schedule_str
    state["microHeartbeatEnabled"] = True
    with open(state_path, 'w') as f:
        json.dump(state, f, indent=2, ensure_ascii=False)
    print(f"[STATE] Updated thinking-state.json: lastMicroRun={now_iso}, interval={new_schedule_str}")
except Exception as e:
    print(f"[STATE] Error: {e}")

print("Done.")
