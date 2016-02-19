elm:
	elm-make Main.elm --output app.js

watch:
	find . -name '*.elm' -not -path './elm-stuff/*' | entr make elm
