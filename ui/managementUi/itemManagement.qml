import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts


ColumnLayout {
    id: mainColumn

    signal openManage()

    anchors.fill: parent
    anchors.margins: 8
    spacing: 8

    Item {
        id: root

        ListModel {
            id: itemModel
        }

        function loadItems() {
            itemModel.clear()

            var items = databaseManager.getItems()

            for (var i = 0; i < items.length; i++) {
                itemModel.append(items[i])
            }
        }

        Component.onCompleted: {
            loadItems()
        }
        SearchPopup {
            id: itemSearchPopup

            sourceModel: itemModel

            onItemSelected: function(item) {
                itemIdField.text = item.itemId
                itemNameField.text = item.itemName

                brandField.text = item.brand
                categoryField.text = item.category

                descField.text = item.description

                stockField.text = item.stock
                // qtyTypeCombo.currentIndex = qtyTypeCombo.find(item.qtyType)

                buyPriceField.text = item.buyPrice
                sellPriceField.text = item.sellPrice
            }
        }
    }





    Rectangle {
        id: formPanel
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#093C5D"
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            RowLayout {

                Label {
                    text: "Search"
                    Layout.preferredWidth: 120
                }

                TextField {
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }}

                Button {
                    id: searchButton
                    text: "Search"
                    Layout.preferredWidth: 100

                    background: Rectangle {
                        anchors.centerIn: parent
                        radius: 10
                        color: searchButton.pressed ? "#093C5D" : "#3B7597"
                        width: 60
                        height: 60
                        }
                    onClicked: itemSearchPopup.openSearch(itemModel)
                }
            }

            RowLayout {

                Label {
                    text: "Item ID"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: itemIdField
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Item Name"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: itemNameField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Brand"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: brandField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Category"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: categoryField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Buy Price"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: buyPriceField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                    Layout.rightMargin: 20
                }

                Label {
                    text: "Buy Price"
                    Layout.preferredWidth: 120
                }
                TextField {
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Sell Price"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: sellPriceField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                    Layout.rightMargin: 20
                }

                Label {
                    text: "Sell Price"
                    Layout.preferredWidth: 120
                }
                TextField {
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Desc"
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: descField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {
                spacing: 20

                ColumnLayout {
                    Label {
                        text: "Stock"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        id: stockField
                        Layout.preferredWidth: 45
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Qty Type"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        id: qtyTypeField
                        Layout.preferredWidth: 70
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Qty"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 70
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                Button {
                    text: "Add"
                    Layout.alignment: Qt.AlignBottom

                    onClicked: {
                            const ok = databaseManager.addItem(
                                itemIdField.text,
                                itemNameField.text,
                                brandField.text,
                                categoryField.text,
                                Number(buyPriceField.text),
                                Number(sellPriceField.text),
                                descField.text,
                                Number(stockField.text),
                                qtyTypeField.text
                            )

                            if (ok) {
                                console.log("Item saved")
                            } else {
                                console.log("Failed to save item")
                            }
                        }
                }

                Button {
                    text: "EEE"
                    Layout.alignment: Qt.AlignBottom
                    onClicked: mainColumn.openManage()
                }
            }
        }
    }
}

