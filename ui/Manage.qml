import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: mainColumn

    signal backToMainMenu()

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
            id: itemButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: itemButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
                }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/item.png"   // your icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }
            // onClicked: mainColumn.openCashier()
        }


        Button {
            id: manageButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: manageButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
                }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/manage.png"   // your icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        Button {
            id: optionsButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: optionsButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
                }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/options.png"   // your icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }
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
                    source: "assets/back.png"   // your icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }
            onClicked: mainColumn.backToMainMenu()
        }
    }
}