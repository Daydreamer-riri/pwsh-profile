# pwsh-profile
My pwsh profile

## Usage

First, you should install [**PowerShell**](https://www.microsoft.com/store/productId/9MZ1SNWT0N5D) and [**Oh-My-Posh**](https://apps.microsoft.com/store/detail/XP8K0HKJFRXGCK) through `MS Store` or `Winget`.

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
winget install Microsoft.Powershell -s winget
```

This profile requires the installation of the following three modules.

```powershell
Install-Module -Name z -Force
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
```
> PSReadLine is built-in

## Edit Profile
```powershell
nvim $PROFILE.CurrentUserCurrentHost
```

and enter the init line
```ps1
. $env:USERPROFILE\.config\pwsh-profile\user_profile.ps1
```

## Preview

![image](https://user-images.githubusercontent.com/70067449/236636808-749ac5b4-54c1-455f-a38c-c87476d8bf74.png)
