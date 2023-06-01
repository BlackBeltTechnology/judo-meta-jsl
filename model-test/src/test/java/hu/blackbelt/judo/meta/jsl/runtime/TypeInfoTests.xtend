package hu.blackbelt.judo.meta.jsl.runtime

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.google.inject.Inject
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.junit.jupiter.api.Test
import hu.blackbelt.judo.meta.jsl.util.JslDslModelExtension
import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.Assert.assertTrue
import hu.blackbelt.judo.requirement.report.annotation.Requirement
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredFieldDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityCalculatedMemberDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredRelationDeclaration

@ExtendWith(InjectionExtension)
@InjectWith(JslDslInjectorProvider)
class TypeInfoTests {
    @Inject extension ParseHelper<ModelDeclaration>
    @Inject extension JslDslModelExtension
    @Inject extension ValidationTestHelper

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-002"
    ])
    def void testPrimitiveField() {
        val p = '''
            model PrimitiveDefaultsModel;

            type boolean Bool;

            entity Test {
                field Bool boolAttr;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val boolAttr = testEntity.memberByName("boolAttr")

        val boolAttrTypeInfo = TypeInfo.getTargetType(boolAttr)

        assertEquals(false, boolAttrTypeInfo.isCollection);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-003"
    ])
    def void testIdentifier() {
        val p = '''
            model TestModel;

            type boolean Bool;

            entity Test {
                identifier Bool boolAttr;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val boolAttr = testEntity.memberByName("boolAttr")

        val boolAttrTypeInfo = TypeInfo.getTargetType(boolAttr)

        assertEquals(false, boolAttrTypeInfo.isCollection);
        assertTrue(boolAttrTypeInfo.isBoolean());
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-007"
    ])
    def void testSingleField() {
        val p = '''
            model TestModel;

            type boolean Bool;

            entity T1 {
            }


            entity Test {
                field T1 t1;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1Field = testEntity.memberByName("t1")

        val t1FieldTypeInfo = TypeInfo.getTargetType(t1Field)

        assertEquals(false, t1FieldTypeInfo.isCollection);
        assertEquals((t1Field as EntityStoredFieldDeclaration).referenceType, t1FieldTypeInfo.getEntity);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-007"
    ])
    def void testCollectionField() {
        val p = '''
            model TestModel;

            entity T1 {
            }

            entity Test {
                field T1[] t1s;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1sField = testEntity.memberByName("t1s")

        val t1sFieldTypeInfo = TypeInfo.getTargetType(t1sField)

        assertEquals(true, t1sFieldTypeInfo.isCollection);
        assertEquals((t1sField as EntityStoredFieldDeclaration).referenceType, t1sFieldTypeInfo.getEntity);
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-007",
        "REQ-ENT-008",
        "REQ-EXPR-003"
    ])
    def void testSelfDerivedToSingleField() {
        val p = '''
            model TestModel;

            entity T1 {
            }


            entity Test {
                field T1 t1;
                field T1 t1d <= self.t1;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1Field = testEntity.memberByName("t1")
        val t1dField = testEntity.memberByName("t1d")

        val t1dFieldTypeInfo = TypeInfo.getTargetType(t1dField)
        val t1dFieldExpressionTypeInfo = TypeInfo.getTargetType((t1dField as EntityCalculatedMemberDeclaration).getterExpr);

        assertEquals(false, t1dFieldTypeInfo.isCollection);
        assertEquals((t1Field as EntityStoredFieldDeclaration).referenceType, t1dFieldTypeInfo.getEntity);
        assertEquals((t1Field as EntityStoredFieldDeclaration).referenceType, t1dFieldExpressionTypeInfo.getEntity);
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-007",
        "REQ-ENT-008",
        "REQ-EXPR-003"
    ])
    def void testSelfDerivedToCollectionField() {
        val p = '''
            model TestModel;

            entity T1 {
            }


            entity Test {
                field T1[] t1s;
                field T1[] t1sd <= self.t1s;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1sField = testEntity.memberByName("t1s")
        val t1sdField = testEntity.memberByName("t1sd")

        val t1sdFieldTypeInfo = TypeInfo.getTargetType(t1sdField)
        val t1sdFieldExpressionTypeInfo = TypeInfo.getTargetType((t1sdField as EntityCalculatedMemberDeclaration).getterExpr);

        assertEquals(true, t1sdFieldTypeInfo.isCollection);
        assertEquals((t1sField as EntityStoredFieldDeclaration).referenceType, t1sdFieldTypeInfo.getEntity);
        assertEquals((t1sField as EntityStoredFieldDeclaration).referenceType, t1sdFieldExpressionTypeInfo.getEntity);
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-002",
        "REQ-EXPR-003",
        "REQ-EXPR-007",
        "REQ-EXPR-022"
    ])
    def void testStaticDerivedToSingleField() {
        val p = '''
            model TestModel;

            entity T1 {
            }


            entity Test {
                field T1 t1sd <= T1!all()!any();
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1sdField = testEntity.memberByName("t1sd")

        val t1sdFieldTypeInfo = TypeInfo.getTargetType(t1sdField)
        val t1sdFieldExpressionTypeInfo = TypeInfo.getTargetType((t1sdField as EntityCalculatedMemberDeclaration).getterExpr);

        assertEquals(false, t1sdFieldTypeInfo.isCollection);
        assertEquals((t1sdField as EntityCalculatedMemberDeclaration).referenceType, t1sdFieldTypeInfo.getEntity);
        assertEquals((t1sdField as EntityCalculatedMemberDeclaration).referenceType, t1sdFieldExpressionTypeInfo.getEntity);
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005"
    ])
    def void testSingleRelation() {
        val p = '''
            model TestModel;

            type boolean Bool;

            entity T1 {
            }


            entity Test {
                relation T1 t1;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1Field = testEntity.memberByName("t1")

        val t1FieldTypeInfo = TypeInfo.getTargetType(t1Field)

        assertEquals(false, t1FieldTypeInfo.isCollection);
        assertEquals((t1Field as EntityStoredRelationDeclaration).referenceType, t1FieldTypeInfo.getEntity);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005"
    ])
    def void testCollectionRelation() {
        val p = '''
            model TestModel;

            entity T1 {
            }

            entity Test {
                relation T1[] t1s;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1sField = testEntity.memberByName("t1s")

        val t1sFieldTypeInfo = TypeInfo.getTargetType(t1sField)

        assertEquals(true, t1sFieldTypeInfo.isCollection);
        assertEquals((t1sField as EntityStoredRelationDeclaration).referenceType, t1sFieldTypeInfo.getEntity);
    }



    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-003"
    ])
    def void testDerivedMultipleRelation() {
        val p = '''
            model TestModel;

            entity T1 {
                relation Test test;
            }

            entity T2 {
            }

            entity Test {
                relation T1[] t1s;
                relation T2[] t2s;

                field T2[] t2sd <= self.t1s.test.t2s;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t2sField = testEntity.memberByName("t2s")
        val t2sdField = testEntity.memberByName("t2sd")

        val t2sFieldTypeInfo = TypeInfo.getTargetType(t2sField)

        assertEquals(true, t2sFieldTypeInfo.isCollection);
        assertEquals((t2sField as EntityStoredRelationDeclaration).referenceType, t2sFieldTypeInfo.getEntity);

        val t2sdFieldExpressionTypeInfo = TypeInfo.getTargetType((t2sdField as EntityCalculatedMemberDeclaration).getterExpr);
        assertEquals((t2sdField as EntityCalculatedMemberDeclaration).referenceType, t2sdFieldExpressionTypeInfo.getEntity);

    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-TYPE-005",
        "REQ-TYPE-006",
        "REQ-TYPE-007",
        "REQ-TYPE-008",
        "REQ-TYPE-009"
    ])
    def void testLiterals() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity Test {
                field Integer numeric <= 12;
                field Date date <= `2022-01-01`;
                field Timestamp timestamp <= `2022-01-01T12:00:00Z`;
                field Time time <= `12:00:00`;
                field String string <= "Test";
                field Boolean boolean <= true;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val numericField = testEntity.memberByName("numeric") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val stringField = testEntity.memberByName("string") as EntityCalculatedMemberDeclaration
        val booleanField = testEntity.memberByName("boolean") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(numericField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(stringField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.getterExpr).getPrimitive);
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-008",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-TYPE-005",
        "REQ-TYPE-006",
        "REQ-EXPR-001",
        "REQ-EXPR-006",
        "REQ-EXPR-013"
    ])
    def void testStringFunctionsLiteralBase() {
        val p = '''
            model TestModel;

            type string String min-size:0 max-size:32;
            type boolean Boolean;
            type numeric Integer precision:9 scale:0;


            entity Test {
                field String left <= "Test"!left(count = 1);
                field String right <= "Test"!right(count = 1);
                field Integer position <= "Test"!position(substring = "es");
                field String substring <= "Test"!substring(count = 1, offset = 2);
                field String lower <= "Test"!lower();
                field String upper <= "Test"!upper();
                field String lowerCase <= "Test"!lower();
                field String upperCase <= "Test"!upper();
                field String capitalize <= "Test"!capitalize();
                field Boolean matches <= "Test"!matches(pattern = r".*es.*");
                field Boolean like <= "Test"!like(pattern = "%es%");
                field Boolean ilike <= "Test"!ilike(pattern = "%es%");
                field String replace <= "Test"!replace(oldstring = "es", newstring = "ee");
                field String trim <= "Test"!trim();
                field String ltrim <= "Test"!ltrim();
                field String rtrim <= "Test"!rtrim();
                field String lpad <= "Test"!lpad(size = 10, padstring = "--");
                field String rpad <= "Test"!rpad(size = 10, padstring = "--");
                field Integer size <= "Test"!size();
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")

        val firstField = testEntity.memberByName("left") as EntityCalculatedMemberDeclaration
        val lastField = testEntity.memberByName("right") as EntityCalculatedMemberDeclaration
        val positionField = testEntity.memberByName("position") as EntityCalculatedMemberDeclaration
        val substringField = testEntity.memberByName("substring") as EntityCalculatedMemberDeclaration
        val lowerField = testEntity.memberByName("lower") as EntityCalculatedMemberDeclaration
        val upperField = testEntity.memberByName("upper") as EntityCalculatedMemberDeclaration
        val lowerCaseField = testEntity.memberByName("lowerCase") as EntityCalculatedMemberDeclaration
        val upperCaseField = testEntity.memberByName("upperCase") as EntityCalculatedMemberDeclaration


        val capitalizeField = testEntity.memberByName("capitalize") as EntityCalculatedMemberDeclaration
        val matchesField = testEntity.memberByName("matches") as EntityCalculatedMemberDeclaration
        val likeField = testEntity.memberByName("like") as EntityCalculatedMemberDeclaration
        val ilikeField = testEntity.memberByName("ilike") as EntityCalculatedMemberDeclaration
        val replaceField = testEntity.memberByName("replace") as EntityCalculatedMemberDeclaration
        val trimField = testEntity.memberByName("trim") as EntityCalculatedMemberDeclaration
        val ltrimField = testEntity.memberByName("ltrim") as EntityCalculatedMemberDeclaration
        val rtrimField = testEntity.memberByName("rtrim") as EntityCalculatedMemberDeclaration
        val lpadField = testEntity.memberByName("lpad") as EntityCalculatedMemberDeclaration
        val rpadField = testEntity.memberByName("rpad") as EntityCalculatedMemberDeclaration
        val sizeField = testEntity.memberByName("size") as EntityCalculatedMemberDeclaration


        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(firstField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lastField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(positionField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(substringField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lowerField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(upperField.getterExpr).getPrimitive);

        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lowerCaseField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(upperCaseField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(capitalizeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(matchesField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(likeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(ilikeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(upperField.getterExpr).getPrimitive);

        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(replaceField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(trimField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(ltrimField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(rtrimField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(lpadField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(rpadField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sizeField.getterExpr).getPrimitive);

    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-009",
        "REQ-EXPR-012"
    ])
    def void testGetVariableFunction() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity Test {
                field Integer numeric <= Integer!getVariable(category = "ENV", key = "NUMERIC");
                field Date date <= Date!getVariable(category = "ENV", key = "DATE");
                field Timestamp timestamp <= Timestamp!getVariable(category = "ENV", key = "TIMESTAMP");
                field Time time <= Time!getVariable(category = "ENV", key = "TIME");
                field String string <= String!getVariable(category = "ENV", key = "STRING");
                field Boolean boolean <= Boolean!getVariable(category = "ENV", key = "BOOLEAN");
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val numericField = testEntity.memberByName("numeric") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val stringField = testEntity.memberByName("string") as EntityCalculatedMemberDeclaration
        val booleanField = testEntity.memberByName("boolean") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(numericField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(stringField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-016",
        "REQ-EXPR-018",
        "REQ-EXPR-017"
    ])
    def void testNowFunction() {
        val p = '''
            model TestModel;

            type date Date;
            type timestamp Timestamp;
            type time Time;

            entity Test {
                field Date date <= Date!now();
                field Timestamp timestamp <= Timestamp!now();
                field Time time <= Time!now();
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-009",
        "REQ-EXPR-012"
    ])
    def void testDefinedFunction() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity Test {
                field Boolean numeric <= Integer!getVariable(category = "ENV", key = "NUMERIC")!isDefined();
                field Boolean date <= Date!getVariable(category = "ENV", key = "DATE")!isDefined();
                field Boolean timestamp <= Timestamp!getVariable(category = "ENV", key = "TIMESTAMP")!isDefined();
                field Boolean time <= Time!getVariable(category = "ENV", key = "TIME")!isDefined();
                field Boolean string <= String!getVariable(category = "ENV", key = "STRING")!isDefined();
                field Boolean boolean <= Boolean!getVariable(category = "ENV", key = "BOOLEAN")!isDefined();
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val numericField = testEntity.memberByName("numeric") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val stringField = testEntity.memberByName("string") as EntityCalculatedMemberDeclaration
        val booleanField = testEntity.memberByName("boolean") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(numericField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(stringField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-012"
    ])
    def void testUndefinedFunction() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity Test {
                field Boolean numeric <= 12!isUndefined();
                field Boolean date <= `2022-01-01`!isUndefined();
                field Boolean timestamp <= `2022-01-01T12:00:00Z`!isUndefined();
                field Boolean time <= `12:00:00`!isUndefined();
                field Boolean string <= "Test"!isUndefined();
                field Boolean boolean <= true!isUndefined();
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val numericField = testEntity.memberByName("numeric") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val stringField = testEntity.memberByName("string") as EntityCalculatedMemberDeclaration
        val booleanField = testEntity.memberByName("boolean") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(numericField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(stringField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-005",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-003",
        "REQ-EXPR-006",
        "REQ-EXPR-022"
    ])
    def void testCollectionSizeFunction() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity T1 {
            }

            entity Test {
                relation T1[] t1s;
                field Integer size <= self.t1s!size();

            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val sizeField = testEntity.memberByName("size") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sizeField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-012"
    ])
    def void testOrElseFunction() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity Test {
                field Integer numeric <= 12!orElse(value = 11);
                field Date date <= `2022-01-01`!orElse(value = `2022-01-01`);
                field Timestamp timestamp <= `2022-01-01T12:00:00Z`!orElse(value = `2023-01-01T12:00:00Z`);
                field Time time <= `12:00:00`!orElse(value = `13:00:00`);
                field String string <= "Test"!orElse(value = "Test2");
                field Boolean boolean <= true!orElse(value = false);
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val numericField = testEntity.memberByName("numeric") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val stringField = testEntity.memberByName("string") as EntityCalculatedMemberDeclaration
        val booleanField = testEntity.memberByName("boolean") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(numericField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(stringField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(booleanField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-014"
    ])
    def void testNumericFunction() {
        val p = '''
            model TestModel;

            type numeric Decimal precision:9 scale:2;

            entity Test {
                field Decimal floor <= 12!floor();
                field Decimal ceil <= 12!ceil();
                field Decimal abs <= 12!abs();
                field Decimal round <= 12!round(scale = 2);
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val floorField = testEntity.memberByName("floor") as EntityCalculatedMemberDeclaration
        val ceilField = testEntity.memberByName("ceil") as EntityCalculatedMemberDeclaration
        val absField = testEntity.memberByName("abs") as EntityCalculatedMemberDeclaration
        val roundField = testEntity.memberByName("round") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(floorField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(ceilField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(absField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(roundField.getterExpr).getPrimitive);
    }


    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-009",
        "REQ-TYPE-008",
        "REQ-TYPE-004",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-014",
        "REQ-EXPR-016",
        "REQ-EXPR-018",
        "REQ-EXPR-017",
        "REQ-EXPR-015"
    ])
    def void testAsStringFunction() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type date Date;
            type timestamp Timestamp;
            type time Time;
            type string String min-size:0 max-size:32;
            type boolean Boolean;

            entity Test {
                field String numeric <= 12!asString();
                field String date <= `2022-01-01`!asString();
                field String timestamp <= `2022-01-01T12:00:00Z`!asString();
                field String time <= `12:00:00`!asString();
                field String boolean <= true!asString();
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val numericField = testEntity.memberByName("numeric") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val booleanField = testEntity.memberByName("boolean") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(numericField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.STRING, TypeInfo.getTargetType(booleanField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-016"
    ])
    def void testDateFunctions() {
        val p = '''
            model TestModel;

            type date Date;
            type numeric Integer precision:9 scale:0;

            entity Test {
                field Integer year <= `2022-01-01`!year();
                field Integer month <= `2022-01-01`!month();
                field Integer day <= `2022-01-01`!day();
                field Integer dayOfWeek <= `2022-01-01`!dayOfWeek();
                field Integer dayOfYear <= `2022-01-01`!dayOfYear();
                field Date date <= Date!of(year = 2022, month = 1, day = 1);
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val yearField = testEntity.memberByName("year") as EntityCalculatedMemberDeclaration
        val monthField = testEntity.memberByName("month") as EntityCalculatedMemberDeclaration
        val dayField = testEntity.memberByName("day") as EntityCalculatedMemberDeclaration
        val dayOfWeekField = testEntity.memberByName("dayOfWeek") as EntityCalculatedMemberDeclaration
        val dayOfYearField = testEntity.memberByName("dayOfYear") as EntityCalculatedMemberDeclaration
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(yearField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(monthField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(dayField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(dayOfWeekField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(dayOfYearField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);

    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-008",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-017"
    ])
    def void testTimeFunctions() {
        val p = '''
            model TestModel;

            type time Time;
            type numeric Integer precision:9 scale:0;

            entity Test {
                field Integer hour <= `12:00:00`!hour();
                field Integer minute <= `12:00:00`!minute();
                field Integer second <= `12:00:00`!second();
                field Time time <= Time!of(hour = 12, minute = 2, second = 23);
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val hourField = testEntity.memberByName("hour") as EntityCalculatedMemberDeclaration
        val minuteField = testEntity.memberByName("minute") as EntityCalculatedMemberDeclaration
        val secondField = testEntity.memberByName("second") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(hourField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(minuteField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(secondField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-007",
        "REQ-TYPE-008",
        "REQ-TYPE-009",
        "REQ-ENT-001",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-018"
    ])
    def void testTimestampFunctions() {
        val p = '''
            model TestModel;

            type timestamp Timestamp;
            type date Date;
            type time Time;
            type numeric Integer(precision = 10, scale = 0);

            entity Test {
                field Date date <= `2022-01-01T12:00:00Z`!date();
                field Time time <= `2022-01-01T12:00:00Z`!time();
                field Integer asMilliseconds <= `2022-01-01T12:00:00Z`!asMilliseconds();
                field Timestamp fromMilliseconds <= Timestamp!fromMilliseconds(milliseconds = 12);
                field Timestamp timestamp <= Timestamp!of(date = Date!of(year = 2022, month = 1, day = 1), time = Time!of(hour = 12, minute = 2, second = 23));
                field Timestamp plus <= `2022-01-01T12:00:00Z`!plus(years = 1, months = -1, days = 0, hours = 12, minutes = 11, seconds = 1, milliseconds = 12);

            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val dateField = testEntity.memberByName("date") as EntityCalculatedMemberDeclaration
        val timeField = testEntity.memberByName("time") as EntityCalculatedMemberDeclaration
        val asMillisecondsField = testEntity.memberByName("asMilliseconds") as EntityCalculatedMemberDeclaration
        val fromMillisecondsField = testEntity.memberByName("fromMilliseconds") as EntityCalculatedMemberDeclaration
        val timestampField = testEntity.memberByName("timestamp") as EntityCalculatedMemberDeclaration
        val plusField = testEntity.memberByName("plus") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.DATE, TypeInfo.getTargetType(dateField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIME, TypeInfo.getTargetType(timeField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(asMillisecondsField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(fromMillisecondsField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(timestampField.getterExpr).getPrimitive);
        assertEquals(TypeInfo.PrimitiveType.TIMESTAMP, TypeInfo.getTargetType(plusField.getterExpr).getPrimitive);

    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-006",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-007",
        "REQ-ENT-008",
        "REQ-ENT-012",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-003",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-021"
    ])
    def void testEntityInstanceFunctions() {
        val p = '''
            model TestModel;

            type boolean Boolean;

            entity T1 {
            }

            entity T2 extends T1 {
            }

            entity Test {
                field T1 t1;
                field T2 t2;
                field T2[] t2s;

                field Boolean typeOf <= self.t1!typeOf(entityType = T1);
                field Boolean kindOf <= self.t1!kindOf(entityType = T1);
                field Test container <= self.t1!container(entityType = Test);
                field T1 asType <= self.t2!asType(entityType = T1);
                field Boolean memberOf <= self.t2!memberOf(instances = self.t2s);

            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1Field = testEntity.memberByName("t1") as EntityStoredFieldDeclaration

        val typeOfField = testEntity.memberByName("typeOf") as EntityCalculatedMemberDeclaration
        val kindOfField = testEntity.memberByName("kindOf") as EntityCalculatedMemberDeclaration
        val containerField = testEntity.memberByName("container") as EntityCalculatedMemberDeclaration
        val asTypeField = testEntity.memberByName("asType") as EntityCalculatedMemberDeclaration

        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(typeOfField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(kindOfField.getterExpr).getPrimitive)

        val TypeInfo containerTypeInfo = TypeInfo.getTargetType(containerField.getterExpr)
        assertEquals(testEntity, containerTypeInfo.getEntity)
        assertEquals(false, containerTypeInfo.isCollection)

        val TypeInfo asTypeTypeInfo = TypeInfo.getTargetType(asTypeField.getterExpr)
        assertEquals(t1Field.referenceType, asTypeTypeInfo.getEntity)
        assertEquals(false, containerTypeInfo.isCollection)

        val memberOfField = testEntity.memberByName("memberOf") as EntityCalculatedMemberDeclaration
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(memberOfField.getterExpr).getPrimitive)

    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-005",
        "REQ-TYPE-006",
        "REQ-TYPE-004",
        "REQ-ENT-001",
        "REQ-ENT-004",
        "REQ-ENT-007",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-003",
        "REQ-EXPR-004",
        "REQ-EXPR-006",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testSelectorFunctions() {
        val p = '''
            model TestModel;

            type string String min-size:0 max-size:32;
            type boolean Boolean;
            type numeric Integer(precision = 10, scale = 0);


            entity T1 {
                field String name;
            }

            entity Test {
                field T1[] t1s;
                field T1 t1;

                field T1[] head <= self.t1s!first(t | t.name);
                field T1[] tail <= self.t1s!last(t | t.name);
                field T1 any <= self.t1s!any();
                field Integer size <= self.t1s!size();
                field Boolean contains <= self.t1s!contains(instance = self.t1);
                field T1[] asCollection <= self.t1s!asCollection(entityType = T1);
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")
        val t1sField = testEntity.memberByName("t1s") as EntityStoredFieldDeclaration

        val headField = testEntity.memberByName("head") as EntityCalculatedMemberDeclaration
        val tailField = testEntity.memberByName("tail") as EntityCalculatedMemberDeclaration
        val anyField = testEntity.memberByName("any") as EntityCalculatedMemberDeclaration
        val sizeField = testEntity.memberByName("size") as EntityCalculatedMemberDeclaration
        val containsField = testEntity.memberByName("contains") as EntityCalculatedMemberDeclaration
        val asCollectionField = testEntity.memberByName("asCollection") as EntityCalculatedMemberDeclaration

        val TypeInfo headTypeInfo = TypeInfo.getTargetType(headField.getterExpr)
        assertEquals(t1sField.referenceType, headTypeInfo.getEntity)
        assertEquals(true, headTypeInfo.isCollection)

        val TypeInfo tailTypeInfo = TypeInfo.getTargetType(tailField.getterExpr)
        assertEquals(t1sField.referenceType, tailTypeInfo.getEntity)
        assertEquals(true, tailTypeInfo.isCollection)

        val TypeInfo anyTypeInfo = TypeInfo.getTargetType(anyField.getterExpr)
        assertEquals(anyField.referenceType, anyTypeInfo.getEntity)
        assertEquals(false, anyTypeInfo.isCollection)

        val TypeInfo asCollectionTypeInfo = TypeInfo.getTargetType(asCollectionField.getterExpr)
        assertEquals(asCollectionField.referenceType, asCollectionTypeInfo.getEntity)
        assertEquals(true, asCollectionTypeInfo.isCollection)

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sizeField.getterExpr).getPrimitive)

        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(containsField.getterExpr).getPrimitive)
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-TYPE-005",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-004",
        "REQ-ENT-007",
        "REQ-ENT-008",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-003",
        "REQ-EXPR-004",
        "REQ-EXPR-006",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testLambdaFunctions() {
        val p = '''
            model TestModel;

            type string String min-size:0 max-size:32;
            type numeric Decimal precision:9 scale:2;
            type boolean Boolean;

            entity T1 {
                field String name;
                field Decimal price;
            }

            entity Test {
                field T1[] t1s;
                field T1 t1;

                field T1[] filter <= self.t1s!filter(t | t.name == "Test");
                field Boolean anyTrue <= self.t1s!anyTrue(t | t.name == "Test");
                field Boolean allTrue <= self.t1s!allTrue(t | t.name == "Test");
                field Boolean anyFalse <= self.t1s!anyFalse(t | t.name == "Test");
                field Boolean allFalse <= self.t1s!allFalse(t | t.name == "Test");

                field Decimal min <= self.t1s!min(t | t.price);
                field Decimal max <= self.t1s!max(t | t.price);
                field Decimal avg <= self.t1s!avg(t | t.price);
                field Decimal sum <= self.t1s!sum(t | t.price);
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("Test")

        val filterField = testEntity.memberByName("filter") as EntityCalculatedMemberDeclaration
        val anyTrueField = testEntity.memberByName("anyTrue") as EntityCalculatedMemberDeclaration
        val allTrueField = testEntity.memberByName("allTrue") as EntityCalculatedMemberDeclaration
        val anyFalseField = testEntity.memberByName("anyFalse") as EntityCalculatedMemberDeclaration
        val allFalseField = testEntity.memberByName("allFalse") as EntityCalculatedMemberDeclaration
        val minField = testEntity.memberByName("min") as EntityCalculatedMemberDeclaration
        val maxField = testEntity.memberByName("max") as EntityCalculatedMemberDeclaration
        val avgField = testEntity.memberByName("avg") as EntityCalculatedMemberDeclaration
        val sumField = testEntity.memberByName("sum") as EntityCalculatedMemberDeclaration

        val TypeInfo filterTypeInfo = TypeInfo.getTargetType(filterField.getterExpr)
        assertEquals(filterField.referenceType, filterTypeInfo.getEntity)
        assertEquals(true, filterTypeInfo.isCollection)

        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(anyTrueField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(allTrueField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(anyFalseField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.BOOLEAN, TypeInfo.getTargetType(allFalseField.getterExpr).getPrimitive)

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(minField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(maxField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(avgField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(sumField.getterExpr).getPrimitive)
    }

    @Test
    @Requirement(reqs = #[
        "REQ-SYNT-001",
        "REQ-SYNT-002",
        "REQ-SYNT-003",
        "REQ-SYNT-004",
        "REQ-MDL-001",
        "REQ-TYPE-001",
        "REQ-TYPE-004",
        "REQ-TYPE-005",
        "REQ-ENT-001",
        "REQ-ENT-002",
        "REQ-ENT-004",
        "REQ-ENT-006",
        "REQ-ENT-008",
        "REQ-ENT-009",
        "REQ-ENT-010",
        "REQ-ENT-011",
        "REQ-EXPR-001",
        "REQ-EXPR-002",
        "REQ-EXPR-003",
        "REQ-EXPR-004",
        "REQ-EXPR-005",
        "REQ-EXPR-006",
        "REQ-EXPR-007",
        "REQ-EXPR-008",
        "REQ-EXPR-022"
    ])
    def void testQueryFunctions() {
        val p = '''
            model TestModel;

            type numeric Integer precision:9 scale:0;
            type string String(min-size = 0, max-size = 128);

            query Lead[] staticLeadsBetween(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) <= Lead!all()!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween);
            query Lead[] staticLeadsOverWithMin(Integer minLeadsOverMin = 5) <= staticLeadsBetween(minLeadsBetween = minLeadsOverMin , maxLeadsBetween = 100);
            query Integer staticLeadsBetweenCount(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) <= Lead!all()!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween)!size();
            query Integer staticLeadsOverWithMinCount(Integer minLeadsOverMin = 5) <= staticLeadsBetweenCount(minLeadsBetween = minLeadsOverMin, maxLeadsBetween = 100);
            query Lead[] staticLeadsBetweenAndSalesPersonLeads(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) =>
                Lead!all()!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween).salesPerson.leadsBetween(minLeadsBetween = minLeadsBetween, maxLeadsBetween = maxLeadsBetween);

            entity SalesPerson {
                relation Lead[] leads opposite salesPerson;

                query Lead[] leadsBetween(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) <= self.leads!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween);
                query Lead[] leadsOverWithMin(Integer minLeadsOverMin = 5) <= self.leadsBetween(minLeadsBetween = minLeadsOverMin , maxLeadsBetween = 100);
                query Lead[] leadsOverWithMinStatic(Integer minLeadsOverMin = 5) <= staticLeadsBetween(minLeadsBetween = minLeadsOverMin, maxLeadsBetween = 100);

                field Lead[] leadsOver10 <= self.leadsOverWithMin(minLeadsOverMin = 10);
                field Lead[] leadsOver20 <= self.leadsBetween(minLeadsBetween = 20);
                field Lead[] leadsOver10Static <= staticLeadsOverWithMin(minLeadsOverMin = 10);
                field Lead[] leadsOver20Static <= staticLeadsBetween(minLeadsBetween = 20);

                query Integer leadsBetweenCount(Integer minLeadsBetween = 1, Integer maxLeadsBetween = 50) <= self.leads!filter(lead | lead.value > minLeadsBetween and lead.value < maxLeadsBetween)!size();
                query Integer leadsOverWithMinCount(Integer minLeadsOverMin = 5) <= self.leadsBetweenCount(minLeadsBetween = minLeadsOverMin, maxLeadsBetween = 100);

                field Integer leadsOver10Count <= self.leadsOverWithMinCount(minLeadsOverMin = 10);
                field Integer leadsOver20Count <= self.leadsBetweenCount(minLeadsBetween = 20);
                field Integer leadsOver10CountStatic <= staticLeadsOverWithMinCount(minLeadsOverMin = 10);
                field Integer leadsOver20CountStatic <= staticLeadsBetweenCount(minLeadsBetween = 20);
            }

            entity Lead {
                field Integer value = 100000;
                relation required SalesPerson salesPerson opposite leads;
            }
        '''.parse
        p.assertNoErrors
        val m = p.fromModel

        val testEntity = m.entityByName("SalesPerson")

        val staticLeadsBetweenQuery = m.queryByName("staticLeadsBetween")
        val staticLeadsOverWithMinQuery = m.queryByName("staticLeadsOverWithMin")
        val staticLeadsBetweenCountQuery = m.queryByName("staticLeadsBetweenCount")
        val staticLeadsOverWithMinCountQuery = m.queryByName("staticLeadsOverWithMinCount")
        val staticLeadsBetweenAndSalesPersonLeadsQuery = m.queryByName("staticLeadsBetweenAndSalesPersonLeads")

        val leadsBetweenQuery = testEntity.memberByName("leadsBetween") as EntityCalculatedMemberDeclaration

        val leadsOverWithMinQuery = testEntity.memberByName("leadsOverWithMin") as EntityCalculatedMemberDeclaration
        val leadsOverWithMinStaticQuery = testEntity.memberByName("leadsOverWithMinStatic") as EntityCalculatedMemberDeclaration

        val leadsOver10Field = testEntity.memberByName("leadsOver10") as EntityCalculatedMemberDeclaration
        val leadsOver20Field = testEntity.memberByName("leadsOver20") as EntityCalculatedMemberDeclaration
        val leadsOver10StaticField = testEntity.memberByName("leadsOver10Static") as EntityCalculatedMemberDeclaration
        val leadsOver20StaticField = testEntity.memberByName("leadsOver20Static") as EntityCalculatedMemberDeclaration

        val leadsBetweenCountQuery = testEntity.memberByName("leadsBetweenCount") as EntityCalculatedMemberDeclaration
        val leadsOverWithMinCountQuery = testEntity.memberByName("leadsOverWithMinCount") as EntityCalculatedMemberDeclaration

        val leadsOver10CountField = testEntity.memberByName("leadsOver10Count") as EntityCalculatedMemberDeclaration
        val leadsOver20CountField = testEntity.memberByName("leadsOver20Count") as EntityCalculatedMemberDeclaration
        val leadsOver10CountStaticField = testEntity.memberByName("leadsOver10CountStatic") as EntityCalculatedMemberDeclaration
        val leadsOver20CountStaticField = testEntity.memberByName("leadsOver20CountStatic") as EntityCalculatedMemberDeclaration


        val TypeInfo staticLeadsBetweenTypeInfo = TypeInfo.getTargetType(staticLeadsBetweenQuery.expression)
        assertEquals(staticLeadsBetweenQuery.referenceType, staticLeadsBetweenTypeInfo.getEntity)
        assertEquals(true, staticLeadsBetweenTypeInfo.isCollection)

        val TypeInfo staticLeadsOverWithMinTypeInfo = TypeInfo.getTargetType(staticLeadsOverWithMinQuery.expression)
        assertEquals(staticLeadsOverWithMinQuery.referenceType, staticLeadsOverWithMinTypeInfo.getEntity)
        assertEquals(true, staticLeadsBetweenTypeInfo.isCollection)

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(staticLeadsBetweenCountQuery.expression).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(staticLeadsOverWithMinCountQuery.expression).getPrimitive)

        val TypeInfo staticLeadsBetweenAndSalesPersonLeadsTypeInfo = TypeInfo.getTargetType(staticLeadsBetweenAndSalesPersonLeadsQuery.expression)
        assertEquals(staticLeadsBetweenAndSalesPersonLeadsQuery.referenceType, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.getEntity)
        assertEquals(true, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.isCollection)

        val TypeInfo leadsBetweenTypeInfo = TypeInfo.getTargetType(leadsBetweenQuery.getterExpr)
        assertEquals(leadsBetweenQuery.referenceType, leadsBetweenTypeInfo.getEntity)
        assertEquals(true, staticLeadsBetweenAndSalesPersonLeadsTypeInfo.isCollection)

        val TypeInfo leadsOverWithMinTypeInfo = TypeInfo.getTargetType(leadsOverWithMinQuery.getterExpr)
        assertEquals(leadsOverWithMinQuery.referenceType, leadsOverWithMinTypeInfo.getEntity)
        assertEquals(true, leadsOverWithMinTypeInfo.isCollection)

        val TypeInfo leadsOverWithMinStaticTypeInfo = TypeInfo.getTargetType(leadsOverWithMinStaticQuery.getterExpr)
        assertEquals(leadsOverWithMinStaticQuery.referenceType, leadsOverWithMinStaticTypeInfo.getEntity)
        assertEquals(true, leadsOverWithMinStaticTypeInfo.isCollection)

        val TypeInfo leadsOver10TypeInfo = TypeInfo.getTargetType(leadsOver10Field.getterExpr)
        assertEquals(leadsOver10Field.referenceType, leadsOver10TypeInfo.getEntity)
        assertEquals(true, leadsOver10TypeInfo.isCollection)

        val TypeInfo leadsOver20TypeInfo = TypeInfo.getTargetType(leadsOver20Field.getterExpr)
        assertEquals(leadsOver20Field.referenceType, leadsOver20TypeInfo.getEntity)
        assertEquals(true, leadsOver20TypeInfo.isCollection)

        val TypeInfo leadsOver10StaticTypeInfo = TypeInfo.getTargetType(leadsOver10StaticField.getterExpr)
        assertEquals(leadsOver10StaticField.referenceType, leadsOver10StaticTypeInfo.getEntity)
        assertEquals(true, leadsOver10StaticTypeInfo.isCollection)

        val TypeInfo leadsOver20StaticTypeInfo = TypeInfo.getTargetType(leadsOver20StaticField.getterExpr)
        assertEquals(leadsOver20StaticField.referenceType, leadsOver20StaticTypeInfo.getEntity)
        assertEquals(true, leadsOver20StaticTypeInfo.isCollection)

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsBetweenCountQuery.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOverWithMinCountQuery.getterExpr).getPrimitive)

        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver10CountField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver20CountField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver10CountStaticField.getterExpr).getPrimitive)
        assertEquals(TypeInfo.PrimitiveType.NUMERIC, TypeInfo.getTargetType(leadsOver20CountStaticField.getterExpr).getPrimitive)

    }


}
