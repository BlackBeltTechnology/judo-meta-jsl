package hu.blackbelt.judo.meta.jsl.runtime

import org.junit.jupiter.api.Test
import hu.blackbelt.judo.requirement.report.annotation.TestCase
import hu.blackbelt.judo.requirement.report.annotation.Requirement

class InstanceQueryTests {
    
    /**
     * Testing the instance queries with constant default values.
     * 
     * @prerequisites Nothing
     * 
     * @type Static
     * 
     * @jslModel
     *  model modelTC024;
     *             
     *  // Decimal
     *  type numeric Decimal(precision = 13, scale = 4);
     *  
     *  type boolean Boolean;
     *  type date Date;
     *  type time Time;
     *  type timestamp Timestamp;
     *  type numeric Integer(precision = 9, scale = 0);
     *  type numeric Long(precision = 15, scale = 0);
     *  type string String(min-size = 0, max-size = 200);
     *  
     *  // my enum
     *  enum MyEnum {
     *      A01 = 1;
     *      A02 = 2;
     *      A03 = 3;
     *      A00 = 0;
     *  }
     *  
     *  // MyEntity
     *  entity MyEntity {
     *      field Timestamp fCreated = Timestamp!now();
     *      field Boolean   fBool;
     *      field Date      fDate;
     *      field Time      fTime;
     *      field Long      fLong;
     *      field String    fString;
     *      field Decimal   fDecimal;
     *      field MyEnum    fEnum;
     *  }
     *  
     *  // Parent entity that contains the instance queries
     *  entity ParentEntity {
     *      field Timestamp created = Timestamp!now();
     *  
     *      // relations
     *      relation MyEntity   firstEntity;
     *      relation MyEntity[] otherEntities;
     *  
     *      query MyEntity[] queryByTimestamp(Timestamp p1 = `2019-07-18T11:11:12.003+02:00`) =>
     *          self.otherEntities
     *          !filter(e | e.fCreated <= p1);
     *  
     *      query MyEntity[] queryByBoolean(Boolean p1 = false) =>
     *          self.otherEntities
     *          !filter(e | e.fBool == p1);
     *  
     *      query MyEntity[] queryByDate(Date p1 = `2019-07-18`) =>
     *          self.otherEntities
     *          !filter(e | e.fDate == p1);
     *      
     *      query MyEntity[] queryByTime(Time p1 = `11:11:12`) =>
     *          self.otherEntities
     *          !filter(e | e.fTime == p1);
     *      
     *      query MyEntity[] queryByLong(Long p1 = 9999) =>
     *          self.otherEntities
     *          !filter(e | e.fLong == p1);
     *      
     *      query MyEntity[] queryByString(String p1 = "Lorem ipsum") =>
     *          self.otherEntities
     *          !filter(e | e.fString == p1);
     *      
     *      query MyEntity[] queryByDecimal(Decimal p1 = -1526.225) =>
     *          self.otherEntities
     *          !filter(e | e.fDecimal == p1);
     *      
     *      query MyEntity[] queryByMyEnum(MyEnum p1 = MyEnum#A00) =>
     *          self.otherEntities
     *          !filter(e | e.fEnum == p1);
     *  }
     * 
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC024")
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-SYNT-005",
        "REQ-TYPE-001",
        "REQ-TYPE-002",
        "REQ-TYPE-004",
        "REQ-TYPE-005",
        "REQ-TYPE-006",
        "REQ-TYPE-007",
        "REQ-TYPE-008",
        "REQ-TYPE-009",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-009",
        "REQ-ENT-010",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-004",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testInstaceQueriesWithConstantDefaultValues() {
        //TODO
    }
}