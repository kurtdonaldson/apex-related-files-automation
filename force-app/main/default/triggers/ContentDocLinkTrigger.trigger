trigger ContentDocLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContentDocLinkTriggerHelper.ContentDocLinkUpload(Trigger.new);
        }
    }

}