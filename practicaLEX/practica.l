/* Declaraciones */

%{
  #include <stdio.h>
  #include <ctype.h>
  #include <string.h>
  #include <stdlib.h>

  typedef struct {
    double secsInicio;
    double secsFinal;
    char texto[256];
  } Subtitulo;

  Subtitulo subtitulos[1024];
  int total = 0;
  int final = 0;

  int aNumero(char c) {
    return c - 48;
  }

  void convertir(char texto[]) {
    int horas = aNumero(texto[0]) * 10 + aNumero(texto[1]);
    int minutos = aNumero(texto[3]) * 10 + aNumero(texto[4]);
    int segundos = aNumero(texto[6]) * 10 + aNumero(texto[7]);
    double milisegundos = (aNumero(texto[9]) * 100 + aNumero(texto[10]) * 10 + aNumero(texto[11])) / 1000.0;
    double totalSecs = horas * 3600 + minutos * 60 + segundos + milisegundos;
    if (final) {
      subtitulos[total - 1].secsFinal = totalSecs;
    } else {
      subtitulos[total - 1].secsInicio = totalSecs;
    }
    final = ++final % 2;
  }

  void copiar(char texto[]) {
    strcpy(subtitulos[total - 1].texto, texto);
  }
%}

cifra               [0-9]
doscifras           ({cifra}{2})":"
real                ({cifra}{2})","({cifra}{3})
tiempo              {doscifras}{doscifras}{real}
numero              {cifra}+
flechita            " --> "
texto               [^\n]+(\n[^\n]+)*

%x primerTiempo segundoTiempo leerTexto flecha

/* Reglas */
%%
\n                             { }
{numero}                       { ++total; BEGIN(primerTiempo); }
<primerTiempo>\n               { }
<primerTiempo>{tiempo}         { convertir(yytext); BEGIN(flecha); }
<flecha>\n                     { }
<flecha>{flechita}             { BEGIN(segundoTiempo); }
<segundoTiempo>\n              { }
<segundoTiempo>{tiempo}        { convertir(yytext); BEGIN(leerTexto); }
<leerTexto>\n                  { }
<leerTexto>{texto}             { copiar(yytext); BEGIN(INITIAL); }

%%

/* Procedimientos */

void intercambiarSubtitulos(int j, int k) {
  Subtitulo aux = subtitulos[j];
  subtitulos[j] = subtitulos[k];
  subtitulos[k] = aux;
}

void imprimirMenu() {
  printf("\nMenú:\n1. Atrasar\n2. Adelantar\n3. Añadir\n4. Eliminar\n5. Intercambiar\n6. Modificar\n7. Salir\n");
}

void imprimirSubOpciones() {
  printf("\n1. Todo\n2. Uno\n3. Rango\n4. Salir\n");
}


int escogerOpcion(int max) {
  int d;
  do {
    printf("\nIntroduzca opción: ");
    scanf("%d", &d);
  } while (d > max || d < 1);
  return d;
}

float obtenerTiempo() {
  float d;
  printf("\nTiempo en segundos: ");
  scanf("%f", &d);
  return d;
}

int obtenerPosicion() {
  int d;
  printf("\nPosicion: ");
  scanf("%d", &d);
  return d;
}

void atrasar() {
  int o;
  double d;
  int j;
  int k;
  do {
    imprimirSubOpciones();
    o = escogerOpcion(4);
    switch (o) {
      case 1:
        d = obtenerTiempo();
        for (j = 0; j < total; ++j) {
          subtitulos[j].secsInicio += d;
          subtitulos[j].secsFinal += d;
        }
        break;
      case 2:
        j = obtenerPosicion();
        d = obtenerTiempo();
        subtitulos[j].secsInicio += d;
        subtitulos[j].secsFinal += d;
        break;
      case 3:
        j = obtenerPosicion();
        k = obtenerPosicion();
        d = obtenerTiempo();
        for (j; j <= k; ++j) {
          subtitulos[j].secsInicio += d;
          subtitulos[j].secsFinal += d;
        }
        break;
    }
  } while (o != 4);
}

void adelantar() {
  int o;
  double d;
  int j;
  int k;
  do {
    imprimirSubOpciones();
    o = escogerOpcion(4);
    switch (o) {
      case 1:
        d = obtenerTiempo();
        for (j = 0; j < total; ++j) {
          subtitulos[j].secsInicio -= d;
          subtitulos[j].secsFinal -= d;
        }
        break;
      case 2:
        j = obtenerPosicion();
        d = obtenerTiempo();
        subtitulos[j].secsInicio -= d;
        subtitulos[j].secsFinal -= d;
        break;
      case 3:
        j = obtenerPosicion();
        k = obtenerPosicion();
        for (j; j <= k; ++j) {
          subtitulos[j].secsInicio -= d;
          subtitulos[j].secsFinal -= d;
        }
        break;
    }
  } while (o != 4);
}

void aniadir() {
  int pos = obtenerPosicion();
  int j;
  for (j = total - 1 ; j >= pos; --j) {
    subtitulos[j + 1] = subtitulos[j];
  }
  ++total;
  double ini = obtenerTiempo();
  double final = obtenerTiempo();
  subtitulos[pos].secsFinal = final;
  subtitulos[pos].secsInicio = ini;
  printf("\nIntroduce el texto: ");
  getchar();
  fgets(subtitulos[pos].texto, sizeof(subtitulos[pos].texto), stdin);
  strtok(subtitulos[pos].texto, "\n");
}

void eliminar() {
  int j = obtenerPosicion();
  int k;
  for (k = j; k < total; ++k) {
    subtitulos[k] = subtitulos[k + 1];
  }
  --total;
}

void intercambiar() {
  int j = obtenerPosicion();
  int k = obtenerPosicion();
  intercambiarSubtitulos(j, k);
}

void imprimirTiempo(FILE* archivo, double tiempo) {
  int enteros = tiempo;
  int milisegundos = (tiempo - enteros) * 1000;
  int horas = enteros / 3600;
  int minutos = (enteros % 3600) / 60;
  int segundos = (enteros % 3600) % 60;

  char buffhoras[3];
  char buffminutos[3];
  char buffsegundos[3];
  char buffmilisegundos[4];

  sprintf(buffhoras, "%d", horas);
  sprintf(buffminutos, "%d", minutos);
  sprintf(buffsegundos, "%d", segundos);
  sprintf(buffmilisegundos, "%d", milisegundos);

  if (horas < 10) {
    fprintf(archivo, "0%s:", buffhoras);
  } else {
    fprintf(archivo, "%s:", buffhoras);
  }

  if (minutos < 10) {
    fprintf(archivo, "0%s:", buffminutos);
  } else {
    fprintf(archivo, "%s:", buffminutos);
  }

  if (segundos < 10) {
    fprintf(archivo, "0%s,", buffsegundos);
  } else {
    fprintf(archivo, "%s,", buffsegundos);
  }

  if (milisegundos < 10) {
    fprintf(archivo, "00%s", buffmilisegundos);
  } else if (milisegundos < 100) {
    fprintf(archivo, "0%s", buffmilisegundos);
  } else {
    fprintf(archivo, "%s", buffmilisegundos);
  }
}

void modificar() {
  int pos = obtenerPosicion();
  int c;
  double d;
  do {
    printf("\n1. Tiempo inicial\n2. Tiempo final\n3. Texto\n4. Salir\n");
    c = escogerOpcion(4);
    switch (c) {
      case 1:
        d = obtenerTiempo();
        subtitulos[pos].secsInicio = d;
        break;
      case 2:
        d = obtenerTiempo();
        subtitulos[pos].secsFinal = d;
        break;
      case 3:
        printf("\nIntroduce el texto: ");
        getchar();
        fgets(subtitulos[pos].texto, sizeof(subtitulos[pos].texto), stdin);
        strtok(subtitulos[pos].texto, "\n");
        break;
    }
  } while (c != 4);
}

int main(int argc, char* argv[]) {
  if (argc != 2) {
    printf("Fichero de subtítulos no introducido\n");
    exit(-1);
  }

  yyin = fopen(argv[1], "rt");
  if (yyin == NULL) {
    printf("El fichero %s no se puede abrir\n", argv[1]);
    exit(-1);
  }

  yylex();

  int c;
  do {
    imprimirMenu();
    c = escogerOpcion(7);
    switch (c) {
      case 1:
        atrasar();
        break;
      case 2:
        adelantar();
        break;
      case 3:
        aniadir();
        break;
      case 4:
        eliminar();
        break;
      case 5:
        intercambiar();
        break;
      case 6:
        modificar();
        break;
      }
  } while (c != 7);


  FILE* archivo = fopen("subtitulosModificados.srt", "w+");
  if (archivo == NULL) {
    printf("\nError creando subtitulos\n");
    exit(-1);
  }

  int j;
  for (j = 0; j < total; ++j) {
    fprintf(archivo, "%d\n", j + 1);
    imprimirTiempo(archivo, subtitulos[j].secsInicio);
    fprintf(archivo, " --> ");
    imprimirTiempo(archivo, subtitulos[j].secsFinal);
    fprintf(archivo, "\n");
    fprintf(archivo, "%s\n\n", subtitulos[j].texto);
  }

  fclose(archivo);
  return 0;
}
