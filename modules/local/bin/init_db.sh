#!/usr/bin/env sh

# 检查数据库是否已存在
cd ~
if [ -f ".log.db" ]; then
    echo "日志数据库 .log.db 已存在。"
    read -p "是否要重新初始化数据库？这将删除所有现有数据！(y/N): " -r
    echo
    if ! [[ "$REPLY" =~ ^[Yy]$ ]]; then
        echo "操作已取消。"
        exit 0
    fi
    rm .log.db
    echo "已删除旧数据库。"
fi

echo "正在创建日志数据库 .log.db..."

# 创建数据库并建立表结构
sqlite3 .log.db "CREATE TABLE socket (id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT NOT NULL, key TEXT NOT NULL, value TEXT NOT NULL);"
sqlite3 .log.db "CREATE TABLE focus (id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT NOT NULL, type TEXT NOT NULL, workspace TEXT NOT NULL, class TEXT NOT NULL, text TEXT NOT NULL);"

echo "数据库初始化完成！"
echo "已创建表："
echo "- socket (记录桌面界面操作事件)"
echo "- focus (记录划取文字操作和划取的文字内容)"
