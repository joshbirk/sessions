@RestResource(urlMapping='/papers/*')
global with sharing class CFPREST {

	global CFPREST() {}
	
	//{"data":{"FirstName": "Joe","LastName": "Smith","MobilePhone": "888-888-8888","Bio": "One Cool Guy","Email": "joe@smith.com","Title": "My Session","SessionAbstract": "is so cool"}}	
	@HTTPPost
	global static FormStatus submitPaper(FormData data) {
		Speaker__c speaker = new Speaker__c(First_Name__c=data.FirstName,Last_Name__c=data.LastName,Mobile_Phone__c=data.MobilePhone,Position__c=data.Position,Company__c=data.Company,Email__c=data.Email,Twitter__c=data.Twitter,Bio__c=data.Bio);
		
		List<Speaker__c> existing_speakers = [SELECT ID from Speaker__c WHERE Email__c =: data.Email];
		if(existing_speakers.size() == 0) {
			//speaker does not exist, attempt to create one
			try {
				insert speaker;
			} catch(DMLException e) {
				FormStatus fs = new FormStatus();
				fs.Status = 'Error';
				fs.Message = e.getMessage();
			
				return fs;
			}
			
		} else {
			speaker.Id = existing_speakers[0].Id;
		}
		
		Session__c session = new Session__c(CFP__c=true,Title__c=data.Title,Abstract__c=data.SessionAbstract,Additional_Details__c=data.Notes,Track__c=data.Track,Level__c=data.Level);
		if(data.Type == 'ISV') {
			session.ISV_Submission__c = true;
		}
		if(data.Email.indexOf('@salesforce.com') != -1) {
			session.Internal_Submission__c = true;
			session.CFP__c = false;
		}
		try {
			insert session;
		} catch(DMLException e) {
			FormStatus fs = new FormStatus();
			fs.Status = 'Error';
			fs.Message = e.getMessage();
			
			return fs;
		}
		
		Session_Speaker__c ss = new Session_Speaker__c(Session__c=session.Id,Speaker__c=speaker.Id,Lead_Speaker__c=true);
		try {
			insert ss;
		} catch(DMLException e) {
			FormStatus fs = new FormStatus();
			fs.Status = 'Error';
			fs.Message = e.getMessage();
			
			return fs;
		}
		
		FormStatus fs = new FormStatus();
		fs.Status = 'Completed';
		fs.Message = 'Submission complete. Speaker:'+speaker.Id+' Session:'+session.Id;
		fs.Speaker = [SELECT Name, Name__c, Email__c, Position__c, Company__c, Bio__c from Speaker__c WHERE ID =: speaker.Id];
		fs.Session = [SELECT Name, Title__c, Abstract__c, Additional_Details__c from Session__c WHERE ID =: session.Id];
		return fs;
	}	
	
	
	
	global class FormData {
    //Speaker Submission Data
        global String FirstName { get; set; }
        global String LastName { get; set; }
        global String MobilePhone { get; set; }
        global String Position { get; set; }
        global String Company { get; set; }
		global String Email { get; set; }
		global String Twitter { get; set; }
		global String Bio { get; set; }
		
	//Session Submission Data
		global String Title { get; set; }
        global String SessionAbstract { get; set; }
        global String Notes { get; set; }
		global String Track { get; set; }
		global String Level { get; set; }
		global String Type { get; set; }
	}	
	
	//Response Data
	global class FormStatus {
		global String Status { get; set; }
        global String Message { get; set; }
		global Session__c Session{ get; set; }
		global Speaker__c Speaker { get; set; }
	}

}