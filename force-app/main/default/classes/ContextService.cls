/**
 * Context Service utility class to create ContextId and query data through tags     
 */
public class ContextService {

    private String contextId;
    private String contextDefinitionName;
    private String mappingName;
    private Context.IndustriesContext industriesCtx;
    private static final String LOG_PREFIX = 'Apex ContextService: ';
    protected Map<String, Object> contextResult = new Map<String, Object>();
    private Map<String, List<Map<String, String>>> recordData = new Map<String, List<Map<String, String>>>();

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

    
    public ContextService getContext(String objectName, String recordId) {
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
        return this;
    }

    /** Query tags for the current context. */
    public Map<String, Object> queryTags(List<String> tagNames) {
        if(String.isBlank(this.contextId)) {
            throw new IllegalArgumentException('Context Id is not set. Please call getContext() first.');
        }

        Map<String, Object> input = new Map<String, Object>{
            'contextId' => this.contextId,
            'tags' => (tagNames == null) ? new List<String>() : tagNames
        };
        Map<String, Object> output = (Map<String, Object>)industriesCtx.queryTags(input)?.get('queryResult');
        return output;
    }

}