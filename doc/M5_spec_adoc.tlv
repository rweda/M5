\m5_TLV_version 1d: tl-x.org
\SV
// This M5 spec is generated with the help of M5 itself.
// Since M5 syntax appears throughout, we have to be careful about M5's processing of this syntax
// with careful use of quotes, etc.

\m4

m4_define(['m5_main_doc'], ['= M5 Text Processing Language User's Guide
:toc: macro
:toclevels: 3
// Web page meta data.
:keywords:    Gnu, M4, M5, macro, preprocessor, TL-Verilog, Redwood +
              EDA, HDL
:description: M5 is a macro preprocessor on steroids. It is built on the simple principle of text +
              substitution but provides features and syntax on par with other simple programming languages. +
              It is an easy and capable tack-on to any text format as well as +
              a reasonable general-purpose programming language specializing in text processing. +
              Its broad applicability makes M5 a valuable tool in every programmer/engineer/scientist/AI's toolbelt.



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

[.text-center]
_To enrich any text format_

[.text-center]
M5 version 1.0, document subversion 1, 2023 +
by Steve Hoover, Redwood EDA, LLC +
(mailto:steve.hoover@redwoodeda.com[steve.hoover@redwoodeda.com])

This document is licensed under the https://creativecommons.org/publicdomain/zero/1.0/legalcode[CC0 1.0 Universal] license.

The M5 macro preprocessor enhances the Gnu M4 macro preprocessor,
adding features typical of programming languages.

toc::[]

== Background Information

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



=== M5's Place in the World

This section describes the history of and motivation for M5 and it's relation to M4 and TL-Verilog.


==== M5's Association with TL-Verilog

Although M5 was developed for TL-Verilog, it is not specifically tied to TL-Verilog.
It does, however, like all M4 libraries, depend upon a specific set of M4 syntax configurations,
and these configurations were chosen to best suit TL-Verilog.

The required M4 configurations are described in <<usage>>. These configurations
establish:

- builtin macro prefix: `m4_` (used by the M5 library, not by the end user)
- quote characters: `['` and `']`

TL-Verilog supports other TL-Verilog-specific macro preprocessing. Documentation can be found
within the https://makerchip.com[Makerchip IDE].


[[vs_m4]]
==== M5 Versus M4

M5 uses M4 to implement a macro-preprocessing language with some subtle philosophical
differences. While M4 is adequate for simple substitutions, M5 aims to preserve the conceptual simplicity of
macro preprocessing while adding features that improve readability and manageability of
more complex use cases.

M4 favors aggressive macro expansion, which frequently leads to the need for multiple levels
of nested quoting to prevent unintended substitutions. This leads to obscure bugs.
M5 implicitly quotes arguments and returned text, favoring explicit expansion.

==== M5 Above and Beyond M4

M5 contributes:

- features that feel like a typical, simple programming language
- literal string variables
- functions with explicit named arguments
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
through hoops to provide <<m_regex>> and <<m_substr>> (for strings of limited length)
that return quoted (literal) text, `m4_patsubst` cannot be fixed (though <<m_for_each_regex>>
is similar). The result of `m4_patsubst` can be quoted only by quoting the input string,
which can complicate the match expression, or by ensuring that all text is matched,
which can be awkward, and quoting substitutions.

In addition to these issues, care must be taken to ensure that resulting text does not contain mismatching
quotes or parentheses or combine with surrounding text to result in the same. Such
resulting mismatches are difficult to debug. M5 provides a notion of "unquoted strings"
that can be safely manipulated using <<m_regex>>, and <<m_substr>>.

Additionally the regex configuration used by M4 is quite dated. For example, it does
not support lookahead, lazy matches, and character codes.

===== Instrospection
Introspection is essentially impossible. The only way to see what is defined is to
dump definitions to a file and parse this file.

===== Recursion
Recursion has a fixed (command-line) depth limit, and this limit is not applied reliably.

===== Unicode
M4 is an old tool and was built for ASCII text. UTF-8 is now the most common text format.
It is a superset of ASCII that encodes additional characters as two or more bytes using byte
codes (0x10-0xFF) that do not conflict by those defined by ASCII (0x00-0x7F). All such bytes
(0x10-0xFF) are treated as characters by M4 with no special meaning, so these characters
pass through, unaffected, in macro processing like most others. There are two
implications to be aware of. First, <<m_length>> provides a length in bytes, not characters.
Second, <<m_substr>> and regular expressions manipulate bytes, not characters. This can
result in text being split in the mid-character, resulting in invalid character
encodings.

===== Debugging features
M4's facilities for associating output with input only map output lines to line numbers of
top-level calls. M4 does not maintain a call stack with line numbers.

M4 and M5 have no debugger to step through code. Printing (see <<m_DEBUG>> is the debugging mechanism of choice.

/**
==== M6

M6 would be rebuilt from scratch without the use of M4.
- m6() has 0 args; m6(['']) has 1 arg; m6(m6_shift(1)) has 0 args.
- No $ substitution if no arg list. In fact definitions should be distinct between vars and macros, so
it's always one use or the other.
- No @*
- `m6_` and quote chars are configurable as an attribute of quoted text or file as a whole. (If still M4 under the hood, `pre_m6`
would substitute it for a control character prefix, and M4 would be configured to recognize
this control character as a word.)
- No inline behavior of macros (`['']`) implied after macro definitions.
- Many of the M4 macros that return unquoted text would return quoted text, and other <<Limitations_of_M5>>
would be fixed as well.
- All m6_... are interpreted as a call; error reported if macro doesn't exist.

**/

=== M5 Status

Certain features documented herein, specifically <<Syntactic Sugar>>, currently work only in conjunction with the TL-Verilog macro preprocessor.
The intent is to support them in M5 itself, and they are documented with that in mind.


/** This is a bit overstated. So we get rid of ternary vs. if. Big whoop.
=== A Quick Taste

...

The same condintional macros can be applied to output text, strings, statements, and expressions, so there is less
syntax and fewer keywords to learn. Here we use the `if` (also referenced as <<m_if>>) macro in various contexts and compare
with a more traditional programming language syntax. `if`

Inline conditional text:

 There are m5_if(m5_BallCnt < 0, ['no'], ['m5_BallCnt']) balls remaining.
 
 print("There are " + ((ball_cnt < 0) ? "no" : ball_cnt) + "balls remaining.");

As a code statement producing output text:

 ~if(m5_BallCnt < 0, ['no'], ['m5_BallCnt'])

 print((ball_cnt < 0) ? "no" : ball_cnt);
 or
 out_str = out_str + ((ball_cnt < 0) ? "no" : ball_cnt);

As conditional execution:

 if(m5_BallCnt < 0, [
    set(BallCnt, 0)
 ])
 
 if (ball_cnt < 0) {
    ball_cnt = 0;
 }

As a conditional assignment:

 ~set(BallCnt, m5_if(m5_BallCnt < 0, ['0'], ['m5_BallCnt'])
 
 ball_cnt = (ball_cnt < 0) ? 0 : ball_cnt;

...
**/


[[usage]]
== Getting Started with the M5 Tool

[[config]]
=== Configuring M5

M5 adds a minimal amount of syntax, and it is important that this syntax is unlikely to conflict
with the target language syntax. The syntax that could conflict is listed in <<Ensure No Impact>>.
Currently, there is no easy mechanisms to configure this syntax.

/**
Most notably M5 introduces quote characters used to provide
literal text that is not subject to macro preprocessing. By default M5 uses `['` and `']`.
It can be configured to use different quote characters by modifying two simple scripts that
substitute quotes in the input and output files and configure M4 to use the substituted
quote characters. Similar scripts must be applied to all `.m4` files including the ones
that define M5 to change all `['` / `']` quotes to the desired quotes.

Additionally, M5 defines a comment syntax, `/{empty}//` and `/*{empty}*` / `*{empty}*/` that can be configured in the pre-preprocessing
script.
 **/


=== Running M5

Currently, M5 is bundled to run with TL-Verilog tool flows. The script that builds this documentation
can be consulted for example usage by way of TL-Verilog tool flows.

/**
The Linux command:

```sh
m5 < in-file > out-file
```

(TODO: Provide m5 script that does `--prefix_builtins`.)

runs M5 in its default configuration.
**/

=== Ensure No Impact

When enabling the use of M5 on a file, first, be sure M5 processing does nothing to the file. As used for TL-Verilog,
M5 should output the input text, unaltered, as long as your file contains no:

- quotes, e.g. `['`, `']`)
- `m5_` or `m4_`
- M5 comments, e.g. `/{empty}//`, `/*{empty}*`, `*{empty}*/`
- (and specific to TL-Verilog: `\TLV`)
- (mismatched parentheses may result in warnings)

In other configurations, the following may also result in processing:

- code blocks, e.g. `[` or `{` followed by a newline or `]` or `}` beginning a line after optional whitespace



== An Overview of M5 Concepts

=== Macro Preprocessing in General

Macro preprocessors extend a target programming language, text format, or any arbitrary text with the ability to define
and call (aka instantiate, invoke, expand, evaluate, or elaborate) parameterized macros that provide
text substitutions. Macros are generally used to provide convenient shorthand for commonly-used constructs.
Macro preprocessors processes a text file sequentially with a default behavior of passing
the input text through as output text. When a macro name is encountered, it and its argument list are substituted
for new text according to its definition.

M5 provides convenient syntax for macro preprocessing as well as programatic text processing, sharing the same
macros for each. This provides advanced text manipulation to supercharge any language or text format, or it can be used to
fully process any text format.


=== Macros Overview

In source context, a macro that simply outputs a static text string can be defined like this:

 m5_macro(hello, Hello World!)

And called like this:

 m5_hello()

Resulting in:

 Hello World!

Macros can also be parameterized. Here we define a macro that outputs a string with a single
parameter referenced as `${empty}1`:

 m5_macro(hello, Hello $1!)

And call it like this:

 m5_hello(World)

Resulting in:

 Hello World!

For more details on macro syntax, see <<Declaring Macros>>, <<Calling Macros>>, and <<Macro Arguments>>.


=== Quotes Overview

Quotes (`['` and `']`) may be used around text to prevent substitutions. For example, to provide
a macro whose result includes a comma, quotes are needed:

 m5_macro(hello, ['Hello, $1!'])

Without these quotes, the comma in `Hello, $1!` would be interpreted as a macro argument separator.

Furthermore, a second level of quotes may be needed to prevent the interpretation of the comma after
substitution:

 m5_macro(hello, ['['Hello, $1!']'])
 m5_hello(World)

The call substitutes with `['Hello, World!']` (actually `['Hello, World!']['']`), which elaborates to the literal text:

 Hello, World!

For more details on quote use, see <<quotes>>.


=== Variables Overview

Variables hold string values. They can be thought of as macros without arguments. They are defined as:

 m5_var(Hello, ['Hello, World!'])
 m5_var(Age, 23)

And used as:
   
 m5_Hello I am m5_Age years old.

Resulting in:
   
    Hello, World! I am 23 years old.

Variables are always returned as literal strings, so a second level of quoting is
not required for the definition of `Hello`.

Variables are scoped, and by convention, scoped
definitions are named in camel case (strictly speaking, Pascal case).

For more details on variable use, see <<variables>> and <<variable_sugar>>.


=== Macro Stacks

All macros and variables, are actually stacks of definitions that can be pushed and popped. (These
stacks are frequently one entry deep.) The top definition is active, providing the replacement text when
the macro/variable is instantiated. The others are only accessible by popping the stack.
Pushing and popping are not generally done explicitly, but rather through scoped declarations. See <<Scoped Code Blocks>>.


=== Code Syntax Overview

The above syntax is convenient in "source context", embedded into another language. It is clear where substitutions
occur because all macro calls and variables are referenced with an `m5_` prefix. This syntax, however, quickly becomes
clunky for any substantial text manipulation, requiring excessive `m5_`-prefixing.
Additionally, it is difficult to format code readably because carriage returns and other whitespace are generally
taken literally. This results in single-line syntax with many levels of nesting that quickly become difficult
to follow.

Code regions can be defined (using target-language-specific syntax) within which code syntax is supported.

Take for example this one-line definition in source context of an `assert` macro:

 m5_macro(assert, ['m5_if(['$1'], ['m5_error(['Failed assertion: $1.'])'])'])

In code context, this can be written equivalently (though with a slight performance impact) as:

 macro(assert, {
    if(['$1'], [
       error(['Failed assertion: $1.'])
    ])
 })

The `m5_` prefix is implied at the beginning of each code "statement".

For more details, see <<code_blocks>>.


=== Functions and Scope Overview

M5 also provides a syntax for function declarations with named parameters. The assert macro can be
defined as a function as:

 fn(assert, Expr, {
    if(m5_Expr, [
       error(Failed assertion: m5_Expr.)
    ])
 })

Like any respectable programming language, `Expr`, above, is local to the function.
Functions and other macros may produce result text (see <<Function Output Example>> and <<code_blocks>>). They may also produce
side effects including variable declarations (see <<Aftermath>>) and STDERR output (see <<m_error>>).

For more details on functions, see <<Functions>>. For more details on scope, see <<scope>>.


=== Function Output Example

We can add output text to this function indicating assertion failures in the resulting text:
   
 fn(assert, Expr, {
    ~if(m5_Expr, [
        error(Failed assertion: m5_Expr.)
        ~(Failed assertion: m5_Expr.)
    ])
  })

Statements producing output are prefixed with a tilde (`~`).


=== Libraries and Namespaces Overview

M5 has a simple and effective import mechanism where a macro library file is simply imported by its URI
(URL or local file). Libraries can be imported into their own namespace (though this mechanism is not
yet implemented).

/// For more details on libraries, see <<Libraries>>. For more details on namespaces, see <<Namespaces>>.


=== Processing Steps

Several of the above constructs, including code blocks and statements are termed "syntactic sugar" and
are processed in a first pass before macro substitution--yes as a pre-preprocessing step.

M5 processing involves the following (ordered) steps:

 * Substitute quotes for single control characters.
 * Process syntactic sugar (in a single pass):
 ** Strip M5 comments.
 ** Process other syntactic sugar, including block and label syntax.
 ** Process pragmas; check indentation and quote/parenthesis matching.
 * Write the resulting file.
 * Run M4 on this file (substituting macros).


== Sugar-Free M5 Details

=== Defining Sugar-free

M5 can be used "sugar-free". It's just a bit clunky for humans. Syntactic sugar is recognized in the
source file. Text that is constructed on the fly and evaluated (e.g. by <<m_eval>>) is evaluated sugar-free.


[[quotes]]
=== Quotes

Unwanted processing, such as macro substitution, can be avoided using quotes. By default, these are `['`
and `']` (and a configuration mechanism is not yet available to change this).
Like syntactic sugar, they are recognized only when they appear in a
source file and cannot be constructed from their component characters. Quotes, however, are an essential
part of M5, not a syntactic convenience.

Quoted text begins with `['`. The quoted text is parsed only for `['` and `']` and
ends at the corresponding `']`. The quoted text passes through to the
resulting text, including internal matching quotes, without any
substitutions. The outer quotes themselves are discarded.
The end quote acts as a word boundary for subsequent text processing.

Within quotes, intervening
characters that would otherwise have special treatment, such as commas, parentheses, and `m5_`-prefixed
words (after sugar processing), have no special treatment.

Quotes can be used to delimit words. For example, the empty quotes below:

 Index['']m5_Index

enable `m5_Index` to substitute, as would:

 ['Index']m5_Index

(`Index/m5_Index` is a shorthand for this. See <<prefix_escapes>>.)

Quotes can also be used to avoid the interpretation of `m5_foo` as syntactic sugar. (See <<Macro Call Sugar>>.)

Special syntax is provided for multi-line literal quoted text. (See <<Code Blocks>>.) Outside of those
constructs, quoted text should not contain newlines since newlines are used to format code.
Instead, the <<m_nl>> variable (or macro) provides a literal newline character, for example:

 m5_DEBUG(['Line:']m5_nl['  ']m5_Line)


[[variables]]
=== Variables

A variable holds a literal text string. Variables are defined using: <<m_var>>, are reassigned using <<m_set>>,
and are accessed using <<m_get>>. For example:

 m5_var(Foo, 5)
 m5_set(Foo, m5_calc(m5_Foo + 1))
 m5_get(Foo)   /// Yields: "6"

Syntactic sugar provides variable access using, e.g., `m5_Foo` rather than `m5_get(Foo)`. (See <<variable_sugar>>.)


=== Declaring Macros

 m5_macro(echo, ['['$1']'])

 m5_echo(['Hello, World!'])

substitutes with `['Hello, World!']`, and this elaborates as `Hello, World!`.

/**
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
**/

The most direct way to declare a macro is with <<m_macro>>. For example:

 m5_macro(foo,
    ['['Args:$1,$2']'])

This defines the macro body as `['Args:$1,$2']`.

A macro call returns the body of the macro definition with numbered parameters substituted with
the corresponding arguments. Dollar parameter substitutions are made throughout the entire body
string regardless of the use of quotes and adjacent text. The result is then evaluated, so these macros can perform
computations, assign variables, provide argument lists, etc. In this case, the body is quoted, so
its resulting text is literal. For example:
 
 m5_foo(A,B)     ==> Yields: "Args:A,B"

A few special dollar parameters are supported in addition to numbered parameters. The following
notations are substituted:

- `${empty}1`, `${empty}2`, etc.: These substitute with corresponding arguments.
- `${empty}#`: The number of arguments.
- `${empty}@`: This substitutes with a comma delimited list of the arguments, each quoted so as to be
        taken literally. So, `m5_macro(foo, ['m5_bar(${empty}@)'])` is one way to define `m5_foo(...)` to have the
        same behavior as `m5_bar(...)`.
- `${empty}*`: This is rarely useful. It is similar to `${empty}@`, but arguments are unquoted.
- `${empty}0`: The name of the macro itself. It can be convenient for making recursive calls
       (though see <<m_recurse>>). `${empty}0__` can also be used as a name prefix to localize a macro name
       to this macro, though this use model is discouraged. (See <<masking>>.)
       For <<Functions>>, `${empty}0` is the internal name holding the function body. It should not
       be used for recursion but can be used as a unique prefix.

CAUTION: Macros may be declared by other macros in which case the inner macro body appears within
the outer macro body. Numbered parameters appearing in the inner body would be substituted as
parameters of the _outer_ body. It is generally not recommended to use numbered
parameters for arguments of nested macros, though it is possible. For more on the topic,
see <<block_labels>>.

A richer declaration mechanism is provided by <<m_fn>>. (See <<Functions>>.)


=== Calling Macros

The following illustrates a call of the macro named `foo`:

 m5_foo(hello, 5)

NOTE: When this syntax appears in a source file, it is recognized as syntatic sugar and is processed
to provide additional checking. Here, we specifically descibe the processing of this syntax when
constructed from other processing, noting that syntactic sugar results in similar behavior. (See. <<Macro Call Sugar>>.)

A well-formed M5 macro name is comprised of one or more word
characters (`a-z`, `A-Z`, `0-9`, and `_`).

When elaboration encounters (in unquoted text and without a preceding word character or immediately following
another macro call) `m5_`, followed immediately by the
well-formed name of a defined macro, followed immediately by `(` (e.g. `m5_foo(`) an argument list (see <<arguments>>) is processed,
then the macro is "called" (or "expanded"). `$` substitutions are performed on the macro body (see <<Declaring Macros>>), the
resulting text replaces the macro name and argument list followed by an implicit `['']` to create a word boundary,
and elaboration is resumed from the start of this substituted text.

Macro names should not be encountered without an argument list. Though this would result in calling the
macro with zero arguments, it is discouraged due to the syntactic confusion with variables. Macros
can be called with zero arguments using `m5_call(macro_name)` instead. (See <<m_call>>.)

NOTE: Though discouraged, it is possible to define macros with names containing non-word characters.
Such macros can only be called indirectly (e.g. `m5_call(b@d, args)`). (See <<m_call>>.)

NOTE: In addition to `m5_` macros,
the M4 macros from which M5 is constructed are available, prefixed by `m4_`, though their
direct use is discouraged and this document does not describe their use. Elaboration of the string `m4_`
should by avoided.


[[arguments]]
=== Macro Arguments

Macro calls pass arguments within `(` and `)` that are comma-separated.
For each argument, preceding whitespace is not part of the argument, while postceding whitespace
is. Specifically, the argument list begins after the unquoted `(`. Subsequent text is elaborated
sequentially (invoking macros and interpreting quotes). The text value of the first argument begins
at the first elaborated non-whitespace charater following the `(`. Unquoted `(` are counted as
an argument is processed. An argument is terminated by the first unquoted and non-parenthetical
`,` or `)` in the resulting elaborated text. A subsequent argument, similarly,
begins with the first non-whitespace character following the `,` separator. Whitespace includes
spaces, newlines, and tabs. An unquoted `)` ends the list.

Some examples to illustrate preceding and postceding whitespace and nested macros:

If, `m5_foo(A,B)` echoes its arguments to produce literal text `{A;B}`, then:
 
 m5_foo(  A,  B)          ==> Yields: "{A;B}"
 m5_foo(    ['']  A,B)    ==> Yields: "{  A;B}"
 m5_foo(  A  ,  B  )      ==> Yields: "{A  ;B  }"
 m5_foo(m5_foo(A, B), C)   ==> Yields: "{{A;B};C}"
 m5_foo(m5_foo([')'],B),C)==> Yields: "{{);B};C}"  (with a warning about unbalanced parentheses)

Arguments can be empty text, such as `()` (one empty argument) and `(,)` (two empty arguments).
Note that the use of quotes is prefered for clarity. For example, `([''])` and
`([''], [''])` are identical to the previous cases.

The above syntax does not permit macro calls with zero arguments, but `m5_call(macro_name)` can be used
for this purpose. (See <<m_call>>.)

Be aware that when argument lists get long, it is useful to break them up on multiple lines. The newlines
should precede, not postcede the arguments, so they are not included in the arguments. E.g.:

 m5_foo(long-arg1,
        long-arg2)

Notably, the closing parenthesis should *not* be on a the next line by itself. This would include the
newline and spaces in the second argument.



== Syntactic Sugar

=== Comments

==== M5 Comments (`/{empty}//` and `/{empty}*{empty}*`...`{empty}*{empty}*/`)

M5 comments are one form of syntactic sugar. They look like:

 /']['// This line comment will disappear.
 /*']['* This block comment will also disappear. *']['*/

Block comments begin with `/{empty}*{empty}*` and end with `{empty}*{empty}*/`. Line comments
begin with `/{empty}//` and end with a newline. Both are stripped prior to any other processing.
As such:

- M5-commented parentheses and quotes are not visible to parenthesis and quote matching checks, etc.
- M5 comments may follow the `[` or `{` beginning a code block or after a comma and prior to an argument
that begins on the next line without affecting the code block or argument.

Whitespace preceding a line comment is also stripped. Newlines from block comments are preserved.

NOTE: Text immediately following `{empty}*{empty}*/` may, after stripping the comment, begin the line.
Comments are stripped before indentation checking. It is thus generally recommented that multi-line block comments
end with a newline.

In case `/{empty}//` or `/{empty}*{empty}*` are needed in the resulting file, quotes can be used, e.g.: `['//']['/']`, to
disrupt the syntax.


==== Target-Language Comments (E.g. `//`)

Comments in the target language are not recognized as comments by M5. To disable
M5 code, it is important to use M5 comments, not target-language comments. (Thus it can be especially
problematic when one's editor mode highlights target-language comments in a manner that suggests the
code has no impact.)


[[statement_comments]]
==== Statement Comments (E.g. `/`)

These are specific to <<code_blocks>>, introduced later.


[[macro_sugar]]
=== Macro Call Sugar

`m5_foo(` is syntactic sugar for `m5_call(foo,`. (See <<m_call>>.) This transformation
(as long as it is evaluated) has no impact other than to verify that the macro exists.
`m5_foo(` should not appear in literal text that is never to be evaluated as it would
get undesirably sugared. (See <<quotes>> and <<prefix_escapes>> for syntax to avoid undesired sugaring.)

NOTE: The M5 processor may avoid applying this sugar for common macros from the M5 core library that are
known to exist.


[[variable_sugar]]
=== Variable Sugar

`m5_Foo` (without a postceding `(`) is syntactic sugar for `m5_get(Foo)`. (See <<m_get>>.)
`m5_Foo` should not appear in literal text that is never to be evaluated as it would
get undesirably sugared. (For syntax to avoid undesired sugaring, see <<quotes>> and <<prefix_escapes>>.)


[[prefix_escapes]]
=== Backslash Word Boundary (`m5_\` and `\m5_`)

As more convenient alternatives to quotes:

  - `m5_\foo` results in `m5_foo` without interpretation as syntactic sugar. It should be used in literal contexts that are not evaluated.
  - `\m5_foo` is shorthand for `['']m5_` to provide a word boundary, enabling M5 processing of `m5_foo`.


[[bodies]]
=== Multi-line Constructs: Blocks and Bodies

==== What are Bodies and Blocks?

A "body" is a parameter or macro value that is to be be evaluated in the context of a caller.
Macros, like <<m_if>> and <<m_loop>> have "immediate" body parameters. These bodies are to be evaluated
by calls to these macros themselves. The final argument to a function or macro declaration
is an "indirect" body argument. This body is to be evaluated, not by the declaration macro itself, but by the
caller of the macro it declares.

NOTE: Declaring macros that evaluate body arguments requires special consideration. See <<body_arguments>>.

<<Code Blocks>> are convenient syntactic sugar constructs for multi-line body arguments formatted like code.

<<Text blocks>> are syntactic sugar for specifying multi-line blocks of arbitrary text, indented with
the code.

==== Macro Bodies

A body argument can be provided as a quoted string of text:

 m5_if(m5_A > m5_B, ['['Yes, ']m5_A[' > ']m5_B'])   /// Might result in "Yes, 4 > 2".

Note that the quoting of `['Yes, ']` prevents misinterpretation of the `,` as an argument separator
as the body is evaluated.

This syntax is fine for simple text substitutions, but it is essentially restricted to a single line
which is unreadable for larger bodies that might define local variables, perform calculations,
evaluate code conditionally, iterate in loops, call other functions, recurse, etc.

[[code_blocks]]
==== Code Blocks

M5 supports special multi-line syntactic sugar convenient for body arguments, called "code blocks". These look more
like blocks of code in a traditional programming language. Aside from comments and whitespace, they
contain only macro calls and variable elaborations ("statements"). The resulting text of the code block is constructed from the results
of these macro calls.

The code below is equivalent to the example above, expressed using a code body (and assuming it is
itself called from within a code body).

 /Might result in "Yes, 4 > 2".
 ~if(m5_A > m5_B, [
    ~(['Yes, '])
    ~A
    ~([' > '])
    ~B
 ])

The block begins with `[`, followed immediately by a newline. It ends with a line that begins with `]`,
indented consistently with the beginning line. The above code block is "unscoped". A "scoped" code block
uses, instead, `{` and `}`. Scopes are detailed in <<scope>>.

The first non-blank line of the block determines the indentation of the block. Indentation uses spaces;
tabs are discouraged, but must be used consistently if they are used. All non-blank lines at this level
of indentation (after stripping M5 comments) begin a "statement".
Lines with deeper indentation would continue a statement. A continuation line either begins a macro argument
or is part of its own (nested) code block argument.

Essentially, the body, when evaluated, results in the text produced by its statements, which are macros or
variables, listed without their `m5_` prefix, or inline text.

Specifically, statements can be:

  - Macro calls, such as `~if(m5_A > m5_B, ...)`.
  - Variable elaborations, such as `~A`.
  - Output statements, such as `~(['Yes, '])`.
  - Comments, such as `/A comment`.

Statements that produce output (as all statements in the above example's code block do) must be preceded by `~`
(and others may be). This simply helps to identify
the source of code block ouput. The `~(...)` syntax produces the given text. A `m5_` prefix is implicit on statements.
In the rare (and discouraged) event that a macro without this prefix is to be called, such as use of an `m4_`
macro, using `~out(m4_...)` will do the trick.

The earlier example behaves the same as:

 m5_out(m5_if(m5_A > m5_B, m5__block(['
    m5_out(['Yes, '])
    m5_out(m5_get(A))
    m5_out([' > '])
    m5_out(m5_get(B))
 ']))

The (internal) `m5__block` macro evaluates its argument and results in any text captured by `m5_out`.  

Top-level M5 content (in TL-Verilog, the content of an `\m5` region) is formatted as a non-scoped
code block with no output.


[[scope]]
==== Scoped Code Blocks

Scoped <<Code Blocks>> are delimited by `{` / `}` quotes.
Within a code block, variable declarations (e.g. made by <<m_var>>) are scoped. Their definitions are pushed by the declaration, and
popped at the end of their scope. (See <<Macro Stacks>> regarding pushing and popping.)

It is recommended that all indirect body arguments (see <<bodies>>), such as those of <<m_fn>> be scoped. Immediate body
arguments (see <<bodies>>), such as those of <<m_if>>, are most often unscoped, but scope may be used to isolate the side
effects of the block to explicit <<m_out_eval>> calls. Scoped and unscoped blocks are illustrated in the following example:

 fn(check, Cond, {
    if(m5_Cond, [
        warning(Check failed.)
    ])
 )}

Declarations from outer scopes are visible in inner scopes. Similarly, declarations from calling scopes
are visible in callee scopes, though functions should generally be written without any assumptions about the calling
scope. Exceptions should be clearly documented/commented.

NOTE: It is fine to redeclare a variable in the same scope. The redeclaration will override the first,
and both definitions will be popped after evaluating the code block. Notably, a variable may be
conditionally declared without any negative consequence on stack maintenance.

By convention, scoped variables and macros use Pascal case, e.g. `MyVar`. (See <<Macro Naming Conventions>>.)


[[text_blocks]]
==== Text Blocks

"Text blocks" provide a syntax for multi-line quoted text that is indented with its surroundings.
They are formatted similarly to code blocks, but use standard (`['` / `']` ) quotes. The openning quote
must be followed by a newline and the closing quote must begin a new line that is indented consistently
with the line beginning the block. Their indentation is defined by the first non-blank line in the block.
All lines must contain at least this indentation (except the last). This fixed level of indentation
and the beginning and ending newline are removed. Aside from the removal of this whitespace, the
text block is simply quoted text containing newlines. For example:

   macro(copyright, ['['
      Copyright (c) 20xx
      All rights reserved.
   ']'])

There is no parsing for code and text blocks
as well as label syntaxes within text blocks. There is parsing of M5 comments, quotes, and parentheses
(counting) and quotes are recognized (and, of course, number parameter substitutions will occur for a text block that is elaborated as
part of a macro body).

==== Evaluate Blocks

It can be convenient to form non-body arguments by evaluating code. Syntactic sugar is provided for
this in the form of a `*` preceding the block open quote.

For example, here a scoped evaluate code block is used to form an error message by searching for
negative arguments:

 error(*{    /// like:  error(m5_eval({
    ~(['Arguments include negative values: '])
    var(Comma, [''])
    ~for(Value, ['$@'], [
       ~if(m5_Value < 0, [
          ~Comma
          set(Comma, [', '])
          ~Value
       ])
    ])
    ~(['.'])
 })


[[block_labels]]
==== Block Labels: Escaping Blocks and Labeled Numbered Parameters

Proper use of quotes can get a bit tedious, especially when it is necessary to escape out of several
levels of nested quotes. It can improve maintainability, code clarity, and
performance to make judicious use of block labels. Note, however, that *the need for block labels is
rare* and is mostly replaced by mechanisms provided by <<Functions>>.

Blocks can be labeled using syntax such as:

 macro(my_macro, ..., <sf>{
 })

Labels can be used in two ways.

- First, to escape out of a block, typically to generate text of the block.
- Second, to specify the block associated with a numbered parameter.

Both use cases are illustrated in the following example that attempts to declare a macro for parsing text.
This macro declares a helper macro `ParseError` for reporting parse errors that can be
used many times by `my_parser`.

 /Parse a block of text.
 macro(my_parser, {
    var(Text, ['$1'])  //']['/ Text to parse
    var(What, ['$2'])  //']['/ A description identifying what is begin parsed
    /Report a parse error, e.g. m5_ParseError(['unrecognized character'])
    macro(ParseError, {
       error(['Parsing of ']m5_What[' failed with: "$1"'])  /// !!! TWO MISTAKES !!!
    })
    ...
 })

This code contains, potentially, two mistakes in the error message. First, `m5_What` will be
substituted at the time of the call to `ParseError`. As long as `my_parser` does not
modify the value of `What`, this is fine, but it might be preferred to expand `m5_What` in
the definition itself to avoid this potential <<masking>> issue in case `What` is reused.

Secondly, `${empty}1` will be substituted upon calling `my_parser`, not upon calling `ParseError`,
and it will be substituted with a null string.

The corrected example would use:

 macro(ParseError, <err>{
    error(['Parsing of ']<err>m5_What[' failed with: "$<err>1"'])  /']['// 2 Fixes!
 })

This code corrects both issues:

 

- `'{empty}]<err>m5_What[{empty}'`: This syntax acts in this case
as `'{empty}]'{empty}]m5_nquote(1,m5_get(What))[{empty}'[{empty}'`, escaping enough
levels of quoting to evaluate `m5_What` in the text of the `err` block and having the effect of
using the definition of `m5_What` at the time of the macro definition. (The added level of quotes
corresponds to the `{` / `}` block quotes which are sugar for `['` / `']`.)
- `$<err>1`: This syntax associates `${empty}1` with the `err` block and is in this example
equivalent to `'{empty}]'{empty}]m5_nquote_dollar(1,1)[{empty}'[{empty}'`.


[[pragmas]]
[[checks]]
=== Syntax Checks and Pragmas

[[indentation_checks]]
==== Indentation Checks

M5 checks that indentation is consistent for code and text blocks.


[[matching]]
==== Quote and Parenthesis Matching

M5 checks that quotes (including `[` / `]` and `{` / `}` quotes for code blocks) are balanced.
This is done after comments are stripped. `']` / `['` quotes may be used to escape from block quotes within a line.

M5 checks that parentheses are balanced within block quotes. This is done after comments are stripped.


==== Pragmas

In certain cases quote and parenthesis checking gets in the way. It is possible to disable checking and control debug behavior using pragmas.
Pragmas processing happens after M5 comments are stripped. The following strings are recognized as pragmas:

  * `where_am_i`: Prints the current quote context to STDERR.
  * `[enable/disable]_debug`: Improves the readability of the file resulting from sugar processing, and continues processing after normally-fatal errors.
  * `[enable/disable]_paren_checks`: Enables or disables parenthesis tracking and reporting. Enabling and disabling should be done at matching levels.
  * `[enable/disable]_quote_checks`: Enables or disables reporting of quote mismatches.
  * `[enable/disable]_verbose_checks`: Enables or disables verbose checking.

Since the pragmas would pass through to the target file, pragmas are generally expressed using the following macro calls
which elaborate to nothing:

  * `m5_pragma_{empty}where_am_i()`
  * `m5_pragma_[enable/disable]_{check}()`, where `{check}` is `debug`, `paren_checks`, `quote_checks`, or `verbose_checks`.


== Coding Practices

=== Coding Conventions

[[status]]
=== Status

The variable <<v_status>> has a reserved usage. Some macros are defined to set <<v_status>>. A non-empty
value indicates that the macro did not perform its duties to the fullest. Several `m5_if*` macros set non-empty
status if they do not evaluate a body.

Macros such as <<m_else>> and <<m_if_so>> take action based on <<v_status>>.

Well-behaved macros set <<v_status>> always or never (and never is the assumption if no side effect is listed in a
macro's documentation). Thus <<v_status>> is more like a return value than
a sticky flag. Sticky behavior can be achieved using <<m_sticky_status>>. There is no support for try-catch-like
error handling. In bodies of <<m_macro>> it may be necessary to explicitly save and restore status to avoid unintended
side-effects on <<v_status>> from calls within the bodies. <<m_fn>> does this automatically. If <<v_status>> is checked, it is
generally checked immediately after a call.


=== Functions

All but the simplest of macros are most often declared using `m5_fn` and similar macros. These support a richer set of
mechanisms for defining and passing parameter. While `m5_macro` is most often used with a one-line body definition,
`m5_fn` is most often used with multi-line bodies as <<Scoped Code Blocks>>.

Such `m5_fn` declarations using <<Scoped Code Blocks>> look and act like functions/procedures/subroutines/methods in a traditional
programming language, and we often refer to them as "functions". Function calls pass arguments into parameters. Functions'
code block bodies contain macro calls (statements) that define local variables, perform calculations, evaluate code conditionally,
iterate in loops, call other functions, recurse, etc.

Unlike typical programming languages, functions, like all macros, evaluate to text that substitutes for the calls.
There is no mechanism to explicitly print to the standard output stream (though there
are macros for printing to the standard error stream). Only a top-level call from the source code will
implicitly echo to standard output.

Functions are defined using: <<m_fn>> and <<m_lazy_fn>>.

Declarations take the form:

 m5_fn(<name>, [<param-list>,] ['<body>'])

A basic function declaration with a one-line body looks like:

 m5_fn(mul, val1, val2, ['m5_calc(m5_val1 * m5_val2)'])

Or, equivalently, using a code block body:
   
 fn(mul, val1, val2, {
    ~calc(m5_val1 * m5_val2)
 })

This `mul` function is called (in source context) like:

 m5_mul(3, 5)  //']['/ produces 15

==== Parameters

===== Parameters Types and Usage

- *Numbered parameters*: Numbered parameters, as in <<m_macro>> (see <<Declaring Macros>>), can be referenced as `$1`, `$2`, etc. with
                         the same replacement behavior. However, they
                         are explicitly identified in the parameter list (see <<parameter_list>>).
                         Within the function body, similar to `['$3']`, <<m_fn_arg>> may also be used to access an argument. For example,
                         `m5_fn_arg(3)` evaluates to the literal third argument value.
- *Special parameters*: As for <<m_macro>>, special parameters are supported. Note that: `${empty}@`, `${empty}*`, and `${empty}#` reflect only
                        numbered parameters. Also, `${empty}0` will not have the expected value, however `${empty}0__` can still be
                        used as a name prefix to localize names to this function. (See <<masking>>.) Similar to `${empty}@`, the <<m_fn_args>> macro
                        (or variable) also provides a quoted list of the numbered arguments.
                        Similar to `${empty}#`, the <<m_fn_arg_cnt>> macro also provides the number of numbered arguments.
- *Named parameters*: These are available locally to the body as variables. They are not available to the <<Aftermath>> of
                      the function.

[[parameter_list]]
===== The Parameter List

The parameter list (`<param-list>`) is a list of zero or more `<param-spec>`{empty}s, where `<param-spec>` is:

- A parameter specification of the form: `[?][[<number>]][[^]<name>][: <comment>]` (in this order), e.g. `?[2]^Name: the name of something`:
  * `<name>`:   Name of a named parameter.
  * `?`:        Specifies that the parameter is optional. Calls are checked to ensure that arguments are provided for all non-optional parameters
                or are defined for inherited parameters. Non-optional parameters may
                not follow optional ones.
  * `[<number>]`: Number of a numbered parameter. The first must be `[1]` and would correspond to `$1` and `m5_fn_arg(1)`, and so on.
                  `<number>` is verified to match the sequential ordering of numbered parameters. Numbered parameters may
                  also be named, in which case they can be accessed either way.
  * `^`:        Specifies that the parameter is inherited. It must also be named. Its definition is inherited from the context of the func definition.
                If undefined, the empty `['']` value is provided and an error is reported unless the parameter is optional,
                e.g. `?^<name>`. There is no corresponding argument in a call of this function. It is conventional to list
                inherited parameters last (before the body) to maintain correspondence between the parameter
                list of the definition and the argument list of a call.
  * `<comment>`: A description of the parameter. In addition to commenting the code, this can be extracted in
                documentation./** See <<m_enable_doc>>.**/
- `...`:        Listed after last numbered parameter to allow extra numbered arguments. Without this, extra arguments
                result in an error (except for the single empty argument of e.g. `m5_foo()`. See <<fn_arguments>>.)

==== When To Use What Type of Parameter

For nested declarations, the use of numbered parameters (`${empty}1`, `${empty}2`, ...) and special parameters
(`${empty}@`, `${empty}*`, `${empty}#`, and `${empty}0`) can be extremely awkward.
Nested declarations are declarations within the bodies of other declarations. Since nested bodies are part of outer bodies,
numbered and special parameters within them would actually substitute based on the outer bodies. This can be prevented
by generating the body with macros that produce the numbered parameter references, but this requires an unnatural and bug prone use of quotes.
Therefore the use of functions with named parameters is preferred for inner macro declarations. Use of <<m_fn_args>> and <<m_fn_arg>> is
also simpler than using special parameters. If parameters are named, these are helpful primarily
to access `...` arguments or to pass argument lists to other functions.

Additionally, and in summary:

- *Numbered/special parameters*: These can be convenient to ensure substitution throughout the body without interference from
                         quotes. They can, however, be extremely awkward to use in nested definitions
                         as they would substitute with the arguments of the outer function/macro. Being unnamed,
                         readability is an issue, especially for large functions.
- *Named parameters*: These act more like typical function arguments vs. text substitution. Since they are named, they
                      can improve readability. Unlike numbered parameters, they work perfectly well in functions
                      defined within other functions/macros. (Similarly, <<m_fn_args>> and <<m_fn_arg>> are useful
                      for nested declarations.) Macros will not evaluate within quoted strings, so typical use requires
                      unquoting, e.g. `['Arg1: ']m5_arg1['.']` vs. `['Arg1: $1.']`.
- *Inherited parameters*: These provide a more natural, readable, and explicit mechanism for customizing a function to the
                          context in which it is defined. For example a function may define another function that is
                          customized to the parameters of the outer function.

[[fn_arguments]]
==== Function Call Arguments

Function calls must have arguments for all non-optional, non-inherited (`^`) parameters. Arguments are positional, so misaligning arguments
is a common source of errors. There is checking, however, that required arguments are provided and that no extra arguments are given.
`m5_foo()` is permitted for a function `foo` declared with no parameters, though it is passed one emtpy parameter.
(`m5_call(foo)` might be preferred.)

==== Function Arguments Example

In M5 context, function `foo` is declared below to display its parameters.

  // Context:
  var(Inherit2, two)
  // Define foo:
  fn(foo, Param1, ?[1]Param2: an optional parameter,
          ?^Inherit1, [2]^Inherit2, ..., {
    ~nl(Param1: m5_Param1)
    ~nl(Param2: m5_Param2)
    ~nl(Inherit1: m5_Inherit1)
    ~nl(Inherit2: m5_Inherit2)
    ~nl(['numbered args: $@'])
  })

And it can be called (again, in M5 context):

 /Call foo:
 foo(arg1, arg2, extra1, extra2)

And this expands to:

 Param1: arg1
 Param2: arg2
 Inherit1:
 Inherit2: two
 numbered args: ['arg2'],['two'],['extra1'],['extra2']

==== Aftermath

It is possible for a function to make assignments (and, actually do anything) in the calling scope.
This can be done using <<m_on_return>> or <<m_return_status>>.

This is important for:

- passing arguments by reference
- returning status
- evaluating body arguments
- tail recursion

Each of these is discussed in its own section, next.


==== Passing Arguments by Reference

Functions can pass variables by reference and make assignments to the referenced
variables upon returning from the function. For example:

 fn(update, FooRef, {
   var(Value, ['updated value'])
   on_return(set, m5_FooRef, m5_Value)
 }
 set(Foo, ['xxx'])
 update(Foo)
 ~Foo   /// Results in "updated value".

A similar function could be defined to declare a referenced variable by using `var` instead of `set`.

The use of <<m_on_return>> avoids the potential masking issue that would result from:

 update(Value)


==== Returning Status

A function's <<v_status>> should be returned via the function's aftermath, using <<m_return_status>>, e.g.

 fn(my_fn, Val, {
    if(m5_Val > 10, [''])
    return_status(m5_status)   /// Return the status from the if statement.
 })

Functions automatically restore <<v_status>> after body evaluation to its value prior to body evaluation, so
the evaluation of the body has no impact on <<v_status>>. Aftermath is evaluated after this.
It is fine to call <<m_return_status>> multiple times. Only the last call will have a visible effect.


[[body_arguments]]
==== Functions with Body Arguments

The example below illustrates a function `if_neg` that takes an argument that is a body to evaluate.
The body is defined in a calling function, e.g. `my_fn` on lines 15-16. Such a body is expected to evaluate
in the context of the calling function, `my_fn`. Its assignment of `Neg`, on line 15, should be an assignment of
its own local `Neg`, declared on line 12. Its side effects from <<m_return_status>> on
line 15 should be side effects of `my_fn`.

If the body is evaluated inside the function body, its side effects would be side effects of `if_neg`,
not `my_fn`. The body should instead be evaluated as aftermath, using <<m_on_return>>, as on line 6.

Note that <<m_return_status>> is called after evaluating `m5_Body`. Both <<m_on_return>> and <<m_return_status>>
add to the <<Aftermath>> of the function, and <<v_status>> must be set after evaluating the body (which
could affect <<v_status>>).

Example of a body argument.

  1: // Evaluate a body if a value is negative.
  2: fn(if_neg, Value, Body, {
  3:    var(Neg, m5_calc(Value < 0))
  4:    ~if(Neg, [
  5:       /~eval(m5_Body)    /// Incorrect!!!
  6:       on_return(Body)    /// Correct.
  7:    ])
  8:    return_status(if(Neg, [''], else))
  9: })
 10: 
 11: fn(my_fn, {
 12:    var(Neg, [''])
 13:    return_status(['pos'])
 14:    ~if_neg(1, [
 15:       return_status(['neg'])
 16:       set(Neg, ['-'])
 17:    ])
 18:    ...
 19: })

Since <<m_macro>> does not support <<Aftermath>>, it is not recommended to use <<m_macro>> with a body argument.


==== Tail Recursion

Recursive calls tend to grow the stack significantly, and this can result in an error (see <<v_recursion_limit>>) as well
inefficiency. When recursion is the last act of the function ("tail recursion"), the recursion can be performed in
aftermath to avoid growing the stack. For example:

  fn(my_fn, First, ..., {
    ...
    ~unless(m5_Done, [
      ...
      on_return(my_fn\m5_comma_args())
    ])
    ...
  })


/** WIP
=== Contexts: Namespaces, and Libraries

==== Contexts

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


==== Macro Naming Conventions

To avoid <<masking>> issues, naming conventions divide the namespace in two styles:

- Lower case with underscores, e.g.: `m5_builtin_macro`
- Pascal case, e.g. `m5_MyVarName`

Names using lowercase with underscores: universal, namespaces, namespaced

Names using Pascal case: scoped macros (variables, functions, and traditional macros)

In both cases, names must be composed of ASCII characters `A-Z`, `a-z`, `0-9`, and `_`, and the first character must be alphabetic.

Libraries may define private macros using double underscore (`__`). A non-private macro in a universal library reserves
its own name in the universal namespace and also private names beginning with that name and `__`.
To maximize the ability of third-party libraries to share a namespace with other libraries, macros in third-party
libraries that are helpers for other macros should use the name of the associated macro before the `__`.


==== Universal Macros

==== Namespaces

==== Libraries

**/

=== Coding Paradigms, Patterns, Tips, Tricks, and Gotchas


[[masking]]
==== Variable Masking

Variable "masking" is an issue that can arise when a macro has side effects determined by its arguments.
For example, an argument might specify the name of a variable to assign, or an argument might provide a body to
evaluate that could declare or assign arbitrary variables. If the macro declares a local variable,
and the side effect updates a variable by the same name, the local variable may inadvertently be the
one that is updated by the side effect. This issue is addressed differently depending
how the macro is defined. Note that using function <<Aftermath>> is the preferred method, but all
options are listed here for completeness:

* Functions: Set variables using <<Aftermath>>. Using functions for variable-setting macros is preferred.
* Macros declaring their body using a code block: Set variable using <<m_out_eval>>.
* Macros declaring their body using a string: Push/pop local variables named using `${empty}0__` prefix.

'])
\m4
   m4_define(['m5_need_docs'], yes)
   m4_include_lib(['./m5.m4'])
\m5
enable_doc(adoc)

/Shorthand for m5_doc_macro__adoc__fn__<name>.
macro(DocFn, ['m5_doc_as_fn($@)m5_get(doc_macro__adoc__fn__$1)'])
macro(DocFns, ['m5_doc_now_as_fns($@)'])
macro(DocVar, m5_defn(doc_macro__doc_var))


var(mac_spec, *['
 == Macro Library
 
 === Specification Conventions
 ['
 Macros are listed by category in a logical order. An alphabetical <<Index>> of macros can be found at the end of
 this document (at least in the `.pdf` version).
 Macros that return integer values, unless otherwise specified, return decimal value strings. Similarly,
 macro arguments that are integer values accept decimal value strings. Boolean inputs and outputs use
 `0` and `1`. Behavior for other argument values is undefined if unspecified.
 
 Resulting output text is, by default, literal (quoted). Macros named with a `_eval` suffix generally result
 in text that gets evaluated.
 ']
 
 === Assigning and Accessing Macros/Variables

 ==== Declaring/Setting Variables

 m5_DocFn(var, ['
  D: Declare a scoped variable. See <<variables>>.
  S: the variable is defined
  E: var(Foo, 5)
  A: (m_macro, m_fn)
 '], Name: variable name, ?Value: the value for the variable, ...: additional variables and values to declare (values are required))


 m5_DocFn(set, ['
  D: Set the value of a scoped variable. See <<variables>>.
  S: the variable's value is set
  E: set(Foo, 5)
  A: (m_var)
 '], Name: variable name, Value: the value)

 m5_DocFn(push_var, ['
  D: Declare a variable that must be explicitly popped.
  S: the variable is defined
  E: push_var(Foo, 5)
  ...
  pop(Foo)
  A: (m_pop)
 '], Name: variable name, Value: the value)

 m5_DocFn(pop, ['
  D: Pop a variable or traditional macro declared using `push_var` or `push_macro`.
  S: the macro is popped
  E: push_var(Foo, 5)
  ...
  pop(Foo)
  A: (m_push_var, m_push_macro)
 '], Name: variable name)

 m5_DocFn(null_vars, ['
  D: Declare variables with empty values.
  S: the variables are declared
 '], ...: names of variables to declare)

 ==== Declaring Macros

 m5_DocFns(['fn, lazy_fn'], ['
  D: Declare a function. For details, see <<Functions>>. `fn` and `lazy_fn` are functionally equivalent but
  have different performance profiles, and lazy functions do not support inherited (`^`) parameters.
  Lazy functions wait until they are used before defining themselves, so they are generally preferred
  in libraries except for the most commonly-used functions.
  S: the function is declared
  E: fn(add, Addend1, Addend2, {
     ~calc(Addend1 + Addend2)
  })
  A: (Functions)
 '], ...: arguments and body)


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
 
 m5_DocFns(['macro, null_macro'], ['
  D: Declare a scoped macro. See <<Declaring Macros>>. A null macro must produce no output.
  S: the macro is declared
  E: m5_\macro(ParseError, <p>[
     error(['Failed to parse $<p>1.'])
  ])
  A: (m_var, m_set_macro)
 '], Name: the macro name, Body: the body of the macro)

 m5_DocFn(set_macro, ['
  D: Set the value of a scoped(?) macro. See <<Declaring Macros>>. Using this macro is rare.
  S: the macro value is set
  A: (m_var, m_set_macro)
 '], Name: the macro name, Body: the body of the macro)
 
 m5_DocFn(push_macro, ['
  D: Push a new value of a macro that must be explicitly popped. Using this macro is rare.
  S: the macro value is pushed
  A: (m_pop, m_macro, m_set_macro)
 '], Name: the macro name, Body: the body of the macro)

 ==== Accessing Macro/Variable Values
 
 m5_DocFn(get, ['
  O: the value of a variable without `$` substitution (even if not assigned as a string)
  E: var(OneDollar, ['$1.00'])
  get(OneDollar)
  P: 
  $1.00
  A: (m_var, m_set)
 '], Name: name of the variable)

 m5_DocFns(['must_exist, var_must_exist'], ['
  D: Ensure that the `Name`d macro (`must_exist`) or variable (`var_must_exist`) exists.
 '], Name: name of the macro/variable)

 
 === Code Constructs
 
 ==== Status

 m5_DocVar(status, ['
 D: This universal variable is set as a side-effect of some macros to indicate an exceptional
 condition or non-evaluation of a body argument. It may be desirable to check this condition
 after calling such macros. Macros, like `m5_\else` take action based on the value
 of `m5_\status`. An empty value indicates no special condition.
 Macros either always set it (to an empty or non-empty value) or never set it. Those that set
 it list this in their "Side Effect(s)".
 A: (m_fn, m_return_status, m_else, m_sticky_status)
 '])

 m5_DocVar(sticky_status, ['
 D: Used by the <<m_sticky_status>> macro to capture the value of `m5_\status`.
 A: (v_status, m_sticky_status)
 '])

 m5_DocFn(sticky_status, ['
 D: Used to capture the first non-empty status of multiple macro calls.
 S: <<v_sticky_status>> is set to <<v_status>> if it is empty and <<v_status>> is not.
 E: if(m5_\A >= m5_\Min, [''])
 sticky_status()
 if(m5_\A <= m5_\Max, [''])
 sticky_status()
 if(m5_\reset_sticky_status(), ['m5_\error(m5_A is out of range.)'])
 A: (v_status, m_sticky_status, m_reset_sticky_status)
 '])

 m5_DocFn(reset_sticky_status, ['
 D: Tests and resets <<v_sticky_status>>.
 O: [`0` / `1`] the original nullness of <<v_sticky_status>>
 S: <<v_sticky_status>> is reset (emptied/nullified)
 A: (m_sticky_status)
 '])

 ==== Conditionals

 m5_doc_as_fn(unless, [''], Cond, TrueBody, FalseBody)
 m5_DocFns(['if, unless, else_if'], ['
  D: An if/else construct. The condition is an expression that evaluates using <<m_calc>> (generally boolean (0/1)).
  The first block is evaluated if the condition is non-0 (for `if` and `else_if`) or 0 (for `unless`),
  otherwise, subsequent conditions are evaluated, or if only one argument remains, it is the
  final else block, and it is evaluate. (`unless` cannot have subsequent conditions.) `if_else` does
  nothing if `m5_\status` is initially empty.
  
  NOTE: As an alternative to providing else blocks within `m5_\if`, <<m_else>> and similar macros may be used subsequent to
  `m5_\if` / `m5_\unless` and other macros producing <<v_status>>, and this may be easier to read.
  O: the output of the evaluated body
  S: status is set, empty iff a block was evaluated; side-effects of the evaluated body
  E: ~if(m5_\eq(m4_Ten, 10) && m5_\Val > 3, [
     ~do_something(...)
  ], m5_\Val > m5_\Ten, [
     ~do_something_else(...)
  ], [
     ~default_case(...)
  ])
  A: (m_else, m_case)
 '], Cond: ['the condition for evaluation'],
     TrueBody: ['the body to evaluate if the condition is true (1)'],
     ...: ['['either a `FalseBody` or (for `m5_\if` only) recursive `Cond`, `TrueBody`, `...` arguments to evaluate if the condition is false (not 1)']'])

 m5_DocFns(['if_eq, if_neq'], ['
  D: An if/else construct where each condition is a comparison of an independent pair of strings.
  The first block is evaluated if the strings match (for `if`) or mismatch (for `if_neq`), otherwise, the
  remaining arguments are processed in a recursive call, either comparing the next pair of strings
  or, if only one argument remains, evaluating it as the final else block.
   
  NOTE: As an alternative to providing else blocks, <<m_else>> and similar macros may be used subsequently,
  and this may be easier to read.
  O: the output of the evaluated body
  S: status is set, empty iff a body was evaluated; side-effects of the evaluated body
  E: ~if_eq(m4_Zero, 0, [
     ~zero_is_zero(...)
  ], m5_\calc(m5_\Zero < 0), 1, [
     ~zero_is_negative(...)
  ], [
     ~zero_is_positive(...)
  ])
  A: (m_else, m_case)
 '], String1: the first string to compare,
     String2: the second string to compare,
     TrueBody: the body to evaluate if the strings match,
     ...: ['either a `FalseBody` or recursive `String1`, `String2`, `TrueBody`, `...` arguments to evaluate if the strings do not match'])

 m5_doc_as_fn(if_null, [''], Var, Body, ?ElseBody)
 m5_doc_as_fn(if_def, [''], Var, Body, ?ElseBody)
 m5_doc_as_fn(if_ndef, [''], Var, Body, ?ElseBody)
 m5_DocFns(['if_null, if_def, if_ndef, if_defined_as'], ['
  D: Evaluate `Body` if the named variable is empty (`if_null`), defined (`if_def`), not defined (`if_ndef`), or not defined and equal to the given value (`if_defined_as`).,
  or `ElseBody` otherwise.
  O: the output of the evaluated body
  S: status is set, empty iff a body was evaluated; side-effects of the evaluated body
  E: if_null(Tag, [
     error(No tag.)
  ])
  A: (m_if)
 '], Var: the variable's name,
     Value: ['for `if_defined_as` only, the value to compare against'],
     Body: the body to evaluate based on `m5_\Name`'s existence or definition,
     ?ElseBody: a body to evaluate if the condition if `Body` is not evaluated)

 m5_DocFns(['else, if_so'], ['
  D: Likely following a macro that sets `m5_\status`, this evaluates a body if <<v_status>> is non-empty (for `else`) or empty (for `if_so`).
  O: the output of the evaluated body
  S: status is set, empty iff a body was evaluated; side-effects of the evaluated body
  E: ~if(m5_\Cnt > 0, [
     decrement(Cnt)
  ])
  else([
     ~(Done)
  ])
  A: (m_if, m_if_eq, m_if_neq, m_if_null, m_if_def, m_if_ndef, m_var_regex)
 '], Body: ['the body to evaluate based on <<v_status>>'])

 m5_DocFn(else_if_def, ['
  D: Evaluate `Body` iff the `Name`d variable is defined.
  O: the output of the evaluated body
  S: status is set, empty iff a body was evaluated; side-effects of the evaluated body
  E: m5_\set(Either, if_def(First, m5_\First)m5_\else_if_def(Second, m5_\Second))
  A: (m_else_if, m_if_def)
 '], Name: the name of the case variable whose value to compare against all cases,
     Body: ['the body to evaluate based on <<v_status>>'])

 m5_DocFn(case, ['
  D: Similar to <<m_if>>, but each condition is a string comparison against a value in the `Name` variable.
  O: the output of the evaluated body
  S: status is set, empty iff a block was evaluated; side-effects of the evaluated body
  E: ~case(m5_\Response, ok, [
     ~ok_response(...)
  ], bad, [
     ~bad_response(...)
  ], [
     error(Unrecognized response: m5_\Response)
  ])
  A: (m_else, m_case)
 '], Name: the name of the case variable whose value to compare against all cases,
     Value: the first string value to compare `VarName` against,
     TrueBody: the body to evaluate if the strings match,
     ...: ['either a `FalseBody` or recursive `Value`, `TrueBody`, `...` arguments to evaluate if the strings do not match'])
 

 ==== Loops
 
 m5_DocFn(loop, ['
  D: A generalized loop construct. Implicit variable `m5_\LoopCnt` starts at 0 and increments by 1
  with each iteration (after both blocks).
  O: output of the blocks
  S: side-effects of the blocks
  E: ~loop((MyVar, 0), [
     ~do_stuff(...)
  ], m5_\LoopCnt < 10, [
     ~do_more_stuff(...)
  ])
  A: (m_repeat, m_for, m_calc)
 '], InitList: ['a parenthesized list, e.g. `(Foo, 5, Bar, ok)` of at least one variable, initial-value pair providing variables scoped to the loop, or `['']`'],
     DoBody: ['a block to evaluate before evaluating `WhileCond`'],
     WhileCond: ['an expression (evaluated with <<m_calc>>) that determines whether to continue the loop'],
     ?WhileBody: ['a block to evaluate if `WhileCond` evaluates to true (1)'])

 m5_DocFn(repeat, ['
  D: Evaluate a block a predetermined number of times. Implicit variable `m5_\LoopCnt` starts at 0
  and increments by 1 with each iteration.
  O: output of the block
  S: side-effects of the block
  E: ~repeat(10, [
     ~do_stuff(...)
  ])  /// Iterates m5_\LoopCnt 0..9.
  A: (m_loop)
 '], Cnt: ['the number of times to evaluate the body'],
     Body: ['a block to evaluate `Cnt` times'])

 m5_DocFn(for, ['
  D: Evaluate a block for each item in a listed. Implicit variable `m5_\LoopCnt` starts at 0
  and increments by 1 with each iteration.
  O: output of the block
  S: side-effects of the block
  E: ~for(fruit, ['apple, orange, '], [
     ~do_stuff(...)
  ])  /// (also maintains m5_\LoopCnt)
  A: (m_loop)
 '], Var: ['the loop item variable'],
     List: ['a list of items to iterate over, the last of which will be skipped if empty; for each item, `Var` is set to the item, and `Body` is evaluated'],
     Body: ['a block to evaluate for each item'])

 ==== Recursion
 
 m5_DocFn(recurse, ['
  D: Call a macro recursively to a given maximum recursion depth. Functions have a built-in recursion
  limit, so this is only useful for macros.
  O: the output of the recursive call
  S: the side effects of the recursive call
  E: m5_\recurse(20, myself, args)
  A: (v_recursion_limit, m_on_return)
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
  A: (m_quote)
 '])
 
 m5_DocFns(['orig_open_quote, orig_close_quote'], ['
  D: Produce `['` or `']`. These quotes in the original file are translated internally to ASCII
  control characters, and in output (STDOUT and STDERR) these control characters are translated to single-unicode-character
  "printable quotes". This original quote syntax is most easily produced using these macros, and
  once produced, has no special meaning in strings (though `[` and `]` have special meaning in
  regular expressions).
  O: the literal quote
  A: (m_printable_open_quote, m_printable_close_quote)
 '])
 
 m5_DocFns(['printable_open_quote, printable_close_quote'], ['
  D: Produce the single unicode character used to represent `['` or `']` in output (STDOUT and STDERR).
  O: the printable quote
  A: (m_orig_open_quote, m_orig_close_quote)
 '])
 
 m5_DocFn(['UNDEFINED'], ['
  D: A unique untypeable value indicating that no assignment has been made.
  This is not used by any standard macro, but is available for explicit use.
  O: the value indicating "undefined"
  E: m5_\var(Foo, m5_\UNDEFINED)
  m5_\if_eq(Foo, m5_\UNDEFINED, ['['Foo is undefined.']'])
  R: Foo is undefined.
 '])
 
 ==== Slicing and Dicing Strings

 m5_DocFns(['append_var, prepend_var, append_macro, prepend_macro'], ['
  D: Append or prepend to a variable or macro. (A macro evaluates its context; a variable does not.)
  E: m5_\var(Hi, ['Hello'])
  m5_\append_var([', ']m5_\Name['!']) /// equivalent to m5_\var(Hi, ['Hello'][', ']m5_\Name['!'])
  m5_\Hi
  P: Hello, Joe!
 '], Name: the variable name, String: the string to append/prepend)

 m5_DocFns(['substr, substr_eval'], ['
  D: Extract a substring from `String` starting from `Index` and extending for `Length` ASCII characters (unicode bytes)
  or to the end of the
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
  
  `substr` is a slow operation relative to `substr_eval` (due to limitations of M4).
  O: the substring or its evaluation
  E: m5_\substr(['Hello World!'], 3, 5)
  P: lo Wo
  A: (m_dequote, m_requote)
 '], String: the string, From: the starting position of the substring, ?Length: the length of the substring)

 m5_DocFn(join, ['
  O: the arguments, delimited by the given delimiter string
  E: m5_\join([', '], ['new-line'], ['m5_\nl'], ['macro'])
  P: new-line, m5_\nl, macro
 '], Delimiter: text to delimit arguments, ...: arguments to concatenate (with delimitation))

 m5_DocFns(['translit, translit_eval'], ['
  D: Transliterate a string, providing a set of character-for-character substitutions (where a character
  is a unicode byte). `translit_eval` evaluates the resulting string.
  Note that `['` and `']` are internally single characters. It is possible to
  substitute these quotes (if balanced in the string and in the result) using `translit_eval` but not using `translit`.
  O: the transliterated string (or its evaluation for `translit_eval`)
  S: for `translit_eval`, the side-effects of the evaluation
  E: m5_\translit(['Testing: 1, 2, 3.'], ['123'], ['ABC'])
  P: Testing: A, B, C.
 '], String: the string to tranliterate, InChars: the input characters to replace, OutChars: the corresponding character replacements)

 m5_DocFns(['uppercase, lowercase'], ['
  D: Convert upper-case ASCII characters to lower-case.
  O: the converted string
  E: m5_\uppercase(['Hello!'])
  P: HELLO!
 '], String: the string)

 m5_DocFn(replicate, ['
  D: Replicate a string the given number of times. (A non-evaluating version of `m5_\repeat`.)
  O: the replicated string
  E: m5_\replicate(3, ['.'])
  P: ...
  A: (m_repeat)
 '], Cnt: the number of repetitions, String: the string to repeat)

 m5_DocFn(strip_trailing_whitespace_from, ['
  D: Strip trailing whitespace from the given variable.
  S: the variable is updated
 '], Var: the variable)

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
  E: 1: m5_\var(Foo, Hello)
     m5_\format_eval(`String "%s" uses %d chars.', Foo, m5_\length(Foo))
  2: m5_\format_eval(`%*.*d', `-1', `-1', `1')
  3: m5_\format_eval(`%.0f', `56789.9876')
  4: m5_\length(m5_\format(`%-*X', `5000', `1'))
  5: m5_\format_eval(`%010F', `infinity')
  6: m5_\format_eval(`%.1A', `1.999')
  7: m5_\format_eval(`%g', `0xa.P+1')
  P: 1: 
     String "Hello" uses 5 chars.
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
 
 m5_DocFn(for_each_line, ['
  D: Evaluate `m5_\Body` for every line of `m5_\Text`, with `m5_\Line` assigned to the line (without any new-lines).
  O: output from `m5_\Body`
  S: side-effects of `m5_\Body`
 '], Text: the block of text, Body: ['the body to evaluate for every `m5_\if` of `m5_\Text`'])


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
  A: (m_printable_open_quote, m_printable_close_quote)
 '], String: the string to output)

 m5_DocFn(no_quotes, ['
  D: Assert that the given string contains no quotes.
 '], String: the string to test)
 
 ==== Regular Expressions

 ['
 Regular expressions in M5 use the same regular expression syntax as GNU Emacs. (See
 https://www.gnu.org/software/emacs/manual/html_node/emacs/Regexps.html[GNU Emacs Regular Expressions].)
 This syntax is similar to BRE, Basic Regular Expressions in POSIX and is regrettably rather limited.
 Extended Regular Expressions are not supported.
 ']

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

 m5_DocFns(['regex, regex_eval'], ['
  D: Searches for `Regexp` in `String`, resulting in either the position of the match or the given replacement.
  
  `Replacement` provides the output text. It may contain references to subexpressions of `Regex` to expand
  in the output. In `Replacement`, `\n` references the nth parenthesized subexpression of `Regexp`, up to nine
  subexpressions, while `\&` refers to the text of the entire regular expression matched. For all other
  characters, a preceding `\` treats the character literally.
  O: If `Replacement` is omitted, the index of the first match of `Regexp` in `String` is produced (where the
  first character in the string has an index of 0), or -1 is produced if there is no match.
  
  If `Replacement` is given and there was a match, this argument provides the output, with `\n`
  replaced by the corresponding matched subexpressions of `Regex` and `\&` replaced by the entire matched
  substring. If there was no match result is empty.
  
  The resulting text is literal for `regex` and is evaluated for `regex_eval`.
  S: `regex_eval` may result in side-effects resulting from the evaluation of `Replacement`. 
  E: m5_\regex_eval(['Hello there'], ['\w+'], ['First word: m5_\translit(['\&']).'])
  P: First word: Hello.
  A: (m_var_regex, m_if_regex, m_for_each_regex)
 '], String: the string to search,
     Regex: the regular expression to match,
     ?Replacement: the replacement)

 m5_DocFn(var_regex, ['
  D: Declare variables assigned to subexpressions of a regular expression.
  S: `status` is assigned, non-empty iff no match.
  E: m5_\var_regex(['mul A, B'], ['^\(\w+\)\s+\(w+\),\s*\(w+\)$'], (Operation, Src1, Src2))
  m5_\if_so(['m5_\DEBUG(Matched: m5_\Src1[','] m5_\Src2)'])
  m5_\else(['m5_\error(['Match failed.'])'])
  A: (m_regex, m_regex_eval, m_if_regex, m_for_each_regex)
 '], String: the string to match,
     Regex: the Gnu Emacs regular expression,
     VarList: a list in parentheses of variables to declare for subexpressions)

 m5_DocFns(['if_regex, else_if_regex'], ['
  D: For chaining `var_regex` to parse text that could match a number of formats.
  Each pattern match is in its own scope. `else_if_regex` does nothing if `m5_\status` is non-empty.
  O: output of the matching body
  S: `m5_\status` is non-null if no expression matched; side-effects of the bodies
  E: ~if_regex(m5_\Instruction, ['^mul\s+\(w+\),\s*\(w+\)$'], (Src1, Src2), [
     ~calc(m5_\Src1 * m5_\Src2)
  ], ['^incr\s+\(w+\)$'], (Src1), [
     ~calc(m5_\Src1 + 1)
  ])
  A: (m_var_regex)
 '], String: the string to match,
     Regex: the Gnu Emacs regular expression,
     VarList: a list in parentheses of variables to declare for subexpressions,
     Body: the body to evaluate if the pattern matches,
     ...: ['additional repeated Regex, VarList, Body, ... to process if pattern doesn't match'])

 m5_DocFn(for_each_regex, ['
  D: Evaluate body for every pattern matching regex in the string. <<v_status>> is unassigned.
  S: side-effects of evaluating the body
  E: m5_\for_each_regex(H1dd3n D1git5, ['\([0-9]\)'], (Digit), ['Found m5_\Digit. '])
  P: Found 1. Found 3. Found 1. Found 5. 
  A: (m_regex, m_regex_eval, m_if_regex, m_else_if_regex)
 '], String: the string to match (containing at least one subexpression and no `$`),
     Regex: the Gnu Emacs regular expression,
     VarList: a (non-empty) list in parentheses of variables to declare for subexpressions,
     Body: the body to evaluate for each matching expression)


 === Utilities
 
 ==== Fundamental Macros
 
 m5_DocFn(defn, ['
  O: the M4 definition of a macro; note that the M4 definition is slightly different from the M5 definition
 '], Name: the name of the macro)

 m5_DocFn(call, ['
  D: Call a macro. Versus directly calling a macro, this indirect mechanism has two primary uses.
  First it provides a consistent syntax for calls with zero arguments as for calls with a non-zero
  number of arguments. Second, the macro name can be constructed.
  O: the output of the called macro
  S: the side-effects of the called macro
  E: m5_\call(error, ['Fail!'])
  A: (m_comma_shift, m_comma_args)
 '], Name: the name of the macro to call, ...: the arguments of the macro to call)

 m5_DocFn(quote, ['                  
  O: a comma-separated list of quoted arguments, i.e. `${empty}@`                   
  E: m5_\quote(A, ['B'])
  P: ['A'],['B']
  A: (m_nquote)
 '], ...: arguments to be quoted)
 
 m5_DocFn(nquote, ['
  O: the arguments within the given number of quotes, the innermost applying individually to
  each argument, separated by commas. A `num` of `0` results in the inlining of `${empty}@`.
  E: 1: m5_\nquote(3, A, ['m5_\nl'])
  2: m5_\nquote(3, m5_\nquote(0, A, ['m5_\nl'])xx)
  P: 1: ['['['A'],['m5_\nl']']']
  2: ['['['A'],['m5_\nlxx']']']
  A: (m_quote)
 '], ...: )
 
 m5_DocFn(eval, ['
  D: Evaluate the argument.
  O: the result of evaluating the argument
  S: the side-effects resulting from evaluation
  E: 1: m5_\eval(['m5_\calc(1 + 1)'])
  2: m5_\eval(['m5'])_calc(1 + 1)
  P: 1: 2
  2: m5_\calc(1 + 1)
 '], Expr: the expression to evaluate)

 m5_DocFns(['comment, nullify'], ['
  O: nothing at all; used to provide a comment (though <<comments>> are preferred) or to discard the result of an evaluation
 '], ...: )

 ==== Manipulating Macro Stacks

 See <<stacks>>.

 m5_DocFns(['get_ago'], ['
  O: ['a value from a variable's stack, or empty if not defined']
  E: *{
     var(Foo, A)
     var(Foo, B)
     ~get_ago(Foo, 1)
     ~get_ago(Foo, 0)
  }
  P: AB
 '], Name: variable name, Ago: ['0 for current definition, 1 for previous, and so on'])

 m5_DocFn(depth_of, ['
  O: the number of values on a variable's stack
  E: m5_\depth_of(Foo)
  m5_\push_var(Foo, A)
  m5_\depth_of(Foo)
  P: 0
  
  1
 '], Name: macro name)

 ==== Argument Processing

 m5_DocFns(['shift, comma_shift'], ['
  D: Removes the first argument. `comma_shift` includes a leading `,` if there are more than zero arguments.
  O: a list of remaining arguments, or `['']` if less than two arguments
  S: none
  E: m5_\foo(m5_\shift($@))         //']['/ $@ has at least 2 arguments
  m5_\call(foo['']m5_\comma_shift($@)) //']['/ $@ has at least 1 argument
 '], ...: arguments to shift)

 m5_DocFn(nargs, ['
  O: the number of arguments given (useful for variables that contain lists)
  E: m5_\set(ExampleList, ['hi, there'])
  m5_\nargs(m5_\ExampleList)
  P: 
  2
 '], ...: arguments)

 m5_DocFn(argn, ['
  O: the nth of the given `arguments` or `['']` for non-existent arguments
  E: m5_\set(ExampleList, ['hi, there'])
  m5_\argn(2, ExampleList)
  P: 
  there
 '], ArgNum: the argument number (n) (must be positive), ...: arguments)

 m5_DocFn(comma_args, ['
  D: Convert a quoted argument list to a list of arguments with a preceding comma.
  This is necessary to properly work with argument lists that may contain zero arguments.
  E: m5_\call(foo['']m5_\comma_args(['$@']), last)
  A: (m_comma_shift, m_comma_fn_args)
 '], ...: quoted argument list)

 /** Deprecated. Use above instead for better consistency
 m5_DocFn(call_varargs, ['
  D: For working with argument lists that can have zero arguments, this is a bit cleaner
  looking that using `m5_\comma_args` for common cases. This is a variant of `m5_\call` that has a
  final argument that is a list of 0 or more additional arguments.
  E: m5_\call_varargs(my_fn, arg1, ['$@'])
  A: (m_comma_args)
 '], ...: quoted, argument list)
 **/
 
 m5_DocFn(echo_args, ['
  D: For rather pathological use illustrated in the example, ...
  O: the argument list (`${empty}@`)
  E: m5_\macro(append_to_paren_list, ['m5_\echo_args$1, ${empty}2'])
  m5_\append_to_paren_list((one, two), three)
  P: (one,two,three)
 '], ...: the arguments to output)

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
 
 m5_DocFn(calc, ['
  D: Calculate an expression.
  Calculations are done with 32-bit signed integers. Overflow silently results in wraparound.
  A warning is issued if division by zero is attempted, or if the expression could not be parsed.
  Expressions can contain the following operators, listed in order of decreasing precedence.

  - `()`: For grouping subexpressions
  - `+`, `-`, `~`, `!`: Unary plus and minus, and bitwise and logical negation
  - `**`: Exponentiation (exponent must be non-negative, and at least one argument must be non-zero)
  - `*`, `%`: Multiplication, division, and modulo
  - `+ -`: Addition and subtraction
  - `<<`, `>>`: Shift left or right (for shift amounts > 32, the amount is implicitly ANDed with `0x1f`)
  - `>`, `>=`, `<`, `<=`: Relational operators
  - `==`, `!=`: Equality operators
  - `&`: Bitwise AND
  - `^`: Bitwise XOR (exclusive or)
  - `\|`: Bitwise OR
  - `&&`: Logical AND
  - `\|\|`: Logical OR

  All binary operators, except exponentiation, are left-associative. Exponentiation is right-associative.
  
  Immediate values in `Expr` may be expressed in any radix (aka base) from 1 to 36 using prefixes as follows:
  
  - (none): Decimal (base 10)
  - `0`: Octal (base 8)
  - `0x`: hexadecimal (base 16)
  - `0b`: binary (base 2)
  - `0r:`, where `r` is the radix in decimal: Base `r`.
  
  Digits are `0`, `1`, `2`, …, `9`, `a`, `b` … `z`. Lower and upper case letters can be used
  interchangeably in numbers and prefixes. For radix 1, leading zeros are ignored, and all remaining
  digits must be `1`.

  For the relational operators, a true relation returns 1, and a false relation return 0.
  O: the calculated value of the expression in the given `Radix`; the value is zero-extended as requested by `Width`; values may
  have a negative sign (`-`) and they have no radix prefix; digits > 9 use lower-case letters; output is empty if the expression is invalid
  E: 1: m5_\calc(2**3 <= 4)
  2: m5_\calc(-0xf, 2, 8)
  P: 1: 0
  2: -00001111
 '], Expr: the expression to calculate,
     ?Radix: the radix of the output (default 10),
     ?Width: ['a minimum width to which to zero-pad the result if necessary (excluding a possible negative sign)'])

 m5_DocFns(['equate, operate_on'], ['
  D: Set a variable to the result of an arithmetic expression computed by <<m_calc>>. For
  `m5_\operate_on`, the variable value implicitly preceeds the expression, similar to `+=`, `*=`, etc. in other languages.
  S: the variable is set
  E: m5_\equate(Foo, 1+2)
  m5_\operate_on(Foo, * (3-1))
  m5_\Foo
  P: 
  
  6
  A: (m_set, m_calc)
 '], Name: name of the variable to set, Expr: the expression/partial-expression to evaluate)

 m5_DocFns(['increment, decrement'], ['
  D: Increment/decrement a variable holding an integer value by one or by the given amount.
  S: the variable is updated
  E: m5_\increment(Cnt)
  A: (m_set, m_calc, m_operate_on)
 '], Name: name of the variable to set, ?Amount: ['the integer amount to increment/decrement, defaulting to zero'])

 ==== Boolean Macros
 
 These have boolean (`0` / `1`) results. Note that some <<m_calc>> expressions result in boolean values as well.
 
 m5_DocFns(['is_null, isnt_null'], ['
  O: [`0` / `1`] indicating whether the value of the given variable (which must exist) is empty
 '], Name: the variable name)

 m5_DocFns(['eq, neq'], ['
  O: [`0` / `1`] indicating whether the given `String1` is/is-not equivalent to `String2` or any of the remaining string arguments
  E: m5_\if(m5_\neq(m5_\Response, ok, bad), ['m5_\error(Unknown response: m5_\Response.)'])
 '], String1: the first string, String2: the second string, ...: further strings to also compare)


 ==== Within Functions or Code Blocks
 
 m5_DocFns(['fn_args, comma_fn_args'], ['
  D: `m5_\fn_args()` results in the numbered argument list of the current function. This is like `${empty}@`, but it can be used in a nested
  function without escaping (e.g. `${empty}<label>@`). `m5_\comma_fn_args()` is the same, but has a preceeding comma if the list is
  non-empty. Note that these can be used as variables (`m5_\fn_args` and `m5_\comman_fn_args`) to provide quoted versions of these.
  O: 
  S: none
  E: m5_\foo(1, m5_\fn_args())           //']['/ works for 1 or more fn_args
  m5_\foo(1['']m5_\comma_fn_args())   //']['/ works for 0 or more fn_args
  A: (m_fn_arg, m_fn_arg_cnt)
 '])
 
 m5_DocFn(fn_arg, ['
  D: Access a function argument by position from `m5_\fn_args`.
  This is like, e.g. `${empty}3`, but is can be used in a nested function without escaping (e.g. `${empty}<label>3`), and
  can be parameterized (e.g. `m5_\fn_arg(m5_\ArgNum)`).
  O: the argument value.
  A: (m_fn_args, m_fn_arg_cnt)
 '], Num: the argument number)

 m5_DocFn(fn_arg_cnt, ['
  D: The number of arguments in `m5_\fn_args` or `${empty}#`.
  This is like, e.g. `${empty}#`, but is can be used in a nested function without escaping (e.g. `${empty}<label>#`).
  O: the argument value.
  A: (m_fn_args, m_fn_arg)
 '])

 m5_DocFns(['out, out_eval'], ['
  D: These append to code block output that is expanded after the evaluation of the block. `m5_\out` captures
  literal text, while the argument to `m5_out_eval` gets evaluated. Thus `m5_out_eval` is useful for code
  block side effects. `m5_\out` is useful only in pathological cases within statements and by dynamically
  constructed code since the shorthand syntax `~(...)` is effectively identical to `~out(...)`.
  Note that these macros are not recommended for use in function blocks as functions have their own
  mechanism for side effects that applies outside of the function (after popping parameters). (See <<Aftermath>>.)
  O: no direct output, though, since these indirectly result in output as a side-effect, it is recommended to use `~`
  statement syntax with these
  S: indirectly, `out_eval` can result in the side effects of its output expression
  A: (Code Blocks, Aftermath)
 '], String: the string to output)

 m5_DocFn(return_status, ['
  D: Provide return status. (Shorthand for `m5_\on_return(set, status, m5_\Value)`.) This negates any prior calls
  to `return_status` from the same function.
  S: sets `m5_\status`
  A: (m_on_return, status, Aftermath)
 '], ?Value: ['the status value to return, defaulting to the current value of `m5_\status`'])
 
 m5_DocFn(on_return, MacroName, ..., ['
  D: Call a macro upon returning from a function. Arguments are those for m5_\call.
  This is most often used to have a function declare or set a variable/macro as a side effect.
  It is also useful to perform a tail recursive call without growing the call stack.
  S: that of the resulting function call
  E: fn(set_to_five, VarName, {
     on_return(set, m5_\VarName, 5)
  })
  fn(set2, VarName1, Val1, VarName2, Val2, {
     ...
     on_return(eval, {
        set(VarName1, m5_\Val1)
        set(VarName2, m5_\Val2)
     })
  })
  A: (m_return_status, Aftermath)
 '], MacroName: ['the name of the macro to call'], ...: ['its arguments'])


 === Checking and Debugging

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
 
 m5_DocFn(debug_level, ['
  D: Get or set the debug level.
  O: with zero arguments, the current debug level
  S: sets `debug_level`
  E: debug_level(max)
  use(m5-1.0)
 '], ?level: ['[`min`, `default`, `max`] the debug level to set'])
 

 ==== Checking and Reporting to STDERR
 
 These macros output text to the standard error output stream (STDERR) (with `[{empty}'` / `'{empty}]` quotes represented by single characters).
 (Note that STDOUT is the destination for the evaluated output.)
 
 m5_DocFns(['errprint, errprint_nl'], ['
  D: Write to STDERR stream (with a trailing new-line for `errprint_nl`).
  E: m5_\errprint_nl(['Hello World.'])
 '], text: ['the text to output'])

 m5_DocFns(['warning, error, fatal_error, DEBUG'], ['
  D: Report an error/warning/debug message and stack trace (except for `DEBUG_if`).
  Exit for fatal_error, with non-zero exit code.
  E: m5_\error(['Parsing failed.'])
 '], message: ['the message to report; (`Error:` pre-text (for example) provided by the macro)'])

 m5_DocFns(['warning_if, error_if, fatal_error_if, DEBUG_if'], ['
  D: Report an error/warning/debug message and stack trace (except for `DEBUG_if`) if the given condition is true.
  Exit for fatal_error, with non-zero exit code.
  E: m5_\error_if(m5_\Cnt < 0, ['Negative count.'])
 '], condition: ['the condition, as in `m5_\if`.'], message: ['the message to report; (`Error:` pre-text (for example) provided by the macro)'])

 m5_DocFns(['assert, fatal_assert'], ['
  D: Assert that a condition is true, reporting an error if it is not, e.g. `Error: Failed assertion: -1 < 0`. Exit for fatal_error, with non-zero exit code.
  E: m5_\assert(m5_\Cnt < 0)
 '], message: ['the message to report; (`Error:` pre-text (for example) provided by the macro)'])

 m5_doc_as_fn(verify_min_args, ['
 '], Name, Min, Actual)
 m5_doc_as_fn(verify_num_args, ['
 '], Name, Min, Actual)
 m5_DocFns(['verify_min_args, verify_num_args, verify_min_max_args'], ['
  D: Verify that a traditional macro has a minimum number, a range, or an exact number of arguments.
  E: m5_\verify_min_args(my_fn, 2, $#)
 '], Name: the name of this macro (for error message), Min: the required minimum or exact number of arguments,
     Max: the maximum number of arguments, Actual: the actual number of arguments)
 
 ==== Uncategorized Debug Macros
 
 m5_DocVar(recursion_limit, ['
  D: If the function call stack exceeds this value, a fatal error is reported.
 '])

 m5_DocFn(abbreviate_args, ['
  D: For reporting messages containing argument lists, abbreviate long arguments and/or a long argument list by replacing
     long input args and remaining arguments beyond a limit with ['...'].
  O: a quoted string of quoted args with a comma preceding every arg.
  E: m5_\abbreviate_args(5, 15, $@)
 '], max_args: ['if more than this number of args are given, additional args are represented as ['...']'],
     max_arg_length: ['maximum length in characters to display of each argument'],
     ...: ['arguments to represent in output'])
'])



macro(tail_doc, ['
 
 == Reference Card

 M5 processes the following syntaxes:

 [cols="2,3,5a"]
 .Core Syntax
 |===
 |Use |Reference |Syntax

 |M5 comments
 |<<Comments>>
 |`/{empty}//`, `/']['{empty}*{empty}*`, `{empty}*{empty}*']['/`

 |Quotes
 |<<Quotes>>
 |`['`, `']`

 |Macro calls
 |<<Calling Macros>>
 |e.g. `m5_\my_fn(arg1, arg2)`

 |Numbered/special parameters
 |<<Declaring Macros>>
 |`$` (e.g. `${empty}3`, `${empty}@`, `${empty}#`, `${empty}*`)

 |Escapes
 |<<prefix_escapes>>
 |`\\m5_foo`, `m5_\foo`
 |===

 Additionally, text and code block syntax is recognized when special quotes are opened at the end of a line or closed
 at the beginning of a line. See <<Code Blocks>>. For example:

  /Report error.
  error(*<blk>{
      ~(['Something went wrong!'])
  })

 Block syntax incudes:

 [cols="2,3,5a"]
 .Block Syntax
 |===
 |Use |Reference |Syntax

 |Code block quotes
 |<<Code Blocks>>
 |`[`, `]`, `{`, `}` (ending/beginning a line)

 |Text block quotes
 |<<Text Blocks>>
 |`['`, `']` (ending/beginning a line)

 |Evaluate Blocks
 |<<Evaluate Blocks>>
 |`{empty}*[`, `[`, `{empty}*{`, `}`, `*['`, `']`

 |Statement comment
 |<<statement_comments>>
 |`/Blah blah blah...`

 |Statement with no output
 |<<Code Blocks>>
 |`foo`, `bar(...)` (`m5_\` prefix implied)

 |Code block statement with output
 |<<bCode Blocks>>
 |`~foo`, `~bar(...)` (`m5_\` prefix implied)

 |Code block output
 |<<Code Blocks>>
 |`~(...)`
 |===

 Though not essential, block labels can be used to improve maintainability and performance in extreme cases.

 [cols="2,3,5a"]
 .Block Label Syntax
 |===
 |Use |Reference |Syntax

 |Named blocks
 |<<block_labels>>
 |`<foo>` (preceding the open quote, after optional `{empty}*`) e.g. `{empty}*<bar>{` or `<baz>[{empty}'`

 |Quote escape
 |<<block_labels>>
 |`'{empty}]<foo>m5_\Bar[{empty}'`

 |Labeled number/special parameter reference
 |<<block_labels>>
 |`${empty}<foo>`, e.g. `${empty}<foo>2` or `${empty}<bar>#`
 |===

 Many macros accept arguments with syntaxes of their own, defined in the macro definition. Functions, for example are fundamental. See <<Functions>>.

 [index]
 == Index

'])
\SV
m5_output_with_restored_quotes(m5_defn(main_doc))
m5_output_with_restored_quotes(m5_mac_spec)
m5_output_with_restored_quotes(m5_defn(tail_doc))
