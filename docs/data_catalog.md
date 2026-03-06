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
        <th>
    Columns_name</th>
    <th>
    Data types
    </th>
    <th>
        Description
    </th>
    </thead>
    <tbody>
<td>
        customer_key
    </td>
    <td>
        INT
    </td>
    <td>
        Surrigate key uniquely identify the each customer record in the dimesion table 
    </td>
    </tbody>
    
  </table></li>
</ul>
