param([string]$Config = "", [string]$RomName = "")

$Platform = "S2I"

while ($true)
{
	$ConfigFile = "config_${Platform}_${Config}.asm"
	if (Test-Path $ConfigFile) {break}
	if ($Config -ne "") {Write-Host "${ConfigFile} does not exist!"}

	"Configurations available:"
	Get-Item "config_${Platform}_*.asm" | foreach {Write-Host " >", $_.Name.Substring(8 + $Platform.Length, $_.Name.Length - 12 - $Platform.Length)}
	$Config = (Read-Host -prompt "Configuration").Trim()
}

$RomSize = "32"

$CPUType = "80"

if ($RomName -eq "") {$RomName = "${Platform}_${Config}"}

$ErrorAction = 'Stop'

$TasmPath = '.\tools\tasm32'
$CpmToolsPath = '.\tools\cpmtools'

$env:TASMTABS = $TasmPath
$env:PATH = $TasmPath + ';' + $CpmToolsPath + ';' + $env:PATH

$RomFile = "${RomName}.rom"

""
"Building ${RomName}: ${ROMSize}KB ROM configuration ${Config} for Z${CPUType}..."
""

$TimeStamp = '"' + (Get-Date -Format 'yyMMddThhmm') + '"'
$Variant = '"S2I-' + $Env:UserName + '"'

Function Asm($Component, $Opt, $Architecture=$CPUType, $Output="${Component}.bin")
{
  $Cmd = "tasm -t${Architecture} -g3 ${Opt} ${Component}.asm ${Output}"
  $Cmd | write-host
  Invoke-Expression $Cmd | write-host
  if ($LASTEXITCODE -gt 0) {throw "TASM returned exit code $LASTEXITCODE"}
}

Function Concat($InputFileList, $OutputFile)
{
	Set-Content $OutputFile -Value $null
	foreach ($InputFile in $InputFileList)
	{
		Add-Content $OutputFile -Value ([System.IO.File]::ReadAllBytes($InputFile)) -Encoding byte
	}
}

# Generate the build settings include file

@"
; RomWBW Configured for ${Platform} ${Config}, $(Get-Date)
;
#DEFINE		TIMESTAMP	${TimeStamp}
#DEFINE		VARIANT		${Variant}
;
ROMSIZE		.EQU		${ROMSize}		; SIZE OF ROM IN KB
PLATFORM	.EQU		PLT_${Platform}		; HARDWARE PLATFORM
;
; INCLUDE PLATFORM SPECIFIC DEVICE DEFINITIONS
;
#IF (PLATFORM == PLT_S100)
  #INCLUDE "std-s100.inc"
#ELSE
  #INCLUDE "std-n8vem.inc"
#ENDIF
;
#INCLUDE "${ConfigFile}"
;
"@ | Out-File "build.inc" -Encoding ASCII

# Build components

Asm 'zapple'
Asm 'hbios'
Asm 's2i'

# Generate result files using components above

"Building ${RomName}..."

Concat 's2i.bin','zapple.bin','hbios.bin' 's2i.rom'

# Cleanup
