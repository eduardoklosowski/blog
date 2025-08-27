ZOLA_VERSION := 0.21.0
BINARIES := zola
OUTPUT_DIR := public


# Commands

.PHONY: build serve

build: zola
	./zola build --output-dir $(OUTPUT_DIR)

serve: zola
	./zola serve --output-dir $(OUTPUT_DIR)


# Binaries

.PHONY: download-all-binaries

download-all-binaries: $(BINARIES)

zola:
	wget -O - https://github.com/getzola/zola/releases/download/v$(ZOLA_VERSION)/zola-v$(ZOLA_VERSION)-x86_64-unknown-linux-gnu.tar.gz | tar xzf -


# Clear

.PHONY: clean dist-clean

clean:
	rm -rf $(OUTPUT_DIR)

dist-clean: clean
	rm -rf $(BINARIES)
