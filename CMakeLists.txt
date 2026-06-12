cmake_minimum_required(VERSION 3.10)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)
project(dynamic-data-masking
        VERSION 0.1
        DESCRIPTION "a dynamic data masking system"
        LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(server
        src/dynamic_main.cpp
        src/MysqlOperator.cpp
        src/BaseDetector.cpp
        src/PhoneDetector.cpp
        src/DetectorManager.cpp
        src/BaseMasking.cpp
        src/StarMasking.cpp
        src/AddressMasking.cpp
        src/SensitiveFieldsManager.cpp
        src/EmailMasking.cpp
        src/GeneralizationMasking.cpp
        src/DbField.cpp
        src/DbTable.cpp
        src/StructureMasking.cpp
        src/ReplaceMasking.cpp
        src/NoiseMasking.cpp
        src/AccountManager.cpp)

target_include_directories(server PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/include)

target_link_libraries(server PRIVATE
        event
        mysqlclient
        sqlparser
        sodium)

if(UNIX)
        target_link_libraries(server PRIVATE m)
endif()
