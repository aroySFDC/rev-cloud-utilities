# ContextService utility apex class
Quickly build a context instance and query tags
update tags at run time and commit the change to database
```
ContextService contextService = new ContextService('RLM_SalesTransactionContext', 'QuoteEntitiesMapping').getContext('Quote', '0Q0ak000002pn3xCAA');
contextService = contextService.queryTags(new List<String>{'ShippingCity'});
contextService.setAttributeValue('ShippingCity', 'San Francisco');
contextService.commitContext();

## Get Attribute value
```
contextService = contextService.queryTags(new List<String>{'Status', 'ShippingCity'});
System.debug('\n Attrbute value for Status '+contextService.getAttributeValue('Status'));
```