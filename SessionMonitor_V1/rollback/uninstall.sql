/*
 * 卸載腳本 - 移除監控系統所有組件
 * 版本: 1.0.0
 */

SET SERVEROUTPUT ON
SET ECHO ON

SPOOL rollback/uninstall_log.txt

PROMPT ====================================================
PROMPT Oracle 會話監控系統卸載開始
PROMPT ====================================================
PROMPT 時間: [DD-MON-YYYY HH24:MI:SS]

-- 連接到監控用戶
CONNECT session_monitor/complex_password

-- 刪除排程任務
BEGIN
    DBMS_OUTPUT.PUT_LINE('正在刪除排程任務...');
    BEGIN
        DBMS_SCHEDULER.DROP_JOB('SESSION_MONITOR_JOB', TRUE);
        DBMS_OUTPUT.PUT_LINE('已刪除 SESSION_MONITOR_JOB');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('刪除任務出錯: ' || SQLERRM);
    END;
END;
/

-- 刪除視圖
DECLARE
    TYPE t_view_list IS TABLE OF VARCHAR2(30);
    v_views t_view_list := t_view_list(
        'V_DEADLOCK_ANALYSIS', 'V_LONG_SESSIONS', 
        'V_BLOCKING_SESSIONS', 'V_SQL_PERFORMANCE'
    );
BEGIN
    DBMS_OUTPUT.PUT_LINE('正在刪除視圖...');
    FOR i IN 1..v_views.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP VIEW ' || v_views(i);
            DBMS_OUTPUT.PUT_LINE('已刪除視圖 ' || v_views(i));
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('刪除視圖 ' || v_views(i) || ' 出錯: ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- 刪除觸發器
BEGIN
    DBMS_OUTPUT.PUT_LINE('正在刪除觸發器...');
    BEGIN
        EXECUTE IMMEDIATE 'DROP TRIGGER capture_deadlock_info';
        DBMS_OUTPUT.PUT_LINE('已刪除觸發器 capture_deadlock_info');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('刪除觸發器出錯: ' || SQLERRM);
    END;
END;
/

-- 刪除存儲過程
BEGIN
    DBMS_OUTPUT.PUT_LINE('正在刪除存儲過程...');
    BEGIN
        EXECUTE IMMEDIATE 'DROP PROCEDURE collect_session_data';
        DBMS_OUTPUT.PUT_LINE('已刪除存儲過程 collect_session_data');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('刪除存儲過程出錯: ' || SQLERRM);
    END;
END;
/

-- 刪除表
DECLARE
    TYPE t_table_list IS TABLE OF VARCHAR2(30);
    v_tables t_table_list := t_table_list(
        'SESSION_ASH', 'SESSION_LONGOPS', 'SESSION_LOCK',
        'SESSION_PLAN', 'SESSION_SQL', 'SESSION_MAIN'
    );
BEGIN
    DBMS_OUTPUT.PUT_LINE('正在刪除表...');
    FOR i IN 1..v_tables.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || v_tables(i) || ' CASCADE CONSTRAINTS';
            DBMS_OUTPUT.PUT_LINE('已刪除表 ' || v_tables(i));
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('刪除表 ' || v_tables(i) || ' 出錯: ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT ====================================================
PROMPT 監控系統卸載完成
PROMPT ====================================================

SPOOL OFF