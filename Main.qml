import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "ui"

ApplicationWindow {
    width: 1400
    height: 800
    visible: true
    title: qsTr("Basic Cashier")


    Loader {
        id: pageLoader
        anchors.fill: parent
        source: "ui/MainMenu.qml"

        onLoaded: {
            if (!item) return

            if (item.openCashier) {
                item.openCashier.connect(function() {
                    pageLoader.source = "ui/Cashier.qml"
                })
            }

            if (item.openAbout) {
                item.openAbout.connect(function() {
                    pageLoader.source = "ui/About.qml"
                })
            }

            if (item.openManage) {
                item.openManage.connect(function() {
                    pageLoader.source = "ui/Manage.qml"
                })
            }

            if (item.openItemManagement) {
                item.openItemManagement.connect(function() {
                    pageLoader.source = "ui/managementUi/itemManagement.qml"
                })
            }

            if (item.openCustomerManagement) {
                item.openCustomerManagement.connect(function() {
                    pageLoader.source = "ui/managementUi/customerManagement.qml"
                })
            }

            if (item.openDatabaseManagement) {
                item.openDatabaseManagement.connect(function() {
                    pageLoader.source = "ui/managementUi/databaseManagement.qml"
                })
            }

            if (item.openTransactionManagement) {
                item.openTransactionManagement.connect(function() {
                    pageLoader.source = "ui/managementUi/transactionManagement.qml"
                })
            }

            // ===== SHARED BACK =====
            if (item.backToMainMenu) {
                item.backToMainMenu.connect(function() {
                    pageLoader.source = "ui/MainMenu.qml"
                })
            }
        }
    }
}