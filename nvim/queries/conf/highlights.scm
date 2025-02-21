; Variable assignments (key=value)
(variable_assignment
  name: (variable_name) @keyword
  "=" @operator
  value: (word) @string)

; Braced blocks (e.g., input-field { ... })
(compound_statement
  "{" @punctuation.bracket
  "}" @punctuation.bracket)

; Comments
(comment) @comment

; Section headers (e.g., 'input-field' before '{')
((word) @namespace
 (#not-has-parent? @namespace variable_assignment)
 (#is-not? local))

; Colors and gradients within values
((word) @constant
 (#match? @constant "rgba?\\([0-9, .]+\\)"))

((word) @constant.hex
 (#match? @constant.hex "#[0-9a-fA-F]{6,8}"))

; Gradient parts (match individual words that are part of gradients)
((word) @function
 (#match? @function "rgba?\\([0-9, .]+\\)"))
((word) @function
 (#match? @function "rgba?\\([0-9a-fA-F]+\\)"))
((word) @function
 (#match? @function "[0-9]+deg")
 (#has-ancestor? @function variable_assignment))
