# SSH Configuration
This documenations is just a reminder how to setup ssh correclty on the windows systems.

## 1. Create ssh key
With puttygen you can create a key store the keys securly and dont lose them.
## 2. Add the ssh key
Add the ssh key to the provider (Github, Gitlab)
## 3. Install git
Install git on windows

[Git on windows](https://git-scm.com/downloads)
## 4. Create config
Navigate to C:\users\%username%\.ssh and create a config file called config and add the content like below (update the placeholders)

In the following example i have a hosted git server and the public github version
```
Host git-01.yourdomain.com
   Hostname git-01
   user alain.seys
   IdentityFile "FULL_PATH_TO_YOUR_KEY" 

Host github.com
    Hostname github.com
    User git
    IdentityFile "FULL_PATH_TO_YOUR_KEY"
    PreferredAuthentications publickey
```