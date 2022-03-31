package com.zylkerservices;

public class Partner {
	
	private int partner_id;
	private String govt_number;
	private String partner_name;
	private String partner_email;
	private Long partner_phno;
	private String partner_dp_url;
	private boolean partner_verification;
	private int number_of_orders_received;
	private int number_of_orders_completed;
	private double avg_rating;
	private int service_charge;
	private String csrf;
	@Override
	public String toString() {
		return "Partner [partner_id=" + partner_id + ", govt_number=" + govt_number + ", partner_name=" + partner_name
				+ ", partner_email=" + partner_email + ", partner_phno=" + partner_phno + ", partner_dp_url="
				+ partner_dp_url + ", partner_verification=" + partner_verification + ", number_of_orders_received="
				+ number_of_orders_received + ", number_of_orders_completed=" + number_of_orders_completed
				+ ", avg_rating=" + avg_rating + ", service_charge=" + service_charge + ", csrf=" + csrf + "]";
	}
	public int getPartner_id() {
		return partner_id;
	}
	public void setPartner_id(int partner_id) {
		this.partner_id = partner_id;
	}
	public String getGovt_number() {
		return govt_number;
	}
	public void setGovt_number(String govt_number) {
		this.govt_number = govt_number;
	}
	public String getPartner_name() {
		return partner_name;
	}
	public void setPartner_name(String partner_name) {
		this.partner_name = partner_name;
	}
	public Long getPartner_phno() {
		return partner_phno;
	}
	public void setPartner_phno(Long partner_phno) {
		this.partner_phno = partner_phno;
	}
	public String getPartner_dp_url() {
		return partner_dp_url;
	}
	public void setPartner_dp_url(String partner_dp_url) {
		this.partner_dp_url = partner_dp_url;
	}
	public boolean isPartner_verification() {
		return partner_verification;
	}
	public void setPartner_verification(boolean partner_verification) {
		this.partner_verification = partner_verification;
	}
	public int getNumber_of_orders_received() {
		return number_of_orders_received;
	}
	public void setNumber_of_orders_received(int number_of_orders_received) {
		this.number_of_orders_received = number_of_orders_received;
	}
	public int getNumber_of_orders_completed() {
		return number_of_orders_completed;
	}
	public void setNumber_of_orders_completed(int number_of_orders_completed) {
		this.number_of_orders_completed = number_of_orders_completed;
	}
	public double getAvg_rating() {
		return avg_rating;
	}
	public void setAvg_rating(double avg_rating) {
		this.avg_rating = avg_rating;
	}
	public void setService_charge(int service_charge)
	{
		this.service_charge = service_charge;
	}
	public int getService_charge()
	{
		return service_charge;
	}
	public String getPartner_email() {
		return partner_email;
	}
	public void setPartner_email(String partner_email) {
		this.partner_email = partner_email;
	}
	public String getCsrf() {
		return csrf;
	}
	public void setCsrf(String csrf) {
		this.csrf = csrf;
	}
}
