#
# Cookbook:: RuntimeIntegration
# Recipe:: Install RuntimeIntegration
#
# Copyright:: 2019, The Authors, All Rights Reserved.
#
# Install RuntimeIntegration
powershell_script 'get-azure-IR' do
	code <<-EOH
	# check to see if domain or workgroup
		$check = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
	# on domain
		If ($check -eq $True){
		write-host "On domain"
		#write in access check or add credentials
		$uri = '\\'
		}
	# not on domain
		Else {
		write-host "On workgroup"
		#$uri = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=39717" #this uri doesn't always auto-download
		$uri = "https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_3.19.7129.1 (64-bit).msi" #specific uri could break
		}
	# where to download the file locally
		$out = "C:\IntegrationRuntime_3.19.msi"
		
	Function Download_MSI_IR_Installer{
		Invoke-WebRequest -uri $uri -OutFile $out
	}
		
	Function Install_IR{
		$FileExists = Test-Path $msifile -IsValid
		$DataStamp = get-date -Format yyyyMMddTHHmmss
		$logFile = '{0}-{1}.log' -f $msifile.fullname,$DataStamp
		$MSIArguments = @(
			"/i"
			('"{0}"' -f $msifile.fullname)
			"/qn"
			"/norestart"
			"/L*v"
			$logFile
		)
		
		If ($FileExists -eq $True)
		{
			write-host "Starting Installation"
			Start-Process "msiexec.exe" -ArgumentList $MSIArguments -passthru | wait-process
			write-host "Finished msi "$msifile
		}

		Else {Write-Host "File doesn't exists"}
	
	
Write-Host "Please wait while I download the installer..."
Download_MSI_IR_Installer -wait-process

# Sets the path
$msifile = Get-ChildItem -Path $out -File -Filter '*.ms*' 
	write-host "Found Azure Integration Runtime MSI $msifile"

# Installs the application
Install_IR -wait-process

	# cleanup by removing install file
		Remove-Item –path $out –recurse
	EOH
end

execute 'register-IR' do
	command 'command_to_run'
	# register IR
		cd "C:\Program Files\Microsoft Integration Runtime\3.0\Shared"
		Start ConfigManager.exe
		#$IRkey = node['IRkey']
		start dmgcmd.exe -RegisterNewNode $IRkey -EnableRemoteAccess "443" -Key $IRkey -Start -StartUpgradeService -TurnOnAutoUpdate 
end