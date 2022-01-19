push-location $PSScriptRoot

#$ErrorActionPreference = 'Inquire'

Write-Host "Working from: [$(Get-Location)]"

$folders = @{
  generated = join-path -path . -ChildPath "generated"
}

$files = @{
  passwordTxt = join-path -path $folders.generated -ChildPath "Password.txt"
  dockercomposetemplate = join-path -path . -ChildPath "docker-compose.vs.yml.template"
  dockercomposedebugyml = join-path -path ..\ -ChildPath "docker-compose.vs.debug.yml"
  dockercomposereleaseyml = join-path -path ..\ -ChildPath "docker-compose.vs.release.yml"
  febedb_ca_cert_crt = join-path -path $folders.generated -ChildPath "febedb.ca.cert.crt"
}

if (test-path $folders.generated)
{
  if (test-path $files.passwordTxt)
  {
    Write-Warning "Seems you already ran this script."
    $answer = Read-Host "Do you want to rerun the script? (Y/N)"
    if (-not ($answer -eq "y" -or $answer -eq "yes"))
    {
      Write-Host "Exiting..."
      break
    }
  }
  remove-item $folders.generated -recurse -Force
}
new-item $folders.generated -itemType Directory -erroraction SilentlyContinue

Write-Host "Create random password for certificates"
$values = @{
  password = [string][Guid]::NewGuid().ToString("N")
}
Set-Content -Path $files.passwordTxt -Value $values.password -NoNewline
Write-Host "Saved the password in file Password.txt.  This file will be used in the generation of certificates next"

# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
$a = @(
  "run",
  "--name", "febedbcreateCerts"
  "--rm",
  "--volume", "$(Get-Location):/Certs"
  "--workdir", "/Certs"
  "mcr.microsoft.com/dotnet/sdk:5.0"
  "pwsh", "-File", "/Certs/GenerateCertsInContainer.ps1"
)
Write-Host "Create Generate Certs using Docker"
Write-Host "docker $($a -join " ")"
& docker @a

Write-Host "Create a docker-compose VS debug yml from template"
$composeTemplate = Get-Content -Path $files.dockercomposetemplate
$composeText = $composeTemplate.Replace("`$Password", $values.password)
Set-Content -Path $files.dockercomposedebugyml -Value $composeText
Set-Content -Path $files.dockercomposereleaseyml -Value $composeText


Write-Host "Add CA Cert to this computer's Certificate Store"
$testCaCert = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2" @((Resolve-Path -path $files.febedb_ca_cert_crt).Path, $null)

$storeName = [System.Security.Cryptography.X509Certificates.StoreName]::Root;
$storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store($storeName, $storeLocation)
$store.Open(([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite))
try
{
  Write-Host "  Note: Check your popup windows, it will ask if you trust this certificate, obviously, say yes :)"
  Write-Host "If this script seems hanging/stopped, check your popup windows."
  $store.Add($testCaCert)
}
finally
{
  $store.Close()
  $store.Dispose()
}
Write-Host "Remember to include every pfx in the mounts"