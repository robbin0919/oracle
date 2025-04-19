/*
 * 數據收集存儲過程 - 監控核心邏輯
 * 版本: 1.0.0
 */

CREATE OR REPLACE PROCEDURE collect_session_data 
AS
    v_rowcount NUMBER;
BEGIN
    -- 收集會話資訊
    INSERT INTO session_main (
        sid, serial#, username, osuser, machine, 
        program, module, action, logon_time, status, 
        last_call_et, blocking_session, wait_class, event, 
        seconds_in_wait, state, sql_id, prev_sql_id, 
        sql_child_number, sql_exec_id, sql_exec_start,
        plsql_entry_object_id, plsql_entry_subprogram_id, plsql_object_id
    )
    SELECT 
        s.sid, s.serial#, s.username, s.osuser, s.machine,
        s.program, s.module, s.action, s.logon_time, s.status,
        s.last_call_et, s.blocking_session, s.wait_class, s.event,
        s.seconds_in_wait, s.state, s.sql_id, s.prev_sql_id,
        s.sql_child_number, s.sql_exec_id, s.sql_exec_start,
        s.plsql_entry_object_id, s.plsql_entry_subprogram_id, s.plsql_object_id
    FROM v$session s
    WHERE s.type = 'USER'
    AND (s.status = 'ACTIVE' OR s.last_call_et > 300 OR s.blocking_session IS NOT NULL);
    
    v_rowcount := SQL%ROWCOUNT;
    COMMIT;
    
    -- 收集SQL語句資訊 (關聯到活躍的會話)
    INSERT INTO session_sql (
        sql_id, sql_fulltext, sql_text, command_type, parsing_schema_name,
        executions, elapsed_time, cpu_time, buffer_gets, disk_reads,
        direct_writes, rows_processed, fetches, plan_hash_value, hash_value,
        optimizer_cost, optimizer_mode, last_active_time, last_load_time
    )
    SELECT DISTINCT
        q.sql_id, q.sql_fulltext, q.sql_text, q.command_type, q.parsing_schema_name,
        q.executions, q.elapsed_time, q.cpu_time, q.buffer_gets, q.disk_reads,
        q.direct_writes, q.rows_processed, q.fetches, q.plan_hash_value, q.hash_value,
        q.optimizer_cost, q.optimizer_mode, q.last_active_time, q.last_load_time
    FROM v$sql q
    WHERE q.sql_id IN (
        SELECT sql_id FROM session_main 
        WHERE capture_time = (SELECT MAX(capture_time) FROM session_main)
        AND sql_id IS NOT NULL
        UNION
        SELECT prev_sql_id FROM session_main 
        WHERE capture_time = (SELECT MAX(capture_time) FROM session_main)
        AND prev_sql_id IS NOT NULL
    );
    COMMIT;
    
    -- 收集執行計劃
    INSERT INTO session_plan (
        sql_id, plan_hash_value, id, operation, options, 
        object_name, object_owner, access_predicates, filter_predicates,
        cost, cardinality, bytes, cpu_cost, io_cost
    )
    SELECT 
        p.sql_id, p.plan_hash_value, p.id, p.operation, p.options,
        p.object_name, p.object_owner, p.access_predicates, p.filter_predicates,
        p.cost, p.cardinality, p.bytes, p.cpu_cost, p.io_cost
    FROM v$sql_plan p
    WHERE p.sql_id IN (
        SELECT sql_id FROM session_sql
        WHERE capture_time = (SELECT MAX(capture_time) FROM session_sql)
    );
    COMMIT;
    
    -- 收集鎖資訊
    INSERT INTO session_lock (
        sid, serial#, lock_type, mode_held, mode_requested,
        lock_id1, lock_id2, blocking_others
    )
    SELECT 
        l.sid, s.serial#, l.type, l.lmode, l.request,
        l.id1, l.id2, 
        CASE WHEN EXISTS (
            SELECT 1 FROM v$lock l2 
            WHERE l2.request > 0 AND l2.id1 = l.id1 AND l.lmode > 0
        ) THEN 'YES' ELSE 'NO' END as blocking_others
    FROM v$lock l
    JOIN v$session s ON l.sid = s.sid
    WHERE s.type = 'USER'
    AND (l.lmode > 0 OR l.request > 0)
    AND l.type != 'AE'; -- 排除編輯鎖
    COMMIT;
    
    -- 收集長時間運行操作
    INSERT INTO session_longops (
        sid, serial#, opname, target, sofar,
        totalwork, units, elapsed_seconds, time_remaining,
        sql_id, sql_plan_hash_value
    )
    SELECT 
        lo.sid, lo.serial#, lo.opname, lo.target, lo.sofar,
        lo.totalwork, lo.units, lo.elapsed_seconds, lo.time_remaining,
        lo.sql_id, lo.sql_plan_hash_value
    FROM v$session_longops lo
    WHERE lo.time_remaining > 0
    OR lo.elapsed_seconds > 60;
    COMMIT;
    
    -- 收集活動會話歷史(ASH)
    INSERT INTO session_ash (
        ash_time, session_id, session_serial#, sql_id, sql_child_number,
        event, event_id, wait_class, time_waited,
        blocking_session, blocking_session_serial#, user_id, module
    )
    SELECT 
        ash.sample_time, ash.session_id, ash.session_serial#, ash.sql_id, ash.sql_child_number,
        ash.event, ash.event_id, ash.wait_class, ash.time_waited,
        ash.blocking_session, ash.blocking_session_serial#, ash.user_id, ash.module
    FROM v$active_session_history ash
    WHERE ash.sample_time >= SYSTIMESTAMP - INTERVAL '5' MINUTE;
    COMMIT;
    
    -- 清理歷史資料 (保留30天)
    DELETE FROM session_main WHERE capture_time < SYSTIMESTAMP - INTERVAL '30' DAY;
    DELETE FROM session_sql WHERE capture_time < SYSTIMESTAMP - INTERVAL '30' DAY;
    DELETE FROM session_plan WHERE capture_time < SYSTIMESTAMP - INTERVAL '30' DAY;
    DELETE FROM session_lock WHERE capture_time < SYSTIMESTAMP - INTERVAL '30' DAY;
    DELETE FROM session_longops WHERE capture_time < SYSTIMESTAMP - INTERVAL '30' DAY;
    DELETE FROM session_ash WHERE capture_time < SYSTIMESTAMP - INTERVAL '30' DAY;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        -- 實際環境中可考慮寫入錯誤日誌表
END collect_session_data;
/

SHOW ERRORS PROCEDURE collect_session_data;