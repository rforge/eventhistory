#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* Integer-Vgl. auf glibc f�r qsort() */
int compare_ints( const void *a, const void *b ) {
  const int *ia = (const int *) a;
  const int *ib = (const int *) b;
  return (*ia > *ib) - (*ia < *ib);
}

/*****************************************************************************
 * Erstellt eine zuf�llige Permutation aus einem Intervall [start, stop[
 * mit oder ohne Zur�cklegen. Die Ergebnisliste wird sortiert.
 * Dabei werden m Zahlen gezogen. Wenn m nicht gesetzt, dann wird die
 * L�nge (stop-start) angenommen.
 *
 * Zufallszahlen: der Seed wird hier nicht ge�ndert, muss im Hauptprogramm
 * passieren.
 *
 * Da dynamisch Speicher allokiert wird, muss aufgepa�t werden, dass dieser
 * auch wieder freigegeben wird: free( res )
 *
 * PARAMETER:
 *         int    start   - Untere Indexgrenze Ursprungsarray
 *         int    stop    - Obere Indexgrenze Ursprungsarray (> start angen.)
 *         int    m       - Anzahl der zu ziehenden Werte
 *                          (Mit Zur�cklegen oder m==0 ==> ( stop - start))
 *         int    back    - Flag: 0 - Ziehen ohne Zur�cklegen
 *                                1 - Ziehen mit Zur�cklegen
 *         int  **res     - Pointer auf Zielarray (wird komplett neu allokiert)
 *****************************************************************************/
void shake( int start, int stop, int back, int m, int **res ) {
  int len;
  int i;

  /* L�nge neues Array. Wenn m nicht gesetzt, dann stop - start */
  len = ( m == 0 ) ? stop - start : m;

  /* Speicher f�r das Indexarray. */
  *res = malloc( (size_t) len * sizeof( int ) );

  /* Ziehen mit Zur�cklegen. */
  if( back == 1 ) {
    for( i = 0; i < len; i++ ) {
      /* Index zuf�llig ziehen. */
      (*res)[i] = ( rand() % ( stop - start ) ) + start;
    }
  }
  /* Ziehen ohne Zur�cklegen.
     K�nnte sicher auch wesentlich eleganter und auch schneller sein,
     da hier am Ende viele Zufallszahlen verworfen werden.
   */
  else {
    /* GCC erlaubt lokale Arrays mit parametrisierter Gr��e.
        int taken[len];
       W�re eigentlich sch�ner, da das Array dann auf dem Heap erzeugt werden
       w�rde. Untere L�sung ist aber portabler. Ebenso entf�llt die eigene
       Initialisierung.
       Andere Compiler brauchen hier ein m/c-alloc */
    int *taken = calloc( stop - start, sizeof( int ) );    /* Init auf 0 */

    i = 0;

    while( i < len ) {
      /* Index zuf�llig ziehen.
         Index geht von 0 bis ( stop - start - 1 ) => es wird bei
         ( stop - start ) Durchl�ufen jeder Wert zwischen
         Durchl�ufen jeder Index genau einmal erzeugt.
	  */
      int index = rand() % ( stop - start );

      /* Wenn dieser Index schon gepickt wurde, dann direkt die n�chste
         Zahl suchen. */
      if( taken[index] > 0 ) continue;

      taken[index] = 1;                 /* Index als belegt markieren. */
      (*res)[i++] = index + start;      /* Index speichern. */
    }

    free( taken );
  }

  /* Vor der R�ckgabe sortieren. */
  qsort( *res, len, sizeof( int ), compare_ints );
}

/*
 Test...
 */
#define maxLen 1000

int main( int argc, char* argv[] ) {
  int    start, stop, m;
  int    *res;

  int    i;

  /* Random Seed, sollte vom R-Programm aus gesetzt werden. */
  srand( 1001 );

  start = 100;
  stop  = 120;
  m     = 10;

  /* Resample: neu durchmischen. Ziehen ohne Zur�cklegen. */
  /* printf( "Ziehen ohne Zur�cklegen...\n\n" ); */

  shake( start, stop, 0, m, &res );

  /* for( i = 0; i < m; i++ ) { */
    /* printf( "%d: INDEX: %d\n", i, res[i] ); */
  /* } */

  /* Wichtisch: dynamischer Speicher freigeben. */
  free( res );

  /* printf( "\n\nZiehen mit Zur�cklegen...\n\n" ); */

  m = 0;   /* Keine Anzahlsbeschr�nkung. */
  shake( start, stop, 1, m, &res );

  /* for( i = 0; i < ( ( m > 0 ) ? m : ( stop - start ) ); i++ ) { */
    /* printf( "%d: INDEX: %d\n", i, res[i] ); */
  /* } */

  free( res );
}
