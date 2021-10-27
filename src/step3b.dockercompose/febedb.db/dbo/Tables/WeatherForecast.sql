CREATE TABLE [dbo].[WeatherForecast]
(
	[Id] INT IDENTITY(1,1) PRIMARY KEY NOT NULL
	, [Date] DATETIME NOT NULL
	, [TemperatureC] INT NOT NULL
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date value was updated',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WeatherForecast',
    @level2type = N'COLUMN',
    @level2name = N'Date'