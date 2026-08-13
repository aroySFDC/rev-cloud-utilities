/**
 * Context Service utility class to create ContextId and query data through tags     
 */
public class ContextService {

    private String contextId;
    private String contextDefinitionName;
    private String mappingName;
    private String targetMappingId;
    private Context.IndustriesContext industriesCtx;
    private static final String LOG_PREFIX = 'Apex ContextService: ';
    public Map<String, Object> contextResult = new Map<String, Object>();
    private Map<String, List<Map<String, String>>> recordData = new Map<String, List<Map<String, String>>>();
    private Map<String, Object> queryResult;

    public ContextService(String contextId) {
        this.contextId = contextId;
        this.industriesCtx = new Context.IndustriesContext();
    }

    public ContextService(String contextDefinitionName, String mappingName) {
        this.industriesCtx = new Context.IndustriesContext();
        this.recordData = new Map<String, List<Map<String, String>>>();
        this.setContextInputs(contextDefinitionName, mappingName);
    }

    /** Set the Mapping Id (fluent). */
    private void setContextInputs(String contextDefinitionName, String mappingName) {
        this.mappingName = mappingName;
        this.contextDefinitionName = contextDefinitionName;
    }

    /** Get the ContextId for the given object and record Id. */
    public ContextService getContext(String objectName, String recordId) {
        System.debug(LOG_PREFIX + 'Getting context for object: ' + objectName + ', recordId: ' + recordId);
        try {
            if (!recordData.containsKey(objectName)) {
            recordData.put(objectName, new List<Map<String, String>>());
            }
            recordData.get(objectName).add(new Map<String, String>{
                'id' => recordId,
                'businessObjectType' => objectName
            });
            Map<String, String> metadata = new Map<String, String>{
                'contextDefinitionName' => this.contextDefinitionName,
                'mappingName' => this.mappingName
            };

            Map<String, Object> contextInputs = new Map<String, Object>{
                'metadata' => metadata,
                'data' => JSON.serialize(recordData)
            };
            this.contextResult = industriesCtx.buildContext(contextInputs);
            this.contextId = (String)contextResult.get('contextId');
            this.targetMappingId = (String)contextResult.get('contextMappingId');
        } catch (Exception e) {
            System.debug(LOG_PREFIX + 'Error in getContext: ' + e.getMessage());
            throw e;
        }
        return this;
    }

    /** Get the cached ContextId. */
    public string getContextId(){
        if(this.contextResult.isEmpty()) throw new IllegalArgumentException('Call getContext() function to cache the result first before getting the context Id');
        return this.contextId;
    }

    /** Query tags for the current context. */
    public ContextService queryTags(List<String> tagNames) {
        if(String.isBlank(this.contextId)) {
            throw new IllegalArgumentException('Context Id is not set. Please call getContext() first.');
        }

        if(tagNames.isEmpty()) {
            throw new IllegalArgumentException('Tag names list is empty. Please provide at least one tag name to query.');
        }
        this.queryResult = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>{
            'contextId' => this.contextId,
            'tags' => tagNames
        };
        this.queryResult = (Map<String, Object>)industriesCtx.queryTags(input)?.get('queryResult');
        return this;
    }

    // TO DO: Implement updateContextAttributes method to update context attributes based on the provided dataPath and attributeMap.
    public void setAttributeValue(String tagName, String tagValue) {
        if(String.isBlank(this.contextId)) {
            throw new IllegalArgumentException('Context Id is not set. Please call getContext() first.');
        }

        if(this.queryResult == null || this.queryResult.isEmpty()) {
            throw new IllegalArgumentException('Query result is empty. Please call queryTags() first to populate the query result.');
        }
        List<Object> tagResult = (List<Object>)queryResult.get(tagName);
        Map<String,Object> contextTagDataRepresentation = (Map<String,Object>)tagResult.get(0);
        List<String> dataPath = (List<String>)contextTagDataRepresentation.get('dataPath');

        Map<String, Object> nodePathInputRepresentation = new Map<String, Object> {
            'nodePath' => new Map<String, Object> {'dataPath' => dataPath},
            'attributes' => getAttributeMap(tagName, tagValue)
        };
        
        Map<String, Object> input = new Map<String, Object>{
            'contextId' => this.contextId,
            'nodePathAndAttributes' => new List<Map<String, Object>>{nodePathInputRepresentation}
        };
        System.debug('\n Input payload for updater context attribute '+JSON.serialize(input));
        industriesCtx.updateContextAttributes(input);
    }

    public void commitContext() {
        if(String.isBlank(this.contextId)) {
            throw new IllegalArgumentException('Context Id is not set. Please call getContext() first.');
        }
        Map<String, Object> input = new Map<String, Object>();
        input.put('contextId', this.contextId);
        input.put('targetMappingId', this.targetMappingId);
        Map<String, Object> output = industriesCtx.persistContext(input);
    }

    private List<Map<String, Object>> getAttributeMap(String tagName, String tagValue) {
        List<Map<String, Object>> attributeList = new List<Map<String, Object>>();
        Map<String, Object> attributeMap = new Map<String, Object>{
            'attributeName' => tagName,
            'attributeValue' => tagValue
        };
        attributeList.add(attributeMap);
        return attributeList;
    }

}