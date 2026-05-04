cmake_minimum_required(VERSION 3.16)

project(Basic_Qt_Cashier VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appBasic_Qt_Cashier
    main.cpp
)

qt_add_qml_module(appBasic_Qt_Cashier
    URI Basic_Qt_Cashier
    QML_FILES

        RESOURCES references
        QML_FILES
        QML_FILES
        QML_FILES Main.qml
        QML_FILES ui/Cashier.qml
        QML_FILES ui/About.qml ui/MainMenu.qml
        RESOURCES "random stuff/todo.txt"
        RESOURCES ui/assets/shopping-cart.png
        RESOURCES ui/assets/about.png ui/assets/manage.png ui/assets/options.png
        QML_FILES ui/Manage.qml
        QML_FILES ui/managementUi/itemManagement.qml
        RESOURCES ui/assets/item.png
        RESOURCES ui/assets/back.png
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appBasic_Qt_Cashier PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBasic_Qt_Cashier
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appBasic_Qt_Cashier
    PRIVATE Qt6::Quick
)

install(TARGETS appBasic_Qt_Cashier
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
