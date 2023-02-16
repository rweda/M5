# M5

The M5 Text Processing Language

# M5 Docs

The [latest PDF docs](https://docs.google.com/viewer?url=https://raw.githubusercontent.com/rweda/M5/main/doc/M5_spec.pdf) built from this repo are included in this repo for easy reference.

# Build

To build:

```sh
cd doc
./build_docs
```

The M5 docs are specified using M5 itself (as a `.tlv` file) in `doc/M5_spec_adoc.tlv`. The build
process runs SandPiper-SaaS in order to run M5, then runs `asciidoctor` to produce `.pdf` and
`.html` docs.

# Issues

HTML docs do not support a macro index (so the PDF is preferred).
