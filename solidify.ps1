# == BEGIN SCRIPT SETTINGS

# Deny creation of new profiles. Don't remember cookies,
# passwords and history. Install uBlock Origin.
$SolidifyChrome = $true

# Prevent changing/setting passwords, account picture,
# lock screen, wallpaper.
$SolidifyUser = $true

# Disable creation of new users, signing in with a 
# Microsoft account and disable writing to USBs.
$SolidfyMachine = $true


# == END SCRIPT SETTINGS
# Do not touch the script bellow unless you know what you are doing!
#  If you do know, make a pull request :)

# Solidify Chrome
if ($SolidifyChrome) {
    $chromePolicy = @{
        "Profile.default_content_settings.popups" = 0
        "Profile.default_content_settings.cookies" = 2
        "Profile.default_content_settings.history" = 2
        "Profile.managed_default_content_settings.images" = 2
        "Profile.managed_default_content_settings.javascript" = 2
    }

    # Install uBlock Origin using Chrome extension ID
    $ublockExtensionId = "cjpalhdlnbpafiamejdnhcphjbkeiagm"
    $ublockChromeUrl = "https://clients2.google.com/service/update2/crx?response=redirect&os=win&arch=x86-64&nacl_arch=x86-64&prod=chromiumcrx&prodchannel=stable&prodversion=100.0.4324.182&x=id%3D$ublockExtensionId%26installsource%3Dondemand%26uc"

    Write-Host "Solidifying Chrome settings..."
    $chromePolicy.GetEnumerator() | ForEach-Object {
        Write-Host "Setting Chrome policy: $($_.Key) = $($_.Value)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name $($_.Key) -Value $($_.Value)
    }

    Write-Host "Installing uBlock Origin..."
    Invoke-WebRequest -Uri $ublockChromeUrl -OutFile "$env:TEMP\ublock_origin.crx"
    Start-Process -FilePath "chrome.exe" -ArgumentList "--allow-outdated-plugins --allow-running-insecure-content --load-extension='$env:TEMP\ublock_origin.crx'" -Wait
    Remove-Item -Path "$env:TEMP\ublock_origin.crx" -Force
}

# Solidify User settings
if ($SolidifyUser) {
    Write-Host "Solidifying User settings..."

    # Prevent changing password
    Write-Host "Disallowing password change..."
    $securityPolicy = Get-WmiObject -Class Win32_AccountSecuritySetting | Where-Object { $_.Element -eq "Password" }
    $securityPolicy.ControlFlags += 16
    $securityPolicy.Put()

    # Prevent changing account picture
    Write-Host "Disallowing account picture change..."
    $accountPictureRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (-not (Test-Path $accountPictureRegPath)) {
        New-Item -Path $accountPictureRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $accountPictureRegPath -Name "NoChangeAccountPicture" -Value 1

    # Prevent changing lock screen image
    Write-Host "Disallowing lock screen image change..."
    $lockScreenRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $lockScreenRegPath)) {
        New-Item -Path $lockScreenRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $lockScreenRegPath -Name "DisableLockScreenAppNotifications" -Value 1

    # Prevent changing wallpaper
    Write-Host "Disallowing wallpaper change..."
    $wallpaperRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
    if (-not (Test-Path $wallpaperRegPath)) {
        New-Item -Path $wallpaperRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $wallpaperRegPath -Name "NoChangingWallPaper" -Value 1
}

# Solidify Machine settings
if ($SolidifyMachine) {
    Write-Host "Solidifying Machine settings..."

    # Disable creation of new users
    Write-Host "Disallowing user creation..."
    $userCreationRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $userCreationRegPath)) {
        New-Item -Path $userCreationRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $userCreationRegPath -Name "NewUsername" -Value 0

    # Disable signing in with a Microsoft account
    Write-Host "Disallowing signing in with a Microsoft account..."
    $microsoftAccountRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $microsoftAccountRegPath)) {
        New-Item -Path $microsoftAccountRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $microsoftAccountRegPath -Name "MSAOptional" -Value 0

    # Disable writing to USBs
    Write-Host "Disallowing writing to USBs..."
    $usbWritingRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies"
    if (-not (Test-Path $usbWritingRegPath)) {
        New-Item -Path $usbWritingRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $usbWritingRegPath -Name "WriteProtect" -Value 1
}