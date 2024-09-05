@isTest
public class TestFactoryData {
    public static List<Account> createAccountsWithContacts(Integer numAccts, Integer numContactsPerAccount){
        List<Account> accts = new List<Account>();
        Set<String> accNames = new Set<String>();
        for(Integer i=0; i<numAccts; i++){
            Account acc = new Account(Name='Test Account' + i);
            accNames.add('Test Account' + i);
            accts.add(acc);
        }
        insert accts;
        List<Contact> cons = new List<Contact>();
        //Loop through Accounts and Add required number of Accounts
        for(Integer j = 0; j < numAccts; j++){
            Account acct = accts[j];
            for(Integer k = 0; k < numContactsPerAccount; k++){
                cons.add(new Contact(LastName=acct.Name + ' Contact' + k,
                        AccountId=acct.Id));
            }
        }
        insert cons;
        accts = [SELECT name, id, (SELECT LastName, id FROM Contacts) FROM Account WHERE Name IN :accNames];
        System.debug('accts insert = ' + accts);
		return accts;        
    }    
    
    public static List<ContentVersion> createContentVersion(Integer numContentVersions){
        
        List<ContentVersion> conVersions = new List<ContentVersion>();
        Set<String> conVersionTitles = new Set<String>();
        for(Integer i = 0; i < numContentVersions; i++){
            ContentVersion c = new ContentVersion(
            					Title='File Name' + i,
            					PathOnClient='test',
            					VersionData=blob.valueOf('Test Content data'),
            					Description= 'Send Email' + i);
            conVersionTitles.add('File Name' + i);
            conVersions.add(c);
        }
        insert conVersions;
        conVersions = [SELECT ContentDocumentID FROM ContentVersion WHERE Title IN :conVersionTitles];
        //System.debug('conversions insert = ' + conVersions);
        return conVersions;        
    }


}