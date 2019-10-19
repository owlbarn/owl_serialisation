
all: build

build:
	dune build @install

doc: _build
	dune build @doc

clean:
	dune clean
