namespace febedb.frontend
{
  /// <summary>
  /// See appsettings.json or appsettings.{Environment}.json for the values
  /// </summary>
  public class Settings
  {
    /// <summary>
    /// appsettings.json > "Settings"
    /// </summary>
    public const string Key = "Settings";

    /// <summary>
    /// appsettings.json > Settings > BackendUrl
    /// </summary>        
    public string BackendUrl { get; set; }
  }
}
