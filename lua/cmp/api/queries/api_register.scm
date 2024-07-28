; Match api.register or <identifier>.api.register calls
(function_call
  name: (dot_index_expression
    ; Could replace the table below with `table: (_)`
    table: [
        (dot_index_expression
            table: (identifier)
            field: (identifier) ; @api
        )
        (identifier) ; @api
    ]
    field: (identifier) @func_name (#eq? @func_name "register")
  )
  arguments: (arguments (table_constructor))
) @register_func

; Match the table counstructor for the function
(table_constructor
    (field
        name: (identifier) @name_key (#eq? @name_key "name")
        value: (string
            content: (string_content) @name)
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
        name: (identifier) @kind_key (#eq? @kind_key "kind")
        value: (string
            content: (string_content) @kind)
    )
    (field
        name: (identifier) @allowed_key (#eq? @allowed_key "allowed")
        value: (table_constructor) @allowed ; List of values. Values is of the following: string, dot_index_expression, or identifier.
    )?
    (field
        name: (identifier) @aliases_key (#eq? @aliases_key "aliases")
        value: (table_constructor) @aliases ; List of key-value pairs. Values are of the following types: string, table_constructor of strings.
    )?
    (field
        name: (identifier) @tokens (#eq? @tokens "tokens")
        value: (true)
    )?
    (field
        name: (identifier) @pathVars (#eq? @pathVars "pathVars")
        value: (true)
    )?
    (field
        name: (identifier) @allowDuplicates (#eq? @allowDuplicates "allowDuplicates")
        value: (true)
    )?
)

