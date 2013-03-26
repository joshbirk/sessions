global with sharing class AsyncUtility implements Database.Batchable<sObject>, Schedulable, Messaging.InboundEmailHandler {
    //To use a callout in batch Apex, you must specify Database.AllowsCallouts
    //   IE: implements Database.Batchable<sObject>, Database.AllowsCallouts{}
    //use Database.Stateful to maintain state between jobs  
    
    //global or global
    global AsyncUtility() {}
    
    
    //--- Scheduled Apex
    global void execute(SchedulableContext ctx) {
            //currently SchedulableContext has one method: getTriggerID
            //use System.abort() to stop execution
            
            //Scheduled logic
            //UtilityClass.method();
            sendNagEmails();
            }
            
    global static void sendNagEmails() {
    /*    List<Session__c> sessions_behind = [SELECT Id, Behind_Milestones__c, Content_Owner__r.Email__c, Evangelist__r.Email__c, Title__c from Session__c WHERE Behind_Milestones__c = TRUE];
        for (Session__c s : sessions_behind) {
            List<String> emails = new List<String>();
            emails.add(s.Content_Owner__r.Email__c);
            emails.add(s.Evangelist__r.Email__c);
            
            sendEmail('[SESSIONS] Session "'+s.Title__c+'" is behind milestones','"'+s.Title__c+'" is behind milestones.',emails,false);
      
        } */
        
        
    }
    
    //--- Batch Apex         
    global Database.QueryLocator start(Database.BatchableContext BC){
            //similarly, BatchableContext has getJobID method
            
            //update SOQL for your query locator
            return Database.getQueryLocator('SELECT ID, Behind_Milestones__c FROM Session__c');
            }
            
    global void execute(Database.BatchableContext BC, List<sObject> scope) { 
            List<Session__c> sessions_in_scope = new List<Session__c>();
            for(SObject s : scope) {
                sessions_in_scope.add(new Session__c(id=s.Id));
            }
            update DataUtility.checkMilestones(sessions_in_scope);  
            }
    
    global void finish(Database.BatchableContext BC) { 
            //send notifications, final clean up
            }
    
    
    //-- Inbound Email      
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
           //inboundEmail has:
           //binaryAttachments, textAttachments, 
           //ccAddresses, fromAddress, fromName, replyTo, subject,  toAddresses,
           //htmlBodyIsTruncated, inReplyTo, messageId, plainTextBody, plainTextBodyIsTruncated, references, headers, htmlBody 
    
           //Handle email, ie:
           //UtilityClass.method(email.Subject, email.plainTextBody);
    
           //assuming everything went well
           Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
           result.success = true;
           return result; 
           }

    //-- Outbound Email 
    static global Boolean sendEmail(String subject, String body, List<String> toAddresses, Boolean isHTML, Boolean sendBlind) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject (subject);  
            if(isHTML) {
                mail.setHTMLBody(body);
            } else {
                mail.setPlainTextBody(body);
            }   
            Messaging.SendEmailResult []r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            return r[0].isSuccess();
        }
    
    @IsTest
    static void testAsyncApex() {
        DataUtility.createMilestoneData();      
        List<Milestone__c> milestones = [SELECT ID from Milestone__c];
        System.assertEquals(7,milestones.size());

        Session__c s = new Session__c(Title__c='Test Session');
        insert s;

        
        Test.startTest();
            AsyncUtility job = new AsyncUtility();
            ID batchprocessid = Database.executeBatch(job);
        Test.stopTest();
        
        List<Session__c> sessions_behind = [SELECT Id from Session__c WHERE Behind_Milestones__c = TRUE];
        System.assertEquals(1,sessions_behind.size());
    }   

}