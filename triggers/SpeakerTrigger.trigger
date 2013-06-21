trigger SpeakerTrigger on Speaker__c (after insert, after update) {

	List<User> approved_speakers = new List<User>();
	for(Speaker__c so : Trigger.new) {
		if(so.Approved__c && !Trigger.oldMap.get(so.Id).Approved__c) {
		//	approved_speakers.add(DataUtility.createSpeakerUser(so.Id));
		}
	}
	
	insert approved_speakers;


}