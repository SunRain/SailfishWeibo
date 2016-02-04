
@ECHO OFF
set MER_SSH_SHARED_HOME=C:/Project
::Source tree directory is usually the working directory
set SOURCE_TREE=SailfishWeibo/src/QSinaWeiboApi/QWeiboSDK/HackLogin/htmlcxx

::Directory relative to the shared home folder of the SDK
set SOURCE_RELATIVE=%MER_SSH_SHARED_HOME%/%SOURCE_TREE%

::Relative path of source tree in SDK VM
set TARGET_PATH=%SOURCE_RELATIVE%

::Set this to "SailfishOS Device" or whatever target you
::want to deploy your application to.
set DEPLOYMENT_DEVICE="SailfishOS Emulator"

set MER_SSH_PORT=2222
set MER_SSH_USERNAME=mersdk
set MER_SSH_PRIVATE_KEY=C:/SailfishOS/vmshare/ssh/private_keys/engine/mersdk

set SSH_BIN="C:\Program Files\Git\usr\bin\ssh.exe"

set MER_SSH_TARGET_NAME=SailfishOS-armv7hl
set SSH_EXEC=%SSH_BIN% -p %MER_SSH_PORT% -l %MER_SSH_USERNAME% -i %MER_SSH_PRIVATE_KEY% localhost 

::ECHO %SSH_EXEC%
::ECHO %TARGET_PATH%
::echo ../src1/%SOURCE_TREE%/build/../configure

%SSH_EXEC% sb2 -t %MER_SSH_TARGET_NAME% mkdir ../src1/%SOURCE_TREE%/../htmlcxx-build
::%SSH_EXEC% sb2 -t %MER_SSH_TARGET_NAME% sh ../src1/%SOURCE_TREE%/build/../configure --enable-shared --enable-static
%SSH_EXEC% 'cd ../src1/%SOURCE_TREE%/../htmlcxx-build ; sb2 -t %MER_SSH_TARGET_NAME% ../htmlcxx/configure --enable-shared --enable-static; sb2 -t %MER_SSH_TARGET_NAME% make'
::%SSH_EXEC% sb2 -t %MER_SSH_TARGET_NAME% make 
