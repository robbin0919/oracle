-- 查詢最近死鎖情況
SELECT * FROM v_deadlock_analysis 
WHERE capture_time > SYSTIMESTAMP - INTERVAL '1' DAY
ORDER BY capture_time DESC;

-- 查詢長時間運行的SQL
SELECT * FROM v_long_sessions
WHERE capture_time > SYSTIMESTAMP - INTERVAL '4' HOUR
ORDER BY minutes_running DESC;

-- 查詢阻塞樹結構
SELECT * FROM v_blocking_sessions;

-- 查詢性能問題SQL
SELECT * FROM v_sql_performance
WHERE capture_time > SYSTIMESTAMP - INTERVAL '1' DAY
ORDER BY elapsed_sec DESC;

-- 追蹤特定會話在一段時間內的活動
SELECT 
    s.capture_time,
    s.sid, s.status, s.event, s.wait_class,
    s.sql_id, q.sql_text,
    s.prev_sql_id, pq.sql_text AS prev_sql_text
FROM session_main s
LEFT JOIN session_sql q ON s.capture_time = q.capture_time AND s.sql_id = q.sql_id
LEFT JOIN session_sql pq ON s.capture_time = pq.capture_time AND s.prev_sql_id = pq.sql_id
WHERE s.sid = :target_sid
AND s.capture_time BETWEEN :start_time AND :end_time
ORDER BY s.capture_time;