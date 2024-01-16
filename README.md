# Setup Documentation

The entire setup was done using **root** user.




1) Create the folders `/opt/restic/bin` and `/opt/restic/config`

2) Copy the scripts into `/opt/restic/bin/`

3) Copy `env.example.sh` to `/opt/restic/config/env.sh`

4) Build the wrapper scripts

5) In the **ResticWrapper** folder, build the wrapper scripts as follows:

     1) `xcodebuild -scheme ResticCheckWrapper -derivedDataPath ./build -configuration Release build`
     2) `xcodebuild -scheme ResticBackupWrapper -derivedDataPath ./build -configuration Release build`

6) Copy the wrapper scripts into `/opt/restic` using:

        1) `cp build/Build/Products/Release/ResticBackupWrapper /opt/restic/bin`
              2) `cp build/Build/Products/Release/ResticCheckWrapper /opt/restic/bin`

7) Manually create a new entry in the System Keychain

   1) Open Keychain.app and select **System"**
   2) Click on **Create new Keychain item**
   3) Fill in the following:
       1) Name: **de.fnordlab.ResticWrapper.repository-password**
       2) Account Name: **repository-password**
       3) Account Password: **\<Restic Repository Password\>**
   4) Save the entry
   5) Search for the newly created entry using its name
   6) Open the entry and add the `ResticBackupWrapper` and `ResticCheckWrapper` to the applications that are always allowed

8) Give `restic` and `ResticBackupWrapper` **Full Disk Access**

9) Create the folders

        - `/Library/Logs/restic`

        - `/Library/Caches/restic`

10) Create a SSH Key and register the public key at the target. The SSH key must not have a password. This needs to be improved in the future