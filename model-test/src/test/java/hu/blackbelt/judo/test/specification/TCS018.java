package hu.blackbelt.judo.test.specification;

public interface TCS018 {

	/**
	 * Testing the static queries with constant default values.
	 * 
	 * @author ferenc.magnucz@blackbelt.hu
	 * @prerequisites Nothing
	 * @type Static
	 * @others
	 *  Implement this test case in the
	 *  {@link hu.blackbelt.judo.meta.jsl.model.test} module.
	 * @jslModel {@link modelTCS018.jsl}
	 * @requirements
	 * 	|===
	 *  | Requirement Id | Requirement testing type
	 *  //----------------------
	 *  | REQ-SYNT-001 | +
	 *  | REQ-SYNT-002 | +
	 *  | REQ-SYNT-003 | +
	 *  | REQ-SYNT-004 | +
	 *  | REQ-SYNT-005 | +
	 *  | REQ-TYPE-001 | +
	 *  | REQ-TYPE-002 | +
	 *  | REQ-TYPE-004 | +
	 *  | REQ-TYPE-005 | +
	 *  | REQ-TYPE-006 | +
	 *  | REQ-TYPE-007 | +
	 *  | REQ-TYPE-008 | +
	 *  | REQ-TYPE-009 | +
	 *  | REQ-MDL-001  | +
	 *  | REQ-ENT-001  | +
	 *  | REQ-ENT-002  | +
	 *  | REQ-ENT-004  | +
	 *  | REQ-ENT-005  | +
	 *  | REQ-ENT-009  | +
	 *  | REQ-ENT-011  | +
	 *  | REQ-EXPR-001 | +
	 *  | REQ-EXPR-002 | +
	 *  | REQ-EXPR-004 | +
	 *  | REQ-EXPR-006 | +
	 *  | REQ-EXPR-007 | +
	 *  | REQ-EXPR-008 | +
	 *  // TODO: JNG-4392 | REQ-EXPR-012 | +
	 *  | REQ-EXPR-022 | +
	 *  |===
	 * @scenario
	 *  . Parse (and/or build) the model.
	 *
	 *  . The result of the model parsing (and/or building) is successful.
	 */
	void tcs018();
	
	
}
