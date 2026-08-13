ContextService contextService = new ContextService('RLM_SalesTransactionContext', 'QuoteEntitiesMapping');
contextService.getContext('Quote', '0Q0ak000002pn3xCAA');
System.debug('Context Definition Result ##### '+contextService.contextResult);
Map<String, Object> queryResult = contextService.queryTags(new List<String>{'Status', 'Account', 'ShippingCity'});
List<Object> shippingCityResult = (List<Object>)queryResult.get('ShippingCity');
Map<String,Object> contextTagDataRepresentation = (Map<String,Object>)shippingCityResult.get(0);
contextService.updateContextAttribute((List<String>)contextTagDataRepresentation.get('dataPath'), 'ShippingCity', 'San Francisco');
