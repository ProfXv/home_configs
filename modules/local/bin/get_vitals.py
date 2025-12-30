#!/usr/bin/env python

import asyncio
import struct
import sqlite3
import os
from bleak import BleakScanner
from typing import Dict, Any, Optional
from pathlib import Path

# --- 蓝牙和数据常量 ---
TARGET_MAC_ADDRESS = "54:10:25:05:00:10"
HEALTH_DATA_UUID_A = "00001803-0000-1000-8000-00805f9b34fb"
HEALTH_DATA_UUID_B = "00000318-0000-1000-8000-00805f9b34fb"

def parse_packet_a(data: bytes) -> Optional[Dict[str, Any]]:
    try:
        return {
            "收缩压(mmHg)": data[0],
            "舒张压(mmHg)": data[1],
            "体温(°C)": struct.unpack('>H', data[2:4])[0] / 100.0
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

def write_data_to_db(data: Dict[str, Any]):
    # 写入数据库
    db_path = Path.home() / ".log.db"
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 准备数据映射，将中文键转换为英文键
    data_mapping = {
        "心率(BPM)": "heart_rate",
        "血氧(%)": "blood_oxygen",
        "体温(°C)": "body_temperature",
        "收缩压(mmHg)": "systolic_pressure",
        "舒张压(mmHg)": "diastolic_pressure",
        "步数": "steps",
        "电池(%)": "battery_level"
    }

    # 创建一个字典，仅包含我们想要的键
    db_data = {
        data_mapping[key]: value for key, value in data.items() if key in data_mapping
    }

    # 构建INSERT语句
    columns = ', '.join(db_data.keys())
    placeholders = ', '.join(['?'] * len(db_data))
    sql = f"INSERT INTO vitals ({columns}) VALUES ({placeholders})"

    try:
        cursor.execute(sql, tuple(db_data.values()))
        conn.commit()
    except Exception as e:
        print(f"写入数据库失败: {e}")
    finally:
        conn.close()

    # 更新Waybar
    os.system("pkill -SIGRTMIN+1 waybar")

def focused_detection_callback(device, advertisement_data):
    if device.address.upper() != TARGET_MAC_ADDRESS.upper():
        return

    service_data = advertisement_data.service_data
    if not service_data:
        return

    if HEALTH_DATA_UUID_A in service_data:
        if parsed_data := parse_packet_a(service_data[HEALTH_DATA_UUID_A]):
            write_data_to_db(parsed_data)

    if HEALTH_DATA_UUID_B in service_data:
        if parsed_data := parse_packet_b(service_data[HEALTH_DATA_UUID_B]):
            write_data_to_db(parsed_data)

async def main():
    scanner = BleakScanner(focused_detection_callback)
    try:
        await scanner.start()
        await asyncio.Event().wait()
    finally:
        await scanner.stop()


if __name__ == "__main__":
    asyncio.run(main())
