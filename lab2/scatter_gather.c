#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

float Promedio(float* p,int size)
{
	float promedio = 0;
	int i;
	for(i=0;i<size;i++)
	{
		promedio+=p[i];
	}
	return promedio/size;
}

int main()
{
	int world_rank,world_size;
	MPI_Init(NULL,NULL);
	MPI_Comm_size(MPI_COMM_WORLD,&world_size);
	MPI_Comm_rank(MPI_COMM_WORLD,&world_rank);

	int elements_per_proc = 6;
	float* rand_nums = NULL;
	int i,arr_size = world_size*elements_per_proc;
	

	if (world_rank == 0) {
  		
  		rand_nums = malloc(sizeof(float)*arr_size);
		for(i=1;i<=arr_size;i++)
		{
			rand_nums[i-1]=i*1.0;
		}
	}

	
	float *sub_rand_nums = malloc(sizeof(float) * elements_per_proc);

	
	MPI_Scatter(rand_nums, elements_per_proc, MPI_FLOAT, sub_rand_nums,elements_per_proc, MPI_FLOAT, 0, MPI_COMM_WORLD);

	
	float sub_avg = Promedio(sub_rand_nums, elements_per_proc);
	
	float *sub_avgs = NULL;
	if (world_rank == 0) {
	  sub_avgs = malloc(sizeof(float) * world_size);
	}
	MPI_Gather(&sub_avg, 1, MPI_FLOAT, sub_avgs, 1, MPI_FLOAT, 0,
	           MPI_COMM_WORLD);

	
	if (world_rank == 0) {
	  float avg = Promedio(sub_avgs, world_size);
	  printf("Promedio: %f\n",avg);
	}

	MPI_Finalize();
	return 0;
}
