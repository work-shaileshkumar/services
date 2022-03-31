package com.zylkerservices;

import java.sql.PreparedStatement;
import java.sql.SQLException;

public class Logs {
	
	public static void addUserLog(int user_id, String logMessage)
	{
		String logSql = "INSERT INTO user_logs(user_id, user_activity) values(?,?)";
		try 
		{
		    PreparedStatement logStmt = Database.getConnection().prepareStatement(logSql);
            logStmt.setInt(1, user_id);
            logStmt.setString(2, logMessage);
            logStmt.executeUpdate();
		}
		catch(Exception e)
		{
			System.out.println("Failed to write UserLog");
		}
	}
	
	public static void addDeveloperLog(String fileName,String methodName, String errorMessage)
	{
		String logSql = "INSERT INTO developer_logs(fileName, methodName, errorMessage) values(?,?,?)";
		System.out.println(errorMessage+" "+fileName+" "+methodName);
		try
		{
		    PreparedStatement logStmt = Database.getConnection().prepareStatement(logSql);
		    logStmt.setString(1, fileName);
		    logStmt.setString(2, methodName);
		    logStmt.setString(3, errorMessage);
		    logStmt.executeUpdate();
		}
		catch(Exception e)
		{
			System.out.println(e.toString());
			System.out.println("Failed to write DeveloperLog");
		}
	}
}
