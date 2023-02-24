package hu.blackbelt.judo.test.specification;

/**
 * This is a test specification template.
 */
public interface TCS000 {

	/**
	 * This is a test specification template.
	 * 
	 * @author <email_address_of_the_author>
	 * 
	 * @prerequisites TODO Write here what are the prerequisites for starting this test case.
	 *  If there isn't anything, use the 'Nothing' word.
	 *  For example: "The XXX environment variable value is 'lorem ipsum'" OR "Nothing"
	 * 
	 * @type TODO Use one of the following both words 'Static' or 'Behaviour'.
	 *  'Static' means that the test case parsing a JSL model and check the result of the parsing.
	 *  'Behaviour' means that the test case generate the SDK of a JSL model, and do something via the generated SDK.
	 *  For example, it creates one ore more entity instance, and checks their attributes.
	 * 
	 * @others
	 *  TODO Write here any other instructions or information, that is necessary or important to implement
	 *  the test case. This is an optional property.
	 * 
	 * @jslModel
	 *  TODO Give a JSL model, that the test case has to use.
	 * 
	 * @requirements
	 *  Write here the requirement identifiers which this test case checks.
	 *  Moreover, indicate the purpose of the requirement test. It can be positive (+) or negative (-).
	 * 	|===
	 *  | Requirement Id | Requirement testing type
	 *  //----------------------
	 *  | TODO | +
	 *  | TODO | -  
	 *  |===
	 * 
	 * @scenario
	 *  TODO Write here the steps of this test.
	 */
	void tcs000();
}
