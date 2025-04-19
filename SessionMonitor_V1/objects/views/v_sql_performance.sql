-- SQL效能問題分析視圖
CREATE OR REPLACE VIEW v_sql_performance AS
SELECT 
    q.capture_time,
    q.sql_id, q.plan_hash_value,
    q.sql_text,
    q.parsing_schema_name,
    q.executions, 
    ROUND(q.elapsed_time/1000000, 2) AS elapsed_sec,
    ROUND(q.cpu_time/1000000, 2) AS cpu_sec,
    q.buffer_gets, q.disk_reads,
    ROUND(q.buffer_gets/GREATEST(q.executions,1)) AS avg_buffer_gets,
    ROUND(q.disk_reads/GREATEST(q.executions,1)) AS avg_disk_reads,
    ROUND(q.elapsed_time/1000000/GREATEST(q.executions,1),2) AS avg_elapsed_sec,
    ROUND(q.cpu_time/1000000/GREATEST(q.executions,1),2) AS avg_cpu_sec,
    q.optimizer_cost
FROM session_sql q
WHERE q.executions > 0
AND (q.elapsed_time/1000000/GREATEST(q.executions,1) > 1  -- 平均執行時間超過1秒
     OR q.buffer_gets/GREATEST(q.executions,1) > 10000)   -- 平均緩沖區獲取超過10000次
ORDER BY q.elapsed_time DESC;