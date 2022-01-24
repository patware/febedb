SET IDENTITY_INSERT [dbo].[WeatherForecast] ON;
GO

INSERT INTO [dbo].[WeatherForecast] ([Id], [Date], [TemperatureC]) VALUES (1, N'2022-01-01 00:00:00', -25);
GO

SET IDENTITY_INSERT [dbo].[WeatherForecast] OFF;
GO

SELECT * FROM [dbo].[WeatherForecast];
GO