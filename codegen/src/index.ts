import * as ts from "typescript"
import process from "process";

import { 
  createInterfaceMap,
  getBaseInterfaces,
  getInterfaces,
  handleInterface,
  getTypeAliases,
  createTypeAliasMap,
} from "./parser"

import { propsCompare, Field, WrittenProps, Props } from "./types" 
import { collectForeignData, top, writeForeignData, writeProps } from "./writer"
import { ignoreForeignDataList } from "./consts";

const printWrittenProps = (writtenProps: WrittenProps[]): void =>
  writtenProps.forEach((p) => {
    console.log(p.props.join("\n\n"))
    if(p.fns.length){
      console.log("\n")
      console.log(p.fns.join("\n\n"))
    }
    console.log("\n")
  })



const options = ts.getDefaultCompilerOptions()
const program = ts.createProgram(["./node_modules/@types/react-native/index.d.ts"], options)
const sources =
  program
    .getSourceFiles()
    .filter((src) => src.isDeclarationFile)
    .filter((src) => src.fileName.indexOf("@types/react-native/index.d.ts") >= 0)

console.log("sources.length", sources.length)
console.log("sources.fileName[]", sources.map(({fileName}) => fileName))
// process.exit(0)
const interfaces: ts.InterfaceDeclaration[] = getInterfaces(sources[0])
const interfaceMap = createInterfaceMap(interfaces)
const typeAliasMap = createTypeAliasMap(getTypeAliases(sources[0]))
const baseInterfaces = getBaseInterfaces(interfaceMap, sources[0])

// console.log("baseInterfaces", baseInterfaces.map(({classNames}) => classNames));
// console.log("typeAliasMap", Object.keys(typeAliasMap));
// console.log("interfaceMap", Object.keys(interfaceMap));

const props = baseInterfaces.map(handleInterface(true)(typeAliasMap)(interfaceMap))

console.log("props", props.map(({name}) => name))
const remainingTypeNames: string[] = collectForeignData(([] as Field[]).concat(...props.map((prop) => prop.fields)))
const buildAdditionalProps = (names: string[], existingNames: string[], count: number): Props[] => {
  
  if(names.length === 0) return []
  if(count > 10) throw ("propbably in a cycle while building additional props")
  
  const additionalProps = 
  names 
    .filter(name => existingNames.indexOf(name) < 0)
    .filter(name => ignoreForeignDataList.indexOf(name) < 0)
    .filter(name => interfaceMap[name] !== undefined)
    .map(name => handleInterface(false)(typeAliasMap)(interfaceMap)({ iface: interfaceMap[name], classNames: []}))
    
    
    const additionalTypeNames = 
    collectForeignData(([] as Field[])
    .concat(...additionalProps.map((prop) => prop.fields)))
    .filter(name => ignoreForeignDataList.indexOf(name) < 0)
    .filter(name => names.indexOf(name) < 0)
    
    return additionalProps.concat(buildAdditionalProps(additionalTypeNames, existingNames.concat(names), count + 1))
  }
  
console.log("before remainingProps")
const remainingProps = buildAdditionalProps(remainingTypeNames, props.map(p => p.name), 0)
console.log("after remainingProps")

const allProps = props.concat(remainingProps).sort(propsCompare).map(writeProps)

console.log(top)
printWrittenProps(allProps)

