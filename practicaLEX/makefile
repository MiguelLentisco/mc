all: modificarSubtitulos

modificarSubtitulos: lex.yy.c practica.l
	gcc lex.yy.c -o modificarSubtitulos -lfl

lex.yy.c: practica.l
	flex practica.l

ejemplo: modificarSubtitulos
	./modificarSubtitulos subtitulos/ejemplo.srt
