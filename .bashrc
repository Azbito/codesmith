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

        create_cpp_format_file
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

    create_cpp_format_file() {
    local PROJECT_NAME=$1

    cat > "$PROJECT_NAME/.clang-format" <<EOL
        [*]
        cpp_indent_braces=false
        cpp_indent_multi_line_relative_to=innermost_parenthesis
        cpp_indent_within_parentheses=indent
        cpp_indent_preserve_within_parentheses=false
        cpp_indent_case_labels=false
        cpp_indent_case_contents=true
        cpp_indent_case_contents_when_block=false
        cpp_indent_lambda_braces_when_parameter=true
        cpp_indent_goto_labels=one_left
        cpp_indent_preprocessor=leftmost_column
        cpp_indent_access_specifiers=false
        cpp_indent_namespace_contents=true
        cpp_indent_preserve_comments=false
        cpp_new_line_before_open_brace_namespace=ignore
        cpp_new_line_before_open_brace_type=ignore
        cpp_new_line_before_open_brace_function=ignore
        cpp_new_line_before_open_brace_block=ignore
        cpp_new_line_before_open_brace_lambda=ignore
        cpp_new_line_scope_braces_on_separate_lines=false
        cpp_new_line_close_brace_same_line_empty_type=false
        cpp_new_line_close_brace_same_line_empty_function=false
        cpp_new_line_before_catch=true
        cpp_new_line_before_else=true
        cpp_new_line_before_while_in_do_while=false
        cpp_space_before_function_open_parenthesis=remove
        cpp_space_within_parameter_list_parentheses=false
        cpp_space_between_empty_parameter_list_parentheses=false
        cpp_space_after_keywords_in_control_flow_statements=true
        cpp_space_within_control_flow_statement_parentheses=false
        cpp_space_before_lambda_open_parenthesis=false
        cpp_space_within_cast_parentheses=false
        cpp_space_after_cast_close_parenthesis=false
        cpp_space_within_expression_parentheses=false
        cpp_space_before_block_open_brace=true
        cpp_space_between_empty_braces=false
        cpp_space_before_initializer_list_open_brace=false
        cpp_space_within_initializer_list_braces=true
        cpp_space_preserve_in_initializer_list=true
        cpp_space_before_open_square_bracket=false
        cpp_space_within_square_brackets=false
        cpp_space_before_empty_square_brackets=false
        cpp_space_between_empty_square_brackets=false
        cpp_space_group_square_brackets=true
        cpp_space_within_lambda_brackets=false
        cpp_space_between_empty_lambda_brackets=false
        cpp_space_before_comma=false
        cpp_space_after_comma=true
        cpp_space_remove_around_member_operators=true
        cpp_space_before_inheritance_colon=true
        cpp_space_before_constructor_colon=true
        cpp_space_remove_before_semicolon=true
        cpp_space_after_semicolon=false
        cpp_space_remove_around_unary_operator=true
        cpp_space_around_binary_operator=insert
        cpp_space_around_assignment_operator=insert
        cpp_space_pointer_reference_alignment=left
        cpp_space_around_ternary_operator=insert
        cpp_wrap_preserve_blocks=one_liners
        cpp_empty_line_between_methods=true
EOL

    print_success "Created .clang-format for $PROJECT_NAME"
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
