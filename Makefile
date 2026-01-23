# Zola - https://github.com/getzola/zola/releases
ZOLA_VERSION := 0.22.1

# Mermaid - https://www.jsdelivr.com/package/npm/mermaid
MERMAID_VERSION := 11.12.2

BINARIES := zola static/mermaid.min.js
OUTPUT_DIR := public


# Commands

.PHONY: build serve

build: download-binaries
	./zola build --output-dir $(OUTPUT_DIR) --force

serve: download-binaries
	./zola serve --output-dir $(OUTPUT_DIR) --force


# Binaries

.PHONY: download-binaries

download-binaries: $(BINARIES)

zola:
	wget -O - https://github.com/getzola/zola/releases/download/v$(ZOLA_VERSION)/zola-v$(ZOLA_VERSION)-x86_64-unknown-linux-gnu.tar.gz | tar xzf - zola

static/mermaid.min.js:
	wget -O $@ https://cdn.jsdelivr.net/npm/mermaid@$(MERMAID_VERSION)/dist/mermaid.min.js


# Clear

.PHONY: clean dist-clean

clean:
	rm -rf $(OUTPUT_DIR)

dist-clean: clean
	rm -rf $(BINARIES)
