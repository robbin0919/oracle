/*
 * 排程任務設定 - 定期自動收集會話資訊
 * 版本: 1.0.0
 */

DECLARE
    v_job_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_job_exists 
    FROM user_scheduler_jobs 
    WHERE job_name = 'SESSION_MONITOR_JOB';
    
    IF v_job_exists > 0 THEN
        BEGIN
            DBMS_SCHEDULER.DROP_JOB(
                job_name => 'SESSION_MONITOR_JOB',
                force => TRUE
            );
            DBMS_OUTPUT.PUT_LINE('已刪除現有任務');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('刪除現有任務失敗: ' || SQLERRM);
        END;
    END IF;

    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SESSION_MONITOR_JOB',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'collect_session_data',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=5',
        enabled         => TRUE,
        comments        => '每五分鐘收集會話監控資訊 (版本1.0.0)'
    );
    
    DBMS_OUTPUT.PUT_LINE('監控任務已創建並啟用');
END;
/