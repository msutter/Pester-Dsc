Function Get-DscTestEnvirement {
    param (
        [String]$TestDrive,
        [String]$ResourcePath
    )
    $TestDrivePath        = (Get-item $TestDrive).FullName.TrimEnd('/').TrimEnd('\')
    $ModulePath           =  Split-Path -Parent $ResourcePath | Split-Path -Parent
    $ModulesRootPath      = $ModulePath | Split-Path -Parent
    $ModuleName           = (Split-Path -Leaf $ModulePath)
    $ResourceName         = (Split-Path -Leaf $ResourcePath)
    $SchemaMofPath        = "${ResourcePath}\${ResourceName}.schema.mof"
    $TestConfig           = ".\${ResourceName}.Tests.Config.ps1"
    $MofRootPath          = "${TestDrivePath}\TestConfig"
    $MofPath              = "${MofRootPath}\test.mof"
    $TestModulePath       = "${TestDrivePath}\Modules"
    $OriginalPSMODULEPATH = $env:PSMODULEPATH

    if (Test-path $TestModulePath) {Remove-Item -Recurse -Force $TestModulePath}
    if (Test-path $MofRootPath) {Remove-Item -Recurse -Force $MofRootPath}

    if (!(Test-path $TestModulePath)) {New-Item -ItemType directory -Path $TestModulePath}
    if (!(Test-path $MofRootPath)) {New-Item -ItemType directory -Path $MofRootPath}

    Copy-Item -Recurse "${ModulePath}" "${TestModulePath}\${ModuleName}"
    $env:PsModulePath = "${TestModulePath};C:\Windows\system32\WindowsPowerShell\v1.0\Modules"    
    Get-DscResource -Name $ResourceName | out-null
    . $TestConfig
    TestConfig -OutputPath $MofRootPath

    $env:PSMODULEPATH = $OriginalPSMODULEPATH

    $DscProperties = @{
        'TestDrivePath'   = $TestDrivePath;
        'SchemaMofPath'   = $SchemaMofPath;
        'MofPath'         = $MofPath;
        'ResourcePath'    = $ResourcePath;
        'ModulePath'      = $ModulePath;
        'ModulesRootPath' = $ModulesRootPath;
        'ModuleName'      = $ModuleName;
        'ResourceName'    = $ResourceName
        }

    $DscTest = New-Object -TypeName PSObject -Prop $DscProperties 
    return $DscTest



}
