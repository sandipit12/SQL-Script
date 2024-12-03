USE master;
GO
SELECT l.name AS LoginName, l.sid AS LoginSID
 ,u.name AS UserName, u.sid AS UserSID
 FROM dbo.syslogins l
 JOIN AdviserManagement.dbo.sysusers u ON l.name = u.name
 WHERE l.sid <> u.sid
GO
