@IsTest
public with sharing class SessionUnitTests {

	public SessionUnitTests() {	}
	
	@IsTest
	public static void testCreateMilestoneData() {
		DataUtility.createMilestoneData();		
		List<Milestone__c> milestones = [SELECT ID from Milestone__c];
		System.assertEquals(7,milestones.size());
		
		Session__c session = new Session__c(Title__c='Test Session');
		insert session;
		
		List<Session_Milestone__c> s_milestones = [SELECT ID from Session_Milestone__c where Session__c =: session.Id];
		System.assertEquals(7,s_milestones.size());
		
	}
	
	//Test Milestone Check
	@IsTest 
	public static void mileStoneCheck() {
		DataUtility.createMilestoneData();		
		
		Session__c session = new Session__c(Title__c='Test Session');
		insert session;
		
		List<Session__c> sessions = [SELECT ID from Session__c];
		
		//Test for Session Milestones
		System.assertNotEquals(DataUtility.checkMilestones(sessions).size(),0);
		
		
	} 
	
	
	//Test Lead Speaker Check
	@IsTest 
	public static void leadSpeakerCheck() {
		DataUtility.createMilestoneData();		
		
		Session__c session = new Session__c(Title__c='Test Session');
		insert session;
		
		Speaker__c speaker = new Speaker__c(First_Name__c='Frank',Last_Name__c='Smith',Email__c='j@j.com',Mobile_Phone__c='888-888-8888');
		insert speaker;
		
		Session_Speaker__c ss = new Session_Speaker__c(Speaker__c=speaker.Id,Session__c=session.Id,Lead_Speaker__c=true);
		insert ss;
		
		Session_Speaker__c ss2 = ss.clone();
		
		try{
			insert ss2;
		} catch(DMLException e) {
			System.assertNotEquals(null,e.getMessage());
		}
		
		
		System.assertEquals(null,ss2.Id);
		List<Session__c> updated_session = [SELECT ID from Session__c WHERE ID =: session.id AND Lead_Speaker__c =: ss.Id];
		System.assertEquals(1,updated_session.size());
		
	}
	
	
	//Test Apex REST endpoint
	@IsTest
	public static void apexRESTSubmission() {
		 RestRequest req = new RestRequest(); 
		 RestResponse res = new RestResponse();
		 String jsonData = '{"FirstName": "Joe","LastName": "Smith","MobilePhone": "888-888-8888","Bio": "One Cool Guy","Email": "joe@smith.com","Title": "My Session","SessionAbstract": "is so cool"}';
		
/*		 req.requestURI = 'https://www.salesforce.com/services/apexrest/papers';  
		 req.httpMethod = 'POST';
		 req.requestBody = Blob.valueOf(jsonData);
		 RestContext.request = req;
		 RestContext.response = res; */
		 
		 CFPREST.FormData fd = (CFPREST.FormData)System.JSON.deserializeStrict(jsonData,CFPREST.FormData.class);
		 CFPREST.FormStatus fs = CFPREST.submitPaper(fd);
		 
		 List<Session__c> session = [SELECT ID, Lead_Speaker__c from Session__c];
		 System.assertEquals(session.size(),1);
		 
		 List<Speaker__c> speaker = [SELECT ID from Speaker__c];
		 System.assertEquals(speaker.size(),1);
		
		 List<Session_Speaker__c> ss = [SELECT ID, Lead_Speaker__c from Session_Speaker__c];
		 System.assertEquals(ss.size(),1);
		
		 System.assertEquals(session[0].Lead_Speaker__c,ss[0].Id);
	}
}

/*




System.DmlException: Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, SessionSpeakerTrigger: execution of BeforeInsert

caused by: System.ListException: Row with null Id at index: 0

Class.DataUtility.checkDuplicateLeadSpeakers: line 47, column 1
Trigger.SessionSpeakerTrigger: line 3, column 1: []


*/