#include "databasemanager.h"
#include <QVariantList>
#include <QVariantMap>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

bool DatabaseManager::openDatabase()
{
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("cashier.db");

    if (!db.open()) {
        emit databaseError(db.lastError().text());
        return false;
    }

    if (!createTables()) {
        return false;
    }

    emit databaseOpened();
    return true;
}

bool DatabaseManager::createTables()
{
    QSqlQuery query;

    bool ok = query.exec(
        "CREATE TABLE IF NOT EXISTS items ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "item_id TEXT UNIQUE NOT NULL,"
        "item_name TEXT NOT NULL,"
        "brand TEXT,"
        "category TEXT,"
        "buy_price REAL,"
        "sell_price REAL,"
        "description TEXT,"
        "stock INTEGER,"
        "qty_type TEXT"
        ")"
        );

    if (!ok) {
        emit databaseError(query.lastError().text());
        return false;
    }
    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS customers ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT NOT NULL,"
        "address TEXT NOT NULL,"
        "company TEXT NOT NULL,"
        "phone TEXT NOT NULL,"
        "email TEXT NOT NULL"
        ")"
        );

    if (!ok) {
        emit databaseError(query.lastError().text());
        return false;
    }

    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS transactions ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "invoice_no TEXT UNIQUE NOT NULL,"
        "date TEXT NOT NULL,"
        "customer_name TEXT,"
        "subtotal REAL NOT NULL,"
        "tax REAL NOT NULL,"
        "discount REAL NOT NULL,"
        "total REAL NOT NULL,"
        "cash REAL NOT NULL,"
        "debt REAL NOT NULL"
        ")"
        );

    if (!ok) {
        emit databaseError(query.lastError().text());
        return false;
    }

    ok = query.exec(
        "CREATE TABLE IF NOT EXISTS transaction_items ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "transaction_id INTEGER NOT NULL,"
        "item_id TEXT NOT NULL,"
        "item_name TEXT NOT NULL,"
        "description TEXT,"
        "qty_type TEXT,"
        "qty INTEGER NOT NULL,"
        "price REAL NOT NULL,"
        "discount REAL NOT NULL,"
        "subtotal REAL NOT NULL,"
        "FOREIGN KEY(transaction_id) REFERENCES transactions(id)"
        ")"
        );

    if (!ok) {
        emit databaseError(query.lastError().text());
        return false;
    }

    return true;
}

bool DatabaseManager::addItem(QString itemId,
                              QString itemName,
                              QString brand,
                              QString category,
                              double buyPrice,
                              double sellPrice,
                              QString description,
                              int stock,
                              QString qtyType)
{
    QSqlQuery query;

    query.prepare(
        "INSERT INTO items "
        "(item_id, item_name, brand, category, buy_price, sell_price, description, stock, qty_type) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );

    query.addBindValue(itemId);
    query.addBindValue(itemName);
    query.addBindValue(brand);
    query.addBindValue(category);
    query.addBindValue(buyPrice);
    query.addBindValue(sellPrice);
    query.addBindValue(description);
    query.addBindValue(stock);
    query.addBindValue(qtyType);

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return false;
    }

    return true;
}

QVariantList DatabaseManager::getItems()
{
    QVariantList items;

    QSqlQuery query(db);

    query.prepare(
        "SELECT item_id, item_name, brand, category, buy_price, sell_price, "
        "description, stock, qty_type FROM items ORDER BY item_name"
        );

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return items;
    }

    while (query.next()) {
        QVariantMap item;

        item["itemId"] = query.value("item_id").toString();
        item["itemName"] = query.value("item_name").toString();
        item["brand"] = query.value("brand").toString();
        item["category"] = query.value("category").toString();
        item["buyPrice"] = query.value("buy_price").toDouble();
        item["sellPrice"] = query.value("sell_price").toDouble();
        item["description"] = query.value("description").toString();
        item["stock"] = query.value("stock").toInt();
        item["qtyType"] = query.value("qty_type").toString();
        item["price"] = query.value("sell_price").toDouble();

        items.append(item);
    }

    return items;
}

bool DatabaseManager::addCustomer(QString name,
                                  QString address,
                                  QString company,
                                  QString phone,
                                  QString email)
{
    QSqlQuery query;

    query.prepare(
        "INSERT INTO customers "
        "(name, address, company, phone, email) "
        "VALUES (?, ?, ?, ?, ?)"
        );

    query.addBindValue(name);
    query.addBindValue(address);
    query.addBindValue(company);
    query.addBindValue(phone);
    query.addBindValue(email);

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return false;
    }

    return true;
}

QVariantList DatabaseManager::getCustomers()
{
    QVariantList customers;

    QSqlQuery query;

    query.prepare(
        "SELECT id, name, address, company, phone, email "
        "FROM customers "
        "ORDER BY name"
        );

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return customers;
    }

    while (query.next()) {
        QVariantMap customer;

        customer["id"] = query.value("id").toInt();
        customer["name"] = query.value("name").toString();
        customer["address"] = query.value("address").toString();
        customer["company"] = query.value("company").toString();
        customer["phone"] = query.value("phone").toString();
        customer["email"] = query.value("email").toString();

        customers.append(customer);
    }

    return customers;
}

bool DatabaseManager::updateCustomer(int id,
                                     QString name,
                                     QString address,
                                     QString company,
                                     QString phone,
                                     QString email)
{
    QSqlQuery query;

    query.prepare(
        "UPDATE customers SET "
        "name = ?, "
        "address = ?, "
        "company = ?, "
        "phone = ?, "
        "email = ? "
        "WHERE id = ?"
        );

    query.addBindValue(name);
    query.addBindValue(address);
    query.addBindValue(company);
    query.addBindValue(phone);
    query.addBindValue(email);
    query.addBindValue(id);

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return false;
    }

    return query.numRowsAffected() > 0;
}

bool DatabaseManager::deleteCustomer(int id)
{
    QSqlQuery query;

    query.prepare("DELETE FROM customers WHERE id = ?");
    query.addBindValue(id);

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return false;
    }

    return query.numRowsAffected() > 0;
}


bool DatabaseManager::addTransaction(QString invoiceNo,
                                     QString date,
                                     QString customerName,
                                     double subtotal,
                                     double tax,
                                     double discount,
                                     double total,
                                     double cash,
                                     double debt,
                                     QVariantList items)
{
    db.transaction();

    QSqlQuery transactionQuery(db);

    transactionQuery.prepare(
        "INSERT INTO transactions "
        "(invoice_no, date, customer_name, subtotal, tax, discount, total, cash, debt) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );

    transactionQuery.addBindValue(invoiceNo);
    transactionQuery.addBindValue(date);
    transactionQuery.addBindValue(customerName);
    transactionQuery.addBindValue(subtotal);
    transactionQuery.addBindValue(tax);
    transactionQuery.addBindValue(discount);
    transactionQuery.addBindValue(total);
    transactionQuery.addBindValue(cash);
    transactionQuery.addBindValue(debt);

    if (!transactionQuery.exec()) {
        qDebug() << "updateTransaction UPDATE error:" << transactionQuery.lastError().text();
        emit databaseError(transactionQuery.lastError().text());
        db.rollback();
        return false;
    }

    int transactionId = transactionQuery.lastInsertId().toInt();

    for (const QVariant &itemVariant : items) {
        QVariantMap item = itemVariant.toMap();

        QSqlQuery itemQuery(db);

        itemQuery.prepare(
            "INSERT INTO transaction_items "
            "(transaction_id, item_id, item_name, description, qty_type, qty, price, discount, subtotal) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );

        itemQuery.addBindValue(transactionId);
        itemQuery.addBindValue(item["itemId"].toString());
        itemQuery.addBindValue(item["itemName"].toString());
        itemQuery.addBindValue(item["description"].toString());
        itemQuery.addBindValue(item["qtyType"].toString());
        itemQuery.addBindValue(item["qty"].toInt());
        itemQuery.addBindValue(item["price"].toDouble());
        itemQuery.addBindValue(item["discount"].toDouble());
        itemQuery.addBindValue(item["subtotal"].toDouble());

        if (!itemQuery.exec()) {
            qDebug() << "updateTransaction INSERT item error:" << itemQuery.lastError().text();
            emit databaseError(itemQuery.lastError().text());
            db.rollback();
            return false;
        }
    }

    db.commit();
    return true;
}

QVariantList DatabaseManager::getTransactions()
{
    QVariantList transactions;

    QSqlQuery query(db);

    query.prepare(
        "SELECT id, invoice_no, date, customer_name, subtotal, tax, discount, total, cash, debt "
        "FROM transactions "
        "ORDER BY id DESC"
        );

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return transactions;
    }

    while (query.next()) {
        QVariantMap transaction;

        transaction["id"] = query.value("id").toInt();
        transaction["invoiceNo"] = query.value("invoice_no").toString();
        transaction["date"] = query.value("date").toString();
        transaction["customerName"] = query.value("customer_name").toString();
        transaction["subtotal"] = query.value("subtotal").toDouble();
        transaction["tax"] = query.value("tax").toDouble();
        transaction["discount"] = query.value("discount").toDouble();
        transaction["total"] = query.value("total").toDouble();
        transaction["cash"] = query.value("cash").toDouble();
        transaction["debt"] = query.value("debt").toDouble();

        transactions.append(transaction);
    }

    return transactions;
}


QVariantList DatabaseManager::getTransactionItems(int transactionId)
{
    QVariantList items;

    QSqlQuery query(db);

    query.prepare(
        "SELECT id, transaction_id, item_id, item_name, description, qty_type, qty, price, discount, subtotal "
        "FROM transaction_items "
        "WHERE transaction_id = ?"
        );

    query.addBindValue(transactionId);

    if (!query.exec()) {
        emit databaseError(query.lastError().text());
        return items;
    }

    while (query.next()) {
        QVariantMap item;

        item["id"] = query.value("id").toInt();
        item["transactionId"] = query.value("transaction_id").toInt();
        item["itemId"] = query.value("item_id").toString();
        item["itemName"] = query.value("item_name").toString();
        item["description"] = query.value("description").toString();
        item["qtyType"] = query.value("qty_type").toString();
        item["qty"] = query.value("qty").toInt();
        item["price"] = query.value("price").toDouble();
        item["discount"] = query.value("discount").toDouble();
        item["subtotal"] = query.value("subtotal").toDouble();

        items.append(item);
    }

    return items;
}

bool DatabaseManager::deleteTransaction(int transactionId)
{
    db.transaction();

    QSqlQuery deleteItemsQuery(db);
    deleteItemsQuery.prepare("DELETE FROM transaction_items WHERE transaction_id = ?");
    deleteItemsQuery.addBindValue(transactionId);

    if (!deleteItemsQuery.exec()) {
        qDebug() << "updateTransaction DELETE items error:" << deleteItemsQuery.lastError().text();
        emit databaseError(deleteItemsQuery.lastError().text());
        db.rollback();
        return false;
    }

    QSqlQuery deleteTransactionQuery(db);
    deleteTransactionQuery.prepare("DELETE FROM transactions WHERE id = ?");
    deleteTransactionQuery.addBindValue(transactionId);

    if (!deleteTransactionQuery.exec()) {
        emit databaseError(deleteTransactionQuery.lastError().text());
        db.rollback();
        return false;
    }

    db.commit();
    return deleteTransactionQuery.numRowsAffected() > 0;
}

bool DatabaseManager::updateTransaction(int transactionId,
                                        QString invoiceNo,
                                        QString date,
                                        QString customerName,
                                        double subtotal,
                                        double tax,
                                        double discount,
                                        double total,
                                        double cash,
                                        double debt,
                                        QVariantList items)
{
    db.transaction();

    QSqlQuery transactionQuery(db);

    transactionQuery.prepare(
        "UPDATE transactions SET "
        "invoice_no = ?, "
        "date = ?, "
        "customer_name = ?, "
        "subtotal = ?, "
        "tax = ?, "
        "discount = ?, "
        "total = ?, "
        "cash = ?, "
        "debt = ? "
        "WHERE id = ?"
        );

    transactionQuery.addBindValue(invoiceNo);
    transactionQuery.addBindValue(date);
    transactionQuery.addBindValue(customerName);
    transactionQuery.addBindValue(subtotal);
    transactionQuery.addBindValue(tax);
    transactionQuery.addBindValue(discount);
    transactionQuery.addBindValue(total);
    transactionQuery.addBindValue(cash);
    transactionQuery.addBindValue(debt);
    transactionQuery.addBindValue(transactionId);

    if (!transactionQuery.exec()) {
        qDebug() << "updateTransaction UPDATE error:" << transactionQuery.lastError().text();
        emit databaseError(transactionQuery.lastError().text());
        db.rollback();
        return false;
    }

    QSqlQuery deleteItemsQuery(db);
    deleteItemsQuery.prepare("DELETE FROM transaction_items WHERE transaction_id = ?");
    deleteItemsQuery.addBindValue(transactionId);

    if (!deleteItemsQuery.exec()) {
        qDebug() << "updateTransaction DELETE items error:" << deleteItemsQuery.lastError().text();
        emit databaseError(deleteItemsQuery.lastError().text());
        db.rollback();
        return false;
    }

    for (const QVariant &itemVariant : items) {
        QVariantMap item = itemVariant.toMap();

        QSqlQuery itemQuery(db);

        itemQuery.prepare(
            "INSERT INTO transaction_items "
            "(transaction_id, item_id, item_name, description, qty_type, qty, price, discount, subtotal) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );

        itemQuery.addBindValue(transactionId);
        itemQuery.addBindValue(item["itemId"].toString());
        itemQuery.addBindValue(item["itemName"].toString());
        itemQuery.addBindValue(item["description"].toString());
        itemQuery.addBindValue(item["qtyType"].toString());
        itemQuery.addBindValue(item["qty"].toInt());
        itemQuery.addBindValue(item["price"].toDouble());
        itemQuery.addBindValue(item["discount"].toDouble());
        itemQuery.addBindValue(item["subtotal"].toDouble());

        if (!itemQuery.exec()) {
            qDebug() << "updateTransaction INSERT item error:" << itemQuery.lastError().text();
            emit databaseError(itemQuery.lastError().text());
            db.rollback();
            return false;
        }
    }

    db.commit();
    return true;
}