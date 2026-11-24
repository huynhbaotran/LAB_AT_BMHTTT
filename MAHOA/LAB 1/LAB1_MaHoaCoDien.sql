-- 1. Tạo cơ sở dữ liệu LAB1_MaHoaCoDien
IF DB_ID(N'LAB1_MaHoaCoDien') IS NULL
    CREATE DATABASE [LAB1_MaHoaCoDien];
GO

USE [LAB1_MaHoaCoDien];
GO

-- 2. Tạo bảng lưu lịch sử mã hóa / giải mã
IF OBJECT_ID(N'dbo.history', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.history (
        id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
        algorithm NVARCHAR(50) NOT NULL,
        operation VARCHAR(10) NOT NULL,
        input_text NVARCHAR(MAX) NOT NULL,
        result_text NVARCHAR(MAX) NOT NULL,
        CONSTRAINT CK_lab1_operation CHECK (operation IN ('ENCRYPT', 'DECRYPT'))
    );
END;
GO

-- 3. Tạo tài khoản đăng nhập ứng dụng 
USE [master];
GO
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'lab1_user')
BEGIN
    CREATE LOGIN [lab1_user]
        WITH PASSWORD = ***,
             CHECK_POLICY = ON,
             CHECK_EXPIRATION = OFF;
END;
GO

USE [LAB1_MaHoaCoDien]; 
GO 
SELECT TOP (20) id, created_at, algorithm, operation, input_text, result_text 
FROM dbo.history ORDER BY id DESC; 
GO 
SELECT COUNT(*) AS so_ban_ghi FROM dbo.history; 
GO 
SELECT algorithm, COUNT(*) AS so_lan FROM dbo.history GROUP BY algorithm ORDER BY so_lan DESC; 
GO 
