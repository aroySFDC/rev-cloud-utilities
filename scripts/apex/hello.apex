ContextService contextService = new ContextService('RLM_SalesTransactionContext', 'QuoteEntitiesMapping').getContext('Quote', '0Q0ak000002pn3xCAA');
contextService = contextService.queryTags(new List<String>{'ShippingCity'});
contextService.setAttributeValue('ShippingCity', 'San Francisco');
contextService.commitContext();


