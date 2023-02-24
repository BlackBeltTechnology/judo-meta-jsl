package hu.blackbelt.judo.test.specification;

public interface TCS019 {

	/**
	 * Testing the static queries with default values that are expressions.
	 * 
	 * @author ferenc.magnucz@blackbelt.hu
	 * @prerequisites Nothing
	 * @type Static
	 * @others
	 *  Implement this test case in the
	 *  {@link hu.blackbelt.judo.meta.jsl.model.test} module.
	 * @jslModel
	 *  <pre>
     * model modelTCS019;
     * 
     * import judo::types;
     * 
     * // Decimal
     * type numeric Decimal(precision = 13, scale = 4);
     * 
     * // my enum
     * enum MyEnum {
     *     A01 = 1;
     *     A02 = 2;
     *     A03 = 3;
     *     A00 = 0;
     * }
     * 
     * // MyEntity
     * entity MyEntity {
     *     field Timestamp fCreated = Timestamp!now();
     *     field Boolean   fBool;
     *     field Date      fDate;
     *     field Time      fTime;
     *     field Long      fLong;
     *     field String    fString;
     *     field Decimal   fDecimal;
     *     field MyEnum    fEnum;
     * }
     * 
     * // Entity for the results of queries
     * entity Snapshot {
     *     field Timestamp created = Timestamp!now();
     * 
     *     // relations
     *     relation MyEntity[] defEntities; // = setOfMyEntities();
     * }
     * 
     * query MyEntity[] queryByTimestamp(
     *     Timestamp p1 = Timestamp!now()
     * ) => MyEntity!all()
     *      !filter(e | e.fCreated <= p1);
     * 
     * query MyEntity[] queryByBoolean(
     *     Boolean p1 = (1 >= 2)
     * ) => MyEntity!all()
     *      !filter(e | e.fBool == p1);
     * 
     * query MyEntity[] queryByDate(
     *     Date p1 = Date!now()
     * ) => MyEntity!all()
     *      !filter(e | e.fDate == p1);
     * 
     * query MyEntity[] queryByTime(
     *     Time p1 = Time!now()
     * ) => MyEntity!all()
     *      !filter(e | e.fTime == p1);
     * 
     * query MyEntity[] queryByLong(
     *     Long p1 = (1 + 2)
     * ) => MyEntity!all()
     *      !filter(e | e.fLong == p1);
     * 
     * query MyEntity[] queryByString(
     *     String p1 = "Lorem ipsum"!left(count = 2)
     * ) => MyEntity!all()
     *      !filter(e | e.fString == p1);
     * 
     * query MyEntity[] queryByDecimal(
     *     Decimal p1 = (-1526.225)!round(scale = 2)
     * ) => MyEntity!all()
     *      !filter(e | e.fDecimal == p1);
     * 
     * query MyEntity[] queryByMyEnum(
     *     MyEnum p1 = (1 <= 2 ? MyEnum#A00 : MyEnum#A03)
     * ) => MyEntity!all()
     *      !filter(e | e.fEnum == p1);
	 *  </pre>
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
	void tcs019();
}
