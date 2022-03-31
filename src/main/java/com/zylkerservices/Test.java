package com.zylkerservices;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Random;
import java.util.Scanner;
import java.util.regex.Pattern;

public class Test {
	
	public static char getRandomValue()
	{
		Random rand = new Random();
		String alphabets = "abcdefghijklmnopqrstuvwxyzABCDEFGHILKLMNOPQRSTUVWXYZ0123456789";
		return alphabets.charAt((rand.nextInt((61 - 0))+0));
	}
	
	public static String createCsrfToken()
	{
		String csrfToken = "";
		for(int i=0;i<128;i++)
		{
		    csrfToken += getRandomValue();
		}
		return csrfToken;
	}
	public static double calculateTax(int serviceCharge)
	{
		return (18*serviceCharge*1.0)/100;
	}
	

	public static void main(String[] args)
	{
		Scanner sc = new Scanner(System.in);
		LocalDate date = LocalDate.now();
		LocalDate endDate = date.plusDays(31);
		System.out.println(date+" "+endDate);
		//String input = sc.nextLine();
		//System.out.println(Pattern.matches("[a-zA-z0-9]{1,64}+@+[a-zA-Z0-9]{1,255}+.+[a-zA-Z0-9]{1,64}", input)); 
		//System.out.println(Pattern.matches("^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$", input));

		//System.out.println(Security.decodeFromBase64("eyJ1c2VyX3JvbGUiOiJjdXN0b21lciIsInVzZXJfaWQiOjEwMDc4LCJjc3JmIjoiMkduZm5hMUZaaWwxMXEwbU1rUDZxZnZHT0RBWWRMcmxwSERISXRuVVFoRG9oN1RMR1Vla1FZODY2ZFl3d2pZdU1YelY4UndvU1B1MDJZaGM1dlhsWEtvVjF4eXRRb3FkbzFBMnRaZERlZThFVTQyd1lZYlpaNm00dXhBd2JLd1QiLCJleHAiOjE2NDY4MTYyMTIxMzQsImlhdCI6MTY0NjgxMjYxMjEzNH0="));
		
	}
}
