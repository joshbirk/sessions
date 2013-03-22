public with sharing class DataUtility {
	public DataUtility() {	}
	
	public static void createMilestoneData() {
		List<Milestone__c> milestones = new List<Milestone__c>();
		milestones.add(new Milestone__c(Name='Title Approved', Deadline__c=date.parse('1/2/2013')));
		milestones.add(new Milestone__c(Name='Abstract Approved', Deadline__c=date.parse('11/3/2013')));
		milestones.add(new Milestone__c(Name='Speakers Approved', Deadline__c=date.parse('11/4/2013')));
		milestones.add(new Milestone__c(Name='Slides Drafted', Deadline__c=date.parse('11/5/2013')));
		milestones.add(new Milestone__c(Name='Dry Run Scheduled', Deadline__c=date.parse('11/6/2013')));
		milestones.add(new Milestone__c(Name='Dry Run Approved', Deadline__c=date.parse('11/7/2013')));
		milestones.add(new Milestone__c(Name='Slides Approved', Deadline__c=date.parse('11/8/2013')));
		
		insert milestones;
	}
	
	public static List<Session__c> checkMilestones(List<Session__c> scope) {
		Date t = Date.Today();	
		Map<Id,Session__c> mapped_sessions = new Map<Id,Session__c>(scope);
		for(Session__c s : scope) {
			s.Behind_Milestones__c = false; //assume the session is not behind
		}
		Map<Id, Session_Milestone__c> milestones = new Map<Id, Session_Milestone__c>([SELECT Id,Session__c from Session_Milestone__c WHERE Session__c IN :mapped_sessions.keyset() AND Completed__c = NULL AND Milestone__r.Deadline__c <= :t]);
		for(Id milestone_id : milestones.keySet()) {
			mapped_sessions.get(milestones.get(milestone_id).Session__c).Behind_Milestones__c = true; //failed milestone found
			}
		
		
		return scope;
	}
	
	
	public static List<Session_Milestone__c> createMilestonesFor(Session__c s) {
		List<Session_Milestone__c> session_milestones = new List<Session_Milestone__c>();
		List<Milestone__c> existing_milestones = [SELECT ID from Milestone__c];
		for(Milestone__c m : existing_milestones) {
			session_milestones.add(new Session_Milestone__c(Session__c=s.Id,Milestone__c=m.Id));
		}
		
		return session_milestones;
	}
	
	public static List<Session_Speaker__c> checkDuplicateLeadSpeakers(List<Session_Speaker__c> scope) {
		List<Id> session_ids = new List<Id>();
		List<Session_Speaker__c> dupe_leads = new List<Session_Speaker__c>();
		Map<Id,Session_Speaker__c> lead_speakers = new Map<Id,Session_Speaker__c>();
	
		for(Session_Speaker__c s : scope) {
			if(s.Lead_Speaker__c == true) {
				session_ids.add(s.Session__c);
				if(s.Id != null) {lead_speakers.put(s.Id,s);}	
		}
		
		
		List<Session_Speaker__c> duplicate_leads = [SELECT ID from Session_Speaker__c WHERE ID NOT IN :lead_speakers.keySet() AND Session__c IN :session_ids AND Lead_Speaker__c = TRUE];
		for(Session_Speaker__c speaker : scope) {
				for(Session_Speaker__c dupe : duplicate_leads) {
					if(dupe.Session__c == speaker.Session__c) {
						dupe_leads.add(speaker);
					}
				}
			}
		
		
		}
	
		return dupe_leads;
	
	}
	
	
	

}