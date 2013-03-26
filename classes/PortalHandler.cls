global with sharing class PortalHandler implements Auth.RegistrationHandler{
	
		global User createUser(Id portalId, Auth.UserData data){
		    User u = new User();
		    Profile p = [SELECT Id FROM profile WHERE name='DFC Speaker'];
		    u.username = data.username;
			System.debug(u.username);
		    u.email = data.email;
		    u.lastName = data.lastName;
		    u.firstName = data.firstName;
		    String alias = data.username;
		    if(alias.length() > 8) {
		        alias = alias.substring(0, 8);
		    }
		    u.alias = alias;
		    u.languagelocalekey = data.locale;
		    u.localesidkey = data.locale;
		    u.emailEncodingKey = 'UTF-8';
		    u.timeZoneSidKey = 'America/Los_Angeles';
		    u.profileId = p.Id;
			System.debug(u.profileId);

		    return u;
		}

		global void updateUser(Id userId, Id portalId, Auth.UserData data){}

		global static void sendSpeakerApprovalEmail(List<Speaker__c> speakers) {
	
		}

		global static void sendSessionApprovalEmail(List<Session_Speaker__c> speakers) {
	
		}

}