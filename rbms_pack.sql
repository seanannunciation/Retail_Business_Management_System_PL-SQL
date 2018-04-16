create or replace package rbms_package as
type ref_cursor is ref cursor;

/*This procedure is used to display the products table*/
procedure display_products(prod_cur out ref_cursor);

/*This procedure is used to display the employees table*/
procedure display_employees(emp_cur out ref_cursor);

/*This procedure is used to display the customers table*/
procedure display_customers(cust_cur out ref_cursor);

/*This procedure is used to display the discounts table*/
procedure display_discounts(dis_cur out ref_cursor);

/*This procedure is used to display the suppliers table*/
procedure display_suppliers(supplier_cur out ref_cursor);

/*This procedure is used to display the supplies table*/
procedure display_supplies(supplies_cur out ref_cursor);

/*This procedure is used to display the purchases table*/
procedure display_purchases(pur_cur out ref_cursor);

/*This procedure is used to display the logs table*/
procedure display_logs(log_cur out ref_cursor);

/*This function is used to report the total savings for a pur#*/
FUNCTION purchase_saving(pur#_in in NUMBER)
return number;

/*This procedure is used to check the monthly sales activities for an employee*/
procedure monthly_sale_activities(employee_id in 
employees.eid%type,Invaliderror out varchar2, c1 OUT ref_cursor);

/*This procedure is used to add customers*/
procedure add_customers(c_id in customers.cid%type,c_name in 
customers.name%type,c_telephone in customers.telephone#%type,
Invaliderror1 out varchar2);

/*This procedure is used to add purchases*/
procedure add_purchase(e_id in purchases.eid%type, 
p_id in purchases.pid%type,
c_id in purchases.cid%type,
pur_qty in purchases.qty%type, poutput out varchar, error out varchar2);

/*This procedure is used to delete a purchase*/
PROCEDURE DELETE_PURCHASE(PUR_IN in purchases.pur#%type, error out varchar2, 
poutput out varchar);


end rbms_package;
/

