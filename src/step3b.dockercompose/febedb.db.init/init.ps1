#run the setup script to create the DB and the schema in the DB
#do this in a loop because the timing for when the SQL instance is ready is indeterminate
Write-Host "$PSScriptRoot, $PSCommandPath"
$sqlIsReady=$false
Write-Host "Step 1: waiting for SQL Server to be running and responsive on server febedb.db"
foreach ($i in (1..50))
{
    <#
      $i = 1
    #>
    Write-Host "  Try #$i`: Run sqlcmd to febedb.db server"
    # /opt/mssql-tools/bin/sqlcmd
    # -b: returns an ERRORLEVEL (1 if fail or 0 if pass)
    # -S: servername, in our case because we're in docker (docker-compose), the name of the server is the 'service name' from the yaml
    # -Q: query string to execute.  (upper case -Q that is, because we want to exit the sqlcmd command shell after the query, if lower case -q, the sql shell would remain open)
    $a = @(
      "-b",
      "-S",
      '"febedb.db"',
      "-U", "SA",
      "-P", "$env:SA_PASSWORD",
      "-Q", "SELECT 'Connected', @@SERVERNAME, CURRENT_USER;"
    )
    Write-Host "/opt/mssql-tools/bin/sqlcmd $($a -join " ")"
    & /opt/mssql-tools/bin/sqlcmd @a

    if ($LASTEXITCODE -eq 0)
    {
      Write-Host "    Sql Server is ready"
      $sqlIsReady=$true
      break
    }
    else
    {
      Write-Host "    not ready yet... Sleeping 1 second then retry. Exit Code [$LASTEXITCODE]"
      start-sleep -Seconds 1
    }
}

if ($sqlIsReady)
{
  Write-Host "Step 2: Run SqlPackage to deploy the dacpac"
  foreach($i in (1..50))  
  {
    Write-Host "  Try #$i`: calling SqlPackage on sqlserver febedb.db"
    $a = @(
      "/Action:Publish",
      "/SourceFile:""/dacpacs/febedb.db.dacpac""",
      "/TargetDatabaseName:""febedb""",
      "/TargetServerName:""febedb.db""",
      "/TargetUser:""sa""",
      "/TargetPassword:""$($env:SA_PASSWORD)"""
    )
    Write-Host "/opt/sqlpackage/sqlpackage $($a -join " ")"
    /opt/sqlpackage/sqlpackage @a
    if ($LASTEXITCODE -eq 0)
    {
      Write-Host "    Dacpac deployed completed"
      break
    }
    else
    {
      Write-Host "    Problem running SqlPackage to deploy the Dacpac, pausing for 1 second before retrying. Exit Code [$LASTEXITCODE]"
      Start-Sleep -Seconds 1
    }
  }
}
else
{
  Write-Host "Step 2: Skipped, Sql still isn't ready, even after 50 retries"
}

if ($sqlIsReady)
{
  Write-Host "Step 3: Seed some data"

  Write-Host "  Seed data using sqlcmd"
    $a = @(
      "-b",               #terminate batch if there is an error
      "-S", "febedb.db",  #server name
      "-d", "febedb",     #database name
      "-U", "SA",
      "-P", "$env:SA_PASSWORD",
      "-i", "/init/seed.sql"
    )
    Write-Host "/opt/mssql-tools/bin/sqlcmd $($a -join " ")"
    & /opt/mssql-tools/bin/sqlcmd @a

}



Write-Host "Script is done..."
