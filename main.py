import pandas as pd
categories = pd.read_csv('W:/Datasets/Northwind+Traders/Northwind Traders/categories.csv')
print(categories)

customers = pd.read_excel('W:/Datasets/Northwind+Traders/Northwind Traders/customers.xls')
print(customers.head(10))

employees = pd.read_excel('W:/Datasets/Northwind+Traders/Northwind Traders/employees.xls')
print(employees.head())

orders = pd.read_excel('W:/Datasets/Northwind+Traders/Northwind Traders/orders.xls')
print(orders.head())

order_details = pd.read_excel('W:/Datasets/Northwind+Traders/Northwind Traders/order_details.xls')
print(order_details.head())

products = pd.read_excel('W:/Datasets/Northwind+Traders/Northwind Traders/products.xls')
print(products.head())

shippers = pd.read_excel('W:/Datasets/Northwind+Traders/Northwind Traders/shippers.xls')
print(shippers.head())

# Adding a new "ProcessingTime" Column in the Orders Table for future analysis
orders = orders.assign(ProcessingTime=(orders.shippedDate - orders.orderDate))
orders['ProcessingTime']=orders['ProcessingTime'].dt.days.astype('float')
print(orders.head())

# Adding a Revenue Column in OrderDetails Table

order_details = order_details.assign(Revenue=(1-order_details.discount)*(order_details.unitPrice * order_details.quantity))
print(order_details.head())


# Adding a "Profit" Column in Orders Table

orders = orders.assign(Profit=order_details.Revenue - orders.freight)
print(orders.head())

# Adding a "Profit Margin" Column in OrderDetails Table

order_details = order_details.assign(ProfitMargin=(orders.Profit / order_details.Revenue)*100)
print(order_details.head())

# Finding the Last Order Date in Data

print(max(orders.orderDate))

# Finding the First Order Date in Data

print(min(orders.orderDate))

# Adding a new "OrderYear" Column in the Orders Table for future analysis

orders = orders.assign(OrderYear=orders.orderDate.dt.year)

print(orders.head())

# Adding a new "OrderMonth" Column in the Orders Table for future analysis

orders = orders.assign(OrderMonth=orders.orderDate.dt.month)

print(orders.head())

# Adding a new "OrderQuarter" Column in the Orders Table for future analysis

orders = orders.assign(OrderQuarter=orders.orderDate.dt.quarter)

print(orders.head())

# Total Revenue

print(sum(order_details.Revenue))


# Viewing Revenue Each Year

chart1=pd.merge(orders, order_details, how="left", on='orderID')[["Revenue","OrderYear"]].groupby(["OrderYear"]).agg(
    {"Revenue": ["sum"]}
)
print(chart1)

# Viewing Revenue in Current Year Vs Previous Year

# For order_details["OrderYear"] in ["2014", "2015"]:
chart2=pd.merge(orders, order_details, how="left", on='orderID').groupby(['OrderMonth','OrderYear']).agg(
    {"Revenue": 'sum'}
)
print(chart2)

# Viewing Quantity Each Year

chart3=pd.merge(orders, order_details, how="left", on='orderID')[["quantity","OrderYear"]].groupby(["OrderYear"]).agg(
    {"quantity": ["sum"]}
)
print(chart3)

# Viewing Quantity in Current Year Vs Previous Year

chart15=pd.merge(orders, order_details, how="left", on='orderID').groupby(['OrderMonth','OrderYear']).agg(
    {"quantity": 'sum'}
)
print(chart15)


# Viewing Avg Processing Days Each Year

chart4=orders.groupby(['OrderYear'])['ProcessingTime'].sum()
print(chart4)


# Quantity and Revenue trend per Quarter

chart5=pd.merge(orders, order_details, how="left", on='orderID')[["quantity","Revenue","OrderYear","OrderQuarter"]].groupby(["OrderYear","OrderQuarter"]).agg(
    {"quantity": ["sum"], "Revenue": ["sum"]}
)
print(chart5)

# Top 5 Countries for Revenue, and their Profit

chart6=orders.merge(order_details, how="left", on='orderID').merge(customers, how="left", on='customerID').groupby(['country']).agg(
    {"Revenue": ["sum"],"Profit": ["sum"]}
).sort_values(by=('Revenue', 'sum'), ascending= False)
print(chart6.head())

# Top Employees for Revenue, and their Headquarter Location

chart7=orders.merge(order_details, how="left", on='orderID').merge(employees, how="left", on='employeeID').groupby(['employeeName','country']).agg(
    {"Revenue": ["sum"],"Profit": ["sum"]}
).sort_values(by=('Revenue', 'sum'), ascending= False)
print(chart7)

# Product Category Revenue Over Time

chart8=order_details.merge(orders, how="left", on='orderID').merge(products, how="left", on='productID').merge(categories, how="left", on='categoryID').groupby(['categoryName','OrderYear','OrderQuarter']).agg(
    {"Revenue": ["sum"],"Profit": ["sum"]}
).sort_values(by=['OrderYear','OrderQuarter',('Revenue', 'sum'),'categoryName'], ascending= [True, True, False, True])
print(chart8)

# Product Category percentage Contribution in Revenue

chart9=products.merge(order_details, how="left", on='productID').merge(categories, how="left", on='categoryID').groupby('categoryName').agg({"Revenue": ["sum"]})
chart9['Revenue percent'] = (chart9[('Revenue', 'sum')] / sum(order_details.Revenue)) * 100
chart9=chart9.sort_values(by=('Revenue percent',    ''), ascending=False)
print(chart9)

# Product Performance in Quantity, Revenue, Profit and Avg Processing Time

chart10=order_details.merge(orders, how="left", on='orderID').merge(products, how="left", on='productID').groupby(['productName']).agg(
    {"Revenue": ["sum"],"Profit": ["sum"], "quantity": ["sum"], "ProcessingTime": ["mean"]}
).sort_values(by=('Revenue', 'sum'), ascending= False)
print(chart10)

# Shipping Companies and their shipping cost over the years

chart11=orders.merge(shippers, how="left", on='shipperID').groupby(['companyName','OrderYear']).agg({"freight": ["sum"]})
print(chart11)

# Shipping Companies and their percentage contribution in shipping costs

chart12=orders.merge(shippers, how="left", on='shipperID').groupby('companyName').agg({"freight": ["sum"]})
chart12['Percent Contribution'] = (chart12[('freight', 'sum')] / sum(orders.freight)) * 100
chart12=chart12.sort_values(by=('Percent Contribution',    ''), ascending=False)
print(chart12)

# Shipping Companies and their percentage contribution in total quantity

chart13=orders.merge(order_details, how="left", on='orderID').merge(shippers, how="left", on='shipperID').groupby('companyName').agg({"quantity": ["sum"]})
chart13['Percent Contribution'] = (chart13[('quantity', 'sum')] / sum(order_details.quantity)) * 100
chart13=chart13.sort_values(by=('Percent Contribution',    ''), ascending=False)
print(chart13)

# Shipping Companies and their percentage contribution in total processing time

chart14=orders.merge(shippers, how="left", on='shipperID').groupby('companyName').agg({"ProcessingTime": ["sum"]})
chart14['Percent Contribution'] = (chart14[('ProcessingTime', 'sum')] / sum(orders.ProcessingTime)) * 100
chart14=chart14.sort_values(by=('Percent Contribution',    ''), ascending=False)
print(chart14)
