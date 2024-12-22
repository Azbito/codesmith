codesmith() {
    clear

    print_header() {
        local MESSAGE=$1
        local LINE_LENGTH=46
        local MESSAGE_LENGTH=${#MESSAGE}

        local BORDER="╔═$(printf '%*s' $((LINE_LENGTH-4)))═╗"
        local PADDING=$(printf '%*s' $(( (LINE_LENGTH - MESSAGE_LENGTH - 2) / 2 )) )

        echo -e "\n\e[1;34m$BORDER\e[0m"
        printf "\e[1;34m║%s%s%s║\e[0m\n" "$PADDING" "$MESSAGE" "$PADDING"
        echo -e "\e[1;34m╚═$(printf '%*s' $((LINE_LENGTH-4)))═╝\e[0m"
    }

    print_success() {
        echo -e "\e[1;32m[✔] $1\e[0m"
    }

    print_error() {
        local MESSAGE=$1
        local LINE_LENGTH=46
        local MESSAGE_LENGTH=${#MESSAGE}

        local BORDER="╔═$(printf '%*s' $((LINE_LENGTH-4)))═╗"
        local PADDING=$(printf '%*s' $(( (LINE_LENGTH - MESSAGE_LENGTH - 2) / 2 )) )

        echo -e "\n\e[1;31m$BORDER\e[0m"
        printf "\e[1;31m║%s%s%s║\e[0m\n" "$PADDING" "$MESSAGE" "$PADDING"
        echo -e "\e[1;31m╚═$(printf '%*s' $((LINE_LENGTH-4)))═╝\e[0m"
    }

    handle_commit() {
        local commit_msg=$1
        if [ -z "$commit_msg" ]; then
            print_error "Please provide a commit message."
            return 1
        fi

        git add .
        git commit -m "$commit_msg"
        git push
        print_success "Changes committed successfully with message: $commit_msg"
        return 0
    }

    init_cpp_project() {
        local PROJECT_NAME=$1
        local IS_DLL=$2

        if [ "$IS_DLL" == "-dll" ]; then
            print_header "Initializing C++ DLL Project: $PROJECT_NAME"
            mkdir -p "$PROJECT_NAME/src" "$PROJECT_NAME/include" "$PROJECT_NAME/build" "$PROJECT_NAME/.vscode"
            create_cpp_files_dll "$PROJECT_NAME"
            create_vscode_cpp_dll_config "$PROJECT_NAME"
        else
            print_header "Initializing C++ Executable Project: $PROJECT_NAME"
            mkdir -p "$PROJECT_NAME/src" "$PROJECT_NAME/build" "$PROJECT_NAME/.vscode"
            create_cpp_files_exe "$PROJECT_NAME"
            create_vscode_cpp_exe_config "$PROJECT_NAME"
        fi

        print_footer "$PROJECT_NAME"
    }

    create_cpp_files_dll() {
        local PROJECT_NAME=$1

        cat > "$PROJECT_NAME/src/DLLMain.cpp" <<EOL
#include "DLLMain.h"
#include <iostream>
#include <windows.h>

DLLMain_API void say_hello() {
    std::cout << "Hello from the attached process DLL!" << std::endl;
}

extern "C" BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        std::cout << "DLL attached to process!" << std::endl;
        say_hello();
    } else if (ul_reason_for_call == DLL_PROCESS_DETACH) {
        std::cout << "DLL detached from process!" << std::endl;
    }
    return TRUE;
}
EOL

        cat > "$PROJECT_NAME/include/DLLMain.h" <<EOL
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

        print_success "Created DLL files for $PROJECT_NAME"
    }

    create_cpp_files_exe() {
        local PROJECT_NAME=$1

        cat > "$PROJECT_NAME/src/main.cpp" <<EOL
#include <iostream>

int main() {
    std::cout << "Hello, $PROJECT_NAME!" << std::endl;
    return 0;
}
EOL

        print_success "Created main.cpp for $PROJECT_NAME"
    }

    create_vscode_cpp_dll_config() {
        local PROJECT_NAME=$1

        cat > "$PROJECT_NAME/.vscode/tasks.json" <<EOL
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "g++",
            "args": [
                "-shared",
                "-o",
                "build/$PROJECT_NAME.dll",
                "src/DLLMain.cpp"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
EOL
        print_success "Created tasks.json for DLL project"
    }

    create_vscode_cpp_exe_config() {
        local PROJECT_NAME=$1

        cat > "$PROJECT_NAME/.vscode/tasks.json" <<EOL
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "g++",
            "args": [
                "-o",
                "build/$PROJECT_NAME.exe",
                "src/main.cpp"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
EOL
        print_success "Created tasks.json for Executable project"
    }

    print_footer() {
        local PROJECT_NAME=$1

        echo -e "\n\e[1;35m**********************************************\e[0m"
        echo -e "\e[1;35m*  Happy Hacking, $PROJECT_NAME! 🚀✨     *\e[0m"
        echo -e "\e[1;35m**********************************************\e[0m"
        echo -e "\e[1;32mYou can now open your project in VSCode and start coding! 💻🎉\e[0m"
        echo -e "\e[1;33mMay the code be with you! 👾💻\e[0m"
    }

    if [ "$1" == "commit" ]; then
        handle_commit "$2"
    elif [ "$1" == "cpp" ]; then
        init_cpp_project "$2" "$3"
    else
        print_error "Unsupported language or action: $1"
        return 1
    fi
}
