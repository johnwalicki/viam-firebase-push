VENV   := venv
PYTHON := $(VENV)/bin/python

.PHONY: setup build module run update clean

# setup.sh skips pip when .installed exists, so drop the marker whenever
# requirements.txt changes to force a reinstall.
.installed: requirements.txt
	rm -f .installed
	sh ./setup.sh

setup: .installed

# PyInstaller one-file binary, packaged as dist/archive.tar.gz (meta.json build.path).
build: setup
	sh ./build.sh

module: build

run: setup
	exec $(PYTHON) -m src.main $(ARGS)

# Bump the viam-sdk pin in requirements.txt to the latest release on PyPI.
update:
	@latest=$$(curl -s https://pypi.org/pypi/viam-sdk/json | python3 -c 'import json,sys; print(json.load(sys.stdin)["info"]["version"])'); \
	sed -i "s/^viam-sdk==.*/viam-sdk==$$latest/" requirements.txt; \
	echo "viam-sdk pinned to $$latest"

clean:
	rm -rf $(VENV) .installed build dist main.spec
