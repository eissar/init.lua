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

(
  (region_start) @start_name
  (_)+ @fold
  (region_end) @end_name
  (#match_region? @start_name @end_name)
)

;(; works/ no new predicate required
;  (region_start (region_name)) @_start_name
;  (_)+
;  .
;  (region_end (region_name)) @_end_name
;  (#eq? @_start_name @_end_name)
;)





;(#make-range! @fold @start_region @end_region)

; can we (comment) @fold; (var_declaration) @fold
;(source_file
;  ((comment) @_start (#lua-match? @_start "^// #region")) @fold
;  ( (_)* @fold
;    (#lua-match? @fold "^//(?! #end).")  ; Ensure we don't fold past the end region.  Crucial!
;  )  ; The inner content is optional (empty regions).
;  ;((comment) @_end (#lua-match? @_end "^// #endregion")) @fold
;)


;(
;  [(region_start (region_name)@_start_name)] @fold
;  (_)* @fold
;  [(region_end (region_name) @_end_name)] @fold
;  (#any-eq? @_start_name @_end_name)
;)

;(; overlapping region issue
; [
;  (
;   (region_start (region_name) @start_name)
;   (_)+ @fold  ; Capture any intervening nodes.
;   .
;   (region_end (region_name) @end_name)
;   )
;  ]
; ;(#any-eq? @start_name @end_name)
; )

;(
;(region_start (region_name)) @_start
;(_)* @fold
;(region_end (region_name)) @_end
;(#eq? @_start @_end)
;)

;(
; [
;  (region_start (region_name)@_start_name)
;  (_)+
;  (region_end (region_name)@_end_name)
; ] @fold
;  (#any-eq? @_start_name @_end_name)
;)




; only fold function block body
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
