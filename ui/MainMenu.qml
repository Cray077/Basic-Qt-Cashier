import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: mainColumn

    signal openCashier()
    signal openAbout()
    signal openManage()

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
            id: cartButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: cartButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
                }

            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/shopping-cart.png"   // your icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }
            onClicked: mainColumn.openCashier()
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
            onClicked: openManage()
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
            id: aboutButton
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            background: Rectangle {
                anchors.centerIn: parent
                radius: 10
                color: aboutButton.pressed ? "#093C5D" : "#3B7597"
                width: 60
                height: 60
                }



            contentItem: Item {
                anchors.fill: parent

                Image {
                    anchors.centerIn: parent
                    source: "assets/about.png"   // your icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
            }
            onClicked: mainColumn.openAbout()
        }
    }
}