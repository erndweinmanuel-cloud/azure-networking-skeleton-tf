param(
  [Parameter(Mandatory=$true)]
  [string]$InputPath,

  [Parameter(Mandatory=$true)]
  [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Redact-Text {
  param([string]$Text)

  # 1) Redact Azure subscription path segments
  $Text = $Text -replace '(?i)/subscriptions/[0-9a-f-]{36}', '/subscriptions/[REDACTED_SUBSCRIPTION]'
  $Text = $Text -replace '(?i)/tenants/[0-9a-f-]{36}', '/tenants/[REDACTED_TENANT]'
  $Text = $Text -replace '(?i)[a-z0-9-]+\.onmicrosoft\.com', '[REDACTED_TENANT_DOMAIN]'

  # 2) Redact explicit keys/IDs commonly present in az / terraform outputs
  $Text = $Text -replace '(?i)"subscriptionId"\s*:\s*"[^"]+"', '"subscriptionId":"[REDACTED]"'
  $Text = $Text -replace '(?i)"tenantId"\s*:\s*"[^"]+"', '"tenantId":"[REDACTED]"'
  $Text = $Text -replace '(?i)"homeTenantId"\s*:\s*"[^"]+"', '"homeTenantId":"[REDACTED]"'
  $Text = $Text -replace '(?i)"objectId"\s*:\s*"[^"]+"', '"objectId":"[REDACTED]"'
  $Text = $Text -replace '(?i)"principalId"\s*:\s*"[^"]+"', '"principalId":"[REDACTED]"'
  $Text = $Text -replace '(?i)"clientId"\s*:\s*"[^"]+"', '"clientId":"[REDACTED]"'
  $Text = $Text -replace '(?im)\b(ssh-ed25519|ssh-rsa [REDACTED_PUBLIC_KEY]
# Collect files
$files = Get-ChildItem -Path $InputPath -Recurse -File -Force

if ($files.Count -eq 0) {
  Write-Host "No files found in InputPath: $InputPath"
  exit 1
}

foreach ($f in $files) {
  $rel = $f.FullName.Substring($InputPath.Length).TrimStart('\','/')
  $target = Join-Path $OutputPath $rel

  New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null

  $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $redacted = Redact-Text -Text $content

  # Write UTF8 (no BOM) for clean diffs
  [System.IO.File]::WriteAllText($target, $redacted, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host "Redaction done."
Write-Host "Input:  $InputPath"
Write-Host "Output: $OutputPath"
