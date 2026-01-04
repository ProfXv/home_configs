#!/bin/sh

sqlite3 ~/.log.db "SELECT content FROM speech, (SELECT start_speech_id, end_speech_id FROM intention WHERE id = $1) as ids WHERE speech.id BETWEEN ids.start_speech_id AND ids.end_speech_id;"