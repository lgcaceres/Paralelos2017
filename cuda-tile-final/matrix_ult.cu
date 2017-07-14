#include <stdio.h>
#include <stdlib.h>

#define THREAD_PER_BLOCK 2

__global__
void add_matrix(int* a, int* b, int* c,int n)
{
	int col = blockDim.x*blockIdx.x+ threadIdx.x;
	int row = blockDim.y*blockIdx.y+ threadIdx.y;

	if ( col<n && row<n )
	{
		c[row*n+col] = a[row*n+col] + b[row*n+col];
	}
}

__global__
void mult_matrix(int* a, int* b, int* c,int n)
{
	int col = blockDim.x*blockIdx.x+ threadIdx.x;
	int row = blockDim.y*blockIdx.y+ threadIdx.y;


	if ( col<n && row<n )
	{
		int i;
		c[row*n+col] = 0;

		for(i=0;i<n;i++)
		{
			c[row*n + col] += a[ row*n + i ]*b[ i*n + col ];

		}

	}
}

__global__
void mult_matrix_shared(int* a, int* b, int* c,int n)
{
	__shared__ float sub_a[THREAD_PER_BLOCK][THREAD_PER_BLOCK];
	__shared__ float sub_b[THREAD_PER_BLOCK][THREAD_PER_BLOCK];

	int bx = blockIdx.x; int by = blockIdx.y;
	int tx = threadIdx.x; int ty = threadIdx.y;
	
	int Row = by * THREAD_PER_BLOCK + ty;
	int Col = bx * THREAD_PER_BLOCK + tx;

	int Pvalue = 0;
	
	for (int ph = 0; ph < n/THREAD_PER_BLOCK; ++ph) {
	
		sub_a[ty][tx] = a[Row*n + ph*THREAD_PER_BLOCK + tx];
		sub_b[ty][tx] = b[(ph*THREAD_PER_BLOCK + ty)*n + Col];
		__syncthreads();
		
		for (int k = 0; k < THREAD_PER_BLOCK; ++k) {
			Pvalue += sub_a[ty][k] * sub_b[k][tx];
		}
		__syncthreads();
	}
	c[Row*n + Col] = Pvalue;
}

__global__ 
void  mult_mat_rectangular(int *d_M, int *d_N, int *p,int N){
	__shared__ int Mds[THREAD_PER_BLOCK][THREAD_PER_BLOCK];
	__shared__ int Nds[THREAD_PER_BLOCK][THREAD_PER_BLOCK];

	int bx = blockIdx.x;
	int by = blockIdx.y;

	int tx = threadIdx.x;
	int ty = threadIdx.y;

	int Row = by*THREAD_PER_BLOCK + ty;
	int Col = bx*2*THREAD_PER_BLOCK + tx;
	
	int Col2 = (bx*2 + 1)*THREAD_PER_BLOCK + tx;

	int p1 = 0;
	int p2 = 0;
	
	int k = 0;
	int prefM = d_M[Row*N + k*THREAD_PER_BLOCK + tx];
	int prefN = d_N[(k*THREAD_PER_BLOCK + ty)*N + Col];
	
	int prefN2 = d_N[(k*THREAD_PER_BLOCK + ty)*N + Col2];
		
	Mds[ty][tx] = prefM;
	Nds[ty][tx] = prefN;
	__syncthreads();
	
	for(int m = 0; m < N/THREAD_PER_BLOCK ; ++m){				
		
		prefM = d_M[Row*N + m*THREAD_PER_BLOCK + tx];
		prefN = d_N[(m*THREAD_PER_BLOCK + ty)*N + Col];
		
		for(int k = 0; k < THREAD_PER_BLOCK; k++){
			p1 += Mds[ty][k] * Nds[k][tx];
		}		
		
		__syncthreads();
		
		Nds[ty][tx] = prefN2;
		
		__syncthreads();
		
		prefN2 = d_N[(m*THREAD_PER_BLOCK + ty)*N + Col2];
		
		for(int k = 0; k < THREAD_PER_BLOCK; k++){
			p2 += Mds[ty][k] * Nds[k][tx];
		}
		__syncthreads();
		
		
		Mds[ty][tx] = prefM;
		Nds[ty][tx] = prefN;
		
	}
	p[Row*N + Col] = p1;
	p[Row*N + Col2] = p2;
}

void print_matrix(int* a,int n)
{
	int i,j;
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			printf("%d ",a[i*n+j]);
		}
		printf("\n");
	}
}

void fill_matrix(int* a,int n)
{
	int i,j;
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			//a[i*n+j] = rand()%5+1;
			a[i*n+j] = 1;
		}
	}
}

int main()
{
	int *a,*b,*c;
	int *d_a,*d_b,*d_c;

	int mat_elem = 8;
	int my_size = mat_elem*mat_elem*sizeof(int);

	//cudaEvent_t my_start,my_stop;
	//cudaEventCreate(&my_start);
	//cudaEventCreate(&my_stop);

	a = (int*) malloc(my_size);
	b = (int*) malloc(my_size);
	c = (int*) malloc(my_size);

	fill_matrix(a,mat_elem);
	fill_matrix(b,mat_elem);

	printf("Matrix A\n");
	print_matrix(a,mat_elem);
	printf("Matrix B\n");
	print_matrix(b,mat_elem);
	printf("\n");

	cudaMalloc((void**)&d_a,my_size);
	cudaMalloc((void**)&d_b,my_size);
	cudaMalloc((void**)&d_c,my_size);

	cudaMemcpy(d_a,a,my_size,cudaMemcpyHostToDevice);
	cudaMemcpy(d_b,b,my_size,cudaMemcpyHostToDevice);

	dim3 my_block(THREAD_PER_BLOCK,THREAD_PER_BLOCK);
	dim3 my_grid((mat_elem + THREAD_PER_BLOCK-1)/my_block.x,(mat_elem + THREAD_PER_BLOCK-1)/my_block.y);
	
	//////////////////////ELAPSED TIME ///////////////////////////////
	
	//cudaEventRecord(my_start,0);
	//mult_matrix<<<my_grid,my_block>>>(d_a, d_b, d_c,mat_elem);
	mult_mat_rectangular<<<my_grid,my_block>>>(d_a, d_b, d_c,mat_elem);
	//cudaEventRecord(my_stop,0);
	//cudaEventSynchronize(my_stop);
	/////////////////////////////////////////////////////
	
	//float elapsed_time;
	//cudaEventElapsedTime(&elapsed_time,my_start,my_stop);

	cudaMemcpy(c,d_c,my_size,cudaMemcpyDeviceToHost);
	printf("Matrix C\n");
	print_matrix(c,mat_elem);	


	//printf("time : %f\n",elapsed_time);
	return 0;
}