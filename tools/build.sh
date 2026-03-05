bun build --compile --target=bun-windows-arm64 ./tools/installer.ts --outfile ./tools/bin/ManaoManager_Windows_Arm64.exe
bun build --compile --target=bun-linux-arm64 ./tools/installer.ts --outfile ./tools/bin/ManaoManager_Linux_Arm64
bun build --compile --target=bun-darwin-arm64 ./tools/installer.ts --outfile ./tools/bin/ManaoManager_Darwin_Arm64
bun build --compile --target=bun-windows-x64 ./tools/installer.ts --outfile ./tools/bin/ManaoManager_Windows_x64.exe
bun build --compile --target=bun-linux-x64 ./tools/installer.ts --outfile ./tools/bin/ManaoManager_Linux_x64
bun build --compile --target=bun-darwin-x64 ./tools/installer.ts --outfile ./tools/bin/ManaoManager_Darwin_x64