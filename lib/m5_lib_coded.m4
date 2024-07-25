m4_divert(-1)


// A library of M4 macros for implementing the M5 language.
// Note that the M5 standard library is separate.
// This provides just enough to define a "do" block and "use(m5-1.0)" within it.


// Push/pop behavior for divert. The below m4_func(..m4_output(..)..) macros are an
// improved mechanism for these.
// TODO: Phase these out. These work to hide output text, but not to hide text that is captured for later output.
// Macros can be defined using m4_define_show/hide to be explicit about their context.
// Generally macros will be defined as m4_define_hide, using m4_show internally to produce output.
// This makes macros more like functions with print statements, and allows them to be formatted readably.
// Be aware that m4_show'ing unquoted comments will cause havoc.
// Note that hidden output is not no-output, but rather output that is diverted. In other words,
// m4_hide(m4_show(HI)) will produce "HI".
m4_define(m4_visibility, hide)
m4_define(m4_hide, m4_ifelse(m4_visibility, show, m4_divert(-1), )m4_pushdef(m4_visibility, hide)$1m4_popdef(m4_visibility)m4_ifelse(m4_visibility, show, m4_divert, ))
m4_define(m4_show, m4_ifelse(m4_visibility, hide, m4_divert, )m4_pushdef(m4_visibility, show)$1m4_popdef(m4_visibility)m4_ifelse(m4_visibility, hide, m4_divert(-1), ))
m4_define(m4_define_hide, m4_define($1, m4_hide($2)))
m4_define(m4_define_show, m4_define($1, m4_show($2)))
// Evaluate argument if inside "show" context.
m4_define(m4_unless_hidden, m4_ifelse(m4_visibility, hide, , $1))


// Instantiated by pre_m4 at the start of the file to define macros for top-level and library files.
//   - m4_file_uri
//   - m4_FILE
//   - m5__stmt_file (for call stack)
m4_define_hide(m4_m5_file_begin, 
   m4_pushdef(m4_file_uri, $1)
   m4_pushdef(m4_FILE, $2)
   m4_pushdef(m5__stmt_file, $2)
)
m4_define_hide(m4_m5_file_end, 
   m4_popdef(m4_file_uri)
   m4_popdef(m4_FILE)
   m4_popdef(m5__stmt_file)
)


m4_define(m5_nl, $1
)

/// m5_quote(args) - convert args to quoted list of quoted strings
m4_define(m5_quote, $@)

/// Introduce the given number of levels of quotes.
/// m5_nquote(2, one, two) is equivalent to m5_quote(m5_quote(one, two)) is equivalent to one,two, which all evaluate to one, two.
m4_define(m5_nquote,
   m4_ifelse(m4_eval($1 <= 0), 1, m4_shift($@), $0(m4_eval($1-1), m5_quote(m5_shift($@)))))

// A block of code to execute, likely providing definitions, used as:
// m5_do([
//    ...
// ])
m4_define(m5_do,
   m4_pushdef(m4__out, m4_patsubst(m5_quote(m4_joinall(,, $1)), \s*, ))m4_ifelse(m4_defn(m4__out), , , m5_warning(Block contained the following unprocessed text: "m4_defn(m4__out)"))m4_popdef(m4__out))

// For error reporting. This is redefined by m5.m4 to be more capable, but we need basic
// functionality for macros defined here.
m4_define(m5_error,
   m4_errprint(Error: $1m5_nl()))
m4_define(m5_warning,
   m4_errprint(Warning: $1m5_nl()))


/// Get the value of a variable.
m4_define(m5_get,
   m4_ifdef(~$1, m4_defn(~$1), m5_get__error($1)))
m4_define(m5_get__error,
   m5_$1m5_error(Getting value of undefined variable "$1".m4_ifdef(m5_$1,  (Note that it is defined as a macro.)), get, 20))
m4_define(m5_call,
   m4_ifdef(m5_$1, m4_indir(m5_$@), m5_call__error($1)))
m4_define(m5_call__error,
   m5_$1(...)m5_error(Calling undefined macro "$1".m4_ifdef(~$1,  (Note that it is defined as a variable.)), call, 20))

// For ~(...) code statements.
m4_define(m5_out,        m4_define(m5_block_output, m4_defn(m5_block_output)$1)m4_ifelse(m4_eval($# > 1), 1, $0(m4_shift($@))))

m4_define(m5_eval, $1)
m4_define(m5_defn, m4_ifdef(m5_$1, m4_defn(m5_$1), m5_error(No definition for m5_$1.)))
// m4_quote(args) - convert args to single-quoted string
m4_define(m4_quote, m4_ifelse($#, 0, , $*))
// m4_dquote(args) - convert args to quoted list of quoted strings
m4_define(m4_dquote, $@)

m4_define(m5_arg_comma, ,)


// TODO: If max debug_level, set file in blocks as well as scopes.
m4_define(m5__block,
   m4_pushdef(m5_block_output, )m4_pushdef(m5__stmt_line, ?)m5__exec($1)m4_popdef(m5__stmt_line)m5_eval(m5_defn(block_output))m4_popdef(m5_block_output))
m4_define(m5__scope,
   m4_pushdef(m5_block_output, )m5__begin_scopem4_pushdef(m5__stmt_file, $1)m4_pushdef(m5__stmt_line, ?)m5__exec($2)m4_popdef(m5__stmt_line)m4_popdef(m5__stmt_file)m5__end_scopem5_eval(m5_defn(block_output))m4_popdef(m5_block_output))
// For text blocks. Strip leading new line (which requires a regexp, which doesn't work with \n).
m4_define(m5__text_block,
   m4_regexp(m4_translit($1, m5_nl(), ), ^\(.*\)$, m4_translit(\1, , m5_nl())))
m4_define(m5__stmt,
   m4_ifelse(m4_pushdef(m5__tmp, m4_quote(m4_indir($@)))m4_defn(m5__tmp), , , m5__stmt_err(m4_defn(m5__tmp), $@)))
m4_define(m5__stmt_err,
   m5_error(Code block statement: $2(m5_abbreviate_args(5, 12, m4_shift(m4_shift($@))))m5_nl()     produced unexpected output: m5_substr(m5_dequote($1), 0, 30)m4_ifelse(m4_eval(m4_len($1) > 30), 1, ...))m5_out($1))
m4_define(m5__out_stmt,
   m5_out(m4_indir($@)))
m4_define(m5__stmt_var,
   m5_out(m5_get($1)))   // pre_m4 reported an error for missing "~" in this case.
m4_define(m5__out_stmt_var,
   m5_out(m5_get($1)))
m4_define(m5__l,
   m4_define(m5__stmt_line, $1))

/// Evaluate $1 that should not produce any output other than whitespace and comments. No output is produced, and an error is reported if the evaluation was non-empty.
m4_define(m5__exec,
   m5_do($1))

// Merge all arguments into a delimited string.
m4_define(m4_joinall, m4_ifelse(m4_eval($# <= 2), 1, $2, m4_joinall($1, $2$1$3m4_ifelse(m4_eval($# > 3), 1, , m4_shift(m4_shift(m4_shift($@)))))))

// Output nothing.
m4_define(m4_null, )


// These pragmas are recognized by m5. They can appear anywhere on a line to disable/enable reporting
// of issues with indentation and use of  quotes. They expand to nothing.
m4_define(m4_define_pragma,
   m4_define(m4_pragma_$1, )
     m4_define(m5_pragma_$1, )
     m4_define(~pragma_$1, ))
m4_define(m4_define_pragmas,
   m4_define_pragma(enable_$1)
     m4_define_pragma(disable_$1))
m4_define_pragmas(paren_checks)
m4_define_pragmas(quote_checks)
m4_define_pragmas(verbose_checks)
m4_define_pragmas(existence_checks)
m4_define_pragmas(debug)
m4_define_pragmas(sugar)
m4_define_pragmas(literal_comma)
m4_define_pragma(where_am_i)



// Concatenate strings.
// Output the quoted concatenation of the arguments.
// Mostly this is useful to enable M4 macro definitions spanning multiple lines.
m4_define(m5__concat,
   m4_ifelse($#$1, 1, , $1$0(m4_shift($@))))



// Library inclusion.


// Strip weird chars to avoid bugs with weird file names in cases where they are only used in reporting.
m4_define(m4_strip_weird_chars,
          m4_patsubst($1,
                        [^a-zA-Z0-9\-\.\/],
                        ))

// Strip the protocol from a URI, leaving '/' in it's place.
// This is a helper for m4_include_url(..).
// E.g. "http://www.foo.com/file.txt" => "/www.foo.com/file.txt"
// The result looks like an absolute file, which makes it friendly as a filename for SandPiper.
m4_define(m4_strip_protocol,
          m4_patsubst($1,
                        ^\w+:///?,
                        /))


// Include an m4 tlv file from the web via curl or from the local filesystem given a path starting with "./" or "../".
// Relative paths are relative to the current file's URL/path indicated in m4_file_uri.
// No inclusion will be done if a library by the same name or URI has already been included.
// An error is reported if a library by the same name, but not the same URI has been included.
// Future library inclusion mechanisms will supersede this mechanism.
//  $1: The URI, as described above.
//  $2: (opt) a library name identifier, which could be the name from m5_use, to avoid multiple inclusion.
// TODO: Handle non-existent file properly.
// TODO: Reconsider use of m4_hide_include_libs, defined in rw_tlv.m4.
m4_define(m4_include_url_cnt, 0)
m4_define(m4_include_url_depth, 0)
m4_define_hide(
  m4_include_lib,
  // If we already included this library using the exact same URI or name, don't include it again.
    m4_ifdef(m4_include_lib__uri=$1, 
      // This library (exact same URI) has already been loaded.
      m4_errprint(Info: Skipping inclusion of "$1" since it has already been included.m4_nl)
    , 
      m4_ifdef(m4_include_lib__name=$2, 
        // A library by this name has already been included, but the URI was not an exact match.
        m4_errprint(Error: A library named "$1" was already included, though its path was different.m4_nl)
        m4_errprint(       Currently, there is no support for loading multiple versions of a library.m4_nl)
        m4_errprint(       Skipping inclusion of "$1".m4_nl)
      , 
        // No library by this name or URI has been included. Include it.
        m4_define(m4_include_url_cnt, m4_eval(m4_include_url_cnt + 1))
        m4_define(m4_include_url_depth, m4_eval(m4_include_url_depth + 1))
        // Run curl and pre_m4 to produce an m4 file for inclusion.
        // (M4-SAFE is used by the SaaS, which runs in a secure shell that does not permit paths to be used for command execution.)
        m4_syscmd(m4_ifdef(M4_SAFE,
                          ,
                          m4_pre_m4_path/)include_url '$1' m4_include_url_cnt 'm4_strip_weird_chars(m4_strip_protocol($1))' 'm4_file_uri' 'm4_obj_dir' 'm4_webcache')
        m4_ifelse(m4_sysval, 0,
          // Include the preprocessed m4 file.
            m4_show(m4_ifelse(m4_hide_include_libs, 1, // Included hidden file., // Included URL: "$1"))
            m4_include(m4_obj_dir/m4_include_url_file.m4_include_url_cnt)  // Include the file created by include_url script.
          ,
          m4_sysval, 1,
          m4_show(// FAILED to access: "$1")
            m4_errprint(ERROR: M5 include URL/path "$1" could not be found.m4_new_line())
          ,
          m4_show(// FAILED to process: "$1" (m4_sysval))
            m4_errprint(ERROR: M5 include URL/path "$1" could not be processed.m4_new_line())
          
        )
        m4_define(m4_include_url_depth, m4_eval(m4_include_url_depth - 1))
        // Remember this inclusion.
        m4_define(m4_include_lib__uri=$1, 1)
        m4_ifelse($2, , , m4_define(m4_include_lib__name=$2, 1))
      )
    )
  )



// A mechanism for including standardized libraries.
// The single argument includes a library name (with no '-'), a '-', and a version string, e.g. my_lib-2.1.
// This macro maps name-version to a URL. "name" becomes the 2nd argument to m4_include_lib.
// TODO: This mechanism should be in a public repo for maintenance.
// m5_use(library-name[.#]*
// A simple map of library names (including version numbers) to URLs.
m4_define(m4__define_libraries,
   m4_ifelse(m4_eval($# >= 2), 1, m4_define(m4__lib:$1, $2)m4_ifelse(m4_index($1, -), -1, m4_errprint(Error: Defined library "$1" containing no "-" to separate version string.))$0(m4_shift(m4_shift($@)))))
# TODO: What's the dependency model? Should these be provided by m5.m4 (other than m5-X.X)?
m4__define_libraries(
   m5-0.1, https://raw.githubusercontent.com/rweda/M5/ea452a341518275778f440c3856ee82558a77f2e/m5.m4,
   m5-0.2, https://raw.githubusercontent.com/rweda/M5/707a84d015ea397f7ebc0f7ff8d4c389b6ca3d06/m5.m4,
   m5-1.0, https://raw.githubusercontent.com/rweda/M5/0dd04971e78f2e3dc7daf32d75cd14632850e554/m5.m4,
   m5-local, /home/steve/repos/M5/lib/m5.m4,
   std-0.1, https://raw.githubusercontent.com/TL-X-org/tlv_lib/c48ad6c12e21f6fb49d77e7a633387264660d401/fundamentals_lib.tlv,
   flow-0.1, https://raw.githubusercontent.com/TL-X-org/tlv_flow_lib/c48ad6c12e21f6fb49d77e7a633387264660d401/pipeflow_lib.tlv,
   fpga-0.1, https://raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/3760a43f58573fbcf7b7893f13c8fa01da6260fc/tlv_lib/fpga_includes.tlv,
   xilinx-0.1, https://raw.githubusercontent.com/TL-X-org/tlv_flow_lib/c48ad6c12e21f6fb49d77e7a633387264660d401/xilinx_macros.tlv)
// Use a library (that does not define SV content).
// TODO: Currently m4_include_lib should be called from SV context if it has SV content. m5_include_lib should not produce output, but rather
//       add SV content to a macro that is to be instantiated.
m4_define(m5_use,
   m4_ifelse(m4_eval($# >= 1), 1,
               m4_ifdef(m4__lib:$1,
                          m4_include_lib(m4_defn(m4__lib:$1), m4_substr($1, 0, m4_index($1, -))),
                          m4_errprint(Unknown library: "$1".m5_nl()))))


m4_define(m4_visibility, show)



// Not used here, but used by m5.m4 and generic_tlv.m4.


// Echo the input. (Same as m4_quote). It can be used to force evaluation of returned string that is quoted.
// E.g. if m4_some_string() returns a quoted string, m4_echo(m4_some_string())
// will evaluate it.
m4_define(m4_echo, $1)

// Append/prepend to macro definition.
// These are deprecated in favor of m4_str_append/prepend above.
// (The original definition must be quoted to avoid evaluation when appended to.)
// E.g:
//   m4_def(foo, hi)
//   m4_append(foo, there) // is like m4_def(foo, hithere)
m4_define(m4_append,
   m4_def($1, m4_dquote(m4_echo(m4_m4prefix($1))$2)))
m4_define(m4_prepend,
   m4_def($1, m4_dquote($2m4_echo(m4_m4prefix($1)))))

// Append/prepend string to a macro definition.
// (The concatenation is evaluated and dquoted. The macro definition and string argument are generally
// expected to be a quoted to avoid alteration.)
// E.g:
//   m4_def(foo, hi)
//   m4_str_append(foo, there) // is like m4_def(foo, hithere)
m4_define(m4_str_append,
   m4_def($1, m4_defn(m4_m4prefix($1))$2))
m4_define(m4_str_prepend,
   m4_def($1, $2m4_defn(m4_m4prefix($1))))


// TODO: Add sanity checking for macro names in definitions list.

// TODO: # <comment>s replaced by : <comment>s, so this becomes obsolete.
// Process parameters defining a macro name and optionally a description preceded by /# ?/.
//   $1: Optionally a description preceded by /# ?/
//   $1 or $2: Macro name without m4_/M4_ prefix.
//   ...: remaining args.
// Return the parameter list with description removed if provided.
m4_define(m4_process_description,
          m4_ifelse(m4_regexp($1, ^# ?), 0,
                      m4_shift($@),
                      $@))


// Append "m4_" or "M4_" depending on case of 1st char.
m4_define(m4_m4prefix,
          m4_ifelse(m4_regexp($1, ^[A-Z]), 0,
                      M4_$1,
                      m4_$1))

// Body of m4_def, instantiated with the first optional description arg stripped, and the addition of a new $1:
//   $1: The name of the macro to process the remaining arguments, without the "m4_".
//   $2: The name of the macro to define the macros (e.g.: define or pushdef).
//   $3:  or +1 to indicate one non-definition argument at the end of $@.
//       (+2, etc. not supported (only to avoid a bunch of shifting).)
//   $4: The name of the macro to defined, without the "m4_"/"M4_".
//   $5: The definition of the new macro.
//   $...: (opt) As in m4_def (or none).
//   $...: Non-definition args (as required based on $3).
//   Return: Remaining non-definition args (based on $3) with extra quotes.
// TODO: This should be used to produce the body rather than being used in the body.
m4_define(m4_def_body,
          m4_ifelse(m4_eval($# < 5$3), 1,
                      m4_errprint(Error: Missing or extra arg in macro definition at line m4___line__ of m4___file__.m4_new_line()),
                      m4_$2(m4_m4prefix($4), $5)m4_ifelse(m4_eval($# > 5$3), 1,
                                                                    m4_$1(m4_shift(m4_shift(m4_shift(m4_shift(m4_shift($@)))))),
                                                                    $6)))
m4_define(m4_def,
          m4_def_body(def, define, , m4_process_description($@)))



/// Line number for error reporting.
m4_define(m5__stmt_line, ?)

/// For trading off runtime for error reporting.

/// Internal variable indicating the debug level.
m4_define(m5__debug_level,
   default)
/// See docs.
m4_define(m5_debug_level,
   m4_null(
      m4_ifelse($#, 0, m5__debug_level, 
        /// Record setting.
        m4_define(m5__debug_level, $1)

        /// Overrides for min/max.
        m4_ifelse(m5__debug_level, min, 
        , m5__debug_level, max, 
        )
      )
   ))
m5_debug_level(default)


m4_divertm4_dnl
