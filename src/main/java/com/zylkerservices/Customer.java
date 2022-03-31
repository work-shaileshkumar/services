package com.zylkerservices;

public class Customer {
	
	private int customer_id;
	private String customer_email;
	private String customer_dp_url;
	private String customer_name;
	private Long customer_phno;
	private int wallet_balance;
	private int locked_wallet_balance;
	private String csrf;
	public int getCustomer_id() {
		return customer_id;
	}
	public void setCustomer_id(int customer_id) {
		this.customer_id = customer_id;
	}
	public String getCustomer_dp_url() {
		return customer_dp_url;
	}
	public String getCustomer_email() {
		return customer_email;
	}
	public void setCustomer_email(String customer_email) {
		this.customer_email = customer_email;
	}
	public void setCustomer_dp_url(String customer_dp_url) {
		this.customer_dp_url = customer_dp_url;
	}
	public String getCustomer_name() {
		return customer_name;
	}
	public void setCustomer_name(String customer_name) {
		this.customer_name = customer_name;
	}
	public Long getCustomer_phno() {
		return customer_phno;
	}
	@Override
	public String toString() {
		return "Customer [customer_id=" + customer_id + ", customer_email=" + customer_email + ", customer_dp_url="
				+ customer_dp_url + ", customer_name=" + customer_name + ", customer_phno=" + customer_phno
				+ ", wallet_balance=" + wallet_balance + ", locked_wallet_balance=" + locked_wallet_balance + "]";
	}
	public void setCustomer_phno(Long customer_phno) {
		this.customer_phno = customer_phno;
	}
	public int getWallet_balance() {
		return wallet_balance;
	}
	public void setWallet_balance(int wallet_balance) {
		this.wallet_balance = wallet_balance;
	}
	public int getLocked_wallet_balance() {
		return locked_wallet_balance;
	}
	public void setLocked_wallet_balance(int locked_wallet_balance) {
		this.locked_wallet_balance = locked_wallet_balance;
	}
	public String getCsrf() {
		return csrf;
	}
	public void setCsrf(String csrf) {
		this.csrf = csrf;
	}
}
