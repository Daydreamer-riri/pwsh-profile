# pwsh-profile
My pwsh profile

## Usage

First, you should install [**PowerShell**](https://www.microsoft.com/store/productId/9MZ1SNWT0N5D) and [**Oh-My-Posh**](https://apps.microsoft.com/store/detail/XP8K0HKJFRXGCK) through `MS Store` or `Winget`.
Besides that, I am also using GitHub CLI.

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
winget install Microsoft.Powershell -s winget
winget install --id GitHub.cli
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

![image1](https://daydreamer-riri.me/_astro/preview1.08b66b2d_ZPCXpa.webp)
![image2](https://daydreamer-riri.me/_astro/preview2.9ce9352f_2vKlsS.webp)
