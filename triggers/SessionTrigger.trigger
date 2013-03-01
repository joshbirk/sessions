trigger SessionTrigger on Session__c (before update, after insert, after update) {


if(Trigger.isAfter) {
	List<Session_Milestone__c> new_milestones = new List<Session_Milestone__c>();
	Map<Id,Session__c> sessions_to_check = new Map<Id,Session__c>(Trigger.new);
	Map<Id,Session_Milestone__c> existing_milestones = new Map<Id,Session_Milestone__c>([SELECT Id, Session__c from Session_Milestone__c where Session__c IN :sessions_to_check.keySet()]);
	
	for(Id si : sessions_to_check.keySet()) {
		Boolean bFound = false;
		for(Id emi : existing_milestones.keySet()) {
			if(existing_milestones.get(emi).Session__c == si) {
				bFound = true;
			}
		}
		if(!bFound) { 
			new_milestones.addAll(DataUtility.createMilestonesFor(sessions_to_check.get(si)));
			}
	}
	
	insert new_milestones;
}

}