#!/home/paradoxist/.python/bin/python

import time
import os
from datetime import datetime, timedelta
from dateutil import tz
from astral import LocationInfo
from astral.sun import sun

TIMEZONE = "Asia/Shanghai"
LATITUDE = 28.47
LONGITUDE = 119.92
OUTPUT_FILE = os.path.expanduser("~/.solar_status")

ICON_NOW = "󱩷"
ICON_SUNRISE = ""
ICON_NOON = ""
ICON_SUNSET = ""

def format_timedelta(td):
    """Formats a timedelta object into HH:MM:SS, ensuring non-negative output."""
    total_seconds = int(td.total_seconds())
    hours, rem = divmod(abs(total_seconds), 3600)
    mins, secs = divmod(rem, 60)
    return f"{hours:02}:{mins:02}:{secs:02}"

def get_sun_events(loc, target_date):
    """Calculates all necessary sun transition times for a given date."""
    yesterday = target_date - timedelta(days=1)
    tomorrow = target_date + timedelta(days=1)
    
    sun_yesterday = sun(loc.observer, date=yesterday, tzinfo=loc.timezone)
    sun_today = sun(loc.observer, date=target_date, tzinfo=loc.timezone)
    sun_tomorrow = sun(loc.observer, date=tomorrow, tzinfo=loc.timezone)
    
    return {
        "prev_sunset": sun_yesterday['sunset'],
        "sunrise": sun_today['sunrise'],
        "noon": sun_today['noon'],
        "sunset": sun_today['sunset'],
        "next_sunrise": sun_tomorrow['sunrise']
    }


if __name__ == "__main__":
    local_tz = tz.gettz(TIMEZONE)
    location = LocationInfo(latitude=LATITUDE, longitude=LONGITUDE, timezone=TIMEZONE)
    
    last_calculated_date = None
    sun_events = {}

    while True:
        now = datetime.now(local_tz)

        if last_calculated_date != now.date():
            last_calculated_date = now.date()
            sun_events = get_sun_events(location, last_calculated_date)

        if not sun_events:
            time.sleep(1)
            continue

        s = sun_events
        if now < s['sunrise']:
            past_event_icon, past_event_time = ICON_SUNSET, s['prev_sunset']
            future_event_icon, future_event_time = ICON_SUNRISE, s['sunrise']
        elif now < s['noon']:
            past_event_icon, past_event_time = ICON_SUNRISE, s['sunrise']
            future_event_icon, future_event_time = ICON_NOON, s['noon']
        elif now < s['sunset']:
            past_event_icon, past_event_time = ICON_NOON, s['noon']
            future_event_icon, future_event_time = ICON_SUNSET, s['sunset']
        else:
            past_event_icon, past_event_time = ICON_SUNSET, s['sunset']
            future_event_icon, future_event_time = ICON_SUNRISE, s['next_sunrise']

        time_since = format_timedelta(now - past_event_time)
        time_until = format_timedelta(future_event_time - now)
        output = f"{past_event_icon} ← {time_since} ← {ICON_NOW} → {time_until} → {future_event_icon}"

        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(output)
        os.system("pkill -SIGRTMIN+2 waybar")

        time.sleep(1 - (datetime.now().microsecond / 1_000_000.0))
