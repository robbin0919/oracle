-- 阻塞分析視圖
CREATE OR REPLACE VIEW v_blocking_sessions AS
WITH blocker_tree AS (
    SELECT 
        s.capture_time,
        LEVEL as blocking_level,
        CONNECT_BY_ROOT s.sid AS root_blocker,
        s.sid, s.serial#, s.username, s.status,
        s.sql_id, s.event, s.wait_class, 
        s.blocking_session
    FROM session_main s
    WHERE s.capture_time = (SELECT MAX(capture_time) FROM session_main)
    CONNECT BY PRIOR s.sid = s.blocking_session
    START WITH s.blocking_session IS NULL AND s.sid IN 
        (SELECT blocking_session FROM session_main WHERE blocking_session IS NOT NULL)
)
SELECT 
    b.capture_time,
    b.blocking_level, b.root_blocker,
    b.sid, b.serial#, b.username, b.status,
    m.machine, m.program, m.module,
    b.sql_id, b.event, b.wait_class,
    q.sql_text,
    q.elapsed_time/1000000 as elapsed_sec,
    q.executions
FROM blocker_tree b
JOIN session_main m ON b.capture_time = m.capture_time AND b.sid = m.sid
LEFT JOIN session_sql q ON b.capture_time = q.capture_time AND b.sql_id = q.sql_id
ORDER BY b.root_blocker, b.blocking_level;
