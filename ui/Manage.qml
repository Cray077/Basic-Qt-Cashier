import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: mainColumn

    signal backToMainMenu()
    signal openItemManagement()
    signal openCustomerManagement()
    signal openDatabaseManagement()
    signal openTransactionManagement()

    anchors.fill: parent
    anchors.centerIn: parent
    anchors.margins: 8
    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        Label {
            text: "Welcome"
            font.pixelSize: 40
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 100

        Button {
            id: itemManagementButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: itemManagementButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
            }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/item.png"
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }

            onClicked: mainColumn.openItemManagement()
        }

        Button {
            id: customerManagementButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: customerManagementButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
            }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/customer.png"
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }

            onClicked: mainColumn.openCustomerManagement()
        }

        Button {
            id: databaseManagementButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: databaseManagementButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
            }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/database-storage.png"
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }

            onClicked: mainColumn.openDatabaseManagement()
        }

        Button {
            id: transactionManagementButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: transactionManagementButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
            }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/transaction.png"
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }

            onClicked: mainColumn.openTransactionManagement()
        }

        Button {
            id: backButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: backButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
            }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/back.png"
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }

            onClicked: mainColumn.backToMainMenu()
        }
    }
}