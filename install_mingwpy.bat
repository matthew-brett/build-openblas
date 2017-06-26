REM Install mingwpy
set PATH=C:\msys64\usr\bin;%PATH%
pacman -Sy --noconfirm p7zip
curl -L "%MINGWPY_URL%/%GCC_FNAME%" -o gcc.7z
bash -c "7z x gcc.7z"
