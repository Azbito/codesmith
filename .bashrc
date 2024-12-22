codesmith() {
    clear
    
    print_header() {
        MESSAGE=$1
        LINE_LENGTH=46
        MESSAGE_LENGTH=${#MESSAGE}
        
        BORDER="╔═$(printf '%*s' $((LINE_LENGTH-4)))═╗"
        
        PADDING=$(printf '%*s' $(( (LINE_LENGTH - MESSAGE_LENGTH - 2) / 2 )) )
        
        echo -e "\n\e[1;34m$BORDER\e[0m"
        printf "\e[1;34m║$PADDING%s$PADDING ║\e[0m\n" "$MESSAGE"
        echo -e "\e[1;34m╚═$(printf '%*s' $((LINE_LENGTH-4)))═╝\e[0m"
    }

    
    print_success() {
        echo -e "\e[1;32m[✔] $1\e[0m"
    }
    
    print_error() {
        MESSAGE=$1
        LINE_LENGTH=46
        MESSAGE_LENGTH=${#MESSAGE}
        
        BORDER="╔═$(printf '%*s' $((LINE_LENGTH-4)))═╗"
        
        PADDING=$(printf '%*s' $(( (LINE_LENGTH - MESSAGE_LENGTH - 2) / 2 )) )
        
        echo -e "\n\e[1;31m$BORDER\e[0m"
        printf "\e[1;31m║$PADDING%s$PADDING║\e[0m\n" "$MESSAGE"
        echo -e "\e[1;31m╚═$(printf '%*s' $((LINE_LENGTH-4)))═╝\e[0m"
    }

    if [ "$1" == "commit" ]; then
        commit_msg=$2
        if [ -z "$commit_msg" ]; then
            print_error "Please provide a commit message."
            return 1
        fi

        git add .
        git commit -m "$commit_msg"
        git push
        print_success "Changes committed successfully with message: $commit_msg"
        return 0
    fi

    LANGUAGE=$1
    PROJECT_NAME=$2

    if [ -z "$PROJECT_NAME" ]; then
        print_error "Please provide a project name."
        return 1
    fi

    
    if [ "$LANGUAGE" == "cpp" ]; then
        print_header "Initializing C++ Project: $PROJECT_NAME"

        
        mkdir -p "$PROJECT_NAME/src"
        mkdir -p "$PROJECT_NAME/build"
        mkdir -p "$PROJECT_NAME/.vscode"
        print_success "Directories created successfully."

        
        cat > "$PROJECT_NAME/src/main.cpp" <<EOL
#include <iostream>

int main() {
    std::cout << "Hello, $PROJECT_NAME!" << std::endl;
    return 0;
}
EOL
        print_success "Created src/main.cpp"

        
        cat > "$PROJECT_NAME/src/DLLMain.h" <<EOL
#ifndef DLLMain_H
#define DLLMain_H

#ifdef DLLMain_EXPORTS
    #define DLLMain_API __declspec(dllexport)
#else
    #define DLLMain_API __declspec(dllimport)
#endif

extern "C" {
    DLLMain_API void say_hello();
}

#endif // DLLMain_H
EOL
        print_success "Created src/DLLMain.h"

        
        cat > "$PROJECT_NAME/src/DLLMain.cpp" <<EOL
#include "DLLMain.h"
#include <iostream>

void say_hello() {
    std::cout << "Hello from the DLL!" << std::endl;
}
EOL
        print_success "Created src/DLLMain.cpp"

        cat > "$PROJECT_NAME/.vscode/cppproperties.json" <<EOL
{
    "configurations": [
        {
            "name": "Win32",
            "includePath": [
                "\${workspaceFolder}/**",
                "C:/path/to/your/include"
            ],
            "defines": [],
            "compilerPath": "C:/path/to/g++",
            "cStandard": "c11",
            "cppStandard": "c++17",
            "intelliSenseMode": "gcc-x86",
            "browse": {
                "path": [
                    "\${workspaceFolder}/**",
                    "C:/path/to/your/include"
                ],
                "limitSymbolsToIncludedHeaders": true
            }
        }
    ],
    "version": 4
}
EOL
        print_success "Created .vscode/cppproperties.json"

        cat > "$PROJECT_NAME/.vscode/tasks.json" <<EOL
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "g++",
            "args": [
                "-g",
                "\${workspaceFolder}/src/*.cpp",
                "-o",
                "\${workspaceFolder}/build/\${workspaceFolderBasename}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
EOL
        print_success "Created .vscode/tasks.json"

        cat > "$PROJECT_NAME/.vscode/launch.json" <<EOL
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug (gdb)",
            "type": "cppdbg",
            "request": "launch",
            "program": "\${workspaceFolder}/build/\${workspaceFolderBasename}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "\${workspaceFolder}",
            "environment": [],
            "externalConsole": true,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "miDebuggerPath": "/usr/bin/gdb",
            "preLaunchTask": "build",
            "serverLaunchTimeout": 2000,
            "logging": {
                "moduleLoad": false,
                "trace": true,
                "engineLogging": false
            },
            "windows": {
                "MIMode": "gdb",
                "miDebuggerPath": "C:/path/to/gdb.exe"
            }
        }
    ]
}
EOL
        print_success "Created .vscode/launch.json"

        echo -e "\n\e[1;35m**********************************************\e[0m"
        echo -e "\e[1;35m*  Happy Hacking, $PROJECT_NAME! 🚀✨     *\e[0m"
        echo -e "\e[1;35m**********************************************\e[0m"
        echo -e "\e[1;32mYou can now open your project in VSCode and start developing! 💻🎉\e[0m"
        echo -e "\e[1;33mMay the code be with you! 👾💻\e[0m"

    elif [ "$LANGUAGE" == "lua" ]; then
        print_header "Initializing Lua Project: $PROJECT_NAME"
        
        mkdir -p "$PROJECT_NAME/src/modules"
        mkdir -p "$PROJECT_NAME/.vscode"
        print_success "Directories created successfully."

        cat > "$PROJECT_NAME/src/main.lua" <<EOL
-- main.lua for $PROJECT_NAME

print("Hello, $PROJECT_NAME! Starting your Lua project.")

-- Requiring the 'example' module
local example = require("modules.example")

-- Calling the 'say_hello' function from the 'example' module
example.say_hello()
EOL
        print_success "Created src/main.lua"

        cat > "$PROJECT_NAME/src/modules/example.lua" <<EOL
-- example.lua

local M = {}

function M.say_hello()
    print("Hello from the Example module!")
end

return M
EOL
        print_success "Created src/modules/example.lua"

        cat > "$PROJECT_NAME/.vscode/settings.json" <<EOL
{
    "files.associations": {
        "*.lua": "lua"
    },
    "editor.tabSize": 2,
    "editor.insertSpaces": true
}
EOL
        print_success "Created .vscode/settings.json"

        cat > "$PROJECT_NAME/.vscode/launch.json" <<EOL
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Lua Debug",
            "type": "lua",
            "request": "launch",
            "program": "\${workspaceFolder}/src/main.lua"
        }
    ]
}
EOL
        print_success "Created .vscode/settings.json"

        echo -e "\n\e[1;35m**********************************************\e[0m"
        echo -e "\e[1;35m*  Happy Hacking, $PROJECT_NAME! 🚀✨     *\e[0m"
        echo -e "\e[1;35m**********************************************\e[0m"
        echo -e "\e[1;32mYou can now open your Lua project in VSCode and start coding! 💻🎉\e[0m"
        echo -e "\e[1;33mMay the code be with you! 👾💻\e[0m"

    else
        print_error "Unsupported language: $LANGUAGE"
        return 1
    fi
}