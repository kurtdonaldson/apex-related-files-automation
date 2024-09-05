public class ContentDocLinkTriggerHelper {
    
    public static void ContentDocLinkUpload(List<ContentDocumentLink> triggeredConDocLinks){
         //Map to store ContentDocument Ids and their ContentDocumentLinks
    	Map<ID, ID> contentDocLinks = new Map<ID, ID>();
    
   
   	 	//If the ContentDocumentID is populated in the ContentDocumentLink, we add it to the List
    	for(ContentDocumentLink conDocLink : triggeredConDocLinks){
        	if(conDocLink.ContentDocumentId != null && conDocLink.LinkedEntityId != null){        
            	contentDocLinks.put(conDocLink.ContentDocumentId, conDocLink.LinkedEntityId);         
        	}
    	}
    
  
    	//Get List of ALL LinkedEntity IDs that are associated with the Content Document. Doing this to avoid creating duplicates. 
        List<ID> linkedEntityIDs = new List<ID>();
    	for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocLinks.keySet()]){
    	    if(cdl.LinkedEntityId != null){
    	       linkedEntityIDs.add(cdl.LinkedEntityId);
    	    }
    	}
        
        
        //NEW ContentDocumentLinks to INSERT
        List<ContentDocumentLink> newContactDocumentLinks = new List<ContentDocumentLink>();  
        
    	
    	//if statement for Contact ContentDocumentLink triggers
    	List<Account> parentAccount = new List<Account>();
        List<Contact> childContactsOfParentAccount = new List<Contact>();
        
        if([SELECT id, LinkedEntity.type FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocLinks.keySet() Limit 1].LinkedEntity.type == 'Contact'){
            parentAccount = [SELECT id, name, (SELECT id, accountid FROM Contacts) FROM Account WHERE id IN (SELECT accountid FROM Contact WHERE id IN :contentDocLinks.values())];
    		childContactsOfParentAccount = [SELECT id, accountid FROM Contact WHERE accountid IN :parentAccount];
            
            //Map Account IDs to Contact IDs
    		Map<ID, Set<ID>> accountToContactsMap = new Map<ID, Set<ID>>();
    
        	for(Contact con : childContactsOfParentAccount){
     			if(con.id != null){
                	if(!accountToContactsMap.containsKey(con.accountid)){
                    	accountToContactsMap.put(con.accountid, new Set<ID>());
                	}
                	accountToContactsMap.get(con.accountid).add(con.id);
      			}
   			}
            
            //CONTACT TO ACCOUNT CODE
    		for(ID cdlContentDocId : contentDocLinks.keySet()){
        		for(Account acc : parentAccount){
                	//Below. Check if the accountsToContacts map has a contactID that matches the LinkedentityID. 
        			if(acc.id != null &&  accountToContactsMap.get(acc.id).contains(contentDocLinks.get(cdlContentDocId)))    {
        			ContentDocumentLink newCdl = new ContentDocumentLink();
        			newCdl.ContentDocumentId =  cdlContentDocId;
        			newCdl.LinkedEntityId = acc.id;
        			newCdl.ShareType = 'I';
        			newCdl.Visibility = 'AllUsers';
        			newContactDocumentLinks.add(newCdl);
        			}    
    			}              
    		}
            
            
        }
                
        //Contacts that are children of the Account associated with the ContentDocumentLink trigger
    	List<Contact> childContacts = new List<Contact>();
        if([SELECT id, LinkedEntity.type FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocLinks.keySet() Limit 1].LinkedEntity.type == 'Account'){
            childContacts = [SELECT id, accountid FROM Contact WHERE accountId IN :contentDocLinks.values() AND id NOT IN :linkedEntityIDs];
            
            //ACCOUNT TO CONTACTS CODE
     		for(ID cdlContentDocId : contentDocLinks.keySet()){
    			for(Contact con : childContacts){
     	  			if(con.id != null && con.accountId == contentDocLinks.get(cdlContentDocId))    {
     	   			ContentDocumentLink newCdl = new ContentDocumentLink();
     	   			newCdl.ContentDocumentId = cdlContentDocId;
     	   			newCdl.LinkedEntityId = con.id;
     	   			newCdl.ShareType = 'I';
    	    		newCdl.Visibility = 'AllUsers';
    	    		newContactDocumentLinks.add(newCdl);
    	    		} 
    			}            
    		}
            
        }

		//INSERT ContactDocumentLinks
        if(newContactDocumentLinks.size() > 0){
        insert newContactDocumentLinks;
    	}
    }

}