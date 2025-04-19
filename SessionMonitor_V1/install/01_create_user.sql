/*
 * 創建監控用戶
 * 版本: 1.0.0
 * 依賴: 需要管理員權限
 */

DECLARE
    v_user_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'SESSION_MONITOR';
    
    IF v_user_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER session_monitor IDENTIFIED BY complex_password QUOTA UNLIMITED ON USERS';
        DBMS_OUTPUT.PUT_LINE('用戶 SESSION_MONITOR 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('用戶 SESSION_MONITOR 已存在，跳過創建');
    END IF;
    
    -- 授權 (無條件執行以確保權限完整)
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE JOB TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW, CREATE TRIGGER, CREATE SEQUENCE TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$session TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$sql TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$sql_plan TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$lock TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$process TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$session_wait TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$session_longops TO session_monitor';
    EXECUTE IMMEDIATE 'GRANT SELECT ON v_$active_session_history TO session_monitor';
    
    DBMS_OUTPUT.PUT_LINE('所有必要權限已授予');
END;
/