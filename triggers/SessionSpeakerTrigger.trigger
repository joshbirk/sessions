trigger SessionSpeakerTrigger on Session_Speaker__c (before insert, before update, after insert, after update) {

	Map<Id,Session_Speaker__c> duplicate_leads = new Map<Id,Session_Speaker__c>();
	
	if(Trigger.isBefore) {
		duplicate_leads = new Map<Id,Session_Speaker__c>(DataUtility.checkDuplicateLeadSpeakers(Trigger.new));
		List<Session_Speaker__c> approved_speakers = new List<Session_Speaker__c>();
		
		for(Session_Speaker__c s : duplicate_leads.values()) {
			s.addError('You cannot have more than one lead speaker');
		}
		for(Session_Speaker__c speaker : Trigger.new) {
		if(speaker.Approved__c && speaker.Accepted__c && !speaker.Notification_Sent__c) {
			speaker.Notification_Sent__c = true;
			approved_speakers.add(speaker);
			}
		}
	//	PortalHandler.sendSessionApprovalEmail(approved_speakers);
	}
	
	if(Trigger.isAfter) {
		List<Session__c> sessions_with_leads = new List<Session__c>();
		
		for(Session_Speaker__c speaker : Trigger.new) {
			if(!duplicate_leads.containsKey(speaker.Id) && speaker.Lead_Speaker__c == true) {
				Session__c session = new Session__c(Id=speaker.Session__c,Lead_Speaker__c=speaker.Id);
				sessions_with_leads.add(session);
			}
			
			
		}
		update sessions_with_leads;
		
		
	}

}