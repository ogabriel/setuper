source $lib_dir/helper_functions.sh

CheckPermissons
DefineDistro

source $lib_dir/config/main.sh

LoadConfig

source $lib_dir/handler/main.sh

HandleFlatpakPackages
HandleASDFDependencies

HandlePackages
HandleSourcedPackages

HandleASDFInstall
HandleASDFPlugins

HandleSystemFiles
HandleSystemFilesFromTo
HandleSystemDirectories
HandleSystemDirectoriesFromTo

HandleGroups
HandleUsers

HandleUserFiles
HandleUserFilesFromTo
HandleUserDirectories
HandleUserDirectoriesFromTo

HandleSystemdUnits

HandleSSHGenKeys
HandleSSHAddkeys

Info "Installation complete"
