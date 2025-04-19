/*
 * 檢驗腳本 - 驗證監控系統是否正確安裝
 * 版本: 1.0.0
 */

SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 132
SET PAGESIZE 100

SPOOL utils/verify_result.txt

PROMPT ====================================================
PROMPT Oracle 會話監控系統安裝驗證
PROMPT ====================================================
PROMPT 執行時間: [DD-MON-YYYY HH24:MI:SS]

CONNECT session_monitor/complex_password

DECLARE
    v_count NUMBER;
    v_status VARCHAR2(10);
    TYPE t_object_list IS TABLE OF VARCHAR2(100);
    v_tables t_object_list := t_object_list(
        'SESSION_MAIN', 'SESSION_SQL', 'SESSION_PLAN',
        'SESSION_LOCK', 'SESSION_LONGOPS', 'SESSION_ASH'
    );
    v_views t_object_list := t_object_list(
        'V_DEADLOCK_ANALYSIS', 'V_LONG_SESSIONS',
        'V_BLOCKING_SESSIONS', 'V_SQL_PERFORMANCE'
    );
    v_procs t_object_list := t_object_list('COLLECT_SESSION_DATA');
BEGIN
    DBMS_OUTPUT.PUT_LINE('檢查表...');
    FOR i IN 1..v_tables.COUNT LOOP
        SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = v_tables(i);
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('表 ' || v_tables(i) || ' 存在 - 正常');
        ELSE
            DBMS_OUTPUT.PUT_LINE('表 ' || v_tables(i) || ' 不存在 - 錯誤');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '檢查視圖...');
    FOR i IN 1..v_views.COUNT LOOP
        SELECT COUNT(*) INTO v_count FROM user_views WHERE view_name = v_views(i);
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('視圖 ' || v_views(i) || ' 存在 - 正常');
        ELSE
            DBMS_OUTPUT.PUT_LINE('視圖 ' || v_views(i) || ' 不存在 - 錯誤');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '檢查存儲過程...');
    FOR i IN 1..v_procs.COUNT LOOP
        SELECT COUNT(*) INTO v_count FROM user_procedures WHERE object_name = v_procs(i);
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('過程 ' || v_procs(i) || ' 存在 - 正常');
        ELSE
            DBMS_OUTPUT.PUT_LINE('過程 ' || v_procs(i) || ' 不存在 - 錯誤');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '檢查排程任務...');
    SELECT COUNT(*) INTO v_count FROM user_scheduler_jobs WHERE job_name = 'SESSION_MONITOR_JOB';
    IF v_count > 0 THEN
        SELECT enabled INTO v_status FROM user_scheduler_jobs WHERE job_name = 'SESSION_MONITOR_JOB';
        DBMS_OUTPUT.PUT_LINE('任務 SESSION_MONITOR_JOB 存在 - 正常 (狀態: ' || v_status || ')');
    ELSE
        DBMS_OUTPUT.PUT_LINE('任務 SESSION_MONITOR_JOB 不存在 - 錯誤');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '執行數據收集測試...');
    BEGIN
        collect_session_data();
        DBMS_OUTPUT.PUT_LINE('數據收集成功');
        
        SELECT COUNT(*) INTO v_count FROM session_main;
        DBMS_OUTPUT.PUT_LINE('SESSION_MAIN 現有記錄數: ' || v_count);
        
        SELECT COUNT(*) INTO v_count FROM session_sql;
        DBMS_OUTPUT.PUT_LINE('SESSION_SQL 現有記錄數: ' || v_count);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('數據收集測試失敗: ' || SQLERRM);
    END;
END;
/

SPOOL OFF