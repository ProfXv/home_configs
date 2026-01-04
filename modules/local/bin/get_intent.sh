#!/bin/sh

N_COUNT=1

while [ $# -gt 0 ]; do
    case $1 in
        -t) T_TIME="$2"; shift 2 ;;
        -s) SEARCH_STR="$2"; shift 2 ;;
        -n) N_COUNT="$2"; shift 2 ;;
        --start) START_TIME="$2"; shift 2 ;;
        --end) END_TIME="$2"; shift 2 ;;
        *) break ;;
    esac
done

DB="$HOME/.log.db"

if [ -z "$T_TIME" ] && [ -z "$SEARCH_STR" ] && [ -z "$START_TIME" ] && [ -z "$END_TIME" ] && [ "$N_COUNT" = "1" ]; then
    sqlite3 "$DB" "SELECT COUNT(*) FROM intention;"
    exit 0
fi

WHERE=""
if [ -n "$SEARCH_STR" ]; then
    WHERE="$WHERE (s1.content LIKE '%$SEARCH_STR%' OR s2.content LIKE '%$SEARCH_STR%') AND"
fi

if [ -n "$START_TIME" ] && [ -n "$END_TIME" ]; then
    WHERE="$WHERE s1.time_start BETWEEN '$START_TIME' AND '$END_TIME' AND"
fi

WHERE="${WHERE% AND}"

ORDER=""
if [ -n "$T_TIME" ]; then
    ORDER="ORDER BY ABS(strftime('%s', s1.time_start) - strftime('%s', '$T_TIME'))"
elif [ -z "$WHERE" ]; then
    ORDER="ORDER BY s1.time_start DESC"
fi

LIMIT=""
if [ -n "$N_COUNT" ] && [ "$N_COUNT" != "0" ]; then
    LIMIT="LIMIT $N_COUNT"
fi

if [ -z "$WHERE" ]; then
    ID_QUERY="SELECT i.id FROM intention i JOIN speech s1 ON i.start_speech_id = s1.id $ORDER $LIMIT"
else
    ID_QUERY="SELECT DISTINCT i.id FROM intention i JOIN speech s1 ON i.start_speech_id = s1.id JOIN speech s2 ON i.end_speech_id = s2.id WHERE $WHERE $ORDER $LIMIT"
fi

FIRST=1
for ID in $(sqlite3 "$DB" "$ID_QUERY"); do
    [ $FIRST -eq 0 ] && echo ""
    sqlite3 "$DB" "
        SELECT s.content
        FROM speech s, intention i
        WHERE i.id = $ID
          AND s.id BETWEEN i.start_speech_id AND i.end_speech_id
        ORDER BY s.id;"
    FIRST=0
done