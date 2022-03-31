package com.zylkerservices;

import java.security.NoSuchAlgorithmException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.regex.Pattern;

public class Check {
	
	// returns "user_id" if the user exists else it returns "-1"
	public static int isExistingUser(String email) throws SQLException
	{
		String checkIfAlreadyPresentSql = "SELECT user_id FROM user_credentials WHERE email = ?";
		PreparedStatement checkIfAlreadyPresentStmt = Database.getConnection().prepareStatement(checkIfAlreadyPresentSql);
		checkIfAlreadyPresentStmt.setString(1,email);
		ResultSet rs = checkIfAlreadyPresentStmt.executeQuery();
		if(rs.next())
		{
			int user_id = rs.getInt(1);
			return user_id;
		}
		return -1;
	}
	
	public static boolean isValidEmailAndPassword(String email, String password)
	{
		String emailRegex = "[a-zA-z0-9]{1,64}+@+[a-zA-Z0-9]{1,255}+.+[a-zA-Z0-9]{1,64}";
		String passwordRegex = "^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$";
		return Pattern.matches(emailRegex, email) && Pattern.matches(passwordRegex, password);
	}
}
