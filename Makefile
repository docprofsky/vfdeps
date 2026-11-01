PATH:=$(PREFIX)/bin:$(PATH)

all: ocaml findlib num zarith ocamlbuild camlp-streams lablgtk z3 csexp dune sexplib0 base res stdio cppo ocplib-endian stdint result capnp capnp-ocaml stdlib-shims ocaml-compiler-libs ppx_derivers ppxlib ppx_parser

# ---- OCaml ----

OCAML_VERSION=4.14.2
OCAML_BINARY=$(PREFIX)/bin/ocamlopt.opt

ocaml-$(OCAML_VERSION).tar.gz:
	./download ocaml-$(OCAML_VERSION).tar.gz https://github.com/ocaml/ocaml/archive/$(OCAML_VERSION).tar.gz c2d706432f93ba85bd3383fa451d74543c32a4e84a1afaf3e8ace18f7f097b43

ocaml-$(OCAML_VERSION): ocaml-$(OCAML_VERSION).tar.gz
	tar xzf ocaml-$(OCAML_VERSION).tar.gz

$(OCAML_BINARY): | ocaml-$(OCAML_VERSION)
	cd ocaml-$(OCAML_VERSION) && \
        ./configure -prefix $(PREFIX) && \
        $(MAKE) && \
        $(MAKE) install

ocaml: $(OCAML_BINARY)
.PHONY: ocaml

clean::
	-rm -Rf ocaml-$(OCAML_VERSION)

# ---- Findlib ----

FINDLIB_VERSION=1.9.8
FINDLIB_BINARY=$(PREFIX)/bin/ocamlfind

findlib-$(FINDLIB_VERSION).tar.gz:
	./download findlib-$(FINDLIB_VERSION).tar.gz http://download.camlcity.org/download/findlib-$(FINDLIB_VERSION).tar.gz 662c910f774e9fee3a19c4e057f380581ab2fc4ee52da4761304ac9c31b8869d

findlib-$(FINDLIB_VERSION): findlib-$(FINDLIB_VERSION).tar.gz
	tar xzf findlib-$(FINDLIB_VERSION).tar.gz

findlib-$(FINDLIB_VERSION)/Makefile.config: $(OCAML_BINARY) | findlib-$(FINDLIB_VERSION)
	cd findlib-$(FINDLIB_VERSION) && \
	./configure \
	  -bindir $(PREFIX)/bin \
          -mandir $(PREFIX)/man \
          -sitelib $(PREFIX)/lib/ocaml \
          -config $(PREFIX)/etc/findlib.conf

$(FINDLIB_BINARY): findlib-$(FINDLIB_VERSION)/Makefile.config
	cd findlib-$(FINDLIB_VERSION) && \
        $(MAKE) all && \
        $(MAKE) opt && \
        $(MAKE) install

findlib: $(FINDLIB_BINARY)
.PHONY: findlib

clean::
	-rm -Rf findlib-$(FINDLIB_VERSION)

# ---- Num ----

NUM_VERSION=1.4
NUM_BINARY=$(PREFIX)/lib/ocaml/nums.cmxa

num-$(NUM_VERSION).tar.gz:
	./download num-$(NUM_VERSION).tar.gz https://github.com/ocaml/num/archive/v$(NUM_VERSION).tar.gz 015088b68e717b04c07997920e33c53219711dfaf36d1196d02313f48ea00f24

num-$(NUM_VERSION): num-$(NUM_VERSION).tar.gz
	tar xzf num-$(NUM_VERSION).tar.gz

$(NUM_BINARY): $(FINDLIB_BINARY) | num-$(NUM_VERSION)
	cd num-$(NUM_VERSION) && $(MAKE) all && $(MAKE) install

num: $(NUM_BINARY)
.PHONY: num

clean::
	-rm -Rf num-$(NUM_VERSION)

# ---- Zarith ----

ZARITH_VERSION=1.14
ZARITH_BINARY=$(PREFIX)/lib/ocaml/zarith.cmxa

zarith-$(ZARITH_VERSION).tar.gz:
	./download zarith-$(ZARITH_VERSION).tar.gz https://github.com/ocaml/Zarith/archive/release-$(ZARITH_VERSION).tar.gz 5db9dcbd939153942a08581fabd846d0f3f2b8c67fe68b855127e0472d4d1859

zarith-$(ZARITH_VERSION): zarith-$(ZARITH_VERSION).tar.gz
	tar xzf zarith-$(ZARITH_VERSION).tar.gz

$(ZARITH_BINARY): $(FINDLIB_BINARY) | zarith-$(ZARITH_VERSION)
	cd Zarith-release-$(ZARITH_VERSION) && ./configure && $(MAKE) all && $(MAKE) install

zarith: $(ZARITH_BINARY)
.PHONY: zarith

clean::
	-rm -Rf zarith-$(ZARITH_VERSION)

# ---- ocamlbuild ----
# not used by þe flake, but 0.16.1 is þe version in boþ of þe flake's Nixpkgs

OCAMLBUILD_VERSION=0.16.1
OCAMLBUILD_BINARY=$(PREFIX)/bin/ocamlbuild

ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz:
	./download ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz https://github.com/ocaml/ocamlbuild/archive/$(OCAMLBUILD_VERSION).tar.gz 2ba6857f2991b7f69368e8db818b163d31cf5a367f15f5953bf8f01a77b3d4fc

ocamlbuild-$(OCAMLBUILD_VERSION): ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz
	tar xzf ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz

$(OCAMLBUILD_BINARY): $(FINDLIB_BINARY) | ocamlbuild-$(OCAMLBUILD_VERSION)
	cd ocamlbuild-$(OCAMLBUILD_VERSION) && \
        $(MAKE) configure && $(MAKE) && $(MAKE) install

ocamlbuild: $(OCAMLBUILD_BINARY)
.PHONY: ocamlbuild

clean::
	-rm -Rf ocamlbuild-$(OCAMLBUILD_VERSION)

# ---- dune ----
DUNE_VERSION=3.17.2
DUNE_BINARY=$(PREFIX)/bin/dune

dune-$(DUNE_VERSION).tar.gz:
	./download $@ https://github.com/ocaml/dune/archive/refs/tags/$(DUNE_VERSION).tar.gz 1b45e34d1eacf40be569e4d7ad055508a3242637b098327c91f7ce67772a1889

dune-$(DUNE_VERSION): dune-$(DUNE_VERSION).tar.gz
	tar xzf $<

$(DUNE_BINARY): $(OCAML_BINARY) $(FINDLIB_BINARY) | dune-$(DUNE_VERSION)
	cd $| && ./configure --libdir=$(PREFIX)/lib/ocaml && $(MAKE) release && $(MAKE) install

dune: $(DUNE_BINARY)
.PHONY: dune

clean::
	-rm -Rf dune-$(DUNE_VERSION)

DUNE_INSTALL=dune build @install --profile release && dune install --profile release --prefix=$(PREFIX) --libdir=$(PREFIX)/lib/ocaml

# ---- camlp-streams ----
CAMLP_STREAMS_VERSION=5.0.1
CAMLP_STREAMS_BINARY=$(PREFIX)/lib/ocaml/camlp-stream/camlp-streams.cmxa

camlp-streams-$(CAMLP_STREAMS_VERSION).tar.gz:
	./download $@ https://github.com/ocaml/camlp-streams/archive/refs/tags/v$(CAMLP_STREAMS_VERSION).tar.gz ad71f62406e9bb4e7fb5d4593ede2af6c68f8b0d96f25574446e142c3eb0d9a4

camlp-streams-$(CAMLP_STREAMS_VERSION): camlp-streams-$(CAMLP_STREAMS_VERSION).tar.gz
	tar xzf $<

$(CAMLP_STREAMS_BINARY): $(DUNE_BINARY) | camlp-streams-$(CAMLP_STREAMS_VERSION)
	cd $| && $(DUNE_INSTALL)

camlp-streams: $(CAMLP_STREAMS_BINARY)
.PHONY: camlp-streams

clean::
	-rm -Rf camlp-streams-$(CAMLP_STREAMS_VERSION)

# ---- lablgtk ----

LABLGTK_VERSION=2.18.13
LABLGTK_BINARY=$(PREFIX)/lib/ocaml/lablgtk2/lablgtk.cmxa

lablgtk-$(LABLGTK_VERSION).tar.gz:
	./download lablgtk-$(LABLGTK_VERSION).tar.gz https://github.com/garrigue/lablgtk/archive/refs/tags/$(LABLGTK_VERSION).tar.gz 7b9e680452458fd351cf8622230d62c3078db528446384268cd0dc37be82143c

lablgtk-$(LABLGTK_VERSION): lablgtk-$(LABLGTK_VERSION).tar.gz
	tar xzf lablgtk-$(LABLGTK_VERSION).tar.gz

$(LABLGTK_BINARY): $(FINDLIB_BINARY) | lablgtk-$(LABLGTK_VERSION)
	cd lablgtk-$(LABLGTK_VERSION) && \
        ./configure --prefix=$(PREFIX) && $(MAKE) world && $(MAKE) install

lablgtk: $(LABLGTK_BINARY)
.PHONY: lablgtk

clean::
	-rm -Rf lablgtk-$(LABLGTK_VERSION)

# ---- Z3 ----

Z3_VERSION=4.13.4
Z3_BINARY=$(PREFIX)/bin/z3
Z3_DIR=z3-z3-$(Z3_VERSION)

z3-$(Z3_VERSION).tar.gz:
	./download z3-$(Z3_VERSION).tar.gz https://github.com/Z3Prover/z3/archive/z3-$(Z3_VERSION).tar.gz 4071977e66e9f3d239b7b098ceddfe62ffdf3c71e345e9524a4a5001d1f4adf3

$(Z3_DIR): z3-$(Z3_VERSION).tar.gz
	tar xzf z3-$(Z3_VERSION).tar.gz

$(Z3_BINARY): $(FINDLIB_BINARY) $(ZARITH_BINARY) | $(Z3_DIR)
	cd $(Z3_DIR) && \
        python3 scripts/mk_make.py --ml --prefix=$(PREFIX) && \
        cd build && $(MAKE) && $(MAKE) install

z3: $(Z3_BINARY)
.PHONY: z3

clean::
	-rm -Rf $(Z3_DIR)

# ---- csexp ----
# not in flake
CSEXP_VERSION=1.5.2
CSEXP_BINARY=$(PREFIX)/lib/ocaml/csexp/csexp.cmxa

csexp-$(CSEXP_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-dune/csexp/archive/refs/tags/$(CSEXP_VERSION).tar.gz de3fda861ec8210a404fcb76afa162b08ed1cd11228645c78b53e1f82b24e236

csexp-$(CSEXP_VERSION): csexp-$(CSEXP_VERSION).tar.gz
	tar xzf $<

$(CSEXP_BINARY): $(DUNE_BINARY) | csexp-$(CSEXP_VERSION)
	cd $| && $(DUNE_INSTALL)

csexp: $(CSEXP_BINARY)
.PHONY: csexp

# ---- other dune libraries ----
STDUNE_BINARY=$(PREFIX)/lib/ocaml/stdune/stdune.cmxa
$(STDUNE_BINARY): $(DUNE_BINARY) $(CSEXP_BINARY) | dune-$(DUNE_VERSION)
	cd $| && dune build stdune.install && dune install stdune --prefix=$(PREFIX) --libdir=$(PREFIX)/lib/ocaml

DUNE_CONF_BINARY=$(PREFIX)/lib/ocaml/dune-configurator/configurator.cmxa
$(DUNE_CONF_BINARY): $(DUNE_BINARY) $(STDUNE_BINARY) | dune-$(DUNE_VERSION)
	cd $| && dune build dune-configurator.install && dune install dune-configurator --prefix=$(PREFIX) --libdir=$(PREFIX)/lib/ocaml

# ---- sexplib0 ----
# not in flake
SEXPLIB0_VERSION=0.16.0
SEXPLIB0_BINARY=$(PREFIX)/lib/ocaml/sexplib0/sexplib0.cmxa

sexplib0-$(SEXPLIB0_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/sexplib0/archive/refs/tags/v$(SEXPLIB0_VERSION).tar.gz 73002106488074187a174992da6e76f36f543e6daa80dbf6039a3e10e46adc80

sexplib0-$(SEXPLIB0_VERSION): sexplib0-$(SEXPLIB0_VERSION).tar.gz
	tar xzf $<

$(SEXPLIB0_BINARY): $(DUNE_BINARY) | sexplib0-$(SEXPLIB0_VERSION)
	cd $| && $(DUNE_INSTALL)

sexplib0: $(SEXPLIB0_BINARY)
.PHONY: sexplib0

clean::
	-rm -Rf sexplib0-$(SEXPLIB0_VERSION)

# ---- base ----
# not in flake
BASE_VERSION=0.16.2
BASE_BINARY=$(PREFIX)/lib/ocaml/base/base.cmxa

base-$(BASE_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/base/archive/refs/tags/v$(BASE_VERSION).tar.gz 2aa2f5c0fa9ebd3651fff4aa64d71830d4810fe841afd900427451670b909087

base-$(BASE_VERSION): base-$(BASE_VERSION).tar.gz
	tar xzf $<

$(BASE_BINARY): $(DUNE_BINARY) $(DUNE_CONF_BINARY) $(STDUNE_BINARY) $(SEXPLIB0_BINARY) | base-$(BASE_VERSION)
	cd $| && $(DUNE_INSTALL)

base: $(SEXPLIB0_BINARY) $(BASE_BINARY)
.PHONY: base

clean::
	-rm -Rf base-$(BASE_VERSION)

# ---- res ----
# not in flake
RES_VERSION=5.0.2
RES_BINARY=$(PREFIX)/lib/ocaml/res/res.cmxa

res-$(RES_VERSION).tar.gz:
	./download $@ https://github.com/mmottl/res/archive/refs/tags/$(RES_VERSION).tar.gz b2005a675a6eb799badf7ca4bd9b5fdbaeced43ae370441b59962f7fbb1a8245

res-$(RES_VERSION): res-$(RES_VERSION).tar.gz
	tar xzf $<

$(RES_BINARY): $(DUNE_BINARY) | res-$(RES_VERSION)
	cd $| && $(DUNE_INSTALL)

res: $(RES_BINARY)
.PHONY: res

clean::
	-rm -Rf res-$(RES_VERSION)

# ---- stdio ----
# not in flake
STDIO_VERSION=0.16.0
STDIO_BINARY=$(PREFIX)/lib/ocaml/stdio/stdio.cmxa

stdio-$(STDIO_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/stdio/archive/refs/tags/v$(STDIO_VERSION).tar.gz 388561b483894ae27b5968358b7978ae6a242f426e8c26fd92b39852d68b856e

stdio-$(STDIO_VERSION): stdio-$(STDIO_VERSION).tar.gz
	tar xzf $<

$(STDIO_BINARY): $(DUNE_BINARY) $(BASE_BINARY) | stdio-$(STDIO_VERSION)
	cd $| && $(DUNE_INSTALL)

stdio: $(STDIO_BINARY)
.PHONY: stdio

clean::
	-rm -Rf stdio-$(STDIO_VERSION)

# ---- cppo ----
# not in flake
# not in þe flake's closure
CPPO_VERSION=1.8.0
CPPO_BINARY=$(PREFIX)/bin/cppo

cppo-$(CPPO_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-community/cppo/archive/refs/tags/v$(CPPO_VERSION).tar.gz 6e62a8ee0217c9cc38d5860110eb18eb8d89c05c420353d298e1431fe8bac00f

cppo-$(CPPO_VERSION): cppo-$(CPPO_VERSION).tar.gz
	tar xzf $<

$(CPPO_BINARY): $(DUNE_BINARY) $(OCAMLBUILD_BINARY) | cppo-$(CPPO_VERSION)
	cd $| && $(DUNE_INSTALL)

cppo: $(CPPO_BINARY)
.PHONY: cppo

clean::
	-rm -Rf cppo-$(CPPO_VERSION)

# ---- ocplib-endian ----
# not in flake
OCPLIB-ENDIAN_VERSION=1.2
OCPLIB-ENDIAN_BINARY=$(PREFIX)/lib/ocaml/ocplib-endian/ocplib_endian.cmxa

ocplib-endian-$(OCPLIB-ENDIAN_VERSION).tar.gz:
	./download $@ https://github.com/OCamlPro/ocplib-endian/archive/$(OCPLIB-ENDIAN_VERSION).tar.gz 97ae74e8aeead46a0475df14af637ce78e2372c07258619ad8967506f2d4b320

ocplib-endian-$(OCPLIB-ENDIAN_VERSION): ocplib-endian-$(OCPLIB-ENDIAN_VERSION).tar.gz
	tar xzf $<

$(OCPLIB-ENDIAN_BINARY): $(DUNE_BINARY) $(CPPO_BINARY) | ocplib-endian-$(OCPLIB-ENDIAN_VERSION)
	cd $| && $(DUNE_INSTALL)

ocplib-endian: $(OCPLIB-ENDIAN_BINARY)
.PHONY: ocplib-endian

clean::
	-rm -Rf ocplib-endian-$(OCPLIB-ENDIAN_VERSION)

# ---- stdint ----
STDINT_VERSION=0.7.2
STDINT_DIR=ocaml-stdint-$(STDINT_VERSION)
STDINT_BINARY=$(PREFIX)/lib/ocaml/stdint/stdint.cmxa

stdint-$(STDINT_VERSION).tar.gz:
	./download $@ https://github.com/andrenth/ocaml-stdint/archive/refs/tags/$(STDINT_VERSION).tar.gz b0efc17f83f4a744f0a578edce476eba83aa1894c7e45993db375189b47c5e64

$(STDINT_DIR): stdint-$(STDINT_VERSION).tar.gz
	tar xzf $<

$(STDINT_BINARY): $(DUNE_BINARY) | $(STDINT_DIR)
	cd $| && $(DUNE_INSTALL)

stdint: $(STDINT_BINARY)
.PHONY: stdint

clean::
	-rm -Rf stdint-$(STDINT_VERSION)

# ---- result ----
# not in flake
RESULT_VERSION=1.5
RESULT_BINARY=$(PREFIX)/lib/ocaml/result/result.cmxa

result-$(RESULT_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/result/archive/refs/tags/$(RESULT_VERSION).tar.gz 1072a8b0b35bd6df939c0670add33027f981e4f69a53233cb006b442fa12af30

result-$(RESULT_VERSION): result-$(RESULT_VERSION).tar.gz
	tar xzf $<

$(RESULT_BINARY): $(DUNE_BINARY) | result-$(RESULT_VERSION)
	cd $| && $(DUNE_INSTALL)

result: $(RESULT_BINARY)
.PHONY: result

clean::
	-rm -Rf result-$(RESULT_VERSION)

# ---- cap'n proto ----
## capnp tool to produce stubs code based on .capnp schema files, also installs the C++ plugin to create C++ stubs
CAPNP_VERSION=1.4.0
CAPNP_DIR=capnproto-c++-$(CAPNP_VERSION)
CAPNP_BINARY=$(PREFIX)/bin/capnp

capnp-$(CAPNP_VERSION).tar.gz:
	./download $@ https://capnproto.org/capnproto-c++-$(CAPNP_VERSION).tar.gz fa02378ad522b318916b9ad928d1372fc9abd43dd1f4f0392e50450f5c87828f

$(CAPNP_DIR): capnp-$(CAPNP_VERSION).tar.gz
	tar xzf $<

$(CAPNP_BINARY): | $(CAPNP_DIR)
	cd $| && cmake -G Ninja -S . -B build -DWITH_ZLIB=OFF -DWITH_OPENSSL=OFF -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && cmake --build build --target install

capnp: $(CAPNP_BINARY)
.PHONY: capnp

clean::
	-rm -Rf $(CAPNP_DIR)

## capnp plugin for ocaml, which allows to create stubs code with the capnp tool
CAPNP_OCAML_VERSION=3.6.0
CAPNP_OCAML_DIR=capnp-ocaml-$(CAPNP_OCAML_VERSION)
CAPNP_OCAML_BINARY=$(PREFIX)/lib/ocaml/capnp/capnp.cmxa

capnp-ocaml-$(CAPNP_OCAML_VERSION).tar.gz:
	./download $@ https://github.com/capnproto/capnp-ocaml/archive/refs/tags/v$(CAPNP_OCAML_VERSION).tar.gz 5c9b774b577b44cebd117b218a1dba691d1b694e7529d2f88cf4d5eaca195007

$(CAPNP_OCAML_DIR): capnp-ocaml-$(CAPNP_OCAML_VERSION).tar.gz
	tar xzf $<

$(CAPNP_OCAML_BINARY): $(DUNE_BINARY) $(RES_BINARY) $(STDIO_BINARY) $(OCPLIB-ENDIAN_BINARY) $(STDINT_BINARY) $(RESULT_BINARY) | $(CAPNP_OCAML_DIR)
	cd $| && $(DUNE_INSTALL)

capnp-ocaml: $(CAPNP_BINARY) $(CAPNP_OCAML_BINARY)
.PHONY: capnp-ocaml

clean::
	-rm -Rf $(CAPNP_OCAML_DIR)

# ---- ocaml compiler libs ----
# not in flake
OCAML_COMPILER_LIBS_VERSION=0.12.4
OCAML_COMPILER_LIBS_BINARY=$(PREFIX)/lib/ocaml/ocaml-compiler-libs/toplevel/ocaml_toplevel.cmxa

ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/ocaml-compiler-libs/archive/refs/tags/v$(OCAML_COMPILER_LIBS_VERSION).tar.gz f4c37daf975b67c1f645a5d0294ec8ca686b982da410d9f915ccd93548c6e2f1

ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION): ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION).tar.gz
	tar xzf $<

$(OCAML_COMPILER_LIBS_BINARY): $(DUNE_BINARY) | ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION)
	cd $| && $(DUNE_INSTALL)

ocaml-compiler-libs: $(OCAML_COMPILER_LIBS_BINARY)
.PHONY: ocaml-compiler-libs

clean::
	-rm -Rd ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION)

# ---- stdlib-shims ----
# not in flake
STDLIB-SHIMS_VERSION=0.3.0
STDLIB-SHIMS_BINARY=$(PREFIX)/lib/ocaml/stdlib-shims/stdlib_shims.cmxa

stdlib-shims-$(STDLIB-SHIMS_VERSION).tar.gz:
	./download $@ https://github.com/ocaml/stdlib-shims/archive/refs/tags/$(STDLIB-SHIMS_VERSION).tar.gz 6d0386313a021146300011549180fcd4e94f7ac3c3bf021ff165f6558608f0c2

stdlib-shims-$(STDLIB-SHIMS_VERSION): stdlib-shims-$(STDLIB-SHIMS_VERSION).tar.gz
	tar xzf $<

$(STDLIB-SHIMS_BINARY): $(DUNE_BINARY) | stdlib-shims-$(STDLIB-SHIMS_VERSION)
	cd $| && $(DUNE_INSTALL)

stdlib-shims: $(STDLIB-SHIMS_BINARY)
.PHONY: stdlib-shims

clean::
	-rm -Rf stdlib-shims-$(STDLIB-SHIMS_VERSION)

# ---- ppx derivers ----
# not in flake
PPX_DERIVERS_VERSION=1.2.1
PPX_DERIVERS_BINARY=$(PREFIX)/lib/ocaml/ppx_derivers/ppx_derivers.cmxa

ppx_derivers-$(PPX_DERIVERS_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-ppx/ppx_derivers/archive/refs/tags/$(PPX_DERIVERS_VERSION).tar.gz b6595ee187dea792b31fc54a0e1524ab1e48bc6068d3066c45215a138cc73b95

ppx_derivers-$(PPX_DERIVERS_VERSION): ppx_derivers-$(PPX_DERIVERS_VERSION).tar.gz
	tar xzf $<

$(PPX_DERIVERS_BINARY): $(DUNE_BINARY) | ppx_derivers-$(PPX_DERIVERS_VERSION)
	cd $| && $(DUNE_INSTALL)

ppx_derivers: $(PPX_DERIVERS_BINARY)
.PHONY: ppx_derivers

clean::
	-rm -Rf ppx_derivers-$(PPX_DERIVERS_VERSION)

# ---- ppxlib ----
PPXLIB_VERSION=0.33.0
PPXLIB_BINARY=$(PREFIX)/lib/ocaml/ppxlib/ppxlib.cmxa

ppxlib-$(PPXLIB_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-ppx/ppxlib/archive/refs/tags/$(PPXLIB_VERSION).tar.gz 2834c8d58f433d80be8d17c116eb77ba54a4a7f21bb9e257e3f35dfd2aeb3ccc

ppxlib-$(PPXLIB_VERSION): ppxlib-$(PPXLIB_VERSION).tar.gz
	tar xzf $<

$(PPXLIB_BINARY): $(DUNE_BINARY) $(STDLIB-SHIMS_BINARY) $(OCAML_COMPILER_LIBS_BINARY) $(PPX_DERIVERS_BINARY) $(SEXPLIB0_BINARY) | ppxlib-$(PPXLIB_VERSION)
	cd $| && $(DUNE_INSTALL)

ppxlib: $(PPXLIB_BINARY)
.PHONY: ppxlib

clean::
	-rm -Rf ppxlib-$(PPXLIB_VERSION)

# ---- ppx parser ----
PPX_PARSER_VERSION=0.1.0
PPX_PARSER_BINARY=$(PREFIX)/lib/ocaml/ppx_parser/ppx_parser.cmxa

ppx_parser-$(PPX_PARSER_VERSION).tar.gz:
	./download $@ https://github.com/NielsMommen/ppx_parser/archive/refs/tags/$(PPX_PARSER_VERSION).tar.gz 42007eb6dfd7c6cdc02a4acae8a4d48626ba06fca4d5590aeeb1420943d0dc79

ppx_parser-$(PPX_PARSER_VERSION): ppx_parser-$(PPX_PARSER_VERSION).tar.gz
	tar xzf $<

$(PPX_PARSER_BINARY): $(DUNE_BINARY) $(PPXLIB_BINARY) $(CAMLP_STREAMS_BINARY) | ppx_parser-$(PPX_PARSER_VERSION)
	cd $| && $(DUNE_INSTALL)

ppx_parser: $(PPX_PARSER_BINARY)
.PHONY: ppx_parser

clean::
	-rm -Rf ppx_parser-$(PPX_PARSER_VERSION)
	
