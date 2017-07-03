#include <stdio.h>
#include <stdlib.h>

#define THREAD_PER_BLOCK 70


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
	__shared__ float Mds[THREAD_PER_BLOCK][THREAD_PER_BLOCK];
	__shared__ float Nds[THREAD_PER_BLOCK][THREAD_PER_BLOCK];

	int bx = blockIdx.x; int by = blockIdx.y;
	int tx = threadIdx.x; int ty = threadIdx.y;
	
	int Row = by * THREAD_PER_BLOCK + ty;
	int Col = bx * THREAD_PER_BLOCK + tx;

	int Pvalue = 0;
	
	for (int ph = 0; ph < n/THREAD_PER_BLOCK; ++ph) {
	
		Mds[ty][tx] = a[Row*n + ph*THREAD_PER_BLOCK + tx];
		Nds[ty][tx] = b[(ph*THREAD_PER_BLOCK + ty)*n + Col];
		__syncthreads();
		
		for (int k = 0; k < THREAD_PER_BLOCK; ++k) {
			Pvalue += Mds[ty][k] * Nds[k][tx];
		}
		__syncthreads();
	}
	c[Row*n + Col] = Pvalue;
}


void fill_mat(int* a,int n)
{
	int i,j;
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			a[i*n+j] = rand()%5+1;
		}
	}
}

int main()
{
	int *a,*b,*c;
	int *d_a,*d_b,*d_c;

	int mat_elem = 2000;
	int my_size = mat_elem*mat_elem*sizeof(int);
	
	float tiempo;
	cudaEvent_t inicio,final;
	cudaEventCreate(&inicio);
	cudaEventCreate(&final);

	a = (int*) malloc(my_size);
	b = (int*) malloc(my_size);
	c = (int*) malloc(my_size);

	fill_mat(a,mat_elem);
	fill_mat(b,mat_elem);
	printf("\n");

	cudaMalloc((void**)&d_a,my_size);
	cudaMalloc((void**)&d_b,my_size);
	cudaMalloc((void**)&d_c,my_size);

	cudaMemcpy(d_a,a,my_size,cudaMemcpyHostToDevice);
	cudaMemcpy(d_b,b,my_size,cudaMemcpyHostToDevice);

	dim3 my_block(THREAD_PER_BLOCK,THREAD_PER_BLOCK);
	dim3 my_grid((mat_elem + THREAD_PER_BLOCK-1)/my_block.x,(mat_elem + THREAD_PER_BLOCK-1)/my_block.y);

	
    	cudaEventRecord(inicio,0);
	
	//mult_matrix_shared<<<my_grid,my_block>>>(d_a, d_b, d_c,mat_elem);
	mult_matrix<<<my_grid,my_block>>>(d_a, d_b, d_c,mat_elem);
    	cudaEventRecord(final,0);
    	cudaEventSynchronize(final);
    	/////////////////////////////////////////////////////

    	cudaEventElapsedTime(&tiempo,inicio,final);

	cudaMemcpy(c,d_c,my_size,cudaMemcpyDeviceToHost);

	printf("tiempo %d X %d, tam=%d : %0.15f\n",THREAD_PER_BLOCK,THREAD_PER_BLOCK,mat_elem,tiempo);
	return 0;
}

