package com.zylkerservices;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.NoSuchAlgorithmException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.json.JSONObject;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class UserRepository {
	
	
	//returns either userCreated or userExists or serverError
	public static String createNewUser(User userObj) 
	{
		try
		{
			if (Check.isExistingUser(Security.sanitize(userObj.getEmail())) == -1 && Check.isValidEmailAndPassword(userObj.getEmail(), userObj.getPassword())) 
			{
				String createUserSql = "INSERT INTO user_credentials(email, user_role, user_auth_type,acc_creation_date, email_verification) VALUES(?, ?, ?, ?, ?)";
				PreparedStatement createUserStmt = Database.getConnection().prepareStatement(createUserSql,PreparedStatement.RETURN_GENERATED_KEYS);
				createUserStmt.setString(1, Security.sanitize(userObj.getEmail()));
				createUserStmt.setString(2, Security.sanitize(userObj.getUser_role()));
				createUserStmt.setString(3, Security.sanitize(userObj.getUser_auth_type()));
				userObj.setAcc_creation_date();
				createUserStmt.setObject(4, userObj.getAcc_creation_date());
				createUserStmt.setBoolean(5, userObj.getEmail_verification());
				createUserStmt.executeUpdate();
				// getting the userId after user creation
				ResultSet rs = createUserStmt.getGeneratedKeys();
				while (rs.next()) 
				{
					int user_id = rs.getInt(1); // newly generated user_id
					String storePasswordSql = "INSERT INTO user_passwords(user_id, password) values(?, sha2(?, 256))";
					PreparedStatement storePasswordStmt = Database.getConnection().prepareStatement(storePasswordSql);
					storePasswordStmt.setInt(1, user_id);
					storePasswordStmt.setString(2, userObj.getPassword());
					storePasswordStmt.executeUpdate();
					Logs.addUserLog(user_id, "New User Created");
					return "userCreated-" + user_id + "-" + userObj.getUser_role();
				}
				return "serverError";
			} 
			else 
			{
				return "userExists";
			}
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("UserRepository.java", "createNewUser", e.toString());
			return "serverError";
		}
	}
	
	public static String authenticate(User obj) throws SQLException, NoSuchAlgorithmException
	{
		String email = Security.sanitize(obj.getEmail());
		String password = obj.getPassword();
		String user_auth_type = Security.sanitize(obj.getUser_auth_type());
		int user_id = Check.isExistingUser(email);
		if(user_id != -1)
		{
			if(user_auth_type.equals("google"))
			{
				String fetchDataSql = "SELECT user_role FROM user_credentials WHERE user_id = ?";
				PreparedStatement fetchDataStmt = Database.getConnection().prepareStatement(fetchDataSql);
				fetchDataStmt.setInt(1, user_id);
				ResultSet rs = fetchDataStmt.executeQuery();
				if(rs.next())
				{
					String user_role = rs.getString(1);
				    return "success-"+user_id+"-"+user_role;
				}
				return "serverError";
			}
			else if(user_auth_type.equals("email"))
			{
			    String fetchDataSql = "SELECT  user_passwords.password, user_credentials.user_role FROM user_credentials AS user_credentials, user_passwords AS user_passwords WHERE user_credentials.user_id = ? AND user_passwords.user_id = ?;";
			    PreparedStatement fetchDataStmt = Database.getConnection().prepareStatement(fetchDataSql);
			    fetchDataStmt.setInt(1, user_id);
			    fetchDataStmt.setInt(2, user_id);
			    ResultSet rs = fetchDataStmt.executeQuery();
				if(rs.next())
				{
					String user_entered_password_hash = Security.get_sha_256(password);
					String password_hash_from_db = rs.getString(1);
					String user_role = rs.getString(2);
					if(password_hash_from_db.equals(user_entered_password_hash))
					{
						return "success-"+user_id+"-"+user_role;
					}
					else
					{
						return "wrongCredentials";
					}
				}
				return "serverError";
			}
		}
		return "noSuchUser";
	}
	
	public static String resetPassword(int user_id, String currentPassword, String newPassword)
	{
		try
		{
			String fetchCurrentPasswordSql = "SELECT password FROM user_passwords WHERE user_id = ?";
			PreparedStatement fetchCurrentPasswordStmt = Database.getConnection().prepareStatement(fetchCurrentPasswordSql);
			fetchCurrentPasswordStmt.setInt(1, user_id);
			ResultSet rs = fetchCurrentPasswordStmt.executeQuery();
			while(rs.next())
			{
				if(rs.getString(1).equals(Security.get_sha_256(currentPassword)))
				{
					String updatePasswordSql = "UPDATE user_passwords SET password = sha2(?,256) WHERE user_id = ?";
					PreparedStatement updatePasswordStmt = Database.getConnection().prepareStatement(updatePasswordSql);
					updatePasswordStmt.setString(1, newPassword);
					updatePasswordStmt.setInt(2, user_id);
					int rowsAffected = updatePasswordStmt.executeUpdate();
					if(rowsAffected > 0)
					{
						return "success";
					}
				}
				else
				{
					return "wrongCurrentPassword";
				}
			}
			return "failed";
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("CustomerRepository.java", "resetPassword", e.toString());
		}
		return "serverError";
	}
	
	public static HashMap<String, Object> fetchJWT(HttpServletRequest request) throws JsonParseException, JsonMappingException, IOException 
	{
		HashMap<String, Object> jwt = null;
		Cookie cookies[] = request.getCookies();
		if(cookies != null)
		{
		    for(Cookie cookie:cookies)
		    {
			    if(cookie.getName().equals("user_token"))
			    {
				    String cookieValue = cookie.getValue();
				    String token = Security.decodeFromBase64(cookieValue.substring(0,cookieValue.indexOf(".")));
				    jwt = new ObjectMapper().readValue(token, HashMap.class);
			    }
		    }
		}
		return jwt;
	}
	
	public static void checkIsRegisteredUser(String email, HttpServletResponse response)
	{
		try
		{
		    int result = Check.isExistingUser(email);
		    boolean isExisting = result == -1 ? false : true;
			response.setContentType("application/json");
			PrintWriter out = response.getWriter();
			JSONObject jsonResponse = new JSONObject();
			jsonResponse.put("isExisting", isExisting);
			out.print(jsonResponse);
			out.flush();
		}
		catch(Exception e)
		{
			Logs.addDeveloperLog("UserRepository.java", "checkIsRegisteredUser", e.toString());
		}
	}
	
}
