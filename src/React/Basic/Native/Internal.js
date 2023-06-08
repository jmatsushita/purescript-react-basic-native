import * as React from "react"
import * as RN from "react-native"

export const mergeStyles = (styles) => {
  return Object.assign.apply(null, [{}].concat(styles))
}

export const unsafeCreateNativeElement = (name) => {
  return (props) => {
    var children = (props.children) ? props.children : []
    return React.createElement.apply(React, [RN[name], props].concat(children))
  }
}
