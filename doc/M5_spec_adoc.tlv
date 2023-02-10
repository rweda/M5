\m4_TLV_version 1d: tl-x.org
\SV
// This M5 spec is generated with the help of M5 itself.
// Since M5 syntax appears throughout, we have to be careful about M5's processing of this syntax
// with careful use of quotes, etc.

\m4

m4_define(['m5_main_doc'], ['= M5 Text Processing Language User's Guide
Steve Hoover <steve.hoover@redwoodeda.com>
v1.0, 2023
:toc: preamble
:toclevels: 3
// Web page meta data.
:keywords:    Gnu, M4, M5, macro, preprocessor, TL-Verilog, Redwood +
              EDA, HDL
:description: M5 is a macro preprocessor on steroids. It is built on the simple principle of text +
              substitution but provides robust features on par with other programming languages. +
              It is optimized for simple use cases and for comprehension by non-experts while being +
              capable of general-purpose programming.

//:library: M5
:idprefix: m5_
:numbered:
:secnums:
:sectnumlevels: 4
:imagesdir: images
:experimental:
//:css-signature: m5doc
//:max-width: 800px
//:doctype: book
//:sectids!:
ifdef::env-github[]
:note-caption: :information_source:
:tip-caption: :bulb:
endif::[]


The M5 macro preprocessor enhances the Gnu M4 macro preprocessor,
adding features typical of programming languages.

== General Information

=== Overview

{description}

M5 was developed by Redwood EDA, LLC and is used in conjunction with TL-Verilog, but it is appropriate as an
advance macro preprocessor or code generator for any target language or even as a stand-alone language.
M5 is constructed with a bit of pre-preprocessing, providing syntactic sugar, and then the use of the Gnu M4
macro preprocessor with an extensive library.

This chapter provides background and general information about M5, guidance about this specification,
and instructions for using M5.


=== About this Specification

This document is intended to stand on its own, independent of the
https://www.gnu.org/software/m4/[M4 documentation]. The M4 documentation
can, in fact, be confusing as M5 has philosophical differences.
Differences versus M4 are described in <<vs_m4>>.


[[usage]]
=== Getting Started with M5

[[config]]
==== Configuring M5

M5 adds a minimal amount of syntax, and it is important that this syntax is unlikely to conflict
with the output language syntax. Most notably M5 introduces quote characters used to provide
literal text that is not subject to macro preprocessing. By default M5 uses `['` and `']`.
It can be configured to use different quote characters by modifying two simple scripts that
substitute quotes in the input and output files and configure M4 to use the substituted
quote characters. Similar scripts must be applied to all `.m4` files including the ones
that define M5 to change all `['` / `']` quotes to the desired quotes.

Additionally, M5 defines a comment syntax that can be configured in the pre-preprocessing
script.

==== Running M5

The Linux command:

```sh
m5 < in-file > out-file
```

(TODO: Provide m5 script that does `--prefix_builtins`.)

runs M5 in its default configuration.

==== Ensure No Harm

First, be sure M5 processing does nothing on a file with no M5 syntax. As used for TL-Verilog,
M5 should output the input text, unaltered, as long as your file contains no:

- quotes, e.g. `['`, `']`)
- `m5` or `m4`

In other configurations, the following may also result in processing:

- vanishing comments, e.g. `/{empty}//`, `/*{empty}*`, `*{empty}*/`
- code blocks, e.g. `[` or `{` followed by a new line or `]` or `}` beginning a line after optional whitespace


=== M5's Place in the World

This section describes the history of and motivation for M5 and it's relation to M4 and TL-Verilog.


==== M5's Association with TL-Verilog

Although M5 was developed for TL-Verilog, it is not specifically tied to TL-Verilog.
It does, however, like all M4 libraries, depend upon a specific set of M4 syntax configurations,
and these configurations were chosen to best suit TL-Verilog.

The required M4 configurations are described in <<usage>>. These configurations
establish:

- builtin macro prefix: `m4_`
- quote characters: `['` and `']`

TL-Verilog supports other TL-Verilog-specific macro preprocessing
that is https://xxx[documented separately].

TL-Verilog preprocessing supports special code block syntax. To improve readability for
TL-Verilog users, this document does assume support for this syntax. <<code_blocks>>
describes equivalent syntax that can be used without TL-Verilog preprocessing.

[[vs_m4]]
==== M5 Versus M4

M5 uses M4 to implement a macro-preprocessing language with some subtle philosophical
differences. While M4 is adequate for simple substitutions, M5 aims to preserve the conceptual simplicity of
macro preprocessing while adding features that improve readability and manageability of
more complex use cases.

M4 favors aggressive macro expansion, which frequently leads to the need for multiple levels
of nested quoting to prevent unintended substitutions. This leads to obscure bugs.
M5 implicitly quotes arguments and returned text, favoring explicit expansion where desired.

==== M5 Above and Beyond M4

M5 contributes:

- features that feel like a typical, simple programming language
- a categorization of macros as variables, functions, and traditional macros
- named arguments for improved readability
- a moderate level of variable typing
- scope for variable declarations
- an intentionally minimal amount of syntactic sugar
- document generation assistance
- debug aids such as stack traces
- safer parsing and string manipulation
- a richer core library of utilities
- a future plan for modular libraries

==== Limitations of M5

M4 has certain limitations that M5 is unable to address. M5 uses M4 as is without
modifications to the M4 implementation (though these limitations may motivate
changes to M4 in the future).

===== Modularity
M4 does not provide any library, namespace, and version management facilities.
Though M5 does not currently address these needs, plans have been sketched in code comments.

===== String processing
While macro processing is all about string processing, safely manipulating arbitrary
strings is not possible in M4 or it is beyond awkward at best. M4 provides
`m4_regexp`, `m4_patsubst`, and `m4_substr`. These return unquoted strings that will
necessarily be elaborated, potentially altering the string. While M5 is able to jump
through hoops to provide `m5_regexp` and `m5_substr` (for strings of limited length)
that return quoted (literal) text, `m4_patsubst` cannot be fixed. The result of `m4_patsubst` can
be quoted only by quoting the input string, which can complicate the match expression,
or by ensuring that all text is matched, which can be awkward, and quoting substitutions.

In addition to these issues, care must be taken to ensure resulting strings do not contain mismatching
quotes or parentheses or combine with surrounding text to result in the same. Such
resulting mismatches are difficult to debug. M5 provides a notion of "unquoted strings"
that can be safely manipulated using `m5_regex`, and `m5_substr`.

Additionally the regex configuration used by M4 is quite dated. For example, it does
not support lookahead, lazy matches, and character codes.

===== Instrospection
Introspection is essentially impossible. The only way to see what is defined is to
dump definitions to a file and parse this file.

===== Recursion
Recursion has a fixed (command-line) depth limit, and this limit is not applied reliably.

===== File format
M4 is an old tool and was built for ASCII text. UTF-8 is now the most common text format.
It is a superset of ASCII that encodes additional characters as two or more bytes using byte
codes (0xFF-0x10) that do not conflict by those defined by ASCII (0x7F-0x00). All such bytes
(0xFF-0x10) are treated as characters by M4 with no special meaning, so these characters
pass through, unaffected, in macro processing like most others. There are two
implications to be aware of. First, `m5_len` provides a length in bytes, not characters.
Second, `substr` and regular expressions manipulate bytes, not characters. This can
result in text being split in the mid-character, resulting in invalid character
encodings.

====== Debugging features
M4's facilities for associating output with input only map output lines to line numbers of
top-level calls. (TL-Verilog tools have mechanisms for line tracking.)

M4 does not maintain a call stack. M5 adds one which tracks function names and arguments
of calls, but it cannot track line numbers.

M4 and M5 have no debugger to step through code. Printing is the debugging mechanism of choice.

=== Status

Certain features documented herein currently work only in conjunction with the TL-Verilog macro preprocessor.
The intent is to support them in M5 itself, and they are documented with that in mind. Such features
include:

- code blocks
- vanishing comments
- use of control-character quotes



== Processing Text and Calling Macro

=== Macro Preprocessing in General

M5, like other macro preprocessors, processes a text file sequentially with a default behavior of passing
the input text through as output text. Parameterized macros may be defined. When a macro name appears
in the input text, it (and its argument list) may be substituted for new text according to its definition.
Quotes (`['` and `']`) may be used around text to prevent substitutions.


=== Macro Substitution

A well-formed M5 macro name begins with `m5_` and is comprised entirely of word
characters (`a-z`, `A-Z`, `0-9`, and `_`). When a well-formed macro name appears, entirely in unquoted input text,
delimited by non-word characters (or the beginning or end of the file), the macro
is "called". It and its optional argument list are substituted with the text resulting from
the macro call. The argument list begins immediately after the macro name with an unquoted `(` and ends with the matching
unquoted `)`, such as `m5_foo(hello, 5)`. For details, see <<arguments>>.

NOTE: It is possible to define macros with names containing non-word characters, but these will
not substitute as described above. They can only be called indirectly. In addition to macros with the
`m5_` prefix, `m5` by itself is a legal predefined macro name. Also, the M4 macros from which M5 is
constructed are available, prefixed by `m4_`, though their direct use is discouraged. Using `m4_`
macros, it is possible to define macros without these prefixes, and doing so is discouraged.

Many, but not all, M5 macros result in literal (quoted) text that will not itself substitute.


[[quotes]]
=== Quotes

Unwanted substitution can be avoided using quotes. In M5, quotes are `['` and `']`. Quoted text begins with `['`.
The quoted text is parsed only for `['` and `']` and ends at the corresponding `']`. Intervening
characters that would otherwise have special treatment, such as `m5`*, `(`, and `)`,
have no special treatment when quoted. The quoted text passes through to the
resulting text (including internal matching quotes) without involvement in any
substitutions. The outer quotes themselves are discarded.
The end quote acts as a word boundary for subsequent text processing.

Quotes can be used to delimit words. For example, the empty quotes below:

 Index['']m5_index

enable `m5_index` to substitute, as would:

 ['Index']m5_index

As with strings in other programming languages, it is generally good coding practice to avoid using new lines
in the souce code to represent literal new lines. Code formatting (using new lines and indentation)
should reflect code structure, not the formatting of strings and output.
`m5_nl` should be used instead (or a macro that ultimately uses `m5_nl`). The one exception the this
rule is "text blocks", described in <<text_blocks>>.



=== Comments

==== Vanishing Comments (`/{empty}//` and `/{empty}*{empty}*`...`{empty}*{empty}*/`)

The following illustrates vanishing comments:

 /']['// This line comment will disappear.
 /*']['* This block comment will also disappear. *']['*/

Block comments beginning with `/{empty}*{empty}*` and ending with `{empty}*{empty}*/` and line comments
beginning with `/{empty}//` and ending with a new line are stripped from the source file prior to other
processing (except for new lines). As such:

- Vanishing-commented parentheses and quotes are not visible to parenthesis and quote matching checks, etc.
- Vanishing comments may follow the `[` or `{` beginning a code block or after a comma and prior to an argument
that begins on the next line without affecting the code block or argument.

NOTE: Any text immediately following `{empty}*{empty}*/` will, after stripping the comment, begin the line.
Comments are stripped after indentation checking. It is thus generally recommented that multi-line block comments
end with a new line.

==== Preserved Comments (`//`)

Line comments in the target language (`//`) have special treatment to avoid unexpected
expansion of commented macros. Unquoted `//` comments until the next new line, pass through to the output
as literal text.

CAUTION: This behavior is both helpful and dangerous. It can hide quotes as a result of dynamic evaluation, leading
to mismatched quotes that are inconsistent with static checking which ignores `//`. It is best to use
vanishing quotes to disable macro code. 

NOTE: `/*` and `*/` are not recognized as block comments. In target languages that support
this comment style, their use can be convenient for seeing evaluations in output comments. `['//']`
(or similar) can also be used to pass macro evaluations in comments.


[[arguments]]
=== Arguments

TODO: Macro categories have not been introduced yet.

Traditional macros and function calls pass arguments within `(` and `)` that are comma-separated.
For each argument, preceding whitespace is not part of the argument, while postceding whitespace
is. Specifically, the argument list begins after the unquoted `(`. Subsequent text is elaborated
sequentially (invoking macros and interpreting quotes). The text value of the first argument begins
at the first elaborated non-whitespace charater following the `(`. Unquoted `(` are counted as
an argument is processed. An argument is terminated by the first unquoted and non-parenthetical
`,` or `)` in the resulting elaborated text. A subsequent argument, similarly,
begins with the first non-whitespace character following the `,` separator. Whitespace includes
spaces, new lines, and tabs. An unquoted `)` ends the list.

Some examples to illustrate preceding and postceding whitespace:

 m5_macro(foo, ['Args:$1,$2'])
 
 m5_foo(  A,  B)        ==> Yields: "Args:A,B"
 m5_foo(    ['']  A,B)  ==> Yields: "Args:  A,B"
 m5_foo(  A  ,  B  )    ==> Yields: "Args:A  ,B  "

Arguments can be empty text, such as `()` (one empty argument) and `(,)` (two empty arguments).
`([''])` and `([''], [''])` are identical to the previous cases and are preferred, to express
the intended empty arguments more clearly.

There are a few gotchas to watch out for.

When argument lists get long, it is useful to break them up on multiple lines. The new lines
should precede, not postcede the arguments. E.g.:

 m5_foo(long-arg1,
        long-arg2)

Notably, the closing parenthesis should *not* be on a the next line by itself. This would include the
new line and spaces in the second argument.


[[bodies]]
== Multi-line Constructs: Blocks and Bodies

=== What are Bodies and Blocks?

A "body" is a parameter or macro value that is to be be evaluated in the context of a caller.
Macros, like `m5_if` and `m5_loop` have immediate body parameters. These bodies are to be evaluated
by these macros in the context of the caller. The final argument to a function or macro declaration
is an indirect body argument. The body is to be evaluated, not by the declaration macro itself, but by the
caller of the macro it declares.

NOTE: Declaring macros that evaluate body arguments requires special consideration. See <<evaluating_bodies>>.

"Code blocks" are convenient constructs for multi-line body arguments formatted like code.

A "Text block" construct is also available for specifying multi-line blocks of arbitrary text, indented with
the code.

=== Macro Bodies

A body argument can be provided as a quoted string of text:

 m5_if(m5_A > m5_B, ['['Yes, ']m5_A[' > ']m5_B'])   // Might result in "Yes, 4 > 2".

Note that the quoting of `['Yes, ']` prevents misinterpretation of the `,` as an argument separator
as the body is evaluated.

This syntax is fine for simple text substitutions, but it is essentially restricted to a single line
which is unreadable for larger bodies that might define local variables, perform calculations,
evaluate code conditionally, iterate in loops, call other functions, recurse, etc.

[[code_blocks]]
=== Code Blocks

M5 supports a special multi-line syntax convenient for body arguments, called "code blocks". These look more
like blocks of code in a traditional programming language. Aside from comments and whitespace, they
contain only macro calls ("statements"). The resulting text of the code block is constructed from the results
of these macro calls.

The code below is equivalent to the example above, expressed using a code body, and assuming it is
called from within a code body.

 ~if(m5_A > m5_B, [
    ~(['Yes, '])
    ~A
    ~([' > '])
    ~B
 ])

The block begins with `[`, followed immediately by a new line (even if commented by `//`). It ends with a line that begins with `]`,
indented consistently with the beginning line. The above code block is "unscoped". A "scoped" code block
uses, instead, `{` and `}`. Scopes are detailed in <<scope>>.

The first non-blank line of the block determines the indentation of the block. Indentation uses spaces;
tabs are discouraged, but must be used consistently if they are used. All non-blank lines at this level
of indentation are either preserved comments or statements (after stripping vanishing comments). (All lines
are statements in the above example.)
Lines with deeper indentation would continue a statement. A continuation line either begins a macro argument
or is part of its own (nested) code block argument.

Statements that produce output (as all statements in the above example do) must be preceded by `~`
(and others may be). This simply helps to identify
the source of code block ouput. The `~(...)` syntax has the same effect as `~out(m5_...)` and
is used to directly provide output text. A `m5_` prefix is implicit on statements.
In the rare (and discouraged) event that a macro without this prefix is to be called, such as use of an `m4_`
macro, using `~out(m4_...)` will do the trick.

The above example is interpreted as:

 m5_if(m5_A > m5_B, m5__block(['
 m5_out(['Yes, '])
 m5_out_stmt(m5_A)
 m5_out([' > '])
 m5_out_stmt(m5_B)
 '])

Top-level M5 content (in TL-Verilog, the content of an \m5 region) is formatted as a non-scoped
code block with no output.

[[text_blocks]]
=== Text Blocks

"Text blocks" provide a syntax for multi-line quoted text that is indented with its surroundings.
They are formatted similarly to code blocks, but use standard (`['`/`']`) quotes. The openning quote
must be followed by a new line and the closing quote must begin a new line that is indented consistently
with the line beginning the block. Their indentation is defined by the first non-blank line in the block.
All lines must contain at least this indentation (except the last). This fixed level of indentation
and the beginning and ending new line are removed. Aside from the removal of this whitespace, the
text block is simply quoted text containing new lines.

Non-evaluating (no "*") text blocks are leaf-level blocks, meaning, there is no parsing for code and text blocks
as well as label syntaxes within non-evaluating text blocks. There is parsing of vanishing comments, quotes, and parentheses
(counting) and quotes are recognized (and, of course, number parameter substitutions will occur for a text block that is elaborated as
part of a macro body).

=== Evaluating-Blocks

It can be convenient to form non-body arguments by evaluating code. Syntactic sugar is provided for
this in the form of a `*` preceding the block open quote.

For example, here an evaluating scoped code block is used to form an error message by searching for
negative arguments:

 error(*{
    ~(['Arguments includes negative values: '])
    var(Comma, [''])
    ~for(Value, ['$@'], [
       if(m5_Value < 0, [
          ~Comma
          set(Comma, [', '])
          ~Value
       ])
    ])
    ~(['.'])
 })

=== Block Labels: Escaping Blocks, and Labeled Numbered Parameters

Proper use of quotes can get a bit tedious, especially when it is necessary to escape out of several
levels of nested quotes. Though rarely needed, in can improve maintainability, code clarity, and
performance to make judicious use of block labels.

Blocks can be labeled using syntax such as:

 fn(some_function, ..., <sf>{
 })

Labels can be used in two ways.

- First, to escape out of a block, typically to generate text of the block.
- Second, to specify the block associated with a numbered parameter.

Both use cases are illustrated in the following example that attempts to declare a function for parsing text.
This function declares a helper function `ParseError` for reporting parse errors that can be
used many times by `my_parser`.

 /// Parse a block of text.
 fn(my_parser,
    Text: Text to parse,
    What: A description identifying what is begin parsed,
 {
    /// Report a parse error, e.g. m5_ParseError(['unrecognized character'])
    macro(ParseError, {
       error(['Parsing of ']m5_What[' failed with: "$1"'])  /// !!! TWO MISTAKES !!!
    })
    
    ...
 })

This code contains, potentially, two mistakes in the error message. First, `m5_What` will be
substituted at the time of the call to `ParseError`. As long as `my_parser` does not
modify the value of `What`, this is fine, but it might be preferred to expand `m5_What` in
the definition itself to avoid this potential masking issue in case `What` is reused.

Secondly, `$1` will be substituted upon calling `my_parser`, not upon calling `ParseError`,
and it will be substituted with a null string.

The corrected example is:

 /// Parse a block of text.
 fn(my_parser,
    Text: Text to parse,
    What: A description identifying what is begin parsed,
 {
    /// Report a parse error, e.g. m5_ParseError(['unrecognized character'])
    macro(ParseError, <err>{
       error(['Parsing of ']<err>m5_What[' failed with: "$<err>1"'])  /// !!! TWO CORRECTIONS !!!
    })
    
    ...
 })

This code corrects both issues:

- `']<err>m5_What['` 


== Declaring Macros

=== Macro Categories

`m5`* macro definitions fall into three general categories:

- variables: These hold values as strings.
- functions: These operate on inputs to produce output text and side effects.
- traditional macros: These are quick-and-dirty M4-style macros whose return text is evaluated. For the
most part these are superceded by variables and functions. The primary motivation to supporting
these is performance.

Variables, functions, and tranditional macros are defined with a name, such as `foo`, and called (aka
instantiated, invoked, expanded, evaluated, or elaborated), with the prefix `m5_`, e.g. `m5_foo`.

Here are some sample uses:

[%autowidth]
|===
|Category |Definition |Call |Resulting Text

|Variables
|`m5_var(Foo, 5)`
|`m5_Foo`
|`5`

|Traditional macros
|`m5_macro(foo, ['['Arg: $1']'])`
|`m5_foo(hi)`
|`Arg: hi`

|Functions
|`m5_fn(foo, in, ['m5_out(['Arg: ']m5_in)'])`
|`m5_foo(hi)`
|`Arg: hi`
|===

[[result_classes]]
Macros return text in one of three ways, determining the treatment of the text (here `text`):

- Literal: (`['text']`) The resulting text is quoted, so its evaluation results in a literal string (`text`)
           (as long as the text itself does not contain imbalanced quotes, which is hard to do and
           wreaks havoc). This is the behavior of variables, and functions.
- Evaluated: (`text['']`) The resulting text is essentially evaluated in isolation from surrounding text.
             Note that the prior ....
             It may continue an argument list, but it will not combine with subsequent text to result in
             a macro name to call. It is generally recommended to name such macros with a suffix of `_eval`
             (or the `eval` macro, itself).
- Inline: (`text`) The resulting text evaluates together with subsequent text (which could complete
          the text for a macro name to call or provide an argument list). Problematically, it
          could combine with subsequent text to form a quote. This is generally discouraged. It is
          generally recommended to name such macros with a suffix of "_inline" (or the "inline" macro, itself).
          TODO: I don't believe there's a practical use model 


=== Substituting Numbered Parameter

Numbered parameters may be used in the bodies of traditional macros and functions (and some variables,
though this is not the intended use model). Numbered parameter
substitutions are made throughout the entire body string regardless of the use of quotes. The following
notations are substituted:

- `$1`, `$2`, etc.: These substitute with corresponding arguments.
- `$#`: The number of arguments (including only those that are numbered). Note that `m5_foo()` has one empty macro argument, while `m5_foo` has zero.
- `$@`: This substitutes with a comma delimited list of the arguments, each quoted so as to be taken literally. So, `m5_macro(foo, ['m5_bar($@)'])`
        is one way to give `m5_foo(...)` the same behavior as `m5_bar(...)`.
- `$*`: This is rarely useful. It is similar to `$@`, but arguments are unquoted.
- `$0`: `$0__` can be used as a name prefix to localize a macro name to this macro. (See <<masking>>.)
        In traditional macros, `$0` is the name of the macro itself, and it can be used for recursive calls
        (though see `m5_recurse`). For functions, `$0` is the name of the function body and it should not
        be used for recursion.

CAUTION: Macros may be declared by other macros in which case the inner macro body appears within
the outer macro body. Numbered parameters appearing in the inner body would be substituted as
parameters of the outer body. It is generally not recommended to use numbered
parameters for arguments of nested macros, though it is possible. For more on the topic,
see <<Escaping Blocks>>.


=== Variables

Variables are expected to be defined without parameters and to be invoked without a parameter list. They
simply map a name to a text string.

Variables are defined using: `m5_var`, `m5_set`, `m5_var_str`, `m5_set_str`

Parameters: Variables are not generally used with parameters, however numbered parameters are supported.
Since variables result in literal (quoted) text, these parameters can only go so far as to expand arguments
literally in the resulting text. Where it may be necessary to avoid inadvertent interpretation of a `$`
in a variable value as a parameter reference, access the value of the variable using `m5_value_of`.


=== Traditional Macros

A traditional macro call returns the body of the macro definition with numbered parameters substituted with
the corresponding arguments. The body is then evaluated (unlike variables), so these macros can perform
computations, assign variables, etc. For example:

 m5_macro(foo,
    ['['Args:$1,$2']'])
 
 m5_foo(A,B)     ==> Yields: "Args:A,B"

Traditional macros are declared using `m5_macro` and `m5_macro_inline`.


=== Functions

Functions are macros that support a richer set of mechanisms for defining and passing parameter. Functions
have a body that is generally defined as a <<code_block>>...
Functions are macros that look and act like functions/procedures/subroutines/methods in a traditional programming
language, especially when used with <<code_blocks>>. Function calls pass arguments into parameters. Function
bodies contain macro calls that define local
variables, perform calculations, evaluate code conditionally, iterate in loops, call other functions, recurse,
etc. They may contain comments and whitespace, and these have no impact. They evaluate to literal text that
is explicitly returned using `m5_out(...)` and related macros.

There is no mechanism to explicitly print to the standard output stream, as is typical in a programming language (though there
are macros for printing to the standard error stream). It is up to the caller what to do with the result. Only
a top-level call from the source code will implicitly echo to standard output.

Functions are defined using: `m5_fn`, `m5_eval_fn`, `m5_inline_fn`, m5_null_fn`, `m5_lazy_fn`, ...

Declarations take the form:

 m5_fn(<name>, [<param-list>,] ['<body>'])

A basic function declaration looks like:

 m5_fn(mul, val1, val2, ['m5_calc(m5_val1 * m5_val2)'])

And is called like:

 m5_mul(3, 5)  // produces 15

==== Parameters

Several parameter types are provided.

===== Numbered Versus Named Parameters

- *Numbered parameters*: Numbered parameters are the macro parameters supported natively by M4, such as (`$1`, `$2`, etc.).
                         `$@`, `$*`, and `$#` are also supported in the body. Unlike macros, they are substituted before
                         elaborating the body regardless of whether they are contained within quotes or parentheses. For
                         functions, numbered parameters are explicit in the parameter list.
- *Named parameters*: These are available to the body as macros. If from an argument, they return the quoted argument.
                      m5_<name> is pushed prior to evaluation of the body and popped afterward.

===== The Parameter List

The parameter list (`<param-list>`) is a list of `<param-spec>`, where `<param-spec>` is:

- A parameter spec of the form: `[?][[<number>]][[^]<name>][: <comment>]` (in this order), e.g. `?[2]^name: the name of something`:
  * `<name>`:   A named parameter.
  * `?`:        An optional parameter. Calls are checked to ensure that arguments are provided for all non-optional parameters
                or are defined for inherited parameters. (Note that m5_foo() has one empty arg.) Non-optional parameters may
                not follow optional ones.
  * `[<number>]`: A numbered parameter. The first would be `[1]` and would correspond to `$1`, and so on.
                  `<number>` is verified to match the sequential ordering of numbered parameters.
  * `^`:        An inherited named parameter. Its definition is inherited from the context of the func definition.
                If undefined, the empty `['']` value is provided and an error is reported unless the parameter is optional,
                e.g. `?^<name>`. There is no corresponding argument in a call of this function. It is conventional to list
                inherited parameters last (before the body) to maintain correspondence between the parameter
                list of the definition and the argument list of a call.
  * `<comment>`: A description of the parameter. In addition to commenting the code, this can be extracted in
                documentation. See `m5_enable_doc`.
- `...`:        Listed after last numbered parameter to allow extra numbered arguments. Without this, extra arguments result in an error.
                (Note that `m5_foo()` has one empty argument, and this is permitted for a function with no named parameters.)
- `['']`:       Empty elements in the parameter list are ignored and do not correspond to any arguments (as a convenience for empty
                list expansion).

In addition to accessing the list of numbered arguments using `$@`, it can also be accessed as `m5_fn_args`. `m5_func_arg(3)` can
be used to access the third argument from `m5_fn_args`, and `m5_fn_arg_cnt` returns the number of numbered arguments.

==== Function Call Arguments

Function calls will have arguments for all parameters that are not inherited (`^`). Arguments are positional, so misaligning arguments
is a common source of errors. There is checking, however, that required arguments are provided and that no extra arguments are given.

==== When To Use What Type of Parameter

For nested declarations, named parameters are preferred. Nested declarations are declarations within the bodies of other declarations.
The use of numbered parameters (`$1`, `$2`, and ...) as well as `$@`, `$*`, and `$#` can be extremely awkward in this case. Unless
care is taken, they would substitute based on the outer definition, not the inner ones. Though this can be prevented
by generating the body with macros that produce the numbered parameter references, this requires unnatural and bug prone use of quotes.
So the use of functions with named parameters is preferred for inner macro declarations. Use of `m5_fn_args` and `m4_func_arg` is
also possible with numbered parameters, though for nested functions this is suggested only to access `...` arguments or to pass the
arguments to other functions.

Additionally, and in summary:

- *Numbered parameters*: These can be convenient to ensure substitution throughout the body without interference from
                         quotes. They can, however, be extremely awkward to use in functions defined within the bodies of
                         other functions/macros as they would substitute with the arguments of the outer function/macro,
                         not the inner one. Being unnamed, readability is an issue, especially for large functions.
- *Named parameters*: These act more like typical function arguments vs. text substitution. Since they are named, they
                      can improve readability. Unlike numbered parameters, they work perfectly well in functions
                      defined within other functions/macros. (Similarly, m5_fn_args and m5_func_arg are useful
                      for nested declarations.) Macros will not evaluate within quoted strings, so typical use requires
                      unquoting, e.g. `['Arg1: ']m5_arg1['.']` vs. `['Arg1: $1.']`.
- *Inherited parameters*: These provide a more natural, readable, and explicit mechanism for customizing a function to the
                          context in which it is defined. For example a function may define another function that is
                          customized to the parameters of the outer function.

==== Passing Arguments by Reference

It is possible for a function to make assignments (and, actually do anything) in the calling scope.
This can be done using <<m5_out_eval>>, <<m5_on_return>>, or <<m5_return_status>>.

In particular, functions can pass variables by reference and make assignments to the referenced
variables. The parameter would be a named parameter, say `foo_ref`, passed the name of the referenced variable.
A function can modify a variable using a parameter, say `foo_ref`, and calling in its code block
`on_return(set, m5_foo_ref, ['updated value'])`.
A function can declare a variable using a parameter, say `foo_ref`, and calling in its code block
`on_return(var, m5_foo_ref, ['init value'])`.


==== Function Arguments Example

In the context of a code block, function `foo` is declared to output its prameters.

  // Context:
  var(inherit2, two)
  // Define foo:
  fn(foo, param1, ?[1]param2: an optional parameter, ?^inherit1, [2]^inherit2, ..., {
    ~nl(param1: m5_param1)
    ~nl(param2: m5_param2)
    ~nl(inherit1: m5_inherit1)
    ~nl(inherit2: m5_inherit2)
    ~nl(['numbered args: $@'])
  })

And it can be called (again, in this example, from a code block):

  // Call foo:
  foo(arg1, arg2, extra1, extra2)

And this expands to:

 param1: arg1
 param2: arg2
 inherit1:
 inherit2: two
 numbered args: ['arg2'],['two'],['extra1'],['extra2']

==== Functions with Body Arguments




== Contexts: Scope, Namespaces, and Libraries

=== Contexts

The context of a macro comes in three types:

- Universal: Universal macro names are the same for any M5 program. These can be called directly, prefixed
  with `m5_`. They can be:
  - Built-in: These are defined by the M5 library.
  - External: These are only defined if explicitly included.
- Namespaced: Namespaces are used to avoid name conflicts between third-party libraries and between different
  versions of the same library. Namespaces are local to a library or application, and may exist in a hierarchy.
  The same macro may exist in multiple namespaces of multiple libraries, and its definition is shared.
  Namespaced macros are called via `m5_my(...)`.
- Scoped: Declarations made within a <<scope>> are local to that scope. Naming conventions avoid
  name conflicts with the other context types.


=== Macro Naming Conventions

To avoid ((masking)) issues, naming conventions divide the namespace in two styles:

- Lower case with underscores, e.g.: `m5_builtin_macro`
- Pascal case, e.g. `m5_MyVarName`

Names using lowercase with underscores: universal, namespaces, namespaced

Names using Pascal case: scoped macros (variables, functions, and traditional macros)

In both cases, names must be composed of ASCII characters `A-Z`, `a-z`, `0-9`, and `_`, and the first character must be alphabetic.

Libraries may define private macros using double underscore (`__`). A non-private macro in a universal library reserves
its own name in the universal namespace and also private names beginning with that name and `__`.
To maximize the ability of third-party libraries to share a namespace with other libraries, macros in third-party
libraries that are helpers for other macros should use the name of the associated macro before the `__`.


[[scope]]
=== Scope

==== Macro Stacks

All macros in M4, and thus in M5, are stacks of definitions that can be pushed and popped. (These stacks are frequently one entry deep.)
The top definition of a macro provides the replacement text when
the macro is called. The others are only accessible by popping the stack. In M5, pushing and popping are not generally done
explicitly, but rather through scoped declarations.

==== Scoped Code Blocks

Some macros accept body arguments that may be evaluated by calls to the macro. (See <<bodies>>.) Such an argument
may be given as a scoped code block. (See <<code_blocks>>.)

Within a code block, declarations made using `m5_var`, ... are scoped. Their definitions are pushed by the declaration, and
popped at the end of their scope.

`m5_set`, ... redefine the top entry.

Declarations from outer scopes are visible in inner scopes. Similarly, declarations from calling scopes are visible in callee scopes.
Function are generally written without any assumptions about the calling scope and should not use definitions from them. Exceptions
should be clearly documented/commented.

NOTE: It is fine to redeclare a variable in the same scope. The redeclaration will override the first,
and both definitions will be popped after evaluating the code block. Notably, a variable may be
conditionally declared without any negative consequence on stack maintenance.


=== Universal Marcros

=== Namespaces

=== Libraries


[[status]]
== Status

The variable `m5_status` has a reserved usage. Some macros are defined to set `m5_status`. A non-`['']`
value indicates that the macro did not perform its duties to the fullest. Several `m5_if*` macros set non-`['']`
status if they do not evaluate a body.

Macros such as `m5_else` and `m5_ifso` take action based on `m5_status`.

Some macros are defined explicitly to preserve the value of `m5_status` (or restore it upon completion). These
macros can be used between a status-producing macro and a status-consuming macro.

Macros whose treatment of `m5_status` is not specified may update `m5_status` in unpredictable ways. This can be
source of bugs in poorly-constructed code, especially when library versions are updated.


== Processing Order

WIP...

- Strip vanishing comments.
- Substitute block and label syntax, match quotes and parentheses.
- Produce pre-preprocessed file for M4.
- M4 macro preprocessing (substituting macros).


== Coding Paradigms, Patterns, Tips, Tricks, and Gotchas


=== Arbitrary Strings

It's important to keep in mind that variables are macros, and macro calls substitute `$` parameters, whether
parameters are given or not. (This is legacy from M4, and working around it would impact performance appreciably.)
Whenever dealing using variables containing arbitrary strings, use `m5_value_of`, or use `m5_str` and `m5_set_str`.
See [[String Processing]].


[[masking]]
=== Masking and `$0`

TODO: Move this to a section about macros that have body arguments.

A common pattern is to declare a variable in an outer-level macro body and assign it in a lower-level
macro body. This paradigm fails if a variable by the same name happens to be declared by an intervening
macro. This is referred to as "masking".

In macros that only evaluate code provided in the body of the macro itself, any masking is apparent and is unlikely
to catch a developer by surprise. Masking becomes an issue when a macro evaluates arbitrary code provided as an input
in a body argument.

TODO: Use `\_` prefix (w/ Pascal case) instead.
To avoid masking, proior to evaluating a body argument, a macro should only declare variables (and other macros)
using uniquified names. Uniquified, or "local" macro names can be generated using the prefix `$0__`.
In traditional macros, `$0` is the name of the macro. In functions, `$0` is the name given to the
function body. In either case, this prefix constructs a name that is implicitly reserved by the macro.


'])
\m4
   m4_define(['m5_need_docs'], yes)
   m4_use(m5-0.1)
\m5

enable_doc(adoc)

/// Shorthand for m5_doc_macro__adoc__<name>.
macro(DocFn, ['m5_doc_as_fn($@)m5_value_of(['doc_macro__adoc__$1'])'])
macro(DocFns, ['m5_doc_now_as_fns($@)'])
macro(DocVar, m5_defn(doc_macro__doc_var))


var(mac_spec, *['
 == Macros Specifications
 
 === Specification Conventions
 ['
 Macros that return integer values, unless otherwise specified, return decimal value strings. Similarly,
 macro arguments that are integer values accept decimal value strings. Boolean inputs and outputs use
 `0` and `1`. Behavior for other argument values is undefined if unspecified.
 
 Resulting text is by default literal (`['text']`). Macros named with a `_eval` suffix generally result
 in text that gets evaluated (`text['']`). Macros named with a `_inline` suffix generally result in
 text that evaluates inline (`text`), so it may combine with subsequent text for further evaluation. For
 more about these categories, see <<result_classes>>.
 ']

 === Assigning and Accessing Macros Values

 ==== Declaring/Setting Variables

 m5_DocFn(var, ['
  D: Declare a scoped variable. See <<variables>>.
  S: the variable is defined
  E: var(Foo, 5)
  A: (macro, fn, var_str)
 '], Name: variable name, ?Value: the value for the variable, ...: additional variables and values to declare (values are required))

 m5_DocFn(set, ['
  D: Set the value of a scoped variable. See <<variables>>.
  S: the variable's value is set
  E: set(Foo, 5)
  A: (var)
 '], Name: variable name, Value: the value)

 m5_DocFn(push_var, ['
  D: Declare a variable that must be explicitly popped.
  S: the variable is defined
  E: push_var(Foo, 5)
  ...
  pop(Foo)
  A: (pop)
 '], Name: variable name, Value: the value)

 m5_DocFn(pop, ['
  D: Pop a variable or traditional macro declared using `push_var` or `push_macro`.
  S: the macro is popped
  E: push_var(Foo, 5)
  ...
  pop(Foo)
  A: (push_var, push_macro)
 '], Name: variable name)

 m5_DocFn(var_str, ['
  D: Declare a variable and assign it a "string value". A string value evaluates without `$` substitution.
  S: the variable is defined
  E: m5_var_str(OneDollar, ['$1.00'])
  m5_OneDollar()
  P: 
  $1.00
  A: (var, value_of)
 '], Name: variable name, ?Value: the value for the string variable (empty by default))

 m5_DocFn(set_str, ['
  D: Set a variable with a string value (so the variable will evaluate without `$` substitution).
  S: the variable is defined
  E: m5_var_str(OneDollar, ['$1.00'])
  m5_OneDollar()
  P: 
  $1.00
  A: (var, value_of)
 '], Name: variable name, ?Value: the value for the string variable (empty by default))

 m5_DocFn(null_vars, ['
  D: Declare variables with empty values.
  S: the variables are declared
 '], ...: names of variables to declare)

 ==== Declaring Functions

 /**
 m5_DocFn(, ['
  D: 
  O: 
  S: none
  E: 
  P: 
  A: ()
 '], ...: )
 **/
 
 ==== Declaring/Setting Traditional Macros

 /**
 m5_DocFn(, ['
  D: 
  O: 
  S: none
  E: 
  P: 
  A: ()
 '], ...: )
 **/
 
 m5_DocFns(['macro, macro_inline, null_macro'], ['
  D: Declare a scoped traditional macro. See <<macros>>. The evaluation of an inline macro
  can combine with subsequent text to evaluate further. A null macro must produce no output.
  S: the macro is declared
  E: m5_macro(ParseError, <p>['
     m5_error(['Failed to parse $<p>1.'])
  '])
  A: (var, set_macro)
 '], Name: the macro name, Body: the body of the macro)

 m5_DocFn(set_macro, ['
  D: Set the value of a scoped traditional macro. See <<macros>>. Using this macro is rare.
  S: the macro value is set
  A: (var, set_macro)
 '], Name: the macro name, Body: the body of the macro)
 
 m5_DocFn(push_macro, ['
  D: Push a new value of a traditional macro that must be explicitly popped. Using this macro is rare.
  S: the macro value is pushed
  A: (pop, macro, set_macro)
 '], Name: the macro name, Body: the body of the macro)

 ==== Accessing Macro Values
 
 m5_DocFn(value_of, ['
  O: the value of a variable without `$` substitution (even if not assigned as a string)
  E: var(OneDollar, ['$1.00'])
  value_of(OneDollar)
  P: 
  $1.00
  A: (var_str, set_str)
 '], Name: name of the variable)

 
 === Code Constructs
 
 m5_DocVar(status, ['
 D: This universal variable is set as a side-effect of some macros to indicate an exceptional
 condition or non-evaluation of a body argument. It may be desirable to check this condition
 after calling such macros. Macros, like `m5_else` take action based on the value
 of `m5_status`. An empty value indicates no special condition.
 Macros either always set it (to an empty or non-empty value) or never set it. Those that set
 it list this in their "Side Effect(s)".
 '])

 ==== Conditionals

 ==== Loops

 ==== Recursion
 
 m5_DocFn(recurse, ['
  D: Call a macro recursively to a given maximum recursion depth. Functions have a built-in recursion
  limit, so this is only useful for macros.
  O: the output of the recursive call
  S: the side effects of the recursive call
  E: m5_recurse(20, myself, args)
  A: (recursion_limit, on_return)
 '], max_depth: the limit on the depth of recursive calls made through this macro, macro: the recursive macro to call, ...: arguments for `macro`)


 === Working with Strings
 
 ==== Special Characters
 
 m5_DocFn(nl, ['
  D: Produce a new-line. Programmatically-generated output should always use this macro
  (directly or indirectly) to produce new-lines, rather than using an actual new-line in
  the source file. Thus the input file formatting can reflect the code structure, not the output
  formatting. 
  O: a new-line
 '])
 
 m5_DocFns(['open_quote, close_quote'], ['
  D: Produce an open or close quote. These should rarely (never?) be needed and should be used with extra
  caution since they can create undetected imbalanced quoting. The resulting quote is literal,
  but it will be interpreted as a quote if evaluated.
  O: the literal quote
  A: (quote)
 '])
 
 m5_DocFns(['orig_open_quote, orig_close_quote'], ['
  D: Produce `['` or `']`. These quotes in the original file are translated internally to ASCII
  control characters, and in output (STDOUT and STDERR) these control characters are translated to single-unicode-character
  "printable quotes". This original quote syntax is most easily produced using these macros, and
  once produced, has no special meaning in strings (though `[` and `]` have special meaning in
  regular expressions).
  O: the literal quote
  A: (printable_open_quote, printable_close_quote)
 '])
 
 m5_DocFns(['printable_open_quote, printable_close_quote'], ['
  D: Produce the single unicode character used to represent `['` or `']` in output (STDOUT and STDERR).
  O: the printable quote
  A: (orig_open_quote, orig_close_quote)
 '])
 
 m5_DocFn(['UNDEFINED'], ['
  D: A unique untypeable value indicating that no assignment has been made.
  This is not used by any standard macro, but is available for explicit use.
  O: the value indicating "undefined"
  E: m5_var(Foo, m5_UNDEFINED)
  m5_if_eq(Foo, m5_UNDEFINED, ['['Foo is undefined.']'])
  R: Foo is undefined.
 '])
 
 ==== Slicing and Dicing Strings

 m5_DocFns(['append_var, prepend_var, append_macro, prepend_macro'], ['
  D: Append or prepend to a variable or macro. (A macro evaluates its context; a variable does not.)
  E: m5_var(Hi, ['Hello'])
  m5_append_var([', ']m5_Name['!']) /// equivalent to m5_var(Hi, ['Hello'][', ']m5_Name['!'])
  m5_Hi
  P: Hello, Joe!
 '], ...: )

 m5_DocFns(['substr, substr_eval, substr_inline'], ['
  D: Extract a substring from `String` starting from `Index` and extending for `Length` characters or to the end of the
  string if `Length` is omitted or exceeds the string length. The first character of the string has index 0.
  The result is empty if there is an error parsing `From` or `Length`, if `From` is beyond the end of the string,
  or if `Length` is negative.
  
  Extracting substrings from strings with quotes is dangerous as it can lead to imbalanced quoting.
  If the resulting string would contain any quotes, an error is reported suggesting the use of `dequote` and `requote`
  and the resulting string has its quotes replaced by control characters.
  
  Extracting substrings from UTF-8 strings (supporting unicode characters) is also dangerous. M5
  treats characters as bytes and UTF-8 characters can use multiple bytes, so substrings can split
  UTF-8 characters. Such split UTF-8 characters will result in bytes/M5-characters that have no
  special treatment in M5. They can be rejoined to reform valid UTF-8 strings.
  
  When evaluating substrings, care must be taken with `,`, `(`, and `)` because of their meaning in argument parsing.  
  
  `substr` is a slow operation relative to `substr_eval` and `substr_inline` (due to limitations of M4).
  O: the substring or its (possibly-inline) evaluation
  E: m5_substr(['Hello World!'], 3, 5)
  P: lo Wo
  A: (dequote, requote)
 '], String: the string, From: the starting position of the substring, ?Length: the length of the substring)

 m5_DocFn(join, ['
  O: the arguments, delimited by the given delimiter string
  E: m5_join([', '], ['new-line'], ['m5_nl'], ['macro'])
  P: new-line, m5_nl, macro
 '], Delimiter: text to delimit arguments, ...: arguments to concatenate (with delimitation))

 m5_DocFns(['translit, translit_eval'], ['
  D: Transliterate a string, providing a set of character-for-character substitutions (where a character
  is a unicode byte). `translit_eval` evaluates the resulting string.
  Note that `['` and `']` are internally single characters. It is possible to
  substitute these quotes (if balanced in the string and in the result) using `translit_eval` but not using `translit`.
  O: the transliterated string (or its evaluation for `translit_eval`)
  S: for `translit_eval` the side-effects of the evaluation
  E: m5_translit(['Testing: 1, 2, 3.'], ['123'], ['ABC'])
  P: Testing: A, B, C.
 '], String: the string to tranliterate, InChars: the input characters to replace, OutChars: the corresponding character replacements)

 m5_DocFns(['uppercase, lowercase'], ['
  D: Convert upper-case ASCII characters to lower-case.
  O: the converted string
  E: m5_uppercase(['Hello!'])
  P: HELLO!
 '], String: the string)

 m5_DocFn(replicate, ['
  D: Replicate a string the given number of times. (A non-evaluating version of `m5_repeat`.)
  O: the replicated string
  E: m5_replicate(3, ['.'])
  P: ...
  A: (repeat)
 '], Cnt: the number of repetitions, String: the string to repeat)

 ==== Formatting Strings
 
 m5_DocFn(format_eval, ['
  D: Produce formatted output, much like the C `printf` function. The `string` argument may contain `%`
  specifications that format values from `...` arguments.

  From the https://www.gnu.org/software/m4/manual/m4.html#Format[M4 Manual], `%` specifiers include
  `c`, `s`, `d`, `o`, `x`, `X`, `u`, `a`, `A`, `e`, `E`, `f`, `F`, `g`, `G`, and `%`. The following are also supported:
  
  - field widths and precisions
  - flags `+`, `-`, ` `, `0`, `#`, and `'`
  - for integer specifiers, the width modifiers `hh`, `h`, and `l`
  - for floating point specifiers, the width modifier `l`
  
  Items not supported include positional arguments, the `n`, `p`, `S`, and `C` specifiers, the `z`,
  `t`, `j`, `L` and `ll` modifiers, escape sequences, and any platform extensions available in the native printf (for example,
  `%a` is supported even on platforms that haven’t yet implemented C99 hexadecimal floating point output natively).
  
  For more details on the functioning of `printf`, see the C Library Manual, or the POSIX specification.
  O: the formatted string
  E: 1: m5_var(Foo, Hello)
     m5_format_eval(`The string "%s" uses %d characters.', Foo, m5_length(Foo))
  2: m5_format_eval(`%*.*d', `-1', `-1', `1')
  3: m5_format_eval(`%.0f', `56789.9876')
  4: m5_length(m5_format(`%-*X', `5000', `1'))
  5: m5_format_eval(`%010F', `infinity')
  6: m5_format_eval(`%.1A', `1.999')
  7: m5_format_eval(`%g', `0xa.P+1')
  P: 1: 
     The string "Hello" uses 5 characters.
  2: 1
  3: 56790
  4: 5000
  5:        INF
  6: 0X2.0P+0
  7: 20
 '], string: the string to format, ...: ['values to format, one for each `%` sequence in `string`'])

 ==== Inspecting Strings
 
 m5_DocFn(length, ['
  O: the length of a string in ASCII characters (unicode bytes)
 '], String: the string)
 
 m5_DocFn(index_of, ['
  O: the position in a string in ASCII characters (unicode bytes) of the first occurence of a given substring or -1 if not present, where the string starts with character zero
 '], String: the string, Substring: the substring to find)

 m5_DocFn(num_lines, ['
  O: the number of new-lines in the given string
 '], String: the string)

 ==== Safely Working with Strings

 m5_DocFns(['dequote, requote'], ['
  D: For strings that may contain quotes, working with substrings can lead to imbalanced quotes
  and unpredictable behavior. `dequote` replaces quotes for (different) control-character/byte quotes, aka "surrogate-quotes"
  that have no special meaning. Dequoted strings can be safely sliced and diced, and once reconstructed into
  strings containing balanced (surrogate) quotes, dequoted strings can be requoted using `requote`.
  O: dequoted or requoted string
 '], String: the string to dequote or requote)

 m5_DocFn(output_with_restored_quotes, ['
  O: the given string with quotes, surrogate quotes and printable quotes replaced by their original format ([''])
  A: (printable_open_quote, printable_close_quote)
 '], String: the string to output)

 m5_DocFn(no_quotes, ['
  D: Assert that the given string contains no quotes.
 '], String: the string to test)
 
 ==== Regular Expressions

 === Utilities
 
 ==== Fundamental Macros
 
 m5_DocFn(defn, ['
  O: the definition of a macro
 '], Name: the name of the macro)

 m5_DocFn(call, ['
  D: Call a macro. Versus directly calling a ` this indirect mechanism has two primary uses.
  First it provides a consistent syntax for calls with zero arguments as for calls with a non-zero
  number of arguments. Second, the macro name can be constructed conveniently.
  O: the output of the called macro
  S: the side-effects of the called macro
  E: m5_call(error, ['Fail!'])
  A: (comma_shift, comma_args, call_varargs)
 '], Name: the name of the macro to call, ...: the arguments of the macro to call)

 m5_DocFn(quote, ['                  
  O: a comma-separated list of quoted arguments, i.e. `$@`                   
  E: m5_quote(A, ['B'])
  P: ['A'],['B']
  A: (nquote)
 '], ...: arguments to be quoted)
 
 m5_DocFn(nquote, ['
  O: the arguments within the given number of quotes, the innermost applying individually to
  each argument, separated by commas. A `num` of `0` results in the inlining of `$@`.
  E: 1: m5_nquote(3, A, ['m5_nl'])
  2: m5_nquote(3, m5_nquote(0, A, ['m5_nl'])xx)
  P: 1: ['['['A'],['m5_nl']']']
  2: ['['['A'],['m5_nlxx']']']
  A: (quote)
 '], ...: )
 
 m5_DocFns(['eval, inline'], ['
  D: Evaluate the argument. For `m5_inline`, the resulting text is then evaluated together with subsequent text.
  O: the result of evaluating the argument
  S: the side-effects resulting from evaluation
  E: 1: m5_eval(['m5_calc(1 + 1)'])
  2: m5_eval(['m5_'])calc(1 + 1)
  3: m5_inline(['m5_'])calc(1 + 1)
  P: 1: 2
  2: m5_calc(1 + 1)
  3: 2
 '], Expr: the expression to evaluate)

 m5_DocFns(['comment, nullify'], ['
  O: nothing at all; used to provide a comment (though <<comments>> are preferred) or to discard the result of an evaluation
 '], ...: )

 ==== Manipulating Macro Stacks

 See <<stacks>>.

 m5_DocFns(['defn_ago, value_ago'], ['
  O: ['a former definition or value of a macro, or empty if not defined']
  E: *{
     var(Foo, A)
     var(Foo, B)
     ~defn_ago(Foo, 1)
     ~value_ago(Foo, 0)
  }
  P: ['A']
  B
 '], Name: macro name, Ago: ['0 for current definition, 1 for previous, and so on'])

 m5_DocFn(depth_of, ['
  O: the number of definitions in a macro's stack
  E: m5_depth_of(Foo)
  m5_push_var(Foo, A)
  m5_depth_of(Foo)
  P: 0
  
  1
 '], Name: macro name)

 ==== Argument Processing

 m5_DocFn(shift, ['
  D: Removes the first argument.
  O: a list of remaining arguments, or `['']` if less than two arguments
  S: none
  E: m5_foo(m5_shift($@))
  A: (comma_shift)
 '], ...: arguments to shift)

 /**
 m5_DocFn(, ['
  D: 
  O: 
  S: none
  E: 
  P: 
  A: ()
 '], ...: )
 **/

 ==== Arithmetic Macros
 
 ==== Boolean Macros
 
 These have boolean (`0` / `1`) results. Note that some <<m5_calc>> expressions result in boolean values as well.
 
 m5_DocFns(['is_null, isnt_null'], ['
  O: [`0` / `1`] indicating whether the value of the given variable (which must exist) is empty
 '], Name: the variable name)

 ==== Within Functions or Code Blocks
 
 m5_DocFns(['out, out_inline, out_eval'], ['
  D: For use as code block statements, these append to code block output (<<m5_block_output>>) to become
  the output of the code block. Note that `m5_out` is useful only in pathological cases of dynamically
  constructed code since the shorthand syntax `~(...)` is effectively identical to `~out(...)`.
  `~out_eval(...)` and `~out_inline(...)` capture block output that evaluates (after block evaluation).
  Note that these macros are not recommended for use in function blocks as functions have their own
  mechanism for side-effects. (See <<m5_on_return>>.)
  O: no direct output, though, since these indirectly result in output as a side-effect, it is recommended to use `~`
  statement syntax with these
  S: indirectly, `out_inline` and `out_eval` can result in the side-effects of their output expressions
  E: set_macro(ActiveMacroPrefix, [
     ~out_inline(Foo)
  ])
  ActiveMacroPrefix()Bar()
  A: (fn, --functions--, --code blocks--)
 '], String: the string to output)

 /**  deprecated; we'll instead support labels on all quotes
 m5_DocFn(WRAP, ['
  D: This has special behavior (from M4's `m4_dnl`). It, and all remaining characters on its line
  including the ending new-line are eliminated without evaluation. Other comment formats are preferred for
  commenting. It's primary use model is for performance-critical scoped traditional macros, as in the
  example below, where a macro is declared using a text block as its body for better performance
  than a function with a scoped code block body.
  E: fn(Foo, {
     macro(SetCoord, <p>['
        m5_set(x, ['$<p>1'])m5_WRAP
        m5_set(y, ['$<p>2'])
     '])
     SetCoord(1, 2)
     ...
  })
 '])
 **/

 m5_DocFn(eval_body_arg, ['
  D: Evaluate a body argument in the context of the caller....
  O: 
  S: none
  E: 
  P: 
  A: ()
 '], ...: )

 === Debugging

 ==== Writing to STDERR
 
 These macros output text to the standard error output stream (STDERR) (with `[{empty}'` / `'{empty}]` quotes represented by single characters).
 (Note that STDOUT is the destination for the evaluated output.)
 
 m5_DocFns(['warning, error, fatal_error, DEBUG'], ['
  D: Report an error/warning/debug message and stack trace (except for `DEBUG_if`).
  Exit for fatal_error, with non-zero exit code.
  E: m5_error(['Parsing failed.'])
 '], message: ['the message to report; (`Error:` pre-text (for example) provided by the macro)'])

 m5_DocFns(['warning_if, error_if, fatal_error_if, DEBUG_if'], ['
  D: Report an error/warning/debug message and stack trace (except for `DEBUG_if`) if the given condition is true.
  Exit for fatal_error, with non-zero exit code.
  E: m5_error_if(m5_Cnt < 0, ['Negative count.'])
 '], condition: ['the condition, as in `m5_if`.'], message: ['the message to report; (`Error:` pre-text (for example) provided by the macro)'])

 m5_DocFns(['assert, fatal_assert'], ['
  D: Assert that a condition is true, reporting an error if it is not, e.g. `Error: Failed assertion: -1 < 0`. Exit for fatal_error, with non-zero exit code.
  E: m5_assert(m5_Cnt < 0)
 '], message: ['the message to report; (`Error:` pre-text (for example) provided by the macro)'])

 m5_DocFns(['errprint, errprint_nl'], ['
  D: Write to STDERR stream (with a trailing new-line for `errprint_nl`).
  E: m5_errprint_nl(['Hello World.'])
 '], text: ['the text to output'])

 ==== Uncategorized Debug Macros
 
 m5_DocVar(recursion_limit, ['
  D: If the function call stack exceeds this value, a fatal error is reported.
 '])

 m5_DocFn(abbreviate_args, ['
  D: For reporting messages containing argument lists, abbreviate long arguments and/or a long argument list by replacing
     long input args and remaining arguments beyond a limit with ['...'].
  O: a quoted string of quoted args with a comma preceding every arg.
  E: m5_abbreviate_args(5, 15, $@)
 '], max_args: ['if more than this number of args are given, additional args are represented as ['...']'],
     max_arg_length: ['maximum length in characters to display of each argument'],
     ...: ['arguments to represent in output'])
'])



macro_inline(tail_doc, ['
 == Syntax Index

 M5 processes the following syntaxes:

 [cols="2,3,5a"]
 .Core Syntax
 |===
 |Use |Reference |Syntax

 |Vanishing comments
 |<<comments>>
 |`/{empty}//`, `/']['{empty}*{empty}*`, `{empty}*{empty}*']['/`

 |Preserved comments
 |<<comments>>
 |`//`

 |Quotes
 |<<quotes>>
 |`['`, `']`

 |Macro calls
 |<<calls>>
 |e.g. `m5_my_fn(arg1, arg2)`

 |Numbered/special parameters
 |<<numbered_params>>
 |`$` (e.g. `$3`, `$@`, `$#`, `$*`)
 |===

 Additionally, text and code block syntax is recognized when special quotes are opened at the end of a line or closed
 at the beginning of a line. See <<blocks>>. For example:

  error(*<blk>{
      ~(['Hello World!'])
  })

 Block syntax incudes:

 [cols="2,3,5a"]
 .Block Syntax
 |===
 |Use |Reference |Syntax

 |Code block quotes
 |<<code_blocks>>
 |`[`, `]`, `{`, `}` (ending/beginning a line)

 |Text block quotes
 |<<text_blocks>>
 |`['`, `']` (ending/beginning a line)

 |Evaluating Blocks
 |<<evaluating_blocks>>
 |`{empty}*[`, `[`, `{empty}*{`, `}`, `*['`, `']`

 |Statement with no output
 |<<statements>>
 |`foo`, `bar(...)` (`m5_` prefix implied)

 |Code block statement with output
 |<<bodies>>
 |`~foo`, `~bar(...)` (`m5_` prefix implied)

 |Code block output
 |<<bodies>>
 |`~(...)`
 |===

Though not essential, block labels can be used to improve maintainability and performance in extreme cases.

 [cols="2,3,5a"]
 .Block Label Syntax
 |===
 |Use |Reference |Syntax

 |Named blocks
 |<<named_blocks>>
 |`<foo>` (preceding the open quote, after optional `{empty}*`) e.g. `{empty}*<bar>{` or `<baz>[{empty}'`

 |Quote escape
 |<<escapes>>
 |`'{empty}]<foo>m5_Bar[{empty}'`

 |Labeled number/special parameter reference
 |<<labeled_parameters>>
 |`${empty}<foo>`, e.g. `${empty}<foo>2` or `${empty}<bar>#`
 |===

 Many macros accept arguments with syntaxes of their own, defined in the macro definition. Functions, for example are fundamental. See <<functions>>.

 [index]
 == Index

'])
\SV
m5_output_with_restored_quotes(m5_defn(main_doc))
m5_output_with_restored_quotes(m5_value_of(mac_spec))
m5_output_with_restored_quotes(m5_defn(tail_doc))
