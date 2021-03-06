#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabVMDiskFile' {

    InModuleScope $moduleName {

        Context 'Validates "SetLabVMDiskResource" method' {
            
            It 'Mounts virtual machine VHDX file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ExpandLabResource -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskResource -ConfigurationData $configurationData -NodeName $testVMName -DisplayName $testVMName;

                Assert-MockCalled Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }

            It 'Calls "ExpandLabResource" to inject disk resource' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ExpandLabResource -ParameterFilter { $Name -eq $testVMName }  -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskResource -ConfigurationData $configurationData -NodeName $testVMName -DisplayName $testVMName;

                Assert-MockCalled ExpandLabResource -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Dismounts virtual machine VHDX file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ExpandLabResource -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskResource -ConfigurationData $configurationData -NodeName $testVMName -DisplayName $testVMName;

                Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }
        
        }  #end context Validates "SetLabVMDiskResource" method
        
        Context 'Validates "SetLabVMDiskFile" method' {

            $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

            It 'Mounts virtual machine VHDX file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock SetLabVMDiskDscResource -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential;

                Assert-MockCalled Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }

            It 'Copies DSC resources' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; ProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock SetLabVMDiskDscResource -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential;

                Assert-MockCalled SetLabVMDiskDscResource -Scope It;
            }

            It 'Creates "Unattend.xml" file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock SetLabVMDiskDscResource -MockWith { }
                Mock SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential;

                Assert-MockCalled SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -Scope It;
            }

            It 'Copies default "BootStrap.ps1"' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock Copy-Item -ParameterFilter { $Destination.EndsWith('\Program Files\WindowsPowershell\Modules') -eq $true } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential;

                Assert-MockCalled SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -Scope It;
            }
            
            It 'Copies "BootStrap.ps1" with a custom bootstrap when "CustomBootStrap" is specified' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock Copy-Item -ParameterFilter { $Destination.EndsWith('\Program Files\WindowsPowershell\Modules') -eq $true } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $CustomBootStrap -ne $null } -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential -CustomBootStrap '# Test Bootstrap';

                Assert-MockCalled SetBootStrap -ParameterFilter { $CustomBootStrap -ne $null } -Scope It;
            }
            
            It 'Copies default "SetupComplete.cmd"' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock Copy-Item -ParameterFilter { $Destination.EndsWith('\Program Files\WindowsPowershell\Modules') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $CustomBootStrap -ne $null } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $CoreCLR -eq $false } -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential;

                Assert-MockCalled SetSetupCompleteCmd -ParameterFilter { $CoreCLR -eq $false } -Scope It;
            }

            It 'Copies CoreCLR "SetupComplete.cmd"' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
                Mock Copy-Item -ParameterFilter { $Destination.EndsWith('\Program Files\WindowsPowershell\Modules') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $CustomBootStrap -ne $null } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $CoreCLR -eq $true } -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential -CoreCLR;

                Assert-MockCalled SetSetupCompleteCmd -ParameterFilter { $CoreCLR -eq $true } -Scope It;
            }
            
            It 'Dismounts virtual machine VHDX file' {
                $testVMName = 'TestVM';
                $testVhdPath = "TestDrive:\$testVMName.vhdx";
                $testDiskNumber = 42;
                $testDriveLetter = 'Z';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; NodeDisplayName = $testVMName; Timezone = 'GMT Standard Time'; }
                    )
                }
                Mock Stop-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock ResolveLabVMDiskPath -ParameterFilter { $Name -eq $testVMName } -MockWith { return $testVhdPath; }
                Mock Mount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
                Mock Get-Partition -ParameterFilter { $DiskNumber -eq $testDiskNumber } -MockWith { return [PSCustomObject] @{ DriveLetter = $testDriveLetter; } }
                Mock Start-Service -ParameterFilter { $Name -eq 'ShellHWDetection' } -MockWith { }
                Mock SetBootStrap -ParameterFilter { $Path.EndsWith('\BootStrap') -eq $true } -MockWith { }
                Mock SetSetupCompleteCmd -ParameterFilter { $Path.EndsWith('\Windows\Setup\Scripts') -eq $true } -MockWith { }
                Mock SetUnattendXml -ParameterFilter { $Path.EndsWith('\Windows\System32\Sysprep\Unattend.xml') -eq $true } -MockWith { }
                Mock Copy-Item -ParameterFilter { $Destination.EndsWith('\Program Files\WindowsPowershell\Modules') -eq $true } -MockWith { }
                Mock Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }

                SetLabVMDiskFile -NodeData $configurationData.AllNodes[0] -Name $testVMName -Credential $testCredential;

                Assert-MockCalled Dismount-Vhd -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
            }
            
        }  #end context Validates "SetLabVMDiskFile" method
        
    } #end InModuleScope

} #end describe LabVMDiskFile
