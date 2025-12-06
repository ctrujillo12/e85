// lab6_ct.c
// Cheyenne Trujillo ctrujillo@g.hmc.edu 10-16-25


#include <math.h>
#include <stdlib.h>

// index = i * n + j

// Set Y = A + B.
// Adds two m-by-n matrices (encoded as 1D arrays of length m*n)
//   and put the sum into a third.
void add(int m, int n, double *A, double *B, double *Y) {
    for(int i=0; i<m*n; i++){
        // int idx = i * n + j;
        Y[i] = A[i] + B[i];
    }
    
    return; // TODO
}



// Set Y = sa * A + sb * B ("scaled" version of the add function)
//
void linearcomb(int m, int n, double sa, double sb, 
                double *A, double *B, double *Y) {
    for(int i=0; i<m; i++){
        for(int j=0; j<n; j++){
            int idx = i * n + j;
            Y[idx] = sa * A[idx] + sb * B[idx];
        }
    }
    return; // TODO
}


// Set At = transpose(A).
//     A is an m-by-n matrix (encoded as a 1D array of length m*n), and
//     At is a m-by-n matrix (encoded as a 1D array of length n*m)
//
void transpose(int m, int n, double *A, double *A_t) {
    for(int i=0; i<m; i++){
        for(int j=0; j<n; j++){
           A_t[j * m + i] = A[i * n + j];
        }
    }
   
    
    return; // TODO
}


// Returns 1 if all m*n elements of A are equal to
//    the corresponding elements of B, and returns 0 otherwise
int equal(int m, int n, double *A, double *B) {

    for(int i=0; i<m*n; i++){
        // idx = i*n+j;
        if (A[i] != B[i]){
            return 0;
        }
    }


    return 1; // TODO
}


// Y = A * B
// Although all are represented with 1D arrays, we think of
//    A as  m1 by n1m2,  B as  n1m2 by n2, and Y as  m1 by n2.
void mult(int m1, int n1m2, int n2, double *A, double *B, double *Y) {
    
    for(int i=0; i<m1; i++){
        for(int j=0; j<n2; j++){

            double dotproduct = 0.0;

            for(int k=0; k<n1m2; k++){
                dotproduct += A[i * n1m2 + k] * B[k * n2 + j];
            }

            Y[i * n2 + j] = dotproduct;
        }
    }
    // for every row of A and column of B :
    //     dotproduct = dotproduct + A[idx]*B[idx] 
    return; // TODO
}


//////////////////////////////////////////////////////////////////
// The following helper functions and main() are provided for you.
//////////////////////////////////////////////////////////////////


// Given an m-by-n matrix (represented using a 1-dimensional
// array A of length m*n), return the sum of all m*n values 
// in the matrix.
// 
// The matrix is given as a 1-dimensional array A of length m*n,
// but that encodes a matrix with m rows and n columns as follows:
//
//   [ A[0]       A[1]       ...  A[n-1]  ]
//   [ A[n]       A[n+1]     ...  A[2n-1] ] 
//   [ A[2n]      A[2n+1]    ...  A[3n-1] ]
//   [ ...        ...        ...  ...     ]
//   [ A[mn-n]    A[mn-n+1]  ...  A[mn-1] ]
//
// Equivalently (but showing patterns more clearly) 
// the input A represents the matrix:
// 
//   [ A[0n    +0]  A[0n    +1] ...  A[0n    +(n-1)] ]
//   [ A[1n    +0]  A[1n    +1] ...  A[1n    +(n-1)] ] 
//   [ A[2n    +0]  A[2n    +1] ...  A[2n    +(n-1)] ]
//   [ ...          ...         ...  ...             ]
//   [ A[(m-1)n+0]  A[(m-1)n+1] ...  A[(m-1)n+(n-1)] ]
// 
double matrix_sum(int m, int n, double *A) {
    double sum = 0.0;
   
    // For each of the m rows (counting from 0)
    for (int i = 0; i < m; i++) {


        // For each of the n columns in row i (counting from 0)
        for (int j = 0; j < n; j++) {


            // Add the matrix value at row i, column j to our 
            //  running total (using the pattern above
            //  to find the correct value inside array A)
            sum += A[i*n + j];
        }
    }


    return sum;
}


// Returns an uninitialized m-by-n matrix of doubles
//    (encoded as a 1D array of length m*n)
// We have to use malloc because 
//
double *newMatrix(int m, int n) {
    double *mat = (double *)malloc(m * n * sizeof(double));
    return mat;
}


// Returns a new n-by-n matrix filled out as an identity
//   (i.e., all 0.0's except for 1.0's on the diagonal)
//
double *newIdentityMatrix(int n) {
    double *mat = newMatrix(n, n);


    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            mat[j + i * n] = (i == j);


    return mat;
}


// From the tutorial (and debugged)
double dotproduct(int n, double a[], double b[]) {
    double sum = 0.0;
    for (int i = 0; i < n; i++) {
        sum += a[i] * b[i];
    }
    return sum;
}


int main(void) {
    // Warm-up
    double v1[3] = {4, 2, 1};
    double v2[3] = {1, -2, 3};
    double dp = dotproduct(3, v1, v2); // compute v1 dot v2


    // We can think of the 9-element array m1 as
    // representing the 3x3 matrix
    //      [ m1[0] m1[1] m1[2] ]      [ 0.0 0.0 2.0 ]
    //      [ m1[3] m1[4] m1[5] ]  ==  [ 0.0 0.0 0.0 ]
    //      [ m1[6] m1[7] m1[8] ]      [ 2.0 0.0 0.0 ]
    double m1[9] = {0, 0, 2, 0, 0, 0, 2, 0, 0};


    // We can think of the 9-element array m2 as 
    // representing the 3x3 matrix
    //      [ m2[0] m2[1] m2[2] ]      [ 1.0 0.0 0.0 ]
    //      [ m2[3] m2[4] m2[5] ]  ==  [ 0.0 1.0 0.0 ]
    //      [ m2[6] m2[7] m2[8] ]      [ 0.0 0.0 1.0 ]
    double *m2 = newIdentityMatrix(3);


    // The 9-element array m3 starts out as 9 uninitialized doubles,
    // representing an uninitialized 3x3 matrix.
    //      [ m3[0] m3[1] m3[2] ]      [ ? ? ? ]
    //      [ m3[3] m3[4] m3[5] ]  ==  [ ? ? ? ]
    //      [ m3[6] m3[7] m3[8] ]      [ ? ? ? ]
    double *m3 = newMatrix(3, 3);


    // We can think of the 6-element array m4 as
    // representing the 3x2 matrix
    //      [ m4[0] m4[1] ]      [ 2 3 ]
    //      [ m4[2] m4[3] ]  ==  [ 4 5 ]
    //      [ m4[4] m4[5] ]      [ 6 7 ]
    double m4[6] = {2, 3, 4, 5, 6, 7};


    // The 6-element array m5 starts out uninitialized, 
    // representing an uninitialized 3x2 matrix.
    //      [ m5[0] m5[1] ]      [ ? ? ]
    //      [ m5[2] m5[3] ]  ==  [ ? ? ]
    //      [ m5[4] m5[5] ]      [ ? ? ]
    double *m5 = newMatrix(3, 2); // 3x2 matrix


    // We can think of the 6-element array m6 as representing
    // representing the 2x3 matrix
    //     [ m6[0] m6[1] m6[2] ]  ==  [ 6 2 5 ]
    //     [ m6[3] m6[4] m6[5] ]      [ 8 2 7 ]
    double m6[6] = {6, 2, 5, 8, 2, 7};


    // m7 and m8 are 6-element arrays; like m5 they
    // start out as uninitialized 3x2 matrices.
    double *m7 = newMatrix(3, 2);
    double *m8 = newMatrix(3, 2);


    // This is the expected final value of m8
    // after running the tests below.
    double expected[6] = {2, 1, 0, 1, 0, -1};


    // Run some tests
    //
    add(3, 3, m1, m2, m3);                   // m3 = m1+m2
    mult(3, 3, 2, m3, m4, m5);               // m5 = m3*m4
    transpose(2, 3, m6, m7);                 // m7 = m6^t
    linearcomb(3, 2, 1, 1 - dp, m5, m7, m8); // m8 = 1*m5 + (1-dp)*m7
    int eq = equal(3, 2, m8, expected);      // check m8


    return !eq; // return 0 if it worked (no error) and 1 otherwise
}
