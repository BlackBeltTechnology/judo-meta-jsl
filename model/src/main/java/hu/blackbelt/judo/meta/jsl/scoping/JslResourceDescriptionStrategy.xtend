package hu.blackbelt.judo.meta.jsl.scoping

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor
import hu.blackbelt.judo.meta.jsl.jsldsl.ModelDeclaration
import org.eclipse.xtext.naming.IQualifiedNameProvider
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityDeclaration
import java.util.Map
import java.util.HashMap
import hu.blackbelt.judo.meta.jsl.jsldsl.QueryDeclaration
import hu.blackbelt.judo.meta.jsl.jsldsl.JsldslPackage
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityRelationOppositeInjected
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import hu.blackbelt.judo.meta.jsl.jsldsl.EntityStoredRelationDeclaration

@Singleton
class JslResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

    @Inject extension IQualifiedNameProvider

    override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {

        if (eObject instanceof ModelDeclaration) {
            val modelDeclaration = eObject

            if (modelDeclaration.fullyQualifiedName !== null) {
                // System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ modelDeclaration + " fq: " + modelDeclaration.fullyQualifiedName.toString("::"));
                acceptor.accept(
                    EObjectDescription::create(
                        modelDeclaration.fullyQualifiedName, modelDeclaration, modelDeclaration.indexInfo
                    )
                )

                modelDeclaration.declarations.forEach[
                    declaration |

                    val fullyQualifiedName = declaration.fullyQualifiedName

                    if (fullyQualifiedName !== null)

                        acceptor.accept(
                            EObjectDescription::create(
                                fullyQualifiedName, declaration
                            )
                        )

                        if (declaration instanceof QueryDeclaration) {
                            val fq = declaration.fullyQualifiedName
                            if (fq !== null) {
                                // System.out.println("Indexing: " + fq)
                                acceptor.accept(
                                    EObjectDescription::create(
                                        fq, declaration, declaration.indexInfo
                                    )
                                )
                            }
                        }

                        if (declaration instanceof EntityDeclaration) {
                            //val decl = EcoreUtil.resolve(declaration, modelDeclaration) as EntityDeclaration;
                            declaration.members.forEach[m | {
                                val fq = m.fullyQualifiedName
                                if (fq !== null) {
                                    // System.out.println("Indexing: " + fq)
                                    acceptor.accept(
                                        EObjectDescription::create(
                                            fq, m, m.indexInfo
                                        )
                                    )

                                    if (m instanceof EntityStoredRelationDeclaration) {
                                        if ((m as EntityStoredRelationDeclaration).opposite instanceof EntityRelationOppositeInjected) {
                                            val fqOpposite = (m as EntityStoredRelationDeclaration).opposite.fullyQualifiedName
                                            if (fqOpposite !== null) {
                                                acceptor.accept(
                                                    EObjectDescription::create(
                                                        fqOpposite, (m as EntityStoredRelationDeclaration).opposite, (m as EntityStoredRelationDeclaration).opposite.indexInfo(m)
                                                    )
                                                )
                                            }
                                        }
                                    }
                                }
                            }]
                        }

                ]
            }
            true
        } else {
            // System.out.println("JslResourceDescriptionStrategy.createEObjectDescriptions="+ eObject);
            false
            //return super.createEObjectDescriptions(eObject, acceptor);
        }

    }

    def Map<String, String> indexInfo(EObject object) {
        object.indexInfo(null)
    }


    def Map<String, String> indexInfo(EObject object, EObject object2) {
        /*
         EntityMemberDeclaration
         : NL+ (EntityFieldDeclaration
         | EntityIdentifierDeclaration
         | EntityRelationDeclaration
         | EntityDerivedDeclaration
         | EntityQueryDeclaration
         | ConstraintDeclaration)
         ;
         */

        val Map<String, String> userData = new HashMap<String, String>

        switch object {
             ModelDeclaration: {
                 // System.out.println("(ModeltDeclaration) index:" + object.name)

                 if (object.name !== null) {
                     userData.put("fullyQualifiedName", object.name)
                 }
                 // System.out.println("Indexing " + object.name)
                 if (object.imports !== null) {
                     val importNames = new StringBuilder();
                     object.imports.forEach[
                         import |
                         val importNode = NodeModelUtils.findNodesForFeature(import, JsldslPackage::eINSTANCE.modelImportDeclaration_Model).head
                         if (importNode !== null) {
                            var importName = importNode.text.trim
                             if (importName.startsWith("`") && importName.endsWith("`")) {
                                 importName = importName.substring(1, importName.length - 1);
                             }

                             if (importNames.toString.length > 0) {
                                 importNames.append(",")
                             }
                             val aliasNode = NodeModelUtils.findNodesForFeature(import, JsldslPackage::eINSTANCE.modelImportDeclaration_Alias).head
                            var alias = "";
                             if (aliasNode !== null) {
                                 alias = aliasNode.text.trim;
                             }

                             importNames.append(importName + "=" + alias)

                             // System.out.println("(ModelDeclaration) Import name:" + importName + " Alias: " + alias)
                         }
                     ]
                     // System.out.println("\tImport: " + importNames)
                     userData.put("imports", importNames.toString)
                 }
             }

             EntityStoredRelationDeclaration: {
                 if ((object as EntityStoredRelationDeclaration).opposite !== null && (object as EntityStoredRelationDeclaration).opposite instanceof EntityRelationOppositeInjected) {
                     userData.put("oppositeName", ((object as EntityStoredRelationDeclaration).opposite as EntityRelationOppositeInjected).name)
                 }
             }
         }
        return userData
    }
}
