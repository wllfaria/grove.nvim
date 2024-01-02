format:
	stylua lua/ --config-path=.stylua.toml

lint:
	luacheck lua/ --globals vim

test:
	nvim --headless --noplugin -u scripts/tests/minimal.vim \
		-c 'PlenaryBustedDirectory tests/ {minimal_init = "scripts/tests/minimal.vim"}'

all: format lint test
