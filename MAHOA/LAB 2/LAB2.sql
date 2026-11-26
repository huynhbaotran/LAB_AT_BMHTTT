-- Chay bang tai khoan quan tri trong SQL Server Management Studio. -- Chon New Query va chay toan bo script. 
IF DB_ID(N'LAB2_MaHoaHienDai') IS NULL 
BEGIN 
    CREATE DATABASE LAB2_MaHoaHienDai; 
END; 
GO 
USE LAB2_MaHoaHienDai; 
GO 
IF OBJECT_ID(N'dbo.app_users', N'U') IS NULL 
BEGIN 
    CREATE TABLE dbo.app_users ( 
        user_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
        username NVARCHAR(40) NOT NULL UNIQUE, 
        salt VARBINARY(16) NOT NULL, 
        password_hash VARBINARY(32) NOT NULL, 
        created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME() 
    ); 
END; 
GO 
IF OBJECT_ID(N'dbo.crypto_history', N'U') IS NULL 
BEGIN 
    CREATE TABLE dbo.crypto_history ( 
        history_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
        algorithm NVARCHAR(40) NOT NULL, 
        operation NVARCHAR(16) NOT NULL, 
        app_username NVARCHAR(40) NULL, 
        input_length INT NOT NULL, 
        output_length INT NOT NULL, 
        created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME() 
    ); 
END; 
GO 
SELECT name FROM sys.tables ORDER BY name; 
GO 


-- Chi dung cho SQL Server Express tren may thuc hanh. 
USE master; 
GO 
IF SUSER_ID(N'lab2_user') IS NULL 
    CREATE LOGIN lab2_user WITH PASSWORD = 'LabUser@2026', CHECK_POLICY = ON; 
GO 
USE LAB2_MaHoaHienDai; 
GO 
IF DATABASE_PRINCIPAL_ID(N'lab2_user') IS NULL 
    CREATE USER lab2_user FOR LOGIN lab2_user; 
GO 
IF IS_ROLEMEMBER(N'db_datareader', N'lab2_user') = 0 
    ALTER ROLE db_datareader ADD MEMBER lab2_user; 
IF IS_ROLEMEMBER(N'db_datawriter', N'lab2_user') = 0 
    ALTER ROLE db_datawriter ADD MEMBER lab2_user; 
GO 