trigger SessionMilestoneTrigger on Session_Milestone__c (after insert, after update) {

	Map<Id,Session__c> sessions_map = new Map<Id,Session__c>();
	List<Session__c> sessions_to_update = new List<Session__c>();
	for(Session_Milestone__c  so : Trigger.new) {
		if(!sessions_map.containsKey(so.Session__c)) {
			sessions_to_update.add(new Session__c(id=so.Session__c));
		}
		sessions_map.put(so.Session__c,new Session__c(id=so.Session__c));
	}
	
	update DataUtility.checkMilestones(sessions_to_update);


}