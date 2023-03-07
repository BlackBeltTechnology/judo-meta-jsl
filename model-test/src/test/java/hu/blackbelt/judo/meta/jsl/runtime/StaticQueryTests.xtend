package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Disabled
import hu.blackbelt.judo.requirement.report.annotation.Requirement
import hu.blackbelt.judo.requirement.report.annotation.TestCase

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class StaticQueryTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension ValidationTestHelper

    /**
     * Testing the static queries with constant default values.
     * 
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC018")
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
        "REQ-ENT-011",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-004",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        //TODO: JNG-4392 => "REQ-EXPR-012",
        "REQ-EXPR-022"
    ])
    def void testStaticQueriesWithConstantDefaultValues() {
        '''model modelTC018;
           
           // Decimal
           type numeric Decimal(precision = 13, scale = 4);
           
           type boolean Boolean;
           type date Date;
           type time Time;
           type timestamp Timestamp;
           type numeric Integer(precision = 9, scale = 0);
           type numeric Long(precision = 15, scale = 0);
           type string String(min-size = 0, max-size = 4000);
           
           // my enum
           enum MyEnum {
               A01 = 1;
               A02 = 2;
               A03 = 3;
               A00 = 0;
           }
           
           // MyEntity
           entity MyEntity {
               field Timestamp fCreated = Timestamp!now();
               field Boolean   fBool;
               field Date      fDate;
               field Time      fTime;
               field Long      fLong;
               field String    fString;
               field Decimal   fDecimal;
               field MyEnum    fEnum;
           }
           
           // Entity for the results of queries
           entity Snapshot {
               field Timestamp created = Timestamp!now();
           
               // relations
               relation MyEntity[] defEntities; // = setOfMyEntities();
           }
           
           query MyEntity[] queryByTimestamp(Timestamp p1 = `2019-07-18T11:11:12.003+02:00`) =>
               MyEntity!all()
               !filter(e | e.fCreated <= p1);
           
           query MyEntity[] queryByBoolean(Boolean p1 = false) =>
               MyEntity!all()
               !filter(e | e.fBool == p1);
           
           query MyEntity[] queryByDate(Date p1 = `2019-07-18`) =>
               MyEntity!all()
               !filter(e | e.fDate == p1);
           
           query MyEntity[] queryByTime(Time p1 = `11:11:12`) =>
               MyEntity!all()
               !filter(e | e.fTime == p1);
           
           query MyEntity[] queryByLong(Long p1 = 9999) =>
               MyEntity!all()
               !filter(e | e.fLong == p1);
           
           query MyEntity[] queryByString(String p1 = "Lorem ipsum") =>
               MyEntity!all()
               !filter(e | e.fString == p1);
           
           query MyEntity[] queryByDecimal(Decimal p1 = -1526.225) =>
               MyEntity!all()
               !filter(e | e.fDecimal == p1);
           
           query MyEntity[] queryByMyEnum(MyEnum p1 = MyEnum#A00) =>
               MyEntity!all()
               !filter(e | e.fEnum == p1);
        '''.parse => [
            assertNoErrors
        ]
    }
    
    /**
     * Testing the static queries with default values that are expressions.
     * 
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC019")
    @Disabled("JNG-4566")
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
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-009",
        "REQ-ENT-011",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-004",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        "REQ-EXPR-013",
        "REQ-EXPR-014",
        "REQ-EXPR-022"
    ])
    def void testStaticQueriesWithExpressionDefaultValues() {
        '''model modelTC019;
           
           import judo::types;
           
           // Decimal
           type numeric Decimal(precision = 13, scale = 4);
           
           // my enum
           enum MyEnum {
               A01 = 1;
               A02 = 2;
               A03 = 3;
               A00 = 0;
           }
           
           // MyEntity
           entity MyEntity {
               field Timestamp fCreated = Timestamp!now();
               field Boolean   fBool;
               field Date      fDate;
               field Time      fTime;
               field Long      fLong;
               field String    fString;
               field Decimal   fDecimal;
               field MyEnum    fEnum;
           }
           
           // Entity for the results of queries
           entity Snapshot {
               field Timestamp created = Timestamp!now();
           
               // relations
               relation MyEntity[] defEntities; // = setOfMyEntities();
           }
           
           query MyEntity[] queryByTimestamp(
               Timestamp p1 = Timestamp!now()
           ) => MyEntity!all()
                !filter(e | e.fCreated <= p1);
           
           query MyEntity[] queryByBoolean(
               Boolean p1 = (1 >= 2)
           ) => MyEntity!all()
                !filter(e | e.fBool == p1);
           
           query MyEntity[] queryByDate(
               Date p1 = Date!now()
           ) => MyEntity!all()
                !filter(e | e.fDate == p1);
           
           query MyEntity[] queryByTime(
               Time p1 = Time!now()
           ) => MyEntity!all()
                !filter(e | e.fTime == p1);
           
           query MyEntity[] queryByLong(
               Long p1 = (1 + 2)
           ) => MyEntity!all()
                !filter(e | e.fLong == p1);
           
           query MyEntity[] queryByString(
               String p1 = "Lorem ipsum"!left(count = 2)
           ) => MyEntity!all()
                !filter(e | e.fString == p1);
           
           query MyEntity[] queryByDecimal(
               Decimal p1 = (-1526.225)!round(scale = 2)
           ) => MyEntity!all()
                !filter(e | e.fDecimal == p1);
           
           query MyEntity[] queryByMyEnum(
               MyEnum p1 = (1 <= 2 ? MyEnum#A00 : MyEnum#A03)
           ) => MyEntity!all()
                !filter(e | e.fEnum == p1);
        '''.parse => [
            assertNoErrors
        ]
    }
    
    /**
     * Testing the static queries without parameters.
     * 
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC014")
    //@Disabled("JNG-4566")
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
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-009",
        "REQ-ENT-011",
        "REQ-EXPR-002",
        "REQ-EXPR-004",
        "REQ-EXPR-005",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testStaticQueriesWithoutParameters() {
        '''model modelTC014;
        
	        import judo::types;
	        
	        // my decimal
	        type numeric Decimal(precision = 13, scale = 4);
	        
	        // my enum
	        enum MyEnum {
	            A01 = 1;
	            A02 = 2;
	            A03 = 3;
	            A00 = 0;
	        }
	        
	        // MyEntity
	        entity MyEntity {
	            field Boolean   fBool;
	            field Date      fDate;
	            field Time      fTime;
	            field Timestamp fTimestamp;
	            field Long      fLong;
	            field String    fString;
	            field Decimal   fDecimal;
	            field MyEnum    fEnum;
	        }
	        
	        // Entity for the results of queries
	        entity Snapshot1 {
	            field Boolean   fBool      = anyMyEntityFBool();
	            field Date      fDate      = anyMyEntityFDate();
	            field Time      fTime      = anyMyEntityFTime();
	            field Timestamp fTimestamp = anyMyEntityFTimestamp();
	            field Long      fLong      = anyMyEntityFLong();
	            field String    fString    = anyMyEntityFString();
	            field Decimal   fDecimal   = anyMyEntityFDecimal();
	            field MyEnum    fEnum      = anyMyEntityFEnum();
	        }
	        
	        // static queries
	        query Boolean   anyMyEntityFBool()      => MyEntity!all()!any().fBool;
	        query Date      anyMyEntityFDate()      => MyEntity!all()!any().fDate;
	        query Time      anyMyEntityFTime()      => MyEntity!all()!any().fTime;
	        query Timestamp anyMyEntityFTimestamp() => MyEntity!all()!any().fTimestamp;
	        query Long      anyMyEntityFLong()      => MyEntity!all()!any().fLong;
	        query String    anyMyEntityFString()    => MyEntity!all()!any().fString;
	        query Decimal   anyMyEntityFDecimal()   => MyEntity!all()!any().fDecimal;
	        query MyEnum    anyMyEntityFEnum()      => MyEntity!all()!any().fEnum;
	        query MyEntity[] listOfMyEntities()     => MyEntity!all();
        '''.parse => [
            assertNoErrors
        ]
    }
    
    /**
     * Testing the static queries with default values.
     * 
     * @prerequisites Nothing
     * @type Static
     * @scenario
     *  . Parse (and/or build) the model.
     *
     *  . The result of the model parsing (and/or building) is successful.
     */
    @Test
    @TestCase("TC016")
    @Disabled("JNG-4566")
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
        "REQ-MDL-003",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-009",
        "REQ-ENT-011",
        "REQ-EXPR-002",
        "REQ-EXPR-004",
        "REQ-EXPR-005",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testStaticQueriesWithDefaultValues() {
        '''model modelTC016;
	        
	        import judo::types;
	        
	        // my decimal
	        type numeric Decimal(precision = 13, scale = 4);
	        
	        // my enum
	        enum MyEnum {
	            A01 = 1;
	            A02 = 2;
	            A03 = 3;
	            A00 = 0;
	        }
	        
	        // MyEntity
	        entity MyEntity {
	            field Timestamp fCreated = Timestamp!now();
	            field Boolean   fBool;
	            field Date      fDate;
	            field Time      fTime;
	            field Timestamp fTimestamp;
	            field Long      fLong;
	            field String    fString;
	            field Decimal   fDecimal;
	            field MyEnum    fEnum;
	        }
	        
	        // Entity for the results of queries
	        entity Snapshot1 {
	            field Timestamp created = Timestamp!now();
	            
	            // fields
	            field MyEntity fMyEntity001 = anyMyEntity001();
	            field MyEntity fMyEntity002 = anyMyEntity002();
	            field MyEntity fMyEntity003 = anyMyEntity003();
	            field MyEntity fMyEntity004 = anyMyEntity001(p2 = false);
	            field MyEntity fMyEntity005 = anyMyEntity002(p3 = "AAA", p1 = `2023-01-01`);
	            field MyEntity fMyEntity006 = anyMyEntity003(p1 = -10, p3 = true, p2 = MyEnum#A02);
	        
	            // relations
	            relation MyEntity[] defEntities => setOfMyEntities();
	            relation MyEntity[] otherEntities => setOfMyEntities(p1 = MyEnum#A01)
	        }
	        
	        // static queries
	        query MyEntity anyMyEntity001(
	            Timestamp p1 = Timestamp!now()!plus(days = -7),
	            Boolean p2 = true,
	            Long p3 = 13
	        ) => MyEntity!all()
	             !filter(e | p1 <= e.fCreated and p2 == e.fBool and p3 <= e.fLong)
	             !any();
	        
	        query MyEntity anyMyEntity002(
	            Date p1 = Timestamp!now()!date(),
	            Time p2 = Timestamp!now()!time(),
	            String p3 = "Lorem ipsum"
	        ) => MyEntity!all()
	             !filter(e | p1 == e.fDate and p2 <= e.Time and p3 != e.fString)
	             !any();
	        
	        query MyEntity anyMyEntity003(
	            Decimal p1 = 999999999.9999,
	            MyEnum p2 = MyEnum#A00,
	            Boolean p3 = false
	        ) => MyEntity!all()
	             !filter(e | p1 <= e.fDecimal and e.fEnum >= p2 or p3 == e.fBool)
	             !any();
	        
	        query MyEntity[] setOfMyEntities(
	            MyEnum p1 = MyEnum#A03
	        ) => MyEntity!all()
	             !filter(e | p1 == e.fEnum and e.fCreated <= Timestamp!now())
        '''.parse => [
            assertNoErrors
        ]
    }
     
}