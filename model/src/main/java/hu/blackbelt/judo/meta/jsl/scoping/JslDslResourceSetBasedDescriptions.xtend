package hu.blackbelt.judo.meta.jsl.scoping

import java.io.InputStream
import java.io.ByteArrayInputStream
import org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions
import org.eclipse.xtext.resource.impl.ResourceDescriptionsData
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.emf.ecore.resource.ResourceSet
import com.google.inject.Singleton

@Singleton
class JslDslResourceSetBasedDescriptions extends ResourceSetBasedResourceDescriptions {

	val uri = org.eclipse.emf.common.util.URI.createPlatformResourceURI("platform:/resource/judo-types.jsl", true)
	//val uri = org.eclipse.emf.common.util.URI.createPlatformResourceURI("__judotypes/_synthetic.jsl", true)
	

	override synchronized setContext(Notifier ctx) {
		super.context = ctx;
		
		//val resourceSet = EcoreUtil2.getResourceSet(ctx);
		//loadJudoTypes(super.resourceSet);
		//if (resourceSet != null) {
		//	data = ResourceDescriptionsData.ResourceSetAdapter.findResourceDescriptionsData(resourceSet);
		//}
	}


    def void loadJudoTypes(ResourceSet resourceSet) {
    	if (resourceSet != null) {
	    	var resource = resourceSet.getResource(uri, false)
	    	if (resource === null) {
	    		resource = resourceSet.createResource(uri)		
		        val InputStream in = new ByteArrayInputStream(judoTypes().toString().getBytes("UTF-8"))
		        resource.load(in, resourceSet.getLoadOptions())
	    	}    		
    	}
    }
	    
    def judoTypes() '''
		model judo::types;
		
		type boolean Boolean;
		type date Date;
		type time Time;
		type timestamp Timestamp;
		type numeric Integer(precision = 15, scale = 0);
		type string String(min-size = 0, max-size = 4000);
    '''
    
}
   