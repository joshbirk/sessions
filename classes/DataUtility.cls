public with sharing class DataUtility {
	public static final Integer NUMBER_OF_MILESTONES = 7;

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
	
	public static List<Session__c> checkMilestones(List<SObject> scope) {
		Date t = Date.Today();	
		for(SOBject s : scope) {
			Session__c session = (Session__c)s;
			session.Behind_Milestones__c = false; //assume the session is not behind
		}
		Map<Id, Session_Milestone__c> milestones = new Map<Id, Session_Milestone__c>([SELECT Id,Session__c from Session_Milestone__c WHERE Completed__c = NULL AND Milestone__r.Deadline__c <= :t]);
		for(Id milestone_id : milestones.keySet()) {
			for(SObject s : scope) {
				Session__c session = (Session__c)s;
				if(milestones.get(milestone_id).Session__c == session.Id) {
					session.Behind_Milestones__c = true; //failed milestone found
				}
			}
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
	
	
	@IsTest
	public static void testCreateMilestoneData() {
		DataUtility.createMilestoneData();		
		List<Milestone__c> milestones = [SELECT ID from Milestone__c];
		System.assertEquals(DataUtility.NUMBER_OF_MILESTONES,milestones.size());
		
		Session__c session = new Session__c(Title__c='Test Session');
		insert session;
		
		List<Session_Milestone__c> s_milestones = [SELECT ID from Session_Milestone__c where Session__c =: session.Id];
		System.assertEquals(DataUtility.NUMBER_OF_MILESTONES,s_milestones.size());
		
	}

}
