package hu.blackbelt.judo.meta.jsl.runtime

import org.junit.jupiter.api.Test
import hu.blackbelt.judo.requirement.report.annotation.TestCase
import hu.blackbelt.judo.requirement.report.annotation.Requirement
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class InstanceQueryTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper
    
    
    /**
     * Testing the instance queries with constant default values.
     * 
     * @prerequisites Nothing
     * 
     * @type Static
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
         '''
			model modelTC024;
			// Decimal
			type numeric Decimal precision:13 scale:4;
			
			type boolean Boolean;
			type date Date;
			type time Time;
			type timestamp Timestamp;
			type numeric Integer precision:9 scale:0;
			type numeric Long precision:15 scale:0;
			type string String min-size:0 max-size:200;
			
			// my enum
			enum MyEnum {
			    A01 = 1;
			    A02 = 2;
			    A03 = 3;
			    A00 = 0;
			}
			
			// MyEntity
			entity MyEntity {
			    field Timestamp fldCreated = Timestamp!now();
			    field Boolean   fldBool;
			    field Date      fldDate;
			    field Time      fldTime;
			    field Long      fldLong;
			    field String    fldString;
			    field Decimal   fldDecimal;
			    field MyEnum    fldEnum;
			}
			
			// Parent entity that contains the instance queries
			entity ParentEntity {
			    field Timestamp created = Timestamp!now();
			
			    // relations
			    relation MyEntity   firstEntity;
			    relation MyEntity[] otherEntities;
			        
			    relation MyEntity derivedByTimestamp1 <= self!queryByTimestamp();
			    relation MyEntity derivedByTimestamp2 <= self!queryByTimestamp(p1 = `2023-07-18T11:11:12.003-02:00`);
			    
			    relation MyEntity derivedByBoolean1 <= self!queryByBoolean();
			    relation MyEntity derivedByBoolean2 <= self!queryByBoolean(p1 = true);
			    
			    relation MyEntity derivedByDate1 <= self!queryByDate();
			    relation MyEntity derivedByDate2 <= self!queryByDate(p1 = `2019-07-18`);
			    
			    relation MyEntity derivedByTime1 <= self!queryByTime();
			    relation MyEntity derivedByTime2 <= self!queryByTime(p1 = `11:11:12`);
			    
			    relation MyEntity derivedByLong1 <= self!queryByLong();
			    relation MyEntity derivedByLong2 <= self!queryByLong(p1 = 9999);
			    
			    relation MyEntity derivedByString1 <= self!queryByString();
			    relation MyEntity derivedByString2 <= self!queryByString(p1 = "Lorem ipsum");
			    
			    relation MyEntity derivedByDecimal1 <= self!queryByDecimal();
			    relation MyEntity derivedByDecimal2 <= self!queryByDecimal(p1 = -1526.225);
			    
			    relation MyEntity derivedByEnum1 <= self!queryByMyEnum();
			    relation MyEntity derivedByEnum2 <= self!queryByMyEnum(p1 = MyEnum#A00); 
			
			}
			
			query MyEntity queryByTimestamp(Timestamp p1 = `2019-07-18T11:11:12.003+02:00`) on ParentEntity <=
			    self.otherEntities
			    !filter(e | e.fldCreated <= p1)
			    !any();
			
			query MyEntity queryByBoolean(Boolean p1 = false) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldBool == p1)
			    !any();
			
			query MyEntity queryByDate(Date p1 = `2019-07-18`) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldDate == p1)
			    !any();
			
			query MyEntity queryByTime(Time p1 = `11:11:12`) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldTime == p1)
			    !any();
			
			query MyEntity queryByLong(Long p1 = 9999) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldLong == p1)
			    !any();
			
			query MyEntity queryByString(String p1 = "Lorem ipsum") on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldString == p1)
			    !any();
			
			query MyEntity queryByDecimal(Decimal p1 = -1526.225) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldDecimal == p1)
			    !any();
			
			query MyEntity queryByMyEnum(MyEnum p1 = MyEnum#A00) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldEnum == p1)
			    !any();
        '''.parse => [
            assertNoErrors
        ]
    }
    
     /**
     * Testing the instance queries have more parameters with constant default values
     * 
     * @prerequisites Nothing
     * 
     * @type Static
     * 
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC025")
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
    def void testInstaceQueriesWithMoreParameterWithConstantDefaultValues() {
         '''
			model modelTC025;
			           
			// Decimal
			type numeric Decimal precision:13 scale:4;
			
			type boolean Boolean;
			type date Date;
			type time Time;
			type timestamp Timestamp;
			type numeric Integer precision:9 scale:0;
			type numeric Long precision:15 scale:0;
			type string String min-size:0 max-size:200;
			
			// my enum
			enum MyEnum {
			    A01 = 1;
			    A02 = 2;
			    A03 = 3;
			    A00 = 0;
			}
			
			// MyEntity
			entity MyEntity {
			    field Timestamp fldCreated = Timestamp!now();
			    field Boolean   fldBool;
			    field Date      fldDate;
			    field Time      fldTime;
			    field Long      fldLong;
			    field String    fldString;
			    field Decimal   fldDecimal;
			    field MyEnum    fldEnum;
			}
			
			// Parent entity that contains the instance queries
			entity ParentEntity {
			    field Timestamp created = Timestamp!now();
			
			    // relations
			    relation MyEntity   firstEntity;
			    relation MyEntity[] otherEntities;         
			    
			    relation MyEntity derived001 <= self!queryWithMoreParam001();
			    relation MyEntity derived002 <= self!queryWithMoreParam002();
			    relation MyEntity derived003 <= self!queryWithMoreParam003();
			    relation MyEntity derived004 <= self!queryWithMoreParam001(p2 = false);
			    relation MyEntity derived005 <= self!queryWithMoreParam002(p3 = "AAA", p1 = `2023-01-01`);
			    relation MyEntity derived006 <= self!queryWithMoreParam003(p1 = -10, p3 = true, p2 = MyEnum#A02);
			    
			    // relations
			    //relation MyEntity[] defEntities => self.setOfMyEntities();
			    //relation MyEntity[] otherEntities => self.setOfMyEntities(p1 = MyEnum#A01);
			
			}
			
			query MyEntity queryWithMoreParam001(
			    Timestamp p1 = `2019-07-18T11:11:12.003+02:00`,
			    Boolean p2 = true,
			    Long p3 = 13
			) on ParentEntity <= self.otherEntities
			     !filter(e | p1 <= e.fldCreated and p2 == e.fldBool and p3 <= e.fldLong)
			     !any();
			     
			query MyEntity queryWithMoreParam002(
			    Date p1 = `2019-07-18`,
			    Time p2 = `11:11:12`,
			    String p3 = "Lorem ipsum"
			) on ParentEntity  <= self.otherEntities
			     !filter(e | p1 == e.fldDate and p2 <= e.fldTime and p3 != e.fldString)
			     !any();
			
			query MyEntity queryWithMoreParam003(
			    Decimal p1 = 999999999.9999,
			    MyEnum p2 = MyEnum#A00,
			    Boolean p3 = false
			) on ParentEntity  <= self.otherEntities
			     !filter(e | p1 <= e.fldDecimal and e.fldEnum >= p2 or p3 == e.fldBool)
			     !any();
			
			query MyEntity[] setOfMyEntities(
			    MyEnum p1 = MyEnum#A03
			) on ParentEntity  <= self.otherEntities
			     !filter(e | p1 == e.fldEnum and e.fldCreated <= Timestamp!now());
         '''.parse => [
            assertNoErrors
        ]
    }
    
     /**
     * Testing instance queries that return with primitive types
     * 
     * @prerequisites Nothing
     * 
     * @type Static
     * 
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC026")
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
    def void testInstaceQueriesWithPrimitiveReturnType() {
         '''
			model modelTC026;
			// Decimal
			type numeric Decimal precision:13 scale:4;
			
			type boolean Boolean;
			type date Date;
			type time Time;
			type timestamp Timestamp;
			type numeric Integer precision:9 scale:0;
			type numeric Long precision:15 scale:0;
			type string String min-size:0 max-size:200;
			
			// my enum
			enum MyEnum {
			    A01 = 1;
			    A02 = 2;
			    A03 = 3;
			    A00 = 0;
			}
			
			// MyEntity
			entity MyEntity {
			    field Timestamp fldCreated = Timestamp!now();
			    field Boolean   fldBool;
			    field Date      fldDate;
			    field Time      fldTime;
			    field Long      fldLong;
			    field String    fldString;
			    field Decimal   fldDecimal;
			    field MyEnum    fldEnum;
			}
			
			// Parent entity that contains the instance queries
			entity ParentEntity {
			    field Timestamp created = Timestamp!now();
			
			    // relations
			    relation MyEntity   firstEntity;
			    relation MyEntity[] otherEntities;
			    
			    
			    field Timestamp derivedByTimestamp1 <= self!queryByTimestamp();
			    field Timestamp derivedByTimestamp2 <= self!queryByTimestamp(p1 = `2023-07-18T11:11:12.003-02:00`);
			    
			    field Boolean derivedByBoolean1 <= self!queryByBoolean();
			    field Boolean derivedByBoolean2 <= self!queryByBoolean(p1 = true);
			    
			    field Date derivedByDate1 <= self!queryByDate();
			    field Date derivedByDate2 <= self!queryByDate(p1 = `2019-07-18`);
			    
			    field Time derivedByTime1 <= self!queryByTime();
			    field Time derivedByTime3 <= self!queryByTime(p3 = MyEnum#A00 ,p1 = `11:11:12`);
			    
			    field Long derivedByLong1 <= self!queryByLong();
			    field Long derivedByLong2 <= self!queryByLong(p1 = 9999);
			    
			    field String derivedByString1 <= self!queryByString();
			    field String derivedByString4 <= self!queryByString(p1 = "Lorem ipsum", p2 = 345.678, p3 = 456, p4 = MyEnum#A03);
			    
			    field Decimal derivedByDecimal1 <= self!queryByDecimal();
			    field Decimal derivedByDecimal2 <= self!queryByDecimal(p1 = -1526.225);
			    
			    field MyEnum derivedByEnum1 <= self!queryByMyEnum();
			    field MyEnum derivedByEnum2 <= self!queryByMyEnum(p1 = MyEnum#A00);
			}
			
			query Timestamp queryByTimestamp(
			    Timestamp p1 = `2019-07-18T11:11:12.003+02:00`,
			    Boolean p2 = true
			)  on ParentEntity <= self.otherEntities
			    !filter(e | e.fldCreated <= p1 and e.fldBool == p2)
			    !any()
			    .fldCreated;
			
			query Boolean queryByBoolean(Boolean p1 = false)  on ParentEntity <=
			    self.otherEntities
			    !filter(e | e.fldBool == p1)
			    !any()
			    .fldBool;
			
			query Date queryByDate(Date p1 = `2019-07-18`) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldDate == p1)
			    !any()
			    .fldDate;
			
			query Time queryByTime(
			    Time p1 = `11:11:12`,
			    Date p2 = `2019-07-18`,
			    MyEnum p3 = MyEnum#A03
			) on ParentEntity  <= self.otherEntities
			    !filter(
			        e | e.fldTime == p1 and
			        e.fldDate == p2 and
			        e.fldEnum == p3
			    )
			    !any()
			    .fldTime;
			
			query Long queryByLong(Long p1 = 9999) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldLong == p1)
			    !any()
			    .fldLong;
			
			query String queryByString(
			    String p1 = "Lorem ipsum",
			    Decimal p2 = 123.345,
			    Long p3 = 998,
			    MyEnum p4 = MyEnum#A01
			)  on ParentEntity <= self.otherEntities
			    !filter(
			        e | e.fldString == p1 and
			        e.fldDecimal == p2 and
			        e.fldLong == p3 and
			        e.fldEnum == p4
			    )
			    !any()
			    .fldString;
			
			query Decimal queryByDecimal(Decimal p1 = -1526.225) on ParentEntity  <=
			    self.otherEntities
			    !filter(e | e.fldDecimal == p1)
			    !any()
			    .fldDecimal;
			
			query MyEnum queryByMyEnum(
			    MyEnum p1 = MyEnum#A00,
			    Timestamp p2 = `2019-07-18T11:11:12.003+02:00`
			) on ParentEntity <= self.otherEntities
			    !filter(e | e.fldEnum == p1 and e.fldCreated <= p2)
			    !any()
			    .fldEnum;
        '''.parse => [
            assertNoErrors
        ]
    }
}
