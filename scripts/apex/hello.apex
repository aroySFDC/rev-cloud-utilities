ContextService contextService = new ContextService('RLM_SalesTransactionContext', 'QuoteEntitiesMapping');
contextService.getContext('Quote', '0Q0ak000002pn3xCAA');
System.debug('Context Definition Result '+contextService.contextResult);