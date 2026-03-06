<h1> Overview</h1>
the Gold layer is the bussiness-level data representation ,structure to support analytical ans reporting use cases. it consists of <b>dimension tables </b>
and  <b>fact tables</b> for specif bussiness metrics.
<hr>
<h2>1. gold .dim_customers</h2>
<ul>
  <li><b> Purpose:</b> Stores customers details enriched with demographic and geographic data </li>
  <li><b> Columns:</b>
  <table>
    <thead>
        <th>Columns_name</th>
        <th>Data types</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td>customer_key</td>
            <td>INT</td>
            <td>Surrogate key uniquely identify the each customer record in the dimension table</td>
        </tr>
        <tr>
            <td>customer_id</td>
            <td>VARCHAR(50)</td>
            <td>Unique customer identifier</td>
        </tr>
        <tr>
            <td>customer_number</td>
            <td>VARCHAR(50)</td>
            <td>Customer account number</td>
        </tr>
        <tr>
            <td>first_name</td>
            <td>VARCHAR(50)</td>
            <td>Customer's first name</td>
        </tr>
        <tr>
            <td>last_name</td>
            <td>VARCHAR(50)</td>
            <td>Customer's last name</td>
        </tr>
        <tr>
            <td>country</td>
            <td>VARCHAR(50)</td>
            <td>Country of residence</td>
        </tr>
        <tr>
            <td>marital_status</td>
            <td>VARCHAR(20)</td>
            <td>Customer's marital status eg.('Marriaged','single','N/a')</td>
        </tr>
        <tr>
            <td>gender</td>
            <td>VARCHAR(20)</td>
            <td>Customer's gender eg.('Male','Female','N/a')</td>
        </tr>
        <tr>
            <td>birthdate</td>
            <td>DATE</td>
            <td>Customer's date of birth eg.('1967-04-23')</td>
        </tr>
    </tbody>
  </table></li>
</ul>

<hr>
<h2>2. gold .dim_products</h2>
<ul>
  <li><b> Purpose:</b> Stores product details enriched with category and pricing information </li>
  <li><b> Columns:</b>
  <table>
    <thead>
        <th>Columns_name</th>
        <th>Data types</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td>product_key</td>
            <td>INT</td>
            <td>Primary key uniquely identifying each product record</td>
        </tr>
        <tr>
            <td>product_id</td>
            <td>VARCHAR</td>
            <td>Unique product identifier</td>
        </tr>
        <tr>
            <td>product_number</td>
            <td>VARCHAR</td>
            <td>Product number/code</td>
        </tr>
        <tr>
            <td>product_name</td>
            <td>VARCHAR</td>
            <td>Name of the product</td>
        </tr>
        <tr>
            <td>category_id</td>
            <td>VARCHAR</td>
            <td>Identifier for the product category</td>
        </tr>
        <tr>
            <td>subcategory</td>
            <td>VARCHAR</td>
            <td>Subcategory of the product</td>
        </tr>
        <tr>
            <td>maintenance</td>
            <td>VARCHAR</td>
            <td>Maintenance requirements or status</td>
        </tr>
        <tr>
            <td>cost</td>
            <td>DECIMAL</td>
            <td>Cost of the product</td>
        </tr>
        <tr>
            <td>productt_one</td>
            <td>VARCHAR</td>
            <td>Product type or variant</td>
        </tr>
        <tr>
            <td>start_date</td>
            <td>DATE</td>
            <td>Date when the product became available</td>
        </tr>
    </tbody>
  </table></li>
</ul>
<hr>
<h2>3. gold .fact_sales</h2>
<ul>
  <li><b> Purpose:</b> Stores sales transaction facts linking customers and products with sales metrics </li>
  <li><b> Columns:</b>
  <table>
    <thead>
        <th>Columns_name</th>
        <th>Data types</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td>order_number</td>
            <td>VARCHAR</td>
            <td>Unique order identifier</td>
        </tr>
        <tr>
            <td><b>fk1</b></td>
            <td>INT</td>
            <td>Foreign key linking to product_key in dim_products</td>
        </tr>
        <tr>
            <td><b>fk2</b></td>
            <td>INT</td>
            <td>Foreign key linking to customer_key in dim_customers</td>
        </tr>
        <tr>
            <td>order_date</td>
            <td>DATE</td>
            <td>Date when the order was placed</td>
        </tr>
        <tr>
            <td>shipping_date</td>
            <td>DATE</td>
            <td>Date when the order was shipped</td>
        </tr>
        <tr>
            <td>due_date</td>
            <td>DATE</td>
            <td>Due date for the order</td>
        </tr>
        <tr>
            <td>sales_amount</td>
            <td>DECIMAL</td>
            <td>Total sales amount for the order</td>
        </tr>
        <tr>
            <td>qunatity</td>
            <td>INT</td>
            <td>Quantity of products in the order</td>
        </tr>
        <tr>
            <td>price</td>
            <td>DECIMAL</td>
            <td>Price per unit</td>
        </tr>
    </tbody>
  </table></li>
</ul>


