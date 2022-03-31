package com.zylkerservices;

import java.sql.Connection;
import java.sql.DriverManager;

public class Database {
	
	private static Connection con = null;
	private Database() 
	{
		try 
		{
		    String url = "jdbc:mysql://localhost:3306/zylkerservices";
		    String username = "root";
		    String password = "asdfrewq";
		    Class.forName("com.mysql.cj.jdbc.Driver");
		    con = DriverManager.getConnection(url, username, password);
		    System.out.println("connected...");
		}
		catch(Exception e) 
		{
			// database connection failed
			System.out.println("DB connection failed in Database.java!");
		}
	}
	public static Connection getConnection() {
		if(con==null) 
		{
			Database establishConn = new Database();
		}
		return con;
	}
}
