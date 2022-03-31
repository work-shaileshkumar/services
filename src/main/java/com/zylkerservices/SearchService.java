package com.zylkerservices;

import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

public class SearchService {
	
	public static List<Partner> findRelevantPartners(int serviceId, String serviceLocation, String searchText, String sortType)
	{
		List<Partner> relevantPartners = new ArrayList<Partner>();
		relevantPartners = PartnerRepository.getRelevantPartnersData(serviceId, serviceLocation, searchText, sortType);
		return relevantPartners;
	}
	
	public static void addViewCount(int customer_id, int partner_id, String serviceName, String serviceLocation)
	{
		PartnerRepository.updateProfileViews(customer_id, partner_id, serviceName, serviceLocation);
	}
	
	public static List<String> fetchAllAvailableServices()
	{
		List<String> availableServices = PartnerRepository.availableServices();
	    return availableServices;
	}
	
	public static List<String> fetchAllAvailableLocations()
	{
		List<String> availableLocations = PartnerRepository.availableLocations();
	    return availableLocations;
	}
}
