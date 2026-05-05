import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root

    signal backToMainMenu()

    Connections {
        target: databaseManager

        function onDatabaseError(message) {
            console.log("DATABASE ERROR:", message)
        }
    }

    anchors.fill: parent
    anchors.margins: 8
    spacing: 8

    property int currentTransactionId: -1
    property int selectedCartIndex: -1

    ListModel { id: itemModel }
    ListModel { id: transactionModel }
    ListModel { id: cartModel }

    function toNumber(value) {
        var n = Number(value)
        return isNaN(n) ? 0 : n
    }

    function loadItems() {
        itemModel.clear()

        if (typeof databaseManager === "undefined" || databaseManager === null) {
            console.log("databaseManager is not available")
            return
        }

        var items = databaseManager.getItems()
        for (var i = 0; i < items.length; i++)
            itemModel.append(items[i])
    }

    function loadTransactions() {
        transactionModel.clear()

        if (typeof databaseManager === "undefined" || databaseManager === null) {
            console.log("databaseManager is not available")
            return
        }

        var rows = databaseManager.getTransactions()
        for (var i = 0; i < rows.length; i++)
            transactionModel.append(rows[i])
    }

    function clearTransactionFields() {
        currentTransactionId = -1
        invoiceNoField.text = ""
        dateField.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
        customerNameField.text = ""
        taxField.text = "0"
        totalDiscountField.text = "0"
        cashField.text = "0"
        totalField.text = "0"
        finalTotalField.text = "0"
        debtField.text = "0"
        dueDateField.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
        cartModel.clear()
        selectedCartIndex = -1
        clearItemFields()
    }

    function clearItemFields() {
        itemIdField.text = ""
        itemNameField.text = ""
        descField.text = ""
        stockField.text = ""
        qtyTypeField.text = ""
        qtyField.text = "1"
        priceField.text = "0"
        discountField.text = "0"
        addedDescriptionField.text = ""
        subTotalField.text = "0"
        selectedCartIndex = -1
    }

    function calculateLineSubtotal() {
        var subtotal = (toNumber(priceField.text) * toNumber(qtyField.text)) - toNumber(discountField.text)
        subTotalField.text = Math.max(0, subtotal).toFixed(2)
    }

    function updateTotals() {
        var subtotal = 0
        for (var i = 0; i < cartModel.count; i++)
            subtotal += toNumber(cartModel.get(i).subtotal)

        var tax = toNumber(taxField.text)
        var discount = toNumber(totalDiscountField.text)
        var total = Math.max(0, subtotal + tax - discount)
        var cash = toNumber(cashField.text)
        var debt = Math.max(0, total - cash)

        totalField.text = subtotal.toFixed(2)
        finalTotalField.text = total.toFixed(2)
        debtField.text = debt.toFixed(2)
    }

    function cartModelToArray() {
        var items = []

        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i)

            items.push({
                itemId: item.itemId || "",
                itemName: item.itemName || "",
                description: item.description || "",
                qtyType: item.qtyType || "",
                qty: Number(item.qty || 0),
                price: Number(item.price || 0),
                discount: Number(item.discount || 0),
                subtotal: Number(item.subtotal || 0)
            })
        }

        return items
    }

    function addOrUpdateCartItem() {
        if (itemIdField.text.trim() === "" || itemNameField.text.trim() === "") {
            console.log("Select an item first")
            return
        }

        calculateLineSubtotal()

        var row = {
            itemId: itemIdField.text,
            itemName: itemNameField.text,
            description: addedDescriptionField.text.trim() !== "" ? addedDescriptionField.text : descField.text,
            qtyType: qtyTypeField.text,
            qty: Number(qtyField.text),
            price: Number(priceField.text),
            discount: Number(discountField.text),
            subtotal: Number(subTotalField.text)
        }

        if (selectedCartIndex >= 0 && selectedCartIndex < cartModel.count)
            cartModel.set(selectedCartIndex, row)
        else
            cartModel.append(row)

        clearItemFields()
        updateTotals()
    }

    function removeSelectedCartItem() {
        if (selectedCartIndex < 0 || selectedCartIndex >= cartModel.count)
            return

        cartModel.remove(selectedCartIndex)
        selectedCartIndex = -1
        clearItemFields()
        updateTotals()
    }

    function loadCartRow(index) {
        if (index < 0 || index >= cartModel.count)
            return

        selectedCartIndex = index
        var row = cartModel.get(index)

        itemIdField.text = row.itemId
        itemNameField.text = row.itemName
        descField.text = row.description
        stockField.text = ""
        qtyTypeField.text = row.qtyType
        qtyField.text = row.qty
        priceField.text = Number(row.price).toFixed(2)
        discountField.text = Number(row.discount).toFixed(2)
        addedDescriptionField.text = row.description
        subTotalField.text = Number(row.subtotal).toFixed(2)
    }

    function loadTransaction(transaction) {
        currentTransactionId = transaction.id
        invoiceNoField.text = transaction.invoiceNo
        dateField.text = transaction.date
        customerNameField.text = transaction.customerName
        taxField.text = Number(transaction.tax).toFixed(2)
        totalDiscountField.text = Number(transaction.discount).toFixed(2)
        cashField.text = Number(transaction.cash).toFixed(2)

        cartModel.clear()
        selectedCartIndex = -1

        var items = databaseManager.getTransactionItems(transaction.id)

        for (var i = 0; i < items.length; i++) {
            var item = items[i]

            cartModel.append({
                itemId: item.itemId,
                itemName: item.itemName,
                description: item.description,
                qtyType: item.qtyType,
                qty: Number(item.qty),
                price: Number(item.price),
                discount: Number(item.discount),
                subtotal: Number(item.subtotal)
            })
        }

        updateTotals()
        clearItemFields()
    }

    function updateTransaction() {
        if (currentTransactionId < 0) {
            console.log("Search and load a transaction first")
            return
        }

        if (cartModel.count === 0) {
            console.log("Transaction cart is empty")
            return
        }

        updateTotals()

        var ok = databaseManager.updateTransaction(
            currentTransactionId,
            invoiceNoField.text,
            dateField.text,
            customerNameField.text,
            toNumber(totalField.text),
            toNumber(taxField.text),
            toNumber(totalDiscountField.text),
            toNumber(finalTotalField.text),
            toNumber(cashField.text),
            toNumber(debtField.text),
            cartModelToArray()
        )

        if (ok) {
            console.log("Transaction updated")
            loadTransactions()
        } else {
            console.log("Failed to update transaction")
        }
    }

    function deleteCurrentTransaction() {
        if (currentTransactionId < 0) {
            console.log("Search and load a transaction first")
            return
        }

        var ok = databaseManager.deleteTransaction(currentTransactionId)
        if (ok) {
            console.log("Transaction deleted")
            clearTransactionFields()
            loadTransactions()
        } else {
            console.log("Failed to delete transaction")
        }
    }

    Component.onCompleted: {
        loadItems()
        loadTransactions()
        clearTransactionFields()
    }

    SearchPopup {
        id: itemSearchPopup
        sourceModel: itemModel

        onItemSelected: function(item) {
            itemIdField.text = item.itemId
            itemNameField.text = item.itemName
            descField.text = item.description
            stockField.text = item.stock
            qtyTypeField.text = item.qtyType
            qtyField.text = "1"
            priceField.text = item.price !== undefined ? item.price : item.sellPrice
            discountField.text = "0"
            addedDescriptionField.text = ""
            calculateLineSubtotal()
            qtyField.forceActiveFocus()
        }
    }

    Popup {
        id: transactionSearchPopup
        parent: Overlay.overlay
        modal: true
        focus: true
        width: 900
        height: 520
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2) - 20
        padding: 18
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        function openSearch() {
            transactionSearchText.text = ""
            transactionSearchPopup.rebuildTransactionFilter()
            open()
            transactionSearchText.forceActiveFocus()
        }

        background: Rectangle {
            color: "#093C5D"
            radius: 8
            border.color: "#5DF8D8"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Search Transactions"
                    color: "white"
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                }
                Button { text: "Refresh"; onClicked: { loadTransactions(); transactionSearchPopup.rebuildTransactionFilter() } }
                Button { text: "X"; onClicked: transactionSearchPopup.close() }
            }

            TextField {
                id: transactionSearchText
                Layout.fillWidth: true
                placeholderText: "Search by invoice, customer, date, total..."
                color: "#5DF8D8"
                selectByMouse: true
                background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 4 }
                onTextChanged: transactionSearchPopup.rebuildTransactionFilter()
            }

            Rectangle {
                Layout.fillWidth: true
                height: 34
                color: "#062A42"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Label { text: "Invoice"; color: "white"; font.bold: true; Layout.preferredWidth: 150 }
                    Label { text: "Date"; color: "white"; font.bold: true; Layout.preferredWidth: 130 }
                    Label { text: "Customer"; color: "white"; font.bold: true; Layout.fillWidth: true }
                    Label { text: "Total"; color: "white"; font.bold: true; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                    Label { text: "Cash"; color: "white"; font.bold: true; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                    Label { text: "Debt"; color: "white"; font.bold: true; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                }
            }

            ListView {
                id: transactionResultList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: filteredTransactionModel
                currentIndex: 0

                delegate: Rectangle {
                    required property int index
                    required property int id
                    required property string invoiceNo
                    required property string date
                    required property string customerName
                    required property real total
                    required property real cash
                    required property real debt

                    width: transactionResultList.width
                    height: 42
                    color: ListView.isCurrentItem ? "#2E8AB8" : (transactionMouse.containsMouse ? "#1E638A" : "#0D466B")
                    border.color: "#2E6688"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        Label { text: invoiceNo; color: "#5DF8D8"; Layout.preferredWidth: 150; elide: Text.ElideRight }
                        Label { text: date; color: "white"; Layout.preferredWidth: 130; elide: Text.ElideRight }
                        Label { text: customerName; color: "white"; Layout.fillWidth: true; elide: Text.ElideRight }
                        Label { text: Number(total).toFixed(2); color: "white"; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                        Label { text: Number(cash).toFixed(2); color: "white"; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                        Label { text: Number(debt).toFixed(2); color: "white"; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                    }

                    MouseArea {
                        id: transactionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: transactionResultList.currentIndex = index
                        onDoubleClicked: transactionSearchPopup.chooseTransaction()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label { text: filteredTransactionModel.count + " result(s)"; color: "#D8F7FF"; Layout.fillWidth: true }
                Button { text: "Load"; enabled: filteredTransactionModel.count > 0; onClicked: transactionSearchPopup.chooseTransaction() }
                Button { text: "Cancel"; onClicked: transactionSearchPopup.close() }
            }
        }

        ListModel { id: filteredTransactionModel }

        function rebuildTransactionFilter() {
            filteredTransactionModel.clear()
            var q = transactionSearchText.text.toLowerCase().trim()

            for (var i = 0; i < transactionModel.count; i++) {
                var row = transactionModel.get(i)
                var haystack = (row.invoiceNo + " " + row.date + " " + row.customerName + " " + row.total + " " + row.cash + " " + row.debt).toLowerCase()
                if (q === "" || haystack.indexOf(q) !== -1)
                    filteredTransactionModel.append(row)
            }

            transactionResultList.currentIndex = filteredTransactionModel.count > 0 ? 0 : -1
        }

        function chooseTransaction() {
            if (transactionResultList.currentIndex < 0 || filteredTransactionModel.count === 0)
                return

            var tx = filteredTransactionModel.get(transactionResultList.currentIndex)
            loadTransaction(tx)
            close()
        }
    }

    Rectangle {
        id: formPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        color: "#093C5D"
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            RowLayout {
                Label { text: "Invoice No."; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: invoiceNoField
                    Layout.preferredWidth: 260
                    readOnly: true
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }

                Button { text: "Search Transaction"; onClicked: transactionSearchPopup.openSearch() }

                Label { text: "Date"; color: "white"; Layout.preferredWidth: 60 }
                TextField {
                    id: dateField
                    Layout.preferredWidth: 180
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }

                Label {
                    text: currentTransactionId >= 0 ? "Loaded ID: " + currentTransactionId : "No transaction loaded"
                    color: currentTransactionId >= 0 ? "#5DF8D8" : "#FFD8D8"
                    Layout.leftMargin: 12
                }
            }

            RowLayout {
                Label { text: "Customer name"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: customerNameField
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Item ID"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: itemIdField
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
                Button { text: "Search Item"; onClicked: itemSearchPopup.openSearch(itemModel) }
            }

            RowLayout {
                Label { text: "Item Name"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: itemNameField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Desc"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: descField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                spacing: 18

                ColumnLayout {
                    Label { text: "Stock"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: stockField; Layout.preferredWidth: 60; readOnly: true; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                ColumnLayout {
                    Label { text: "Qty Type"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: qtyTypeField; Layout.preferredWidth: 80; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                ColumnLayout {
                    Label { text: "Qty"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: qtyField; Layout.preferredWidth: 70; text: "1"; color: "#5DF8D8"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextChanged: calculateLineSubtotal(); background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                ColumnLayout {
                    Label { text: "Price"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: priceField; Layout.preferredWidth: 120; text: "0"; color: "#5DF8D8"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextChanged: calculateLineSubtotal(); background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                ColumnLayout {
                    Label { text: "Disc"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: discountField; Layout.preferredWidth: 90; text: "0"; color: "#5DF8D8"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextChanged: calculateLineSubtotal(); background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                ColumnLayout {
                    Label { text: "Added Description"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: addedDescriptionField; Layout.preferredWidth: 260; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                ColumnLayout {
                    Label { text: "Sub Total"; color: "white"; Layout.alignment: Qt.AlignHCenter }
                    TextField { id: subTotalField; Layout.preferredWidth: 160; readOnly: true; text: "0"; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }

                Button { text: selectedCartIndex >= 0 ? "Update Item" : "Add Item"; Layout.alignment: Qt.AlignBottom; onClicked: addOrUpdateCartItem() }
                Button { text: "Remove"; Layout.alignment: Qt.AlignBottom; onClicked: removeSelectedCartItem() }
                Button { text: "Clear"; Layout.alignment: Qt.AlignBottom; onClicked: clearItemFields() }
            }
        }
    }

    Rectangle {
        id: cartPanel
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "white"
        border.color: "#cccccc"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: "#093C5D"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Label { text: "Item ID"; color: "white"; font.bold: true; Layout.preferredWidth: 120 }
                    Label { text: "Item Name"; color: "white"; font.bold: true; Layout.fillWidth: true }
                    Label { text: "Qty"; color: "white"; font.bold: true; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                    Label { text: "Type"; color: "white"; font.bold: true; Layout.preferredWidth: 70 }
                    Label { text: "Price"; color: "white"; font.bold: true; Layout.preferredWidth: 110; horizontalAlignment: Text.AlignRight }
                    Label { text: "Disc"; color: "white"; font.bold: true; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                    Label { text: "Subtotal"; color: "white"; font.bold: true; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                    Label { text: "Description"; color: "white"; font.bold: true; Layout.fillWidth: true }
                }
            }

            ListView {
                id: cartListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: cartModel
                currentIndex: selectedCartIndex

                delegate: Rectangle {
                    required property int index
                    required property string itemId
                    required property string itemName
                    required property string description
                    required property string qtyType
                    required property int qty
                    required property real price
                    required property real discount
                    required property real subtotal

                    width: cartListView.width
                    height: 36
                    color: index === selectedCartIndex ? "#D8F7FF" : (index % 2 === 0 ? "#ffffff" : "#f2f2f2")
                    border.color: "#dddddd"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        Label { text: itemId; color: "black"; Layout.preferredWidth: 120; elide: Text.ElideRight }
                        Label { text: itemName; color: "black"; Layout.fillWidth: true; elide: Text.ElideRight }
                        Label { text: qty; color: "black"; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                        Label { text: qtyType; color: "black"; Layout.preferredWidth: 70 }
                        Label { text: Number(price).toFixed(2); color: "black"; Layout.preferredWidth: 110; horizontalAlignment: Text.AlignRight }
                        Label { text: Number(discount).toFixed(2); color: "black"; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                        Label { text: Number(subtotal).toFixed(2); color: "black"; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                        Label { text: description; color: "black"; Layout.fillWidth: true; elide: Text.ElideRight }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: loadCartRow(index)
                        onDoubleClicked: loadCartRow(index)
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 170
        color: "#093C5D"
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 24

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Label { text: "Total"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: totalField; Layout.fillWidth: true; readOnly: true; text: "0"; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
                RowLayout {
                    Label { text: "Tax / PPN"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: taxField; Layout.fillWidth: true; text: "0"; color: "#5DF8D8"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextChanged: updateTotals(); background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
                RowLayout {
                    Label { text: "Discount"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: totalDiscountField; Layout.fillWidth: true; text: "0"; color: "#5DF8D8"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextChanged: updateTotals(); background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Label { text: "Final Total"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: finalTotalField; Layout.fillWidth: true; readOnly: true; text: "0"; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
                RowLayout {
                    Label { text: "Cash"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: cashField; Layout.fillWidth: true; text: "0"; color: "#5DF8D8"; inputMethodHints: Qt.ImhFormattedNumbersOnly; onTextChanged: updateTotals(); background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
                RowLayout {
                    Label { text: "Debt"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: debtField; Layout.fillWidth: true; readOnly: true; text: "0"; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
                RowLayout {
                    Label { text: "Due Date"; color: "white"; Layout.preferredWidth: 90 }
                    TextField { id: dueDateField; Layout.fillWidth: true; color: "#5DF8D8"; background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 } }
                }
            }

            GridLayout {
                Layout.preferredWidth: 430
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12

                Button { text: "Search Transaction"; Layout.fillWidth: true; Layout.fillHeight: true; onClicked: transactionSearchPopup.openSearch() }
                Button { text: "Refresh"; Layout.fillWidth: true; Layout.fillHeight: true; onClicked: { loadItems(); loadTransactions() } }
                Button { text: "Clear"; Layout.fillWidth: true; Layout.fillHeight: true; onClicked: clearTransactionFields() }
                Button { text: "Delete"; Layout.fillWidth: true; Layout.fillHeight: true; enabled: currentTransactionId >= 0; onClicked: deleteCurrentTransaction() }
                Button { text: "Back"; Layout.fillWidth: true; Layout.fillHeight: true; onClicked: root.backToMainMenu() }
                Button { text: "Update"; Layout.fillWidth: true; Layout.fillHeight: true; enabled: currentTransactionId >= 0; onClicked: updateTransaction() }
            }
        }
    }
}
