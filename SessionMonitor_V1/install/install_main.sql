/*
 * Oracle 會話監控系統安裝主腳本
 * 版本: 1.0.0
 * 日期: 2025-04-19
 */

SET SERVEROUTPUT ON
SET ECHO ON
SET VERIFY OFF
SET TERMOUT ON

DEFINE INSTALL_DIR='&1'
DEFINE SYS_PWD='&2'

SPOOL &INSTALL_DIR/install/install_log.txt

PROMPT ====================================================
PROMPT Oracle 會話監控系統安裝開始
PROMPT ====================================================
PROMPT 時間: [DD-MON-YYYY HH24:MI:SS]

-- 創建用戶和授權
@&INSTALL_DIR/install/01_create_user.sql

-- 連接到監控用戶
CONNECT session_monitor/complex_password

-- 創建表結構
PROMPT 創建表結構...
@&INSTALL_DIR/objects/tables/session_main.sql
@&INSTALL_DIR/objects/tables/session_sql.sql
@&INSTALL_DIR/objects/tables/session_plan.sql
@&INSTALL_DIR/objects/tables/session_lock.sql
@&INSTALL_DIR/objects/tables/session_longops.sql
@&INSTALL_DIR/objects/tables/session_ash.sql

-- 創建索引
PROMPT 創建索引...
@&INSTALL_DIR/objects/indexes/main_indexes.sql
@&INSTALL_DIR/objects/indexes/sql_indexes.sql
@&INSTALL_DIR/objects/indexes/plan_indexes.sql
@&INSTALL_DIR/objects/indexes/lock_indexes.sql
@&INSTALL_DIR/objects/indexes/longops_indexes.sql
@&INSTALL_DIR/objects/indexes/ash_indexes.sql

-- 創建存儲過程
PROMPT 創建存儲過程...
@&INSTALL_DIR/objects/procedures/collect_session_data.sql

-- 創建分析視圖
PROMPT 創建分析視圖...
@&INSTALL_DIR/objects/views/deadlock_analysis.sql
@&INSTALL_DIR/objects/views/long_sessions.sql
@&INSTALL_DIR/objects/views/blocking_sessions.sql
@&INSTALL_DIR/objects/views/sql_performance.sql

-- 創建觸發器
PROMPT 創建觸發器...
@&INSTALL_DIR/objects/triggers/deadlock_trigger.sql

-- 設置排程任務
PROMPT 設置排程任務...
@&INSTALL_DIR/objects/jobs/monitor_job.sql

PROMPT ====================================================
PROMPT Oracle 會話監控系統安裝完成
PROMPT ====================================================

SPOOL OFF