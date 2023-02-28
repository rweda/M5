# M5

The M5 Text Processing Language

# M5 Docs

The docs can be viewed [here](doc/M5_spec.adoc), but the index does not render in GitHub, so for anything more than window shopping, [download the PDF](doc/M5_spec.pdf).

# Build

To build:

```sh
cd doc
./build_docs
```

The M5 docs are specified using M5 itself (as a `.tlv` file) in `doc/M5_spec_adoc.tlv`. `build_docs` runs SandPiper-SaaS
in order to process `M5_spec_adoc.tlv` using M5, then it runs `asciidoctor` to produce `.pdf` and
`.html` docs. Installation of `asciidoctor` is left as an exercise for the reader.

# Issues

HTML docs do not support a macro index (so the PDF is preferred).
