/*
 * 數據收集存儲過程 - 監控核心邏輯
 * 版本: 1.0.0
 */

CREATE OR REPLACE PROCEDURE collect_session_data 
AS
    v_rowcount NUMBER;
    v_start TIMESTAMP;
    v_error_code NUMBER;
    v_error_msg VARCHAR2(4000);
BEGIN
    v_start := SYSTIMESTAMP;
    DBMS_OUTPUT.PUT_LINE('開始收集會話數據: ' || TO_CHAR(v_start, 'YYYY-MM-DD HH24:MI:SS.FF'));
    
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
    DBMS_OUTPUT.PUT_LINE('已收集 ' || v_rowcount || ' 條會話數據');
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
    
    v_rowcount := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('已收集 ' || v_rowcount || ' 條SQL數據');
    COMMIT;
    
    -- [其餘收集代碼省略，與之前相同]
    
    -- 數據收集完成
    DBMS_OUTPUT.PUT_LINE('數據收集完成，耗時: ' || 
        EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start)) || ' 秒');
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;
        
        DBMS_OUTPUT.PUT_LINE('錯誤: ' || v_error_code || ' - ' || v_error_msg);
        ROLLBACK;
        
        -- 記錄錯誤到特定日誌表(可選實現)
END collect_session_data;
/

SHOW ERRORS PROCEDURE collect_session_data;