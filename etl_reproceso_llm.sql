USE FlexerDWH;
GO

ALTER TABLE oltp.llm_logs
ADD updated_at DATETIME2 DEFAULT GETDATE();
GO

UPDATE oltp.llm_logs
SET updated_at = parsed_at;
GO