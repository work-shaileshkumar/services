package com.zylkerservices;

import java.time.LocalDateTime;

public class User {
	
	private String email;
	private String password;
	private String user_role;
	private String user_auth_type;
	private LocalDateTime last_seen;
	private LocalDateTime acc_creation_date;
	boolean email_verification;
	
	// getters and setters
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getUser_role() {
		return user_role;
	}
	public void setUser_role(String user_role) {
		this.user_role = user_role;
	}
	public String getUser_auth_type() {
		return user_auth_type;
	}
	public void setUser_auth_type(String user_auth_type) {
		this.user_auth_type = user_auth_type;
	}
	@Override
	public String toString() {
		return "User [email=" + email + ", user_role=" + user_role + ", user_auth_type=" + user_auth_type
				+ ", last_seen=" + last_seen + ", acc_creation_date=" + acc_creation_date + ", email_verification="
				+ email_verification + "]";
	}
	public LocalDateTime getLast_seen() {
		return last_seen;
	}
	public void setLast_seen() {
		this.last_seen = LocalDateTime.now();
	}
	public LocalDateTime getAcc_creation_date() {
		return acc_creation_date;
	}
	public void setAcc_creation_date() {
		this.acc_creation_date = LocalDateTime.now();;
	}
	public boolean getEmail_verification() {
		return email_verification;
	}
	public void setEmail_verification(boolean email_verification) {
		this.email_verification = email_verification;
	}	
}
