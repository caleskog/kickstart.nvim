; Match api.deprecateField or <identifier>.api.deprecateField calls
(function_call
  name: (dot_index_expression
          table: [
                  (dot_index_expression
                    table: [
                            (identifier)
                            (dot_index_expression)
                            ]
                    field: (identifier) ; @api
                    )
                  (identifier) ; @api
                  ]
          field: (identifier) @deprecateField_func_name (#eq? @deprecateField_func_name "deprecateField")
          )
  arguments: (arguments
               (string) @deprecateField_name
               (string) @deprecateField_message
               (function_definition) @deprecateField_using
               )
  ) @deprecateField_func

; Match api.deprecateValue or <identifier>.api.deprecateValue calls
(function_call
  name: (dot_index_expression
          table: [
                  (dot_index_expression
                    table: [
                            (identifier)
                            (dot_index_expression)
                            ]
                    field: (identifier) ; @api
                    )
                  (identifier) ; @api
                  ]
          field: (identifier) @deprecateValue_func_name (#eq? @deprecateValue_func_name "deprecateValue")
          )
  arguments: (arguments
               (string) @deprecateValue_from
               (string) @deprecateValue_name
               (string) @deprecateValue_message
               (function_definition) @deprecateValue_using
               (function_definition)? @deprecateValue_default
               )
  ) @deprecateValue_func


; Match api.register or <identifier>.api.register calls
(function_call
  name: (dot_index_expression
          ; Could replace the table below with `table: (_)`
          table: [
                  (dot_index_expression
                    table: [
                            (identifier)
                            (dot_index_expression)
                            ]
                    field: (identifier) ; @api
                    )
                  (identifier) ; @api
                  ]
          field: (identifier) @register_func_name (#eq? @register_func_name "register")
          )
  arguments: (arguments (table_constructor))
  ) @register_func

; Match api.alias or <identifier>.api.alias calls
(function_call
  name: (dot_index_expression
          ; Could replace the table below with `table: (_)`
          table: [
                  (dot_index_expression
                    table: [
                            (identifier)
                            (dot_index_expression)
                            ]
                    field: (identifier) ; @api
                    )
                  (identifier) ; @api
                  ]
          field: (identifier) @alias_func_name (#eq? @alias_func_name "alias")
          )
  arguments: (arguments 
            (string)+
            )
  ) @alias_func

(arguments
  (string) @alias_string
  )

; Match api.register fields
(field
  name: (identifier) @name_key (#eq? @name_key "name")
  value: (string
           content: (string_content ) @name )
  )

(field
  name: (identifier) @scope_key (#eq? @scope_key "scope")
  value: [
          (string
            content: (string_content) @scope)
          (table_constructor) @scope
          ]
  )

(field
  ; This matches the case where there is an optional `name:` child.
  name: (identifier)? @field_name
  value: [
          ; The `scope` field is a table_constructor of values. Each vaule is a string type.
          (string) @field_string
          ; The `allowed` field is a table_constructor of key-value pairs. Values are of the following types: string, table_constructor of strings.
          (dot_index_expression
            table: [
                    (identifier)
                    (dot_index_expression)
                    ]
            field: (identifier)) @field_dotted_expression
          (identifier) @field_identifier
          (table_constructor) @field_table
          ]
  ) @premake_field

(field
  name: (identifier) @kind_key (#eq? @kind_key "kind")
  value: (string
           content: (string_content) @kind)
  )

(field
  name: (identifier) @allowed_key (#eq? @allowed_key "allowed")
  value: [
          (table_constructor) @allowed
          (function_definition) @allowed
          ]
  )

(field
  name: (identifier) @aliases_key (#eq? @aliases_key "aliases")
  value: (table_constructor) @aliases
  )

(field
  name: (identifier) @tokens (#eq? @tokens "tokens")
  value: (true)
  )

(field
  name: (identifier) @pathVars (#eq? @pathVars "pathVars")
  value: (true)
  )

(field
  name: (identifier) @allowDuplicates (#eq? @allowDuplicates "allowDuplicates")
  value: (true)
  )
