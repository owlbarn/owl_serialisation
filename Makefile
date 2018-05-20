
all: build

build:
	jbuilder build @install

doc: _build
	jbuilder build @doc

clean:
	jbuilder clean
