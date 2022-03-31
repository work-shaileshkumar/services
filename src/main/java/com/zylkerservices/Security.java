package com.zylkerservices;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.Random;

import org.json.simple.JSONObject;

public class Security {

    public static byte[] getSHA(String input)
    {
    	try
    	{
            MessageDigest md = MessageDigest.getInstance("SHA-256"); 
            return md.digest(input.getBytes(StandardCharsets.UTF_8)); 
    	}
    	catch(Exception e) 
    	{
    		return null;
    	}
    }
    
    public static String toHexString(byte[] hash)
    {
        StringBuilder hexString = new StringBuilder(2 * hash.length);
        for (int i = 0; i < hash.length; i++) {
            String hex = Integer.toHexString(0xff & hash[i]);
            if(hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }
    
    public static String get_sha_256(String str) 
    {
    	return toHexString(getSHA(str));
    }
    
    public static String encrypt(String str)
    {
    	String res = "";
    	for(char ch:str.toCharArray())
    	{
    		if(Character.isLetter(ch))
    		{
    			if(ch=='z' || ch=='Z') 
    				ch-=26;
    			ch++;
    		}
    		if(Character.isDigit(ch))
    		{
    			if(ch=='0')
    				ch = '9'+1;
    			ch--;
    		}
    		res += ch;
    	}
    	return res;
    }
    
    public static String decrypt(String str)
    {
    	String res = "";
    	for(char ch:str.toCharArray())
    	{
    		if(Character.isLetter(ch))
    		{
    			if(ch=='a' || ch=='A') 
    				ch+=26;
    			ch--;
    		}
    		if(Character.isDigit(ch))
    		{
    			if(ch=='9')
    				ch = '0'-1;
    			ch++;
    		}
    		res += ch;
    	}
    	return res;
    }
    
    public static String encodeToBase64(String str)
    {
        Base64.Encoder encoder = Base64.getEncoder();
        return encoder.encodeToString(str.getBytes()); 
    }
    
    public static String decodeFromBase64(String str)
    {
    	Base64.Decoder decoder = Base64.getDecoder();
        return  new String(decoder.decode(str));
    }
    
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
	
	public static String sanitize(String input)
	{
		String dangerousChars = "\\#+<>,;\"=";
		for(char ch:dangerousChars.toCharArray())
		{
			input = input.replaceAll(("\\"+ch+""), "");
		}
		return input;
	}
    
    public static String generate_JWT(int user_id, String user_role) throws NoSuchAlgorithmException
    {
    	JSONObject JWT = new JSONObject();
		Long iat = System.currentTimeMillis();
		Long exp = iat+(3600L*1000L);
    	JWT.put("user_id", user_id);
    	JWT.put("user_role", user_role);
    	JWT.put("iat", iat);
    	JWT.put("exp", exp);
    	JWT.put("csrf", createCsrfToken());
    	String JWT_String = JWT.toJSONString();
    	String response = encodeToBase64(JWT_String)+"."+encodeToBase64(Security.encrypt(Security.get_sha_256(JWT_String)));
    	return response;
    }
}
