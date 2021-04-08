push-location $PSScriptRoot

$certsFolder = Resolve-Path .\

if (test-path Generated)
{
  remove-item Generated -recurse -Force
}
new-item -path "Generated" -itemType Directory -erroraction SilentlyContinue

Write-Host "Create random password for certificates"
[string]$Password = [Guid]::NewGuid().ToString("N")
Write-Host "Save that password in file Password.txt.  This file will be used in the generation of certificates next"
Set-Content -Path "${certsFolder}\Generated\Password.txt" -Value $Password -NoNewline

Write-Host "Run the CreateCerts.sh in a docker image that can create OpenSSLs - The generated certs will be in this folder."
docker run --entrypoint="/bin/bash" -v "${certsFolder}:/Certs" -w="/Certs" mcr.microsoft.com/dotnet/aspnet:3.1 "/Certs/CreateCerts.sh"


Write-Host "Create a docker-compose VS debug yml from template"
$composeTemplate = Get-Content -Path "${certsFolder}\docker-compose.vs.debug.yml.template"
$composeText = $composeTemplate.Replace("`$Password", $Password)
Set-Content -Path "${certsFolder}\..\docker-compose.vs.debug.yml" -Value $composeText

Write-Host "Add CA Cert to the Certificate Store"
$testCaCert = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2" @("${certsFolder}\Generated\febedb.ca.cert.crt", $null)

$storeName = [System.Security.Cryptography.X509Certificates.StoreName]::Root;
$storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store($storeName, $storeLocation)
$store.Open(([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite))
try
{
    $store.Add($testCaCert)
}
finally
{
    $store.Close()
    $store.Dispose()
}
Write-Host "Remember to include every pfx in the mounts"