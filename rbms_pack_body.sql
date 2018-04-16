
set serveroutput on 
create or replace package body rbms_package as

procedure display_products(prod_cur out ref_cursor) is
begin
	open prod_cur for select * from products order by pid;
end display_products;

/*procedure display_customers(cust_cur out ref_cursor)*/

procedure display_customers(cust_cur out ref_cursor) is
begin
        open cust_cur for select * from customers order by cid;
end display_customers;

/*procedure display_discounts(dis_cur out ref_cursor);*/

procedure display_discounts(dis_cur out ref_cursor) is
begin
        open dis_cur for select * from discounts;
end display_discounts;


/*procedure display_suppliers(supplier_cur out ref_cursor);*/

procedure display_suppliers(supplier_cur out ref_cursor) is
begin
        open supplier_cur for select * from suppliers order by sid;
end display_suppliers;


/*procedure display_supplies(supplies_cur out ref_cursor);*/

procedure display_supplies(supplies_cur out ref_cursor) is
begin
        open supplies_cur for select * from supplies order by sup#;
end display_supplies;


/* procedure display_purchases(pur_cur out ref_cursor);*/

procedure display_purchases(pur_cur out ref_cursor) is
begin
        open pur_cur for select * from purchases order by pur#;
end display_purchases;

/*procedure display_logs(log_cur out ref_cursor);*/

procedure display_logs(log_cur out ref_cursor) is
begin
        open log_cur for select * from logs order by log#;
end display_logs;

/*procedure to display employees*/

procedure display_employees(emp_cur out ref_cursor) is
begin
	open emp_cur for select * from employees;
end display_employees;


/* function to report the total saving of any purchase */

FUNCTION purchase_saving(pur#_in IN NUMBER)
RETURN NUMBER
IS
SAVING NUMBER;
pur#_count number;

BEGIN
select count(*) into pur#_count from purchases where pur#=pur#_in;

if(pur#_count=0) then
        RETURN -1;
else
SELECT ((p.original_price*pr.qty)-pr.total_price) INTO SAVING from
purchases pr join products p on p.pid=pr.pid where
pur#=pur#_in;

RETURN SAVING;
end if;
END purchase_saving;


/* procedure to report the monthly sales activity of any 
given employee */
procedure monthly_sale_activities(employee_id in
employees.eid%type, Invaliderror out varchar2 , c1 OUT ref_cursor) 
is

Invalideid exception;
count_val number;

begin
select count(*) into count_val from employees where eid = employee_id;

if(count_val = 0) then
	raise Invalideid;
else
        open c1 for
select e.eid, e.name, to_char(pu.ptime,
'MON-YYYY') "month", count(pu.ptime)total_sales, sum(pu.qty)total_quantity,
sum(pu.total_price)total_amount from employees e, purchases pu where
e.eid=pu.eid and e.eid=employee_id group by e.eid, e.name,
to_char(pu.ptime, 'MON-YYYY');

end if;
exception
	when Invalideid then
	Invaliderror:='Employee id does not exist';

end monthly_sale_activities;
 


/* procedure to add customers to the customer table */

procedure add_customers(
c_id in customers.cid%type,
c_name in customers.name%type,
c_telephone in customers.telephone#%type,
Invaliderror1 out varchar2) is

Invalidcid exception;
count_val1 number;

begin
select count(*) into count_val1 from customers where cid = c_id;
if(count_val1=0) then
Invaliderror1:='';
        insert into customers (cid, name, telephone#, visits_made,last_visit_date)
values (c_id, c_name, c_telephone, 1, sysdate);

else
raise Invalidcid;
end if;

exception
	when Invalidcid then
	Invaliderror1:='customer already exists';
	
end add_customers;

/* procedure to add tuples in purchases table */

procedure add_purchase(e_id in purchases.eid%type, 
p_id in purchases.pid%type,
c_id in purchases.cid%type,
pur_qty in purchases.qty%type,
poutput out varchar,
error out varchar2) is 
 
pid_error exception;
eid_error exception;
cid_error exception;
pur_date date;
pur_total_price number(7,2);
next_pur# number(6);
remain_qoh number(5);
o_price number(6,2);
d_rate  number(3,2);
pid_count number;
eid_count number;
cid_count number;


 
BEGIN

pur_date:=SYSDATE;
select count(*) into pid_count from products where pid = p_id;
select count(*) into eid_count from employees where eid = e_id;
select count(*) into cid_count from customers where cid = c_id;


if(eid_count=0) then
raise eid_error;

elsif(pid_count=0) then
raise pid_error;

elsif(cid_count=0) then
raise cid_error;

else
error:='';
SELECT pr.original_price , d.discnt_rate into o_price,d_rate from 
products pr, discounts d where d.discnt_category=pr.discnt_category 
and pr.pid = p_id;

pur_total_price:=(o_price*(1-d_rate))* pur_qty;
select qoh into remain_qoh from products pr where pr.pid = p_id;

if (remain_qoh-pur_qty)<0 then
------dbms_output.put_line('Insufficient quantity in stock, the purchase request is rejected');
poutput:= 'Insufficient quantity in stock';

else
	next_pur#:=pur_seq.nextval;
 	insert into purchases values (next_pur#,e_id,p_id,c_id, 
pur_qty, pur_date, pur_total_price); 	 	
--------dbms_output.put_line('Purchase Successful');
poutput:= 'Purchase Successful';
end if;

end if;

exception
when eid_error then 
error:='Employee does not exists';

when pid_error then
error:='Product does not exists';

when cid_error then
error:='Customer does not exists';

END add_purchase;


/*procedure to delete tuple from purchase*/

PROCEDURE DELETE_PURCHASE(PUR_IN in purchases.pur#%type, error out varchar2, 
poutput out varchar) 
is
pur_error exception;
pur_count number;

BEGIN
select count(*) into pur_count from purchases where pur# = PUR_IN;

if(pur_count=0) then
raise pur_error;

else
error:='';

DELETE FROM PURCHASES 
WHERE PURCHASES.PUR#=PUR_IN;
poutput:= 'Delete Successful';

end if;

exception
when pur_error then 
error:='Purchases number does not exists';

END DELETE_PURCHASE;

end rbms_package;
/
