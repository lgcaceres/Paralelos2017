#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <getopt.h>
#include <string.h>




/*
	g++ -c sort.cpp -o sort.o -fopenmp
	g++ sort.o -o sort -fopenmp -lpthread
*/


void fill_vec(int *a, int n)
{
	int i;

	for(i=0;i<n;i++) {
		a[i] = rand()%100;		
	}
}
void print_vec(int *a, int n){
	int i;
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	printf("\n");
}

void odd_even_sort1(int* a, int n,int threadNumber)
{
  int phase, i, temp;
  for(phase=0;phase<n;++phase)
  {
  	if(phase%2==0) 
    {
    	#pragma omp parallel for num_threads(threadNumber) default(none) shared(a,n) private(i,temp)
      	for(i=1;i<n;i+=2)
			if(a[i-1] > a[i])
			{
	  			temp = a[i];
	  			a[i] = a[i-1];
	  			a[i-1] = temp;
			}
    }
    else 
    {
		#pragma omp parallel for num_threads(threadNumber) default(none) shared(a,n) private(i,temp)
      	for(i=1;i<n-1;i+=2)
			if(a[i] > a[i+1])
			{
      	  		temp = a[i];
	  			a[i] = a[i+1];
	  			a[i+1] = temp;
			}
    }
  }
}

void odd_even_sort2(int* a, int n,int threadNumber)
{
  int phase, i, temp;
  #pragma omp parallel num_threads(threadNumber) default(none) shared(a,n) private(i,temp,phase)
  for(phase=0;phase<n;++phase)
  {
    if(phase%2==0) 
    {
		#pragma omp for
      	for(i=1;i<n;i+=2)
			if(a[i-1] > a[i])
			{
	  			temp = a[i];
	  			a[i] = a[i-1];
	  			a[i-1] = temp;
			}
    }
    else 
    {
		#pragma omp for
      	for(i=1;i<n-1;i+=2)
			if(a[i] > a[i+1])
			{
      	  		temp = a[i];
	  			a[i] = a[i+1];
	  			a[i+1] = temp;
			}
    }
  }
}

int main(int argc,char* argv[])
{
	int thread_count = strtol(argv[1],NULL,10);
	printf("Number of threads: %d\n",thread_count);

	double start1, end1, e1;
 	double start2, end2, e2;

	int n_elems = 20;
	int my_size = n_elems*sizeof(int);

	int* input = (int*) malloc(my_size);
	fill_vec(input,n_elems);

	int* vec1 ,*vec2;
	vec1 = (int*) malloc(my_size);
	vec2 = (int*) malloc(my_size);

	memcpy(vec1,input,my_size);
	memcpy(vec2,input,my_size);
	print_vec(vec1,n_elems);
	print_vec(vec2,n_elems);

	start1 = omp_get_wtime();
  	odd_even_sort1(vec1,n_elems,thread_count);
  	end1 = omp_get_wtime();
  	e1 = end1 - start1;

  	start2 = omp_get_wtime();
  	odd_even_sort2(vec2,n_elems,thread_count);
  	end2 = omp_get_wtime();
  	e2 = end2 - start2;

	print_vec(vec1,n_elems);
	print_vec(vec2,n_elems);

	printf("Method 1 - Elapsed time: %f\n",e1);
  	printf("Method 2 - Elapsed time: %f\n",e2);


	free(input);
	free(vec1);
	free(vec2);
	return 0;
}
