; not ;extends, overwrite.

; only fold top-level
[
 (const_declaration)
 (expression_switch_statement)
 (expression_case)
 (default_case)
 (type_switch_statement)
 (type_case)
 (for_statement)
 ;(func_literal)
 ;(if_statement)
 (import_declaration)
 (method_declaration)
 (type_declaration)
 (var_declaration)
 (composite_literal)
 (literal_element)
 ;; remove comments, block default behavior
 ;(comment)
 ;(block)
 ] @fold

;(
;  (comment) @fold
;  (#lua-match? @fold "^//#region.*")
;  (#offset! @fold 0 0 3 0)
;)

(
 [
  (comment) @_a
  (#lua-match? @_a "^// #region.*")
  ] @_start
 ;(_)+ @fold
 [
  (comment) @_b
  (#lua-match? @_b "^// #endregion.*")
  ] @_end
  (#contains? @_b "region types")
  ; cant do this:
  ; (#contains? @_b @_a) ; #contains? "// #endregion types" "// #region types"
) 

;(
; [(comment) @fold (#lua-match? @fold "^// #region.*")]
; (_)* @fold
; [(comment) @fold (#lua-match? @fold "^// #endregion.*")]
;)



; only fold function block body (not nesting)
(function_declaration
  body: (block) @fold
  (#lua-match? @fold "^.*\n.*\n")
  (#offset! @fold 1 0 -1 0)
  )

(func_literal
  body: (block) @fold
  (#lua-match? @fold "^.*\n.*\n")
  (#offset! @fold 1 0 -1 0)
  )

; only fold if statements with gt 3 newlines
(
 (if_statement) @fold
 (#lua-match? @fold "^.*\n.*\n.*\n")
 )





;(
;    (block) @fold
;    (#contains? @fold "\n")
;    (#offset! @fold 1 0 -1 0);(
;)




;--[[
;-- startrow, startcol, endrow,endcol
;vim.treesitter.query.set(
;    'go',
;    'folds',
;    [[
;
;( ; add offset so we can read comment text.
;  (comment) @fold
;  (#match? @fold "^/\\*\n")
;  (#offset! @fold 1 0 -1 0)
;)
;( ; no offset if the comment has text on the first line
;  (comment) @fold
;  (#match? @fold "^/\\* [a-zA-Z]")
;)
;
;
;]\]
;)
;--]]
