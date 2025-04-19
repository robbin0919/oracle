-- 長時間運行會話分析視圖
CREATE OR REPLACE VIEW v_long_sessions AS
SELECT 
    s.capture_time,
    s.sid, s.serial#, s.username, s.machine, s.program, s.module,
    s.logon_time, s.status, s.last_call_et/60 AS minutes_running,
    s.wait_class, s.event, s.seconds_in_wait,
    s.sql_id, s.prev_sql_id,
    q.sql_text, q.executions, 
    ROUND(q.elapsed_time/1000000/GREATEST(q.executions,1),2) AS avg_elapsed_sec,
    q.buffer_gets, q.disk_reads
FROM session_main s
LEFT JOIN session_sql q ON s.capture_time = q.capture_time AND s.sql_id = q.sql_id
WHERE s.last_call_et > 600  -- 超過10分鐘
ORDER BY s.last_call_et DESC;