CREATE OR REPLACE VIEW v_deadlock_analysis AS
SELECT 
    l.capture_time,
    s.sid, s.serial#, s.username, s.machine, s.program, 
    s.module, s.action, s.sql_id, s.prev_sql_id,
    l.lock_type, l.mode_held, l.mode_requested, 
    l.lock_id1, l.lock_id2, l.blocking_others,
    sq.sql_text, psq.sql_text AS prev_sql_text
FROM session_lock l
JOIN session_main s ON l.capture_time = s.capture_time AND l.sid = s.sid AND l.serial# = s.serial#
LEFT JOIN session_sql sq ON s.capture_time = sq.capture_time AND s.sql_id = sq.sql_id
LEFT JOIN session_sql psq ON s.capture_time = psq.capture_time AND s.prev_sql_id = psq.sql_id
WHERE l.blocking_others = 'YES'
OR l.mode_requested > 0;
 