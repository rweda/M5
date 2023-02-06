\m4_TLV_version 1d: tl-x.org
\m4
// The M5 M4 Macro library.

// Documentation is generated from M5_spec.adoc.

// Internal Coding Conventions:
//
//  o Private macros use "__". A helper macro for m5_foo would be called m5_foo__xxx.
//    The existance of m5_foo reserves the namespace m5_foo__* for private use.
//  o Data structures use ".". E.g. "m4_foo.bar" holds field "bar" of object "m5_foo".
//    (These names cannot be called directly, but can be accessed/called via m4_defn, m4_indir, etc.)





// #############################
// Debugging

// See docs.
m4_define(['m5_recursion_limit'], ['['300']'])

m4_define(['m5__stack_depth'], ['['0']'])


// Abbreviate a string, replacing long strings with ['...'].
// m5_abbreviate(string, max-length)
m4_define(['m5_abbreviate'],
   ['...'])
// TODO: Pull code from abbreviate_args into abbreviate. Also, make a macro to print a string, truncating a printable string and appending ....

// See docs.
m4_define(['m5_abbreviate_args'],
   ['m5_abbreviate_args__guts([''], $@)'])
// Guts of m5_abbreviate_args
// Args: (comma, ...), where ... are the args of m5_abbreviate_args with the count decrementing.
m4_define(['m5_abbreviate_args__guts'],
   ['m4_ifelse(m4_eval($# > 3), 1,
               ['['$1']m4_ifelse(m5_calc(['$2 <= 0']), 1,
                                 ['[' ...']'],
                                 ['m4_ifelse(m5_calc(m4_len(['$4'])[' > $3 || (']m4_index(['$4'], m5_nl)[' >= 0)']), 1,   /// use "..." if arg is too long or contains new line
                                             ['['['...']']'],
                                             ['['['$4']']'])m5_recurse(20, abbreviate_args__guts, [','], m4_eval(['$2-1']), ['$3']m5_comma_shift(m4_shift(m4_shift(m4_shift($@)))))'])'])'])

// Abbreviate m5_func_stack_top (just the top value) by truncating args. This is done lazily only when needed.
m4_define(['m5_abbreviate_func_stack_top'],
   ['m4_define(['m5_func_stack_top'],
               m5_quote(m4_patsubst(m5_translit(m5_func_stack_top, m5_nl, ['']),   /// Transliterated to remove new lines, which affect regex.
                                    ['^\(\w+\)(\(.*\))$'],
                                    ['['\1(']m5_abbreviate_args(6, 15, \2)[')']'])))'])

// Dump the function call stack by recursively peeling into m5_func_stack_top.
// We abbreviate lines as they are processed (even if they have already been abbreviated).
// TODO: Do this instead in m5_fn__to_call.
m4_define(['m5_func_stack'],
   ['m4_ifelse(m4_defn(['m5_func_stack_top']), [''], [''],
      ['m5_eval(m5__concat(
         ['m5_abbreviate_func_stack_top()'],
         ['m4_pushdef(['m5_func_stack_tmp'], m4_defn(['m5_func_stack_top']))'],
         ['m4_popdef(['m5_func_stack_top'])'],
         ['m5_func_stack(['$1'])'],
         ['m4_pushdef(['m5_func_stack_top'], m4_defn(['m5_func_stack_tmp']))'],
         ['m4_popdef(['m5_func_stack_tmp'])'],
         ['m5_nl['$1']m5_printable(m5_func_stack_top)']))'])'])

// Given function and args-list, add the call to the stack.
m4_define(['m5_fn__push_stack'],
   ['m4_pushdef(['m5_func_stack_top'], ['m5_fn__to_call($@)'])m4_define(['m5__stack_depth'], m4_eval(m5__stack_depth + 1))m4_ifelse(m4_eval(m5__stack_depth > m5_recursion_limit), 1, ['m5_fatal_error(['Call stack reached maximum depth. Exiting.'])'])'])
// Given function and args-list, represent them as a call.
m4_define(['m5_fn__to_call'],
   ['['$1']m4_ifelse(['$2'], [''], [''], ['['($2)']'])'])

m4_define(['m5_fn__pop_stack'],
   ['m4_popdef(['m5_func_stack_top'])m4_define(['m5__stack_depth'], m4_eval(m5__stack_depth - 1))'])

// Report error/warning.
//  $1: error/warning
//  $2: message
//  $3: (opt) tag
//  $4: (opt) max times to report this tag (required if tag given); should be the same for all uses of this tag.
m4_define(['m5_report'],
   m5__concat(
      ['m5_comment(['If given, record max for this tag.'])'],
      ['m4_ifelse(m4_eval($# >= 4), 1, ['m4_define(['m5_report__max_$3'], ['$4'])'])'],
      ['m5_comment(['Provide a default max for this tag.'])'],
      ['m4_ifdef(['m5_report__max_$3'], [''], ['m4_define(['m5_report__max_$3'], ['m4_ifelse(m4_eval($# >= 3), 1, ['10'], ['60'])'])'])'],
      ['m5_comment(['Initialize or increment count (including no-tag case).'])'],
      ['m4_define(['m5_report__cnt_$3'], m4_ifdef(['m5_report__cnt_$3'], ['m4_incr(m5_report__cnt_$3)'], ['1']))'],
      ['m5_comment(['Report error if we should.'])'],
      ['m4_ifelse(m4_eval(m5_report__cnt_$3 <= m5_report__max_$3), 1, ['m5_errprint_nl(m5_nl()m5_printable(['$2'])m5_nl()m4_ifelse(m5_report__cnt_$3, m5_report__max_$3, ['['(Subsequent $1s of this type ($3) will be ignored.)']m5_nl()'])['  Call Stack:']m5_nl['    ']m4_ifdef(['m5_func_stack_header'], ['m5_func_stack_header'], ['['No stack']'])['']m5_func_stack(['    -> ']))'])']))
m4_define(['m5_warning'],
   ['m5_report(warning, ['Warning: $1']m5_comma_shift($@))'])
m4_define(['m5_error'],
   ['m5_report(error, ['Error: $1']m5_comma_shift($@))'])
m4_define(['m5_fatal_error'],
   ['m5_error($@)m4_m4exit(1)'])
// Report an error massage (['$2']) if a condition (m5_calc(['$1'])) is true.
m4_define(['m5_error_if'],
   ['m5_if(['$1'], ['m5_error(['$2'])'])'])
// Check a condition that should not be possible to violate.
//  $1: A quoted condition to check via m5_calc($1).
m4_define(['m5_assert'],
   ['m5_if(m5_calc($1), ['Failed assertion: $1.'])'])

// Set the maximum number of errors/warnings to report with a given tag (including none).
//  $1: tag
//  $2: max
m4_define(['m5_set_report_max'],
   ['m4_define(['m5_report__max_$1'], ['$2'])'])

m4_define(['m5_errprint'], ['m4_errprint(m5_printable(m4_quote($@)))'])
// m5_errprint with a new line appended.
m4_define(['m5_errprint_nl'],
   ['m5_errprint($@m5_nl)'])
// Print a debug message to stderr. In CAPS so it stands out.
m4_define(['m5_DEBUG'],
   ['m5_errprint_nl(['DEBUG: ']$@)'])
m4_define(['m5_DEBUG_stack'],
   ['m5_error(['DEBUG: ']$@)'])


// #############################
// Code Blocks

// These are produced by pre_m4.
m4_define(['m5__block'],
   ['['m4_pushdef(['m5_block_output'], [''])m5_exec(['$1'])m5_eval(m5_defn(block_output))m4_popdef(['m5_block_output'])']'])
m4_define(['m5__scope'],
   ['['m4_pushdef(['m5_block_output'], [''])m5__begin_scope['']m5_exec(['$1'])m5__end_scope['']m5_eval(m5_defn(block_output))m4_popdef(['m5_block_output'])']'])
// For text blocks. Strip leading new line (which requires a regexp, which doesn't work with \n).
m4_define(['m5__text_block'],
   ['m4_regexp(m4_translit(['['$1']'], m5_nl, ['']), ['^\(.*\)$'], ['m4_translit(['['\1']'], [''], m5_nl)'])'])
m4_define(['m5__stmt'],
   ['m4_ifelse(m4_pushdef(['m5__tmp'], m4_quote(m4_indir($@)))m4_defn(['m5__tmp']), [''], [''], ['m5__stmt_err(m4_defn(['m5__tmp']), $@)'])'])
m4_define(['m5__stmt_err'],
   ['m5_error(['Code block statement: $2(']m5_abbreviate_args(5, 12, m4_shift(m4_shift($@)))[')']m5_nl['     produced unexpected output: ']m5_substr(m5_dequote(['$1']), 0, 30)m4_ifelse(m4_eval(m4_len(['$1']) > 30), 1, ['['...']']))'])
m4_define(['m5__out_stmt'],
   ['m5_out(m4_indir($@))'])

m4_define(['m5_status'], ['['']'])



// #############################
// Fundamental

// =======================
// Private

// Uniquifier -- A globally unique name.
// There may be a reason to expose these publicly, but I couldn't come up with a reasonable one.
// These are used by lazy functions.
// Use ['m5_']m5__new_uniquifier and subsequently ['m5_']m5__same_uniquifier (prior to other m5__new_uniquifier) as a unique macro name.
m4_define(['m5__uniquifier'], ['['0']'])
m4_define(['m5__same_uniquifier'], ['['_U']m5__uniquifier'])
m4_define(['m5__new_uniquifier'],
   ['m4_define(['m5__uniquifier'], m4_dquote(m4_eval(m5__uniquifier + 1)))m5__same_uniquifier'])


// =======================
// Renamed from M4

m4_define(['m5_shift'], m4_defn(['m4_shift']))
m4_define(['m5_defn'], ['m4_ifdef(['m5_$1'], ['m4_defn(['m5_$1'])'], ['m5_error(['No definition for m5_$1.'])'])'])
m4_define(['m5_call'], ['m4_indir(['m5_$1']m5_comma_shift($@))'])
m4_define(['m5_length'], m4_defn(['m4_len']))
m4_define(['m5_index_of'], m4_defn(['m4_index']))
m4_define(['m5_format_eval'], m4_defn(['m4_format']))


// =======================
// Special Characters and Quotes

m5_pragma_disable_quote_checks
m4_define(['m5_nl'], ['['$1
']'])
m5_pragma_enable_quote_checks

// These provide quotes that can be passed into macro arguments without interpretation.
// (Of course, their substitutions within these macros will be interpreted as quotes, so these
//  macros should be used with caution in rare scenarios.)

// m5_quote(args) - convert args to quoted list of quoted strings
m4_define(['m5_quote'], ['['$@']'])
// Introduce the given number of levels of quotes.
// m5_nquote(2, ['one'], ['two']) is equivalent to m5_quote(m5_quote(['one'], ['two'])) is equivalent to ['['['one'],['two']']'], which all evaluate to ['['one'], ['two']'].
m4_define(['m5_nquote'],
   ['m4_ifelse(m4_eval(['$1 <= 0']), 1, ['m5_shift($@)'], ['$0(m4_eval(['$1-1']), m5_quote(m5_shift($@)))'])'])


// =======================
// Misc

m4_define(['m5_eval'], ['$1['']'])
m4_define(['m5_inline'], ['$1'])
m4_define(['m5_comment'], [''])
m4_define(['m5_nullify'], [''])


// =======================
// Stacks

// Extract an entry from a variable stack.
// m5_defn_ago(foo, 1)  // for previous definition
m4_define(['m5_defn_ago'],
   ['m4_ifdef(['m5_$1'], ['m4_ifelse(m4_eval(['$2 <= 0']), 1, ['m4_defn(['$1'])'], ['m4_pushdef(['m5_$1__reverse'], m4_defn(['m5_$1']))m4_popdef(['m5_$1'])$0(['$1'], m4_eval(['$2 - 1']))m4_pushdef(['m5_$1'], m4_defn(['m5_$1__reverse']))m4_popdef(['m5_$1__reverse'])'])'])'])
// m5_depth_of(foo, 1000)
// Determine the number of entries in a stack (up to an optional limit).
m4_define(['m5_depth_of'],
   ['m4_ifdef(['m5_$1'],
              ['m4_ifelse(m4_ifelse(['$2'], [''], ['0'], ['m4_eval(['$2'] <= 0)']), 1,
                          ['0'],
                          ['m4_pushdef(['m5_$1__reverse'], m4_defn(['m5_$1']))m4_popdef(['m5_$1'])m4_eval(1 + $0(['$1'], m4_ifelse(['$2'], [''], [''], ['m4_eval(['$2 - 1'])'])))m4_pushdef(['m5_$1'], m4_defn(['m5_$1__reverse']))m4_popdef(['m5_$1__reverse'])'])'],
              ['0'])'])


// =======================
// Recursion

// Limited recursion.
// m5_recurse(20, myself, args)  // Recursive call to myself to a limited recursion depth of 20.
m4_define(['m5_recurse'],
          ['m4_ifdef(['m5_$2__rec_depth'], [''], ['m4_define(['m5_$2__rec_depth'], 0)'])m4_define(['m5_$2__rec_depth'], m4_eval(m5_$2__rec_depth + 1))m4_ifelse(m4_eval(m5_$2__rec_depth > ['$1']), 1, ['m5_error(['Recursion limit for $2 exceeded $1.'])'], ['m4_indir(['m5_$2']m4_ifelse(m4_eval($# > 2), 1, [', m4_shift(m4_shift($@))']))'])m4_define(['m5_$2__rec_depth'], m4_eval(m5_$2__rec_depth - 1))'])



// #############################
// Text/String Processing/Parsing

// =======================
// General

// Boolean check of nullness of a variable.
m4_define(['m5_is_null'],
   ['m5_must_exist(['$1'])m4_ifelse(m5_$1, [''], ['['1']'], ['['0']'])'])
m4_define(['m5_isnt_null'],
   ['m5_must_exist(['$1'])m4_ifelse(m5_$1, [''], ['['0']'], ['['1']'])'])

m4_define(['m5_append_var'], ['m5_set(['$1'], m5_value_of(['$1'])['$2'])'])
m4_define(['m5_prepend_var'], ['m5_set(['$1'], ['$2']m5_value_of(['$1']))'])
m4_define(['m5_append_macro'], ['m4_define(['m5_$1'], m4_defn(['m5_$1'])['$2'])'])
m4_define(['m5_prepend_macro'], ['m4_define(['m5_$1'], ['$2']m4_defn(['m5_$1']))'])
// Concatenate strings.
// Output the quoted concatenation of the arguments.
// Mostly this is useful for spanning multiple lines.
m4_define(m5__concat,
   ['m4_ifelse(['$#$1'], ['1'], [''], ['['$1']$0(m4_shift($@))'])'])
// Merge all arguments into a delimited string.
// m5_join([','], ['one'], ['two'])  => ['one'][',']['two']
m4_define(['m5_join'],
   ['m4_ifelse(m4_eval($# <= 2), 1, ['['$2']'], ['$0(['$1'], ['$2$1$3']m4_ifelse(m4_eval($# > 3), 1, [', m4_shift(m4_shift(m4_shift($@)))']))'])'])

m4_define(['m5_translit_eval'], m4_defn(['m4_translit'])['['']'])
// Transliterate. Note that quotes characters cannot be transliterated.
m4_define(['m5_translit'], ['m4_translit(['['$1']'], ['$2'], ['$3'])'])
m4_define(['m5_uppercase'], ['m4_translit(['['$1']'], ['a-z'], ['A-Z'])'])
m4_define(['m5_lowercase'], ['m4_translit(['['$1']'], ['A-Z'], ['a-z'])'])
// m4_replicate(cnt, str)
m4_define(['m5_replicate'],
   ['m5_if($1 > 0, ['['$2']m5_recurse(1000, replicate, m5_calc($1 - 1), ['$2'])'])'])

// E.g: m5_extract_prefix(['!!'], var) strips m5_var of a ['!!'] prefix if it has one and evaluates to ['!!'] or [''].
// Any text beginning from a new line is also stripped.
// Note that, 'var' is assumed to be a variable (so quoted).
m4_define(['m5_extract_prefix'],
          ['m4_ifelse(m5_substr(m5_$2, 0, m4_len(['$1'])), ['$1'],
                      ['m5_substr(m5_$2, 0, m4_len(['$1']))['']m5_set($2, m5_substr(m5_$2, m4_len(['$1'])))'])'])
// m5_extract_prefix_eval(<prefix>, var)
// A faster alternative to m5_extract_prefix that evaluates both the prefix and the assigned values (so a safe
// alternative if these are known not to be affected by evaluation).
m4_define(['m5_extract_prefix_eval'],
          ['m4_ifelse(m4_substr(m5_$2, 0, m4_len(['$1'])), ['$1'],
                      ['['$1']m5_set($2, m4_substr(m5_$2, m4_len(['$1'])))'])'])
// m5_extract_regex(regex, var) like m5_extract_prefix, except the prefix is given as a regex subexpression.
m4_define(['m5_extract_prefix_regex'],
          ['m4_regexp(m5_$2, ['^\($1\)?\(.*\)'], ['m5_var(['$2'], ['\2'])['\1']'])'])

// Evaluate to the number of lines in $1.
m4_define(['m5_num_lines'], ['m4_len(m4_patsubst(['$1'], ['[^']m5_nl[']+'], ['']))'])

// m5_prefix_lines(['prefix'], ['body'])
// Add a prefix after all newlines in body, returning the quoted updated body.
// Note that the first line is not prefixed.
m4_define(['m5_prefix_lines'], ['m4_patsubst(['['$2']'], m5_nl, m5_nl['$1'])'])


m5_pragma_disable_paren_checks
// A literal open/close quote. Use these with caution. They must be matching when evaluated.
m4_define(['m5_open_quote'],
   ['m4_changequote()['m5_nullify('])m4_changequote([','])'])
m4_define(['m5_close_quote'],
   ['m4_changequote()m5_nullify([')']m4_changequote([','])'])
m5_pragma_enable_paren_checks

// Original quotes. Using these macros is safe since the resulting "['", "']" are not interpreted as quotes.
m4_define(['m5_orig_open_quote'],
   ['m4_changequote(<,>)<[><'>m4_changequote([','])'])
m4_define(['m5_orig_close_quote'],
   ['['''][']']'])


/// Use of control characters (surrogates) by M5.
/// Char Hex  Description          Replaces  Scenario
/// ---- ---  -----------          --------  --------
///     01   Start of Heading     SoT([')   An alternate surrogate quote for substr.
///     02   Start of Text        ['        Substituted prior to M4 by pre_m4 and requote_stream scripts. Reversed by post_m4.
///     03   End of Text          ']        "
///     04   End of Transmission  /         For safe strings.
///     06   Acknowledge          SoT([')   Used to provide quoted output in a m4_translit that substitutes quotes.
///     0E   Shift Out            (         For safe strings.
///     0F   Shift In             )         "
///     10   Data Link Esc.       \n        Used for regex to avoid implications of \n.
///     15   Negative Acknowledge EoT('])   Used to provide quoted output in a m4_translit that substitutes quotes.
///     17   End of Trans. Block  ,         For safe strings.
///     19   End of Medium        SoT('])   An alternate surrogate quote for substr.
///     1A   Substitute           _         For safe strings (to prevent macro expansion).
///     1B   Escape               N/A       The value m5_UNDEFINED.
///     1C   File Separator       SoT([')   An alternate surrogate quote for safe strings.
///     1D   Group Separator      EoT('])   "
///     1E   Record Separator     SoT([')   An alternate surrogate quote for dequoted strings.
///     1F   Unit Separator       EoT('])   "


// A value unique from any value ASCII string. Values can be assigned to this to indicate
// that no assignment has been made.
m4_define(['m5_UNDEFINED'], [''])

// Quoting and dequoting.
// Dequoted strings use alternate surrogate quotes and can therefore be safely broken into (quoted) substrings.
// A dequoted string or a partially dequoted string can be dequoted again. Requoting (once) will restore all quotes.

// Substitute quotes for (different) control-character quotes (U-001E and U-001F, "Record Separator"
// and "Unit Separator"), aka "surrogate-quotes".
// Produce a quoted string by giving the string alternate-surrogate-quote bookends that translate to quotes.
// And translit quotes to their surrogates.
m4_define(['m5_dequote'],
   ['m4_translit(['$1'], ['['']'], ['['']'])'])
// Inverse of dequoting, using the inverse approach.
m4_define(['m5_requote'],
   ['m4_translit(['$1'], [''], ['['']['']'])'])

// Same as m5_dequote/m5_requote using different alternate quotes.
// These are used by m5_substr to test dequoting.
// Inverse of dequoting, using the inverse approach.
m4_define(['m5__alt_dequote'],
   ['m4_translit(['$1'], ['['']'], ['['']'])'])
m4_define(['m5__alt_requote'],
   ['m4_translit(['$1'], [''], ['['']['']'])'])


m4_define(['m5_printable_open_quote'], ['['⌈']'])   // other options: ‹⦗⧼᚜⦃⎨༼⦓〈‹⟬≺
m4_define(['m5_printable_close_quote'], ['['⌉']'])

// Substitute control-character quotes for printable UTF-8 quotes.
m4_define(['m5_printable'],
   ['m4_patsubst(m4_patsubst(m5_nquote(2, m5_dequote(['$1'])), [''], m5_printable_open_quote), [''], m5_printable_close_quote)'])

// Output a literal $1 with control-character quotes and printable quotes replaced by their original format (['']).
m4_define(['m5_output_with_restored_quotes'],
   ['m4_pushdef(['m4_tmp'], m5_printable(['$1']))m4_patsubst(m4_patsubst(m5_nquote(2, m4_defn(['m4_tmp'])), m5_printable_open_quote, m5_orig_open_quote), m5_printable_close_quote, m5_orig_close_quote)m4_popdef(['m4_tmp'])'])


// Make sure string has no quotes.
m4_define(['m5_no_quotes'],
   ['m4_ifelse(['$1'], m5_dequote(['$1']), [''], ['m5_error(['String "$1" should not contain quotes.'])'])'])

// Extract a substring.
// $1: the string
// $2: start char position
// $3: (opt) length
// Extracting substrings from strings with quotes is dangerous as it can lead to imbalanced quoting.
// If the resulting string would contain any quotes, an error is reported and the resulting string
// has its quotes replaced by control characters.
m4_define(['m5_substr'],
   m5__scope(['m5_var(ret, m5__unsafe_string(m4_substr(m5__safe_string_with_check(m5__alt_dequote(['$1'])), m5_shift($@))))m4_ifelse(m4_ifelse(m4_index(m5_ret, ['']), ['-1'], ['m4_index(m5_ret, [''])'], ['['0']']), ['-1'], [''], ['m5_error(['$0 extracted a substring containing quotes. Use m5_dequote/m5_requote, perhaps. String: ']"m5_ret")'])m5_out(m5_ret)']))
m4_define(['m5_substr_eval'], m4_defn(['m4_substr'])['['']'])
m4_define(['m5_substr_inline'], m4_defn(['m4_substr']))

// Private macros to deal with the fact that m4_substr produces an unquoted result.

// Replace characters that can be problematic for elaboration with control characters.
// These include parentheses, underscore (to alter macro names), and quotes, detailed under
// "Use of control characters (surrogates) by M5".
// This function may be used with any string, including dequoted ones.
// The resulting string, and substrings of it, can be used without quotes with the assurance
// that it will be unaltered as long as all defined macros have a "m5" or "m5_" prefix and
// there are no control characters other than those used in this library in the original string.
// The safe string aligns character-for-character with the original, so string lengths, etc. are
// preserved.
// This mechanism is reversible (character-for-character) using m5_unsafe_string.
// Users should not require this functionality since M5 provides macros with quoted output.
// TODO: comma and comment??
m4_define(['m5__safe_string'],
   ['m4_translit(['$1'], ['()_/,['']'], ['['']'])'])
// Same as m5__safe_string, but verifies its safety (in current context).
m4_define(['m5__safe_string_with_check'],
   m5__scope(['m5_var(orig, ['$1'])m5_var(ret, m5__safe_string(['$1']))m5_var(restored_str, m5__unsafe_string(m5_eval(m5_ret)))m4_ifelse(m5_orig, m5_restored_str, [''], ['m5_error(['$0 produced a string that reverses to "']m5_restored_str['" which does not match the input string.'])'])m5_out(m5_ret)']))
m4_define(['m5__unsafe_string'],
   ['m4_translit(['$1'], [''], ['()_/,['']['']'])'])




// #############################
// Bodies

// =======================
// Scopes

// m5_out(<string>, ...)    // For use within the body of a function declared with m5_fn(..).
//                          // Appends quoted argument to function output string. Multiple arguments
//                          // will be concatinated (to enable splitting output over multiple lines).
// m5_out_nl(<string>, ...) // m5_out with a new line appended (to each argument).
// m5_eval_out(<string>)    // m5_out, where the output is to be evaluated, not literal. By convention,
//                          // this should be used as ~eval_out to highlight its impact on output, even
//                          // though the "~" has no effect. 
// m5_inline_out(<string>)  // like m5_eval_out, but the output evaluates together with subsequent
//                          // output text or text subsequent to the function call.
m4_define(['m5_out'],        ['m4_define(['m5_block_output'], m4_defn(['m5_block_output'])['['$1']'])m4_ifelse(m4_eval(['$# > 1']), 1, ['$0(m4_shift($@))'])'])
m4_define(['m5_out_nl'],     ['m4_define(['m5_block_output'], m4_defn(['m5_block_output'])['['$1']']m4_quote(m5_nl))m4_ifelse(m4_eval(['$# > 1']), 1, ['$0(m4_shift($@))'])'])
m4_define(['m5_inline_out'], ['m4_define(['m5_block_output'], m4_defn(['m5_block_output'])['$1'])'])
m4_define(['m5_eval_out'],   ['m5_inline_out(['$1['']'])'])




// #############################
// Declarations

// =======================
// Declaration Helpers

// Provides the body of a declaration macro.
//  $1: value expression
//  $2: [''] or the recursive macro name (without prefix) if the declaration macro should support a list.
// TODO: add checking of odd $# (when recursing).
m4_define(['m5__declare_body'],
   ['['m4_pushdef(['m5_']']m4_arg(1)[', ['$1'])m5_prepend_macro(_end_scope_expr, ['m4_popdef(['m5_']']']m4_dquote(m4_arg(1))['[')'])']m4_ifelse(['$2'], [''], [''], ['['m4_ifelse(m4_eval(']']m4_arg(#)['[' == 3), 1, ['m5_error(['$2 called with an odd number of arguments.'])'])m4_ifelse(m4_eval(']']m4_arg(#)['[' > 2), 1, ['m5_$2(m4_shift(m4_shift(']']']m4_dquote(m4_arg(@))['['[')))'])']'])'])
// Same as m5__declare_body, but for 'push' variants.
m4_define(['m5__declare_push_body'],
   ['['m4_pushdef(['m5_']']m4_arg(1)[', ['$1'])']m4_ifelse(['$2'], [''], [''], ['['m4_ifelse(m4_eval(']']m4_arg(#)['[' == 3), 1, ['m5_error(['$2 called with an odd number of arguments.'])'])m4_ifelse(m4_eval(']']m4_arg(#)['[' > 2), 1, ['m5_$2(m4_shift(m4_shift(']']']m4_dquote(m4_arg(@))['['[')))'])']'])'])

/**
// A pre-filter for declaration macros to quickly recognize whether a declaration might have a colon comment.
//  $1: {variable/macro/function} declaration type
//  $2: declared name with optional comment
//  $3: (opt) Default value
m4_define(['m5__doc_declare'],
   ['m4_ifelse(m4_index(['$2'], [':']), -1, ['['$2']'], ['m5__declare_full($@)'])'])

// Helper to process a declared name and optional comment. Result in the name.
// Same interface as m5__declare.
m4_define(['m5__declare_full'],
   ['m4_regexp(['$2'], ['\([a-zA-Z_\.]*\)\(: ?\)?\(.*\)'], ['m5__declare_guts(['$1'], ['\1'], ['\3'], ['$3'])'])'])

// Guts of m5__declare.
//  $1: {variable/macro/function} declaration type
//  $2: declared name
//  $3: description separator
//  $4: remaining (description) string
//  $5: (opt) default value
m4_define(['m5__declare_guts'],
   ['['$2']m4_ifelse(['$3']['$4'], [''],
                     [''],
                  ['$3'], [''],
                     ['m4_error(['Malformed $1 name/description argument: "$2$3$4".'])'],
                     ['m5__doc_declare(['$1'], ['$2'], ['$4'], ['$5'])'])'])

// A scoped declaration's pop expression.
m4_define(['m5__declare_end'],
   ['m5_prepend_macro(_end_scope_expr, ['m4_popdef(['$1'])'])'])
**/


// Push a macro definition.
// TODO: There's now a non-private version.
m4_define(['m5__push_macro'],
   ['m4_pushdef(['m5_$1'], ['$2'])m4_ifelse(m4_eval($# > 2), 1, ['$0(m4_shift(m4_shift($@)))'])'])
// Push a var definition.
m4_define(['m5__push_var'],
   ['m4_pushdef(['m5_$1'], ['['$2']'])m4_ifelse(m4_eval($# > 2), 1, ['$0(m4_shift(m4_shift($@)))'])'])
// Pop a list of macro names (with implied "m5_" prefix), to go with m5__push_macro/var(..)
m4_define(['m5__pop'],
   ['m4_popdef(['m5_$1'])m4_ifelse(m4_eval($# > 1), 1, ['$0(m4_shift($@))'])'])

// m5__pop_push(pop_var, push_var)
// Pops one var/macro and pushes the popped definition into another.
m4_define(['m5__pop_push'],
   ['m5__push_macro(['$2'], m4_defn(['m5_$1']))m5__pop(['$1'])'])


// =======================
// Variables

// Declare a scoped variable with a quoted definition.
m4_define(['m5_var'],
   m5__declare_body(m4_arg(2), var))
// Declare a universal variable.
m4_define(['m5_universal_var'],
   ['m4_ifdef(['m5_$1'], ['m5_error(['Redefining m5_$1.'])'])m4_define(['m5_$1'], ['['$2']'])'])
// Set a variable that has already been declared. E.g. m5_set(var, value).
m4_define(['m5_set'],
   ['m4_ifelse(m4_eval(['$# < 2']), 1,
               ['m5_error(['$0 given an odd number of arguments (or none).'])'])m4_ifdef(['m5_$1'], [''], ['m5_error(['Setting an undefined variable "$1".'])'])m4_define(['m5_$1'], ['['$2']'])'])
// Explicitly pushed/popped vars (use should be rare).
m4_define(['m5_push_var'],
   m5__declare_push_body(m4_arg(2), push_var))
// Pop a pushed macro (var/traditional-macro/function)
m4_define(['m5_pop'],
   ['m4_popdef(['$1'])m4_ifelse($2, [''], [''], ['m5_pop'])'])

// TODO: Define m5_var_str and m5_set_str.
// Convert var to string (enabling it to be accessed directly without $-substitutions by dequoting "$"s).
// The variable's value should contain no quotes.
//   $1: the variable to stringify.
m4_define(['m5_stringify'],
   ['m5_set_macro(['$1'], m4_patsubst(m4_dquote(m4_defn(['m5_$1'])), ['\$'], ['$']m5_close_quote()m5_open_quote()))'])
m4_define(['m5_var_str'],
   ['m5_var(['$1'], ['$2'])m5_stringify(['$1'])'])
m4_define(['m5_set_str'],
   ['m5_set(['$1'], ['$2'])m5_stringify(['$1'])'])

// Set a variable if it is empty.
m4_define(['m5_default'],
   ['m4_ifelse(m4_defn(['m5_$1']), ['['']'], ['m5_set(['$1'], ['$2'])'],
               m4_defn(['m5_$1']), [''], ['m5_error(['$0 setting "$1" which doesn't look like a var.'])'])'])

// Declare variables with [''] values.
// Args: list of variable names to declare.
m4_define(['m5_null_vars'],
   ['m4_ifelse($# > 0, 1, ['m5_var(['$1'], [''])m5_recurse(100, null_vars['']m5_comma_shift($@))'])'])

// Get the value of a variable.
// m5_value_of(foo) has the same effect as m4_foo except when the value contains argument strings such as "$1".
// This evaluates the variable definition, rather than expanding the variable. It also reports an error if the
// variable doesn't exist.
m4_define(['m5_value_of'],
   ['m5_ifdef(['$1'], ['m5_eval(m5_defn(['$1']))'], ['m5_error(['Can't get value_of non-existant variable "$1".'])'])'])


// =======================
// Traditional Macros

// TODO: Rename to m5_fast_fn???

// m5_macro(name, ['<body>'])
// Declare a macro. (See M5 spec.)
m4_define(['m5_macro'],
   m5__declare_body($['']2['['']'], ['']))

m4_define(['m5_set_macro'],
   ['m4_ifelse(m4_eval(['$# < 2']), 1,
               ['m5_error(['$0 given an odd number of arguments (or none).'])'])m4_ifdef(['m5_$1'], [''], ['m5_error(['Setting an undefined variable "$1".'])'])m4_define(['m5_$1'], ['$2'])'])

// m5_inline_macro(name, ['<body>'])
// A variant of m5_macro where the expansion is not separated from the subsequent text. (See M5 spec.)
m4_define(['m5_inline_macro'],
   m5__declare_body($['']2, ['']))

// Output nothing. This is used by m5_null_macro to evaluate without producing output.
m4_define(['m5__null'], [''])
// m5_null_macro(body).
m4_define(['m5_null_macro'],
   m5__declare_body(['m5__null($']['2)'], ['']))
// Explicitly pushed/popped macro (use should be rare). Inline/null versions not defined.
m4_define(['m5_push_macro'],
   m5__declare_push_body(m4_dollar(2), push_macro))


// \m5 region results in m5_region(['...']).
// m4_null should check emptiness.
m4_define(['m5__region'],
   ['m4_exec(['$1'])'])


// =======================
// Functions

// Binding bodies.

// The example below illustrates a function m5_if_neg that takes an argument that is a body to evaluate.
// The body is defined in a calling function, m5_my_fn. Such a body is expected to evaluate
// in the context of the calling function, m5_my_fn, meaning, its side effects should be side effects of
// m5_my_fn. If special care is not taken, its side effect (from m5_on_return) would
// be a side effect of m5_if_neg, not m5_my_fn, as expected. This can be addressed using
// m5_eval_body_arg, which captures the side effects of the body and passes them along to the
// caller.

// Note that my_fn could contain multiple nested m5_if_neg calles, and each would pass
// the side effect along, ultimately producing the side effect in m5_my_fn.
// Also note the distinction between body output and function side effects in that body output
// is associated with bodies, and function side effects are associated with functions. In order for
// body output to propogate to its calling function, each nesting level explicitly passes the
// output along using ~. Propogation is the responsibility of the caller, not the callee.

/// Example of a body argument.
///
/// // Evaluate a body if a value is negative.
/// fn(if_neg, value, body, {
///    ...
///       ~eval(m5_body)   /// Incorrect!!!
///       ~eval_body_arg(m5_body)   /// Correct.
///    ...
/// })
///
/// fn(my_fn, {
///    ~if_neg(1, [
///       on_return(...)
///       ~(...)
///    ])
/// })

// TODO: This will also pop/push m5_my.
// TODO: This could also be accomplished by popping aftermath into a temp, then pushing it after the call.
//       This would be consistent with the above todo.
m4_define(['m5_eval_body_arg'],
   ['m4_pushdef(['m5_fn__aftermath'], [''])['$2']m5_on_return(m5_value_of(fn__aftermath))m4_popdef(['m5_fn__aftermath'])'])


// Return values (in addition to the output text of the block):

// These are preferred over directly setting variables whose names are given due to possible masking (name collisions with local declarations).

// Set the return status of the current function. If called multiple times, the last has priority.
// With no arguments, m5_status is implied.
// If not called, status is explicitly preserved by the function.
m4_define(['m5_return_status'], ['m5_append_macro(fn__aftermath, m4_ifelse($#, 0, ['['m5_set(status, m5_status)']'], ['['m5_set(status, ['$1'])']']))'])
// Call a macro upon returning from a function. Arguments are those for m5_call.
// This is most often used to have a function declare or set a variable/macro as a side effect.
// It is also useful for tail recursion that does not grow the call stack.
m4_define(['m5_on_return'], ['m5_append_macro(fn__aftermath, ['m5_call($@)'])'])


// Evaluate $1 that should not produce any output other than whitespace and comments. No output is produced, and an error is reported if the evaluation was non-empty.
m4_define(['m5_exec'],
   ['m4_pushdef(['m4__out'], m4_patsubst(m4_dquote(m4_joinall([','], $1)), ['\(\s\|//[^']m4_nl]*m4_nl['\)'], ['']))m4_ifelse(m4_defn(['m4__out']), [''], [''], ['m4_warning(['Block contained the following unprocessed text: "']m4_defn(['m4__out'])['"'])'])m4_popdef(['m4__out'])'])


/// m5_fn uses this for the definitions it creates (function and its body).
/// It is used by m5_doc_as_fn to configure m5_fn for docs with low overhead.
m4_define(['m5__fn_def'], m4_defn(['m4_pushdef']))

// m5_fn(...)
// See docs.
//
// Implementation comments:
//
//   m5_fn(['foo'], ['param1'], ['param2: opt param2 desc'], ['Body using m5_param1, m5_param2, and $@.'])
//   Is processed recursively, one argument at a time to effectively create these definitions which provide parts
//   of a subsequent definition. Note that these cannot contain $ substitutions while being constructed, but must
//   evaluate to contain them:
//     m4_pushdef(['m4_push_named_args'], ['['['m4_pushdef(['m4_param1'], ']m4_arg(1)[')']']['['m4_pushdef(['m4_param2'], ']m4_arg(2)[')']']'])
//     m4_pushdef(['m4_dollar_args'], ['[',['$1'],['$3'],['<inheritted>']']'])   // for numbered arg
//     m4_pushdef(['m4_extra_args'], ['['['m4_shift(m4_shift(']']']['['m4_dollar(@)']']['['['))']']']    // if ... (via m4_varargs)
//                            -OR-   ['['['...m5_error(...)']']'])                                       // if no ..., print error except for case of 0 parameters and 1 empty arg
//     m4_pushdef(['m4_pop_named_args'], ['['m4_popdef(['m4_param1'])']['m4_popdef(['m4_param2'])']'])
//   And permanently defines:
//     m4_define(['m4_foo__body'], ['Body using m4_param1, m4_param2, and $@.'])
//   Then combines them as:
//     m4_define(['m4_foo'], m5_eval(m4_push_named_args)...)
//   And pops them.
//
m5_pragma_disable_paren_checks
m5_null_macro(fn, ['
      // Initialize for recursive arg processing.
      m4_ifelse(m4_index(['$1'], :), -1, [''], ['m5_error(['Function with a comment is deprecated: $1'])'])
      m4_pushdef(['m5_func_name'],         m4_regexp(['$1'], ['^\(\w*\)'], ['['\1']']))   /// TODO: Remove support for function comments (not param comments) (for better lazy performance).
      m4_pushdef(['m4_push_named_args'],   ['['']'])
      m4_pushdef(['m4_dollar_args'],       ['['']'])
      m4_pushdef(['m4_varargs'],           ['['m4_dollar(@)']'])
      m4_pushdef(['m4_extra_args'],        ['['['['']m4_ifelse(']']m4_dquote(m4_arg(#)['']m4_arg_cnt['']m4_arg(1))['[', ['10'], [''], ['m4_error(['Too many arguments (']']']']m4_dollar(#)['['['[') given to function "']']']']m5_func_name['['['['" which accepts ']']']']m4_arg_cnt['['['['.'])'])']']'])
      m4_pushdef(['m4_assign_outputs'],    ['['']'])
      m4_pushdef(['m4_pop_named_args'],    [''])
      m4_pushdef(['m4_arg_cnt'],           0)
      m4_pushdef(['m4_numbered_cnt'],      1)
      m4_pushdef(['m4_optional_found'],    0)
      m4_pushdef(['m4_required_arg_cnt'],  0)
      m4_define(['m4_fn__has_inherited'],  0)  /// A global, checked by lazy_fn after it constructs the function.

      m5_doc_fn__begin()
      
      // Recurse, processing params, and capturing body.
      m4_ifelse(m4_eval($# > 1), 1, ['m5_fn__recurse(m4_shift($@))'])
      // Process body.
      // Declare the function.
      /// TODO: Change m4_pushdef to m5_macro
      m5__fn_def(['m5_']m5_func_name,
                m5__concat(
                 ['m4_pushdef(['m5_status'], [''])'],   /// Give function its own status, so we can restore status on return.
                 ['m4_pushdef(['m5_fn__aftermath'],['m4_popdef(['m5_fn__aftermath'])['']'])'],
                 ['m4_ifdef(['m5_func_stack_top'], [''], ['m4_define(['m5_func_stack_header'], m4_dquote(['File "']m4___file__['", line ']m4___line__[' called:']))'])'],
                 ['m5_fn__push_stack(']m5_func_name[', ']m4_arg(@)[')'],
                 ['m4_ifelse(m4_eval(']m4_dollar(#)[' < ']m4_required_arg_cnt['), 1, ['m5_error(['Function ']']']m5_func_name['['[' requires ']']']m4_required_arg_cnt['['[' arguments; ']']']m4_dollar(#)['['[' given.'])'])'],
                 m5_eval(m4_push_named_args),
                 ['m5_eval(['m4_indir(['m4_']']']m5_func_name['['['__body']']'],
                   m4_defn(['m4_dollar_args']),
                   ['m4_ifelse(m4_eval(']m4_dollar(#)[' > ']m4_arg_cnt['), 1, ']m4_dquote(m4_dquote(m5_eval(m4_extra_args)))[')'],
                 ['[')'])'],
                 ['m5_fn__pop_stack()'],
                 m4_pop_named_args,
                 m5_eval(m4_assign_outputs),  /// TODO: This will be problematic if output variables are pushed with new values. These will be popped by body before we see them. So use m5_after and deprecate *output.
                 ['m4_popdef(['m5_status'])'],
                 ['m5_eval(m4_defn(['m5_fn__aftermath']))'],   /// Eval aftermath (without numbered parameter substitution). Note that aftermath pops itself first, so aftermath happens in the parent context.
                 ['']))
      m5_doc_fn__end()
      
      // Pop.
      m4_popdef(['m5_func_name'])
      m4_popdef(['m4_push_named_args'])
      m4_popdef(['m4_dollar_args'])
      m4_popdef(['m4_varargs'])
      m4_popdef(['m4_extra_args'])
      m4_popdef(['m4_assign_outputs'])
      m4_popdef(['m4_pop_named_args'])
      m4_popdef(['m4_arg_cnt'])
      m4_popdef(['m4_numbered_cnt'])
      m4_popdef(['m4_optional_found'])
      m4_popdef(['m4_required_arg_cnt'])
'])
m5_pragma_enable_paren_checks

// Helper for m5_fn that verifies that any text after parameter name is a comment.
m4_define(['m5_fn__param_comment'], ['
   m4_ifelse(m4_index(m5__param, [':']), 0, [''], ['
      // No colon to strip. Should be no comment.
      m4_ifelse(m5__param, [''], [''], ['
         m5_error(['In declaration of function "']m5_func_name['", $1 contains unrecognized text "']m5__param['".'])
      '])
   '])
'])


// TODO: m5_extract_prefix_eval evaluates comments, which can cause problems. Use m4_index of ":" to remove comment.

// Recursive guts of m5_fn for arg processing.
// ...: arg list
// Return quoted body (final arg quoted)
m4_define(
   ['m5_fn__recurse'],
   ['m4_ifelse(
      m4_eval($# <= 1), 1,
      ['m5__fn_def(['m4_']m5_func_name['__body'], ['m4_pushdef(['m5_fn_args'], ']m4_arg(@)[')$1['']m4_popdef(['m5_fn_args'])'])'],
      ['m4_ifelse(['$1'], [''],
                  ['m5_error(['In declaration of function ']m5_func_name[', empty function argument no longer permitted.'])'],
                  ['// First, look for ['...'].
                    m4_pushdef(['m5__param'], ['['$1']'])
                    m4_ifelse(m5_extract_prefix_eval(..., _param), ['...'], ['
                       m4_define(['m4_extra_args'], ['['[', ']']']m4_defn(['m4_varargs']))
                       m4_define(['m5__param_name'], ...)
                       m5_def(out_var_prefix, [''])
                       m4_def(optional_prefix, [''], cnt_prefix, [''])
                       m5_fn__param_comment(['parameter "..."'])
                       m5_doc_fn__param()
                    '], ['
                       // Extract possible '*', '?', '[<number>]', and/or '^' prefixes from argument value.
                       // TODO: These should be pushdef/popdef:
                       m5_def(out_var_prefix, m5_extract_prefix_eval(*, _param))  /// Deprecated.
                       m4_def(optional_prefix, m5_extract_prefix_eval(?, _param))
                       m4_def(cnt_prefix, [''])
                       m4_regexp(m5__param, ['^\[\([0-9]+\)\]\(.*\)'], ['m4_def(cnt_prefix, ['\1'])m4_define(['m5__param'], ['\2'])'])
                       m4_def(inherit_prefix, m5_extract_prefix_eval(^, _param))
                       m4_define(['m5__param_name'], m5_extract_prefix_regex(['\w*'], _param))
                       m5_fn__param_comment(['parameter "']m5__param_name['"'])   /// TODO: This should only be done in debug mode.
                       // Done processing m5__param. It's value is now its comment.
                       // * can't be combined with other prefixes.  TODO: * is deprecated.
                       m4_ifelse(m5_out_var_prefix, ['*'], ['m4_ifelse(m4_optional_prefix['']m4_cnt_prefix['']m4_inherit_prefix, [''], [''], ['m5_error(['Output parameter "']m5__param_name['" of function ']m5_func_name[' shouldn't have other prefix symbols.'])'])'])
                       // The parameter name or number for error messages.
                       m4_define(['m5__param_tag'], m4_ifelse(m5__param_name, [''], m4_cnt_prefix, m5__param_name))
                       // Verify that <name> or <number> is \w+.
                       m4_ifelse(m4_regexp(m5__param_tag, ['^\w+$']), -1, ['m5_error(['Bug: In declaration of function ']m5_func_name[', parameter has illegal name ']m5__param_tag['.']m5_nl[''])'])
                       m4_ifelse(m4_inherit_prefix, ^,
                                 ['// Inherited.
                                   m4_define(['m4_fn__has_inherited'], 1)
                                   // Must be defined unless optional.
                                   m4_ifelse(m4_optional_prefix, [''], ['m4_ifdef(['m5_']m5__param_name, [''], ['m5_error(['In declaration of function ']m5_func_name[', non-optional, inherited parameter ']m5__param_name[' is undefined.']m5_nl[''])'])'])'],
                                 ['// This parameter corresponds to an argument.
                                   // Document it.
                                   m5_doc_fn__param()
                                   m4_ifelse(m4_optional_prefix, ?,
                                             ['m4_define(['m4_optional_found'], 1)'],
                                             ['// Required.
                                               m4_define(['m4_required_arg_cnt'], m4_incr(m4_required_arg_cnt))
                                               m4_ifelse(m4_optional_found, 1,
                                                         ['m5_error(['In declaration of function ']m5_func_name[', parameter ']m5__param_tag[' follows an optional parameter, but is not itself optional.']m5_nl[''])'])
                                             ']
                                            )
                                   m4_define(['m4_arg_cnt'], m4_incr(m4_arg_cnt))
                                   // Exclude arg from varargs
                                   m4_define(['m4_varargs'], ['['['m4_shift(']']']m4_dquote(m4_varargs)['['[')']']'])'])
                       // Expression for the argument corresponding to this parameter (for named and/or numbered arg). E.g. ['$-3'] for non-inherited; m4_defn(['m5_<name>']) for inherited.
                       // Deltas for proc vs. func are applied later:
                       //    o non-inherited named args are quoted: e.g. ['['$-3']']
                       //    o inherited numbered args are evaluated: m4_<name>
                       m4_pushdef(['m4_func_arg'], m4_dquote(m4_ifelse(m4_inherit_prefix, ^,
                                                                       ['m4_dquote(m4_dquote(m4_defn(['m5_']m5__param_name)))'],
                                                                       ['['m4_arg(']m4_arg_cnt[')']'])))
                       // If this param is named, calls must push its value, quoted if (not ^) and proc.
                       m4_ifelse(m5__param_name, [''], [''], ['
                          m4_ifelse(m5_out_var_prefix, *, ['    /// TODO: * is deprecated.
                             /// Outputs are initialized by pushing their current value (or [''] if undefined), and finalized by copying into a new var named according to the argument.
                             m4_append(push_named_args, ['['m4_pushdef(['m5_']']']m5__param_name['[', m5_defn(['m5_']']']m4_func_arg['['))']'])
                             m4_append(assign_outputs, ['['m5_var(']']m4_func_arg['[', m5_']']m5__param_name['[')m4_popdef(['m5_']']']m5__param_name['[')']'])
                             /// Assign the parameter value to a new variable named according to the argument, and pop the parameter. Or, if the parameter name and argument name are the same, there's nothing to be done.
                             //+m4_ifelse(m4_func_arg, m4__param_name, [''], ['m4_append(assign_outputs, ['['m4_pushdef(['m5_']']']m4_func_arg['[', m5_defn(']']m5__param_name['['))m4_popdef(['m5_']']']m5__param_name['[')']'])'])
                          '], ['
                             m4_append(push_named_args, ['['m4_pushdef(['m5_']']']m5__param_name['[', ']']m4_ifelse(m4_inherit_prefix, [''], ['['m4_dquote(']m4_func_arg[')']'], ['m4_func_arg'])['[')']'])
                             m4_append(pop_named_args, ['m4_popdef(['m5_']']m5__param_name[')'])
                          '])
                       '])
                       // If this is a numbered param, confirm count and append arg to the call.
                       m4_ifelse(m4_cnt_prefix, [''], [''],
                                 ['m4_ifelse(m4_cnt_prefix, m4_numbered_cnt, [''],
                                             ['m5_error(['In declaration of function ']m5_func_name[', numbered parameters are out of sequence. Parameter given as '][m4_cnt_prefix][' should be '][m4_numbered_cnt]['.']m4_nl[''])'])
                                   m4_define(['m4_numbered_cnt'], m4_incr(m4_numbered_cnt))
                                   m4_str_append(dollar_args, m4_dquote([',']m4_ifelse(m4_inherit_prefix, ^, ['m4_defn(['m5_']']m5__param_name[')'], m4_func_arg)))'])
                       m4_popdef(['m4_func_arg'])
                       
                    '])
                    m4_popdef(['m5__param_name'])
                  '])
        m4_dquote($0(m4_shift($@)))
      '])
   '])
   

// Define m5_lazy_fn.
//
// Identical to m5_fn, except in performance. A lazy function waits to define the function
// until it is first called. Specifically, it records the function definition arguments and
// defines the function to use them to redefine and call itself. "^" params are not supported.
//
// Implementation: This defines a "maker" (whose definition can be evaluated to make the fn),
// then defines the fn to use the maker then call the made function.
// The maker body cannot be embedded in the lazy function itself because it may contain numbered parameters.
// The maker is given a globally unique name to simplify maintaining its association with this function given
// that this function can be on a stack, and the stack can contain a mix of lazy and non-lazy functions.
m4_define(['m5_lazy_fn'],
   m4_ifelse(m5_need_docs, ['yes'],   /// Defined prior to including library if docs are to be enabled.
      ['['m5_fn($@)']'],  /// Don't be lazy if we're creating docs.
      ['['m5_lazy_fn__guts(m4_regexp(['$1'], ['^\(\w*\)'], ['['\1']']), m4_shift($@))']']))   /// Strip docs from function name.
// Guts of m5_lazy_fn for non-documenation case.
// Same args as m5_lazy_fn, but without docs on function name.
m4_define(['m5_lazy_fn__guts'],
   ['m4_define(['m5_']m5__new_uniquifier, ['m5_fn($@)'])m4_pushdef(['m5_$1'], ['m4_popdef(['m5_$1'])m5_eval(m5_defn(']m5__same_uniquifier['))m4_ifelse(m4_fn__has_inherited, 1, ['m5_error(['Lazy function $1 has an inherited argument. This is not supported.'])'])m4_ifelse(']m4_dollar(#)[', 0, ['m5_$1'], ['m5_$1(']']m4_arg(@)['[')'])'])'])
/// m4_define(['m5_lazy_fn'], m5_defn(fn))  // Disable m5_lazy_fn for testing.


// Access a func argument by position from m5_fn_args.
// This is useful instead of e.g. $3 in function bodies within other function bodies.
m4_define(['m5_func_arg'], ['m4_argn($1, m5_fn_args)'])
// Number of arguments in m5_fn_args.
m4_define(['m5_fn_arg_cnt'],
   ['m4_ifelse(m4_len(m4_defn(['m5_fn_args'])), 0, ['0'], ['m5_nargs(m5_fn_args)'])'])



// #############################
// For manipulating arguments

// Number of arguments.
m4_define(['m5_nargs'], ['['$#']'])
// The nth argument (where the 2nd arg is arg 1).
// m4_argn(#, ...)
m4_define(['m5_argn'],
   ['m4_ifelse(['$1'], 1, ['['$2']'],
               ['m5_argn(m4_decr(['$1']), m4_shift(m4_shift($@)))'])'])
// For providing numbered arg references in nested macro bodies.
// m5_nquote_dollar(#, 1) is equivalent to ['['$#']'], which all evaluate to ['thing'].
m4_define(['m5_nquote_dollar'],
   ['m5_nquote(['$2'], ['$$1'])'])

// A variant of m5_shift that includes the preceding comma and thus differentiates no args from a single empty arg.
m4_define(['m5_comma_shift'],
   ['m4_ifelse(
       $#, 0,
          ['m5_error(['m5_comma_shift() called with no arguments.'])'],
       $#, 1,
          [''],
          [', m5_shift($@)'])'])

// Return the arguments. (Useful for processing parameters that are parenthesized argument lists.)
m4_define(['m5_args'], ['$@'])

// Verify that a macro has a minimum number of arguments.
// m5_verify_min_args(my_fn, 2, $#)
m4_define(['m5_verify_min_args'],
   ['m4_ifelse(m5_calc(['$3'] <  ['$2']), 1, ['m5_error(['$1 requires at least $2 arguments; given $3.'])'])'])
// Verify that a macro has the right number of arguments.
// m5_verify_num_args(my_fn, 2, $#)
m4_define(['m5_verify_num_args'],
   ['m4_ifelse(m5_calc(['$3'] != ['$2']), 1, ['m5_error(['$1 requires $2 arguments; given $3.'])'])'])

// Convert a quoted argument list to a list of arguments with a preceding comma.
// This is necessary to properly deal with zero arguments.
// E.g. m5_call(first['']m5_comma_args(['$@']), last)
m4_define(['m5_comma_args'],
   ['m4_ifelse(['$1'], [''], [''], [', $1'])'])
// m5_call_varargs(my_fn, arg1, ['$@'])
// M4 syntax for argument lists is inconvenient for passing zero arguments.
// This variant of m5_call has a final argument that is a list of 0 or more arguments.
m4_define(['m5_call_varargs'],
   ['m5_verify_min_args(['$0'], 2, $#)m5_call(m5_eval(m5_call_varargs__args($@)))'])
// Process args of m5_call_varargs into a quoted argument list for m5_call.
m4_define(['m5_call_varargs__args'],
   ['m4_ifelse($#, 2, ['['['$1']']m4_ifelse(['$2'], [''], [''], ['[',$2']'])'], ['['['$1'],']$0(m5_shift($@))'])'])

// Given a quoted arg list, produces a quoted arg list with the first arg removed.
// m5_shift_quoted(['['one'],['two']']) => ['['two']']
// Commonly: m5_call_varargs(my_fn, m5_shift_quoted(['$@']))
m4_define(['m5_shift_quoted'],
   ['m4_ifelse($#, 1, [''], ['m5_error(['$0 requires 1 argument; given $#.'])'])m4_ifelse(['$1'], [''], ['m5_error(['$0: Nothing to shift.'])'], ['m5_call(quote['']m5_comma_shift(m5_eval($@)))'])'])


// #############################
// Math

m4_define(['m5_calc'], m4_defn(['m4_eval']))



// #############################
// Regex

// Same as m4_regexp, but with quoted output.
m4_define(['m5_regex'],
   ['m4_regexp(['$1'], ['$2']m4_ifelse(m5_calc($# > 2), 1, [', m5_open_quote['$3']m5_close_quote']))'])

\m5
/// Declare variables initialized with [''] values.
lazy_fn(null_vars,
   ...: list of variable names to declare,
[
   if($# > 0, [
      var(['$1'], [''])
      recurse(100, null_vars['']m5_comma_shift($@))
   ])
])

// Declare variables assigned to subexpressions of a regular expression. Assign `status`, non-empty iff no match.
// TODO: Surround with \(\), and increment \#s in var_regex__match_str. This should be functionally equivalent,
//       but avoid M4 error if no match expressions. Also need to prevent () arg list from looking like a single null arg name.
//       Also, improve on this. Since there is not lazy match, it's hard to get preceding text. Do this by
//       adding \(.*\)$ only if no $ and surround this updated expression with \(\) assign the .* pattern to
//       m5_post; then compute m5_pre based on the length of the surrounding match. This is compute-heavy. 
lazy_fn(var_regex,
   string: the string to match,
   re: the Gnu Emacs regular expression,
   var_list: a list in parentheses of variables to declare for subexpressions,
{
   /// Make sure var_list is as expected.
   if_eq(m4_regexp(m5_var_list, ['^(.*)$']), ['-1'], ['m5_fatal_error(['Malformed argument var_list for function var_regex should be a list in parentheses. Value is "']m5_var_list['".'])'])
   var(exp_cnt, 0)  /// Count of regexp expressions.
   /// The function result for evaluation.
   var(rslt_expr, m4_regexp(m5_value_of(string), m5_value_of(re), ['['['']']']m5_quote(m5_eval(['m5_var_regex__match_str']m5_var_list))))   /// ['['['']']'] ensures non-empty if matched.
   if_null(rslt_expr, [
      set(rslt_expr, ['m5_null_vars$1'])
      return_status(no-match)
   ], [
      return_status()
   ])
   // TODO: Use m5_on_return now.
   ~eval_out(m5_value_of(rslt_expr))
   ///on_return(eval, m5_value_of(rslt_expr)))
})

// Process arguments to produce replacement string. E.g.
//   m5_var_regex__match_str(['foo'], ['bar'])
// becomes:
//   ['m5_var(['foo'], ['\1'])m5_var(['bar'], ['\2'])']
lazy_fn(var_regex__match_str, ..., [
   increment(exp_cnt)
   ~if($# > 0, [
      ~(['m5_var(['$1'], ']m5_quote(['\']m5_exp_cnt)[')'])
      ~recurse(100, var_regex__match_str['']m5_comma_shift($@))
   ])
])

// For chaining var_regex to parse text that could match a number of formats.
// Each pattern match is in its own scope. Return status is non-null if no expression matched.
// TODO: It's not okay to call a body from a function. on_return/return_status will return status from
//       this function, not from the funtion that calls this. Maybe we need a version of fn that doesn't
//       do aftermath (though this one needs it)?? Others are similar.
lazy_fn(if_regex,
   string: the string to match,
   re: the Gnu Emacs regular expression,
   var_list: a list in parentheses of variables to declare for subexpressions,
   body: the body to evaluate if the pattern matches,
   ...: ['additional repeated re, var_list, body, ... to process if pattern doesn't match'],
{
   return_status([''])  /// default
   var_regex(m5_value_of(string), m5_value_of(re), m5_var_list)
   ~if_so(['m5_eval(m5_body)'])   /// TODO: Use m5_eval_body_arg.
   ~else_if($# == 1, ['$1'])  /// else body
   ~else_if($# > 1, [
      /// recurse
      ~if_regex(m5_value_of(string), $@)
      /// propagate status
      return_status(m5_status)
   ])
   else([
      /// Nothing left to try.
      return_status(else)
   ])
})

macro(else_if_regex,
   ['m4_ifelse(m5_status, [''], [''], ['m5_if_regex($@)'])'])

macro(if_status,
   ['['$1']m5_if_so(m5_shift($@))'])
macro(else_if_status,
   ['m4_ifelse(m5_status, [''], [''], ['m5_if_status($@)'])'])


// Evaluate body for every pattern matching regex in the string. m5_status is unassigned.
lazy_fn(for_each_regex,
   string: the string to match (containing at least one subexpression and no `$`),
   re: the Gnu Emacs regular expression,
   [1]var_list: a (non-empty) list in parentheses of variables to declare for subexpressions,
   body: the body to evaluate for each matching expression,
{
   macro(tmp, ['$']['@'])
   var_regex(m5_value_of(string), m5_value_of(re)['\(.*\)'], (m5_tmp$1, remainder))
   ~eval(m5_body)    /// TODO: Use m5_eval_body_arg.
   if_neq(m5_value_of(remainder), [''], [
      on_return(for_each_regex, m5_value_of(remainder), m5_value_of(re), m5_var_list, m5_body)
   ])
})

fn(for_each_line, text, body, {
   /// Regex's do weird things with \n, so substitute them first.
   set(text, m5_translit(m5_value_of(text), m5_nl, ))
   /// Add a trailing \n if the last line is not empty.
   var_regex(m5_value_of(text), ['\([^]\)$'], (dummy))
   if_so([
      set(text, m5_value_of(text)[''])
   ])
   /// For each line, eval the body.
   ~on_return(for_each_regex, m5_value_of(text), ['^\([^]*\)'], (Line), ['m5_var(line, m5_value_of(Line))']m5_body)   /// TODO: Need to get creative with m5_eval_body_arg.
   /// TODO: Above, m5_line is assigned for backward-compatibility only for risc-v_defs.tlv.
})


// Strip trailing whitespace from variable.

fn(strip_trailing_whitespace_from, it, {
   set(m5_it, m5_substr(m5_eval(['m5_']m5_it), 0, m5_calc(m5_length(m5_eval(['m5_']m5_it)) - m5_length(m5_regex(m5_eval(['m5_']m5_it), ['\(\s*\)$'], ['\1'])))))
})



// ############################
// Utilities

// These are a bit more involved than macros in other categories and therefore are defined
// using M5, so they must appear after defining m5_fn.

\m5
   // Convert a hexadecimal (string of hex digits) number to decimal.
   lazy_fn(hex_to_int, digits, {
      var(val, 0)
      set(digits, m5_lowercase(m5_digits))
      loop(, [
         set(val, m5_calc(m5_val * 16))
         if_regex(m5_digits, ['^\([0-9]\)'], (digit), [
            increment(val, m5_digit)
         ], ['^\([a-f]\)'], (digit), [
            increment(val, m5_eval(['1']m5_translit_eval(m5_digit, ['abcdef'], ['012345'])))
         ], [
            error(['Illegal digit in hexadecimal value "']m5_digits['".'])
         ])
         // Next
         set(digits, m5_substr_inline(m5_digits, 1))
      ], ['m5_isnt_null(digits)'])
      ~val
   })
  



\m4


// #############################
// Libraries

// TODO: Libraries will support variants of m5_var and m5_macro that support comments/docs.
//       Doc support looks something like these:
//m4_define(['m5_export_macro'],
//   ['m4_pushdef(['m5_']m5__declare(macro, ['$1']), ['$2['']'])m5__declare_end(['$1'])'])


// Thoughts for Libraries
// ----------------------
//
// Looks clean, doable, efficient, and fairly robust. I like it.
//
//
// Example:
// \m5
//   use(math, ['http://...'])  /// Use library from URL in namespace math.
//   use(fp, [':um_floatingpoint_lib-v2.0.1'])   /// Use library from registered name.
//
//   
//   fn(dist, A, B, {
//      ~math(sqrt, m5_math(sq, m5_A), m5_math(sq, m5_B))
//   })
//
//   export(dist, math)
//
//
// Definitions:
//   - "entity": A function/variable/macro or namespace. Libraries define entities (in a hierarchy).
//   - "namespace": A collection of entities (by reference).
//   - "library namespace": A explicity namespace assigned to a library upon inclusion.
//   - "library ID": A unique global identifier generated for the global namespace of a library. (Null for the M5 library itself.)
//   - "entity ID": A unique global identifier generated for an entity, composed of a library ID and the entity name.
//     The entity is a macro whose name is directly mappable to its entity ID.
//
// Data structures:
//   - Current namespace.
//   - A hash of library URLs to library IDs.
//   - For each library ID, a list of all entities (by name) defined by the library.
//     This does not include entities from sublibraries.
//   - For each library ID, a mapping of all exported entity names provided by the library. Functions
//     and namespaces can be exported, but not variables. Libraries can also export the exports of their
//     sublibraries (if not exported via a namespace) (mechanism TBD).
//   - For each namespace, a mapping of all entity names exported into the namespace to their entity IDs. This
//     has the same format as the library ID mapping of exported entities.
//
// Approach:
//   - Libraries provide exports. Library inclusion defines entities named for reference by library ID.
//     This namespace may be [''] or the same namespace as other library inclusions (but this is not recommended).
//     References to all exports of the library (functions that call the versions indexed by library ID)
//     are added to this namespace. Individual mappings may also be provided, mapping specific exports to other namespaces.
//   - Namespace definitions are lazy.
//   - The M5 library ID is null, mapping entity names 1-to-1 with entity IDs, enabling entities to be called
//     directly from any library. The M5 library includes an M5 namespace library that defines top-level namespaces (that may
//     lazily provide sub-namespaces).
//   - Conflicts can arise if libraries are loaded into the same namespace. When a conflict arises, a warning is reported, and the
//     conflicting entity is replaced by m5_error(...), so uses result in errors.
//   - Namespace names will generally contain a version number or numbers.
//   - Each library has a default namespace name. (? - but this isn't visible on the inclusion line, so...)
//   - Within a library (or always?), only the core M5 macros/variables/functions can be called directly.
//   - Macros/variables/functions defined in (non-core) libraries must be
//     called indirectly as m5_<namespace>(<fn>, <args>).
//   - Each export embeds its library ID, and calls use it. Each call is done though an optional
//     path of namespaces. This path is followed recursively starting from the library ID, then through namespaces
//     and then the function is called (either via the library ID if no path, or via the namespace). Other entities
//     are also references by first unrolling a namespace path. The call, ...??


/** Proposal for addressing masking:
Definitions within a namespace: lowercase+underscore, including:
  - M5 library (null namespace)
  - Library exports
  - Namespaces
Scoped macros: PascalCase
  - Most often, variables, but any scoped macros.
Private definitions: _ prefix
  - Must be used for scoped values in macros that evaluate body arguments to avoid masking,
    or evaluate body (and anything after it) on_return.

Library exports are namespaced or collision-checked.

A current namespace ID is maintained (in a stack).
Call to local (same library) macro "foo": m5_my(foo, args). Needs library support; add m5_my() definition to m5_fn.
Call to a macro "foo" in a namespace "bar": m5_my(bar/foo, args) (which is syntactic sugar for m5_my(bar, foo, args))
sets m5_my() to use bar's namespace, then calls m5_my(foo, args).
Namespace bar is a function that encapsulates its namespace ID in order to call functions of the namespace
(prefixed by namespace ID) which redirect to the functions indexed by Library ID.
Bodies must be bound to the caller, so body calls should pop m5_my, call, push m5_my.
**/


\m4
/// Declarations of null and minimal documentation functions.
/// m5_enable_doc can be used to enable docs.
m4_define(['m5_null_fns'],
   ['m4_define(['m5_$1'], m4_defn(['m4_nullify']))m4_ifelse($# > 1, 1, ['m5_null_fns(m5_shift($@))'])'])

m5_null_fns(doc_fn__begin, doc_fn__begin__adoc, doc_fn__end, doc_fn__end__adoc, doc_fn__param, doc_fn__param__adoc)

m4_define(['m5_doc_macro'], ['m5_call(m5_shift($@))'])

// #############################
// Auto-documentation

// TODO: This should be moved into a library.

/// A version of m5_fn that doesn't actually declare the function macro used to produce docs for non-function
/// macros non-destructively.
m4_define(['m5__doc_only_fn'], ['m4_pushdef(['m5__fn_def'], m5_defn(nullify))m5_fn($@)m4_popdef(['m5__fn_def'])'])

\m5

lazy_fn(indent_text_block, Ind, Text, {
   ~for_each_line(m5_value_of(Text), [
      ~([' ']m5_value_of(Line))
   ])
})

// Returns a comma separated list of macros (which must be defined).
lazy_fn(doc_macro__see_also, Macro, ..., {
   ~if_def(Macro, [
     ~([', `m5_']m5_Macro['`'])
   ], [
      error(['"See also" macro "']m5_Macro['" isn't defined.'])
   ])
   ~if($# >= 1, ['m5_doc_macro__see_also($@)'])
})

// Enable function prototype documentation.
// This should be called prior to declarations.
//
// This creates public and private macros in the universal namespace (though future versions of M5 are
// likely to move them into their own namespace).
//
// Public: doc, enable_doc
// Private: doc_fn__*
//
// For AsciiDoc:
// The function spec can be generated by calling m5_doc_macro__adoc__<name>(['<opt-additional-func-desc-body>']).
//
// Function declarations call m5_doc_macro (optionally), m5_doc_fn__begin(), m5_doc_fn__param() (repeat), and m5_doc_fn__end().
// By default they are null.
// This defines them, specific to the given doc format.
// It also disables lazy definition by assigning lazy declaration macros to equal their non-lazy counterparts.
lazy_fn(enable_doc,
   Format,
{

   /// Translate a block of text in this format ['
   ///  D: Removes the first argument.
   ///  O: a list of remaining arguments, or `['']` if less than two arguments
   ///  S:
   ///  E: foo(m5_shift($']['@))
   ///  A: section1 m_comma_shift
   /// ']
   /// into m5_doc_fn__desc/post_desc.
   fn(doc_macro__adoc__process_macro_desc, Text, {
   
      /// Decompose into D, O, S, E, A variables.
      null_vars(Section, D, O, S, E, A)
      def(doc_fn__desc, [''])
      def(doc_fn__post_desc, [''])
      for_each_line(m5_value_of(Text), {
         /// Process section identifier.
         var(IsStart, 0)  /// [0/1] Start a section.
         if_regex(m5_value_of(Line), ['^\([DOSEA]\): ?\(.*\)'], (NewSection, Remainder), [
            set(IsStart, 1)
            set(Section, m5_NewSection)
            set(Line, m5_value_of(Remainder))
         ])
         /// Add line to section.
         if_neq(m5_Section, [''], ['m5_append_var(m5_Section, m5_value_of(Line))'])
      })
      
      /// Combine fields into m5_doc_fn__desc/post_desc in ASCIIDoc.
      set(doc_fn__desc, *[
         ~if_neq(m5_value_of(D), [''], ['['- *Description*: ']m5_value_of(D)m5_nl()m5_nl'])
         ~if_neq(m5_value_of(O), [''], ['['- *Output*: ']m5_value_of(O)m5_nl()m5_nl'])
         ~if_neq(m5_value_of(S), [''], ['['- *Side Effects*: ']m5_value_of(S)m5_nl()m5_nl'])
         ~if_neq(m5_value_of(E), [''], ['['- *Example(s)*:']m5_nl()m5_nl()m5_indent_text_block([' '], m5_value_of(E)m5_nl)m5_nl()m5_nl'])
         ~if_neq(m5_A, [''], [
            ~(['- *See also*: '])
            ~substr(m5_eval(['m5_doc_macro__see_also']m5_A), 2)
         ])
      ])
   })

   /// Provide description for, then declare a function.
   /// Description is captured universally in m5_doc_macro__<Format>__<Name>.
   /// E.g.:
   /// doc_fn(['
   ///  D: Removes the first argument.
   ///  O: a list of remaining arguments, or `['']` if less than two arguments
   ///  S: None
   ///  E: foo(m5_shift($']['@))
   ///  A: section1 m_comma_shift
   /// ']), shift, ..., ['
   ///    ...
   /// '])
   fn(doc_fn, Name, Desc, ..., ^Format, {
      call(['doc_macro__']m5_Format['__process_macro_desc'], m5_value_of(Desc))
      fn(m5_Name, m5_fn_args)
   })
   /// Document a macro or macros that were already defined, using the same interface as doc_fn.
   fn(doc_as_fn, Name, Desc, ..., ^Format, {
      if_def(m5_Name, [
         call(['doc_macro__']m5_Format['__process_macro_desc'], m5_value_of(Desc))
         _doc_only_fn(m5_Name, m5_fn_args, ['<<dummy-body>>'])
      ], [
         error(['No macro "']m5_Name['" to document.'])
      ])
   })
   

   /// Like doc_as_fn, but a set of macros is documented together, each having been documented already,
   /// though only for their parameter lists, which may be a subset of the parameters provided to this
   /// function. Otherwise, the call to this function provides all documentation, including the superset
   /// parameter list. All parameter lists should use consistent names.
   fn(doc_as_fns,
      SetName: ['a name for this set of functions, where resulting docs will be in doc_macro__<Format>__<SetName>'],
      Names: ['a quoted list of names'],
      Desc,
      ...,
      ^Format,
   {
      /// Extract prototypes and assign the set to doc_macro__<Format>__<SetName>
      var(Separator, [''])
      var(Protos, [''])
      for(Name, m5_Names, [
         /// Extract prototype from this macro's docs.
         if_def(['doc_macro__']m5_Format['__']m5_Name, [
            var(Doc, m5_value_of(['doc_macro__']m5_Format['__']m5_Name))
            set(Proto, m5_regex(m5_value_of(Doc), ['\(`.*`\)'], ['\1']))
            if_eq(Proto, [''], [
               error(['Unable to extract prototype from docs of ']m5_Name.)
            ], [
               append_var(Protos, m5_Separator, m5_Proto)
               set(Separator, m5_nl)
            ])
         ], [
            error(['No documentation for doc_macro__']m5_Format['__']m5_Name.)
         ])
         
         append_var(doc_fn__desc, [''])
      ])
      
      /// Document this set of functions.
      call(['doc_macro__']m5_Format['__process_macro_desc'], m5_value_of(Desc))
      fn(m5_SetName, m5_fn_args)
      
      /// Replace SetName's prototype (first line of its docs) with the set prototypes.
      var(NewDocs, [''])
      set(NewDocs, [
         ~for_each_line(['doc_macro__']m5_Format['__']m5_Name, [
            ~if_null(NewDocs, m5_Protos, m5_Line)
            ~nl
         ])
      ])
      set(['doc_macro__']m5_Format['__']m5_Name, m5_value_of(NewDocs))
   })


   // AsciiDoc-format Functions:
   
   // Pushes a bunch of variables that are updated for each parameter and popped by m5_doc_fn__end__adoc.
   fn(doc_fn__begin__adoc,
      Name,
   {
      push_macro(doc_fn__name, m5_Name)
      push_macro(doc_fn__unnamed_cnt, 0)
      push_macro(doc_fn__comma, [''])
      push_macro(doc_fn__params, [''])
      push_macro(doc_fn__descs, [''])
   })
   
   // Called for each param if adoc format.
   fn(doc_fn__param__adoc,
      ParamName, OptionalPrefix, Desc,
   {
      /// Provide a name for an unnamed parameter.
      if_null(ParamName, [
         increment(doc_fn__unnamed_cnt)
         set(ParamName, <unnamed-m5_doc_fn__unnamed_cnt>)
      ])
      /// Append this parameter to parameter list.
      append_var(doc_fn__params, m5_doc_fn__comma['']m5_ParamName)
      /// Append to parameter descriptions.
      append_var(doc_fn__descs, *[
         ~(['** `']m5_ParamName['`'])
         ~if_eq(m5_OptionalPrefix, ?, ['(opt)'])
         ~Desc
         ~nl
      ])
      set(doc_fn__comma, [', '])
   })
   
   /// End AsciiDoc function.
   /// Declares doc_macro__adoc__<name> (where <name> is in m5_doc_fn__name) that generates ASCIIDoc
   /// content for this function based on transient definitions in:
   /// m5_doc_fn__<X>, where <X> is:
   ///   - name
   ///   - params: list of parameters
   ///   - descs: list of parameters with descriptions
   ///   - desc: (opt) ASCIIDoc macro description
   ///   - post_desc: (opt) ASCIIDoc to appear after parameter descriptions (example, see also)
   /// Then deletes definitions.
   fn(doc_fn__end__adoc, <adoc>{
      def(['doc_macro__adoc__']m5_doc_fn__name, m5_quote(*[
         ~(['`m5_']m5_doc_fn__name['(']m5_doc_fn__params[')`'])
         ~if_def(doc_fn__desc, [
            ~nl(m5_nl)
            ~value_of(doc_fn__desc)
            pop(doc_fn__desc)
         ])
         ~if_def(['doc_macro__adoc__']m5_doc_fn__name, ['m5_nl()m5_nl()m5_value_of(['doc_macro__adoc__']m5_doc_fn__name)'])  /// TODO: Delete me
         ~nl(m5_nl)
         ~(['- *Parameters*:'])
         ~nl(m5_nl)
         ~value_of(doc_fn__descs)
         ~if_def(doc_fn__post_desc, [
            ~nl(m5_nl)
            ~value_of(doc_fn__post_desc)
            pop(doc_fn__post_desc)
         ])
      ]))
      ///DEBUG(Defined doc_macro__adoc__['']m5_doc_fn__name as: m5_eval(['m5_doc_macro__adoc__']m5_doc_fn__name))
      pop(doc_fn__name)
      pop(doc_fn__unnamed_cnt)
      pop(doc_fn__comma)
      pop(doc_fn__params)
      pop(doc_fn__descs)
   })
   
   
   // Functions to call format-specific functions.
   // These use m5_push_macro rather than m5_fn because their definitions affect m5_fn.
   
   // Call doc_fn__begin__<Format>.
   // Assume m5_func_name is defined in context.
   push_macro(doc_fn__begin, <b>[
      ~call(['doc_fn__begin__']<b>m5_Format[''], m5_func_name)
   ])
   
   // For processing parameters.
   // Assumes evaluation in context with ['m5__param_name, m4_optional_prefix, m4_cnt_prefix, and m5__param (comment string)'].
   push_macro(doc_fn__param, <p>[
      call(['doc_fn__param__']<p>m5_Format[''], m5__param_name, m4_optional_prefix, m5__param)
   ])

   // Assume ['m5_func_name'] defined in context.
   push_macro(doc_fn__end, <e>[
      call(['doc_fn__end__']<e>m5_Format[''])
   ])
   
   // Disable lazy functions.
   push_macro(lazy_fn, m5_defn(fn))
   
})



\m4
// #############################
// Development and Debug

m4_define(['m5_TBD'], ['m4_warning(['Reached unwritten code.'])'])







// M5
//
// These are to become M5.
//


// Extract a value from a variable's stack. Return [''] if beyond the stack.
m4_define(['m5_value_ago'],
   ['m4_ifdef(['m5_$1'], ['m4_ifelse(m4_eval(['$2 <= 0']), 1,
              ['m5_$1'],
              ['m4_pushdef(['m5_$1__reverse'], m4_defn(['m5_$1']))m4_popdef(['m5_$1'])$0(['$1'], m4_eval(['$2 - 1']))m4_pushdef(['m5_$1'], m4_defn(['m5_$1__reverse']))m4_popdef(['m5_$1__reverse'])'])'])'])

// Expression that begins scope by pushing m5__end_scope_expr with [''].
// (Other popping expressions are prepended to m5__end_scope_expr by variable definitions.)
m4_define(['m5__begin_scope'],
   ['m4_pushdef(['m5__end_scope_expr'], [''])'])
// Expression that ends scope by evaluating m5__end_scope_expr and popping it.
m4_define(['m5__end_scope'],
   ['m5__end_scope_expr['']m4_popdef(['m5__end_scope_expr'])'])
// Top-level scope:
m5__begin_scope()


// String comparison.
// Compare strings for equality.
m4_define(['m5_eq'],
   ['m4_ifelse(['$1'], ['$2'], 1, 0)'])
// Compare strings for inequality.
m4_define(['m5_neq'],
   ['m4_ifelse(['$1'], ['$2'], 0, 1)'])

// Arithmetic functions.
// Set a variable to the result of an arithmetic expression.
m4_define(['m5_equate'],
   ['m5_set(['$1'], m5_calc(['$2']))'])
// Perform an arithmetic operation on variable holding an integer value. E.g. m4_operate_on(cnt, ['*2']).
m4_define(['m5_operate_on'],
   ['m5_equate(['$1'], m5_$1[' $2'])'])
// Increment a variable holding an integer value. Optionally, a second argument
// provides an increment amount. E.g. m4_increment(total, 5)
m4_define(['m5_increment'],
   ['m5_operate_on(['$1'], ['+ ']m4_ifelse(['$2'], [''], ['1'], ['['$2']']))'])
// Increment a variable holding an integer value. Optionally, a second argument
// provides an decrement amount. E.g. m4_decrement(total, 5)
m4_define(['m5_decrement'],
   ['m4_operate_on(['$1'], ['- ']m4_ifelse(['$2'], [''], ['1'], ['['$2']']))'])

// Scope.
// Constructs supporting scope include:
//   o m4_func/proc
//   o m4_if/ifelse/else
//   o m4_block
//   o m4_loop/repeat/for

// m5_loop((var_name, value, ...), do_block, while_cond, ?while_block)
// m5_loop((my_var, 0), ['
//    do_stuff(...)
// '], ['m5_loop_cnt < 10'], ['
//    do_more_stuff(...)
// '])
// Implicit variable m5_loop_cnt starts at 0 and increments by 1 with each iteration (after both blocks).
m4_define(['m5_loop'],
   ['m4_ifelse(m5_calc(($# < 3) || ($# > 4)), ['1'], ['m5_error(['$0 requires 3 or 4 arguments.'])'])m5_var(loop_cnt, 0)m4_ifelse(['$1'], [''], [''], ['m5_var$1'])['']$2['']m5_loop__body(m4_shift($@))'])
m4_define(['m5_loop__body'],
   ['m4_ifelse(m4_eval(m5_loop_cnt > 1000), 1, ['m5_error(['Loop with while expression ['$2'] reached max of 1000 iterations.'])'])m4_ifelse(m4_eval($2), 1, ['$3['']m5_increment(loop_cnt)$1['']$0($@)'])'])

// m4_repeat(10, ['
//    m4_do_stuff(...)
// '])  // Iterates m5_loop_cnt 0..9.
m4_define(['m5_repeat'],
   ['m5_loop([''],
        [''],
     ['m5_loop_cnt < ['$1']'],
        ['$2'])'])

// m4_for(fruit, ['apple, orange, '], ['
//    m4_do_stuff(...)
// '])  // (also maintains m5_loop_cnt)
// A final empty arg in the $2 list will be ignored.
// m4_for__guts(var, body, garbage, remaining-args...)   // (Use of "garbage" prevents having an empty arg in last iteration.)
m4_define(['m5_for__guts'],
   ['m4_ifelse(m4_eval($# > 4 || ($# == 4 && m5_neq(['$4'], ['']))), 1, ['m5_var(['$1'], ['$4'])$2['']m5_increment(loop_cnt)m5_for__guts(['$1'], ['$2'], m4_shift(m4_shift(m4_shift($@))))'])'])
m4_define(['m5_for'],
   ['m5_push_var(loop_cnt, 0)m5_for__guts(['$1'], ['$3'], [''], $2)['']m5_pop(loop_cnt)'])


\m4

// An if/else construct. The condition is an expression that evaluates to an integer (generally boolean (0/1)).
// The first block is evaluated if the condition is not 0, otherwise, subsequent conditions are evaluated,
// or if only one argument remains, it is the final else block, and it is evaluate.
// The block that is evaluated is evaluated in its own scope.
// Return status is set, empty iff a block was evaluated.
// E.g:
//    m4_if(m4_eq(m4_ten, 10) && m4_val > 3, ['
//       m4_do_something(...)
//    '], m4_condition, ['
//       m4_do_something_else(...)
//    '], ['
//       m4_default_case(...)
//    '])
m4_define(['m5_if'],
   ['m4_ifelse(m4_eval(['$1']), 0,
               ['m4_ifelse(m4_eval($# <= 3), 1,
                           ['$3['']m5_set(status, m4_ifelse($#, 3, [''], ['else']))'],
                           ['m5_if(m4_shift(m4_shift($@)))'])'],
               ['$2['']m5_set(status, [''])'])'])
// A short form of m5_if(m5_eq(...), ...).
// if $1 eq $2, then $3, or
// if $1 eq $2, then $3, else $4, or
// if $1 eq $2, then $3, else if $4 eq $5, then $6, etc.
// Status is set, non-empty if no body given for the non-eq case.
m4_define(['m5_if_eq'],
   ['m4_ifelse(['$1'], ['$2'],
        m4_ifelse(m5_calc($# < 3), 1,
           ['m5_error(['No eq body given for m5_if_eq.'])['']'],
           ['['$3['']m5_set(status, [''])']']),
        m4_ifelse(
           m5_calc($# < 4), 1,
              ['['m5_set(status, else)']'],
           $#, 4,
              ['['$4['']m5_set(status, [''])']'],
              ['m5_shift(m5_shift(m5_shift($@)))']))'])
m4_define(['m5_ifeq'], ['m5_deprecated()']m4_defn(['m5_if_eq']))
m4_define(['m5_if_neq'],
   ['m4_ifelse($#, 3, ['m5_if_eq(['$1'], ['$2'], ['m5_set(status, ['else'])'], ['$3['']m5_set(status, [''])'])'], ['m5_error(['$0 requires exactly three arguments; $# given.'])'])'])
m4_define(['m5_ifne'], ['m5_deprecated()']m4_defn(['m5_if_neq']))


// Similar to m5_if, but each condition is an eq comparison with the same case_var.
// m5_case(case_var, value1, block1[, value2, block2[, ...]][, default_block])
m4_define(['m5_case'],
   ['m4_ifelse(
        m5_calc($# <= 2), 1,
           ['m4_ifelse(m5_calc(['$# > 1']), 1,
                       ['$2['']m5_set(status, [''])'],
                       ['m5_set(status, else)'])'],
           ['m4_ifelse(
               ['$1'],
               ['$2'],
               ['$3['']m5_set(status, [''])'],
               ['$0(['$1']m5_comma_shift(m4_shift(m4_shift($@))))'])'])'])

// Do something if m5_status isn't [''] and given condition calculates to tru.
m4_define(['m5_else_if'],
   ['m4_ifelse(m5_status, [''], [''], ['m5_if($@)'])'])
// Do something if m5_status isn't ['']. Set status to [''].
// This can follow on to any macro that sets status, such as m5_if*, m5_case, m5_var_regex, etc.
m4_define(['m5_else'],
   ['m4_ifelse(m5_status, [''], [''], ['$1['']m5_set(status, [''])'])'])
// Do something if m5_status is ['']. Status is explicitly preserved from its initial state.
// This can follow on to any macro that sets status, such as m5_if*, m5_case, m5_var_regex, etc.
m4_define(['m5_if_so'],
   ['m4_ifelse(m5_status, [''], ['$1['']m5_set(status, [''])'])'])
// If a variable is null.
m4_define(['m5_if_null'],
   ['m5_must_exist(['$1'])m5_if_eq(m5_$1, [''], ['$2']m4_ifelse(m5_calc($# >= 3), 1, [', ['$3']m4_ifelse(m5_calc($# > 3), 1, ['m5_error(['Too many arguments to $0.'])'])']))'])
m4_define(['m5_ifdef'], ['m5_deprecated()m4_ifdef(['m5_$1'], m5_shift($@))'])
m4_define(['m5_if_def'],
   ['m5_if(m4_ifdef(['m5_$1'], 1, 0), ['$2']m4_ifelse(m5_calc($# >= 3), 1, [', ['$3']m4_ifelse(m5_calc($# > 3), 1, ['m5_error(['Too many arguments to $0.'])'])']))'])
m4_define(['m5_if_ndef'],
   ['m5_if(m4_ifdef(['m5_$1'], 0, 1), ['$2']m4_ifelse(m5_calc($# >= 3), 1, [', ['$3']m4_ifelse(m5_calc($# > 3), 1, ['m5_error(['Too many arguments to $0.'])'])']))'])
m4_define(['m5_else_if_def'],
   ['m4_ifelse(m5_status, [''], [''], ['m5_if_def($@)'])'])
m4_define(['m5_must_exist'],
   ['m5_if_ndef(['$1'], ['m5_error(['Macro "$1" does not exist.'])'])'])


// #############################
// Deprecated

m5_set_report_max(deprecated, 2)
m4_define(['m5_deprecated'],
   ['m5_warning(['Deprecated macro $1.'], deprecated)'])

// =======================
// Compatibility

// These macros are equivalent to their M4 counterparts to assist with conversion, but they are deprecated.

m4_define(['m5_def_body'],
          ['m4_ifelse(m4_eval($# < 5$3), ['1'],
                      ['m5_error(['Missing or extra arg in macro definition.'])'],
                      ['m4_$2(['m5_$4'], ['$5'])m4_ifelse(m4_eval($# > 5$3), ['1'],
                                                          ['m5_$1(m4_shift(m4_shift(m4_shift(m4_shift(m4_shift($@))))))'],
                                                          ['['$6']'])'])'])
m4_define(['m5_def'],
          ['m5_deprecated(['$0'])m5_def_body(['def'], ['define'], [''], m4_process_description($@))'])
m4_define(['m5_default_def'],
   ['m5_deprecated(['$0'])m5_def_body(['default_def'], ['default'], [''], m4_process_description($@))'])



// #############################
// TL-Verilog Hardware-specific

// TODO: Create a library for these.

// Strip the prefix from an identifier.
m4_define(['m5_strip_prefix'], ['m4_patsubst(['$1'], ['^\W*'], [''])'])

// m5_stage_eval(expr)
// Evaluates expr with:
//   '@' stripped,
//   '<<' -> ' - '
//   '>>' -> ' + '
//   '<>' -> ' + '
// Eg:
//   @m4_stage_eval(@(2-1))
//   @m4_stage_eval(@2<<1)
//   >>m4_stage_eval((@2 - @1)<<1)
m4_define(['m5_stage_calc'],
   ['m4_eval(m4_patsubst(m4_dquote(m4_patsubst(m4_dquote(m4_patsubst(m4_dquote(m4_patsubst(['['$1']'], ['@'], [''])), ['>>'], [' + '])), ['<<'], [' - '])), ['<>'], [' + ']))'])

// m5_align(signal's_from_stage, signal's_into_stage)
// Provides an ahead alignment identifier value (which can be negative), to consume from from_stage into to_stage.
// Eg:
//   >>m4_align(@2, @1-1)  ==>  >>2
m4_define(['m5_align'], ['m4_stage_eval(($1) - ($2))'])



// Range declarations.
// TODO: Should have push/pop variants of these (to replace these).

// Determine the number of bits required to hold the given binary number.
// (aka, the max 1 position +1; aka floor(lg2(n))+1)
m4_define(['m5_binary_width'], ['m4_ifelse(m4_eval(['$1']), 0, ['0'], ['m4_eval($0(m4_eval((['$1']) >> 1)) + 1)'])'])

\m5
// Define TLV behavioral hierarchy range (which can be reused multiple places in the TL-X hierarchy) and
// define related range constants, including all vector constants for:
//   o the hierarchy's range
//   o the range of indexes into the hierarchy
//   o the range of counts of a number of indices
//
// For example, eight cores might have definitions like:
//   /core[7:0]
//   $core_index[2:0]  // 7..0
//   $num_active_cores[3:0]  // 8..0
// and this macro defines all the related constants for these definitions, so:
//   m5_define_hier(CORE, 8)
//   \m5_CORE_HIER
//   $core_index[m5_CORE_INDEX_RANGE]
//   $num_active_cores[m5_CORE_CNT_RANGE]
//
// Another example:
// m5_define_hier(SCOPE, 10, 2) defines
//   m5_SCOPE_HIER = scope[9:2]
//   For the range of SCOPE:
//     m5_SCOPE_MAX = 9
//     m5_SCOPE_MIN = 2
//     m5_SCOPE_HIGH = 10
//     m5_SCOPE_LOW = 2
//     m5_SCOPE_CNT = 8
//     m5_SCOPE_RANGE = 9:2
//   For the range of indexes into scope[9:2] (e.g. $scope_index[3:0])
//     m5_SCOPE_INDEX_MAX = 3
//     m5_SCOPE_INDEX_MIN = 0
//     m5_SCOPE_INDEX_HIGH = 4
//     m5_SCOPE_INDEX_LOW = 0
//     m5_SCOPE_INDEX_CNT = 4
//     m5_SCOPE_INDEX_RANGE = 3:0
//   For the range of counts of scopes (supporting counts from m5_SCOPE_CNT..0).
//     m5_SCOPE_CNT_MAX = 3
//     m5_SCOPE_CNT_MIN = 0
//     m5_SCOPE_CNT_HIGH = 4
//     m5_SCOPE_CNT_LOW = 0
//     m5_SCOPE_CNT_CNT = 4
//     m5_SCOPE_CNT_RANGE = 3:0
fn(define_hier, scope, high, ?low, [
   define_vector(m5_scope, m5_high, m5_low)
   define_vector(m5_scope['_INDEX'], m5_binary_width(m5_call(m5_scope['_MAX'])))
   define_vector(m5_scope['_CNT'], m5_binary_width(m5_call(m5_scope['_CNT']) + 1))
   var(m5_scope['_HIER'], m5_lowercase(m5_scope)[['m5_']m5_scope['_MAX:m5_']m5_scope['_MIN']])
])

// Define m5 constants for a bit field.
// m5_define_vector(SCOPE, 10 , 2) defines
//   m5_SCOPE_MAX = 9
//   m5_SCOPE_MIN = 2
//   m5_SCOPE_HIGH = 10
//   m5_SCOPE_LOW = 2
//   m5_SCOPE_CNT = 8
//   m5_SCOPE_RANGE = 9:1
// The 3rd arg is optional, and defaults to 0.
fn(define_vector, name, high, ?low, [
   var(m5_name['_MAX'],   m4_eval(m5_high - 1))
   var(m5_name['_MIN'],   m4_ifelse(m5_low, [''], ['0'], ['m5_low']))
   var(m5_name['_HIGH'],  m5_high)
   var(m5_name['_LOW'],   m5_eval(['m5_']m5_name['_MIN']))
   var(m5_name['_CNT'],   m4_eval(m5_high - m5_eval(['m5_']m5_name['_MIN'])))
   var(m5_name['_RANGE'], m5_eval(['m5_']m5_name['_MAX']:['m5_']m5_name['_MIN']))
])

// Define fields of a vector.
// This is similar to m4_define_vector_with_fields, except that the vector is assumed to already be defined.
// E.g. m5_define_fields(INSTR, 32, OP, 26, R1, 21, R2, 16, IMM, 5, DEST, 0)
//   calls m5_define_vector for (m5_INSTR_OP, 32, 26), (m5_INSTR_R1, 26, 21), etc.
// Also captures parameters (shifted by 1), in $1_FIELDS. In the example above:
//   m4_define(['m5_INSTR_FIELDS'], ['['32'], ['OP'], ...']). 
// Subfields and alternate fields can be declared w/ subsequent calls.
macro(define_fields_guts, ['['']
   m4_ifelse(['$4'], [''], [''], ['['']  /// Terminate if < 4 args
      // Define first field.
      m5_define_vector(['$1_$3'], ['$2'], ['$4'])
      // Recurse.
      $0(['$1'], m4_shift(m4_shift(m4_shift($@))))
   '])
'])
null_macro(define_fields,
   ['m5_macro(['$1_FIELDS'], m4_quote(m4_shift($@)))m5_define_fields_guts($@)'])

// Define a vector with fields.
// E.g. m5_define_vector_with_fields(INSTR, 32, OP, 26, R1, 21, R2, 16, IMM, 5, DEST, 0)
//   calls m5_define_vector for: (INSTR, 32, 0) and subfields: (INSTR_OP, 32, 26), (INSTR_R1, 26, 21), etc.
//   Subfields and alternate fields can be declared w/ subsequent calls.
// TODO: It would be good to accept "+N" args that would define the field width rather than position.
//       (This would require processing left to right.)
macro(define_vector_with_fields,
   ['m5_define_vector(['$1'], ['$2'], m4_argn($#, $@))['']m5_define_fields($@)'])

// Produce a TLV expression to assign field signals to the fields of a vector.
// E.g.
//   m5_define_fields(INSTR, 32, OP, 26, R1, 21, R2, 16, IMM, 5, DEST, 0)
//   m5_into_fields(INSTR, ['$instr_sig'])
//   Produces:
//   {$instr_sig_op[6:0], $instr_sig_r1[5:0], $instr_sig_r2[5:0], $instr_sig_imm[11:0], $instr_sig_dest[5:0]} = $instr_sig;
macro(into_fields,
   ['{m5_into_fields_lhs(['$2'], [''], m5_$1_FIELDS)['} = $2;']'])
// E.g. for the last 2 fields of INSTR, above: m5_into_fields(['$instr_sig'], [', '], ['IMM'], ['5'], ['DEST'], ['0'])
macro(into_fields_lhs,
   ['m4_ifelse(['$5'], [''], [''], ['$2$1_['']m4_translit(['$4'], ['A-Z'], ['a-z'])[m4_eval($3 - $5 - 1):0]$0(['$1'], [', '], m4_shift(m4_shift(m4_shift(m4_shift($@)))))'])'])


\m4



// Mapping M4 => M5.
// m4_forloop(var, from, to, stmt) => m5_loop((var_name, value, ...), do_block, while_cond, while_block)
// m4_foreach(...) => m5_for(...?)
// m4_dquote => m5_quote
// m4_translit => m5_translit_eval
// m4_to_upper/lower => m5_upper/lowercase
// m5_eval => m5_inline
// m4_str_append => m5_append_macro
// m4_str_prepend => m5_prepend_macro
// m4_append_var => m5_append_var
// m4_prepend_var => m5_prepend_var
// m4_eval => m5_calc
// m4_joinall => m5_join

