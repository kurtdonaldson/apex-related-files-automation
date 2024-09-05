@isTest
public with sharing class TestContentDocumentLinkUpload {
    
    @isTest
    public static void TestContentDocumentLinkUploadToContacts(){
        
        //Create Account with Contacts

        List<Account> accWithContacts = TestFactoryData.createAccountsWithContacts(1, 2);
        
        List<ContentVersion> conVersions = TestFactoryData.createContentVersion(1); 
            
       
        //Create content doc link. use same ContactDocumentId as content version. Link to Account
        ContentDocumentLink testContentDocLink = new ContentDocumentLink(
            ContentDocumentID = conVersions[0].ContentDocumentId,
            LinkedEntityId = accWithContacts[0].id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        

        //Insert Account ContentDocumentLink
        insert testContentDocLink;
        
        //Query the Contacts that were inserted
        List<Contact> childContacts = [SELECT id, Name from Contact WHERE accountid = :accWithContacts[0].id];
               
        //Check to see if there are 2 LinkedEntity IDs that match the Contact IDs, and that the CDLs have the same ContentDocumentIDs
        List<ContentDocumentLink> resultList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :conVersions[0].ContentDocumentId AND (LinkedEntityID = :accWithContacts[0].Contacts[0].id OR LinkedEntityID = :accWithContacts[0].Contacts[1].id)];
        
        //Then check to see if contentdoc link was created that has the same ContentDocumentID for account
        List<ID> contactIds = new List<ID>();
        
        for(ContentDocumentLink results : resultList){
            if(results.ContentDocumentId != null){
                contactIds.add(results.ContentDocumentId);
            }
        }       
    }
    
    @isTest
    public static void TestContentDocumentLinkUploadToAccount() {
                        
        //Create Account with Contacts
        List<Account> accWithContacts = TestFactoryData.createAccountsWithContacts(1, 1);
        
        List<ContentVersion> conVersions = TestFactoryData.createContentVersion(1);
       
        //Create content doc link. use same ContactDocumentId as content version. Link to Contact
        ContentDocumentLink testContentDocLink = new ContentDocumentLink(
            ContentDocumentID = conVersions[0].ContentDocumentID,
            LinkedEntityId = accWithContacts[0].Contacts[0].id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        //Insert Contact ContentDocumentLink
        insert testContentDocLink;

        //Query the Account that was inserted
        Account parentAccount = [SELECT id, Name from Account WHERE Id IN (SELECT accountId FROM Contact WHERE id = :accWithContacts[0].Contacts[0].id)];

        //Is there a ContentDocumentLink that was created that has the same ContentDocumentId as version.ContentDocumentID AND has a LinkedEntityID the same as parentAccount.id
        List<ContentDocumentLink> resultList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :conVersions[0].ContentDocumentID AND LinkedEntityID = :parentAccount.id];
        
        
         //Then check to see if contentdoc link was created that has the same ContentDocumentID for account
        ID result = null;
        
        for(ContentDocumentLink results : resultList){
            if(results.ContentDocumentId != null){
                result = results.ContentDocumentId;
            }
        }
        
        //System.debug(result);
        System.assert(result != null);
    }
}