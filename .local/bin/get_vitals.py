#!/home/paradoxist/.python/bin/python

import asyncio
import struct
from bleak import BleakScanner
from typing import Dict, Any, Optional
from pathlib import Path

# --- 文件系统和路径设置 ---
HOME_DIR = Path.home()
DATA_DIR_NAME = ".carbon_vitals"
DATA_DIR = HOME_DIR / DATA_DIR_NAME

# --- 蓝牙和数据常量 ---
TARGET_MAC_ADDRESS = "54:10:25:05:00:10"
HEALTH_DATA_UUID_A = "00001803-0000-1000-8000-00805f9b34fb"
HEALTH_DATA_UUID_B = "00000318-0000-1000-8000-00805f9b34fb"

# --- 将内部键名映射到文件名 ---
FILENAME_MAP = {
    "心率(BPM)": "heart_rate",
    "血氧(%)": "blood_oxygen",
    "体温(°C)": "body_temperature",
    "收缩压(mmHg)": "systolic_pressure",
    "舒张压(mmHg)": "diastolic_pressure",
    "步数": "steps",
    "电池(%)": "battery_level"
}

def parse_packet_a(data: bytes) -> Optional[Dict[str, Any]]:
    try:
        return {
            "收缩压(mmHg)": data[0],
            "舒张压(mmHg)": data[1],
            "体温(°C)": f"{struct.unpack('>H', data[2:4])[0] / 100.0:.2f}"
        }
    except Exception:
        return None

def parse_packet_b(data: bytes) -> Optional[Dict[str, Any]]:
    try:
        return {
            "心率(BPM)": struct.unpack('<H', data[6:8])[0],
            "血氧(%)": data[8],
            "步数": struct.unpack('>H', data[15:17])[0],
            "电池(%)": data[2]
        }
    except Exception:
        return None

def write_data_to_files(data: Dict[str, Any]):
    for key, value in data.items():
        if filename := FILENAME_MAP.get(key):
            file_path = DATA_DIR / filename
            file_path.write_text(str(value))
    os.system("pkill -SIGRTMIN+1 waybar")

def focused_detection_callback(device, advertisement_data):
    if device.address.upper() != TARGET_MAC_ADDRESS.upper():
        return

    service_data = advertisement_data.service_data
    if not service_data:
        return

    if HEALTH_DATA_UUID_A in service_data:
        if parsed_data := parse_packet_a(service_data[HEALTH_DATA_UUID_A]):
            write_data_to_files(parsed_data)

    if HEALTH_DATA_UUID_B in service_data:
        if parsed_data := parse_packet_b(service_data[HEALTH_DATA_UUID_B]):
            write_data_to_files(parsed_data)

async def main():
    DATA_DIR.mkdir(exist_ok=True)
    scanner = BleakScanner(focused_detection_callback)
    try:
        await scanner.start()
        await asyncio.Event().wait()
    finally:
        await scanner.stop()


if __name__ == "__main__":
    asyncio.run(main())
