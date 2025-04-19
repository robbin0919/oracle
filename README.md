# Oracle 會話監控系統

## 簡介
此系統用於自動收集和監控 Oracle 資料庫會話信息，追蹤 SQL 執行情況，並提供分析工具協助診斷性能問題、死鎖等情況。

## 版本
當前版本: 1.0.0 (2025-04-19)

## 系統要求
- Oracle 11g R2 或更高版本
- DBA 權限 (僅用於初始安裝)

## 安裝步驟
1. 使用具有 DBA 權限的用戶登錄資料庫
2. 運行安裝腳本:

## 目錄結構  
SessionMonitor/  
├── install/              # 安裝腳本  
├── objects/              # 資料庫對象定義  
│   ├── tables/           # 表結構定義  
│   ├── indexes/          # 索引定義  
│   ├── procedures/       # 程序定義    
│   ├── jobs/             # 作業排程定義  
│   ├── views/            # 視圖定義  
│   └── triggers/         # 觸發器定義  
├── rollback/             # 回滾腳本  
├── upgrade/              # 版本升級腳本  
├── utils/                # 工具腳本  
└── config/               # 配置文件  

## 系統組件
- 資料收集模組: 每5分鐘自動收集活躍會話資訊  
- 會話分析模組: 提供多個視圖用於問題分析  
- 死鎖捕獲觸發器: 發生死鎖時自動收集詳細資訊  

## 使用方法  
### 查詢長時間運行的會話  
```sql
SELECT * FROM v_long_sessions
ORDER BY minutes_running DESC;

##  分析死鎖情況  
```sql
SELECT * FROM v_deadlock_analysis
WHERE capture_time > SYSDATE - 1;