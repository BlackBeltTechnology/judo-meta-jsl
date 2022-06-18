#!/bin/bash

mvn install -Dtycho.mode=maven -P update-target-versions -f ./targetdefinition/pom.xml
mvn validate -DskipModules -Dtycho.mode=maven -P update-category-versions