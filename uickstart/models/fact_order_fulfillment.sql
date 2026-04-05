with stg_orders as (
    select
        orderid,
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey,
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey,
        replace(to_date(orderdate)::varchar, '-', '')::int    as orderdatekey,
        replace(to_date(requireddate)::varchar, '-', '')::int as requiredatekey,
        replace(to_date(shippeddate)::varchar, '-', '')::int  as shippeddatekey,
        freight,
        shipvia,
        shipname,
        shipaddress,
        shipcity,
        shipregion,
        shipcountry
    from {{ source('northwind', 'Orders') }}
),
stg_order_details as (
    select
        orderid,
        sum(quantity) as quantity,
        sum(quantity * unitprice * (1 - discount)) as totalorderamount
    from {{ source('northwind', 'Order_Details') }}
    group by orderid
),
stg_shippers as (
    select * from {{ source('northwind', 'Shippers') }}
)
select
    o.orderid,
    o.customerkey,
    o.employeekey,
    o.orderdatekey,
    o.requiredatekey,
    o.shippeddatekey,
    o.freight,
    od.quantity,
    od.totalorderamount,
    o.shippeddatekey - o.orderdatekey  as daysfromordertoshipped,
    o.requiredatekey - o.orderdatekey  as daysfromordertorequired,
    o.shippeddatekey - o.requiredatekey as shippedtorequireddelta,
    case when o.shippeddatekey - o.requiredatekey <= 0 then 'Y' else 'N' end as shippedontime,
    s.companyname as shippercompanyname,
    o.shipname,
    o.shipaddress,
    o.shipcity,
    o.shipregion,
    o.shipcountry
from stg_orders o
join stg_order_details od on o.orderid = od.orderid
join stg_shippers s on s.shipperid = o.shipvia

