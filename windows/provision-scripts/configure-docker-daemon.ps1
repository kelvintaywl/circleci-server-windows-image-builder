# Replace with your Docker registry mirror
$registryMirror = "https://mirror.gcr.io"

# Check if Docker service is running
$dockerService = Get-Service -Name Docker -ErrorAction SilentlyContinue
if ($dockerService.Status -ne "Running") {
    Write-Host "Docker service is not running."
    exit
}

# Stop Docker service
Stop-Service -Name Docker

# Set the docker configutation
$daemonConfigPath = "C:\ProgramData\Docker\config\daemon.json"

# load or create Docker config JSON
if (Test-Path -Path $daemonConfigPath -PathType Leaf) {
    Write-Host "Docker config JSON exists."
    $daemonConfig = Get-Content -Path $daemonConfigPath | ConvertFrom-Json
} else {
    Write-Host "Docker config JSON does not exist."
    $daemonConfig = @{}
}

# Add or update registry mirror settings
if ($daemonConfig.'registry-mirrors' -eq $null) {
    Write-Host "registry mirror array missing. Creating record.."
    $daemonConfig | add-member -type NoteProperty -Name 'registry-mirrors' -Value @($registryMirror)
} else {
    Write-Host "registry mirror array found. Appending record.."
    $daemonConfig.'registry-mirrors' += $registryMirror
}

# Save the modified configuration file
$daemonConfig | ConvertTo-Json | Set-Content -Path $daemonConfigPath

# inspect config
Get-Content -Path $daemonConfigPath

# Start Docker service
Start-Service -Name Docker

Write-Host "Docker Daemon has been configured to use the registry mirror."