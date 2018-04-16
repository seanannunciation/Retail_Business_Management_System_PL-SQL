/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
//package studentregistrationsystem;
import java.sql.*;
import java.util.*;
import javax.swing.table.DefaultTableModel;
import oracle.sql.*;
import javax.swing.*;
/**
 *
 * @author Debashish
 */
public class ConvertToJtable {
    
    
  
 public DefaultTableModel ConverttoTable(DefaultTableModel modeltable,ResultSet rs)
    {
     try
     {
       
            ResultSetMetaData rsmd=rs.getMetaData();
            int col=rsmd.getColumnCount();
            String columns[]=new String[col];
            for(int i=0;i<col;i++)
            	columns[i]=rsmd.getColumnName(i+1);
    
    
           modeltable.setColumnIdentifiers(columns);

       
      for(int i=0;i<col;i++)
      {
          columns[i]=rsmd.getColumnName(i+1);
      }
       
        
        int colno=rsmd.getColumnCount();
        while(rs.next())
        {
            Object []objects=new Object[colno];
            for(int i=0;i<colno;i++)
            {
                objects[i]=rs.getObject(i+1);
            }
            modeltable.addRow(objects);
        }
        
        return modeltable;      
        
     }
     catch(Exception ex)
     {
         ex.printStackTrace();
     }
        
        
        
        return modeltable;
    }
    
    
    
    
    
}

