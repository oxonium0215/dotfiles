[
  (declaration_list)
  (block)
  (accessor_list)
  (enum_member_declaration_list)
  (switch_body)
  (switch_section)
  (anonymous_object_creation_expression)
  (initializer_expression)
  (lambda_expression)
  (anonymous_method_expression)
] @indent.begin

(if_statement consequence: (_) @indent.begin)
(if_statement alternative: (_) @indent.begin)
(foreach_statement body: (_) @indent.begin)
(for_statement body: (_) @indent.begin)
(while_statement body: (_) @indent.begin)
(do_statement body: (_) @indent.begin)

(try_statement (block) @indent.begin)
(catch_clause (block) @indent.begin)
(finally_clause (block) @indent.begin)

[
  "}"
  "]"
  ")"
] @indent.end

[
  "case"
  "default"
] @indent.branch
