.PHONY: build test run app clean

build:
	swift build

test:
	swift test

run:
	swift run Monomi

app:
	./scripts/make-app.sh

clean:
	swift package clean
	rm -rf build
