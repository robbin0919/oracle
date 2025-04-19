-- 針對特殊事件觸發的額外監控
-- 當檢測到死鎖，立即收集更多資訊
CREATE OR REPLACE TRIGGER capture_deadlock_info
AFTER SERVERERROR ON DATABASE
WHEN (ora_is_servererror(60))  -- ORA-00060: 檢測到死鎖
BEGIN
    collect_session_data();
END;
/