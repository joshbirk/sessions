public with sharing class MilestoneExt {

	public List<Milestone__c> milestones {get; set;}

	public MilestoneExt() {}
	public MilestoneExt(ApexPages.StandardController stc) {
		milestones = [SELECT Id, Name, Deadline__c from Milestone__c];
	}
		
}