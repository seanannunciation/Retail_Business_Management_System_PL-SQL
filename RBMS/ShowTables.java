import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.jdbc.OracleTypes;

public class ShowTables {
	ResultSet rs;
	public ResultSet returnTables(Connection conn,String proc)
	{
		StringBuilder sb=new StringBuilder();
		CallableStatement cs;
		try {
			cs = conn.prepareCall(proc);
			cs.registerOutParameter(1, OracleTypes.CURSOR);
			cs.execute();
			rs = (ResultSet)cs.getObject(1);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		
		return rs;
	}
	

}
