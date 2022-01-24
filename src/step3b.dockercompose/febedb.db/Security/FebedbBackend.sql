CREATE LOGIN [FebedbBackend]
    WITH PASSWORD = N'Febedb@B4ckend'
    , SID = 0x2A30987D5806E143900759FD32FFBAC1
    , DEFAULT_LANGUAGE = [us_english];
GO

CREATE USER [FebedbBackend] FOR LOGIN [FebedbBackend];
GO

GRANT CONNECT TO [FebedbBackend]
GO

ALTER ROLE [db_datareader] ADD MEMBER [FebedbBackend]
GO

ALTER ROLE [db_datawriter] ADD MEMBER [FebedbBackend]
GO