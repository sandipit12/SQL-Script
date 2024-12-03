USE DWH_Dev_Sandip


SELECT COUNT(*) FROM RawData.users

SELECT COUNT(*) FROM Staging.users -- 2599073

SELECT COUNT(*) FROM RawData.UserAffordabilityChecks --418653

ALTER TABLE RawData.ExpectedLoss ADD TrackingSourcePromo VARCHAR(100)