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

if [ -z "$T_TIME" ] && [ -z "$SEARCH_STR" ] && [ -z "$START_TIME" ] && [ -z "$END_TIME" ]; then
    sqlite3 "$DB" "SELECT COUNT(*) FROM intention;"
    exit 0
fi

QUERY="WITH targets AS (
    SELECT DISTINCT i.id, i.start_speech_id, i.end_speech_id
    FROM intention i
    JOIN speech s1 ON i.start_speech_id = s1.id
    JOIN speech s2 ON i.end_speech_id = s2.id"

WHERE=""
ORDER=""

if [ -n "$SEARCH_STR" ]; then
    WHERE="$WHERE (s1.content LIKE '%$SEARCH_STR%' OR s2.content LIKE '%$SEARCH_STR%') AND"
fi

if [ -n "$START_TIME" ] && [ -n "$END_TIME" ]; then
    WHERE="$WHERE s1.time_start BETWEEN '$START_TIME' AND '$END_TIME' AND"
fi

WHERE="${WHERE% AND}"

if [ -n "$WHERE" ]; then
    QUERY="$QUERY WHERE $WHERE"
fi

if [ -n "$T_TIME" ]; then
    ORDER="ORDER BY ABS(strftime('%s', s1.time_start) - strftime('%s', '$T_TIME'))"
elif [ -z "$WHERE" ]; then
    ORDER="ORDER BY s1.time_start DESC"
fi

QUERY="$QUERY $ORDER LIMIT $N_COUNT)
SELECT s.content
FROM speech s, targets
WHERE s.id IN (targets.start_speech_id, targets.end_speech_id)
ORDER BY s.id;"

sqlite3 "$DB" "$QUERY"