
/* purchase table sequence */
 create sequence pur_seq
   increment by 1
   start with 100015
   maxvalue 999999
   cycle
   order;

/* supplies table sequence */
create sequence sup_seq
        increment by 1
        start with 1010
        maxvalue 9999
        nocache
        cycle;


/* logs table sequence */
create sequence log_seq
        increment by 1
        start with 00001
        maxvalue 99999
        cycle
        order;



/* Log_trigger is a trigger when inserting a tuple into the customer table. */
/* It inserts a new row into the logs table with the operation of insert */
/* and put the new cid into the logs table */
CREATE OR REPLACE TRIGGER LOG_TRIGGER
AFTER INSERT ON CUSTOMERS
FOR EACH ROW
BEGIN
INSERT INTO LOGS
(LOG#,USER_NAME,OPERATION,OP_TIME,TABLE_NAME,TUPLE_PKEY)
VALUES(LOG_SEQ.NEXTVAL,user,'INSERT',sysdate,'CUSTOMERS',:NEW.cid);
END;
/


/* LOG_UPDATE_CUST_TRIGGER will generate after an update operation in the*/
/*last_visit_date attribute of the customers table. This trigger will add a*/
/*new row into the logs table with the operation of update with the cid of customer*/
CREATE OR REPLACE TRIGGER LOG_UPDATE_CUST_TRIGGER
AFTER UPDATE OF LAST_VISIT_DATE ON CUSTOMERS
FOR EACH ROW
BEGIN
INSERT INTO LOGS
(LOG#,USER_NAME,OPERATION,OP_TIME,TABLE_NAME,TUPLE_PKEY)
VALUES(LOG_SEQ.NEXTVAL,user,'UPDATE',sysdate,'CUSTOMERS',:NEW.cid);
END;
/


/*LOG_PURCHASES_TRIGGER will execute after insert operation in the purchase table */
/*This trigger will add a new tuple into the logs table with the table name purchases,*/
/*operation as insert and the tuple_key as pur#*/
CREATE OR REPLACE TRIGGER LOG_PURCHASES_TRIGGER
AFTER INSERT ON PURCHASES
FOR EACH ROW
BEGIN
INSERT INTO LOGS
(LOG#,USER_NAME,OPERATION,OP_TIME,TABLE_NAME,TUPLE_PKEY)
VALUES(LOG_SEQ.NEXTVAL,user,'INSERT',sysdate,'PURCHASES',:NEW.pur#);
END;
/

/*LOG_UPDATE_PROD_TRIGGER will execute after update operation of qoh in products table */
/*This trigger will add a new tuple into the logs table with the table name products,*/
/*operation as update and the tuple_key as pid*/
CREATE OR REPLACE TRIGGER LOG_UPDATE_PROD_TRIGGER
AFTER UPDATE OF QOH ON PRODUCTS
FOR EACH ROW
BEGIN
INSERT INTO LOGS
(LOG#,USER_NAME,OPERATION,OP_TIME,TABLE_NAME,TUPLE_PKEY)
VALUES(LOG_SEQ.NEXTVAL,user,'UPDATE',sysdate,'PRODUCTS',:NEW.pid);
END;
/


/*LOG_SUPPLIES_TRIGGER will execute after insert operation on supplies table */
/*This trigger will add a new tuple into the logs table with the table name supplies,*/
/*operation as insert and the tuple_key as sup#*/
CREATE OR REPLACE TRIGGER LOG_SUPPLIES_TRIGGER
AFTER INSERT ON SUPPLIES
FOR EACH ROW
BEGIN
INSERT INTO LOGS
(LOG#,USER_NAME,OPERATION,OP_TIME,TABLE_NAME,TUPLE_PKEY)
VALUES(LOG_SEQ.NEXTVAL,user,'INSERT',sysdate,'SUPPLIES',:NEW.sup#);
END;
/

/*This trigger will update qoh value of a product everytime we insert a tuple in purchases table*/
/*updated qoh field of products will be compared with qoh_threshold*/
/*If it is less, we display a message that qoh is less than threshold.*/
/*We calculate M = qoh_threshold - new_qoh + 1*/
/*we calculate quantity of product to be ordered using given formula in project documents quantity=10+M+new_qoh*/
/*A new entry will be added in supplies table*/
/*We also display new-qoh*/
/*customer's last_visit_date will be replace system date and number of visit made will increment 1*/
create or replace trigger update_q_vm_lvd
after insert on purchases
declare
pur#_id purchases.pur#%type;
p_id purchases.pid%type;
c_id purchases.cid%type;
pur_qty purchases.qty%type;
sup#_id supplies.sup#%type;
sup_date date;
sup_qty supplies.quantity%type; 
temp_qoh_threshold products.qoh_threshold%type;
new_qoh products.qoh%type;
last_visit date;
temp_visits_made customers.visits_made%type;
s_sid supplies.sid%type;


BEGIN

Select sysdate into sup_date from dual;
select pur#,pid,cid,qty,ptime into pur#_id,p_id,c_id,pur_qty,last_visit from purchases group by pur#,pid,cid,qty,ptime having pur#=(select max(pur#) from purchases);
update products set qoh=qoh-pur_qty where pid=p_id;
select qoh, qoh_threshold into new_qoh, temp_qoh_threshold from products pr where pr.pid = p_id;
select visits_made into temp_visits_made from customers where cid=c_id; 
update customers set visits_made = temp_visits_made+1 , last_visit_date = last_visit where cid=c_id;  	 	

if (new_qoh < temp_qoh_threshold) then
	dbms_output.put_line('Quantity on hand(qoh) is below the required threshold and new supply is required');
  sup_qty:=10+temp_qoh_threshold+1;
	select sid into s_sid from (select sid from supplies where pid=p_id order by sid asc) where rownum = 1;
	insert into supplies values (sup_seq.nextval, p_id, s_sid, sup_date, sup_qty);
	update products set qoh=(qoh+sup_qty) where pid=p_id;
	dbms_output.put_line('New QOH: ' || (new_qoh+sup_qty));
end if;
end;
/

/*This trigger is fired when a tuple in the purchases table has been deleted. */
/*It then increases the qoh value in the products table by the deleted tuple qoh value and */
/*also increments the visits_made value by 1 and the last_visit_date by the sysdate in the customers table.*/
CREATE OR REPLACE TRIGGER PRODUCT_TRIGGER
AFTER DELETE ON PURCHASES
FOR EACH ROW
DECLARE
PROD_ID PURCHASES.PID%TYPE;
LAST_DATE PURCHASES.PTIME%TYPE;
BEGIN
UPDATE PRODUCTS SET PRODUCTS.QOH=PRODUCTS.QOH+:old.qty
WHERE PRODUCTS.PID=:old.pid;
UPDATE CUSTOMERS SET VISITS_MADE=VISITS_MADE+1,
LAST_VISIT_DATE=sysdate
WHERE CID=:old.cid;
END;
/

show error;